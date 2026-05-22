#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
ROUTER="$ROOT/hooks/agent-router.sh"
FAILED=0

fail() {
  echo "[FAIL] $*" >&2
  FAILED=$((FAILED + 1))
}

ok() {
  echo "[OK] $*"
}

if [ ! -x "$ROUTER" ]; then
  if [ -f "$ROUTER" ]; then
    chmod +x "$ROUTER"
  else
    echo "[ERROR] router not found: $ROUTER" >&2
    exit 2
  fi
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[ERROR] jq is required" >&2
  exit 2
fi

run_case() {
  local name="$1"
  local prompt="$2"
  shift 2
  local output
  output=$(jq -n --arg prompt "$prompt" '{prompt:$prompt}' | "$ROUTER")
  echo "$output" | jq -e . >/dev/null || { fail "$name invalid JSON"; return; }

  local agent
  for agent in "$@"; do
    if echo "$output" | jq -e --arg agent "$agent" '.harness.recommended_agents | index($agent)' >/dev/null; then
      ok "$name includes $agent"
    else
      fail "$name missing $agent; output=$output"
    fi
  done
}

run_case "product-planning" "Plan a new IT project with PRD, scope, requirements, and acceptance criteria" pm-agent planner
run_case "backend-api" "Implement a backend API endpoint and service layer for orders" backend-agent code-reviewer
run_case "frontend-design" "Design a responsive landing page layout and implement it in React/Next.js" designer-agent react-agent code-reviewer
run_case "qa-release" "Check release readiness, regression risk, QA edge cases, and acceptance coverage" qa-agent
run_case "investigation" "Investigate a multi-step unclear test failure before changing code" reactor-agent debugger

if [ "$FAILED" -gt 0 ]; then
  echo "[SUMMARY] failed=$FAILED" >&2
  exit 1
fi

ok "agent router smoke tests passed"
