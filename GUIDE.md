# Claude Code 하네스 셋업 가이드

> 이 가이드는 Claude Code를 처음 접하는 분을 위한 단계별 안내서입니다.
> 설치부터 실전 활용까지, 15분이면 시작할 수 있습니다.

---

## 목차

1. [Claude Code란?](#1-claude-code란)
2. [이 저장소는 뭔가요?](#2-이-저장소는-뭔가요)
3. [설치하기](#3-설치하기)
4. [설치 확인하기](#4-설치-확인하기)
5. [핵심 개념 이해하기](#5-핵심-개념-이해하기)
6. [첫 번째 사용해보기](#6-첫-번째-사용해보기)
7. [주요 기능 활용하기](#7-주요-기능-활용하기)
8. [트러블슈팅](#8-트러블슈팅)
9. [자주 묻는 질문 (FAQ)](#9-자주-묻는-질문-faq)

---

## 1. Claude Code란?

### 한 줄 요약

Claude Code는 Anthropic이 만든 **터미널(명령줄) 기반 AI 코딩 도구**입니다.

### ChatGPT, Cursor와 뭐가 다른가요?

| 비교 항목 | ChatGPT | Cursor | Claude Code |
|-----------|---------|--------|-------------|
| 작동 방식 | 웹 브라우저 채팅 | VS Code 확장 (에디터) | 터미널 CLI |
| 코드 실행 | 불가 (복사해서 붙여넣기) | 에디터 내에서 수정 | **직접 파일 읽기/쓰기/실행** |
| 프로젝트 이해 | 대화에 붙여넣은 것만 | 열린 파일 위주 | **전체 코드베이스 탐색** |
| Git 연동 | 없음 | 제한적 | **커밋, PR, 브랜치 직접 조작** |
| 자동화 | 없음 | 제한적 | **훅, 에이전트, 커맨드로 완전 자동화** |

### 비유로 이해하기

Claude Code는 **"개발자 옆에 24시간 앉아있는 시니어 개발자 + QA 엔지니어 + 보안 전문가"** 입니다.

- 코드를 직접 읽고, 수정하고, 테스트를 돌립니다
- 위험한 명령어를 실행하려 하면 막아줍니다
- Git 커밋 메시지도 작성해주고, PR도 만들어줍니다
- 에러가 나면 원인을 분석하고 해결책을 제시합니다

### 무엇을 할 수 있나요?

- 새 기능 구현 (설계부터 테스트까지)
- 버그 디버깅 (에러 메시지 붙여넣으면 코드베이스에서 원인 추적)
- 코드 리팩토링 (대규모 구조 변경도 가능)
- 테스트 작성 (TDD 워크플로우 지원)
- 문서 작성, API 설계, 보안 감사 등

---

## 2. 이 저장소는 뭔가요?

### 기본 Claude Code vs 하네스 적용 Claude Code

Claude Code는 기본 설치만으로도 강력합니다. 하지만 **하네스(harness)** 를 추가하면 훨씬 더 좋아집니다.

**하네스란?** 모델을 바꾸지 않고, 모델을 감싸는 시스템(규칙, 자동 검사, 전문가 팀)을 추가해서 성능을 높이는 방법론입니다.

자동차에 비유하면 이렇습니다:

| | 기본 Claude Code | 하네스 적용 후 |
|--|------------------|---------------|
| 자동차 | 고성능 엔진만 있는 차 | 엔진 + 안전벨트 + 에어백 + 자동 차선 유지 + 후방 카메라 |
| 결과 | 빠르지만 사고 위험 | 빠르면서도 안전하고 편리함 |

실제 벤치마크로도 증명되었습니다. LangChain은 동일 모델에 하네스만 개선해서 Terminal Bench 2.0 점수를 52.8%에서 66.5%로 끌어올렸습니다 (Top 30에서 Top 5로 상승).

### 이 저장소가 제공하는 것

| 구성 요소 | 수량 | 비유 | 하는 일 |
|----------|------|------|---------|
| Rules (규칙) | 12개 | 업무 매뉴얼 | AI의 행동 방식을 정의 (코딩 스타일, 보안 원칙 등) |
| Hooks (훅) | 29개 | 공장의 자동 품질 검사 라인 | 위험한 동작 차단, 코드 품질 자동 검사 |
| Commands (커맨드) | 31개 | 단축키 | `/plan`, `/tdd`, `/code-review` 같은 빠른 명령어 |
| Agents (에이전트) | 24개 | 전문가 팀 | 상황별 자동 투입되는 전문가 (보안, 성능, 테스트 등) |
| Skills (스킬) | 36개 | 전문 지식 사전 | 특정 도메인의 깊은 지식 (API 설계, React, RAG 등) |

### 설치 전 vs 설치 후: 구체적인 차이

**상황 1: 실수로 위험한 명령어 실행**

```
설치 전:
> claude "rm -rf / 실행해줘"
→ (그냥 실행될 수 있음)

설치 후:
> claude "rm -rf / 실행해줘"
→ [SAFETY] 차단됨: 위험한 명령어가 감지되었습니다
```

**상황 2: console.log를 프로덕션 코드에 남김**

```
설치 전:
> (console.log가 그대로 커밋됨)

설치 후:
> [WARNING] console.log 감지: src/api/handler.ts:42
  프로덕션 코드에는 적절한 로거를 사용하세요.
```

**상황 3: 새 기능 개발 요청**

```
설치 전:
> "로그인 기능 만들어줘"
→ (바로 코드 작성 시작)

설치 후:
> "로그인 기능 만들어줘"
→ [Explain] 접근법 2가지 제안 + 장단점 비교
→ [사용자 승인 대기]
→ [Execute] 승인 후 코드 작성
→ [code-reviewer 자동 투입] 코드 리뷰 실행
→ [security-reviewer 자동 투입] 인증 관련이므로 보안 검토 추가
```

---

## 3. 설치하기

### 사전 준비 체크리스트

설치 전에 아래 항목이 준비되어 있는지 확인하세요:

| 항목 | 확인 방법 | 없으면? |
|------|----------|---------|
| Claude Code CLI | 터미널에서 `claude --version` | [공식 사이트](https://docs.anthropic.com/en/docs/claude-code/overview)에서 설치 |
| Anthropic 계정 | Claude Code 로그인 완료 | anthropic.com에서 가입 |
| Git | `git --version` | [git-scm.com](https://git-scm.com)에서 설치 |
| Node.js 18+ | `node --version` | [nodejs.org](https://nodejs.org)에서 설치 (일부 훅에 필요) |

### Windows에서 설치하기

**중요: PowerShell을 관리자 권한으로 실행하세요.** (심볼릭 링크 생성에 필요)

관리자 권한으로 실행하는 방법:
1. 시작 메뉴에서 "PowerShell" 검색
2. "관리자 권한으로 실행" 클릭

```powershell
# 1단계: 저장소를 원하는 위치에 클론합니다
git clone https://github.com/hyunseung1119/My_ClaudeCode_Skill.git

# 2단계: 클론한 디렉토리로 이동합니다
cd My_ClaudeCode_Skill

# 3단계: 설치 스크립트를 실행합니다
.\setup.ps1
```

관리자 권한 없이 실행하려면, Windows 설정에서 **개발자 모드**를 켜세요:
- 설정 > 개발자용 > 개발자 모드 활성화

### macOS / Linux에서 설치하기

```bash
# 1단계: 저장소를 원하는 위치에 클론합니다
git clone https://github.com/hyunseung1119/My_ClaudeCode_Skill.git

# 2단계: 클론한 디렉토리로 이동합니다
cd My_ClaudeCode_Skill

# 3단계: 실행 권한을 부여합니다
chmod +x setup.sh

# 4단계: 설치 스크립트를 실행합니다
./setup.sh
```

### 설치 스크립트가 하는 일 (단계별 설명)

설치 스크립트는 위험한 작업을 하지 않습니다. 하는 일은 딱 하나, **심볼릭 링크(바로가기) 생성**입니다.

```
1. ~/.claude/ 아래에 skills, agents, rules, hooks 폴더가 없으면 생성
2. 저장소의 skills/ → ~/.claude/skills/ 로 심볼릭 링크 (36개)
3. 저장소의 agents/ → ~/.claude/agents/ 로 심볼릭 링크 (24개)
4. 저장소의 rules/  → ~/.claude/rules/ 로 심볼릭 링크 (12개)
5. 저장소의 hooks/  → ~/.claude/hooks/ 로 심볼릭 링크 (25개)
6. 훅 스크립트에 실행 권한 부여 (macOS/Linux)
7. 설치 결과 요약 출력
```

**심볼릭 링크란?** 파일을 복사하는 게 아니라 "바로가기"를 만드는 것입니다. 원본 파일(저장소)을 수정하면 링크된 곳(~/.claude/)에도 자동으로 반영됩니다. 이 덕분에 `git pull`만 하면 업데이트가 완료됩니다.

### settings.local.json 설정

설치 스크립트는 `settings.local.json`을 자동으로 복사하지 않습니다. 훅이 정상 작동하려면 이 파일을 수동으로 복사해야 합니다.

```bash
# 프로젝트 디렉토리에서 실행
cp settings.local.json ~/.claude/settings.local.json
```

이 파일에는 허용/차단할 명령어 목록과 훅 배선(어떤 훅이 언제 실행되는지)이 정의되어 있습니다.

---

## 4. 설치 확인하기

설치가 잘 되었는지 하나씩 확인해봅시다.

### 4.1 파일 존재 확인

```bash
# 규칙 확인 (12개가 보여야 합니다)
ls ~/.claude/rules/
# 기대 결과: coding-style.md  context-management.md  defaults.md  ...

# 훅 확인 (25개가 보여야 합니다)
ls ~/.claude/hooks/
# 기대 결과: dangerous-command-blocker.sh  console-log-warning.sh  ...

# 에이전트 확인 (24개가 보여야 합니다)
ls ~/.claude/agents/
# 기대 결과: planner.md  code-reviewer.md  security-reviewer.md  ...

# 스킬 확인 (36개 폴더가 보여야 합니다)
ls ~/.claude/skills/
# 기대 결과: api-design  react-component  tdd-workflow  ...

# 숫자로 한눈에 확인
echo "Rules: $(ls ~/.claude/rules/ | wc -l)"
echo "Hooks: $(ls ~/.claude/hooks/ | wc -l)"
echo "Agents: $(ls ~/.claude/agents/ | wc -l)"
echo "Skills: $(ls ~/.claude/skills/ | wc -l)"
```

### 4.2 심볼릭 링크 확인

```bash
# 링크가 제대로 연결되었는지 확인 (macOS/Linux)
ls -la ~/.claude/rules/ | head -5
# 결과에 -> /path/to/My_ClaudeCode_Skill/rules/... 형태가 보여야 합니다

# Windows PowerShell에서 확인
Get-ChildItem ~/.claude/rules/ | Select-Object Name, LinkTarget | Format-Table
```

### 4.3 Claude Code에서 직접 확인

```bash
# Claude Code를 실행합니다
claude

# 프롬프트에서 규칙이 적용되는지 확인합니다
> 현재 활성화된 규칙 목록을 보여줘

# 기대 결과: workflow.md, harness-engineering.md 등이 언급되어야 합니다
```

### 4.4 문제가 있을 때

설치 확인에서 숫자가 0이거나 파일이 없다면:

```bash
# 심볼릭 링크가 깨진 경우 (재설치)
cd /path/to/My_ClaudeCode_Skill
./setup.sh   # macOS/Linux
# 또는
.\setup.ps1  # Windows (관리자 PowerShell)
```

---

## 5. 핵심 개념 이해하기

이 저장소의 구성 요소는 5가지입니다. 각각이 무엇이고, 어떻게 작동하는지 알아봅시다.

### 5.1 Rules -- AI에게 주는 업무 매뉴얼

Rules는 Claude Code가 **항상 따라야 할 행동 규칙**을 정의합니다. 신입사원에게 주는 업무 매뉴얼과 같습니다.

**가장 중요한 규칙: Explain -> Approve -> Execute**

이 규칙이 없으면 Claude Code는 요청을 받자마자 바로 코드를 작성합니다. 이 규칙이 있으면:

```
1. [Explain] "이렇게 하려고 합니다" + 대안 제시
   → Option A: JWT 인증 - 확장성 좋지만 토큰 관리 필요
   → Option B: 세션 인증 - 간단하지만 수평 확장 어려움

2. [Approve] 사용자가 "A로 가자" 선택

3. [Execute] 선택한 방향으로 코드 작성

4. [Reflect] "JWT를 선택한 이유: MSA 전환 계획이 있으므로"
```

이렇게 하면 "원하는 것과 다른 코드가 나왔다"는 상황을 방지할 수 있습니다.

**주요 규칙 파일 목록:**

| 규칙 파일 | 비유 | 핵심 내용 |
|-----------|------|----------|
| `workflow.md` | 근무 수칙 | Explain->Approve->Execute, 근거 없는 추천 금지 |
| `coding-style.md` | 코딩 컨벤션 | 함수 50줄 이내, 파일 400줄 이내, 불변성 원칙 |
| `testing.md` | 품질 기준 | TDD 필수, 커버리지 80% 이상, 테스트 약화 금지 |
| `security.md` | 보안 체크리스트 | OWASP API Top 10, 시크릿 관리, XSS/CSRF 방지 |
| `harness-engineering.md` | 공장 운영 매뉴얼 | 하네스 미들웨어 패턴, 추론 예산 배분 |
| `agents.md` | 조직도 | 24개 에이전트 역할 배분, 자동 투입 조건 |
| `git-workflow.md` | Git 운영 규칙 | Conventional Commits, PR 워크플로우 |
| `context-management.md` | 메모리 관리 | 세션 라이프사이클, 70% 컨텍스트에서 압축 |
| `cs-boost.md` | 학습 촉진 | 코드 변경시 CS 개념 연결, 에러 3-Layer 분해 |

### 5.2 Hooks -- 자동 품질 검사 라인

Hooks는 Claude Code가 도구를 사용할 때 **자동으로 실행되는 검사 스크립트**입니다.

공장의 조립 라인에 비유하면 이렇습니다:

```
[주문 접수] → [안전 검사] → [조립] → [품질 검사] → [포장 검사] → [출고]
     ↓            ↓           ↓           ↓             ↓           ↓
  사용자 요청  위험 명령 차단  코드 작성  포맷/타입 검사  시크릿 검사  최종 검증
```

실제 파이프라인:

```
사용자 요청
  → env-context-injector.sh       환경 정보 자동 수집 (Git 상태, 프로젝트 구조)
  → dangerous-command-blocker.sh  rm -rf, git push --force 등 차단
  → secret-detector.sh            API 키, 비밀번호 하드코딩 감지
  → [Claude Code가 도구 실행]
  → console-log-warning.sh        console.log 프로덕션 코드 경고
  → prettier-format.sh            JS/TS/CSS 자동 포맷
  → tsc-check.sh                  TypeScript 타입 체크
  → ruff-format.sh                Python 린트 + 포맷
  → loop-detector.sh              같은 파일 4회+ 편집 시 경고
  → trace-logger.sh               모든 도구 호출 기록
  → failure-explainer.sh          에러 발생 시 원인 분석
  → pre-completion-check.sh       종료 전 테스트 실행 여부 확인
  → session-learning.sh           세션 종료 시 학습 패턴 추출
완료
```

**훅의 실행 시점(Hook Points):**

| 시점 | 뜻 | 예시 |
|------|-----|------|
| SessionStart | 세션 시작할 때 | 환경 정보 수집 |
| PreToolUse | 도구 실행 직전 | 위험 명령 차단 |
| PostToolUse | 도구 실행 직후 | 코드 포맷, 타입 체크 |
| PostToolUseFailure | 도구 실행 실패 시 | 에러 분석 |
| Stop | 세션 종료 직전 | 최종 검증, 학습 패턴 추출 |

### 5.3 Agents -- 자동으로 투입되는 전문가 팀

Agents는 **상황에 맞게 자동으로 투입되는 전문가**입니다.

병원에 비유하면:
- **접수 간호사(coordinator)**: 환자(요청)를 보고 어떤 전문의에게 보낼지 판단
- **외과의(architect)**: 시스템 설계가 필요할 때
- **내과의(debugger)**: 원인 불명의 버그가 있을 때
- **영상의학과(code-reviewer)**: 코드를 꼼꼼히 검토할 때
- **감염내과(security-reviewer)**: 보안 취약점을 찾아낼 때

**자동 투입 규칙:**

| 상황 | 자동 투입되는 에이전트 |
|------|---------------------|
| 새 기능 개발 | planner (설계) -> tdd-guide (테스트) -> code-reviewer (리뷰) |
| 코드 작성/수정 | code-reviewer (자동 리뷰) |
| 인증/API/입력 처리 | security-reviewer (보안 검토) |
| 빌드/타입 에러 | build-error-resolver (에러 해결) |
| 성능 문제 | performance-optimizer (최적화) |
| 데이터베이스 | database-reviewer (스키마/쿼리 검토) |

**주요 에이전트 24개:**

| 카테고리 | 에이전트 | 역할 |
|----------|---------|------|
| 핵심 | planner, architect, coordinator | 설계, 아키텍처, 작업 조율 |
| 품질 | code-reviewer, tdd-guide, e2e-runner, critic-agent | 리뷰, TDD, E2E, 비판적 검토 |
| 전문 | security-reviewer, performance-optimizer, database-reviewer | 보안, 성능, DB |
| 언어별 | python-reviewer, go-reviewer, rust-expert, react-agent | 언어 전문 리뷰 |
| 인프라 | infrastructure-agent, build-error-resolver, debugger | 인프라, 빌드 에러, 디버깅 |
| 문서 | doc-updater | 문서 자동 업데이트 |
| 고급 | tree-of-thoughts, refactor-cleaner, vector-db-agent, graphql-expert | 사고법, 리팩토링, 벡터DB, GraphQL |

### 5.4 Skills -- 전문 지식 활성화

Skills는 **특정 도메인에 대한 깊은 전문 지식**입니다. 필요할 때 커맨드로 활성화합니다.

도서관에 비유하면:
- 평소에는 책장에 꽂혀 있음 (메모리를 차지하지 않음)
- 필요할 때 꺼내서 읽음 (`/skill-name`으로 활성화)
- 읽으면 해당 분야의 전문 지식이 적용됨

**주요 스킬 목록:**

| 분야 | 스킬 이름 | 내용 |
|------|----------|------|
| 설계 | api-design, architecture-design | API 설계 패턴, 시스템 아키텍처 |
| 프론트엔드 | react-component, frontend-codemap | React 컴포넌트, 프론트엔드 구조 파악 |
| 백엔드 | backend-api, database-schema | REST/GraphQL API, DB 스키마 설계 |
| 테스트 | tdd-workflow, debugging | TDD 실전 가이드, 디버깅 기법 |
| AI/ML | rag-2.0, ml-training, prompt-optimizer | RAG 시스템, ML 학습, 프롬프트 최적화 |
| 보안 | security-audit | 보안 감사 체크리스트 |
| 문서 | documentation-gen, dev-blog-writer | 문서 생성, 기술 블로그 작성 |
| 계획 | product-planner, llm-app-planner | 프로덕트 기획, LLM 앱 설계 |
| 코드 품질 | clean-code, refactoring, code-review | 클린 코드, 리팩토링, 코드 리뷰 |
| 연구 | ai-research-integration, research-agent-tech | AI 논문 분석, 리서치 에이전트 |
| 페르소나 QA | industry-persona-qa | 산업별 전문가 관점으로 QA |

### 5.5 Commands -- 빠른 실행 명령어

Commands는 자주 쓰는 작업을 **한 단어로 실행하는 단축키**입니다.

Claude Code 프롬프트에서 `/명령어`를 입력하면 해당 워크플로우가 자동으로 실행됩니다.

**가장 많이 쓰는 커맨드 TOP 10:**

| 커맨드 | 하는 일 | 사용 예 |
|--------|---------|---------|
| `/plan` | 작업 계획 수립 | `/plan 사용자 인증 시스템 구현` |
| `/tdd` | TDD 워크플로우 시작 | `/tdd login 함수 테스트` |
| `/code-review` | 코드 리뷰 실행 | `/code-review src/auth/` |
| `/test-coverage` | 테스트 커버리지 확인 | `/test-coverage` |
| `/handoff` | 세션 인수인계 메모 생성 | `/handoff` |
| `/learn` | 세션 학습 패턴 추출 | `/learn` |
| `/checkpoint` | 현재 진행 상황 저장 | `/checkpoint` |
| `/refactor-clean` | 리팩토링 가이드 | `/refactor-clean src/legacy/` |
| `/build-fix` | 빌드 에러 해결 | `/build-fix` |
| `/tool-registry` | 사용 가능한 도구 검색 | `/tool-registry 보안` |

**전체 커맨드 목록:**

```
/build-fix        /checkpoint       /code-review      /define-dod
/e2e              /eval             /evolve           /frontend-codemap
/go-build         /go-review        /go-test          /handoff
/instinct-export  /instinct-import  /instinct-status  /learn
/modern-frontend  /multi-agent      /orchestrate      /plan
/refactor-clean   /rust             /setup-pm         /skill-create
/tdd              /test-coverage    /token-analysis   /tool-registry
/update-codemaps  /update-docs      /verify
```

---

## 6. 첫 번째 사용해보기

설치가 완료되었으면 직접 사용해봅시다. 4개의 실습을 통해 핵심 기능을 체험합니다.

### 실습 1: 안전 기능 확인 (2분)

위험한 명령어가 제대로 차단되는지 확인합니다.

```bash
# Claude Code 실행
claude

# 위험한 명령어 요청 (실제로 실행되지 않습니다)
> rm -rf / 실행해줘
```

**기대 결과:** `dangerous-command-blocker.sh` 훅이 작동하여 차단 메시지가 표시됩니다.

```bash
# 시크릿 감지 테스트
> 다음 코드를 작성해줘:
  const API_KEY = "sk-1234567890abcdef"
```

**기대 결과:** `secret-detector.sh` 훅이 작동하여 하드코딩된 API 키를 경고합니다.

### 실습 2: Explain -> Approve -> Execute 워크플로우 체험 (5분)

아무 프로젝트 디렉토리에서 Claude Code를 실행하고, 기능 구현을 요청해봅니다.

```bash
# 테스트용 디렉토리 생성
mkdir ~/test-project && cd ~/test-project
npm init -y

# Claude Code 실행
claude

# 기능 요청
> 간단한 할 일 목록(TODO) API를 Express로 만들어줘
```

**기대 결과:**

1. Claude Code가 바로 코드를 작성하지 않고, 먼저 **접근 방식을 설명**합니다
2. 2가지 이상의 옵션을 제시합니다 (예: 파일 기반 저장 vs 인메모리)
3. 사용자가 선택하면 그때 코드 작성을 시작합니다
4. 코드 작성 후 **code-reviewer** 에이전트가 자동으로 리뷰를 실행합니다

### 실습 3: 에이전트 자동 투입 확인 (5분)

```bash
# 같은 프로젝트에서
> 이 API에 JWT 인증을 추가해줘
```

**기대 결과:**

1. `planner` 에이전트가 인증 설계를 먼저 제안합니다
2. 구현 후 `code-reviewer`가 코드 리뷰를 실행합니다
3. 인증 관련이므로 `security-reviewer`가 추가로 보안 검토를 실행합니다

이 모든 것이 사용자가 별도로 요청하지 않아도 자동으로 이루어집니다.

### 실습 4: 스킬 활용 (3분)

```bash
# TDD 워크플로우 시작
> /tdd

# 프롬프트가 나오면 테스트 대상 설명
> 사용자 등록 함수: 이메일 검증, 비밀번호 해시, 중복 체크
```

**기대 결과:**

1. `tdd-guide` 에이전트가 투입됩니다
2. 먼저 **실패하는 테스트**를 작성합니다 (RED)
3. 테스트가 실패하는지 확인합니다
4. **최소한의 구현**으로 테스트를 통과시킵니다 (GREEN)
5. 코드를 **리팩토링**합니다 (REFACTOR)
6. 커버리지 80% 이상인지 확인합니다

---

## 7. 주요 기능 활용하기

### 7.1 코드 리뷰 자동화

코드를 작성하거나 수정하면 `code-reviewer` 에이전트가 자동으로 리뷰합니다.

수동으로 리뷰를 요청할 수도 있습니다:

```bash
# 특정 파일 리뷰
> /code-review src/auth/login.ts

# 최근 변경사항 리뷰
> 마지막 커밋의 변경사항을 리뷰해줘
```

리뷰 항목:
- 코딩 스타일 준수 여부 (함수 50줄 이내, 파일 400줄 이내)
- 타입 안전성
- 에러 처리
- 보안 취약점
- 테스트 커버리지

### 7.2 TDD 워크플로우

테스트 주도 개발을 체계적으로 진행합니다.

```bash
> /tdd

# 또는 직접 요청
> 유저 서비스의 findById 함수를 TDD로 만들어줘
```

워크플로우:

```
1. RED    → 실패하는 테스트 작성
2. 실행   → 테스트 실패 확인
3. GREEN  → 최소 구현으로 테스트 통과
4. 실행   → 테스트 통과 확인
5. REFACTOR → 코드 개선 (테스트는 여전히 통과)
6. 커버리지 → 80% 이상 확인
```

**중요:** 테스트가 실패하면 테스트를 약화시키지 않고 구현을 수정합니다. `test.skip`, 빈 catch 블록, 타임아웃 무한 증가는 금지됩니다.

### 7.3 보안 감사

인증, API, 사용자 입력 처리 코드를 작성하면 `security-reviewer`가 자동 투입됩니다.

수동으로 보안 감사를 요청할 수도 있습니다:

```bash
# 프로젝트 전체 보안 감사
> 이 프로젝트의 보안 감사를 해줘

# 특정 파일 보안 검토
> src/api/payment.ts 보안 검토해줘
```

자동 검사 항목:
- 하드코딩된 시크릿 (API 키, 비밀번호, 토큰)
- SQL 인젝션 (문자열 보간 대신 파라미터 바인딩)
- XSS (HTML 출력 이스케이프)
- BOLA (객체 소유권 확인)
- Rate Limiting (인증 엔드포인트 제한)

### 7.4 프로젝트 계획

새 프로젝트나 큰 기능을 시작할 때 체계적인 계획을 세웁니다.

```bash
> /plan AI 기반 코드 리뷰 자동화 서비스
```

`planner` 에이전트가 다음을 생성합니다:
- 요구사항 분석
- 기술 스택 선택 (근거 포함)
- 아키텍처 설계
- 마일스톤 분류
- 리스크 식별

### 7.5 산업별 페르소나 QA

다양한 산업 전문가의 관점에서 제품을 검토합니다.

```bash
# industry-persona-qa 스킬 활성화 후
> 이 API를 핀테크 관점에서 검토해줘
> 이 UI를 헬스케어 규제 관점에서 검토해줘
```

금융, 의료, 교육, 게임 등 산업별 전문가 페르소나가 해당 산업의 규제, 보안 기준, 사용자 경험 관점에서 피드백을 제공합니다.

### 7.6 도구 검색 (/tool-registry)

어떤 커맨드나 스킬이 있는지 모를 때, 키워드로 검색합니다.

```bash
> /tool-registry 보안
# → security-audit, security-reviewer, secret-detector 등 관련 도구 목록

> /tool-registry 프론트엔드
# → react-component, frontend-codemap, modern-frontend 등
```

---

## 8. 트러블슈팅

### 자주 발생하는 문제와 해결법

| 문제 | 원인 | 해결 방법 |
|------|------|----------|
| 훅이 실행되지 않음 | 실행 권한이 없음 | `chmod +x ~/.claude/hooks/*.sh` (macOS/Linux) |
| settings가 적용 안 됨 | 파일 경로 오류 | `cat ~/.claude/settings.local.json`으로 파일 존재 확인 |
| 에이전트가 자동 투입 안 됨 | rules/agents.md 미설치 | `ls ~/.claude/rules/agents.md` 확인 |
| 응답이 느려짐 | 훅 타임아웃 초과 | settings.local.json에서 개별 훅 timeout 값 조정 |
| 심볼릭 링크 생성 실패 (Windows) | 관리자 권한 없음 | PowerShell을 관리자로 실행하거나 개발자 모드 활성화 |
| "command not found" 에러 | jq 미설치 | `brew install jq` (macOS) 또는 `apt install jq` (Linux) |
| prettier가 실행 안 됨 | 프로젝트에 prettier 미설치 | `npm install -D prettier` |
| tsc 체크 실패 | tsconfig.json 없음 | `npx tsc --init`으로 생성 |
| ruff가 실행 안 됨 | ruff 미설치 | `pip install ruff` |

### 특정 훅만 비활성화하기

모든 훅이 필요하지 않을 수 있습니다. settings.local.json에서 특정 훅을 제거하면 됩니다.

```jsonc
// ~/.claude/settings.local.json
{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          // 이 항목을 제거하면 해당 훅이 비활성화됩니다
          // { "type": "command", "command": "bash ~/.claude/hooks/prettier-format.sh" }
        ]
      }
    ]
  }
}
```

### 로그 확인하기

훅 실행 기록은 trace-logger.sh가 자동으로 남깁니다:

```bash
# 트레이스 로그 확인
ls ~/.claude/traces/
cat ~/.claude/traces/$(ls -t ~/.claude/traces/ | head -1)
```

---

## 9. 자주 묻는 질문 (FAQ)

### Q: 이거 쓰면 비용이 더 나오나요?

하네스 자체는 비용을 발생시키지 않습니다. Rules, Hooks, Commands는 로컬에서 실행되는 스크립트와 텍스트 파일이므로 API 호출 비용이 추가되지 않습니다.

다만, 에이전트가 자동 투입될 때 추가적인 Claude API 호출이 발생할 수 있습니다. 예를 들어 code-reviewer가 자동으로 리뷰를 하면 그만큼 토큰을 더 사용합니다. 하지만 이는 "수동으로 리뷰를 요청하는 것"과 같은 비용이므로, 추가 비용이라기보다는 "자동화된 작업의 비용"입니다.

### Q: Claude Code Pro 구독이 필요한가요?

Claude Code CLI를 사용하려면 Anthropic의 API 키 또는 Claude Pro/Team/Enterprise 구독이 필요합니다. 이 하네스 저장소 자체는 무료이며, Claude Code가 설치되어 있으면 누구나 사용할 수 있습니다.

### Q: 업데이트는 어떻게 하나요?

심볼릭 링크로 설치했으므로, 원본 저장소를 업데이트하면 자동으로 반영됩니다:

```bash
# 저장소 디렉토리로 이동
cd /path/to/My_ClaudeCode_Skill

# 최신 버전 가져오기
git pull origin main

# 끝! 심볼릭 링크이므로 별도 재설치 불필요
```

새로운 파일이 추가된 경우에만 설치 스크립트를 다시 실행합니다:

```bash
./setup.sh   # macOS/Linux
.\setup.ps1  # Windows
```

### Q: 특정 훅만 끄고 싶으면?

`~/.claude/settings.local.json`에서 해당 훅 항목을 제거하거나 주석 처리하면 됩니다. [트러블슈팅 섹션](#특정-훅만-비활성화하기)을 참고하세요.

### Q: 팀에서 같이 쓸 수 있나요?

네. 두 가지 방법이 있습니다:

**방법 1: 각자 설치**
- 팀원 각자가 이 저장소를 클론하고 setup 스크립트를 실행합니다
- 장점: 개인별 커스터마이징 가능
- 단점: 업데이트를 각자 해야 함

**방법 2: 프로젝트별 설정**
- 프로젝트 루트에 `.claude/` 디렉토리를 만들고, 프로젝트 전용 규칙을 넣습니다
- `CLAUDE.md`를 프로젝트 루트에 두면 해당 프로젝트에서만 적용됩니다
- 장점: Git으로 팀 전체 동기화
- 단점: 글로벌 설정은 별도 관리

### Q: 커스텀 훅/스킬을 만들 수 있나요?

네. 각 구성 요소의 패턴을 따라 만들면 됩니다.

**커스텀 훅 만들기:**

```bash
# 1. 훅 스크립트 작성
cat > ~/.claude/hooks/my-custom-hook.sh << 'EOF'
#!/bin/bash
# 훅 로직 작성
# 표준 출력 형식: {"decision":"approve","reason":"통과"}
echo '{"decision":"approve","reason":"Custom check passed"}'
EOF

# 2. 실행 권한 부여
chmod +x ~/.claude/hooks/my-custom-hook.sh

# 3. settings.local.json에 훅 등록
```

**커스텀 스킬 만들기:**

```bash
# /skill-create 커맨드를 사용하면 자동으로 템플릿이 생성됩니다
> /skill-create my-domain-skill
```

### Q: Claude Code 없이 이 저장소만 쓸 수 있나요?

아니요. 이 저장소는 Claude Code CLI의 기능(Rules, Hooks, Skills, Agents)에 의존합니다. Claude Code 없이는 동작하지 않습니다.

### Q: 기존 Claude Code 설정과 충돌하나요?

설치 스크립트는 기존 파일이 있으면 덮어씁니다. 기존에 `~/.claude/rules/`나 `~/.claude/hooks/`에 개인 설정이 있다면, 설치 전에 백업하는 것을 권장합니다:

```bash
# 백업
cp -r ~/.claude/rules/ ~/.claude/rules-backup/
cp -r ~/.claude/hooks/ ~/.claude/hooks-backup/

# 설치 실행
./setup.sh
```

### Q: 제거(언인스톨)는 어떻게 하나요?

제거 스크립트가 포함되어 있습니다:

```bash
# macOS/Linux
./uninstall.sh

# Windows
.\uninstall.ps1
```

심볼릭 링크만 제거하므로 원본 저장소는 그대로 남습니다.

---

## 다음 단계

설치와 기본 사용법을 익혔다면, 아래 로드맵을 따라 점진적으로 활용도를 높여보세요.

| 주차 | 목표 | 핵심 학습 | 실습 |
|------|------|----------|------|
| 1주차 | 안전 훅 체험 | dangerous-command-blocker, secret-detector, console-log-warning 이해 | 의도적으로 위험 명령어/시크릿 작성해보고 차단 확인 |
| 2주차 | 품질 자동화 | prettier-format, tsc-check, ruff-format 이해 | JS/TS/Python 파일 작성 후 자동 포맷/린트 확인 |
| 3주차 | 워크플로우 숙달 | Explain->Approve->Execute + TDD 패턴 | `/plan`으로 기능 설계 후 `/tdd`로 구현 |
| 4주차 | 에이전트 활용 | planner + code-reviewer + security-reviewer 협업 | 인증 기능 구현해보며 에이전트 자동 투입 체험 |
| 5주차 | 고급 활용 | `/handoff`, `/checkpoint`, trace 분석 | 멀티 세션 프로젝트 운영, 트레이스 로그 분석 |

### 더 알아보기

- **README.md**: 프로젝트 전체 구조와 하네스 미들웨어 상세 설명
- **MCP_QUICK_SETUP.md**: MCP 서버(GitHub, 브라우저 등) 연동 가이드
- **rules/harness-engineering.md**: 하네스 엔지니어링 이론과 설계 원칙
- **GitHub Issues**: 문제 발견 시 이슈를 남겨주세요

---

> 이 가이드에 대한 피드백이나 개선 제안은 GitHub Issues에 남겨주세요.
> 저장소: https://github.com/hyunseung1119/My_ClaudeCode_Skill
