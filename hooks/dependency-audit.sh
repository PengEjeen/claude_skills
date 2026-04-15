#!/bin/bash
# shellcheck shell=bash
# PostToolUse (Bash): Dependency Audit
# npm/pip/cargo/go 패키지 설치 시 안전성 검사
# Output format: {"decision":"approve|block","reason":"..."}

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# 패키지 설치 명령 감지
if ! echo "$COMMAND" | grep -qE '(npm install|pip install|cargo add|go get|uv add|pnpm add|yarn add|bun add)'; then
  exit 0
fi

# URL 직접 설치 감지
if echo "$COMMAND" | grep -qE 'https?://|git\+|git://'; then
  jq -n '{
    decision: "block",
    reason: "[SECURITY] URL 직접 설치 감지. 레지스트리에서 설치하세요."
  }'
  exit 0
fi

# 위험 플래그 감지
if echo "$COMMAND" | grep -qE '--force|--unsafe-perm|--ignore-scripts'; then
  jq -n '{
    decision: "block",
    reason: "[SECURITY] 위험 플래그 감지: --force/--unsafe-perm/--ignore-scripts. 플래그 없이 재시도하세요."
  }'
  exit 0
fi

# typosquatting 경고 — 흔한 오타 패키지명 패턴
if echo "$COMMAND" | grep -qE '(lodahs|reqeusts|colros|axois|expresss|reactt)'; then
  jq -n '{
    decision: "block",
    reason: "[SECURITY] 패키지명 typosquatting 의심. 정확한 패키지명을 확인하세요."
  }'
  exit 0
fi

# 통과
exit 0
