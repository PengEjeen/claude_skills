# Session Handoff

Generate a handoff document for the next session. Write to `progress/handoff-$(date +%Y%m%d-%H%M).md`:

## Current State
- Branch: `$(git branch --show-current)`
- Last commit: `$(git log --oneline -1)`

## Modified Files
$(git diff --name-only HEAD~1 || git diff --name-only --cached || echo "No changes")

## What Was Done
[Summarize completed work in 3-5 bullets]

## What Remains
[List remaining tasks with checkboxes]

## Known Issues
[Any blockers, failed tests, or unresolved decisions]

## Next Steps
[Ordered list of what the next session should do first]

## Key Context
[Any non-obvious decisions or constraints the next session needs to know]
