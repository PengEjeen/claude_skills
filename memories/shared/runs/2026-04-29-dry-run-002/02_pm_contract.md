# PM Contract

- task_id: T-DRY-002
- owner: react-agent
- owner_scope: Implement responsive landing page hero UI only.
- dependency: existing design tokens and component primitives
- done_criteria: Hero section renders primary headline, supporting copy, CTA, and responsive layout with accessibility notes.
- validation_method: code-reviewer, a11y-reviewer evidence, and qa-agent release-readiness decision.
- next_agent: react-agent

## Acceptance Criteria

- [ ] Hero section has mobile-first responsive layout.
- [ ] Primary CTA is keyboard accessible.
- [ ] Existing design tokens are reused.
- [ ] UI output includes verification evidence.
- [ ] Reviewer and QA gates complete.

## Risks

- Visual design drift if existing tokens are ignored.
- Accessibility regression if CTA semantics are wrong.
