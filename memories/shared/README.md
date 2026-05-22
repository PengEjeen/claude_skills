# Shared Memory

Shared memory stores validated cross-agent artifacts.

## Directory Layout

```text
memories/shared/
  handoffs/    structured handoff JSON/MD
  artifacts/   PRDs, specs, plans, implementation summaries
  reviews/     code/security/a11y/database review reports
  qa/          QA matrices, release-readiness reports, E2E summaries
  decisions/   ADR-style decisions and decision log entries
  runs/        dry-run or real-run execution records
```

## Rules

- Store only validated, artifact-focused outputs.
- Do not store broad conversation history.
- Do not store agent-private scratch work.
- Every handoff must follow `schemas/handoff.schema.json`.
- Reviews and QA outputs should reference task IDs and evidence.
