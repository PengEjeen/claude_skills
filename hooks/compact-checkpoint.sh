#!/bin/bash
# shellcheck shell=bash
# PostCompact: Context Compression Checkpoint
# 컨텍스트 압축 시 progress 파일에 체크포인트 저장

if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  exit 0
fi

PROGRESS_FILE="./claude-progress.txt"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M KST')
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
MODIFIED=$(git diff --name-only 2>/dev/null | head -5)

if [ -f "$PROGRESS_FILE" ]; then
  echo "" >> "$PROGRESS_FILE"
  echo "## Compact — ${TIMESTAMP}" >> "$PROGRESS_FILE"
  echo "- Branch: ${BRANCH}" >> "$PROGRESS_FILE"
  [ -n "$MODIFIED" ] && echo "- Modified: ${MODIFIED}" >> "$PROGRESS_FILE"
fi

# PostCompact은 출력 없이 조용히 종료
exit 0
