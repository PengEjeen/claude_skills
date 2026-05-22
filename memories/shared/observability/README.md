# Observability

This directory stores generated reports for multi-agent dry-runs and delivery traces.

## Purpose

Validation scripts answer whether the structure is valid. Observability reports answer what happened, where evidence exists, and what failed first.

## Generated Files

- `dry_run_observability_latest.md`: latest human-readable dry-run report
- `dry_run_observability_latest.jsonl`: latest machine-readable dry-run report

## Report Fields

Each run should summarize:

- run_name
- validation_status
- first_failure_reason
- task_id
- pm_owner
- handoff_owner
- handoff_next_agent
- evidence_count
- deliverable_count
- reviewer_decision
- qa_result
- rollback_required
- final_decision

## Rule

Reports are generated artifacts. Do not hand-edit generated reports unless explicitly correcting the generator output.
