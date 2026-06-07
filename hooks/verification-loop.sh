#!/bin/bash
# shellcheck shell=bash
# PostToolUse (Edit|MultiEdit|Write): Verification Loop
# 코드 변경 후 관련 테스트를 자동 실행하고, 실패 시 피드백을 컨텍스트에 주입
# Spotify Honk 패턴: 환각 34% 감소, 코드 품질 28% 향상
# Dust.tt verification loop: test -> parse -> feedback cycle
# Output format: {"decision":"approve","reason":"..."}

INPUT=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  printf '{"decision":"approve","reason":"[Verification Loop] skipped: jq unavailable"}\n'
  exit 0
fi

if ! printf '%s' "$INPUT" | jq -e . >/dev/null 2>&1; then
  printf '{"decision":"approve","reason":"[Verification Loop] skipped: invalid hook input"}\n'
  exit 0
fi

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')

# Only trigger on Edit, MultiEdit, or Write
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "MultiEdit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')

# No file path detected
if [ -z "$FILE_PATH" ] || [ "$FILE_PATH" = "null" ]; then
  exit 0
fi

# Only run for source code files
case "$FILE_PATH" in
  *.py|*.ts|*.tsx|*.js|*.jsx|*.go|*.rs) ;;
  *) exit 0 ;;
esac

# Skip test files to avoid infinite loop
case "$FILE_PATH" in
  *test*|*spec*|*_test.*|*.test.*|*.spec.*|*__tests__*) exit 0 ;;
esac

# Skip files in node_modules, dist, build, vendor, etc.
case "$FILE_PATH" in
  *node_modules*|*dist/*|*build/*|*vendor/*|*.min.*) exit 0 ;;
esac

# Session-and-file-specific lock to prevent parallel duplicate runs without skipping later files
SESSION_KEY="${CLAUDE_SESSION_ID:-$$}"
FILE_KEY=$(printf '%s' "$FILE_PATH" | sha256sum | awk '{print $1}')
LOCK_FILE="${TMPDIR:-/tmp}/claude-verify-loop-${SESSION_KEY}-${FILE_KEY}"

# Debounce: don't rerun the same file immediately after formatter-induced edits
if [ -f "$LOCK_FILE" ]; then
  LOCK_MOD=$(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  LOCK_AGE=$(( NOW - LOCK_MOD ))
  if [ "$LOCK_AGE" -lt 5 ]; then
    exit 0
  fi
fi
touch "$LOCK_FILE"

# Resolve file components
BASENAME=$(basename "$FILE_PATH")
DIRNAME=$(dirname "$FILE_PATH")
NAME_NO_EXT="${BASENAME%.*}"
EXT="${BASENAME##*.}"
TEST_FILE=""
TEST_KIND=""

# Detect project type and find related test file
case "$EXT" in
  py)
    # Python: look for test_*.py or *_test.py in multiple locations
    for candidate in \
      "${DIRNAME}/test_${NAME_NO_EXT}.py" \
      "${DIRNAME}/${NAME_NO_EXT}_test.py" \
      "${DIRNAME}/tests/test_${NAME_NO_EXT}.py" \
      "${DIRNAME}/../tests/test_${NAME_NO_EXT}.py" \
      "tests/test_${NAME_NO_EXT}.py" \
      "test/test_${NAME_NO_EXT}.py"; do
      if [ -f "$candidate" ]; then
        TEST_FILE="$candidate"
        TEST_KIND="pytest"
        break
      fi
    done
    ;;
  ts|tsx)
    # TypeScript: look for *.test.ts(x), *.spec.ts(x)
    for suffix in "test" "spec"; do
      for candidate in \
        "${DIRNAME}/${NAME_NO_EXT}.${suffix}.${EXT}" \
        "${DIRNAME}/${NAME_NO_EXT}.${suffix}.ts" \
        "${DIRNAME}/__tests__/${NAME_NO_EXT}.${suffix}.${EXT}" \
        "${DIRNAME}/__tests__/${NAME_NO_EXT}.${suffix}.ts" \
        "${DIRNAME}/../__tests__/${NAME_NO_EXT}.${suffix}.${EXT}"; do
        if [ -f "$candidate" ]; then
          TEST_FILE="$candidate"
          if [ -f "vitest.config.ts" ] || [ -f "vitest.config.js" ] || [ -f "vite.config.ts" ]; then
            TEST_KIND="vitest"
          else
            TEST_KIND="jest"
          fi
          break 2
        fi
      done
    done
    ;;
  js|jsx)
    # JavaScript: look for *.test.js(x), *.spec.js(x)
    for suffix in "test" "spec"; do
      for candidate in \
        "${DIRNAME}/${NAME_NO_EXT}.${suffix}.${EXT}" \
        "${DIRNAME}/${NAME_NO_EXT}.${suffix}.js" \
        "${DIRNAME}/__tests__/${NAME_NO_EXT}.${suffix}.${EXT}" \
        "${DIRNAME}/__tests__/${NAME_NO_EXT}.${suffix}.js" \
        "${DIRNAME}/../__tests__/${NAME_NO_EXT}.${suffix}.${EXT}"; do
        if [ -f "$candidate" ]; then
          TEST_FILE="$candidate"
          if [ -f "vitest.config.ts" ] || [ -f "vitest.config.js" ] || [ -f "vite.config.ts" ]; then
            TEST_KIND="vitest"
          else
            TEST_KIND="jest"
          fi
          break 2
        fi
      done
    done
    ;;
  go)
    # Go: run tests in the same package directory
    GO_TEST_FILE=$(find "$DIRNAME" -maxdepth 1 -name "*_test.go" -print -quit 2>/dev/null)
    if [ -n "$GO_TEST_FILE" ]; then
      TEST_FILE="$GO_TEST_FILE"
      TEST_KIND="go"
    fi
    ;;
  rs)
    # Rust: run cargo test for the specific module
    if grep -qE '#\[cfg\(test\)\]|#\[test\]' "$FILE_PATH" 2>/dev/null; then
      TEST_FILE="$FILE_PATH"
      TEST_KIND="cargo-lib"
    elif [ -d "${DIRNAME}/../tests" ]; then
      RS_TEST=$(find "${DIRNAME}/../tests" -name "${NAME_NO_EXT}*.rs" -print -quit 2>/dev/null)
      if [ -n "$RS_TEST" ]; then
        TEST_FILE="$RS_TEST"
        TEST_KIND="cargo-test"
      fi
    fi
    ;;
esac

# No related test file found -- silent exit
if [ -z "$TEST_FILE" ] || [ -z "$TEST_KIND" ]; then
  exit 0
fi

# Run test with 5-second timeout
case "$TEST_KIND" in
  pytest)
    RESULT=$(timeout 5 python -m pytest "$TEST_FILE" --tb=short -q --no-header 2>&1)
    EXIT_CODE=$?
    ;;
  vitest)
    RESULT=$(timeout 5 npx vitest run "$TEST_FILE" --reporter=verbose 2>&1)
    EXIT_CODE=$?
    ;;
  jest)
    RESULT=$(timeout 5 npx jest "$TEST_FILE" --no-coverage --verbose 2>&1)
    EXIT_CODE=$?
    ;;
  go)
    RESULT=$(cd "$DIRNAME" && timeout 5 go test -v -run . -count=1 -timeout 5s 2>&1)
    EXIT_CODE=$?
    ;;
  cargo-lib)
    RESULT=$(timeout 5 cargo test --lib -- "$NAME_NO_EXT" 2>&1)
    EXIT_CODE=$?
    ;;
  cargo-test)
    RESULT=$(timeout 5 cargo test --test "$NAME_NO_EXT" 2>&1)
    EXIT_CODE=$?
    ;;
  *)
    exit 0
    ;;
esac

# Timeout (exit 124) -- don't block, just note it
if [ "$EXIT_CODE" -eq 124 ]; then
  jq -n --arg tf "$TEST_FILE" '{
    decision: "approve",
    reason: ("[Verification Loop] test timeout (5s). Manual run recommended: " + $tf)
  }'
  exit 0
fi

# Tests passed -- silent success, don't clutter output
if [ "$EXIT_CODE" -eq 0 ]; then
  exit 0
fi

# Tests FAILED -- extract failure summary and inject feedback
# Take last 20 lines for concise failure context
FAILURE_SUMMARY=$(echo "$RESULT" | tail -20)

# Save failure to traces for regression-gate cross-reference
TRACE_DIR="$HOME/.claude/traces"
mkdir -p "$TRACE_DIR"
echo "${TEST_FILE}: $(echo "$FAILURE_SUMMARY" | head -5)" >> "${TRACE_DIR}/last-test-failures.txt"

# Output structured feedback as JSON
jq -n \
  --arg fp "$FILE_PATH" \
  --arg tf "$TEST_FILE" \
  --arg summary "$FAILURE_SUMMARY" \
  '{
    decision: "approve",
    reason: ("[Verification Loop] Related test FAILED after code change.\nSource: " + $fp + "\nTest: " + $tf + "\n\nFailure output:\n" + $summary + "\n\nFix the failing tests before proceeding. Tests will auto-rerun on next edit.")
  }'

exit 0