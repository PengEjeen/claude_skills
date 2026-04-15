# Git Workflow

globs: ['**/*']

## Commit Format
```
<type>: <description>
```
Types: feat, fix, refactor, docs, test, chore, perf, ci

## Feature Workflow
1. **Plan** with planner agent
2. **TDD**: write tests first -> implement -> refactor -> verify 80%+ coverage
3. **Review** with code-reviewer agent
4. **Commit** with conventional format

## PR Workflow
1. Check full commit history with `git diff [base]...HEAD`
2. Comprehensive PR summary covering ALL commits
3. Push with `-u` flag for new branches
