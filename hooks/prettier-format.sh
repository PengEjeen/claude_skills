#!/bin/bash
# shellcheck shell=bash
# PostToolUse: Auto-format JS/TS/CSS/JSON files with Prettier
# Project-level hook (depends on project's node_modules)
# Output format: {"decision":"approve","reason":"..."}

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only format supported file types
if ! echo "$FILE_PATH" | grep -qiE '\.(js|jsx|ts|tsx|css|scss|json|html|yaml|yml)$'; then
  exit 0
fi

# Skip node_modules, dist, build
if echo "$FILE_PATH" | grep -qE '(node_modules|dist|build|\.min\.)'; then
  exit 0
fi

# Find project root (look for package.json upward from file, max 10 levels)
DIR=$(dirname "$FILE_PATH")
PROJECT_ROOT=""
DEPTH=0
while [ "$DIR" != "/" ] && [ "$DIR" != "." ] && [ $DEPTH -lt 10 ]; do
  if [ -f "$DIR/package.json" ]; then
    PROJECT_ROOT="$DIR"
    break
  fi
  DIR=$(dirname "$DIR")
  ((DEPTH++))
done

if [ -z "$PROJECT_ROOT" ]; then
  exit 0
fi

# Check if prettier is available in project
PRETTIER="$PROJECT_ROOT/node_modules/.bin/prettier"
if [ ! -f "$PRETTIER" ]; then
  exit 0
fi

# Run prettier
BASENAME=$(basename "$FILE_PATH")
if "$PRETTIER" --write "$FILE_PATH" 2>/dev/null; then
  jq -n --arg f "$BASENAME" '{
    decision: "approve",
    reason: ("[FORMAT] Prettier auto-formatted: " + $f)
  }'
else
  jq -n --arg f "$BASENAME" '{
    decision: "approve",
    reason: ("[FORMAT] Prettier failed on: " + $f + ". Check for syntax errors.")
  }'
fi

exit 0
