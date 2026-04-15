#!/bin/bash
# shellcheck shell=bash
# WorktreeCreate: Worktree Environment Setup
# git worktree 생성 시 자동으로 의존성 설치 및 환경 초기화
# Source: src/types/hooks.ts - WorktreeCreate event

INPUT=$(cat)

# Get worktree path from hook input
WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktreePath // ""' 2>/dev/null)

if [ -z "$WORKTREE_PATH" ] || [ ! -d "$WORKTREE_PATH" ]; then
  # Try current directory as fallback
  WORKTREE_PATH=$(pwd)
fi

echo "[WORKTREE] 설정 시작: ${WORKTREE_PATH}" >&2

# Node.js project setup
if [ -f "${WORKTREE_PATH}/package.json" ]; then
  PKG_NAME=$(jq -r '.name // "unknown"' "${WORKTREE_PATH}/package.json" 2>/dev/null)
  echo "[WORKTREE] Node.js 프로젝트 감지: ${PKG_NAME}" >&2

  # Check if node_modules exists and is recent
  if [ ! -d "${WORKTREE_PATH}/node_modules" ]; then
    echo "[WORKTREE] npm install 실행 중 (백그라운드)..." >&2
    (cd "$WORKTREE_PATH" && npm install --silent 2>/dev/null &)
  fi
fi

# Python project setup
if [ -f "${WORKTREE_PATH}/pyproject.toml" ] || [ -f "${WORKTREE_PATH}/requirements.txt" ]; then
  PY_VER=$(python3 --version 2>/dev/null || echo "not installed")
  echo "[WORKTREE] Python 프로젝트 감지 (${PY_VER})" >&2
  echo "[WORKTREE] 가상환경 확인: venv, .venv 폴더 없으면 직접 생성 필요" >&2
fi

# Go project setup
if [ -f "${WORKTREE_PATH}/go.mod" ]; then
  echo "[WORKTREE] Go 모듈 감지 — go mod download 권장" >&2
fi

# Rust project setup
if [ -f "${WORKTREE_PATH}/Cargo.toml" ]; then
  echo "[WORKTREE] Rust 프로젝트 감지 — cargo build 권장" >&2
fi

# Log worktree creation
LOG_DIR="${HOME}/.claude/traces"
mkdir -p "$LOG_DIR"
echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"WorktreeCreate\",\"path\":\"${WORKTREE_PATH}\",\"session\":\"${CLAUDE_SESSION_ID:-unknown}\"}" >> "${LOG_DIR}/worktree-log.jsonl"

echo "[WORKTREE] 설정 완료: ${WORKTREE_PATH}" >&2

exit 0
