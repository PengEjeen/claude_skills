#!/bin/bash
# shellcheck shell=bash
# PostToolUse: Auto-lint and format Python files with ruff
# Project-level hook (depends on ruff being installed in venv or globally)
# Output format: {"decision":"approve","reason":"..."}

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check Python files
if ! echo "$FILE_PATH" | grep -qiE '\.py$'; then
  exit 0
fi

# Skip migrations, venv, __pycache__
if echo "$FILE_PATH" | grep -qE '(migrations/|venv/|__pycache__|\.pyc$|site-packages)'; then
  exit 0
fi

# Try project venv ruff first (check pyproject.toml/setup.py location for project root)
RUFF=""
DIR=$(dirname "$FILE_PATH")
PROJECT_ROOT=""
DEPTH=0
while [ "$DIR" != "/" ] && [ "$DIR" != "." ] && [ $DEPTH -lt 10 ]; do
  # Check for project markers first
  if [ -f "$DIR/pyproject.toml" ] || [ -f "$DIR/setup.py" ] || [ -f "$DIR/setup.cfg" ]; then
    PROJECT_ROOT="$DIR"
  fi
  # Check for venv ruff
  for CANDIDATE in "$DIR/.venv/bin/ruff" "$DIR/venv/bin/ruff" "$DIR/.venv/Scripts/ruff.exe" "$DIR/venv/Scripts/ruff.exe"; do
    if [ -f "$CANDIDATE" ]; then
      RUFF="$CANDIDATE"
      break 2
    fi
  done
  DIR=$(dirname "$DIR")
  ((DEPTH++))
done

# Fallback to global ruff
if [ -z "$RUFF" ]; then
  RUFF=$(command -v ruff 2>/dev/null)
fi

if [ -z "$RUFF" ]; then
  exit 0
fi

# Run ruff check --fix then format (capture both outputs)
BASENAME=$(basename "$FILE_PATH")
CHECK_OUTPUT=$("$RUFF" check --fix "$FILE_PATH" 2>&1)
CHECK_EXIT=$?
FORMAT_OUTPUT=$("$RUFF" format "$FILE_PATH" 2>&1)
FORMAT_EXIT=$?

if [ $CHECK_EXIT -ne 0 ] && echo "$CHECK_OUTPUT" | grep -qE 'Found [1-9]'; then
  jq -n --arg f "$BASENAME" --arg issues "$CHECK_OUTPUT" '{
    decision: "approve",
    reason: ("[RUFF] Auto-fixed lint issues in " + $f + ":\n" + $issues + "\nFormatted with ruff format.")
  }'
elif [ $FORMAT_EXIT -ne 0 ]; then
  jq -n --arg f "$BASENAME" --arg err "$FORMAT_OUTPUT" '{
    decision: "approve",
    reason: ("[RUFF] Format failed on " + $f + ": " + $err)
  }'
else
  jq -n --arg f "$BASENAME" '{
    decision: "approve",
    reason: ("[RUFF] Formatted: " + $f)
  }'
fi

exit 0
