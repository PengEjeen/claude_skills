#!/bin/bash
# shellcheck shell=bash
# PreToolUse: Enforce 80%+ test coverage before git commit
# Triggers on: Bash(git commit*)
# Blocks commit if test coverage is below 80%
# Output format: JSON {"decision":"block","reason":"..."} or {"decision":"approve"}

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only trigger on git commit commands
if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
  exit 0
fi

# --- Cache check (10-minute TTL) ---
SESSION_KEY="${CLAUDE_SESSION_ID:-default}"
CACHE_DIR="${TMPDIR:-/tmp}/claude-coverage-cache"
CACHE_FILE="${CACHE_DIR}/coverage-${SESSION_KEY}.json"
LOCK_FILE="${CACHE_DIR}/coverage-${SESSION_KEY}.lock"

mkdir -p "$CACHE_DIR" 2>/dev/null

# Prevent parallel execution with lock file
if [ -f "$LOCK_FILE" ]; then
  # Another coverage check is running — approve to avoid deadlock
  exit 0
fi

# Check cache (valid for 600 seconds = 10 minutes)
if [ -f "$CACHE_FILE" ]; then
  if command -v stat &>/dev/null; then
    MOD_TIME=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null)
    if [ -n "$MOD_TIME" ]; then
      NOW=$(date +%s)
      AGE=$(( NOW - MOD_TIME ))
      if [ "$AGE" -lt 600 ]; then
        # Return cached result
        cat "$CACHE_FILE"
        exit 0
      fi
    fi
  fi
fi

# --- Detect project type ---
HAS_PYTHON=false
HAS_NODE=false
HAS_GO=false

# Python: check for test files
if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "setup.cfg" ]; then
  if find . -maxdepth 4 -name "test_*.py" -o -name "*_test.py" 2>/dev/null | head -1 | grep -q .; then
    HAS_PYTHON=true
  fi
fi

# Node: check for test files and vitest config
if [ -f "package.json" ]; then
  if find . -maxdepth 4 \( -name "*.test.ts" -o -name "*.test.js" -o -name "*.spec.ts" -o -name "*.spec.js" \) 2>/dev/null | head -1 | grep -q .; then
    HAS_NODE=true
  fi
fi

# Go: check for test files
if [ -f "go.mod" ]; then
  if find . -maxdepth 4 -name "*_test.go" 2>/dev/null | head -1 | grep -q .; then
    HAS_GO=true
  fi
fi

# No test framework detected — silently approve
if [ "$HAS_PYTHON" = false ] && [ "$HAS_NODE" = false ] && [ "$HAS_GO" = false ]; then
  exit 0
fi

# --- Run coverage check (5-second timeout) ---
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

COVERAGE_PASS=false
COVERAGE_OUTPUT=""
FRAMEWORK=""

if [ "$HAS_PYTHON" = true ]; then
  FRAMEWORK="Python (pytest + coverage)"
  COVERAGE_OUTPUT=$(timeout 5 bash -c 'coverage run -m pytest --tb=no -q 2>/dev/null && coverage report --fail-under=80 2>/dev/null' 2>&1)
  COVERAGE_EXIT=$?
  if [ $COVERAGE_EXIT -eq 124 ]; then
    # Timeout — approve with warning
    RESULT='{"decision":"approve"}'
    echo "$RESULT" | tee "$CACHE_FILE"
    exit 0
  elif [ $COVERAGE_EXIT -eq 0 ]; then
    COVERAGE_PASS=true
  fi
fi

if [ "$HAS_NODE" = true ] && [ "$COVERAGE_PASS" = false ] && [ -z "$FRAMEWORK" ]; then
  FRAMEWORK="Node (vitest)"
  COVERAGE_OUTPUT=$(timeout 5 bash -c 'npx vitest run --coverage --reporter=json 2>/dev/null' 2>&1)
  COVERAGE_EXIT=$?
  if [ $COVERAGE_EXIT -eq 124 ]; then
    RESULT='{"decision":"approve"}'
    echo "$RESULT" | tee "$CACHE_FILE"
    exit 0
  elif [ $COVERAGE_EXIT -eq 0 ]; then
    COVERAGE_PASS=true
  fi
fi

if [ "$HAS_GO" = true ] && [ "$COVERAGE_PASS" = false ] && [ -z "$FRAMEWORK" ]; then
  FRAMEWORK="Go"
  COVERAGE_OUTPUT=$(timeout 5 bash -c 'go test -cover ./... 2>/dev/null' 2>&1)
  COVERAGE_EXIT=$?
  if [ $COVERAGE_EXIT -eq 124 ]; then
    RESULT='{"decision":"approve"}'
    echo "$RESULT" | tee "$CACHE_FILE"
    exit 0
  elif [ $COVERAGE_EXIT -eq 0 ]; then
    COVERAGE_PASS=true
  fi
fi

# --- Produce result ---
if [ "$COVERAGE_PASS" = true ]; then
  RESULT='{"decision":"approve"}'
  echo "$RESULT" | tee "$CACHE_FILE"
  exit 0
fi

# Coverage failed — extract meaningful summary (first 3 lines of output)
SUMMARY=$(echo "$COVERAGE_OUTPUT" | tail -5 | head -3 | tr '\n' ' ' | sed 's/"/\\"/g' | cut -c 1-200)
REASON="[COVERAGE GATE] ${FRAMEWORK} coverage < 80%. ${SUMMARY}. Run tests and improve coverage before committing."

RESULT=$(printf '{"decision":"block","reason":"%s"}' "$REASON")
echo "$RESULT" | tee "$CACHE_FILE"
exit 0
