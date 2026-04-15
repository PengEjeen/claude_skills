# Testing Requirements

globs: ['**/*.test.*', '**/*.spec.*', '**/tests/**', '**/test/**', '**/__tests__/**']

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (Playwright)

## Test-Driven Development

MANDATORY workflow:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Test Integrity (NEVER weaken tests to pass)

Prohibited patterns — fix implementation, not tests:
- `toBeTruthy()` replacing specific matchers (e.g., `toBe(value)`)
- `test.skip`, `xit(`, `xdescribe(`, `@pytest.mark.skip` without documented reason
- Timeout inflation (>30s without justification)
- Empty catch blocks in test assertions
- Removing assertions to make tests pass

## Troubleshooting Test Failures

1. Use **tdd-guide** agent
2. Check test isolation
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)

## Agent Support

- **tdd-guide** - Use PROACTIVELY for new features, enforces write-tests-first
- **e2e-runner** - Playwright E2E testing specialist
