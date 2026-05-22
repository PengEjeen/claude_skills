# Agent Handoff Contract

This rule defines the compact state format used when work moves between project-delivery agents.

## Required Fields

Every project-delivery handoff must include:

- `task_id`: stable task identifier
- `owner`: current responsible agent
- `owner_scope`: exact responsibility and file or artifact scope
- `inputs`: files, specs, links, or prior artifacts used as input
- `constraints`: technical, product, security, UX, or scope constraints
- `deliverables`: concrete files, specs, reports, or decisions produced
- `evidence`: commands, tests, references, diffs, docs, or review notes supporting the result
- `validation_method`: how completion should be checked
- `next_agent`: recommended next agent
- `open_questions`: unresolved questions or blockers

## Recommended Markdown Shape

```markdown
[agent-name] STATUS: complete|blocked|needs-review

## Handoff
- task_id: T-001
- owner: backend-agent
- owner_scope: API endpoint implementation only
- inputs:
  - spec/api/orders.md
- constraints:
  - Preserve existing auth middleware
- deliverables:
  - src/api/orders.ts
  - tests/api/orders.test.ts
- evidence:
  - npm test -- orders.test.ts: pass
- validation_method: code-reviewer + qa-agent
- next_agent: code-reviewer
- open_questions:
  - none
```

## Forbidden Handoff Content

Do not include:

- broad chat history when a compact state summary is enough
- unrelated file changes
- vague next steps such as "continue" or "review later"
- unsupported claims without evidence
- implementation details outside the agent's declared scope

## Routing Expectations

- PM handoffs should route to `planner`, `research-agent`, or `architect`.
- Research handoffs should route to the agent that can act on the evidence.
- Backend handoffs should route to `code-reviewer`, `security-reviewer`, or `database-reviewer` as needed.
- Frontend handoffs should route to `code-reviewer`, `a11y-reviewer`, or `e2e-runner` as needed.
- QA handoffs should route to implementation agents on failure or human approval on pass.

## Consistency Rules

- `owner` must match the emitting agent.
- `next_agent` must be a known agent.
- Evidence is required for completion claims.
- Handoffs should be artifact-focused and concise.
