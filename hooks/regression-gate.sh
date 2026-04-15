#!/bin/bash
# shellcheck shell=bash
# SessionStart: Regression Gate
# 이전 세션에서 실패한 테스트가 여전히 실패 중인지 빠르게 검사
# 장기 실행 에이전트의 핵심 패턴: 새 컨텍스트 윈도우 시작 시 회귀 확인
# Output format: SessionStart stdout (직접 컨텍스트 주입)

# git repo 안에서만 동작
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

# 세션당 1회만 실행
SESSION_KEY="${CLAUDE_SESSION_ID:-default}"
LOCK_FILE="${TMPDIR:-/tmp}/claude-regression-gate-${SESSION_KEY}"
if [ -f "$LOCK_FILE" ]; then
  exit 0
fi
touch "$LOCK_FILE"

# 이전 실패 기록 파일
FAIL_LOG="$HOME/.claude/traces/last-test-failures.txt"
if [ ! -f "$FAIL_LOG" ]; then
  exit 0
fi

# 실패 기록이 24시간 이내인지 확인
if command -v stat &>/dev/null; then
  MOD_TIME=$(stat -c %Y "$FAIL_LOG" 2>/dev/null || stat -f %m "$FAIL_LOG" 2>/dev/null)
  if [ -n "$MOD_TIME" ]; then
    NOW=$(date +%s)
    AGE=$(( (NOW - MOD_TIME) / 3600 ))
    if [ "$AGE" -gt 24 ]; then
      rm -f "$FAIL_LOG"
      exit 0
    fi
  fi
fi

FAILURES=$(cat "$FAIL_LOG")
if [ -z "$FAILURES" ]; then
  exit 0
fi

FAIL_COUNT=$(echo "$FAILURES" | wc -l | tr -d ' ')

# 빠른 smoke test 실행 (5초 타임아웃)
REGRESSION_FOUND=false
REGRESSED=""

# Python pytest
if echo "$FAILURES" | grep -qE '\.py'; then
  if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -d "tests" ]; then
    RESULT=$(timeout 5 python -m pytest --tb=no --no-header -q 2>&1 | tail -1)
    if echo "$RESULT" | grep -qE 'failed|error'; then
      REGRESSION_FOUND=true
      REGRESSED="${REGRESSED}\n- pytest: ${RESULT}"
    fi
  fi
fi

# Node vitest/jest
if echo "$FAILURES" | grep -qE '\.(ts|js|tsx|jsx)'; then
  if [ -f "package.json" ]; then
    RESULT=$(timeout 5 npx vitest run --reporter=verbose 2>&1 | tail -3)
    if echo "$RESULT" | grep -qiE 'fail|error'; then
      REGRESSION_FOUND=true
      REGRESSED="${REGRESSED}\n- vitest: ${RESULT}"
    fi
  fi
fi

if [ "$REGRESSION_FOUND" = true ]; then
  echo "[REGRESSION GATE] 이전 세션의 실패 테스트가 여전히 실패 중입니다."
  echo "실패 내역:${REGRESSED}"
  echo ""
  echo "이전 실패 기록 (${FAIL_COUNT}건):"
  head -5 "$FAIL_LOG"
  echo ""
  echo "우선순위: 새 작업 전에 이 회귀를 먼저 해결하세요."
else
  # 통과하면 실패 기록 삭제
  rm -f "$FAIL_LOG"
fi

exit 0
