#!/bin/bash
# shellcheck shell=bash
# MainAgentTokenDepletion: Token Budget Warning Handler
# 토큰이 부족할 때 자동으로 compact/clear 권장 메시지 출력
# Source: src/types/hooks.ts - MainAgentTokenDepletion event

INPUT=$(cat)

# Extract token info if available
TOKENS_USED=$(echo "$INPUT" | jq -r '.tokensUsed // 0' 2>/dev/null)
TOKENS_LIMIT=$(echo "$INPUT" | jq -r '.tokensLimit // 0' 2>/dev/null)

# Log the event
LOG_DIR="${HOME}/.claude/traces"
mkdir -p "$LOG_DIR"
echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"MainAgentTokenDepletion\",\"tokensUsed\":${TOKENS_USED},\"tokensLimit\":${TOKENS_LIMIT},\"session\":\"${CLAUDE_SESSION_ID:-unknown}\"}" >> "${LOG_DIR}/token-events.jsonl"

# Output warning to stderr (visible to user)
echo "" >&2
echo "╔══════════════════════════════════════════════════════╗" >&2
echo "║  ⚠️  TOKEN BUDGET WARNING — 토큰이 부족합니다           ║" >&2
echo "╠══════════════════════════════════════════════════════╣" >&2
echo "║  권장 조치:                                           ║" >&2
echo "║  • /compact  — 대화 압축 (정보 보존, 권장)              ║" >&2
echo "║  • /clear    — 새 세션 시작 (완전 초기화)               ║" >&2
echo "║                                                      ║" >&2
echo "║  context-management.md: 70% 도달 시 /compact 실행     ║" >&2
echo "╚══════════════════════════════════════════════════════╝" >&2
echo "" >&2

exit 0
