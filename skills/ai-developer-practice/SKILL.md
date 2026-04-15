---
name: ai-developer-practice
description: 2026년 AI 개발자 실무 종합 스킬. LLM/에이전트 시스템을 운영 수준으로 구축하기 위한 7가지 핵심 역량을 다룹니다. "AI 개발", "에이전트 운영", "LLM 운영", "MLOps", "AI 실무", "에이전트 보안", "LLM observability", "AI 채용", "AI developer", "production LLM", "agent operations" 등의 요청 시 사용합니다. Agentic+RAG+Tool-use 아키텍처, Observability/Eval, 데이터/검색 스택, AI 보안(OWASP LLM Top 10, MITRE ATLAS), 규제/거버넌스(SBOM, EU CRA), 모델 서빙 최적화, AI 개발자 기본기를 포괄합니다.
---

# AI Developer Practice 2026 — 운영 가능한 AI 시스템 구축 가이드

> "PoC는 끝났다. 운영 가능한 에이전트 시스템을 만들 줄 아는 사람이 필요하다."

이 스킬은 2026년 AI 개발자가 실무에서 반드시 갖춰야 할 7가지 핵심 역량을 정리한다.
각 영역의 상세 구현이 필요하면 해당 전문 스킬을 참조한다.

---

## 1. Agentic + RAG + Tool-use — 기본 아키텍처

### 2026년 기본값: 에이전트가 여러 툴/데이터를 호출하는 구조

```
User Query
    ↓
┌─────────────────────────────────┐
│  Orchestrator (LangGraph 등)    │
│  ┌──────────┐  ┌──────────┐    │
│  │ RAG      │  │ Tool-use │    │
│  │ 검색증강  │  │ API 호출  │    │
│  └────┬─────┘  └────┬─────┘    │
│       ↓              ↓          │
│  Vector DB      Internal APIs   │
│  + Reranker     DB / Workflow   │
└─────────────────────────────────┘
    ↓
Response (인용/근거 포함)
```

### 핵심 패턴 3가지

| 패턴 | 설명 | 언제 사용 |
|------|------|-----------|
| **RAG** | 벡터DB/검색 + 프롬프트 구성 + 인용 응답 | 기업 문서 기반 Q&A |
| **Tool-use** | DB 조회, 사내 API 호출, 워크플로 실행 | 외부 시스템 연동 |
| **Multi-Agent** | 라우팅, 역할 분리, HITL 승인 지점 | 복잡한 다단계 작업 |

### 현업 스택 (2026)

```yaml
오케스트레이션:
  - LangGraph / LangChain  # 복잡한 상태 관리
  - CrewAI                  # 역할 기반 협업
  - Temporal + 자체 구현     # 워크플로 엔진 조합

서빙:
  - FastAPI + SSE/WebSocket  # Python 생태계
  - Spring Boot              # Java/엔터프라이즈
  - Next.js (Node)           # 풀스택

비동기/파이프라인:
  - Kafka / RabbitMQ         # 메시지 큐
  - Celery                   # Python 비동기 태스크
  - 큐 기반 작업 처리         # 대용량 배치
```

### 실무 체크리스트
```
□ 에이전트가 호출하는 모든 툴에 timeout과 retry 정책이 있는가?
□ 에이전트의 각 단계(검색→프롬프트→모델→툴→후처리)가 추적 가능한가?
□ 실패 시 graceful degradation이 구현되어 있는가?
□ HITL(Human-in-the-Loop) 승인 지점이 설계되어 있는가?
□ 스트리밍 응답이 지원되는가? (SSE/WebSocket)
```

> **상세 설계:** chatbot-designer 스킬 (아키텍처 패턴), agentic-workflows 스킬 (멀티에이전트)

---

## 2. Observability + Evaluation — 운영의 핵심

### "로그가 아니라 트레이싱/평가/품질지표가 필수"

에이전트/RAG는 구성요소가 많아서 장애가 '모델'이 아니라 체인 어딘가에서 터진다.

### LLM Observability 아키텍처

```
Request → [검색] → [프롬프트 조합] → [모델 호출] → [툴 실행] → [후처리] → Response
   │         │            │              │            │           │
   ▼         ▼            ▼              ▼            ▼           ▼
  ┌──────────────────────────────────────────────────────────────────┐
  │                    Tracing Layer (OpenTelemetry)                  │
  │  span: retrieval  span: prompt   span: llm    span: tool        │
  │  latency: 120ms   tokens: 2000   cost: $0.01  status: success   │
  └──────────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┼─────────┐
                    ▼         ▼         ▼
               Dashboard   Alerts   Cost Report
```

### OpenTelemetry GenAI 트레이싱 (2026 표준)

```python
from opentelemetry import trace
from opentelemetry.instrumentation.openai import OpenAIInstrumentor

# 자동 계측: 모든 LLM 호출에 trace 추가
OpenAIInstrumentor().instrument()

tracer = trace.get_tracer(__name__)

async def rag_pipeline(query: str):
    with tracer.start_as_current_span("rag_pipeline") as span:
        span.set_attribute("gen_ai.operation.name", "retrieve_and_generate")

        # 1. 검색
        with tracer.start_as_current_span("retrieval") as ret_span:
            results = await retriever.search(query)
            ret_span.set_attribute("retrieval.num_results", len(results))
            ret_span.set_attribute("retrieval.strategy", "hybrid")

        # 2. 모델 호출
        with tracer.start_as_current_span("generation") as gen_span:
            response = await llm.generate(query, context=results)
            gen_span.set_attribute("gen_ai.request.model", "claude-sonnet-4-5-20250929")
            gen_span.set_attribute("gen_ai.usage.input_tokens", response.usage.input)
            gen_span.set_attribute("gen_ai.usage.output_tokens", response.usage.output)

        return response
```

### 관측 도구 선택

| 도구 | 유형 | 장점 | 단점 |
|------|------|------|------|
| **Langfuse** | OSS | 셀프호스팅, 비용 없음, LLM 특화 | 대규모 운영 시 관리 부담 |
| **LangSmith** | SaaS | LangChain 통합 최고 | 벤더 종속 |
| **Datadog LLM Obs** | SaaS | 기존 인프라 모니터링 통합 | 비용 높음 |
| **Opik** | OSS | Comet 기반, 실험 추적 | 커뮤니티 작음 |

### 평가 체계 (Eval)

```
평가 피라미드:

    ┌─────────┐
    │ Online  │  ← 실시간: 사용자 피드백, 응답 품질 모니터링
    │ Monitor │
    ├─────────┤
    │  A/B    │  ← 비교: 새 모델/프롬프트 vs 기존
    │  Test   │
    ├─────────┤
    │Regression│ ← 회귀: golden set으로 배포 전 자동 검증
    │  Test    │
    ├─────────┤
    │ Golden  │  ← 기초: 질문-정답 세트 (최소 50-100개)
    │   Set   │
    └─────────┘
```

### Golden Set 구성

```python
# eval/golden_set.json 예시
[
    {
        "query": "연차 신청 절차가 어떻게 되나요?",
        "expected_answer": "인사시스템 > 근태관리 > 연차신청에서...",
        "expected_sources": ["HR-Policy-2026.pdf"],
        "category": "hr_policy",
        "difficulty": "easy"
    },
    {
        "query": "올해 매출 목표 대비 달성률은?",
        "expected_answer": null,  # 모델이 "답변 불가"여야 함
        "expected_sources": [],
        "category": "financial",
        "difficulty": "should_refuse"
    }
]
```

### 평가 메트릭

| 메트릭 | 측정 대상 | 목표값 |
|--------|-----------|--------|
| **Context Precision** | 검색된 문서 중 관련 문서 비율 | > 0.80 |
| **Context Recall** | 관련 문서 중 검색된 비율 | > 0.85 |
| **Faithfulness** | 답변이 검색 결과에 근거한 정도 | > 0.90 |
| **Answer Relevancy** | 답변이 질문과 관련된 정도 | > 0.85 |
| **Latency P95** | 95% 요청의 응답 시간 | < 3s |
| **Cost per Query** | 쿼리당 API 비용 | < $0.05 |

### 운영 지표 & 알람

```yaml
# SLO (Service Level Objectives) 정의
slo:
  availability: 99.5%          # 월간 가용성
  latency_p95: 3000ms          # 95% 응답 시간
  error_rate: < 2%             # 에러율
  quality_score: > 0.85        # 답변 품질 점수

# 알람 설정
alerts:
  - name: high_error_rate
    condition: error_rate > 5% for 5min
    severity: critical
    action: page_oncall

  - name: latency_degradation
    condition: p95_latency > 5000ms for 10min
    severity: warning
    action: slack_notification

  - name: cost_spike
    condition: daily_cost > 2x average
    severity: warning
    action: slack_notification

  - name: quality_drop
    condition: faithfulness < 0.80 for 1hour
    severity: critical
    action: page_oncall + rollback
```

### 런북 (Runbook) 템플릿

```markdown
## Runbook: RAG 품질 저하 대응

### 증상
- Faithfulness < 0.80 알람
- 사용자 "엉뚱한 답변" 피드백 증가

### 진단 순서
1. **검색 품질 확인**: trace에서 retrieval span 확인
   - 검색 결과가 비어있다면 → 인덱스/벡터DB 상태 확인
   - 검색 결과는 있지만 무관하다면 → 임베딩 모델 또는 청킹 문제
2. **모델 응답 확인**: generation span 확인
   - 컨텍스트 무시하고 답변 → 프롬프트 변경 이력 확인
   - 환각(hallucination) → temperature 확인, 프롬프트에 "근거 없으면 모른다고 답하라" 추가
3. **최근 변경사항 확인**: 배포 이력, 프롬프트 변경, 데이터 업데이트

### 즉시 조치
- [ ] 이전 안정 버전으로 롤백 (feature flag)
- [ ] 영향 범위 파악 (로그 쿼리)
- [ ] 근본 원인 분석 후 hotfix

### 예방 조치
- [ ] golden set에 해당 케이스 추가
- [ ] 회귀 테스트에 포함
- [ ] 모니터링 임계값 조정
```

> **상세:** agent-evaluator 스킬 (벤치마크), performance-optimization 스킬 (성능)

---

## 3. 데이터/검색 스택 — RAG 품질의 핵심

### "RAG 품질은 모델보다 검색 품질이 좌우한다"

### 검색 스택 아키텍처

```
문서 원본
    ↓
[전처리] → 정규화, 메타데이터 추출
    ↓
[청킹] → 512 토큰 기준, 오버랩 50 토큰
    ↓
[임베딩] → text-embedding-3-large / multilingual-e5
    ↓
[인덱싱] → 벡터 인덱스 + BM25 인덱스 + 메타데이터
    ↓
[검색] → 하이브리드 (벡터 + 키워드) + 메타데이터 필터
    ↓
[리랭킹] → Cohere Rerank / cross-encoder
    ↓
[생성] → LLM + 인용 생성
```

### 벡터DB 선택 가이드 (2026)

| DB | 유형 | 하이브리드 검색 | 메타데이터 | 추천 상황 |
|----|------|----------------|-----------|-----------|
| **Pinecone** | 관리형 | O | O | 빠른 시작, 운영 부담 최소 |
| **Weaviate** | OSS/관리형 | O (네이티브) | O | 하이브리드 검색 최강 |
| **Qdrant** | OSS | O | O | 가볍고 빠름, Rust 기반 |
| **pgvector** | PostgreSQL | 제한적 | O | PostgreSQL 이미 사용 중 |
| **Milvus** | OSS | O | O | 대규모, GPU 가속 |
| **Elasticsearch** | OSS | O (강점) | O | 기존 ELK 스택 있을 때 |

### 청킹 전략 — "일단 벡터DB" 전에 먼저 설계

```python
# 청킹은 RAG 성능의 50%를 결정한다

# BAD: 단순 문자 수 기반
chunks = text_splitter.split(text, chunk_size=500)

# GOOD: 의미 단위 + 메타데이터
class SmartChunker:
    def chunk(self, document: Document) -> list[Chunk]:
        # 1. 문서 구조 파악 (헤더, 섹션, 리스트)
        sections = self.parse_structure(document)

        chunks = []
        for section in sections:
            chunk = Chunk(
                text=section.text,
                metadata={
                    "source": document.filename,
                    "section": section.title,
                    "page": section.page_number,
                    "doc_type": document.type,      # policy, manual, faq
                    "department": document.department,
                    "updated_at": document.updated_at,
                    "language": detect_language(section.text),
                },
                # 2. 오버랩으로 문맥 보존
                overlap_prev=section.prev_context[:50],
                overlap_next=section.next_context[:50],
            )
            chunks.append(chunk)

        return chunks
```

### 검색 품질 개선 루트

```
검색 실패 감지 (관측)
    ↓
┌───────────────────────────────┐
│ 1. 쿼리 재작성 (Query Rewriting)│  ← 비용 낮음
│    - HyDE (가상 답변 임베딩)     │
│    - Multi-query expansion      │
├───────────────────────────────┤
│ 2. 리랭커 추가                  │  ← 효과 확실
│    - Cohere Rerank             │
│    - Cross-encoder             │
├───────────────────────────────┤
│ 3. 응답 캐시                    │  ← 비용 절감
│    - 동일/유사 쿼리 캐싱        │
│    - Semantic cache             │
├───────────────────────────────┤
│ 4. 청킹/메타데이터 재설계       │  ← 근본 해결
│    - 의미 단위 청킹             │
│    - 메타데이터 필터 강화        │
└───────────────────────────────┘
```

> **상세:** rag-2.0 스킬 (RAG 패턴), research-agent-tech 스킬 (최신 기술)

---

## 4. AI 보안 — "에이전트가 내부 시스템을 만지는 순간"

### 2026년: 보안이 기능 요구사항이다

에이전트가 DB 조회, API 호출, 파일 접근을 하는 순간, 보안은 선택이 아니다.

### OWASP LLM Top 10 (2025) — 핵심 위협

| 순위 | 위협 | 설명 | 대응 |
|------|------|------|------|
| **LLM01** | Prompt Injection | 직접/간접 프롬프트 주입으로 의도치 않은 동작 유발 | 입력 검증, 권한 분리, 출력 검열 |
| **LLM02** | Sensitive Information Disclosure | 학습 데이터/프롬프트의 민감 정보 유출 | PII 필터링, 출력 검열, 프롬프트 보호 |
| **LLM03** | Supply Chain | 악성 모델/플러그인/데이터 | SBOM, 의존성 감사, 모델 출처 검증 |
| **LLM04** | Data and Model Poisoning | 학습/RAG 데이터 오염 | 데이터 검증, 출처 추적 |
| **LLM05** | Improper Output Handling | LLM 출력을 검증 없이 실행 | 출력 새니타이징, 코드 실행 샌드박스 |
| **LLM06** | Excessive Agency | 에이전트에 과도한 권한 부여 | 최소 권한 원칙, 작업별 권한 분리 |
| **LLM07** | System Prompt Leakage | 시스템 프롬프트 노출 | 프롬프트 인젝션 방어, 비공개 지침 분리 |
| **LLM08** | Vector and Embedding Weaknesses | 임베딩 조작으로 검색 결과 오염 | 접근 제어, 임베딩 무결성 검증 |
| **LLM09** | Misinformation | 잘못된 정보를 확신 있게 전달 | 근거 기반 응답 강제, 인용 |
| **LLM10** | Unbounded Consumption | 과도한 리소스 소비 (DoS) | Rate limiting, 토큰 제한, 비용 상한 |

### MITRE ATLAS — AI 위협 모델링

```
MITRE ATLAS = AI 시스템 공격 전술/기법 지식베이스

활용법:
1. 위협 모델링: 시스템별 공격 표면 식별
2. 레드팀 테스트: ATLAS 기법으로 에이전트 테스트
3. 방어 설계: 기법별 대응 매핑

주요 전술:
- Reconnaissance: 모델/시스템 정보 수집
- Resource Development: 공격 데이터/프롬프트 준비
- Initial Access: 프롬프트 인젝션, 입력 조작
- Execution: 의도치 않은 코드/명령 실행
- Persistence: 지속적 접근 유지
- Exfiltration: 데이터 유출
```

### 실무 보안 체크리스트

```
[에이전트 권한]
□ 작업별 최소 권한 분리 (읽기 전용 / 쓰기 / 실행 분리)
□ 민감 데이터 접근 경계 설정
□ 툴 호출 allowlist (허용된 API만 호출 가능)
□ 중요 작업에 인간 승인(HITL) 필수

[입력 검증]
□ 프롬프트 인젝션 탐지 (직접 + 간접)
□ 사용자 입력 새니타이징
□ RAG 소스 데이터 무결성 검증
□ 툴 호출 파라미터 유효성 검사

[출력 검열]
□ PII (개인식별정보) 필터링
□ 정책 위반 응답 차단
□ 코드/명령 출력 시 실행 전 검증
□ "모델이 준 코드/명령은 반드시 검증" (그럴듯함의 함정)

[모니터링]
□ 비정상 패턴 탐지 (반복 프롬프트, 권한 상승 시도)
□ 비용 이상 알람
□ 데이터 유출 탐지
```

### 프롬프트 인젝션 방어 전략

```python
# 구조적으로 완전한 해결은 어렵다 — 다층 방어가 필수

class PromptInjectionDefense:
    """다층 프롬프트 인젝션 방어"""

    def validate_input(self, user_input: str) -> tuple[bool, str]:
        # Layer 1: 패턴 매칭 (알려진 공격 패턴)
        if self.matches_known_patterns(user_input):
            return False, "의심스러운 입력 패턴 탐지"

        # Layer 2: LLM 기반 분류 (작은 모델로)
        is_injection = self.classify_with_llm(user_input)
        if is_injection:
            return False, "프롬프트 인젝션 시도 탐지"

        # Layer 3: 입력 길이/형식 제한
        if len(user_input) > MAX_INPUT_LENGTH:
            return False, "입력 길이 초과"

        return True, "통과"

    def sanitize_for_rag(self, document: str) -> str:
        """RAG 소스에서 간접 인젝션 제거"""
        # 명령어 패턴 제거
        # 시스템 프롬프트 참조 제거
        # 역할 전환 시도 제거
        return cleaned_document
```

> **상세:** security-audit 스킬 (OWASP Top 10 전반), chatbot-designer 스킬 (에이전트 안전성)

---

## 5. 규제/거버넌스/공급망 — "개발 프로세스의 일부"

### EU Cyber Resilience Act (CRA) 타임라인

```
2024-12-10  CRA 발효
2026-09-11  보고 의무 적용 시작 ← 현재 여기
2027-12-11  주요 의무 전면 적용
```

### SBOM (Software Bill of Materials)

```
"베스트프랙티스 → 사실상 요구사항"으로 이동 중

SBOM이 필요한 이유:
1. 취약점 발견 시 영향 범위 즉시 파악
2. 라이선스 컴플라이언스
3. 규제 준수 (EU CRA, US Executive Order)
4. 공급망 공격 방어

AI 시스템 SBOM에 포함할 것:
- 모델 출처와 버전 (model card)
- 학습 데이터 출처 (data card)
- 의존 라이브러리 (Python packages, npm 등)
- 외부 API 의존성 (OpenAI, Anthropic 등)
- RAG 데이터 소스
```

### AI 거버넌스 체크리스트

```
[데이터 거버넌스]
□ 학습/RAG 데이터의 출처와 라이선스 문서화
□ 개인정보 처리 동의 및 근거
□ 데이터 보존/삭제 정책
□ 데이터 접근 로그

[모델 거버넌스]
□ 모델 선택 근거 문서화 (ADR)
□ 모델 버전 관리 및 롤백 계획
□ 편향(bias) 테스트
□ 모델 성능 모니터링 (drift 감지)

[운영 거버넌스]
□ 인시던트 대응 절차
□ 변경 관리 프로세스
□ 감사 로그 보존
□ 정기 보안 리뷰

[규제 준수]
□ SBOM 생성 및 유지
□ 취약점 보고 프로세스
□ 개인정보 영향 평가 (DPIA)
□ AI 시스템 위험 분류 (EU AI Act 해당 시)
```

### SBOM 생성 도구

```bash
# Python 프로젝트
pip install cyclonedx-bom
cyclonedx-py environment -o sbom.json

# Node.js 프로젝트
npx @cyclonedx/cyclonedx-npm --output-file sbom.json

# 컨테이너
syft <image> -o cyclonedx-json > sbom.json

# 취약점 스캔
grype sbom:sbom.json
```

---

## 6. 모델/서빙 전략 — "라우팅 + 캐시 + 경량화"

### "큰 모델 1개"보다 비용/지연/안정성이 KPI

### 모델 라우팅 패턴

```
User Query
    ↓
[복잡도 분류기] ← 작은 모델 또는 규칙 기반
    │
    ├── Simple → GPT-4o-mini / Claude Haiku   (빠르고 저렴)
    ├── Medium → Claude Sonnet / GPT-4o       (균형)
    └── Complex → Claude Opus / o1            (최고 품질)
```

```python
class ModelRouter:
    """쿼리 복잡도에 따라 모델을 자동 선택"""

    ROUTING_RULES = {
        "simple": {  # 단순 조회, FAQ
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 500,
            "temperature": 0,
        },
        "medium": {  # 요약, 분석
            "model": "claude-sonnet-4-5-20250929",
            "max_tokens": 2000,
            "temperature": 0.3,
        },
        "complex": {  # 복잡한 추론, 코드 생성
            "model": "claude-opus-4-6",
            "max_tokens": 4000,
            "temperature": 0.5,
        },
    }

    async def route(self, query: str) -> dict:
        complexity = await self.classify_complexity(query)
        return self.ROUTING_RULES[complexity]
```

### 비용 최적화 전략

| 전략 | 효과 | 구현 난이도 |
|------|------|------------|
| **프롬프트 캐싱** | 입력 토큰 90% 절감 | Easy (10분) |
| **응답 캐시** (semantic) | 동일 쿼리 API 비용 0 | Easy (1일) |
| **모델 라우팅** | 평균 비용 40-60% 절감 | Medium (3일) |
| **배치 처리** | 처리량 2-5x 증가 | Medium (2일) |
| **프롬프트 압축** | 토큰 20-40% 절감 | Medium (2일) |
| **파인튜닝** | 프롬프트 길이 80% 감소 | Hard (2주+) |

### 파인튜닝 vs RAG+프롬프트 판단 기준

```
파인튜닝이 필요한 경우:
✅ 도메인 전문 용어/형식이 필수 (의료, 법률)
✅ 특정 출력 형식 강제 (JSON 스키마, 보고서 양식)
✅ 분류 작업에서 정확도가 핵심
✅ 프롬프트가 너무 길어서 비용이 과다

RAG + 프롬프트로 충분한 경우:
✅ 지식이 자주 업데이트됨
✅ 출처/근거가 필요함
✅ 다양한 태스크를 하나의 모델로 처리
✅ 빠른 반복/실험이 필요
```

> **상세:** prompt-optimizer 스킬 (프롬프트 최적화), ml-training 스킬 (학습), context-compressor 스킬 (압축)

---

## 7. AI 개발자 필수 기본기 — "채용에서 진짜 보는 것"

### 7가지 핵심 역량

```
1. 소프트웨어 엔지니어링
   - 테스트 (단위/통합/E2E)
   - 리팩토링 (안전하게, 테스트와 함께)
   - CI/CD (자동 빌드/테스트/배포)
   - 코드 리뷰 (설계/보안/성능)

2. API/백엔드
   - 인증/인가 (OAuth2, JWT, API Key)
   - Rate limiting (토큰/요청 제한)
   - 멀티테넌시 (데이터 격리, 비용 분리)
   - 비동기 처리 (큐, 이벤트, SSE)

3. 데이터 엔지니어링
   - 데이터 품질 (검증, 정규화, 중복 제거)
   - 파이프라인 (ETL/ELT, 스케줄링)
   - 스키마/메타데이터 설계
   - 데이터 버전 관리

4. 운영 (Operations)
   - SLO/SLA 정의 및 모니터링
   - 알람/온콜 설정
   - 런북 작성 및 유지
   - 장애 대응 (인시던트 관리)
   - 비용 모니터링

5. AI/ML 특화
   - 프롬프트 엔지니어링
   - RAG 파이프라인 설계
   - 임베딩/벡터 검색
   - 모델 평가 (오프라인/온라인)
   - LLM API 통합

6. 보안
   - OWASP LLM Top 10 이해
   - 프롬프트 인젝션 방어
   - 데이터 유출 방지
   - 에이전트 권한 관리

7. 거버넌스
   - AI 윤리/편향 이해
   - 규제 준수 (EU AI Act, CRA)
   - SBOM 관리
   - 감사 대응
```

### 멀티테넌시 설계 (AI 시스템 특화)

```python
# 테넌트별 데이터 격리 + 비용 추적

class TenantAwareRAG:
    """멀티테넌트 RAG 시스템"""

    async def query(self, tenant_id: str, query: str) -> Response:
        # 1. 테넌트별 데이터 격리
        namespace = f"tenant_{tenant_id}"
        results = await self.vector_db.search(
            query=query,
            namespace=namespace,  # 테넌트별 네임스페이스
        )

        # 2. 테넌트별 모델/설정
        config = await self.get_tenant_config(tenant_id)
        model = config.model  # 테넌트별 모델 선택
        system_prompt = config.system_prompt  # 테넌트별 프롬프트

        # 3. 비용 추적
        with self.cost_tracker(tenant_id):
            response = await self.llm.generate(
                model=model,
                system=system_prompt,
                context=results,
                query=query,
            )

        return response
```

### Rate Limiting (AI API 특화)

```python
# 토큰 기반 Rate Limiting (요청 수가 아닌 토큰 소비량)

from datetime import datetime, timedelta

class TokenRateLimiter:
    """토큰 소비량 기반 Rate Limiter"""

    def __init__(self, redis_client):
        self.redis = redis_client

    async def check_limit(
        self,
        tenant_id: str,
        estimated_tokens: int,
    ) -> tuple[bool, dict]:
        key = f"rate:{tenant_id}:{datetime.now().strftime('%Y%m%d%H')}"

        current = await self.redis.get(key) or 0
        limit = await self.get_tenant_limit(tenant_id)  # 예: 100K tokens/hour

        if int(current) + estimated_tokens > limit:
            return False, {
                "error": "rate_limit_exceeded",
                "limit": limit,
                "current": int(current),
                "retry_after": self.next_window_seconds(),
            }

        await self.redis.incrby(key, estimated_tokens)
        await self.redis.expire(key, 3600)

        return True, {
            "remaining": limit - int(current) - estimated_tokens,
            "reset": self.next_window_seconds(),
        }
```

---

## 우선순위 로드맵 (3단계)

### Stage 1: RAG + Tool-use MVP (2-4주)
```
□ 문서 → 청킹 → 검색 → 근거 포함 응답
□ 간단한 툴 1-2개 연결 (DB 조회, API 호출)
□ 기본 프롬프트 설계
□ 스트리밍 응답 (SSE)
□ 에러 핸들링
```

### Stage 2: Eval + Observability (2-3주)
```
□ Golden set 50개+ 구축
□ 회귀 테스트 CI 파이프라인
□ OpenTelemetry 트레이싱 설정
□ 비용/지연/품질 대시보드
□ 알람 설정 (에러율, 지연, 비용)
□ 런북 작성
```

### Stage 3: 보안 + 거버넌스 (2-3주)
```
□ OWASP LLM Top 10 기준 점검
□ 프롬프트 인젝션 방어 구현
□ MITRE ATLAS 기반 위협 모델링
□ 에이전트 권한 최소화
□ SBOM 생성 자동화
□ 취약점 보고 프로세스 수립
□ 감사 로그 구현
```

---

## 관련 스킬 참조 맵

| 영역 | 상세 스킬 |
|------|-----------|
| 아키텍처 설계 | `chatbot-designer`, `architecture-design` |
| 멀티에이전트 | `agentic-workflows` |
| RAG 구현 | `rag-2.0`, `ml-training` |
| 프롬프트 최적화 | `prompt-optimizer`, `chatbot-designer` |
| API 설계 | `api-design`, `backend-api` |
| 보안 감사 | `security-audit` |
| 평가/벤치마크 | `agent-evaluator` |
| 성능 최적화 | `performance-optimization` |
| 코드 품질 | `clean-code`, `code-review`, `tdd-workflow` |
| 기술 조사 | `ai-research-integration`, `research-agent-tech` |
| 문서화 | `documentation-gen` |
| Git/CI/CD | `git-workflow` |
