#!/bin/bash
# shellcheck shell=bash
# PostToolUse: Loop Detection Middleware
# Tracks file edit counts per session and warns when threshold exceeded
# Output format: {"decision":"approve","reason":"..."}

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only track Edit and Write tools
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Track edits in a temp file keyed by session
# Use CLAUDE_SESSION_ID if available, otherwise use PID-based isolation
SESSION_KEY="${CLAUDE_SESSION_ID:-$$}"
TRACK_DIR="${TMPDIR:-/tmp}/claude-loop-detector-${SESSION_KEY}"
mkdir -p "$TRACK_DIR"

# Cross-platform hash: shasum (macOS/Linux) > md5sum (Linux) > md5 (macOS) > fallback
FILE_KEY=$(echo "$FILE_PATH" | shasum -a 256 2>/dev/null | cut -d' ' -f1 \
  || echo "$FILE_PATH" | md5sum 2>/dev/null | cut -d' ' -f1 \
  || echo "$FILE_PATH" | md5 -q 2>/dev/null \
  || echo "$FILE_PATH" | tr -cd '[:alnum:]')
TRACK_FILE="$TRACK_DIR/$FILE_KEY"

# Increment counter
if [ -f "$TRACK_FILE" ]; then
  COUNT=$(cat "$TRACK_FILE")
  COUNT=$((COUNT + 1))
else
  COUNT=1
fi
echo "$COUNT" > "$TRACK_FILE"

BASENAME=$(basename "$FILE_PATH")
THRESHOLD=4

if [ "$COUNT" -ge "$THRESHOLD" ]; then
  jq -n --arg f "$BASENAME" --arg c "$COUNT" '{
    decision: "approve",
    reason: ("[LOOP] " + $f + ": " + $c + " edits this session. Doom loop risk — reassess approach (workflow.md). If same error 2+x, use /clear.")
  }'
fi

exit 0
