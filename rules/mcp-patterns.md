# MCP (Model Context Protocol) Patterns

globs: ['**/.mcp.json', '**/mcp*.json', '**/mcp*.ts', '**/mcp*.py']

> Source: Claude Code 소스코드 `src/services/mcp/`, `src/tools/MCPTool/`, `src/utils/settings/types.ts` 분석 기반

## MCP 서버 설정 구조

### 3가지 설정 위치 (우선순위 순)
```
~/.claude/managed-settings.json  # 엔터프라이즈 정책 (최우선, 변경 불가)
~/.claude/settings.json          # 사용자 전역 설정 (권장)
.claude/settings.json            # 프로젝트별 설정 (프로젝트 루트)
.mcp.json                        # 프로젝트 MCP 서버 선언
```

### settings.json mcp 필드 예시
```json
{
  "mcp": {
    "servers": {
      "github": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-github"],
        "env": {
          "GITHUB_TOKEN": "${GITHUB_TOKEN}"
        }
      },
      "postgres": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-postgres"],
        "env": {
          "DATABASE_URL": "${DATABASE_URL}"
        }
      }
    }
  }
}
```

## 허용/차단 제어

```json
{
  "allowedMcpServers": ["github", "postgres"],
  "deniedMcpServers": ["*-unsafe"],
  "enabledMcpjsonServers": ["trusted-server"],
  "disabledMcpjsonServers": ["experimental-server"]
}
```

## MCP 도구 호출 패턴

MCP 도구는 `mcp__<server>__<tool>` 형식으로 호출됩니다:
```
mcp__github__create_issue
mcp__github__get_pull_request
mcp__memory__search_nodes
```

permissions allow/deny에서도 동일 패턴 적용:
```json
{
  "permissions": {
    "allow": ["mcp__github__*"],
    "deny": ["mcp__github__delete_*"]
  }
}
```

## .mcp.json 프로젝트 선언 형식

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["./mcp-server/index.js"],
      "env": {
        "API_KEY": "${MY_API_KEY}"
      },
      "timeout": 30
    }
  }
}
```

## HTTP 훅과 MCP 연동

MCP 서버를 HTTP 훅으로 감시하거나, 훅에서 MCP 서버 API 호출 가능:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "mcp__github__*",
      "hooks": [{
        "type": "http",
        "url": "https://your-audit-endpoint.com/webhook",
        "headers": { "Authorization": "Bearer ${AUDIT_TOKEN}" },
        "allowedEnvVars": ["AUDIT_TOKEN"]
      }]
    }]
  }
}
```

## 보안 원칙

- **최소 권한**: MCP 서버에 필요한 도구만 허용
- **환경변수 주입**: 하드코딩된 토큰 금지, `${ENV_VAR}` 형식 사용
- **서버 격리**: 신뢰할 수 없는 MCP 서버는 `deniedMcpServers`에 명시
- **감사 로그**: PostToolUse 훅으로 MCP 도구 호출 추적
- **`allowedHttpHookUrls`**: HTTP 훅 URL을 allowlist로 제한

## MCP 스킬 패턴 (skills 폴더)

MCP 서버가 제공하는 프롬프트는 `/skill-name` 형식 슬래시 커맨드로 등록됩니다.
MCP 스킬은 보안상 인라인 셸 커맨드 실행이 금지됩니다 (`src/skills/loadSkillsDir.ts`).

## 현재 PC 설정된 MCP 서버

- `mcp__github__*` — GitHub API 연동 (이슈, PR, 코드 검색)
- `mcp__memory__*` — 지식 그래프 기반 메모리
- `mcp__claude_ai_Gmail__*` — Gmail 연동
- `mcp__claude_ai_Google_Calendar__*` — Google Calendar 연동

## 참고 자료

- [MCP 공식 스펙](https://modelcontextprotocol.io/)
- `src/services/mcp/` — MCP 서버 로딩 로직
- `src/tools/MCPTool/` — MCP 도구 실행 구현
