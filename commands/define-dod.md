# Define Done (Machine-Verifiable DoD)

Create a Definition of Done checklist for the current feature at `progress/feature-$FEATURE_NAME.md`:

## Feature: $ARGUMENTS

### Acceptance Criteria
- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]

### Quality Gates (auto-verified)
- [ ] All tests pass (`npm test` / `pytest`)
- [ ] Coverage >= 80% for new code
- [ ] No lint errors
- [ ] No TypeScript/type errors
- [ ] Security review passed (no hardcoded secrets, input validated)

### Manual Review Required
- [ ] Auth/payment/data-mutation logic reviewed by human
- [ ] Edge cases documented and tested
- [ ] Error messages are user-friendly, no internal leaks

### Status: NOT_STARTED
Progress: 0/$TOTAL_CRITERIA

---
Mark each criterion as PASS/FAIL. Feature is DONE only when all criteria are PASS.
