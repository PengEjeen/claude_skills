# My Claude Code Settings

Claude Code CLI를 위한 종합 하네스 엔지니어링 저장소.
**36개 스킬, 24개 에이전트, 31개 커맨드, 13개 규칙, 29개 훅 스크립트**를 포함합니다.

> **최신 업데이트: 2026-04-02** — 하네스 v7: 29개 훅 (11-Event), CLAUDE.md 최적화 (51→24 lines), 4개 신규 이벤트 훅 (MainAgentTokenDepletion, WorktreeCreate, SubagentStart, PermissionDenied), Reasoning Budget 정정 (xhigh→high)

> **처음이신가요?** → [GUIDE.md](GUIDE.md)를 먼저 읽어보세요 (15분 입문 가이드)

---

## 하네스 엔지니어링 (2026)

> 모델을 바꾸지 않고 하네스(모델을 감싸는 시스템)만 개선해 성능을 올리는 방법론.
> LangChain: 동일 모델로 Terminal Bench 2.0에서 52.8% → 66.5% (+13.7점, Top 30 → Top 5).

이 저장소는 Claude Code의 훅 시스템으로 **2026 SOTA 하네스 패턴**을 구현합니다:

```
Session Start
  → EnvironmentBootstrap       (env-context-injector.sh)
  → ProgressRehydration        (progress-loader.sh)
  → RegressionGate             (regression-gate.sh)

Agent Request
  → LocalContextMiddleware     (env-context-injector.sh)
  → Safety Guard               (dangerous-command-blocker.sh + secret-detector.sh)
  → CommitGuard                (pre-commit-security.sh + code-quality-gate.sh + test-coverage-gate.sh)
  → [Tool Execution]
  → SupplyChainGuard           (dependency-audit.sh)
  → Quality Gate               (console-log, prettier, tsc, ruff)
  → VerificationLoop           (verification-loop.sh)          ← NEW
  → LoopDetectionMiddleware    (loop-detector.sh)
  → Observability              (observability-metrics.sh)       ← NEW
  → ExecutionTracing           (trace-logger.sh)
  → LearningIndexer            (learning-indexer.sh)            ← NEW
  → FailureAnalysis            (failure-explainer.sh)

Context Compression
  → CompactionCheckpoint       (compact-checkpoint.sh)

Lifecycle Events
  → TokenBudgetGuard           (token-depletion.sh)             ← NEW
  → WorktreeLifecycle          (worktree-setup.sh)              ← NEW
  → SubagentMonitor            (subagent-context.sh, async)     ← NEW
  → PermissionAudit            (permission-logger.sh, async)    ← NEW

Session End
  → DoD Verification           (dod-checker.sh)
  → ProgressPersistence         (progress-tracker.sh)
  → PreCompletionChecklist      (pre-completion-check.sh)
  → SessionLearning             (session-learning.sh)
```

### 2026 SOTA 패턴 구현 현황

| 패턴 | 근거 | 구현 |
|------|------|------|
| Verification Loop | Spotify Honk: 환각 34%↓, 코드 품질 28%↑ | `verification-loop.sh` |
| Observability | LangChain/OpenAI: 트레이스 분석이 개선의 핵심 | `observability-metrics.sh` |
| LoopDetection | LangChain 미들웨어 표준 | `loop-detector.sh` |
| Reasoning Budget | Terminal Bench 2.0: high(63.6%) > xhigh(53.9%) | `agents.md` |
| Tool Minimization | mini-SWE-agent: bash-only로 SWE-bench 74% | `agents.md` Tool Strategy |
| PreCompletion | Anthropic 공식 패턴 | `pre-completion-check.sh` |
| Cross-Session State | Anthropic: claude-progress.txt | `progress/SCHEMA.md` |
| Agent Teams | Anthropic: 병렬 작업 50-70% 빠름 | `settings.local.json` env 플래그 |
| Test Coverage Gate | 커밋 전 80% 강제 | `test-coverage-gate.sh` |
| .claudeignore | 토큰 5-10% 절약 | `.claudeignore` |

### 핵심 설계 원칙

- **JSON 출력 통일**: 모든 훅이 `{"decision":"approve|block","reason":"..."}` 형식
- **세션 격리**: 모든 lock/tracking 파일이 session-specific → 멀티 세션 안전
- **Bash-First**: 에이전트 도구는 bash 우선, 전용 도구는 5-10% 케이스에만
- **실측 기반**: Reasoning Budget은 Terminal Bench 2.0 벤치마크 결과에 따라 high 레벨 사용

---

## 프로젝트 구조

```
├── README.md                    ← 이 파일
├── GUIDE.md                     ← 입문자용 15분 가이드 ★
├── MCP_QUICK_SETUP.md           ← MCP 서버 설정 가이드
├── CLAUDE.md                    ← 글로벌 지침 (on-demand 규칙 라우터)
├── .claudeignore                ← 토큰 최적화 (빌드 산출물 제외)
├── settings.local.json          ← 설정 (권한, 훅 배선, Agent Teams)
├── setup.sh / setup.ps1         ← 설치 스크립트
├── uninstall.sh / uninstall.ps1 ← 제거 스크립트
│
├── hooks/ (29개)                ← 하네스 미들웨어 훅 스크립트
│   ├── 안전: dangerous-command-blocker, secret-detector, pre-commit-security
│   ├── 품질: console-log-warning, prettier, tsc, ruff, code-quality-gate
│   ├── 검증: verification-loop, test-coverage-gate, regression-gate ★
│   ├── 추적: trace-logger, observability-metrics, learning-indexer ★
│   ├── 세션: env-context-injector, progress-loader, progress-tracker
│   ├── 생명주기: token-depletion, worktree-setup, subagent-context, permission-logger ★
│   ├── 분석: failure-explainer, loop-detector, dod-checker, compact-checkpoint, session-learning
│   └── 유틸: trace-analyzer (수동 실행 전용, 훅 미배선)
│
├── rules/ (13개)                ← AI 행동 규칙
│   ├── ALWAYS: workflow.md, harness-engineering.md, defaults.md
│   ├── 에이전트: agents.md (24개 오케스트레이션 + Tool Strategy)
│   ├── 코드: coding-style.md, testing.md, security.md, git-workflow.md
│   ├── 시스템: hooks.md, context-management.md, cs-boost.md, mcp-patterns.md ★
│   └── 고급: advanced-workflows.md (Headless, Worktree, /loop, Auto Mode) ★
│
├── skills/ (36개)               ← 전문 스킬 (/skill-name으로 활성화)
├── agents/ (24개)               ← 특화 서브 에이전트
├── commands/ (31개)             ← CLI 커맨드 (/command-name)
└── progress/                    ← 세션 상태 관리
    ├── README.md
    └── SCHEMA.md                ← claude-progress.txt 스키마 ★
```

---

## 구성 요약

| 항목 | 수량 | 설명 |
|------|------|------|
| **Rules** | 13 | ALWAYS 3개 + on-demand 10개 |
| **Hooks** | 29 | 11-Event 파이프라인 (SessionStart 3, UserPromptSubmit 1, PreToolUse 5, PostToolUse 10, PostToolUseFailure 1, PostCompact 1, MainAgentTokenDepletion 1, WorktreeCreate 1, SubagentStart 1, PermissionDenied 1, Stop 4) |
| **Commands** | 31 | `/plan`, `/tdd`, `/verify`, `/tool-registry` 등 |
| **Agents** | 24 | Core 7 + Quality 10 + Domain 4 + Meta 3 |
| **Skills** | 36 | 기획, 개발, AI, 문서, 품질, QA |
| **MCP** | 3 | Context7, GitHub, Playwright |
| **Tracing** | JSONL | `~/.claude/traces/` (metrics + traces, 7일 보관) |

---

## 훅 파이프라인 (29개)

### SessionStart (3)
| 훅 | 역할 |
|----|------|
| `env-context-injector.sh` | Git/프로젝트/런타임 환경 자동 주입 |
| `progress-loader.sh` | 이전 세션 상태 로드 |
| `regression-gate.sh` | 이전 실패 테스트 회귀 검사 (24h TTL) |

### UserPromptSubmit (1)
| 훅 | 역할 |
|----|------|
| `env-context-injector.sh` | 세션 컨텍스트 재주입 fallback (SessionStart 미실행 시) |

### PreToolUse (5)
| 훅 | 매처 | 역할 |
|----|------|------|
| `dangerous-command-blocker.sh` | Bash | rm -rf, git push --force 등 차단 |
| `pre-commit-security.sh` | git commit | staged diff 시크릿 검사 |
| `code-quality-gate.sh` | git commit | merge conflict, TODO/FIXME, 대용량 변경 |
| `test-coverage-gate.sh` | git commit | **80% 미만 커버리지 차단** ★ |
| `secret-detector.sh` | Edit/Write | 14개 provider 패턴 감지 |

### PostToolUse (10)
| 훅 | 역할 |
|----|------|
| `dependency-audit.sh` | npm/pip 패키지 보안 검사 |
| `console-log-warning.sh` | console.log 경고 |
| `prettier-format.sh` | JS/TS/CSS/JSON 자동 포맷 |
| `tsc-check.sh` | TypeScript 타입 체크 |
| `ruff-format.sh` | Python lint + format |
| `loop-detector.sh` | 동일 파일 4회+ 편집 doom loop 경고 |
| `trace-logger.sh` | 도구 호출 JSONL 기록 |
| `verification-loop.sh` | **코드 변경 후 관련 테스트 자동 실행** ★ |
| `observability-metrics.sh` | **메트릭 수집 (도구 사용량, 성공률)** ★ |
| `learning-indexer.sh` | **학습 패턴 자동 인덱싱** ★ |

### PostToolUseFailure (1)
| 훅 | 역할 |
|----|------|
| `failure-explainer.sh` | 에러 분류 + WHY 3단계 + 에스컬레이션 |

### PostCompact (1)
| 훅 | 역할 |
|----|------|
| `compact-checkpoint.sh` | 압축 시 체크포인트 저장 |

### MainAgentTokenDepletion (1)
| 훅 | 역할 |
|----|------|
| `token-depletion.sh` | 토큰 고갈 임박 시 /compact·/clear 프롬프트 |

### WorktreeCreate (1)
| 훅 | 역할 |
|----|------|
| `worktree-setup.sh` | 격리 워크트리 환경 자동 설정 (Node/Python/Go/Rust) |

### SubagentStart (1)
| 훅 | 역할 |
|----|------|
| `subagent-context.sh` | 서브에이전트 스폰 카운터 추적 (async) |

### PermissionDenied (1)
| 훅 | 역할 |
|----|------|
| `permission-logger.sh` | 권한 거부 감사 JSONL 기록, 3회+ 에스컬레이션 (async) |

### Stop (4)
| 훅 | 역할 |
|----|------|
| `dod-checker.sh` | 완료 조건 검증 |
| `progress-tracker.sh` | 세션 상태 기록 |
| `pre-completion-check.sh` | 테스트 실행 여부 검증 |
| `session-learning.sh` | 학습 리마인더 |

---

## 스킬 (36개)

`/skill-name`으로 활성화.

### 제품 기획
| 스킬 | 설명 |
|------|------|
| `product-planner` | 시니어 PM 수준 제품 기획 (TAM/SAM/SOM, JTBD, RICE) |
| `chatbot-designer` | LLM Agent Architect — 대화형 AI 시스템 설계 |
| `llm-app-planner` | LLM 앱 아키텍처 빠른 참조 |
| `api-spec-generator` | API 명세서 자동 생성 |

### 개발
| 스킬 | 설명 |
|------|------|
| `architecture-design` | 시스템 설계 + ADR (Clean Architecture, DDD) |
| `backend-api` | FastAPI 구현 (라우터, 미들웨어, Pydantic) |
| `react-component` | Anti-AI Frontend Design System |
| `api-design` | RESTful/GraphQL API 설계 (OpenAPI 3.x) |
| `clean-code` | Project Guardian — 품질 관리 종합 |
| `refactoring` | 안전한 리팩토링 (동작 변경 없이 구조 개선) |
| `debugging` | 체계적 디버깅 (가설 기반, 이분 탐색, RCA) |
| `performance-optimization` | 성능 분석/최적화 |
| `database-schema` | Database Schema Design |
| `mcp-integration` | MCP 서버 설정/연동 |

### AI / 연구
| 스킬 | 설명 |
|------|------|
| `rag-2.0` | 고급 RAG (Hybrid Search, GraphRAG) |
| `ml-training` | ML 모델 학습/평가, 임베딩, 벡터 검색 |
| `agent-evaluator` | AI 에이전트 자동 테스트/평가 |
| `agentic-workflows` | 멀티 에이전트 시스템 (ReAct, Plan-Execute) |
| `ai-developer-practice` | AI 개발자 실무 7대 역량 |
| `ai-research-integration` | 논문 조사/평가/POC |
| `research-agent-tech` | LLM/Agent 최신 트렌드 |
| `prompt-optimizer` | 프롬프트 엔지니어링 최적화 |

### 문서 / 품질
| 스킬 | 설명 |
|------|------|
| `code-review` | 5-Layer 코드 리뷰 |
| `security-audit` | OWASP Top 10 보안 감사 |
| `tdd-workflow` | TDD 워크플로우 (Red-Green-Refactor) |
| `documentation-gen` | 기술 문서 자동 생성 |
| `dev-journal` | 개발 일지 자동화 |
| `dev-blog-writer` | 기술 블로그 작성 |
| `frontend-codemap` | 프론트엔드 코드맵 |
| `context-compressor` | 컨텍스트 압축으로 토큰 최적화 |
| `git-workflow` | 고급 Git (Conventional Commits, 자동 PR) |
| `developer-growth` | 개발자 성장 프레임워크 |
| `learning-journal` | 학습 일지 자동 생성 |
| `portfolio-generator` | 포트폴리오 문서 자동 생성 |
| `mobile-tablet-redesign` | 모바일/태블릿 UX 리디자인 |

### QA / 테스트
| 스킬 | 설명 |
|------|------|
| `industry-persona-qa` | **산업별 다중 페르소나 QA** ★ (12개 산업, 5-8 페르소나/산업) |

---

## 에이전트 (24개)

자동으로 트리거되는 특화 서브 에이전트 (4개 카테고리):

### Core (7) — 필수 자동 트리거
| 에이전트 | 모델 | 트리거 |
|----------|------|--------|
| planner | Opus | 기능 요청 시 (mandatory) |
| code-reviewer | Sonnet | 코드 작성 후 (mandatory) |
| tdd-guide | Sonnet | 새 기능, 버그 수정 |
| security-reviewer | Sonnet | 인증/API/입력 처리 |
| build-error-resolver | Sonnet | 빌드 실패 |
| debugger | Sonnet | 런타임 에러 |
| architect | Opus | 아키텍처 변경 |

### Quality & Review (10) — 도메인별 리뷰
`a11y-reviewer`, `database-reviewer`, `python-reviewer`, `go-reviewer`, `go-build-resolver`, `graphql-expert`, `rust-expert`, `refactor-cleaner`, `performance-optimizer`, `doc-updater`

### Domain-Specific (4) — 전문 도메인
`react-agent`, `e2e-runner`, `infrastructure-agent`, `vector-db-agent`

### Meta & Orchestration (3) — 메타 추론
`coordinator`, `critic-agent`, `tree-of-thoughts`

---

## 커맨드 (31개)

| 카테고리 | 커맨드 |
|----------|--------|
| **핵심** | `/plan` `/tdd` `/code-review` `/build-fix` `/verify` `/checkpoint` `/define-dod` `/handoff` |
| **검색** | `/tool-registry` ★ — 92개 도구 카테고리별 검색 |
| **프론트엔드** | `/modern-frontend` `/frontend-codemap` `/update-codemaps` `/e2e` |
| **문서/분석** | `/update-docs` `/token-analysis` `/test-coverage` `/eval` `/learn` |
| **멀티에이전트** | `/multi-agent` `/orchestrate` `/evolve` |
| **리팩토링** | `/refactor-clean` `/skill-create` `/setup-pm` |
| **Go/Rust** | `/go-build` `/go-review` `/go-test` `/rust` |
| **학습** | `/instinct-export` `/instinct-import` `/instinct-status` |

---

## 고급 기능 (2026.03)

| 기능 | 설명 | 사용법 |
|------|------|--------|
| **Agent Teams** | 병렬 에이전트 팀 (50-70% 빠름) | `settings.json` env 플래그 활성화 |
| **Headless Mode** | CI/CD 자동 실행 | `claude -p "리뷰해줘" --output-format json` |
| **Worktree** | 격리된 병렬 개발 | `claude -w feature-name` |
| **/loop** | cron-like 반복 작업 | `/loop 5m "PR 상태 확인"` |
| **Auto Mode** | AI 안전 분류기 자동 승인 | permission mode: auto (샌드박스만) |

→ 자세한 내용은 `rules/advanced-workflows.md` 참조

---

## 설치

### 자동 설치

**Windows (PowerShell):**
```powershell
git clone https://github.com/hyunseung1119/My_ClaudeCode_Skill.git
cd My_ClaudeCode_Skill
.\setup.ps1
```

**Linux / macOS:**
```bash
git clone https://github.com/hyunseung1119/My_ClaudeCode_Skill.git
cd My_ClaudeCode_Skill
chmod +x setup.sh && ./setup.sh
```

### 업데이트

```bash
cd My_ClaudeCode_Skill
git pull
./setup.sh  # 또는 .\setup.ps1
```

### 제거

```bash
./uninstall.sh     # Linux/macOS
.\uninstall.ps1    # Windows
```

---

## 문서 목록

| 문서 | 대상 | 내용 |
|------|------|------|
| [README.md](README.md) | 전체 | 프로젝트 개요 (이 파일) |
| [GUIDE.md](GUIDE.md) | **입문자** | 15분 설치~활용 가이드 ★ |
| [MCP_QUICK_SETUP.md](MCP_QUICK_SETUP.md) | 중급 | MCP 서버 설정 (Context7, GitHub, Playwright) |
| [CLAUDE.md](CLAUDE.md) | Claude | 글로벌 지침 라우터 |
| [progress/SCHEMA.md](progress/SCHEMA.md) | 고급 | claude-progress.txt 스키마 |

---

## 업데이트 이력

| 날짜 | 내용 |
|------|------|
| **2026-04-02** | **하네스 v7** — CLAUDE.md 최적화 (51→24줄), 4개 신규 이벤트 훅 (MainAgentTokenDepletion, WorktreeCreate, SubagentStart, PermissionDenied), 수치 전면 정정 (실제 파일 기준), docs-site 배포 업데이트 |
| **2026-03-26** | **하네스 v6** — Verification Loop(Spotify Honk 패턴), Observability 메트릭, Test Coverage Gate(80% 강제), Learning Indexer, Agent Teams 활성화, Tool Strategy(Bash-First), Reasoning Budget 실측 반영(high>xhigh), industry-persona-qa 스킬, tool-registry 커맨드, .claudeignore, advanced-workflows(Headless/Worktree/Loop/Auto Mode), MCP 가이드, 입문자 GUIDE.md |
| 2026-03-24 | 하네스 v5 — 훅 계약 통일, regression gate, python-reviewer, secret 14패턴 |
| 2026-03-22 | dependency-audit, trace-analyzer 추가, 튜토리얼 가이드 |
| 2026-03-13 | 하네스 v4 — 12개 훅, JSON 출력 통일, 세션 격리 |
| 2026-03-12 | 하네스 엔지니어링 적용 (9개 훅) |
| 2026-03-11 | Harness v3, Vercel React, Office 스킬 |
| 2026-03-04 | CLAUDE.md 경량화, Learning Mode |
| 2026-02-02 | 29개 스킬 전체 동기화 |

---

## 참고 자료

- [LangChain: Improving Deep Agents with Harness Engineering](https://blog.langchain.com/improving-deep-agents-with-harness-engineering/)
- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Anthropic: Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps)
- [OpenAI: Harness Engineering](https://openai.com/index/harness-engineering/)
- [Spotify: Background Coding Agents — Feedback Loops](https://engineering.atspotify.com/2025/12/feedback-loops-background-coding-agents-part-3/)
- [Phil Schmid: Agent Harness 2026](https://www.philschmid.de/agent-harness-2026)
- [FeatureBench: Agentic Coding Benchmark](https://arxiv.org/abs/2602.10975)
- [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)

---

## Author

**hyunseung1119** — [@hyunseung1119](https://github.com/hyunseung1119)

MIT License
