#!/bin/bash
# shellcheck shell=bash
# PostToolUse (Edit|Write): Verification Planner
# Builds an advisory verification plan for the changed file without running heavy checks.

INPUT=$(</dev/stdin)

skipped() {
  local reason="$1"
  printf '{"decision":"approve","reason":"[Verification Planner] skipped: %s","harness":{"component":"verification-planner","changed_file":"","risk":"low","checks":[],"manual_checks":[]}}\n' "$reason"
  exit 0
}

if ! command -v jq >/dev/null 2>&1; then
  skipped "jq unavailable"
fi

if ! printf '%s' "$INPUT" | jq -e . >/dev/null 2>&1; then
  skipped "invalid hook input"
fi

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null) || skipped "tool parse failed"
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || skipped "file path parse failed"
if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "null" ]; then
  skipped "empty file path"
fi

CHECKS=()
MANUAL_CHECKS=()
RISK="low"

append_unique() {
  local value="$1"
  local current
  for current in "${VALUES_REF[@]}"; do
    if [ "$current" = "$value" ]; then
      return 0
    fi
  done
  VALUES_REF+=("$value")
}

add_check() {
  CHECKS+=("$1"$'\t'"$2"$'\t'"$3")
}

add_manual_check() {
  VALUES_REF=("${MANUAL_CHECKS[@]}")
  append_unique "$1"
  MANUAL_CHECKS=("${VALUES_REF[@]}")
}

set_risk() {
  case "$1:$RISK" in
    high:*) RISK="high" ;;
    medium:low) RISK="medium" ;;
  esac
}

find_up() {
  local start_dir="$1"
  local target="$2"
  local dir="$start_dir"
  local depth=0

  if [ ! -d "$dir" ]; then
    dir="."
  fi

  while [ "$depth" -lt 10 ]; do
    if [ -f "$dir/$target" ]; then
      printf '%s/%s\n' "$dir" "$target"
      return 0
    fi
    [ "$dir" = "." ] && break
    [ "$dir" = "/" ] && break
    dir=$(dirname "$dir")
    depth=$((depth + 1))
  done

  if [ -f "$target" ]; then
    printf '%s\n' "$target"
    return 0
  fi

  return 1
}

has_pytest_tests() {
  find . -maxdepth 4 \( -name "test_*.py" -o -name "*_test.py" \) 2>/dev/null | head -1 | grep -q .
}

detect_package_manager() {
  local package_dir="$1"

  if [ -f "$package_dir/pnpm-lock.yaml" ]; then
    printf 'pnpm\n'
  elif [ -f "$package_dir/yarn.lock" ]; then
    printf 'yarn\n'
  elif [ -f "$package_dir/bun.lock" ] || [ -f "$package_dir/bun.lockb" ]; then
    printf 'bun\n'
  elif [ -f "$package_dir/package-lock.json" ]; then
    printf 'npm\n'
  else
    printf 'npm\n'
  fi
}

script_command() {
  local package_manager="$1"
  local script_name="$2"

  case "$package_manager" in
    pnpm) printf 'pnpm %s\n' "$script_name" ;;
    yarn) printf 'yarn %s\n' "$script_name" ;;
    bun) printf 'bun run %s\n' "$script_name" ;;
    *) printf 'npm run %s\n' "$script_name" ;;
  esac
}

file_lc=$(printf '%s' "$FILE_PATH" | tr '[:upper:]' '[:lower:]')
basename_lc=$(basename "$file_lc")
ext="${file_lc##*.}"
dirname_path=$(dirname "$FILE_PATH")

case "$file_lc" in
  *.ts|*.tsx|*.js|*.jsx)
    set_risk "medium"
    package_json=$(find_up "$dirname_path" "package.json" || true)
    if [ -n "$package_json" ]; then
      package_dir=$(dirname "$package_json")
      package_manager=$(detect_package_manager "$package_dir")
      if jq -e '.scripts.typecheck? // empty' "$package_json" >/dev/null 2>&1; then
        add_check "TypeScript typecheck" "$(script_command "$package_manager" "typecheck")" "true"
      fi
      if jq -e '.scripts.test? // empty' "$package_json" >/dev/null 2>&1; then
        add_check "JavaScript test suite" "$(script_command "$package_manager" "test")" "true"
      fi
      if jq -e '.scripts.lint? // empty' "$package_json" >/dev/null 2>&1; then
        add_check "JavaScript lint" "$(script_command "$package_manager" "lint")" "false"
      fi
      if jq -e '.scripts.build? // empty' "$package_json" >/dev/null 2>&1; then
        add_check "JavaScript build" "$(script_command "$package_manager" "build")" "false"
      fi
    else
      add_manual_check "package.json not found; verify typecheck/test command manually"
    fi
    if printf '%s' "$file_lc" | grep -Eq 'auth|session|token|permission'; then
      set_risk "high"
      add_manual_check "security-reviewer: review auth/session/token/permission impact"
    fi
    ;;
  *.py)
    set_risk "medium"
    if command -v ruff >/dev/null 2>&1; then
      add_check "Python lint" "ruff check ." "true"
    fi
    if has_pytest_tests; then
      add_check "Python tests" "python -m pytest -q" "true"
    fi
    ;;
  *.sql|*migration*|*migrations*)
    set_risk "high"
    add_manual_check "database-reviewer: review migration/schema/data impact"
    add_manual_check "Confirm rollback path before merge"
    add_manual_check "Check RLS/policy impact"
    add_manual_check "Do not auto-apply this migration"
    ;;
  *.tf)
    set_risk "high"
    if command -v terraform >/dev/null 2>&1; then
      add_check "Terraform validate" "terraform validate" "true"
    fi
    add_manual_check "Plan only: review terraform plan output; do not apply"
    ;;
  dockerfile|*.dockerfile|*.yml|*.yaml)
    set_risk "medium"
    add_manual_check "infrastructure-agent: review container, deployment, or YAML configuration impact"
    ;;
  *)
    RISK="low"
    ;;
esac

checks_json=$(
  for entry in "${CHECKS[@]}"; do
    IFS=$'\t' read -r name command blocking <<EOF
$entry
EOF
    jq -n \
      --arg name "$name" \
      --arg command "$command" \
      --argjson blocking "$blocking" \
      '{name: $name, command: $command, blocking: $blocking}'
  done | jq -s .
)

manual_json=$(printf '%s\n' "${MANUAL_CHECKS[@]}" | jq -R -s 'split("\n") | map(select(length > 0))')

jq -n \
  --arg reason "[Verification Planner] ${FILE_PATH}" \
  --arg changed_file "$FILE_PATH" \
  --arg risk "$RISK" \
  --argjson checks "$checks_json" \
  --argjson manual_checks "$manual_json" \
  '{
    decision: "approve",
    reason: $reason,
    harness: {
      component: "verification-planner",
      changed_file: $changed_file,
      risk: $risk,
      checks: $checks,
      manual_checks: $manual_checks
    }
  }'

exit 0
