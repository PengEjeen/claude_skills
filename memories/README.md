# Memories

This directory defines the project memory and artifact layer used by the multi-agent harness.

## Purpose

Agents should not rely on broad chat history for project state. They should exchange compact, validated artifacts through the shared memory layer.

## Memory Tiers

```text
memories/
  local/       agent-private working notes; not shared as final state
  shared/      validated handoffs, artifacts, reviews, QA reports, decisions
  long_term/   durable project rules, recurring constraints, retrospectives
```

## Core Rule

Only validated outputs belong in `shared/`. Temporary notes and exploratory scratch work should stay outside shared artifacts.

## Related Rules

- `rules/agent-handoff-contract.md`
- `rules/artifact-memory.md`
- `rules/agents.md`
- `AGENT_SYSTEM.md`
