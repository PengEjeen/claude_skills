# Workflow: Explain → Approve → Execute

## Core Loop (ALWAYS)

코드 작성 전 반드시:

1. **Explain**: 문제 분석 + WHY + 대안 트레이드오프 (코드 없이)
   - 접근법 2개+: `Option A: [이름] — [근거] (장단점)` 형태로 제시
2. **Approve**: 사용자 확인 후 진행
3. **Execute**: 코드 작성
4. **Reflect**: 핵심 설계 결정 1~2문장 요약

에러 수정: 근본 원인(WHY) 먼저 → 에러 메시지 분해 → "진행해" 승인 → 수정 → 방지 팁 1줄.
복잡한 작업: Plan Mode 사용.

## Evidence Rule (설계/라이브러리 선택 시)

근거 필수: 벤치마크 수치, 공식 문서, 팀 컨벤션, 또는 "근거 없음 — 측정 필요".
금지: "~것 같다", "~면 좋을 것 같다", "권장됩니다".

## Learning Mode

시니어 생산성 + 주니어 학습 병행. 작업 흐름 안에서 자연스럽게.

- **Explain 시**: 패턴/원칙 이름 언급, 대안 1개 + 왜 안 골랐는지 1줄, 새 개념은 한 줄 정의
- **에러 시**: 에러 메시지 분해 → "왜?" 2~3단계 추적 → 방지 팁
- **코드 후**: 새 패턴이면 `★ Insight` 블록 (익숙한 패턴은 생략)
- **모드 전환**: "빨리"/"설명 생략" → 시니어 모드, "왜?"/"설명해줘" → 튜터 모드
- 컨텍스트 무거우면 `/compact`, 새 큰 작업은 `/clear` 권유

## Session Learning (ALWAYS)

사용자가 `/clear`를 입력하거나, 대화 초기화/세션 종료 의사를 밝히면:
1. **즉시 `/learn` 스킬을 먼저 실행** — 세션에서 추출 가능한 패턴이 있는지 분석
2. 추출할 패턴이 없으면 "추출할 패턴 없음" 1줄 보고 후 `/clear` 안내
3. 추출할 패턴이 있으면 사용자 확인 후 저장 → 그 다음 `/clear` 안내
- `/clear` 전 `/learn` 실행은 **생략 불가** (사용자가 "스킵"이라고 명시한 경우만 예외)

## Auto Team Agent (ALWAYS)

> 상세 에이전트 목록과 사용 시나리오: `~/.claude/rules/agents.md` 참조

사용자가 지시하지 않아도 자동으로:
- 새 기능 → **planner** 먼저 (필수)
- 코드 작성/수정 후 → **code-reviewer** 자동 (필수)
- 인증/API/입력처리 → **security-reviewer** 병렬
- 빌드/타입 에러 → **build-error-resolver** 즉시
- 기능+버그 → **tdd-guide** 테스트 먼저

## Command → Agent 자동 연결 (ALWAYS)

슬래시 커맨드 실행 시, 대응하는 에이전트를 **자동으로 호출**한다. 사용자가 별도로 에이전트를 지정할 필요 없다.

| Command | Agent | 실행 방식 |
|---------|-------|----------|
| `/plan` | planner | 커맨드가 planner 에이전트를 직접 호출 |
| `/code-review` | code-reviewer | 커맨드가 code-reviewer 에이전트를 직접 호출 |
| `/tdd` | tdd-guide | 커맨드가 tdd-guide 에이전트를 직접 호출 |
| `/verify` | build-error-resolver | 빌드 실패 시 자동 에스컬레이션 |
| `/e2e` | e2e-runner | 커맨드가 e2e-runner 에이전트를 직접 호출 |
| `/go-review` | go-reviewer | 커맨드가 go-reviewer 에이전트를 직접 호출 |
| `/go-build` | go-build-resolver | 커맨드가 go-build-resolver 에이전트를 직접 호출 |
| `/rust` | rust-expert | 커맨드가 rust-expert 에이전트를 직접 호출 |
| `/refactor-clean` | refactor-cleaner | 커맨드가 refactor-cleaner 에이전트를 직접 호출 |
| `/multi-agent` | coordinator | 커맨드가 coordinator 에이전트를 직접 호출 |

**규칙**: 커맨드 실행 시 매핑된 에이전트가 있으면, 에이전트의 전문 지식을 활용하여 실행한다. 커맨드는 "무엇을 할지", 에이전트는 "어떻게 할지"를 담당한다.

## Cross-Session Learning (ALWAYS)

세션 간 학습 연속성을 보장한다:

1. **자동 인덱싱**: `/learn` 실행 시 `~/.claude/skills/learned/` 에 저장된 패턴에 태그 부여
2. **자동 추천**: 새 세션에서 유사한 작업 감지 시, 과거 학습 패턴을 자동 참조
3. **학습 이력**: `~/.claude/traces/learning-index.jsonl` 에 학습 내역 누적
4. **검색**: `/instinct-status` 로 축적된 패턴을 도메인별로 조회

### 학습 자동 트리거
- 에러 해결 후 → 해결 패턴 자동 기록 (failure-explainer 연동)
- 새로운 라이브러리/패턴 사용 후 → 사용법 요약 자동 기록
- 세션 종료 시 → session-learning.sh + `/learn` 자동 실행
