# Harness Performance

globs: ['**/hooks/*.sh', '**/settings*.json', '**/rules/*.md']

This rule defines performance and execution boundaries for harness hooks.

## Timeout Budget

Every hook must finish under its configured `settings.local.json` timeout.

| Hook | Event | Timeout | Mode |
|------|-------|---------|------|
| `agent-router.sh` | UserPromptSubmit | 3s | advisory |
| `verification-planner.sh` | PostToolUse Edit/Write | 5s | advisory |
| `test-integrity-gate.sh` | PreToolUse Edit/Write | 3s | advisory |
| `test-integrity-gate.sh` | PreToolUse Bash(git commit*) | 3s | blocking on risky staged patterns |

## Advisory vs Blocking

Advisory hooks may recommend action, add context, or warn. They must not prevent progress unless explicitly promoted to blocking mode by settings and policy.

Blocking hooks may stop an action only when the signal is deterministic enough for the event:

- Safety hazards before tool execution.
- Secret writes.
- Staged test integrity violations before `git commit`.
- Explicit user-defined gates.

## Heavy Work Boundary

Advisory hooks must not run heavy verification:

- Do not run full test suites.
- Do not run coverage jobs.
- Do not run builds.
- Do not run `terraform plan/apply`.
- Do not apply migrations.
- Do not perform network-heavy checks.

They should emit a plan or warning instead. Execution belongs to `/verify`, targeted manual commands, or blocking gates designed for commit-time enforcement.

## Fail-Open Default

New advisory hooks must fail open:

- Invalid or missing JSON input: `decision=approve` with a skipped reason.
- Missing optional tools such as `jq`: `decision=approve` with a skipped reason or a minimal JSON fallback.
- Unexpected empty inputs: `decision=approve`.

Exception: `test-integrity-gate.sh` blocks only in `git commit` mode when risky staged patterns are detected and `SKIP_TEST_INTEGRITY=1` is not set.

## Future Expensive Checks

If a future hook needs expensive analysis:

- Cache results by session, file path, and content hash.
- Prefer short TTLs for commit gates and longer TTLs for advisory diagnostics.
- Store cache under `${TMPDIR:-/tmp}` or `~/.claude/traces` depending on whether the data is ephemeral or audit-oriented.
- Include cache hit/miss in harness metadata when useful.
