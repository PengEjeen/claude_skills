#!/bin/bash
# shellcheck shell=bash
# Merge repository settings.local.json into Claude Code runtime settings.json.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_FILE="$ROOT_DIR/settings.local.json"
TARGET_DIR="${HOME}/.claude"
TARGET_FILE="${TARGET_DIR}/settings.json"

DRY_RUN=false
YES=false
BACKUP_ONLY=false

usage() {
  cat <<'EOF'
Usage: scripts/install-settings.sh [--dry-run] [--yes] [--backup-only]

Options:
  --dry-run      Print merged settings without writing ~/.claude/settings.json
  --yes          Apply without confirmation prompt
  --backup-only  Create a backup and exit without merging
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --yes) YES=true ;;
    --backup-only) BACKUP_ONLY=true ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Required command not found: $cmd" >&2
    exit 1
  fi
}

timestamp() {
  date '+%Y%m%d-%H%M%S'
}

make_backup() {
  local current_file="$1"
  local backup_file="$2"

  mkdir -p "$(dirname "$backup_file")"
  if [ -f "$current_file" ]; then
    cp "$current_file" "$backup_file"
  else
    printf '{}\n' > "$backup_file"
  fi
}

require_cmd jq

if [ ! -f "$SOURCE_FILE" ]; then
  echo "Source settings not found: $SOURCE_FILE" >&2
  exit 1
fi

jq . "$SOURCE_FILE" >/dev/null

mkdir -p "$TARGET_DIR"
current_file="$(mktemp)"
merged_file="$(mktemp)"
summary_file="$(mktemp)"
tmp_target_file=""
cleanup() {
  rm -f "$current_file" "$merged_file" "$summary_file"
  if [ -n "$tmp_target_file" ]; then
    rm -f "$tmp_target_file"
  fi
}
trap cleanup EXIT

if [ -f "$TARGET_FILE" ]; then
  jq . "$TARGET_FILE" > "$current_file"
else
  printf '{}\n' > "$current_file"
fi

backup_file="${TARGET_FILE}.bak.$(timestamp)"

if [ "$BACKUP_ONLY" = true ]; then
  make_backup "$TARGET_FILE" "$backup_file"
  echo "backup path: $backup_file"
  exit 0
fi

jq -n \
  --slurpfile target "$current_file" \
  --slurpfile source "$SOURCE_FILE" \
  '
  def hook_key:
    if has("command") then "command:" + (.command // "")
    else tostring
    end;

  def unique_hooks(existing; incoming):
    (existing // []) as $existing
    | (incoming // []) as $incoming
    | ($existing | map(hook_key)) as $seen
    | {
        hooks: ($existing + ($incoming | map(select((hook_key as $k | $seen | index($k)) | not)))),
        added: ($incoming | map(select((hook_key as $k | $seen | index($k)) | not)) | map(.command // empty)),
        skipped: ($incoming | map(select((hook_key as $k | $seen | index($k)) != null)) | map(.command // empty))
      };

  def merge_event_groups($target_groups; $source_groups):
    reduce ($source_groups // [])[] as $sg (
      {groups: ($target_groups // []), added: [], skipped: []};
      ($sg.matcher // "__all__") as $matcher
      | ([.groups[]? | (.matcher // "__all__")] | index($matcher)) as $idx
      | if $idx == null then
          .groups += [$sg]
          | .added += (($sg.hooks // []) | map(.command // empty))
        else
          (unique_hooks(.groups[$idx].hooks; $sg.hooks)) as $merged
          | .groups[$idx].hooks = $merged.hooks
          | .added += $merged.added
          | .skipped += $merged.skipped
        end
    );

  def merge_hooks($target_hooks; $source_hooks):
    reduce (($source_hooks // {}) | keys_unsorted[]) as $event (
      {hooks: ($target_hooks // {}), added: [], skipped: []};
      (merge_event_groups(.hooks[$event]; $source_hooks[$event])) as $event_merge
      | .hooks[$event] = $event_merge.groups
      | .added += $event_merge.added
      | .skipped += $event_merge.skipped
    );

  ($target[0] // {}) as $t
  | ($source[0] // {}) as $s
  | (merge_hooks($t.hooks; $s.hooks)) as $hook_merge
  | (
      $t
      | .env = (($s.env // {}) + ($t.env // {}))
      | .enabledPlugins = (($s.enabledPlugins // {}) + ($t.enabledPlugins // {}))
      | .hooks = $hook_merge.hooks
      | .permissions = (($s.permissions // {}) + ($t.permissions // {}))
      | .permissions.allow = ((($t.permissions.allow // []) + ($s.permissions.allow // [])) | unique)
      | .permissions.deny = ((($t.permissions.deny // []) + ($s.permissions.deny // [])) | unique)
      | if ($t | has("skipDangerousModePermissionPrompt")) then
          .skipDangerousModePermissionPrompt = $t.skipDangerousModePermissionPrompt
        elif ($s | has("skipDangerousModePermissionPrompt")) then
          .skipDangerousModePermissionPrompt = $s.skipDangerousModePermissionPrompt
        else
          .
        end
    ) as $merged
  | {
      merged: $merged,
      summary: {
        hooks_count: ([($merged.hooks // {})[]?[]?.hooks[]?] | length),
        added_hook_commands: ($hook_merge.added | map(select(length > 0)) | unique),
        skipped_duplicate_commands: ($hook_merge.skipped | map(select(length > 0)) | unique)
      }
    }
  ' > "$summary_file"

jq '.merged' "$summary_file" > "$merged_file"
jq . "$merged_file" >/dev/null

added_commands="$(jq -r '.summary.added_hook_commands[]? // empty' "$summary_file")"
skipped_commands="$(jq -r '.summary.skipped_duplicate_commands[]? // empty' "$summary_file")"
hooks_count="$(jq -r '.summary.hooks_count' "$summary_file")"

if [ "$DRY_RUN" = true ]; then
  jq . "$merged_file"
  echo "merged hooks count: $hooks_count" >&2
  echo "added hook commands:" >&2
  if [ -n "$added_commands" ]; then
    printf '%s\n' "$added_commands" >&2
  else
    echo "(none)" >&2
  fi
  echo "skipped duplicate commands:" >&2
  if [ -n "$skipped_commands" ]; then
    printf '%s\n' "$skipped_commands" >&2
  else
    echo "(none)" >&2
  fi
  echo "backup path: (dry-run; no backup created)" >&2
  exit 0
fi

if [ "$YES" != true ]; then
  printf 'Install Claude Code runtime settings to %s? (y/N) ' "$TARGET_FILE"
  read -r answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *)
      echo "Aborted."
      exit 0
      ;;
  esac
fi

make_backup "$TARGET_FILE" "$backup_file"
tmp_target_file="$(mktemp "${TARGET_DIR}/settings.json.tmp.XXXXXX")"
install -m 0644 "$merged_file" "$tmp_target_file"
jq . "$tmp_target_file" >/dev/null
mv "$tmp_target_file" "$TARGET_FILE"
tmp_target_file=""

echo "merged hooks count: $hooks_count"
echo "added hook commands:"
if [ -n "$added_commands" ]; then
  printf '%s\n' "$added_commands"
else
  echo "(none)"
fi
echo "skipped duplicate commands:"
if [ -n "$skipped_commands" ]; then
  printf '%s\n' "$skipped_commands"
else
  echo "(none)"
fi
echo "backup path: $backup_file"
