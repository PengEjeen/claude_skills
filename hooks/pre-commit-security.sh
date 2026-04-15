#!/bin/bash
# Pre-commit security check — staged 파일에서 민감정보 탐지

STAGED=$(git diff --cached --name-only 2>/dev/null)
if [ -z "$STAGED" ]; then
  exit 0
fi

ISSUES=""

# .env 파일 커밋 방지
if echo "$STAGED" | grep -qE '\.env$|\.env\.local$|\.env\.production$'; then
  ISSUES="${ISSUES}\n❌ .env 파일이 staged에 포함됨"
fi

# 민감정보 패턴 탐지 (staged diff에서)
DIFF=$(git diff --cached 2>/dev/null)

# API keys, tokens, passwords in added lines
SECRETS=$(echo "$DIFF" | grep '^+' | grep -v '^+++' | grep -iE \
  'password\s*=\s*["\x27][^\s]+|api[_-]?key\s*=\s*["\x27][^\s]+|token\s*=\s*["\x27]xox[bpras]-|ghp_[a-zA-Z0-9]{36}|sk-[a-zA-Z0-9]{48}|hooks\.slack\.com/services/' \
  2>/dev/null)

if [ -n "$SECRETS" ]; then
  ISSUES="${ISSUES}\n❌ 민감정보 패턴 발견 (비밀번호, API 키, 토큰)"
fi

if [ -n "$ISSUES" ]; then
  echo -e "🔐 보안 체크 실패:${ISSUES}"
  echo "커밋 전 확인 필요"
  exit 1
fi

exit 0
