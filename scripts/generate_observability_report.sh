#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
RUNS_DIR="$ROOT/memories/shared/runs"
OUT_DIR="$ROOT/memories/shared/observability"
MD_OUT="$OUT_DIR/dry_run_observability_latest.md"
JSONL_OUT="$OUT_DIR/dry_run_observability_latest.jsonl"
VALIDATOR="$ROOT/scripts/validate_dry_runs.sh"

mkdir -p "$OUT_DIR"

if [ ! -d "$RUNS_DIR" ]; then
  echo "[ERROR] runs directory not found: $RUNS_DIR" >&2
  exit 2
fi

if [ ! -f "$VALIDATOR" ]; then
  echo "[ERROR] dry-run validator not found: $VALIDATOR" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[ERROR] jq is required" >&2
  exit 2
fi

extract_md_field() {
  local path="$1"
  local field="$2"
  if [ -f "$path" ]; then
    grep -Ei "^[[:space:]]*-[[:space:]]*${field}:" "$path" | head -1 | sed -E "s/^[[:space:]]*-[[:space:]]*${field}:[[:space:]]*//I" | tr -d '\r'
  fi
}

validation_for_run() {
  local run_dir="$1"
  local tmp
  tmp=$(mktemp -d)
  mkdir -p "$tmp/memories/shared/runs"
  cp -R "$run_dir" "$tmp/memories/shared/runs/"
  local out status first_failure
  set +e
  out=$(bash "$VALIDATOR" "$tmp" 2>&1)
  status=$?
  set -e
  rm -rf "$tmp"
  if [ "$status" -eq 0 ]; then
    printf 'pass\t'
  else
    first_failure=$(printf '%s\n' "$out" | grep -E '^\[FAIL\]' | head -1 | sed -E 's/^\[FAIL\][[:space:]]*//' | tr -d '\r')
    [ -n "$first_failure" ] || first_failure="validator failed without explicit failure line"
    printf 'fail\t%s' "$first_failure"
  fi
}

mapfile -t run_dirs < <(find "$RUNS_DIR" -mindepth 1 -maxdepth 2 -type d -name '*dry-run*' | sort)

if [ "${#run_dirs[@]}" -eq 0 ]; then
  echo "[ERROR] no dry-run directories found under $RUNS_DIR" >&2
  echo "[HINT] expected a directory like memories/shared/runs/2026-04-29-dry-run-001" >&2
  exit 2
fi

{
  echo "# Dry-Run Observability Report"
  echo
  echo "Generated at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "| Run | Status | Task | Owner | Handoff Owner | Next | Evidence | Deliverables | Reviewer | QA | Rollback | Final | First Failure |"
  echo "|-----|--------|------|-------|---------------|------|----------|--------------|----------|----|----------|-------|---------------|"
} > "$MD_OUT"
: > "$JSONL_OUT"

for run_dir in "${run_dirs[@]}"; do
  run_name=$(basename "$run_dir")
  pm_file="$run_dir/02_pm_contract.md"
  reviewer_file="$run_dir/06_reviewer_report.md"
  qa_file="$run_dir/07_qa_report.md"
  decision_file="$run_dir/08_decision.md"
  handoff_file=$(find "$run_dir" -maxdepth 1 -type f -name '*handoff*.json' | head -1 || true)

  task_id=""
  pm_owner=""
  handoff_owner=""
  handoff_next=""
  evidence_count=0
  deliverable_count=0

  if [ -f "$pm_file" ]; then
    task_id=$(extract_md_field "$pm_file" task_id)
    pm_owner=$(extract_md_field "$pm_file" owner)
  fi

  if [ -n "$handoff_file" ] && jq -e . "$handoff_file" >/dev/null 2>&1; then
    handoff_owner=$(jq -r '.owner // ""' "$handoff_file")
    handoff_next=$(jq -r '.next_agent // ""' "$handoff_file")
    evidence_count=$(jq '.evidence // [] | length' "$handoff_file")
    deliverable_count=$(jq '.deliverables // [] | length' "$handoff_file")
    [ -n "$task_id" ] || task_id=$(jq -r '.task_id // ""' "$handoff_file")
  fi

  reviewer_decision=$(extract_md_field "$reviewer_file" decision)
  qa_result=$(extract_md_field "$qa_file" qa_result)
  rollback_required=$(grep -Ei '^## Rollback Required' -A2 "$qa_file" 2>/dev/null | tail -1 | sed 's/^ *//' || true)
  final_decision=$(extract_md_field "$decision_file" decision)

  vf=$(validation_for_run "$run_dir")
  validation_status=$(printf '%s' "$vf" | cut -f1)
  first_failure=$(printf '%s' "$vf" | cut -f2-)
  [ "$first_failure" = "$validation_status" ] && first_failure=""

  esc() { printf '%s' "$1" | sed 's/|/\\|/g'; }

  echo "| $(esc "$run_name") | $(esc "$validation_status") | $(esc "$task_id") | $(esc "$pm_owner") | $(esc "$handoff_owner") | $(esc "$handoff_next") | $evidence_count | $deliverable_count | $(esc "$reviewer_decision") | $(esc "$qa_result") | $(esc "$rollback_required") | $(esc "$final_decision") | $(esc "$first_failure") |" >> "$MD_OUT"

  jq -n \
    --arg run_name "$run_name" \
    --arg validation_status "$validation_status" \
    --arg first_failure_reason "$first_failure" \
    --arg task_id "$task_id" \
    --arg pm_owner "$pm_owner" \
    --arg handoff_owner "$handoff_owner" \
    --arg handoff_next_agent "$handoff_next" \
    --arg reviewer_decision "$reviewer_decision" \
    --arg qa_result "$qa_result" \
    --arg rollback_required "$rollback_required" \
    --arg final_decision "$final_decision" \
    --argjson evidence_count "$evidence_count" \
    --argjson deliverable_count "$deliverable_count" \
    '{run_name:$run_name,validation_status:$validation_status,first_failure_reason:$first_failure_reason,task_id:$task_id,pm_owner:$pm_owner,handoff_owner:$handoff_owner,handoff_next_agent:$handoff_next_agent,evidence_count:$evidence_count,deliverable_count:$deliverable_count,reviewer_decision:$reviewer_decision,qa_result:$qa_result,rollback_required:$rollback_required,final_decision:$final_decision}' >> "$JSONL_OUT"
done

echo "[OK] runs=${#run_dirs[@]}"
echo "[OK] wrote $MD_OUT"
echo "[OK] wrote $JSONL_OUT"
