#!/bin/bash
# shellcheck shell=bash
# PreToolUse: Block dangerous bash commands globally
# Blocks: rm -rf, git push --force, git reset --hard, git clean -f, drop table/database

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# rm with -rf (any order) — catches rm -rf *, rm -rf /, rm -rf .
if echo "$COMMAND" | grep -qiE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|-[a-zA-Z]*f[a-zA-Z]*r)\s'; then
  cat <<'EOF'
{"decision":"block","reason":"[SAFETY] rm -rf detected. Verify the target path carefully and use a more specific command."}
EOF
  exit 0
fi

# git push --force (but NOT --force-with-lease which is safer)
if echo "$COMMAND" | grep -qiE 'git\s+push\s+.*--force($|\s)' && \
   ! echo "$COMMAND" | grep -qiE 'git\s+push\s+.*--force-with-lease'; then
  cat <<'EOF'
{"decision":"block","reason":"[SAFETY] git push --force detected. This can overwrite remote history. Use --force-with-lease instead, or confirm with the user."}
EOF
  exit 0
fi

# git push -f (short flag)
if echo "$COMMAND" | grep -qiE 'git\s+push\s+.*\s-f($|\s)'; then
  cat <<'EOF'
{"decision":"block","reason":"[SAFETY] git push -f detected. This can overwrite remote history. Use --force-with-lease instead, or confirm with the user."}
EOF
  exit 0
fi

if echo "$COMMAND" | grep -qiE 'git\s+reset\s+--hard'; then
  cat <<'EOF'
{"decision":"block","reason":"[SAFETY] git reset --hard detected. This discards all uncommitted changes permanently. Confirm with the user first."}
EOF
  exit 0
fi

if echo "$COMMAND" | grep -qiE 'git\s+clean\s+(-[a-zA-Z]*f|--force)'; then
  cat <<'EOF'
{"decision":"block","reason":"[SAFETY] git clean -f detected. This permanently deletes untracked files. Use git clean -n (dry-run) first."}
EOF
  exit 0
fi

if echo "$COMMAND" | grep -qiE 'drop\s+(table|database|schema)'; then
  cat <<'EOF'
{"decision":"block","reason":"[SAFETY] DROP TABLE/DATABASE detected. This is irreversible. Confirm with the user first."}
EOF
  exit 0
fi

# Allow everything else
exit 0
