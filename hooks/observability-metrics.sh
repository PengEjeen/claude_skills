#!/bin/bash
# shellcheck shell=bash
# PostToolUse: Observability Metrics Collector
# Collects structured metrics for trace-driven harness improvement
# Trigger: PostToolUse on Bash, Edit, Write (all tools)
# Output format: silent (no JSON output — metrics collection only)
#
# Usage:
#   As hook: automatically collects metrics on every tool call
#   Summary: bash ~/.claude/hooks/observability-metrics.sh --summary [days]
#   Reset:   bash ~/.claude/hooks/observability-metrics.sh --reset
#
# Stores: ~/.claude/traces/metrics.jsonl (JSONL format)
# Rotation: auto-rotates when file exceeds 5MB, keeps last 7 days

set -euo pipefail

# --- Constants ---
TRACE_DIR="$HOME/.claude/traces"
METRICS_FILE="$TRACE_DIR/metrics.jsonl"
MAX_SIZE_BYTES=5242880  # 5MB
RETENTION_DAYS=7
EDIT_TRACK_DIR="${TMPDIR:-/tmp}/claude-obs-edits-${CLAUDE_SESSION_ID:-$$}"

# --- Summary Mode ---
if [[ "${1:-}" == "--summary" ]]; then
  DAYS="${2:-7}"

  if [[ ! -f "$METRICS_FILE" ]]; then
    echo "No metrics file found at $METRICS_FILE"
    exit 0
  fi

  echo "========================================"
  echo "  Observability Metrics Summary (${DAYS}d)"
  echo "========================================"
  echo ""

  # Date cutoff (cross-platform)
  CUTOFF=$(date -v-"${DAYS}"d +%Y-%m-%d 2>/dev/null \
    || date -d "${DAYS} days ago" +%Y-%m-%d 2>/dev/null \
    || echo "1970-01-01")

  # Filter recent entries
  RECENT=$(awk -v cutoff="$CUTOFF" '
    {
      match($0, /"ts":"([^"]+)"/, arr)
      if (arr[1] >= cutoff) print
    }
  ' "$METRICS_FILE" 2>/dev/null || cat "$METRICS_FILE")

  TOTAL=$(echo "$RECENT" | grep -c '^{' 2>/dev/null || echo "0")
  echo "Total tool calls: $TOTAL"
  echo ""

  # --- Tool Usage Distribution ---
  echo "--- Tool Usage ---"
  echo "$RECENT" | grep -o '"tool":"[^"]*"' 2>/dev/null \
    | sed 's/"tool":"//;s/"//' \
    | sort | uniq -c | sort -rn \
    | while read -r count tool; do
        pct=$((count * 100 / (TOTAL > 0 ? TOTAL : 1)))
        bar=$(printf '%*s' "$((pct / 5))" '' | tr ' ' '#')
        printf "  %-12s %4d (%2d%%) %s\n" "$tool" "$count" "$pct" "$bar"
      done
  echo ""

  # --- Success/Failure Ratio ---
  echo "--- Success/Failure ---"
  SUCCESS=$(echo "$RECENT" | grep -c '"status":"success"' 2>/dev/null || echo "0")
  FAIL=$(echo "$RECENT" | grep -c '"status":"fail"' 2>/dev/null || echo "0")
  if [[ $TOTAL -gt 0 ]]; then
    SUCCESS_PCT=$((SUCCESS * 100 / TOTAL))
  else
    SUCCESS_PCT=0
  fi
  echo "  Success: $SUCCESS ($SUCCESS_PCT%)"
  echo "  Failure: $FAIL ($((100 - SUCCESS_PCT))%)"
  echo ""

  # --- Per-File Edit Counts (Doom Loop Detection) ---
  echo "--- Per-File Edit Counts (Doom Loop Detection) ---"
  echo "$RECENT" | grep -E '"tool":"(Edit|Write)"' 2>/dev/null \
    | grep -o '"file":"[^"]*"' \
    | sed 's/"file":"//;s/"//' \
    | sort | uniq -c | sort -rn | head -10 \
    | while read -r count file; do
        label=""
        if [[ $count -ge 8 ]]; then
          label=" [DOOM LOOP]"
        elif [[ $count -ge 5 ]]; then
          label=" [WARNING]"
        fi
        printf "  %4d  %s%s\n" "$count" "$file" "$label"
      done
  echo ""

  # --- Session Duration Estimates ---
  echo "--- Session Activity ---"
  echo "$RECENT" | grep -o '"session":"[^"]*"' 2>/dev/null \
    | sed 's/"session":"//;s/"//' \
    | sort | uniq -c | sort -rn | head -5 \
    | while read -r count sess; do
        # Estimate duration from first/last timestamp in session
        FIRST_TS=$(echo "$RECENT" | grep "\"session\":\"$sess\"" | head -1 \
          | grep -o '"ts":"[^"]*"' | sed 's/"ts":"//;s/"//')
        LAST_TS=$(echo "$RECENT" | grep "\"session\":\"$sess\"" | tail -1 \
          | grep -o '"ts":"[^"]*"' | sed 's/"ts":"//;s/"//')
        printf "  Session %.8s: %4d calls | %s -> %s\n" "$sess" "$count" \
          "${FIRST_TS:-?}" "${LAST_TS:-?}"
      done
  echo ""

  # --- Most Failed Files ---
  FAIL_COUNT=$(echo "$RECENT" | grep '"status":"fail"' 2>/dev/null | grep -c '^{' 2>/dev/null || echo "0")
  if [[ $FAIL_COUNT -gt 0 ]]; then
    echo "--- Most Failed Files ---"
    echo "$RECENT" | grep '"status":"fail"' 2>/dev/null \
      | grep -o '"file":"[^"]*"' \
      | sed 's/"file":"//;s/"//' \
      | sort | uniq -c | sort -rn | head -5 \
      | while read -r count file; do
          printf "  %4d  %s\n" "$count" "$file"
        done
    echo ""
  fi

  # --- Metrics File Info ---
  FILE_SIZE=$(wc -c < "$METRICS_FILE" 2>/dev/null || echo "0")
  FILE_SIZE_KB=$((FILE_SIZE / 1024))
  ROTATED=$(ls "$TRACE_DIR"/metrics.*.jsonl 2>/dev/null | wc -l || echo "0")
  echo "--- Storage ---"
  echo "  Current file: ${FILE_SIZE_KB}KB / $((MAX_SIZE_BYTES / 1024))KB"
  echo "  Rotated files: $ROTATED"
  echo ""
  echo "========================================"

  exit 0
fi

# --- Reset Mode ---
if [[ "${1:-}" == "--reset" ]]; then
  rm -f "$METRICS_FILE" "$TRACE_DIR"/metrics.*.jsonl 2>/dev/null
  echo "Metrics reset."
  exit 0
fi

# --- Hook Mode: Collect Metrics ---
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

if [[ -z "$TOOL_NAME" ]]; then
  exit 0
fi

mkdir -p "$TRACE_DIR"

# --- Extract fields ---
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%S 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)
SESSION_KEY="${CLAUDE_SESSION_ID:-unknown}"

# File path extraction (tool-specific)
case "$TOOL_NAME" in
  Edit|Write|Read)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // "N/A"' 2>/dev/null)
    ;;
  Bash)
    # Extract meaningful target from command (first file-like argument)
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // "N/A"' 2>/dev/null | head -c 200)
    FILE_PATH="$CMD"
    ;;
  *)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.pattern // .tool_input.command // "N/A"' 2>/dev/null | head -c 200)
    ;;
esac

# Status detection: check for error indicators in output
TOOL_OUTPUT=$(echo "$INPUT" | jq -r '.tool_output // ""' 2>/dev/null | head -c 500)
if echo "$TOOL_OUTPUT" | grep -qiE '(error|Error|ERROR|FAILED|failed|exception|Exception|fatal|FATAL|panic|PANIC|traceback|Traceback)' 2>/dev/null; then
  STATUS="fail"
else
  STATUS="success"
fi

# Per-file edit count tracking (for Edit/Write only)
EDIT_COUNT=0
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]]; then
  mkdir -p "$EDIT_TRACK_DIR" 2>/dev/null
  # Hash the file path for safe filenames
  HASH=$(echo "$FILE_PATH" | shasum -a 256 2>/dev/null | cut -c1-16 \
    || echo "$FILE_PATH" | md5sum 2>/dev/null | cut -c1-16 \
    || echo "$FILE_PATH" | tr -cd '[:alnum:]' | cut -c1-32)
  COUNTER_FILE="$EDIT_TRACK_DIR/$HASH"
  if [[ -f "$COUNTER_FILE" ]]; then
    EDIT_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
    EDIT_COUNT=$((EDIT_COUNT + 1))
  else
    EDIT_COUNT=1
  fi
  echo "$EDIT_COUNT" > "$COUNTER_FILE"
fi

# Token estimate heuristic based on tool type
case "$TOOL_NAME" in
  Read|Glob|Grep) TOKEN_EST="low" ;;
  Edit|Write)     TOKEN_EST="medium" ;;
  Bash)           TOKEN_EST="high" ;;
  Agent)          TOKEN_EST="xhigh" ;;
  *)              TOKEN_EST="low" ;;
esac

# Shorten file path for display (basename only in the entry, full path preserved)
FILE_SHORT=$(basename "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")

# --- File Rotation (before write) ---
if [[ -f "$METRICS_FILE" ]]; then
  FILE_SIZE=$(wc -c < "$METRICS_FILE" 2>/dev/null || echo "0")
  # Trim whitespace from wc output (macOS compatibility)
  FILE_SIZE=$(echo "$FILE_SIZE" | tr -d '[:space:]')
  if [[ "$FILE_SIZE" -gt "$MAX_SIZE_BYTES" ]]; then
    ROTATE_TS=$(date +%Y%m%d-%H%M%S)
    mv "$METRICS_FILE" "$TRACE_DIR/metrics.${ROTATE_TS}.jsonl" 2>/dev/null
  fi
fi

# --- Cleanup rotated files older than retention period ---
find "$TRACE_DIR" -name "metrics.*.jsonl" -mtime +"$RETENTION_DAYS" -delete 2>/dev/null || true

# --- Write metric entry (fast jq construction) ---
jq -n -c \
  --arg ts "$TIMESTAMP" \
  --arg session "$SESSION_KEY" \
  --arg tool "$TOOL_NAME" \
  --arg file "$FILE_SHORT" \
  --arg filepath "$FILE_PATH" \
  --arg status "$STATUS" \
  --argjson edit_count "$EDIT_COUNT" \
  --arg token_est "$TOKEN_EST" \
  '{ts:$ts,session:$session,tool:$tool,file:$file,filepath:$filepath,status:$status,edit_count:$edit_count,token_est:$token_est}' \
  >> "$METRICS_FILE" 2>/dev/null

exit 0
