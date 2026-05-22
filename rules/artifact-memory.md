# Artifact Memory Rule

This rule defines how agents persist project state outside chat.

## Principle

Project state must be represented as compact artifacts, not as raw conversation history.

## Memory Tiers

- `memories/local/`: private temporary working context
- `memories/shared/`: validated cross-agent artifacts
- `memories/long_term/`: durable project conventions and lessons

## Shared Artifact Types

| Directory | Content |
|-----------|---------|
| `memories/shared/handoffs/` | JSON/MD handoffs between agents |
| `memories/shared/artifacts/` | PRDs, plans, specs, implementation summaries |
| `memories/shared/reviews/` | code/security/a11y/database review reports |
| `memories/shared/qa/` | QA matrices, release-readiness reports, E2E summaries |
| `memories/shared/decisions/` | ADRs and decision log entries |
| `memories/shared/runs/` | dry-run or real-run execution records |

## Required Behavior

- PM outputs should create or update artifacts under `memories/shared/artifacts/`.
- Agent handoffs should use `memories/shared/handoffs/` and follow `handoff.schema.json`.
- Reviewers should write reports under `memories/shared/reviews/`.
- QA should write release-readiness outputs under `memories/shared/qa/`.
- Durable decisions should be promoted to `memories/shared/decisions/` or `memories/long_term/`.

## Do Not Store

- broad chat transcripts
- private scratch work
- unsupported claims
- unrelated file diffs
- secrets or credentials

## Promotion Rule

A local note can be promoted to shared memory only when it has:

1. clear task ID
2. owner
3. deliverable or decision
4. evidence
5. validation method
6. next owner or terminal decision
