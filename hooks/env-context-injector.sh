#!/bin/bash
# shellcheck shell=bash
# UserPromptSubmit: Local Context Middleware
# Auto-injects environment context at the beginning of a session
# Output format: {"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"..."}}

INPUT=$(cat)

# Only inject once per session (use session-specific lock)
SESSION_KEY="${CLAUDE_SESSION_ID:-default}"
LOCK_FILE="${TMPDIR:-/tmp}/claude-env-context-${SESSION_KEY}"
if [ -f "$LOCK_FILE" ]; then
  exit 0
fi
touch "$LOCK_FILE"

# Gather environment context
CONTEXT=""

# Git info
if git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  STATUS=$(git status --short 2>/dev/null | head -10)
  RECENT_COMMITS=$(git log --oneline -5 2>/dev/null)
  CONTEXT="${CONTEXT}[Git] Branch: ${BRANCH}\n"
  if [ -n "$STATUS" ]; then
    CONTEXT="${CONTEXT}Changed files:\n${STATUS}\n"
  fi
  CONTEXT="${CONTEXT}Recent commits:\n${RECENT_COMMITS}\n\n"
fi

# Project detection
if [ -f "package.json" ]; then
  PKG_NAME=$(jq -r '.name // "unknown"' package.json 2>/dev/null)
  NODE_VER=$(node --version 2>/dev/null || echo "not installed")
  CONTEXT="${CONTEXT}[Project] ${PKG_NAME} (Node ${NODE_VER})\n"
fi
if [ -f "pyproject.toml" ]; then
  PY_VER=$(python3 --version 2>/dev/null || echo "not installed")
  CONTEXT="${CONTEXT}[Project] Python project (${PY_VER})\n"
fi
if [ -f "go.mod" ]; then
  GO_VER=$(go version 2>/dev/null || echo "not installed")
  CONTEXT="${CONTEXT}[Project] Go module (${GO_VER})\n"
fi
if [ -f "Cargo.toml" ]; then
  RUST_VER=$(rustc --version 2>/dev/null || echo "not installed")
  CONTEXT="${CONTEXT}[Project] Rust project (${RUST_VER})\n"
fi

# Working directory
CONTEXT="${CONTEXT}[CWD] $(pwd)\n"

if [ -n "$CONTEXT" ]; then
  jq -n --arg ctx "$CONTEXT" '{
    hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      additionalContext: ("[ENV CONTEXT]\n" + $ctx)
    }
  }'
fi

exit 0
