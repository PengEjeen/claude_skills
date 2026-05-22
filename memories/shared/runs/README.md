# Shared Runs

This directory stores dry-run and real-run execution traces for the multi-agent delivery workflow.

## Run Folder Shape

```text
YYYY-MM-DD-dry-run-001/
  01_user_goal.md
  02_pm_contract.md
  03_plan.md
  04_handoff_backend.json
  05_backend_output.md
  06_reviewer_report.md
  07_qa_report.md
  08_decision.md
```

## Rules

- Every run must have a stable task_id.
- PM contract, handoff, reviewer report, QA report, and decision must agree on the task_id.
- Handoff JSON must follow `memories/shared/schemas/handoff.schema.json`.
- Shared run folders must not contain scratch, cot, or private reasoning artifacts.
- QA failure must include rollback, retry, or replan evidence.
