#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$ROOT_DIR/hooks/test-integrity-gate.sh"
FIXTURES="$ROOT_DIR/tests/hooks/fixtures"

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for hook tests" >&2
    exit 1
  fi
}

run_hook() {
  local fixture="$1"
  local output
  if ! output=$("$HOOK" < "$fixture"); then
    echo "hook exited non-zero for $fixture" >&2
    exit 1
  fi
  printf '%s' "$output"
}

require_jq

skip_output="$(run_hook "$FIXTURES/test-integrity-edit-skip.json")"
printf '%s' "$skip_output" | jq -e '.decision == "approve"' >/dev/null
printf '%s' "$skip_output" | jq -e '.harness.findings | length > 0' >/dev/null
printf '%s' "$skip_output" | jq -e '.harness.findings | map(.pattern) | index("skip-test") != null' >/dev/null

clean_output="$(run_hook "$FIXTURES/test-integrity-clean.json")"
printf '%s' "$clean_output" | jq -e '.decision == "approve"' >/dev/null
printf '%s' "$clean_output" | jq -e '.harness.findings | length == 0' >/dev/null

echo "test-test-integrity-gate: OK"
