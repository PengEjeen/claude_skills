#!/bin/bash
# shellcheck shell=bash
# PreToolUse: Test Integrity Gate
# Warns on Edit/Write and blocks git commit when staged changes weaken verification.

INPUT=$(</dev/stdin)

minimal_json() {
  local decision="$1"
  local mode="$2"
  local reason="$3"
  printf '{"decision":"%s","reason":"[TEST INTEGRITY] %s","harness":{"component":"test-integrity-gate","mode":"%s","findings":[]}}\n' "$decision" "$reason" "$mode"
  exit 0
}

if [ "${SKIP_TEST_INTEGRITY:-}" = "1" ]; then
  minimal_json "approve" "bypass" "bypassed by SKIP_TEST_INTEGRITY=1"
fi

if ! command -v jq >/dev/null 2>&1; then
  minimal_json "approve" "advisory" "skipped: jq unavailable"
fi

if ! printf '%s' "$INPUT" | jq -e . >/dev/null 2>&1; then
  minimal_json "approve" "advisory" "skipped: invalid hook input"
fi

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

MODE="advisory"
CONTENT=""
DIFF_CONTEXT=""

case "$TOOL_NAME" in
  Edit|Write)
    CONTENT=$(printf '%s' "$INPUT" | jq -r '.tool_input.new_string // .tool_input.content // empty' 2>/dev/null)
    ;;
  Bash)
    if ! printf '%s' "$COMMAND" | grep -Eq '(^|[;&[:space:]])git[[:space:]]+commit([[:space:]]|$)'; then
      exit 0
    fi
    if printf '%s' "$COMMAND" | grep -Eq '(^|[[:space:]])SKIP_TEST_INTEGRITY=1([[:space:]]|$)'; then
      minimal_json "approve" "bypass" "bypassed by SKIP_TEST_INTEGRITY=1"
    fi
    MODE="blocking"
    DIFF_CONTEXT=$(git diff --cached --no-ext-diff --unified=0 2>/dev/null)
    CONTENT=$(printf '%s\n' "$DIFF_CONTEXT" | grep '^+' | grep -v '^+++' || true)
    ;;
  *)
    exit 0
    ;;
esac

if [ -z "$CONTENT" ]; then
  jq -n --arg mode "$MODE" '{
    decision: "approve",
    reason: "[TEST INTEGRITY] no findings",
    harness: {component: "test-integrity-gate", mode: $mode, findings: []}
  }'
  exit 0
fi

FINDINGS=()

add_finding() {
  local pattern="$1"
  local message="$2"
  local severity="$3"
  FINDINGS+=("$pattern"$'\t'"$message"$'\t'"$severity")
}

detect_pattern() {
  local pattern="$1"
  local regex="$2"
  local message="$3"
  local severity="$4"
  if printf '%s\n' "$CONTENT" | grep -Eq "$regex"; then
    add_finding "$pattern" "$message" "$severity"
  fi
}

detect_pattern "skip-test" '(^|[^[:alnum:]_])(test|it|describe)\.skip[[:space:]]*\(' "Skipped tests were added" "high"
detect_pattern "focused-test" '(^|[^[:alnum:]_])(test|it|describe)\.only[[:space:]]*\(' "Focused tests were added" "high"
detect_pattern "ts-ignore" '@ts-ignore|@ts-nocheck' "TypeScript checking was suppressed" "high"
detect_pattern "lint-disable" 'eslint-disable|biome-ignore' "Lint or formatter checks were suppressed" "medium"
detect_pattern "explicit-any" '(^|[^[:alnum:]_])as[[:space:]]+any([^[:alnum:]_]|$)|:[[:space:]]*any([^[:alnum:]_]|$)' "Explicit any type was added" "medium"
detect_pattern "coverage-threshold" 'coverageThreshold|threshold|branches|functions|lines|statements|fail-under|--cov-fail-under' "Coverage threshold configuration changed; verify it was not lowered" "high"
detect_pattern "weak-assertion" '\.toBeTruthy[[:space:]]*\(|\.toBeDefined[[:space:]]*\(|\.not\.toThrow[[:space:]]*\(' "Potentially weak assertion was added" "low"

if [ "$TOOL_NAME" = "Bash" ] && [ -n "$DIFF_CONTEXT" ]; then
  removed_asserts=$(printf '%s\n' "$DIFF_CONTEXT" | grep '^-' | grep -v '^---' | grep -cE 'expect[[:space:]]*\(|assert[.(]|should[.(]|pytest\.raises|toEqual|toStrictEqual|toThrow' 2>/dev/null || true)
  added_asserts=$(printf '%s\n' "$DIFF_CONTEXT" | grep '^+' | grep -v '^+++' | grep -cE 'expect[[:space:]]*\(|assert[.(]|should[.(]|pytest\.raises|toEqual|toStrictEqual|toThrow' 2>/dev/null || true)
  if [ "$removed_asserts" -gt 0 ] && [ "$added_asserts" -lt "$removed_asserts" ]; then
    add_finding "assertion-removal" "Assertions appear to be removed or weakened in staged changes" "medium"
  fi
fi

if [ "${#FINDINGS[@]}" -eq 0 ]; then
  jq -n --arg mode "$MODE" '{
    decision: "approve",
    reason: "[TEST INTEGRITY] no findings",
    harness: {component: "test-integrity-gate", mode: $mode, findings: []}
  }'
  exit 0
fi

findings_json=$(
  for entry in "${FINDINGS[@]}"; do
    IFS=$'\t' read -r pattern message severity <<EOF
$entry
EOF
    jq -n --arg pattern "$pattern" --arg message "$message" --arg severity "$severity" \
      '{pattern: $pattern, message: $message, severity: $severity}'
  done | jq -s .
)

if [ "$MODE" = "blocking" ]; then
  DECISION="block"
  SUMMARY="blocking findings detected before commit"
else
  DECISION="approve"
  SUMMARY="warning: possible verification weakening detected"
fi

jq -n \
  --arg decision "$DECISION" \
  --arg mode "$MODE" \
  --arg summary "$SUMMARY" \
  --argjson findings "$findings_json" \
  '{
    decision: $decision,
    reason: ("[TEST INTEGRITY] " + $summary),
    harness: {
      component: "test-integrity-gate",
      mode: $mode,
      findings: $findings
    }
  }'

exit 0
