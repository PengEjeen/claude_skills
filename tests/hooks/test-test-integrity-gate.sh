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

coverage_clean_output="$(run_hook "$FIXTURES/test-integrity-coverage-clean.json")"
printf '%s' "$coverage_clean_output" | jq -e '.decision == "approve"' >/dev/null
printf '%s' "$coverage_clean_output" | jq -e '.harness.findings | length == 0' >/dev/null

tmp_dir="$(mktemp -d /tmp/test-integrity-gate.XXXXXX)"
trap 'rm -rf "$tmp_dir"' EXIT
(
  cd "$tmp_dir"
  git init -q
  git config user.email "test@example.com"
  git config user.name "Test"

  printf '%s\n' 'test("weak", () => { expect(value).toBeTruthy(); });' > sample.test.ts
  git add sample.test.ts
  weak_output="$(printf '%s\n' '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' | "$HOOK")"
  printf '%s' "$weak_output" | jq -e '.decision == "approve"' >/dev/null
  printf '%s' "$weak_output" | jq -e '.harness.findings | map(.severity) | index("low") != null' >/dev/null

  git reset -q
  printf '%s\n' 'const lines = report.split("\n"); const functions = registry.list();' > source.ts
  git add source.ts
  coverage_source_output="$(printf '%s\n' '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' | "$HOOK")"
  printf '%s' "$coverage_source_output" | jq -e '.decision == "approve"' >/dev/null
  printf '%s' "$coverage_source_output" | jq -e '.harness.findings | map(.pattern) | index("coverage-threshold") == null' >/dev/null

  git reset -q
  printf '%s\n' '{"jest":{"coverageThreshold":{"global":{"lines":70}}}}' > package.json
  git add package.json
  coverage_config_output="$(printf '%s\n' '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' | "$HOOK")"
  printf '%s' "$coverage_config_output" | jq -e '.decision == "block"' >/dev/null
  printf '%s' "$coverage_config_output" | jq -e '.harness.findings | map(.pattern) | index("coverage-threshold") != null' >/dev/null
)

echo "test-test-integrity-gate: OK"
