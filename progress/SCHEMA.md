# claude-progress.txt Schema

> Cross-session state management for long-running agents.
> Based on Anthropic's documented pattern for multi-context agents.

## Format

```
# Claude Progress — [Project Name]
Updated: [ISO 8601 timestamp]
Session: [session count]
Branch: [current git branch]

## Current Task
- [ ] [Active task description]
- [x] [Completed subtask]

## Last Session Summary
- Files modified: [list]
- Tests: [pass/fail count]
- Blockers: [if any]

## Key Decisions
- [Decision 1]: [rationale]

## Next Steps
1. [Highest priority]
2. [Second priority]

## Known Issues
- [Issue]: [status]
```

## Rules

1. **Size limit**: Max 100 lines. If exceeded, archive old content to `progress/archive/`
2. **Freshness**: progress-loader.sh shows elapsed time since last update
3. **Validation**: progress-tracker.sh updates on every session end
4. **Rotation**: Create new file per major feature/milestone
5. **Git tracking**: Always committed (not in .gitignore)

## Lifecycle

```
Session Start → progress-loader.sh reads → injects into context
Session Work  → tasks tracked in memory
Session End   → progress-tracker.sh writes → git status appended
Next Session  → regression-gate.sh checks → progress-loader.sh reads
```
