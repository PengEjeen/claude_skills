#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
SOURCE_RUN="$ROOT/memories/shared/runs/2026-04-29-dry-run-001"
VALIDATOR="$ROOT/scripts/validate_dry_runs.sh"
FAILED=0
PASSED=0

fail() {
  echo "[FAIL] $*" >&2
  FAILED=$((FAILED + 1))
}

ok() {
  echo "[OK] $*"
  PASSED=$((PASSED + 1))
}

if [ ! -d "$SOURCE_RUN" ]; then
  echo "[ERROR] source dry-run not found: $SOURCE_RUN" >&2
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

make_workspace() {
  local tmp
  tmp=$(mktemp -d)
  mkdir -p "$tmp/memories/shared/runs"
  cp -R "$SOURCE_RUN" "$tmp/memories/shared/runs/"
  printf '%s' "$tmp"
}

expect_validator_failure() {
  local name="$1"
  local tmp="$2"
  if bash "$VALIDATOR" "$tmp" >/tmp/validate_dry_runs_${name}.out 2>&1; then
    fail "$name: validator unexpectedly passed"
    cat /tmp/validate_dry_runs_${name}.out >&2 || true
  else
    ok "$name: validator rejected injected failure"
  fi
  rm -rf "$tmp"
}

# 1. handoff task_id mismatch
case_task_id_mismatch() {
  local tmp run handoff
  tmp=$(make_workspace)
  run="$tmp/memories/shared/runs/2026-04-29-dry-run-001"
  handoff="$run/04_handoff_backend.json"
  jq '.task_id = "T-BROKEN"' "$handoff" > "$handoff.tmp"
  mv "$handoff.tmp" "$handoff"
  expect_validator_failure "task_id_mismatch" "$tmp"
}

# 2. missing handoff evidence
case_missing_evidence() {
  local tmp run handoff
  tmp=$(make_workspace)
  run="$tmp/memories/shared/runs/2026-04-29-dry-run-001"
  handoff="$run/04_handoff_backend.json"
  jq '.evidence = []' "$handoff" > "$handoff.tmp"
  mv "$handoff.tmp" "$handoff"
  expect_validator_failure "missing_evidence" "$tmp"
}

# 3. PM owner differs from handoff owner
case_owner_mismatch() {
  local tmp run
  tmp=$(make_workspace)
  run="$tmp/memories/shared/runs/2026-04-29-dry-run-001"
  perl -0pi -e 's/- owner: backend-agent/- owner: react-agent/' "$run/02_pm_contract.md"
  expect_validator_failure "owner_mismatch" "$tmp"
}

# 4. reviewer fail but QA pass
case_reviewer_fail_qa_pass() {
  local tmp run
  tmp=$(make_workspace)
  run="$tmp/memories/shared/runs/2026-04-29-dry-run-001"
  perl -0pi -e 's/- decision: pass/- decision: fail/' "$run/06_reviewer_report.md"
  expect_validator_failure "reviewer_fail_qa_pass" "$tmp"
}

# 5. QA fail without rollback/retry/replan evidence
case_qa_fail_no_rollback() {
  local tmp run
  tmp=$(make_workspace)
  run="$tmp/memories/shared/runs/2026-04-29-dry-run-001"
  perl -0pi -e 's/- qa_result: pass/- qa_result: fail/' "$run/07_qa_report.md"
  perl -0pi -e 's/no — all acceptance criteria passed with evidence\./no evidence provided./' "$run/07_qa_report.md"
  expect_validator_failure "qa_fail_no_rollback" "$tmp"
}

# 6. forbidden scratch/cot/reasoning artifact exists
case_forbidden_scratch_artifact() {
  local tmp run
  tmp=$(make_workspace)
  run="$tmp/memories/shared/runs/2026-04-29-dry-run-001"
  echo "temporary private notes" > "$run/09_scratch.md"
  expect_validator_failure "forbidden_scratch_artifact" "$tmp"
}

# 7. final approved while QA is not pass
case_final_approved_without_qa_pass() {
  local tmp run
  tmp=$(make_workspace)
  run="$tmp/memories/shared/runs/2026-04-29-dry-run-001"
  perl -0pi -e 's/- qa_result: pass/- qa_result: blocked/' "$run/07_qa_report.md"
  expect_validator_failure "final_approved_without_qa_pass" "$tmp"
}

case_task_id_mismatch
case_missing_evidence
case_owner_mismatch
case_reviewer_fail_qa_pass
case_qa_fail_no_rollback
case_forbidden_scratch_artifact
case_final_approved_without_qa_pass

if [ "$FAILED" -gt 0 ]; then
  echo "[SUMMARY] passed=$PASSED failed=$FAILED" >&2
  exit 1
fi

echo "[SUMMARY] passed=$PASSED failed=0"
exit 0
