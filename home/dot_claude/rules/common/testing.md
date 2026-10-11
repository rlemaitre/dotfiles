# Testing Requirements

Applies to application code projects. For dotfiles, config, scripts and docs, validate with the repo's own checks (`mise run check`, linters) instead.

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (framework chosen per language)

## Test-Driven Development

Follow the superpowers `test-driven-development` skill: failing test first (RED), minimal implementation (GREEN), refactor,
then verify coverage (80%+).

## Troubleshooting Test Failures

1. Use the superpowers `systematic-debugging` skill
2. Check test isolation
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)
