#!/bin/bash
# shellcheck shell=bash
# PermissionDenied: Permission Audit Logger
# 권한 거부 이벤트를 감사 로그에 기록 (async - non-blocking)
# Source: src/types/hooks.ts - PermissionDenied event

INPUT=$(cat)

# Extract denied permission info
TOOL=$(echo "$INPUT" | jq -r '.tool_name // .toolName // "unknown"' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .input // ""' 2>/dev/null | head -c 200)
REASON=$(echo "$INPUT" | jq -r '.reason // "no reason given"' 2>/dev/null)

# Log to permission audit file
LOG_DIR="${HOME}/.claude/traces"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/permission-denied.jsonl"

echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"PermissionDenied\",\"tool\":\"${TOOL}\",\"command\":\"${COMMAND}\",\"reason\":\"${REASON}\",\"session\":\"${CLAUDE_SESSION_ID:-unknown}\"}" >> "$LOG_FILE"

# Check for repeated denials (possible confused agent)
SESSION_KEY="${CLAUDE_SESSION_ID:-default}"
DENY_COUNTER="${TMPDIR:-/tmp}/claude-deny-count-${SESSION_KEY}"
DENY_COUNT=0
if [ -f "$DENY_COUNTER" ]; then
  DENY_COUNT=$(cat "$DENY_COUNTER" 2>/dev/null || echo "0")
fi
DENY_COUNT=$((DENY_COUNT + 1))
echo "$DENY_COUNT" > "$DENY_COUNTER"

# After 3+ denials, escalate to stderr
if [ "$DENY_COUNT" -ge 3 ]; then
  echo "" >&2
  echo "[PERMISSION AUDIT] 이 세션에서 ${DENY_COUNT}번 권한 거부됨" >&2
  echo "  거부된 도구: ${TOOL}" >&2
  echo "  로그: ${LOG_FILE}" >&2
  echo "  지속 거부 시 settings.json permissions.allow 설정 확인 권장" >&2
fi

exit 0
