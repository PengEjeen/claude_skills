# Test Integrity

globs: ['**/hooks/test-integrity-gate.sh', '**/settings*.json', '**/*test*', '**/*spec*', '**/package.json', '**/tsconfig*.json']

Verification must not be weakened to make a task appear complete.

## Policy

Do not introduce or commit changes that reduce the integrity of tests, type checks, lint checks, or coverage gates unless the exception is explicit and documented.

The gate watches for:

- `test.skip`, `it.skip`, `describe.skip`
- `test.only`, `it.only`, `describe.only`
- `@ts-ignore`, `@ts-nocheck`
- `eslint-disable`, `biome-ignore`
- `as any`, `: any`
- suspicious coverage threshold changes
- conservative signals of assertion removal or weakening

## Modes

- Edit/Write: advisory warning only. The change is allowed, but the assistant must address or explain the finding.
- `git commit`: blocking mode. Staged risky additions block the commit unless bypassed.

## Allowed Exceptions

Exceptions are allowed only when intentional:

- Temporary isolation of a flaky test.
- Removal of deprecated tests that no longer match supported behavior.
- Explicit user approval for a short-lived suppression or threshold change.

When an exception is used, the PR or commit message must include the reason, scope, owner, and follow-up plan. Prefer linking a ticket or issue.

## Bypass

Set `SKIP_TEST_INTEGRITY=1` to bypass the gate for a specific command. This should be rare and must be documented in the commit or PR.
