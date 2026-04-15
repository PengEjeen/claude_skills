# MCP Quick Setup (2026)

> Context7 (1위), GitHub (3위), Playwright (2위) -- FastMCP 실사용 데이터 기준

## 현재 상태

세 서버 모두 이미 설치 및 활성화됨 (확인일: 2026-03-26).

| 서버 | 상태 | 설정 위치 |
|------|------|----------|
| Context7 | 활성 | `~/.claude/plugins/.../external_plugins/context7/.mcp.json` |
| GitHub | 활성 | `~/.claude/plugins/.../external_plugins/github/.mcp.json` |
| Playwright | 활성 | `~/.claude/plugins/.../external_plugins/playwright/.mcp.json` |

## 1. Context7 -- 라이브러리 문서 주입 (필수)

가장 인기 있는 MCP 서버 (11,000 views, 690 installs). 라이브러리 버전별 공식 문서를 컨텍스트에 직접 주입.

### 설치

```bash
# Claude Code에서 직접 추가
claude mcp add context7 -- npx -y @upstash/context7-mcp
```

### 현재 설정

```json
{
  "context7": {
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp"]
  }
}
```

### 사용법
- 자동으로 활성화됨
- 코드 작성 시 라이브러리 문서가 자동으로 참조됨
- `resolve-library-id` -> `query-docs` 순서로 호출
- 버전별 정확한 API 문서 제공

## 2. GitHub -- PR/이슈 관리

### 설치

```bash
claude mcp add github -- npx -y @anthropic-ai/claude-code-mcp-server github
```

### 현재 설정

```json
{
  "github": {
    "type": "http",
    "url": "https://api.githubcopilot.com/mcp/",
    "headers": {
      "Authorization": "Bearer ${GITHUB_PERSONAL_ACCESS_TOKEN}"
    }
  }
}
```

### 사용법
- PR 생성, 리뷰, 이슈 관리
- 코드 검색, 파일 내용 조회
- 워크플로우 상태 확인

## 3. Playwright -- 브라우저 자동화

### 설치

```bash
claude mcp add playwright -- npx @playwright/mcp@latest
```

### 현재 설정

```json
{
  "playwright": {
    "command": "npx",
    "args": ["@playwright/mcp@latest"]
  }
}
```

### 사용법
- E2E 테스트 실행
- 스크린샷 캡처
- 브라우저 자동화

## 현재 활성 MCP 서버 확인

```bash
claude mcp list
```

## 참고
- MCP 서버는 Linux Foundation에 기증됨 (2025.12)
- OpenAI, Google DeepMind도 MCP 채택
- 97M+ 월간 다운로드 (Python + TypeScript SDK)
