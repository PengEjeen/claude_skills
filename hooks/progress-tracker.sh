#!/bin/bash
# shellcheck shell=bash
# Stop: Progress Tracker — claude-progress.txt 자동 관리
# 장기 실행 에이전트 패턴: git 상태 + 작업 컨텍스트를 기록하여
# 새 컨텍스트 윈도우에서 빠르게 상태 파악 가능
# 조용히 파일만 업데이트, stdout 없음

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

PROGRESS_FILE="./claude-progress.txt"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M KST')
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "no commits")
MODIFIED=$(git diff --name-only 2>/dev/null | head -10)
STAGED=$(git diff --cached --name-only 2>/dev/null | head -10)

# 변경 파일 요약 (언어별 그룹핑)
PY_COUNT=$(echo "$MODIFIED" | grep -c '\.py$' 2>/dev/null)
JS_COUNT=$(echo "$MODIFIED" | grep -c '\.\(ts\|tsx\|js\|jsx\)$' 2>/dev/null)
OTHER_COUNT=$(echo "$MODIFIED" | grep -vcE '\.(py|ts|tsx|js|jsx)$' 2>/dev/null)

# DoD 파일 감지
DOD_STATUS=""
if [ -f ".dod" ]; then
  TOTAL=$(grep -c '^\[' .dod 2>/dev/null || echo 0)
  DONE=$(grep -c '^\[x\]' .dod 2>/dev/null || echo 0)
  DOD_STATUS="DoD: ${DONE}/${TOTAL} completed"
fi

# 최근 테스트 결과
TEST_STATUS=""
if [ -d ".pytest_cache" ]; then
  LAST_TEST=$(find .pytest_cache -maxdepth 1 -name "*.cache" -newer "$PROGRESS_FILE" 2>/dev/null | head -1)
  if [ -n "$LAST_TEST" ]; then
    TEST_STATUS="pytest: ran recently"
  fi
fi

cat > "$PROGRESS_FILE" << PROGRESS_EOF
# Claude Progress — ${TIMESTAMP}

## State
- Branch: ${BRANCH}
- Last Commit: ${LAST_COMMIT}

## Modified (uncommitted)
${MODIFIED:-"(none)"}

## Staged
${STAGED:-"(none)"}

## Summary
- Python: ${PY_COUNT} files, JS/TS: ${JS_COUNT} files, Other: ${OTHER_COUNT} files
${DOD_STATUS:+- ${DOD_STATUS}}
${TEST_STATUS:+- ${TEST_STATUS}}

## Recent Activity (last 3 commits)
$(git log --oneline -3 2>/dev/null || echo "(none)")
PROGRESS_EOF

# Stop 훅은 출력 없이 종료
exit 0
