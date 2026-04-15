#!/bin/bash
# shellcheck shell=bash
# PostToolUse (Bash): Learning Indexer
# /learn 실행 후 학습 패턴을 자동 인덱싱하여 크로스세션 검색 가능하게 만듦
# Output format: JSON

# stdin에서 훅 입력 파싱
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# /learn 또는 skill-create 관련 명령이 아니면 무시
if ! echo "$COMMAND" | grep -qiE 'learn|instinct|skill-create'; then
  exit 0
fi

LEARNED_DIR="$HOME/.claude/skills/learned"
INDEX_FILE="$HOME/.claude/traces/learning-index.jsonl"

# learned 디렉토리 없으면 종료
if [ ! -d "$LEARNED_DIR" ]; then
  exit 0
fi

# traces 디렉토리 생성
mkdir -p "$HOME/.claude/traces"

# 인덱스 파일이 없으면 생성
touch "$INDEX_FILE"

# learned/ 내 .md 파일 스캔하여 인덱싱
INDEXED=0
for file in "$LEARNED_DIR"/*.md; do
  [ -f "$file" ] || continue

  FNAME=$(basename "$file" .md)
  MOD_TIME=$(date -r "$file" +%Y-%m-%dT%H:%M:%S 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)

  # 이미 인덱싱된 파일이고 수정 안 됐으면 스킵
  if grep -q "\"file\":\"$FNAME\"" "$INDEX_FILE" 2>/dev/null; then
    LAST_INDEXED=$(grep "\"file\":\"$FNAME\"" "$INDEX_FILE" | tail -1 | grep -o '"indexed_at":"[^"]*"' | cut -d'"' -f4)
    if [ "$LAST_INDEXED" = "$MOD_TIME" ]; then
      continue
    fi
  fi

  # 파일에서 키워드 추출 (첫 10줄)
  KEYWORDS=$(head -10 "$file" | grep -oE '[a-zA-Z가-힣]{3,}' | sort -u | head -10 | tr '\n' ',' | sed 's/,$//')

  # 파일에서 도메인 추출 (파일명 기반)
  DOMAIN=$(echo "$FNAME" | sed 's/-/ /g' | cut -d' ' -f1)

  # JSONL로 인덱스 추가
  echo "{\"file\":\"$FNAME\",\"domain\":\"$DOMAIN\",\"keywords\":\"$KEYWORDS\",\"indexed_at\":\"$MOD_TIME\",\"path\":\"$file\"}" >> "$INDEX_FILE"
  INDEXED=$((INDEXED + 1))
done

if [ "$INDEXED" -gt 0 ]; then
  TOTAL=$(wc -l < "$INDEX_FILE" | tr -d ' ')
  echo "{\"decision\":\"approve\",\"reason\":\"[Learning Indexer] ${INDEXED}개 패턴 인덱싱 완료. 총 ${TOTAL}개 패턴 검색 가능.\"}"
fi

exit 0
