#!/bin/bash
# shellcheck shell=bash
# PostToolUse: Warn when console.log is added to code
# Matches Edit and Write tools on JS/TS files
# Output format: {"decision":"approve|block","reason":"..."}

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check JS/TS files
if ! echo "$FILE_PATH" | grep -qiE '\.(js|jsx|ts|tsx|mjs|cjs)$'; then
  exit 0
fi

# For Edit: check new_string, For Write: check content
if [ "$TOOL_NAME" = "Edit" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty')
else
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
fi

if echo "$CONTENT" | grep -qE 'console\.(log|debug|info|warn|error|trace)\('; then
  jq -n --arg fp "$FILE_PATH" '{
    decision: "approve",
    reason: ("[WARN] console.log/debug/info/warn/error/trace detected in " + $fp + ". Consider: (1) Is this debug code that should be removed before commit? (2) Should this use a proper logger instead? (3) If intentional, add a comment explaining why.")
  }'
  exit 0
fi

exit 0
