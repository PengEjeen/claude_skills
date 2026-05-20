# Agent Routing

globs: ['**/hooks/agent-router.sh', '**/settings*.json', '**/commands/route.md', '**/rules/agents.md']

Agent routing is advisory by default. The router recommends agents from the user request, but it does not start subagents automatically.

## Score Policy

The `agent-router` hook classifies the prompt into domains, assigns a score, and emits a JSON advisory payload.

| Score | Recommendation |
|-------|----------------|
| 0-4 | No subagent. Handle locally unless the user explicitly asks for delegation. |
| 5-8 | Recommend `code-reviewer` after code changes when implementation intent is present. |
| 9-12 | Recommend `planner` before work and `code-reviewer` after code changes. |

## Mandatory Domain Reviewers

When these domains are detected, the domain reviewer is mandatory in the recommendation list:

| Domain | Signals | Mandatory reviewer |
|--------|---------|--------------------|
| auth | auth, login, token, session, jwt, oauth, permission, role | `security-reviewer` |
| db | database, migration, sql, postgres, supabase, schema, rls | `database-reviewer` |
| infra | docker, kubernetes, k8s, terraform, ci/cd, deploy, infra | `infrastructure-agent` |
| frontend | react, component, hook, frontend, ui, tsx, jsx | `react-agent` |
| debug | bug, error, failed, exception, traceback, test fail, 실패, 에러 | `debugger` |

Build, type, compile, lint, or test infrastructure failures may also recommend `build-error-resolver`.

## Docs-Only Exception

Docs-only prompts should stay low risk:

- Set score to 0-4.
- Do not recommend `code-reviewer`.
- Do not require verification unless the prompt also asks for code, runtime behavior, or generated artifacts that need execution.

## Replacement For Static Auto-Triggers

This rule is intended to replace the static auto-trigger list in `rules/agents.md` over time:

- Static rules say what agent usually fits a category.
- Agent routing produces a per-request advisory decision with score, domains, risk, and recommended agents.
- Advisory output must not spawn agents by itself.
- Actual delegation still follows the active runtime policy: spawn only when explicitly requested or otherwise allowed by the current harness.

## Output Contract

The hook must return JSON and exit 0:

```json
{
  "decision": "approve",
  "reason": "[Agent Router] score=<n>, agents=<list>",
  "harness": {
    "component": "agent-router",
    "score": 0,
    "task_type": "general",
    "risk_level": "low",
    "domains": [],
    "recommended_agents": [],
    "verification_required": false
  }
}
```

If parsing fails or `jq` is unavailable, fail open with `decision=approve` and a reason containing `[Agent Router] skipped`.
