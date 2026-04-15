# Hooks System

globs: ['**/.claude/hooks/**', '**/settings*.json', '**/CLAUDE.md']

## Hook Types (전체 이벤트 목록)

> Source: `src/types/hooks.ts` (agentSdkTypes.ts) — 2026년 기준 전체 이벤트

| 이벤트 | 발생 시점 | 용도 |
|--------|----------|------|
| **SessionStart** | 세션 시작 시 | 환경 부트스트랩, 프로그레스 로드, 회귀 게이트 |
| **UserPromptSubmit** | 사용자 메시지 처리 전 | 환경 컨텍스트 주입 (fallback) |
| **PreToolUse** | 도구 실행 직전 | 검증, 파라미터 수정, 차단 |
| **PostToolUse** | 도구 실행 완료 후 | 포맷, 타입체크, 경고, 루프 감지, 트레이싱 |
| **PostToolUseFailure** | 도구 실행 실패 후 | 근본원인 분석, 실패 추적 |
| **PostCompact** | 컨텍스트 압축 후 | 체크포인트 저장 |
| **Stop** | 세션 종료 시 | DoD 검증, 프로그레스 추적, 학습 요약 |
| **MainAgentTokenDepletion** | 토큰 부족 감지 시 | compact/clear 권장 알림 |
| **WorktreeCreate** | git worktree 생성 시 | 환경 자동 설정 |
| **SubagentStart** | 서브에이전트 spawn 시 | 호출 추적, 과다 경고 |
| **PermissionDenied** | 권한 거부 시 | 감사 로그 기록 |
| **PermissionRequest** | 권한 요청 시 | 권한 게이트 |
| **FileChanged** | 파일 변경 감지 | 파일 변경 반응 |
| **CwdChanged** | 작업 디렉토리 변경 | 컨텍스트 갱신 |

## Execution Model

같은 이벤트의 훅들은 **순서대로 실행** (sequential). 각 훅은 동일한 input을 받고 JSON으로 행동을 제어합니다.

| Output Format | When Used | Effect |
|---------------|-----------|--------|
| `{"decision":"block","reason":"..."}` | PreToolUse, Stop | 액션 차단 |
| `{"decision":"approve","reason":"..."}` | Any event | 승인 + 컨텍스트 주입 |
| `{"hookSpecificOutput":{...}}` | UserPromptSubmit only | 대화에 컨텍스트 주입 |
| Plain text stdout | SessionStart only | 컨텍스트에 직접 주입 |
| No output (exit 0) | Any event | 조용한 통과 |

**Important:** 같은 체인에서 하나라도 `"decision":"block"` 출력하면 다른 훅과 무관하게 차단됨.

## Hook 고급 기능 (2026)

| 필드 | 용도 | 예시 |
|------|------|------|
| `statusMessage` | 스피너에 표시할 커스텀 메시지 | `"statusMessage": "타입 검사 중..."` |
| `async: true` | 비차단 백그라운드 실행 | trace-logger, session-learning |
| `if` | 권한 룰 문법으로 조건 필터링 | `"if": "Bash(git *)"` |
| `once` | 1회 실행 후 자동 제거 | 일회성 설정 훅 |
| `timeout` | 훅별 타임아웃 (초) | `"timeout": 30` |

## Hook Types (명령 종류)

| 타입 | 용도 |
|------|------|
| `command` | 셸 커맨드 실행 (현재 사용) |
| `prompt` | LLM 프롬프트로 검증 |
| `http` | HTTP POST 웹훅 |
| `agent` | 에이전트형 검증 |

## Provided Hook Scripts — 29 total

### SessionStart (3)
| Script | Purpose |
|--------|---------|
| `env-context-injector.sh` | Git/프로젝트/런타임 환경 정보 자동 주입 (1회, session-specific lock) |
| `progress-loader.sh` | 이전 세션의 claude-progress.txt 상태 로드 (경과 시간 표시) |
| `regression-gate.sh` | 이전 세션 실패 테스트 회귀 검사 (smoke test, 24h TTL) |

### UserPromptSubmit (1)
| Script | Matcher | Purpose |
|--------|---------|---------|
| `env-context-injector.sh` | (all) | 세션 컨텍스트 재주입 fallback (SessionStart 미실행 시 보장) |

### PreToolUse (5)
| Script | Matcher | Purpose |
|--------|---------|---------|
| `dangerous-command-blocker.sh` | Bash | `rm -rf`, `git push --force`, `git reset --hard`, `git clean -f`, `DROP TABLE` 차단 (2s) |
| `pre-commit-security.sh` | Bash(git commit*) | 커밋 전 staged diff에서 시크릿/credential 검사 |
| `code-quality-gate.sh` | Bash(git commit*) | 커밋 전 merge conflict marker, TODO/FIXME, 디버그 로그, 대용량 변경 검사 |
| `test-coverage-gate.sh` | Bash(git commit*) | 커밋 전 테스트 커버리지 80% 미만 시 차단 (Python/Node/Go, 10분 캐시) |
| `secret-detector.sh` | Edit\|Write | 14개 provider 패턴 감지 (AWS, OpenAI, Anthropic, Slack, GitHub 등) (2s) |

### PostToolUse — Bash (3)
| Script | Purpose | Async |
|--------|---------|-------|
| `dependency-audit.sh` | npm/pip/cargo/go 패키지 설치 시 URL 설치, 위험 플래그, typosquatting 검사 | sync |
| `trace-logger.sh` | 모든 도구 호출 → `~/.claude/traces/` JSONL (daily cleanup lock) | **async** |
| `learning-indexer.sh` | `/learn` 실행 후 학습 패턴 자동 인덱싱 → 크로스세션 검색 지원 | **async** |

### PostToolUse — Edit\|Write (8)
| Script | Purpose | Order | Async |
|--------|---------|-------|-------|
| `console-log-warning.sh` | JS/TS console.log/debug/warn/error/trace 경고 | 1st | sync (2s) |
| `prettier-format.sh` | JS/TS/CSS/JSON Prettier 자동 포맷 | 2nd | sync |
| `ruff-format.sh` | Python ruff check --fix + format | 3rd | sync |
| `tsc-check.sh` | TypeScript 증분 타입 체크 | 4th | **async** |
| `loop-detector.sh` | 같은 파일 4회+ 편집 시 doom loop 경고 | 5th | sync (2s) |
| `trace-logger.sh` | 도구 호출 JSONL 기록 | 6th | **async** |
| `verification-loop.sh` | 코드 변경 후 관련 테스트 자동 실행 → 실패 시 피드백 주입 (Spotify Honk 패턴) | 7th | sync |
| `observability-metrics.sh` | 메트릭 수집 → `~/.claude/traces/metrics.jsonl` (5MB 로테이션) | 8th | **async** |

### PostToolUseFailure (1)
| Script | Matcher | Purpose |
|--------|---------|---------|
| `failure-explainer.sh` | Bash | 에러 분류 + WHY 3단계 추적 + 반복 실패 에스컬레이션 (3회+) |

### PostCompact (1)
| Script | Purpose |
|--------|---------|
| `compact-checkpoint.sh` | 컨텍스트 압축 시 progress 파일에 체크포인트 추가 |

### MainAgentTokenDepletion (1)
| Script | Purpose |
|--------|---------|
| `token-depletion.sh` | 토큰 부족 감지 시 /compact·/clear 권장 + JSONL 로그 기록 |

### WorktreeCreate (1)
| Script | Purpose |
|--------|---------|
| `worktree-setup.sh` | worktree 생성 시 Node/Python/Go/Rust 프로젝트 자동 감지 + 환경 설정 |

### SubagentStart (1)
| Script | Purpose | Async |
|--------|---------|-------|
| `subagent-context.sh` | 서브에이전트 시작 횟수 추적, 10회+ 과다 경고 | **async** |

### PermissionDenied (1)
| Script | Purpose | Async |
|--------|---------|-------|
| `permission-logger.sh` | 권한 거부 감사 로그, 3회+ 반복 에스컬레이션 | **async** |

### Stop (4)
| Script | Purpose | Async |
|--------|---------|-------|
| `dod-checker.sh` | 미커밋 변경, .env 추적 여부 등 완료 조건 검증 | sync |
| `progress-tracker.sh` | git + 언어별 요약 + DoD + 테스트 결과 → claude-progress.txt | **async** |
| `pre-completion-check.sh` | 코드 변경 감지 시 테스트 실행 여부 검증 | sync |
| `session-learning.sh` | 세션 학습 요약 리마인더 | **async** |

## Harness Engineering 매핑 (2026)

```
Session Start
  → EnvironmentBootstrap       (env-context-injector.sh — SessionStart)
  → ProgressRehydration        (progress-loader.sh — SessionStart)
  → RegressionGate             (regression-gate.sh — SessionStart)

Agent Request
  → LocalContextMiddleware     (env-context-injector.sh — UserPromptSubmit, fallback)
  → Safety Guard              (dangerous-command-blocker.sh — PreToolUse/Bash)
  → CommitGuard               (pre-commit-security + code-quality-gate + test-coverage-gate — PreToolUse/commit)
  → SecretGuard               (secret-detector.sh — PreToolUse/Edit|Write)
  → [Tool Execution]
  → SupplyChainGuard          (dependency-audit.sh — PostToolUse/Bash)
  → Quality Gate              (console-log + prettier + ruff + tsc(async) — PostToolUse/Edit|Write)
  → LoopDetectionMiddleware    (loop-detector.sh — PostToolUse)
  → ExecutionTracing           (trace-logger.sh — PostToolUse, ASYNC)
  → VerificationLoop          (verification-loop.sh — PostToolUse/Edit|Write)
  → ObservabilityMetrics      (observability-metrics.sh — PostToolUse, ASYNC)
  → LearningIndexer           (learning-indexer.sh — PostToolUse/Bash, ASYNC)
  → FailureAnalysis           (failure-explainer.sh — PostToolUseFailure)
  → CompactCheckpoint         (compact-checkpoint.sh — PostCompact)
  → TokenBudgetGuard          (token-depletion.sh — MainAgentTokenDepletion)
  → WorktreeLifecycle         (worktree-setup.sh — WorktreeCreate)
  → SubagentMonitor           (subagent-context.sh — SubagentStart, ASYNC)
  → PermissionAudit           (permission-logger.sh — PermissionDenied, ASYNC)
  → DoDChecker                (dod-checker.sh — Stop)
  → ProgressTracker           (progress-tracker.sh — Stop, ASYNC)
  → PreCompletionChecklist     (pre-completion-check.sh — Stop)
  → SessionLearning           (session-learning.sh — Stop, ASYNC)
Agent Response
```

## Trace Logs 위치

```
~/.claude/traces/
  YYYY-MM-DD.jsonl         # 일별 도구 호출 로그 (7일 보관, daily cleanup lock)
  metrics.jsonl            # 성능 메트릭 (5MB 로테이션)
  token-events.jsonl       # 토큰 부족 이벤트 로그
  worktree-log.jsonl       # 워크트리 생성 로그
  subagent-log.jsonl       # 서브에이전트 시작 로그
  permission-denied.jsonl  # 권한 거부 감사 로그
```

## Session Isolation

모든 lock/counter 파일은 session-specific (`CLAUDE_SESSION_ID` 또는 `$$` 기반):
- 멀티 세션 동시 실행 시 각 세션이 독립적으로 동작
- `env-context-injector`: 세션당 1회만 주입
- `loop-detector`, `subagent-context`, `permission-logger`: 세션별 카운트 독립 추적
- `pre-completion-check`, `session-learning`: 세션별 lock
- `trace-logger` cleanup: 일별 1회 max (lock-based)

## 설정 파일

실제 훅 설정은 `~/.claude/settings.json` (활성) 및 `settings.local.json` (git 동기화)을 참조하세요.
settings.json이 source of truth — 이 문서와 다를 경우 settings.json 우선.

## Auto-Accept Permissions

Use with caution:
- Enable for trusted, well-defined plans
- Disable for exploratory work
- Never use dangerously-skip-permissions flag
- Configure `allowedTools` in settings instead
