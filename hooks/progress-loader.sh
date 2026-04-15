#!/bin/bash
# shellcheck shell=bash
# SessionStart: Progress Loader — 이전 세션 상태 자동 로드
# SessionStart stdout은 직접 컨텍스트에 주입됨 (JSON 불필요)

PROGRESS_FILE="./claude-progress.txt"

if [ -f "$PROGRESS_FILE" ]; then
  MODIFIED_AGO=""
  if command -v stat &>/dev/null; then
    MOD_TIME=$(stat -c %Y "$PROGRESS_FILE" 2>/dev/null || stat -f %m "$PROGRESS_FILE" 2>/dev/null)
    if [ -n "$MOD_TIME" ]; then
      NOW=$(date +%s)
      DIFF=$(( (NOW - MOD_TIME) / 60 ))
      if [ "$DIFF" -lt 60 ]; then
        MODIFIED_AGO="${DIFF}분 전"
      elif [ "$DIFF" -lt 1440 ]; then
        MODIFIED_AGO="$(( DIFF / 60 ))시간 전"
      else
        MODIFIED_AGO="$(( DIFF / 1440 ))일 전"
      fi
    fi
  fi

  echo "[PROGRESS] 이전 세션 상태 (${MODIFIED_AGO} 업데이트):"
  cat "$PROGRESS_FILE"
fi

exit 0
