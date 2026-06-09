#!/bin/bash
# shellcheck shell=bash
# Stop: Session learning marker
# Records a one-shot session marker without prompting Claude to continue.
# Stop hooks must not emit advisory messages that ask for another response.

INPUT=$(cat)
: "${INPUT:=}"

SESSION_KEY="${CLAUDE_SESSION_ID:-${PPID:-unknown}}"
LOCK_FILE="${TMPDIR:-/tmp}/claude-session-learning-${SESSION_KEY}"
TRACE_DIR="$HOME/.claude/traces"
MARKER_FILE="$TRACE_DIR/session-learning-reminders.log"

# Persist the lock for the session. Do not remove it on EXIT; removing it causes
# Stop -> reminder output -> assistant response -> Stop loops.
if [ -f "$LOCK_FILE" ]; then
  exit 0
fi

mkdir -p "$TRACE_DIR"
touch "$LOCK_FILE"

printf '%s session=%s reminder=%s\n' \
  "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
  "$SESSION_KEY" \
  "review session for reusable patterns if needed" >> "$MARKER_FILE" 2>/dev/null || true

# Silent success. Emitting a reason here can cause the assistant to keep talking
# at the exact point it is trying to stop.
exit 0
