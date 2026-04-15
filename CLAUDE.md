# Global Claude Code Instructions

이 파일은 모든 프로젝트에서 적용되는 전역 지침입니다.

## ALWAYS (모든 작업)

- **workflow.md**: Explain→Approve→Execute→Reflect, Evidence Rule, Learning Mode, `/clear` 전 `/learn` 필수
- **cs-boost.md**: 코드변경 `📌변경` 요약, 에러 `🔍분해` (수정 전 필수), 커밋 전 `🔐보안체크`
- **harness-engineering.md**: 20단계 미들웨어 파이프라인, ReasoningSandwich (Opus→Sonnet→Haiku)
- **agents.md**: 새기능→planner(필수), 코드수정→code-reviewer(필수), 인증/API→security-reviewer(병렬)

## 상황별 규칙 (on-demand)

| 상황 | 규칙 |
|------|------|
| 코드 작성/리뷰 | `coding-style.md`, `testing.md` |
| API/인증/입력처리 | `security.md` |
| 에이전트 디스패치 | `agents.md` |
| Git/PR | `git-workflow.md` |
| 세션/컨텍스트 | `context-management.md` |
| 훅 설정 변경 | `hooks.md` |
| MCP 서버 연동 | `mcp-patterns.md` |
| 고급 워크플로우 | `advanced-workflows.md` |
| 도구 찾기 | `/tool-registry` |
