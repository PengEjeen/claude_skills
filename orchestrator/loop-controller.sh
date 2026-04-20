#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACTS_DIR="$ROOT_DIR/artifacts"
HISTORY_DIR="$ARTIFACTS_DIR/history"
STATE_FILE="$ARTIFACTS_DIR/state.json"
CONTRACT_FILE="$ARTIFACTS_DIR/contract.json"
EVAL_FILE="$ARTIFACTS_DIR/eval.json"
BUDGET_FILE="$ROOT_DIR/orchestrator/budget-policy.json"
DEFAULT_MAX_ROUNDS=5
DEFAULT_MODE="balanced"
DEFAULT_HISTORY_RETENTION=20

require_file() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "Missing required file: $file" >&2
    exit 1
  fi
}

require_nonempty_file() {
  local file="$1"
  local hint="$2"
  if [ ! -f "$file" ]; then
    echo "Missing required file: $file" >&2
    [ -n "$hint" ] && echo "Hint: $hint" >&2
    exit 1
  fi
  if [ ! -s "$file" ]; then
    echo "Required file is empty: $file" >&2
    [ -n "$hint" ] && echo "Hint: $hint" >&2
    exit 1
  fi
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Required command not found: $cmd" >&2
    exit 1
  fi
}

is_valid_json() {
  local file="$1"
  jq -e . "$file" >/dev/null 2>&1
}

json_get_or_default() {
  local file="$1"
  local filter="$2"
  local default_value="$3"
  local value=""

  if is_valid_json "$file"; then
    value="$(jq -r "$filter // empty" "$file" 2>/dev/null || true)"
  fi

  if [ -z "$value" ] || [ "$value" = "null" ]; then
    echo "$default_value"
  else
    echo "$value"
  fi
}

require_cmd jq
require_nonempty_file "$STATE_FILE" "Initialize artifacts/state.json before running the loop controller."
require_nonempty_file "$EVAL_FILE" "Run /evaluator before the loop controller so artifacts/eval.json is populated."
require_nonempty_file "$BUDGET_FILE" "Populate orchestrator/budget-policy.json (see orchestrator/SCHEMA.md)."

mkdir -p "$HISTORY_DIR"

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

if ! is_valid_json "$STATE_FILE"; then
  echo "Invalid JSON in $STATE_FILE" >&2
  exit 1
fi

if ! is_valid_json "$EVAL_FILE"; then
  echo "Invalid JSON in $EVAL_FILE" >&2
  exit 1
fi

# Archive current round snapshot before mutating state
current_round="$(jq -r '.round // 0' "$STATE_FILE")"
archive_file="$HISTORY_DIR/round-${current_round}-${timestamp//:/-}.json"

if [ -f "$CONTRACT_FILE" ] && is_valid_json "$CONTRACT_FILE"; then
  jq -n \
    --slurpfile state "$STATE_FILE" \
    --slurpfile eval "$EVAL_FILE" \
    --slurpfile contract "$CONTRACT_FILE" \
    --arg ts "$timestamp" \
    '
    {
      archived_at: $ts,
      state: $state[0],
      contract: $contract[0],
      eval: $eval[0]
    }
    ' > "$archive_file"
else
  jq -n \
    --slurpfile state "$STATE_FILE" \
    --slurpfile eval "$EVAL_FILE" \
    --arg ts "$timestamp" \
    '
    {
      archived_at: $ts,
      state: $state[0],
      eval: $eval[0]
    }
    ' > "$archive_file"
fi

raw_eval_result="$(jq -r '.result // "blocked"' "$EVAL_FILE")"
eval_phase="$(jq -r '.phase // "execution_evaluation"' "$EVAL_FILE")"
eval_score_json="$(jq -c '.score // 0' "$EVAL_FILE")"
gate_passed_json="$(jq -c '.gate_passed // (.gates.gate_passed // false)' "$EVAL_FILE")"
critical_failed_json="$(jq -c '.critical_dod_failed // (.gates.critical_dod_failed // 0)' "$EVAL_FILE")"
qa_required_json="$(jq -c '.qa_required // false' "$EVAL_FILE")"
qa_performed_json="$(jq -c '.qa_performed // false' "$EVAL_FILE")"
qa_tools_count="$(jq -r '(.qa_summary.tools_used // []) | length' "$EVAL_FILE")"
qa_checks_count="$(jq -r '(.qa_summary.checks_run // []) | length' "$EVAL_FILE")"
qa_evidence_count="$(jq -r '(.qa_summary.evidence // []) | length' "$EVAL_FILE")"
qa_mode_val="$(jq -r '.qa_summary.mode // ""' "$EVAL_FILE")"
stop_reason="$(jq -r '.stop_reason // ""' "$EVAL_FILE")"

eval_result="$raw_eval_result"
critical_failed_val="$(jq -r '.critical_dod_failed // (.gates.critical_dod_failed // 0)' "$EVAL_FILE")"
qa_required_val="$(jq -r '.qa_required // false' "$EVAL_FILE")"
qa_performed_val="$(jq -r '.qa_performed // false' "$EVAL_FILE")"
gate_passed_val="$(jq -r '.gate_passed // (.gates.gate_passed // false)' "$EVAL_FILE")"
qa_evidence_ok="true"

if [ "$qa_required_val" = "true" ]; then
  if [ "$qa_performed_val" != "true" ] \
     || [ "$qa_mode_val" != "mcp_execution" ] \
     || [ "$qa_tools_count" -lt 1 ] \
     || [ "$qa_checks_count" -lt 1 ] \
     || [ "$qa_evidence_count" -lt 1 ]; then
    qa_evidence_ok="false"
  fi
fi

if [ "$critical_failed_val" -gt 0 ]; then
  eval_result="fail"
fi

if [ "$raw_eval_result" = "pass" ] && [ "$gate_passed_val" != "true" ]; then
  eval_result="fail"
fi

if [ "$qa_required_val" = "true" ] && [ "$qa_evidence_ok" != "true" ] && [ "$eval_result" = "pass" ]; then
  if printf '%s' "$stop_reason" | grep -Eiq 'mcp|unavailable|environment|connection|runtime'; then
    eval_result="blocked"
  else
    eval_result="fail"
  fi
fi

if [ "$eval_result" != "$raw_eval_result" ]; then
  tmp_eval="$(mktemp)"
  jq \
    --arg forced_result "$eval_result" \
    --arg ts "$timestamp" \
    '
    .result = $forced_result
    | .controller_override = {
        forced_result: $forced_result,
        reason: "hard_gate_enforced",
        updated_at: $ts
      }
    ' "$EVAL_FILE" > "$tmp_eval"
  mv "$tmp_eval" "$EVAL_FILE"
fi

current_round="$(jq -r '.round // 1' "$STATE_FILE")"
remaining_rounds="$(json_get_or_default "$STATE_FILE" '.budget.remaining_rounds' '')"

if [ -z "$remaining_rounds" ]; then
  remaining_rounds="$(json_get_or_default "$BUDGET_FILE" '.remaining_rounds' '')"
fi
if [ -z "$remaining_rounds" ]; then
  remaining_rounds="$(json_get_or_default "$BUDGET_FILE" '.max_rounds' "$DEFAULT_MAX_ROUNDS")"
fi

max_rounds="$(json_get_or_default "$STATE_FILE" '.budget.max_rounds' '')"
if [ -z "$max_rounds" ]; then
  max_rounds="$(json_get_or_default "$BUDGET_FILE" '.max_rounds' "$DEFAULT_MAX_ROUNDS")"
fi

mode="$(json_get_or_default "$STATE_FILE" '.budget.mode' '')"
if [ -z "$mode" ]; then
  mode="$(json_get_or_default "$BUDGET_FILE" '.mode' "$DEFAULT_MODE")"
fi

new_status=""
new_round="$current_round"
new_remaining="$remaining_rounds"

case "$eval_result" in
  pass)
    new_status="passed"
    ;;
  fail)
    if [ "$eval_phase" = "contract_negotiation" ]; then
      new_status="retry"
      new_round="$current_round"
      new_remaining="$remaining_rounds"
    elif [ "$remaining_rounds" -gt 0 ]; then
      new_status="retry"
      new_round=$((current_round + 1))
      new_remaining=$((remaining_rounds - 1))
    else
      new_status="stopped"
    fi
    ;;
  blocked|*)
    new_status="stopped"
    ;;
esac

tmp_state="$(mktemp)"

jq \
  --arg status "$new_status" \
  --argjson round "$new_round" \
  --argjson remaining "$new_remaining" \
  --arg phase "$eval_phase" \
  --arg result "$eval_result" \
  --argjson score "$eval_score_json" \
  --argjson gate_passed "$gate_passed_json" \
  --argjson qa_required "$qa_required_json" \
  --argjson qa_performed "$qa_performed_json" \
  --argjson critical_failed "$critical_failed_json" \
  --arg ts "$timestamp" \
  --arg mode "$mode" \
  --argjson max_rounds "$max_rounds" \
  '
  .status = $status
  | .round = $round
  | .budget.max_rounds = $max_rounds
  | .budget.remaining_rounds = $remaining
  | .budget.mode = $mode
  | .last_eval = {
      phase: $phase,
      result: $result,
      score: $score,
      gate_passed: $gate_passed,
      qa_required: $qa_required,
      qa_performed: $qa_performed,
      critical_dod_failed: $critical_failed
    }
  | .updated_at = $ts
  ' "$STATE_FILE" > "$tmp_state"

mv "$tmp_state" "$STATE_FILE"

# Retention pruning: keep most recent N history snapshots (see orchestrator/SCHEMA.md).
retention="${ORCHESTRATOR_HISTORY_RETENTION:-$DEFAULT_HISTORY_RETENTION}"
if ! [[ "$retention" =~ ^[0-9]+$ ]]; then
  echo "Warning: ORCHESTRATOR_HISTORY_RETENTION is not a non-negative integer ('$retention'); skipping prune." >&2
elif [ "$retention" -gt 0 ]; then
  # Sort by filename (timestamp suffix sorts chronologically), drop the newest N, delete the rest.
  # Filenames look like: round-<N>-<ISO8601-with-dashes>.json
  mapfile -t snapshots < <(ls -1 "$HISTORY_DIR"/round-*.json 2>/dev/null | sort)
  total="${#snapshots[@]}"
  if [ "$total" -gt "$retention" ]; then
    to_delete=$((total - retention))
    for ((i=0; i<to_delete; i++)); do
      rm -f -- "${snapshots[$i]}"
    done
    echo "Pruned $to_delete old history snapshot(s); retained $retention."
  fi
fi

echo "Updated state: status=$new_status round=$new_round remaining_rounds=$new_remaining phase=$eval_phase result=$eval_result"
