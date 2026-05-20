#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HOOK="$ROOT_DIR/hooks/verification-planner.sh"
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

tmp_dir="$(mktemp -d /tmp/verification-planner-test.XXXXXX)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/src/auth" "$tmp_dir/db/migrations"
cat > "$tmp_dir/package.json" <<'JSON'
{
  "scripts": {
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "lint": "eslint .",
    "build": "vite build"
  }
}
JSON
touch "$tmp_dir/pnpm-lock.yaml"

(
  cd "$tmp_dir"

  ts_output="$(run_hook "$FIXTURES/verification-ts-auth.json")"
  printf '%s' "$ts_output" | jq -e '.decision == "approve"' >/dev/null
  printf '%s' "$ts_output" | jq -e '.harness.checks | map(.command) | index("pnpm typecheck") != null' >/dev/null
  printf '%s' "$ts_output" | jq -e '.harness.checks | map(.command) | index("pnpm test") != null' >/dev/null
  printf '%s' "$ts_output" | jq -e '.harness.checks | map(.command) | index("pnpm lint") != null' >/dev/null
  printf '%s' "$ts_output" | jq -e '.harness.checks | map(.command) | index("pnpm build") != null' >/dev/null
  printf '%s' "$ts_output" | jq -e '.harness.manual_checks | map(test("security-reviewer")) | any' >/dev/null

  sql_output="$(run_hook "$FIXTURES/verification-sql-migration.json")"
  printf '%s' "$sql_output" | jq -e '.decision == "approve"' >/dev/null
  printf '%s' "$sql_output" | jq -e '.harness.manual_checks | map(test("database-reviewer")) | any' >/dev/null
  printf '%s' "$sql_output" | jq -e '.harness.manual_checks | map(test("rollback"; "i")) | any' >/dev/null
  printf '%s' "$sql_output" | jq -e '.harness.manual_checks | map(test("RLS|policy"; "i")) | any' >/dev/null
)

no_pkg_dir="$(mktemp -d /tmp/verification-planner-no-package.XXXXXX)"
trap 'rm -rf "$tmp_dir" "$no_pkg_dir"' EXIT
mkdir -p "$no_pkg_dir/src/auth"
(
  cd "$no_pkg_dir"
  no_pkg_output="$(run_hook "$FIXTURES/verification-ts-auth.json")"
  printf '%s' "$no_pkg_output" | jq -e '.decision == "approve"' >/dev/null
  printf '%s' "$no_pkg_output" | jq -e '.harness.manual_checks | map(test("package.json not found")) | any' >/dev/null
)

echo "test-verification-planner: OK"
