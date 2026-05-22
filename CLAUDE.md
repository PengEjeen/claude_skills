# Global Claude Code Instructions

This file defines global Claude Code behavior for all projects.

## ALWAYS

- `workflow.md`: Explain, approve, execute, reflect. Use evidence-based updates.
- `cs-boost.md`: Summarize code changes, decompose errors before fixing, run security checks before commits.
- `harness-engineering.md`: Use the harness middleware pipeline and reasoning budget rules.
- `agents.md`: Use coordinator-led orchestration, project-delivery agents, and review/QA gates.

## On-Demand Rules

| Situation | Rule |
|-----------|------|
| Code writing or review | `coding-style.md`, `testing.md` |
| API, auth, input handling | `security.md` |
| Agent dispatch | `agents.md` |
| Agent handoff | `agent-handoff-contract.md` |
| Git or PR work | `git-workflow.md` |
| Session or context | `context-management.md` |
| Hook configuration | `hooks.md` |
| MCP integration | `mcp-patterns.md`, `mcp-agent-policy.md` |
| Advanced workflows | `advanced-workflows.md` |
| Tool discovery | `/tool-registry` |
