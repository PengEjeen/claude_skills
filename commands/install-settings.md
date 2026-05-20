# Install Settings

Install repository harness settings into the Claude Code runtime settings file.

## Purpose

`setup.sh` symlinks hooks, rules, skills, commands, and agents into `~/.claude`, but Claude Code reads runtime hook wiring from `~/.claude/settings.json`.

Use this command when `settings.local.json` has hook/env/permission changes that must become active in Claude Code.

## Dry Run

From the repository root:

```bash
scripts/install-settings.sh --dry-run
```

This prints the merged settings JSON and reports:

- merged hooks count
- added hook commands
- skipped duplicate commands
- backup path placeholder

## Apply

```bash
scripts/install-settings.sh --yes
```

Behavior:

- Source: `settings.local.json`
- Target: `~/.claude/settings.json`
- Creates a backup before writing
- Merges `hooks`, `env`, `enabledPlugins`, and `permissions`
- Preserves existing `skipDangerousModePermissionPrompt` if the user already set it
- Deduplicates hooks by command within each event/matcher group

## Backup Only

```bash
scripts/install-settings.sh --backup-only
```

## Rollback

Restore the backup path printed by the installer:

```bash
cp ~/.claude/settings.json.bak.<timestamp> ~/.claude/settings.json
jq . ~/.claude/settings.json >/dev/null
```

Restart Claude Code after rollback.
