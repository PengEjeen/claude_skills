#!/bin/bash
# shellcheck shell=bash
# SubagentStart: Subagent Context Injector
# 서브에이전트 시작 시 핵심 컨텍스트 로깅 및 기록
# Source: src/types/hooks.ts - SubagentStart event

INPUT=$(cat)

# Extract subagent info
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agentType // "unknown"' 2>/dev/null)
AGENT_ID=$(echo "$INPUT" | jq -r '.agentId // "unknown"' 2>/dev/null)

# Log subagent start
LOG_DIR="${HOME}/.claude/traces"
mkdir -p "$LOG_DIR"
echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"SubagentStart\",\"agentType\":\"${AGENT_TYPE}\",\"agentId\":\"${AGENT_ID}\",\"session\":\"${CLAUDE_SESSION_ID:-unknown}\"}" >> "${LOG_DIR}/subagent-log.jsonl"

# Count active subagents in this session
SESSION_KEY="${CLAUDE_SESSION_ID:-default}"
COUNTER_FILE="${TMPDIR:-/tmp}/claude-subagent-count-${SESSION_KEY}"
COUNT=0
if [ -f "$COUNTER_FILE" ]; then
  COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
fi
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Warn on excessive subagent spawning (potential loop)
if [ "$COUNT" -gt 10 ]; then
  echo "" >&2
  echo "[SUBAGENT WARNING] 이 세션에서 ${COUNT}번째 서브에이전트가 시작됩니다." >&2
  echo "  과도한 서브에이전트 spawning은 비효율의 신호일 수 있습니다." >&2
  echo "  현재 작업 목표를 재확인하세요." >&2
fi

exit 0
