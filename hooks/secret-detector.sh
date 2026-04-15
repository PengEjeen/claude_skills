#!/bin/bash
# shellcheck shell=bash
# PreToolUse: Block writing secrets/API keys into code
# Matches Edit and Write tools — checks content for hardcoded credentials

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Allow .env.example files
if echo "$FILE_PATH" | grep -qE '\.env\.example$'; then
  exit 0
fi

# Block writing to secret files (.env, .pem, .key)
if echo "$FILE_PATH" | grep -qE '\.(env|pem|key)$'; then
  jq -n --arg fp "$FILE_PATH" '{
    decision: "block",
    reason: ("[SECURITY] Writing to secret file (" + $fp + "). Use .env.example for templates.")
  }'
  exit 0
fi

# Check content for hardcoded secrets
if [ "$TOOL_NAME" = "Edit" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty')
else
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
fi

if [ -z "$CONTENT" ]; then
  exit 0
fi

# Detect common secret patterns (2026-03 updated — 14 providers)
if echo "$CONTENT" | grep -qEi '(api[_-]?key\s*=\s*["\x27][A-Za-z0-9]{16,}|api[_-]?secret\s*=|aws_access_key_id\s*=\s*["\x27]AK|aws_secret_access_key|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|AKIA[0-9A-Z]{16}|-----BEGIN\s+(RSA|EC|DSA)?\s*PRIVATE\s+KEY|sk-ant-[a-zA-Z0-9]{20,}|xox[bprs]-[a-zA-Z0-9\-]{10,}|gho_[a-zA-Z0-9]{36}|glpat-[a-zA-Z0-9\-]{20}|AIza[a-zA-Z0-9_\-]{35}|whsec_[a-zA-Z0-9]{20,}|shpat_[a-zA-Z0-9]{32}|SG\.[a-zA-Z0-9_\-]{22}\.[a-zA-Z0-9_\-]{43})'; then
  jq -n '{
    decision: "block",
    reason: "[SECURITY] Potential secret/API key detected in code. Use environment variables instead.\nDetected pattern matches: AWS, OpenAI, Anthropic, Slack, GitHub, GitLab, Google, Stripe, Shopify, or SendGrid key."
  }'
  exit 0
fi

exit 0
