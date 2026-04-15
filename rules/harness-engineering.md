# Harness Engineering (2026)

globs: ['**/.claude/**', '**/hooks/**', '**/CLAUDE.md', '**/settings*.json']

> 모델을 바꾸지 않고 하네스(모델을 감싸는 시스템)만 개선해 성능을 올리는 방법론.
> LangChain: 동일 모델로 Terminal Bench 2.0에서 52.8% → 66.5% (+13.7점, Top 30 → Top 5).
> 출처: https://blog.langchain.com/improving-deep-agents-with-harness-engineering/

## 하네스 최적화 3축

하네스를 바꿀 수 있는 지점은 세 가지로 압축된다:
1. **System Prompt** — 행동 규칙, 문제 해결 절차, 환경 제약
2. **Tools** — 에이전트가 사용할 수 있는 도구 선택과 구성
3. **Middleware** — 모델 호출과 도구 호출을 감싸는 훅

## 미들웨어 파이프라인 (현재 구현 — v5)

```
Session Start
  → EnvironmentBootstrap       [env-context-injector.sh — SessionStart]        ✅
  → ProgressRehydration        [progress-loader.sh — SessionStart]              ✅
  → RegressionGate             [regression-gate.sh — SessionStart]              ✅

Agent Request
  → LocalContextMiddleware     [env-context-injector.sh — UserPromptSubmit]     ✅
  → Safety Guard              [dangerous-command-blocker.sh — PreToolUse/Bash]  ✅
  → CommitGuard               [pre-commit-security + code-quality-gate + test-coverage-gate] ✅
  → SecretGuard               [secret-detector.sh — PreToolUse/Edit|Write]      ✅
  → [Tool Execution]
  → SupplyChainGuard          [dependency-audit.sh — PostToolUse/Bash]          ✅
  → Quality Gate              [console-log + prettier + ruff — PostToolUse]     ✅
  → TypeCheck (async)         [tsc-check.sh — PostToolUse, async]               ✅
  → LoopDetectionMiddleware    [loop-detector.sh — PostToolUse]                 ✅
  → VerificationLoop          [verification-loop.sh — PostToolUse/Edit|Write]   ✅
  → ExecutionTracing (async)   [trace-logger.sh — PostToolUse, async]           ✅
  → ObservabilityMetrics      [observability-metrics.sh — PostToolUse, async]   ✅
  → LearningIndexer (async)   [learning-indexer.sh — PostToolUse/Bash, async]   ✅
  → FailureAnalysis           [failure-explainer.sh — PostToolUseFailure]       ✅
  → CompactCheckpoint         [compact-checkpoint.sh — PostCompact]             ✅
  → TokenBudgetGuard          [token-depletion.sh — MainAgentTokenDepletion]    ✅
  → WorktreeLifecycle         [worktree-setup.sh — WorktreeCreate]              ✅
  → SubagentMonitor (async)   [subagent-context.sh — SubagentStart]             ✅
  → PermissionAudit (async)   [permission-logger.sh — PermissionDenied]         ✅
  → DoDChecker                [dod-checker.sh — Stop]                           ✅
  → ProgressTracker (async)   [progress-tracker.sh — Stop]                     ✅
  → PreCompletionChecklist     [pre-completion-check.sh — Stop]                 ✅
  → SessionLearning (async)   [session-learning.sh — Stop]                     ✅
Agent Response
```

**구현 상태**: 20/20 미들웨어 구현 완료 ✅

## 4대 핵심 패턴

### 1. PreCompletionChecklist — 자기 검증 강제

가장 흔한 실패: 에이전트가 코드를 작성하고, 자기 코드를 읽고, "괜찮아 보이네"라고 멈춤.

**해결**: 문제 해결을 4단계로 강제한다.

| 단계 | 행동 | 검증 기준 | 구현체 |
|------|------|----------|--------|
| Plan & Discovery | 태스크 읽기, 코드베이스 탐색, 계획 수립 | 검증 기준 명시 | planner agent |
| Build | 구현 + 엣지케이스 고려 | 행복 경로 + 실패 경로 | Sonnet + hooks |
| Verify | **테스트 실행** + 결과 대조 | 실제 실행 결과 | verification-loop.sh + pre-completion-check.sh |
| Fix | 에러 분석 및 수정 | 재검증 통과 | failure-explainer.sh + loop-detector.sh |

### 2. LocalContextMiddleware — 환경 맥락 주입

에이전트가 자신의 환경을 스스로 파악하려 할 때 오류가 잦다.

**해결**: 세션 시작 시 자동으로 주입:
- Git 상태 (브랜치, 최근 커밋, 변경 파일)
- 언어/런타임 버전 (python, node, go, rust)
- 프로젝트 설정 파일 (package.json, pyproject.toml, go.mod, Cargo.toml)
- 이전 세션 progress (claude-progress.txt)

**Claude Code 구현**: `env-context-injector.sh` (SessionStart + UserPromptSubmit fallback), `progress-loader.sh`

### 3. LoopDetectionMiddleware — 반복 루프 탐지

같은 파일을 N번 이상 편집하면서 같은 에러를 반복하는 "doom loop" 방지.

**해결**: 파일별 편집 횟수 추적 → 임계치 초과 시 재고 프롬프트 주입.

**Claude Code 구현**: `loop-detector.sh` (PostToolUse, 4회+ 경고), `failure-explainer.sh` (PostToolUseFailure, 3회 반복 에스컬레이션)

### 4. Reasoning Sandwich — 추론 예산 배분

추론을 균일하게 쓰면 비효율적이다. 계획과 검증에 집중 투자한다.

> **실측 근거 (Terminal Bench 2.0)**: high(63.6%) > xhigh(53.9%)
> xhigh는 과도한 내부 토큰(50,000+)으로 타임아웃 발생. Planning도 high가 최적.

| 단계 | 추론 수준 | Claude Code 매핑 | 실측 근거 |
|------|----------|-----------------|----------|
| Planning | **high** | Opus — planner/architect 에이전트 | Terminal Bench 63.6% |
| Implementation | **high** | Sonnet — 메인 개발, code-reviewer | — |
| Verification | **high** | Sonnet — 테스트 실행 및 결과 대조 | — |
| Simple edits | **low** | Haiku — 포맷팅, 단순 편집 | — |

## 하네스 설계 원칙

### DO
- 단순하게 시작한다. 견고한 원자적 도구를 제공한다
- 모델이 계획을 세우게 한다 (하네스가 계획하지 않는다)
- 가드레일, 재시도, 검증을 구현한다
- **Rippable하게 만든다** — 모델이 똑똑해지면 제거할 수 있는 로직만 넣는다
- async 훅은 advisory 성격 (결과를 기다리지 않음)
- blocking 훅은 결정적 역할만 (block/approve)

### DON'T
- 거대한 제어 흐름을 만들지 않는다
- 하드코딩된 파이프라인을 만들지 않는다 (모델 버전마다 최적 구조가 다르다)
- 벤치마크 점수만 보지 않는다 (50~100번 도구 호출 후 행동을 평가한다)
- xhigh 추론을 기본으로 쓰지 않는다 (타임아웃 위험)

## 트레이스 기반 개선 루프

성능 개선은 한 번에 끝나지 않는다. 머신러닝의 부스팅처럼 **이전 실패에 집중**해 반복 개선한다:

```
하네스 변경 → 벤치마크 실행 → 트레이스 분석 → 실패 패턴 식별 → 하네스 변경 (반복)
```

- 매 실험마다 에이전트 트레이스를 저장 → `~/.claude/traces/YYYY-MM-DD.jsonl`
- 실패한 케이스만 모아 분석 (`trace-analyzer.sh` 활용)
- 그 결과를 다음 하네스 변경에 반영

## 현재 셋업 성능 지표 (2026-04-02 기준)

| 지표 | 수치 | 상태 |
|------|------|------|
| 미들웨어 구현 | 20/20 (100%) | ✅ |
| 세션 격리 | 10/10 (100%) | ✅ |
| 2026 트렌드 채택 | 8/10 (80%) | ✅ |
| async 훅 비율 | 8/20 (40%) | ✅ |
| 보안 계층 | 7계층 | ✅ |
| **종합 등급** | **B+ (85/100)** | 양호 |

**미구현 2개** (A 등급 달성 조건):
1. Prompt Caching 설정 (예상 효과: 입력 토큰 -90% on cache hit)
2. 동적 모델 선택 자동화 (현재는 model: "sonnet" 고정)

## 참고 자료

- [LangChain: Improving Deep Agents](https://blog.langchain.com/improving-deep-agents-with-harness-engineering/)
- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Phil Schmid: Agent Harness 2026](https://www.philschmid.de/agent-harness-2026)
- [OpenAI: Harness Engineering](https://openai.com/index/harness-engineering/)
