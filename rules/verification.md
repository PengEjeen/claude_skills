# Verification Planning

globs: ['**/hooks/verification-planner.sh', '**/hooks/verification-loop.sh', '**/commands/verify-plan.md', '**/settings*.json']

Verification is split into two phases:

1. **Verification plan generation**: inspect the changed file and emit a lightweight JSON plan.
2. **Verification execution**: run the selected checks only after the plan is understood or when a later harness stage explicitly executes them.

`verification-planner.sh` is advisory. It must not run heavy tests, apply migrations, deploy infrastructure, or mutate external state.

## Output Categories

Executable checks go in `checks`:

```json
{"name": "TypeScript typecheck", "command": "npm run typecheck", "blocking": true}
```

Human or agent review items go in `manual_checks`:

```json
"database-reviewer: review migration/schema/data impact"
```

## File-Type Policy

| File type | Risk | Executable checks | Manual checks |
|-----------|------|-------------------|---------------|
| TS/TSX/JS/JSX | medium | `npm run typecheck` when `package.json` has `scripts.typecheck`; `npm test` when `scripts.test` exists | auth/session/token/permission files require `security-reviewer` review |
| Python | medium | `ruff check .` when `ruff` is available; `python -m pytest -q` when pytest-style tests exist | Add manual review only for domain-specific risk |
| SQL / migrations | high | none by default | `database-reviewer`, rollback path, RLS/policy impact, no auto-apply |
| Terraform | high | `terraform validate` when `terraform` is available | plan-only review; never apply automatically |
| Docker / YAML | medium | none by default | `infrastructure-agent` review |
| Non-code files | low | none by default | none unless the request adds domain risk |

## Safety Rules

- Plan generation must finish quickly and fail open.
- If hook input cannot be parsed or `jq` is unavailable, return `decision=approve` with a skipped reason.
- Do not run `npm test`, `pytest`, `terraform plan`, `terraform apply`, migration commands, Docker builds, or deployment commands from the planner.
- SQL and Terraform plans must clearly separate review from apply. Auto-apply is forbidden.
