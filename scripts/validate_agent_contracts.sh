#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
AGENTS_DIR="$ROOT/agents"
RULES_FILE="$ROOT/rules/agents.md"
FAILED=0

fail() {
  echo "[FAIL] $*" >&2
  FAILED=$((FAILED + 1))
}

ok() {
  echo "[OK] $*"
}

if [ ! -d "$AGENTS_DIR" ]; then
  echo "[ERROR] agents directory not found: $AGENTS_DIR" >&2
  exit 2
fi

if [ ! -f "$RULES_FILE" ]; then
  echo "[ERROR] rules file not found: $RULES_FILE" >&2
  exit 2
fi

if ! command -v grep >/dev/null 2>&1; then
  echo "[ERROR] grep is required" >&2
  exit 2
fi

agent_name_from_file() {
  local file="$1"
  local base
  base=$(basename "$file" .md)
  local declared
  declared=$(grep -E '^name:' "$file" | head -1 | sed -E 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'" || true)
  if [ -n "$declared" ]; then
    printf '%s' "$declared"
  else
    printf '%s' "$base"
  fi
}

has_frontmatter() {
  local file="$1"
  head -1 "$file" | grep -qx -- '---'
}

has_field() {
  local file="$1"
  local field="$2"
  grep -Eq "^${field}:" "$file"
}

requires_no_write_tools() {
  local file="$1"
  if grep -E '^tools:' "$file" | grep -Eq 'Write|Edit'; then
    return 1
  fi
  return 0
}

requires_write_tools() {
  local file="$1"
  local missing=0
  for tool in Read Write Edit Bash Grep Glob; do
    if ! grep -E '^tools:' "$file" | grep -q "$tool"; then
      missing=1
    fi
  done
  return "$missing"
}

shopt -s nullglob
agent_files=("$AGENTS_DIR"/*.md)

for file in "${agent_files[@]}"; do
  name=$(agent_name_from_file "$file")
  base=$(basename "$file")

  if has_frontmatter "$file"; then
    for field in name description tools model; do
      has_field "$file" "$field" || fail "$base missing frontmatter field: $field"
    done
  else
    # Legacy agents are allowed, but should still be registered.
    :
  fi

  if ! grep -Fq "$name" "$RULES_FILE"; then
    fail "$base agent name '$name' not registered in rules/agents.md"
  fi

done

for required in pm-agent research-agent backend-agent designer-agent qa-agent react-agent coordinator; do
  [ -f "$AGENTS_DIR/${required}.md" ] || fail "missing required agent file: agents/${required}.md"
  grep -Fq "$required" "$RULES_FILE" || fail "missing required rules registration: $required"
done

for delivery in pm-agent research-agent backend-agent designer-agent qa-agent react-agent; do
  file="$AGENTS_DIR/${delivery}.md"
  [ -f "$file" ] || continue
  grep -Fq 'Handoff' "$file" || grep -Fq 'Output Contract' "$file" || fail "$delivery missing Handoff/Output Contract section"
done

for readonly_agent in pm-agent research-agent designer-agent; do
  file="$AGENTS_DIR/${readonly_agent}.md"
  [ -f "$file" ] || continue
  requires_no_write_tools "$file" || fail "$readonly_agent should not include Write/Edit tools"
done

for writer_agent in backend-agent react-agent; do
  file="$AGENTS_DIR/${writer_agent}.md"
  [ -f "$file" ] || continue
  requires_write_tools "$file" || fail "$writer_agent should include Read/Write/Edit/Bash/Grep/Glob tools"
done

grep -Fq 'Coordinator is the orchestrator' "$RULES_FILE" || fail "rules/agents.md must state coordinator is the orchestrator"
grep -Fq 'Project Delivery Handoff Contract' "$RULES_FILE" || fail "rules/agents.md missing Project Delivery Handoff Contract"

if [ "$FAILED" -gt 0 ]; then
  echo "[SUMMARY] failed=$FAILED" >&2
  exit 1
fi

ok "agent contracts validated"
exit 0
