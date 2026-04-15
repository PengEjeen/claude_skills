#!/bin/bash
# shellcheck shell=bash
# PostToolUse: Type-check TypeScript files after edit
# Project-level hook (depends on project's tsconfig.json)
# Output format: {"decision":"approve|block","reason":"..."}

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check TS/TSX files
if ! echo "$FILE_PATH" | grep -qiE '\.(ts|tsx)$'; then
  exit 0
fi

# Skip declaration files and node_modules
if echo "$FILE_PATH" | grep -qE '(\.d\.ts$|node_modules)'; then
  exit 0
fi

# Find project root with tsconfig.json (max 10 levels)
DIR=$(dirname "$FILE_PATH")
PROJECT_ROOT=""
DEPTH=0
while [ "$DIR" != "/" ] && [ "$DIR" != "." ] && [ $DEPTH -lt 10 ]; do
  if [ -f "$DIR/tsconfig.json" ]; then
    PROJECT_ROOT="$DIR"
    break
  fi
  DIR=$(dirname "$DIR")
  ((DEPTH++))
done

if [ -z "$PROJECT_ROOT" ]; then
  exit 0
fi

# Check if tsc is available
TSC="$PROJECT_ROOT/node_modules/.bin/tsc"
if [ ! -f "$TSC" ]; then
  exit 0
fi

# Run tsc --noEmit with incremental for speed
ERRORS=$("$TSC" --noEmit --incremental --tsBuildInfoFile /tmp/.tsbuildinfo --pretty false 2>&1 | head -20)

if [ -n "$ERRORS" ] && echo "$ERRORS" | grep -q "error TS"; then
  ERROR_COUNT=$(echo "$ERRORS" | grep -c "error TS")
  SAMPLE=$(echo "$ERRORS" | head -10)
  BASENAME=$(basename "$FILE_PATH")
  jq -n --arg cnt "$ERROR_COUNT" --arg f "$BASENAME" --arg s "$SAMPLE" '{
    decision: "approve",
    reason: ("[TSC] " + $cnt + " TypeScript error(s) after editing " + $f + ":\n" + $s + "\n\nFix these before proceeding.")
  }'
fi

exit 0
