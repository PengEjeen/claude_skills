#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$ROOT_DIR/hooks/agent-router.sh"
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

auth_output="$(run_hook "$FIXTURES/agent-router-auth.json")"
printf '%s' "$auth_output" | jq -e '.decision == "approve"' >/dev/null
printf '%s' "$auth_output" | jq -e '.harness.recommended_agents | index("security-reviewer") != null' >/dev/null

docs_output="$(run_hook "$FIXTURES/agent-router-docs.json")"
printf '%s' "$docs_output" | jq -e '.decision == "approve"' >/dev/null
printf '%s' "$docs_output" | jq -e '(.harness.recommended_agents | length == 0) or (.reason | test("no subagent|agents=none"; "i"))' >/dev/null

echo "test-agent-router: OK"
