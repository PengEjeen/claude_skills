#!/bin/bash
# shellcheck shell=bash
# Stop: Definition of Done Checker
# 세션 종료 시 machine-checkable 완료 조건 검증

INPUT=$(cat)

# git repo 안에서만 동작
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

WARNINGS=""
PASS=0
TOTAL=0

# 1. 미커밋 변경 체크
TOTAL=$((TOTAL + 1))
UNCOMMITTED=$(git diff --name-only 2>/dev/null | wc -l)
STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l)
if [ "$UNCOMMITTED" -eq 0 ] && [ "$STAGED" -eq 0 ]; then
  PASS=$((PASS + 1))
else
  WARNINGS="${WARNINGS}\n- 미커밋 변경 ${UNCOMMITTED}개, staged ${STAGED}개"
fi

# 2. .env 파일이 git에 tracked되지 않는지
TOTAL=$((TOTAL + 1))
ENV_TRACKED=$(git ls-files .env .env.local .env.production 2>/dev/null | wc -l)
if [ "$ENV_TRACKED" -eq 0 ]; then
  PASS=$((PASS + 1))
else
  WARNINGS="${WARNINGS}\n- .env 파일이 git에 tracked됨"
fi

# 결과 출력 (Stop 훅 스키마: decision + reason)
if [ -n "$WARNINGS" ]; then
  cat << EOF
{
  "decision": "approve",
  "reason": "[DoD] ${PASS}/${TOTAL} 통과${WARNINGS}"
}
EOF
fi

exit 0
