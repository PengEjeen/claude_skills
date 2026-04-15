#!/bin/bash
# shellcheck shell=bash
# PreToolUse (Bash git commit*): Code Quality Gate
# 커밋 전 staged diff를 분석하여 명백한 문제 차단
# Output format: {"decision":"approve|block","reason":"..."}

INPUT=$(cat)
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# git commit 명령만 대상
if ! echo "$TOOL_INPUT" | grep -qE '^git commit'; then
  exit 0
fi

DIFF=$(git diff --cached 2>/dev/null)
if [ -z "$DIFF" ]; then
  exit 0
fi

ISSUES=""
BLOCK=false

# 1. merge conflict marker 잔존 — 즉시 차단
CONFLICT=$(echo "$DIFF" | grep '^+' | grep -c '<<<<<<<\|>>>>>>>' 2>/dev/null)
if [ "$CONFLICT" -gt 0 ]; then
  jq -n '{
    decision: "block",
    reason: "[QUALITY GATE] merge conflict marker 잔존. 충돌을 해결한 후 커밋하세요."
  }'
  exit 0
fi

# 2. TODO/FIXME/HACK 잔존 체크
TODO_COUNT=$(echo "$DIFF" | grep '^+' | grep -v '^+++' | grep -ciE 'TODO|FIXME|HACK|XXX' 2>/dev/null)
if [ "$TODO_COUNT" -gt 0 ]; then
  ISSUES="${ISSUES}\n- TODO/FIXME/HACK ${TODO_COUNT}개 발견 (의도적이면 무시 가능)"
fi

# 3. console.log / print() 디버깅 잔존
DEBUG_COUNT=$(echo "$DIFF" | grep '^+' | grep -v '^+++' | grep -cE 'console\.(log|debug|info)\(|print\(' 2>/dev/null)
if [ "$DEBUG_COUNT" -gt 3 ]; then
  ISSUES="${ISSUES}\n- 디버깅 출력 ${DEBUG_COUNT}개 (프로덕션 코드에 console.log/print 다수)"
fi

# 4. 대용량 파일 추가
LARGE_FILES=$(git diff --cached --stat | grep -E '\+[0-9]{4,}' | head -3)
if [ -n "$LARGE_FILES" ]; then
  ISSUES="${ISSUES}\n- 대용량 변경 감지"
fi

if [ -n "$ISSUES" ]; then
  jq -n --arg issues "$ISSUES" '{
    decision: "approve",
    reason: ("[QUALITY GATE] 경고 — 커밋은 진행됩니다:" + $issues)
  }'
fi

exit 0
