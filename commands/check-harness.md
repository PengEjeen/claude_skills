# Check Harness

Check whether Claude Code runtime settings are actually wired to core-harness-v1.

## Commands

Run from any shell:

```bash
jq '.hooks' ~/.claude/settings.json >/dev/null
jq -e '.hooks.UserPromptSubmit[]?.hooks[]?.command | select(test("agent-router.sh"))' ~/.claude/settings.json
jq -e '.hooks.PreToolUse[]?.hooks[]?.command | select(test("test-integrity-gate.sh"))' ~/.claude/settings.json
jq -e '.hooks.PostToolUse[]?.hooks[]?.command | select(test("verification-planner.sh"))' ~/.claude/settings.json
test -x ~/.claude/hooks/test-integrity-gate.sh
jq . ~/.claude/settings.json >/dev/null
ls -1 ~/.claude/traces 2>/dev/null | tail
```

## Expected

- `~/.claude/settings.json` exists and is valid JSON.
- `hooks` key exists.
- `agent-router.sh` is registered under `UserPromptSubmit`.
- `test-integrity-gate.sh` is registered under `PreToolUse`.
- `verification-planner.sh` is registered under `PostToolUse`.
- `~/.claude/hooks/test-integrity-gate.sh` exists and is executable.
- Recent trace files may exist under `~/.claude/traces/` after Claude Code tool activity.

## Repair

If settings are missing:

```bash
scripts/install-settings.sh --dry-run
scripts/install-settings.sh --yes
```
