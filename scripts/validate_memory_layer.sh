#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
FAILED=0

fail() {
  echo "[FAIL] $*" >&2
  FAILED=$((FAILED + 1))
}

ok() {
  echo "[OK] $*"
}

require_file() {
  local path="$1"
  [ -f "$ROOT/$path" ] || fail "missing file: $path"
}

require_dir() {
  local path="$1"
  [ -d "$ROOT/$path" ] || fail "missing directory: $path"
}

require_text() {
  local path="$1"
  local pattern="$2"
  grep -Eq "$pattern" "$ROOT/$path" || fail "$path missing pattern: $pattern"
}

# Git only tracks directories that contain files. This validator checks the
# tracked baseline layer; dry-run-specific directories can be added later.
require_dir memories
require_dir memories/local
require_dir memories/shared
require_dir memories/long_term
require_dir memories/shared/handoffs
require_dir memories/shared/artifacts
require_dir memories/shared/reviews
require_dir memories/shared/qa
require_dir memories/shared/schemas
require_dir memories/shared/checklists

require_file memories/README.md
require_file memories/local/README.md
require_file memories/shared/README.md
require_file memories/long_term/README.md
require_file memories/shared/schemas/handoff.schema.json
require_file memories/shared/handoffs/handoff.example.json
require_file memories/shared/checklists/reviewer.checklist.md
require_file memories/shared/checklists/qa.checklist.md
require_file rules/artifact-memory.md
require_file rules/agent-handoff-contract.md

if command -v jq >/dev/null 2>&1; then
  jq -e . "$ROOT/memories/shared/schemas/handoff.schema.json" >/dev/null || fail "handoff schema is invalid JSON"
  jq -e . "$ROOT/memories/shared/handoffs/handoff.example.json" >/dev/null || fail "handoff example is invalid JSON"

  for field in task_id owner owner_scope inputs constraints deliverables evidence validation_method next_agent open_questions status; do
    jq -e --arg field "$field" 'has($field)' "$ROOT/memories/shared/handoffs/handoff.example.json" >/dev/null || fail "handoff example missing field: $field"
  done

  deliverable_count=$(jq '.deliverables | length' "$ROOT/memories/shared/handoffs/handoff.example.json")
  evidence_count=$(jq '.evidence | length' "$ROOT/memories/shared/handoffs/handoff.example.json")
  [ "$deliverable_count" -ge 1 ] || fail "handoff example must include at least one deliverable"
  [ "$evidence_count" -ge 1 ] || fail "handoff example must include at least one evidence item"
else
  echo "[WARN] jq unavailable; skipping JSON checks" >&2
fi

require_text rules/artifact-memory.md 'memories/shared/handoffs/'
require_text rules/artifact-memory.md 'memories/shared/artifacts/'
require_text rules/artifact-memory.md 'memories/shared/reviews/'
require_text rules/artifact-memory.md 'memories/shared/qa/'
require_text rules/artifact-memory.md 'memories/shared/decisions/'
require_text memories/shared/checklists/reviewer.checklist.md 'decision: pass\|fail\|blocked'
require_text memories/shared/checklists/qa.checklist.md 'qa_result: pass\|fail\|blocked'

if [ "$FAILED" -gt 0 ]; then
  echo "[SUMMARY] failed=$FAILED" >&2
  exit 1
fi

ok "memory layer validated"
exit 0
