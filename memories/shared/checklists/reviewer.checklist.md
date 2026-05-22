# Reviewer Gate Checklist

Use this checklist before a code/security/a11y/database review is marked complete.

## Required Fields

- task_id
- reviewed_artifacts
- reviewer
- decision: pass|fail|blocked
- evidence
- required_changes
- next_agent

## Review Questions

- Does the implementation satisfy the stated owner scope?
- Are changes limited to the declared file scope?
- Are tests or verification commands included?
- Are security, accessibility, data, or performance risks identified?
- Are blockers explicit and assigned to a next agent?

## Decision Rules

- `pass`: evidence supports completion and no blocking issues remain.
- `fail`: required changes are clear and assigned.
- `blocked`: missing input, unclear requirement, or external dependency prevents review.
