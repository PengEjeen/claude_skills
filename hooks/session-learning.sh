#!/bin/bash
# shellcheck shell=bash
# Stop: Session learning reminder
# Reminds to extract patterns before session ends
# Output format: {"decision":"approve","reason":"..."}

INPUT=$(cat)

# Session-specific lock to prevent infinite loop
SESSION_KEY="${CLAUDE_SESSION_ID:-$$}"
LOCK_FILE="${TMPDIR:-/tmp}/claude-session-learning-${SESSION_KEY}"
trap 'rm -f "$LOCK_FILE"' EXIT

if [ -f "$LOCK_FILE" ]; then
  exit 0
fi
touch "$LOCK_FILE"

jq -n '{
  decision: "approve",
  reason: "[LEARNING] If new patterns or error resolutions were discovered in this session, summarize the key 1-2 takeaways."
}'

exit 0
