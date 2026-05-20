#!/bin/bash
# shellcheck shell=bash
# UserPromptSubmit: Agent Router advisory hook
# Classifies the user prompt and recommends agents without executing them.

INPUT=$(</dev/stdin)

skipped() {
  local reason="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg reason "$reason" '{
      decision: "approve",
      reason: ("[Agent Router] skipped: " + $reason),
      harness: {
        component: "agent-router",
        score: 0,
        domains: [],
        recommended_agents: [],
        verification_required: false
      }
    }'
  else
    printf '{"decision":"approve","reason":"[Agent Router] skipped: jq unavailable","harness":{"component":"agent-router","score":0,"domains":[],"recommended_agents":[],"verification_required":false}}\n'
  fi
  exit 0
}

if ! command -v jq >/dev/null 2>&1; then
  skipped "jq unavailable"
fi

if ! echo "$INPUT" | jq -e . >/dev/null 2>&1; then
  skipped "invalid hook input"
fi

PROMPT=$(echo "$INPUT" | jq -r '
  .prompt
  // .message
  // .user_prompt
  // .userPrompt
  // .text
  // .tool_input.prompt
  // ""
' 2>/dev/null) || skipped "prompt parse failed"

if [ -z "$PROMPT" ] || [ "$PROMPT" = "null" ]; then
  skipped "empty prompt"
fi

PROMPT_LC=$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]')

contains_any() {
  local text="$1"
  shift
  local keyword
  for keyword in "$@"; do
    if printf '%s' "$text" | grep -Fq -- "$keyword"; then
      return 0
    fi
  done
  return 1
}

append_unique() {
  local value="$1"
  local current
  for current in "${VALUES_REF[@]}"; do
    if [ "$current" = "$value" ]; then
      return 0
    fi
  done
  VALUES_REF+=("$value")
}

add_domain() {
  VALUES_REF=("${DOMAINS[@]}")
  append_unique "$1"
  DOMAINS=("${VALUES_REF[@]}")
}

add_agent() {
  VALUES_REF=("${AGENTS[@]}")
  append_unique "$1"
  AGENTS=("${VALUES_REF[@]}")
}

SCORE=0
DOMAINS=()
AGENTS=()
TASK_TYPE="general"
RISK_LEVEL="low"
VERIFICATION_REQUIRED=false

DOCS_ONLY=false
if contains_any "$PROMPT_LC" "docs" "documentation" "readme" "changelog" "guide" "문서" "문서화"; then
  DOCS_ONLY=true
fi

HAS_CODE_INTENT=false
if contains_any "$PROMPT_LC" "implement" "add" "fix" "refactor" "change" "modify" "create" "build" "update" "코드" "구현" "수정" "추가" "리팩토링"; then
  HAS_CODE_INTENT=true
fi

if contains_any "$PROMPT_LC" "auth" "login" "token" "session" "jwt" "oauth" "permission" "role" "인증" "로그인" "권한" "세션" "토큰"; then
  add_domain "auth"
  add_agent "security-reviewer"
  SCORE=$((SCORE + 5))
  RISK_LEVEL="high"
fi

if contains_any "$PROMPT_LC" "database" "migration" "sql" "postgres" "supabase" "schema" "rls" "데이터베이스" "마이그레이션" "스키마" "쿼리"; then
  add_domain "db"
  add_agent "database-reviewer"
  SCORE=$((SCORE + 5))
  RISK_LEVEL="high"
fi

if contains_any "$PROMPT_LC" "docker" "kubernetes" "k8s" "terraform" "ci/cd" "deploy" "infra" "배포" "인프라" "도커" "쿠버네티스"; then
  add_domain "infra"
  add_agent "infrastructure-agent"
  SCORE=$((SCORE + 5))
  RISK_LEVEL="high"
fi

if contains_any "$PROMPT_LC" "react" "component" "hook" "frontend" "ui" "tsx" "jsx"; then
  add_domain "frontend"
  add_agent "react-agent"
  SCORE=$((SCORE + 4))
  if [ "$RISK_LEVEL" = "low" ]; then
    RISK_LEVEL="medium"
  fi
fi

if contains_any "$PROMPT_LC" "bug" "error" "failed" "exception" "traceback" "test fail" "test failure" "실패" "에러"; then
  add_domain "debug"
  add_agent "debugger"
  SCORE=$((SCORE + 4))
  TASK_TYPE="debug"
  if [ "$RISK_LEVEL" = "low" ]; then
    RISK_LEVEL="medium"
  fi
fi

if contains_any "$PROMPT_LC" "build error" "type error" "compile" "compilation" "tsc" "lint failed"; then
  add_agent "build-error-resolver"
  SCORE=$((SCORE + 3))
  TASK_TYPE="debug"
fi

if [ "$HAS_CODE_INTENT" = true ]; then
  SCORE=$((SCORE + 2))
  VERIFICATION_REQUIRED=true
  if [ "$TASK_TYPE" = "general" ]; then
    TASK_TYPE="implementation"
  fi
fi

if contains_any "$PROMPT_LC" "plan" "architecture" "design" "complex" "workflow" "orchestration" "설계" "아키텍처" "기획"; then
  SCORE=$((SCORE + 2))
  if [ "$TASK_TYPE" = "general" ]; then
    TASK_TYPE="planning"
  fi
fi

if [ "$DOCS_ONLY" = true ] \
  && [ "${#DOMAINS[@]}" -eq 0 ] \
  && ! contains_any "$PROMPT_LC" "code" "source" "implement" "fix" "refactor" "component" "api" "tsx" "jsx" "py" "go" "rs" "코드" "구현" "수정" "리팩토링"; then
  SCORE=2
  DOMAINS=()
  AGENTS=()
  TASK_TYPE="docs"
  RISK_LEVEL="low"
  VERIFICATION_REQUIRED=false
fi

if [ "$DOCS_ONLY" = false ]; then
  if [ "$SCORE" -ge 9 ]; then
    add_agent "planner"
    add_agent "code-reviewer"
    VERIFICATION_REQUIRED=true
  elif [ "$SCORE" -ge 5 ] && [ "$HAS_CODE_INTENT" = true ]; then
    add_agent "code-reviewer"
    VERIFICATION_REQUIRED=true
  fi
fi

if [ "$SCORE" -gt 12 ]; then
  SCORE=12
fi

domains_json=$(printf '%s\n' "${DOMAINS[@]}" | jq -R -s 'split("\n") | map(select(length > 0))')
agents_json=$(printf '%s\n' "${AGENTS[@]}" | jq -R -s 'split("\n") | map(select(length > 0))')
agents_reason=$(printf '%s' "$agents_json" | jq -r 'if length == 0 then "none" else join(",") end')

jq -n \
  --arg reason "[Agent Router] score=${SCORE}, agents=${agents_reason}" \
  --argjson score "$SCORE" \
  --argjson domains "$domains_json" \
  --argjson agents "$agents_json" \
  --arg task_type "$TASK_TYPE" \
  --arg risk_level "$RISK_LEVEL" \
  --argjson verification_required "$VERIFICATION_REQUIRED" \
  '{
    decision: "approve",
    reason: $reason,
    harness: {
      component: "agent-router",
      score: $score,
      task_type: $task_type,
      risk_level: $risk_level,
      domains: $domains,
      recommended_agents: $agents,
      verification_required: $verification_required
    }
  }'

exit 0
