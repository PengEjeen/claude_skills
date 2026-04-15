# Coding Style

globs: ['**/*.ts', '**/*.js', '**/*.tsx', '**/*.jsx', '**/*.py', '**/*.go', '**/*.rs']

## Principles
- **Functional Core, Imperative Shell**: Pure business logic separate from I/O
- **Type-Driven**: Define types/interfaces first, then implement
- **Result Types**: Use `Result<T, E>` for expected errors instead of exceptions
- **Immutability**: Always create new objects, never mutate existing ones

## Limits
| Metric | Target |
|--------|--------|
| Function length | < 50 lines |
| File length | < 400 lines (800 max) |
| Cyclomatic complexity | < 10 per function |
| Nesting depth | < 4 levels |
| Test coverage | > 80% |

## Organization
- Feature/domain-based file structure, not type-based
- High cohesion within modules, low coupling between them
- Validate user input at boundaries (zod/joi)
- No console.log in production code
- No hardcoded values
