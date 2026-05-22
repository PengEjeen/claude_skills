# QA Gate Checklist

Use this checklist before a task is considered release-ready.

## Required Fields

- task_id
- qa_owner
- qa_result: pass|fail|blocked
- acceptance_coverage
- edge_cases
- regression_risks
- failed_checks
- rollback_required
- evidence
- next_agent

## QA Questions

- Is every acceptance criterion mapped to evidence?
- Are edge cases covered or explicitly deferred?
- Are known regression risks documented?
- Were required tests or manual checks run?
- Is rollback, replan, or retry required?
- Is human approval required before release?

## Decision Rules

- `pass`: all critical acceptance criteria have evidence.
- `fail`: implementation must return to the responsible agent.
- `blocked`: missing requirements, environment, data, or reviewer evidence prevents QA.
