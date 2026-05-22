# MCP Agent Access Policy

This rule maps MCP/tool access to agent roles. Use it with `rules/mcp-patterns.md` and `rules/agents.md`.

## Principle

MCP tools are external context and capability boundaries. Agents should use only the MCP tools required for their role, and only when local repo context is insufficient.

## Agent Policy

### pm-agent
- Use MCP only for product context that cannot be answered from repo files.
- Prefer read-only sources.
- Do not create external issues/pages unless explicitly requested.

### research-agent
- May use documentation, GitHub, and web-style MCP sources for evidence gathering.
- Prefer official documentation, source repositories, and versioned references.
- Must return evidence and confidence.
- Must not modify project files.

### backend-agent
- May use documentation MCP sources for libraries, frameworks, APIs, and SDKs.
- May use GitHub read operations for code examples and issue context.
- Must not use write-capable external tools unless explicitly instructed.
- Database or production-affecting MCP tools should be treated as high risk.

### react-agent
- May use documentation MCP sources for React, Next.js, UI libraries, and component APIs.
- May use browser or Playwright-related tools only for verification or visual inspection.
- Must not create product requirements.

### designer-agent
- May use web/reference sources for UX/UI references and icon/component research.
- Must treat references as evidence, not as direct copies.
- Must not modify code.

### qa-agent
- May use Playwright/browser tools for release validation.
- May use GitHub read operations for PR, issue, and workflow context.
- Must report pass/fail/blocked with evidence.

### coordinator
- Should not directly perform implementation through MCP.
- Coordinates which agent should use which MCP tool.
- Keeps MCP use scoped to the phase objective.

## Guardrails

- Prefer read-only MCP operations by default.
- Use write-capable MCP operations only when explicitly requested.
- Never pass secrets through MCP prompts or logs.
- Treat production-affecting MCP tools as high risk.
- Record evidence for MCP-derived claims.
- If tool output conflicts with repo source of truth, stop and report the conflict.
