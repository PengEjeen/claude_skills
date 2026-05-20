#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/install-settings.sh"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required for install-settings tests" >&2
  exit 1
fi

fake_home="$(mktemp -d /tmp/install-settings-home.XXXXXX)"
trap 'rm -rf "$fake_home"' EXIT

mkdir -p "$fake_home/.claude"
cat > "$fake_home/.claude/settings.json" <<'JSON'
{
  "customKey": "keep-me",
  "env": {
    "USER_VALUE": "1"
  },
  "permissions": {
    "allow": ["Read"],
    "deny": ["Bash(rm -rf:*)"]
  },
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/agent-router.sh",
            "timeout": 3
          }
        ]
      }
    ]
  },
  "skipDangerousModePermissionPrompt": false
}
JSON

HOME="$fake_home" "$SCRIPT" --dry-run > "$fake_home/dry-run.json" 2> "$fake_home/dry-run.log"
jq . "$fake_home/dry-run.json" >/dev/null
test ! -f "$fake_home/.claude/settings.json.bak"

HOME="$fake_home" "$SCRIPT" --yes > "$fake_home/apply-1.log"
jq . "$fake_home/.claude/settings.json" >/dev/null

jq -e '.customKey == "keep-me"' "$fake_home/.claude/settings.json" >/dev/null
jq -e '.skipDangerousModePermissionPrompt == false' "$fake_home/.claude/settings.json" >/dev/null
jq -e '.permissions.allow | index("Read") != null' "$fake_home/.claude/settings.json" >/dev/null
jq -e '.permissions.allow | index("Write") != null' "$fake_home/.claude/settings.json" >/dev/null
jq -e '.permissions.deny | index("Bash(rm -rf:*)") != null' "$fake_home/.claude/settings.json" >/dev/null

backup_count="$(find "$fake_home/.claude" -maxdepth 1 -name 'settings.json.bak.*' | wc -l)"
if [ "$backup_count" -lt 1 ]; then
  echo "expected at least one backup" >&2
  exit 1
fi

HOME="$fake_home" "$SCRIPT" --yes > "$fake_home/apply-2.log"
jq . "$fake_home/.claude/settings.json" >/dev/null

agent_router_count="$(
  jq '[.hooks.UserPromptSubmit[]?.hooks[]? | select(.command == "bash ~/.claude/hooks/agent-router.sh")] | length' "$fake_home/.claude/settings.json"
)"
if [ "$agent_router_count" -ne 1 ]; then
  echo "agent-router hook duplicated: $agent_router_count" >&2
  exit 1
fi

integrity_commit_count="$(
  jq '[.hooks.PreToolUse[]? | select(.matcher == "Bash(git commit*)") | .hooks[]? | select(.command == "bash ~/.claude/hooks/test-integrity-gate.sh")] | length' "$fake_home/.claude/settings.json"
)"
if [ "$integrity_commit_count" -ne 1 ]; then
  echo "test-integrity git commit hook duplicated: $integrity_commit_count" >&2
  exit 1
fi

planner_count="$(
  jq '[.hooks.PostToolUse[]? | select(.matcher == "Edit|Write") | .hooks[]? | select(.command == "bash ~/.claude/hooks/verification-planner.sh")] | length' "$fake_home/.claude/settings.json"
)"
if [ "$planner_count" -ne 1 ]; then
  echo "verification-planner hook duplicated: $planner_count" >&2
  exit 1
fi

HOME="$fake_home" "$SCRIPT" --backup-only > "$fake_home/backup-only.log"
grep -q 'backup path:' "$fake_home/backup-only.log"

missing_home="$(mktemp -d /tmp/install-settings-missing-home.XXXXXX)"
trap 'rm -rf "$fake_home" "$missing_home"' EXIT
HOME="$missing_home" "$SCRIPT" --yes > "$missing_home/apply-missing.log"
jq . "$missing_home/.claude/settings.json" >/dev/null
jq -e '.hooks.UserPromptSubmit[]?.hooks[]?.command | select(test("agent-router.sh"))' "$missing_home/.claude/settings.json" >/dev/null
test -f "$missing_home/.claude/settings.json.bak."*

echo "test-install-settings: OK"
