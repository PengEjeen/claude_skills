# Agent System

This document is the current source of truth for the project-delivery agent system.

## Current Agent Count

Total: **30 agents**

Breakdown:

- Core Agents: 7
- Project Delivery Agents: 5
- Quality & Review Agents: 10
- Domain-Specific Agents: 4
- Meta & Orchestration Agents: 4

## Orchestrator

`coordinator` is the orchestrator. Do not create a separate orchestrator agent.

The coordinator is responsible for:

- selecting agents
- choosing sequential vs parallel execution
- preserving handoff state
- aggregating results
- routing failures back to the responsible agent

## Default Project Delivery Flow

```text
pm-agent
  -> planner
  -> research-agent if needed
  -> architect if needed
  -> backend-agent / react-agent / designer-agent
  -> code-reviewer / security-reviewer / a11y-reviewer
  -> qa-agent / e2e-runner
```

## Agent Categories

### Core Agents (7)

| Agent | Role |
|-------|------|
| planner | implementation planning |
| code-reviewer | mandatory post-change code review |
| tdd-guide | test-first development guidance |
| security-reviewer | auth, API, user input, sensitive data review |
| build-error-resolver | build/type/compile failures |
| debugger | runtime errors and failing tests |
| architect | system design and technical decisions |

### Project Delivery Agents (5)

| Agent | Role |
|-------|------|
| pm-agent | PRD, scope, acceptance criteria, task ownership |
| research-agent | evidence-first technical/product/library/API research |
| backend-agent | API, service, data access, validation, backend tests |
| designer-agent | UX flow, visual direction, design spec, references |
| qa-agent | acceptance coverage, edge cases, regression risk, release readiness |

### Quality & Review Agents (10)

- a11y-reviewer
- database-reviewer
- python-reviewer
- go-reviewer
- go-build-resolver
- graphql-expert
- rust-expert
- refactor-cleaner
- performance-optimizer
- doc-updater

### Domain-Specific Agents (4)

- react-agent
- e2e-runner
- infrastructure-agent
- vector-db-agent

### Meta & Orchestration Agents (4)

- coordinator
- critic-agent
- tree-of-thoughts
- reactor-agent

## Handoff Contract

Project-delivery handoffs use the contract in `rules/agent-handoff-contract.md`.

Required fields:

- task_id
- owner
- owner_scope
- inputs
- constraints
- deliverables
- evidence
- validation_method
- next_agent
- open_questions

## MCP Policy

Agent-specific MCP/tool access is defined in `rules/mcp-agent-policy.md`.

Default policy:

- prefer read-only tool use
- use write-capable external tools only when explicitly requested
- record evidence for tool-derived claims
- treat production-affecting tools as high risk

## Validation

Agent system consistency is checked by:

```bash
bash scripts/validate_agent_contracts.sh
bash scripts/test_agent_router.sh
```

The CI workflow `.github/workflows/validate-agents.yml` runs both checks for changes to agents, routing rules, handoff rules, MCP policy, and validation scripts.
