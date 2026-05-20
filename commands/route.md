# Route

Classify the current user request with the Agent Router policy and print advisory recommendations only.

## Usage

`/route <request>`

## Instructions

1. Read `rules/agent-routing.md`.
2. Classify `$ARGUMENTS` using the same domain and score policy as `hooks/agent-router.sh`.
3. Print the routing result as a concise advisory report.
4. Do not spawn, invoke, or auto-run any agent.
5. If the request is docs-only, keep the score low and do not recommend `code-reviewer`.

## Domain Signals

| Domain | Signals | Recommended agent |
|--------|---------|-------------------|
| auth | auth, login, token, session, jwt, oauth, permission, role | `security-reviewer` |
| db | database, migration, sql, postgres, supabase, schema, rls | `database-reviewer` |
| infra | docker, kubernetes, k8s, terraform, ci/cd, deploy, infra | `infrastructure-agent` |
| frontend | react, component, hook, frontend, ui, tsx, jsx | `react-agent` |
| debug | bug, error, failed, exception, traceback, test fail, 실패, 에러 | `debugger` |

## Output

Use this format:

```markdown
ROUTE: advisory

Score: <0-12>
Task Type: <general|docs|planning|implementation|debug>
Risk: <low|medium|high>
Domains: <none|comma-separated domains>
Recommended Agents: <none|comma-separated agents>
Verification Required: <yes|no>

Reason:
- <short reason for each recommendation>

Execution:
- No agents were started. This command is advisory only.
```

## Arguments

$ARGUMENTS: User request text to classify.
