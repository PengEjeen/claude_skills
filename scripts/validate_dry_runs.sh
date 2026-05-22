#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
RUNS_DIR="$ROOT/memories/shared/runs"
FAILED=0
TOTAL=0

fail() {
  echo "[FAIL] $*" >&2
  FAILED=$((FAILED + 1))
}

ok() {
  echo "[OK] $*"
}

require_file() {
  local path="$1"
  [ -f "$path" ] || { fail "missing file: $path"; return 1; }
}

require_text() {
  local path="$1"
  local pattern="$2"
  grep -Eiq "$pattern" "$path" || { fail "$path missing pattern: $pattern"; return 1; }
}

extract_md_field() {
  local path="$1"
  local field="$2"
  grep -Ei "^[[:space:]]*-[[:space:]]*${field}:" "$path" | head -1 | sed -E "s/^[[:space:]]*-[[:space:]]*${field}:[[:space:]]*//I" | tr -d '\r'
}

if [ ! -d "$RUNS_DIR" ]; then
  echo "[ERROR] runs directory not found: $RUNS_DIR" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[ERROR] jq is required" >&2
  exit 2
fi

shopt -s nullglob
run_dirs=("$RUNS_DIR"/*dry-run*)

if [ "${#run_dirs[@]}" -eq 0 ]; then
  echo "[ERROR] no dry-run directories found under $RUNS_DIR" >&2
  exit 2
fi

for run_dir in "${run_dirs[@]}"; do
  [ -d "$run_dir" ] || continue
  TOTAL=$((TOTAL + 1))
  run_name=$(basename "$run_dir")

  forbidden=$(find "$run_dir" -type f | grep -Ei '(scratch|cot|chain.of.thought|private.reasoning|reasoning)' || true)
  if [ -n "$forbidden" ]; then
    fail "$run_name contains forbidden scratch/reasoning artifacts: $forbidden"
    continue
  fi

  require_file "$run_dir/01_user_goal.md" || continue
  require_file "$run_dir/02_pm_contract.md" || continue
  require_file "$run_dir/03_plan.md" || continue
  require_file "$run_dir/06_reviewer_report.md" || continue
  require_file "$run_dir/07_qa_report.md" || continue
  require_file "$run_dir/08_decision.md" || continue

  output_files=("$run_dir"/05_*_output.md)
  if [ "${#output_files[@]}" -ne 1 ]; then
    fail "$run_name expected exactly one 05_*_output.md file, found ${#output_files[@]}"
    continue
  fi
  output_file="${output_files[0]}"

  handoff_files=("$run_dir"/*handoff*.json)
  if [ "${#handoff_files[@]}" -ne 1 ]; then
    fail "$run_name expected exactly one handoff JSON, found ${#handoff_files[@]}"
    continue
  fi
  handoff="${handoff_files[0]}"

  jq -e . "$handoff" >/dev/null || { fail "$run_name invalid handoff JSON"; continue; }

  for field in task_id owner owner_scope inputs constraints deliverables evidence validation_method next_agent open_questions status; do
    jq -e --arg field "$field" 'has($field)' "$handoff" >/dev/null || fail "$run_name handoff missing field: $field"
  done

  deliverable_count=$(jq '.deliverables | length' "$handoff")
  evidence_count=$(jq '.evidence | length' "$handoff")
  [ "$deliverable_count" -ge 1 ] || fail "$run_name handoff deliverables must be non-empty"
  [ "$evidence_count" -ge 1 ] || fail "$run_name handoff evidence must be non-empty"

  task_goal=$(extract_md_field "$run_dir/01_user_goal.md" task_id)
  task_pm=$(extract_md_field "$run_dir/02_pm_contract.md" task_id)
  task_plan=$(extract_md_field "$run_dir/03_plan.md" task_id)
  task_output=$(extract_md_field "$output_file" task_id)
  task_review=$(extract_md_field "$run_dir/06_reviewer_report.md" task_id)
  task_qa=$(extract_md_field "$run_dir/07_qa_report.md" task_id)
  task_decision=$(extract_md_field "$run_dir/08_decision.md" task_id)
  task_handoff=$(jq -r '.task_id' "$handoff")

  for t in "$task_goal" "$task_pm" "$task_plan" "$task_output" "$task_review" "$task_qa" "$task_decision" "$task_handoff"; do
    [ -n "$t" ] || fail "$run_name has empty task_id in one or more artifacts"
  done

  if [ "$task_pm" != "$task_handoff" ] || [ "$task_goal" != "$task_handoff" ] || [ "$task_plan" != "$task_handoff" ] || [ "$task_output" != "$task_handoff" ] || [ "$task_review" != "$task_handoff" ] || [ "$task_qa" != "$task_handoff" ] || [ "$task_decision" != "$task_handoff" ]; then
    fail "$run_name task_id mismatch across artifacts"
  fi

  require_text "$run_dir/02_pm_contract.md" 'owner:'
  require_text "$run_dir/02_pm_contract.md" 'owner_scope:'
  require_text "$run_dir/02_pm_contract.md" 'dependency:'
  require_text "$run_dir/02_pm_contract.md" 'done_criteria:'
  require_text "$run_dir/02_pm_contract.md" 'validation_method:'
  require_text "$run_dir/02_pm_contract.md" 'next_agent:'

  pm_owner=$(extract_md_field "$run_dir/02_pm_contract.md" owner)
  pm_next=$(extract_md_field "$run_dir/02_pm_contract.md" next_agent)
  handoff_owner=$(jq -r '.owner' "$handoff")

  if [ "$pm_owner" != "$handoff_owner" ]; then
    fail "$run_name PM owner ($pm_owner) does not match handoff owner ($handoff_owner)"
  fi

  if [ "$pm_next" != "$handoff_owner" ]; then
    fail "$run_name PM next_agent ($pm_next) should route to handoff owner ($handoff_owner)"
  fi

  require_text "$run_dir/06_reviewer_report.md" 'decision:[[:space:]]*(pass|fail|blocked)'
  require_text "$run_dir/07_qa_report.md" 'qa_result:[[:space:]]*(pass|fail|blocked)'
  require_text "$run_dir/08_decision.md" 'decision:[[:space:]]*(approved|rejected|blocked)'

  review_decision=$(extract_md_field "$run_dir/06_reviewer_report.md" decision | tr '[:upper:]' '[:lower:]')
  qa_result=$(extract_md_field "$run_dir/07_qa_report.md" qa_result | tr '[:upper:]' '[:lower:]')
  final_decision=$(extract_md_field "$run_dir/08_decision.md" decision | tr '[:upper:]' '[:lower:]')

  if [ "$qa_result" = "pass" ] && [ "$review_decision" != "pass" ]; then
    fail "$run_name QA pass requires reviewer pass"
  fi

  if [ "$final_decision" = "approved" ] && [ "$qa_result" != "pass" ]; then
    fail "$run_name final approval requires QA pass"
  fi

  if [ "$qa_result" = "fail" ]; then
    grep -Eiq 'rollback|retry|replan' "$run_dir/07_qa_report.md" || fail "$run_name QA fail requires rollback/retry/replan evidence"
    grep -Eiq 'rollback|retry|replan' "$run_dir/08_decision.md" || fail "$run_name final decision must mention rollback/retry/replan after QA fail"
  fi

  if [ "$FAILED" -eq 0 ]; then
    ok "$run_name validated"
  else
    echo "[INFO] $run_name checked with current failure count=$FAILED" >&2
  fi
done

if [ "$FAILED" -gt 0 ]; then
  echo "[SUMMARY] failed=$FAILED total=$TOTAL" >&2
  exit 1
fi

ok "dry-runs validated total=$TOTAL"
exit 0
