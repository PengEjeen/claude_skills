# Context Management

## Session Lifecycle
- `/clear` > `/compact` for task boundaries (zero info loss)
- At 70% context usage: proactively compact or start new session
- Never push past 80% — start fresh instead
- Manual `/compact` before 50% for best results

## Multi-Session Workflow
1. **Research session**: explore codebase, read docs, identify approach
2. **Spec session**: write SPEC.md with requirements, edge cases, trade-offs
3. **Implementation session**: fresh context, spec-driven coding

## Compaction Rules
When compacting, ALWAYS preserve:
- List of modified files with change summaries
- Current test commands and their last results
- Active task description and acceptance criteria
- Unresolved blockers or decisions

## Anti-Drift
- 2x same fix attempt on same issue -> `/clear` and restart
- 10+ conversations where 3+ require manual corrections -> re-optimize CLAUDE.md
- Prefer `/handoff` command before ending complex sessions
