#!/bin/bash
# trace-analyzer.sh — 주간 트레이스 분석 리포트
# 실행: bash ~/.claude/hooks/trace-analyzer.sh
# cron: 0 9 * * 1 bash ~/.claude/hooks/trace-analyzer.sh (매주 월 09:00)

TRACE_DIR="$HOME/.claude/traces"
REPORT_DIR="$HOME/.claude/reports"
mkdir -p "$REPORT_DIR"

if [ ! -d "$TRACE_DIR" ]; then
  echo "No traces directory found"
  exit 0
fi

REPORT_FILE="$REPORT_DIR/weekly-$(date +%Y-%m-%d).md"
WEEK_AGO=$(date -v-7d +%Y-%m-%d 2>/dev/null || date -d '7 days ago' +%Y-%m-%d 2>/dev/null)

echo "# Trace Analysis Report — $(date +%Y-%m-%d)" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 총 도구 호출 수
TOTAL=$(find "$TRACE_DIR" -name "*.jsonl" -newer "$TRACE_DIR" 2>/dev/null | xargs cat 2>/dev/null | wc -l)
echo "## Summary" >> "$REPORT_FILE"
echo "- Total tool calls (7d): $TOTAL" >> "$REPORT_FILE"

# 도구별 사용 빈도
echo "" >> "$REPORT_FILE"
echo "## Tool Usage" >> "$REPORT_FILE"
find "$TRACE_DIR" -name "*.jsonl" 2>/dev/null | xargs cat 2>/dev/null | \
  grep -o '"tool":"[^"]*"' | sort | uniq -c | sort -rn | head -10 | \
  while read count tool; do
    echo "- $tool: $count" >> "$REPORT_FILE"
  done

# 실패 패턴
echo "" >> "$REPORT_FILE"
echo "## Failure Patterns" >> "$REPORT_FILE"
find "$TRACE_DIR" -name "*.jsonl" 2>/dev/null | xargs cat 2>/dev/null | \
  grep -i '"status":"fail\|"error":' | wc -l | \
  xargs -I{} echo "- Total failures: {}" >> "$REPORT_FILE"

# 반복 편집 (doom loop 후보)
echo "" >> "$REPORT_FILE"
echo "## Repeated Edits (Doom Loop Candidates)" >> "$REPORT_FILE"
find "$TRACE_DIR" -name "*.jsonl" 2>/dev/null | xargs cat 2>/dev/null | \
  grep -o '"file":"[^"]*"' | sort | uniq -c | sort -rn | head -5 | \
  while read count file; do
    if [ "$count" -gt 5 ]; then
      echo "- WARNING: $file edited $count times" >> "$REPORT_FILE"
    fi
  done

# 7일 이상 된 트레이스 정리
find "$TRACE_DIR" -name "*.jsonl" -mtime +7 -delete 2>/dev/null

echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"

echo "Report saved: $REPORT_FILE"
