# Test Hooks

Run fixture-based tests for harness hook scripts.

## Usage

`/test-hooks`

## Commands

From the repository root:

```bash
bash tests/hooks/test-agent-router.sh
bash tests/hooks/test-verification-planner.sh
bash tests/hooks/test-test-integrity-gate.sh
```

Run all hook tests:

```bash
for test_file in tests/hooks/test-*.sh; do
  bash "$test_file"
done
```

## Coverage

These tests pipe fixture JSON into hook scripts through stdin and validate JSON output with `jq`.

- `agent-router-auth.json`: `security-reviewer` must be recommended.
- `agent-router-docs.json`: no subagent should be recommended.
- `verification-ts-auth.json`: typecheck/test candidates and security manual check.
- `verification-sql-migration.json`: database reviewer, rollback, and RLS/policy manual checks.
- `test-integrity-edit-skip.json`: finding must be emitted.
- `test-integrity-clean.json`: findings must be empty.

Each hook must exit 0.
