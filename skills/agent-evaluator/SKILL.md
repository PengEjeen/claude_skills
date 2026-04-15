---
name: agent-evaluator
description: AI 에이전트 및 챗봇을 자동으로 테스트하고 평가합니다. "에이전트 평가", "챗봇 테스트", "벤치마크", "성능 측정", "agent evaluation", "benchmark", "quality score" 등의 요청 시 사용합니다. 자동 테스트 데이터 생성, 다차원 성능 지표, 평가 보고서를 포함합니다.
---

# 📊 Agent 자동 평가 & 벤치마크 Skill (2026)

## 개요
에이전트와 챗봇을 자동으로 테스트하고 성능 지표를 산출하여 객관적인 평가 보고서를 생성합니다.

## 주요 기능

### 1️⃣ 자동 테스트 데이터 생성
- **합성 데이터**: LLM으로 테스트 질문 자동 생성
- **실제 데이터**: 프로덕션 로그에서 샘플링
- **Edge Cases**: 예외 상황 커버리지
- **난이도 분류**: Easy / Medium / Hard

### 2️⃣ 다차원 성능 평가
- **정확도**: Ground Truth와 비교
- **관련성**: 질문-답변 연관성
- **일관성**: 같은 질문에 동일 답변
- **환각 방지**: 근거 없는 주장 탐지
- **비용**: API 호출 비용 계산
- **속도**: 응답 시간 측정

### 3️⃣ RAG 전용 메트릭
- **Context Precision**: 검색 정확도
- **Context Recall**: 검색 재현율
- **Faithfulness**: 답변 근거 충실도
- **Answer Relevancy**: 답변 관련성

### 4️⃣ 비교 분석
- 버전 간 비교 (v1 vs v2 vs v3)
- A/B 테스트 자동화
- 통계적 유의성 검증
- 회귀 탐지 (성능 하락 감지)

---

## 사용 방법

### Case 1: 기본 평가

```bash
/agent-evaluator --target chatbot_v9 --dataset qa_100
```

**실행 과정:**
1. 테스트 데이터 로드 (100개 질문)
2. 에이전트에 순차 질의
3. 응답 수집 및 메트릭 계산
4. 보고서 생성

**출력:**
```markdown
# 📊 Agent 평가 보고서

## 테스트 정보
- **대상**: ChatBot V9 (OG-RAG)
- **데이터셋**: qa_100 (100 questions)
- **실행 시간**: 2026-01-27 21:30
- **총 소요 시간**: 8분 23초

---

## 🎯 종합 점수

| 지표 | 점수 | 등급 | 목표 |
|------|------|------|------|
| **전체 평가** | **82.3/100** | B+ | A (85+) |
| 정확도 | 87.5% | A- | 90% |
| 관련성 | 91.2% | A | 85% |
| 환각 방지 | 78.4% | B | 85% |
| 비용 효율성 | 85.0% | A- | 80% |
| 응답 속도 | 73.1% | C+ | 80% |

**주요 발견:**
- ✅ 강점: 높은 관련성, 비용 효율적
- ⚠️ 개선 필요: 환각 방지 (78.4%), 응답 속도 (2.8초)

---

## 📈 상세 메트릭

### 1. 정확도 (Accuracy): 87.5%

**정의**: Ground Truth 답변과의 일치도

**결과:**
- 정확한 답변: 63/100 (63%)
- 부분 정확: 25/100 (25%)
- 부정확: 12/100 (12%)

**오답 분석:**
```
질문 #23: "2026년 근로소득공제 한도는?"
예상: 2,000만원
실제: 1,500만원
원인: 2025년 세법 적용 (최신 정보 부족)

질문 #47: "배우자 공제액은?"
예상: 150만원
실제: 100만원
원인: 시행령 vs 시행규칙 혼동
```

**개선 방안:**
1. 2026년 세법 데이터베이스 업데이트
2. 시행령-시행규칙 구분 프롬프트 강화

---

### 2. RAG 메트릭

#### Context Precision: 0.74
**정의**: 검색된 문서 중 관련 문서 비율

| Top-K | Precision | Ideal |
|-------|-----------|-------|
| Top-1 | 0.82 | 0.90+ |
| Top-3 | 0.78 | 0.85+ |
| Top-5 | 0.74 | 0.80+ |

**분석**: Top-5에서 정확도 하락 → 불필요한 문서 포함

**개선 방안**: Reranker 적용 (예상 +10-15%p)

---

#### Context Recall: 0.68
**정의**: 관련 문서 중 검색된 비율

**결과:**
- 검색 실패: 32% (관련 문서 있지만 검색 안 됨)
- 원인 분석:
  - 유사어 미처리 (예: "공제" vs "감면")
  - 복합 질문 처리 부족 (Multi-hop)

**개선 방안**:
1. Query Expansion (동의어 추가)
2. HyDE (가상 답변 생성 후 검색)

---

#### Faithfulness: 0.81
**정의**: 답변이 검색 결과에 근거한 정도

**결과:**
- 완전 근거: 65% (좋음)
- 부분 근거: 23% (허용)
- 근거 없음: 12% (문제!) ← 환각

**환각 사례:**
```
질문: "종합소득세 신고 기한은?"
답변: "매년 6월 30일까지입니다"  ← 틀림!
검색 결과: "5월 31일" (정확)
원인: LLM 사전 지식 우선 (검색 결과 무시)
```

**개선 방안**:
```python
# Grounding 강제 프롬프트
system_prompt = """
⚠️ 경고: 제공된 법조문에만 의존하세요.
검색 결과에 없는 정보는 절대 추측하지 마세요.
불확실하면 "추가 확인 필요"라고 답변하세요.
"""
```

---

#### Answer Relevancy: 0.91
**정의**: 답변이 질문과 관련된 정도

**결과:** 우수 (목표 대비 +6%p)

**예시:**
```
질문: "프리랜서 종합소득세 계산 방법은?"
답변: "1. 사업소득금액 계산... 2. 필요경비 공제... 3. 과세표준..."
관련성: ⭐⭐⭐⭐⭐ (완벽하게 관련)
```

---

### 3. 성능 지표

#### 평균 응답 시간: 2.8초
**목표**: 2.0초 이하

**병목 분석:**
| 단계 | 시간 | 비율 |
|------|------|------|
| Query Router | 0.3초 | 11% |
| Retrieval (Vector + Graph) | 0.9초 | 32% |
| Reranking | 0.5초 | 18% |
| LLM Generation | 1.0초 | 36% |
| Post-processing | 0.1초 | 3% |

**개선 방안:**
1. Retrieval 병렬화 (Vector + Graph 동시 실행)
2. Prompt Caching (LLM 속도 +10%)
3. Haiku 모델 사용 (간단한 질문)

**예상 효과**: 2.8초 → 1.9초 (32% 개선)

---

#### API 비용: $0.0187/질문
**월 예상 비용** (10,000 질문): $187

**비용 분석:**
| 모델 | 호출 횟수 | 비용 | 비율 |
|------|-----------|------|------|
| Query Router (Haiku) | 1 | $0.0002 | 1% |
| Retrieval Eval (Haiku) | 1 | $0.0003 | 2% |
| Answer Gen (Sonnet) | 1 | $0.0180 | 96% |
| Reflection (Haiku) | 0.3 | $0.0002 | 1% |

**최적화 방안:**
1. Prompt Caching → -90% Input 토큰
2. 간단한 질문 Haiku 라우팅 → -83% 비용

**예상 절감**: $187/월 → $58/월 (69% 절감)

---

### 4. 에러 분석

#### 에러율: 3% (3/100 실패)

**에러 유형:**
```
1. Timeout (1건):
   - 질문 #56: "복잡한 다단계 계산"
   - 원인: LangGraph 무한 루프
   - 해결: Max iterations 제한

2. Parsing Error (1건):
   - 질문 #73: "법인세와 소득세 차이"
   - 원인: JSON 응답 불완전
   - 해결: Structured Output 강제

3. API Rate Limit (1건):
   - 질문 #89: 연속 호출
   - 원인: Rate limit 초과
   - 해결: Exponential backoff
```

---

## 🔥 핫스팟 분석

### 가장 느린 질문 Top 5
1. 질문 #56 (8.3초): "여러 소득 유형 통합 계산"
2. 질문 #42 (6.1초): "세법 개정 전후 비교"
3. 질문 #78 (5.9초): "복잡한 공제 조합"

**공통점**: Multi-hop 추론 필요 → Graph Traversal 병목

---

### 가장 비싼 질문 Top 5
1. 질문 #34 ($0.087): "50단계 계산 과정"
2. 질문 #67 ($0.062): "법령 전체 인용"
3. 질문 #91 ($0.055): "상세한 근거 요구"

**공통점**: 출력 토큰 과다 → Max tokens 제한 필요

---

### 환각이 많은 주제 Top 3
1. 최신 세법 개정 (2026년): 35% 환각
2. 지방세 관련: 28% 환각
3. 판례 인용: 22% 환각

**원인**: 데이터베이스에 정보 부족

**해결**: 2026년 세법 크롤링 + 지방세 DB 추가

---

## 📊 버전 비교

### V8 vs V9 성능 비교

| 지표 | V8 (Legacy) | V9 (OG-RAG) | 개선 |
|------|-------------|-------------|------|
| 정확도 | 81.2% | 87.5% | +6.3%p |
| Context Precision | 0.63 | 0.74 | +17% |
| Faithfulness | 0.72 | 0.81 | +13% |
| 평균 응답 시간 | 3.5초 | 2.8초 | -20% |
| 비용 | $0.025 | $0.019 | -24% |
| 환각율 | 18% | 12% | -33% |

**결론**: V9가 모든 지표에서 우수 ✅

---

## 🎯 개선 우선순위

### High Priority (즉시 적용)

#### 1. Reranker 적용
- **목표**: Context Precision 0.74 → 0.85
- **구현 시간**: 1-2일
- **예상 효과**: 정확도 +5-8%p

#### 2. Prompt Caching
- **목표**: 비용 -90%
- **구현 시간**: 1시간
- **예상 효과**: $187/월 → $20/월

#### 3. 2026년 세법 업데이트
- **목표**: 환각율 35% → 10%
- **구현 시간**: 2-3일
- **예상 효과**: 정확도 +3-5%p

---

### Medium Priority (1주 내)

#### 4. Query Expansion
- **목표**: Context Recall 0.68 → 0.80
- **구현 시간**: 3-4일
- **예상 효과**: 검색 실패 32% → 15%

#### 5. Retrieval 병렬화
- **목표**: 응답 시간 2.8초 → 2.0초
- **구현 시간**: 2일
- **예상 효과**: 속도 +29%

---

### Low Priority (2주 내)

#### 6. Multi-Agent 구조
- **목표**: 복잡한 질문 처리 개선
- **구현 시간**: 1-2주
- **예상 효과**: 난제 정확도 +15%

---

## 📁 결과 저장

### 생성되는 파일
```
docs/evaluation/
├── chatbot_v9_report_2026-01-27.md       # 종합 보고서
├── chatbot_v9_metrics.json               # 메트릭 (JSON)
├── chatbot_v9_errors.csv                 # 에러 로그
├── chatbot_v9_slow_queries.csv           # 느린 질문
├── chatbot_v9_hallucinations.csv         # 환각 사례
└── chatbot_v9_comparison.png             # 버전 비교 차트
```

### JSON 출력 예시
```json
{
  "metadata": {
    "target": "chatbot_v9",
    "dataset": "qa_100",
    "timestamp": "2026-01-27T21:30:00Z",
    "duration_seconds": 503
  },
  "overall_score": 82.3,
  "metrics": {
    "accuracy": 0.875,
    "context_precision": 0.74,
    "context_recall": 0.68,
    "faithfulness": 0.81,
    "answer_relevancy": 0.91,
    "avg_response_time": 2.8,
    "avg_cost": 0.0187,
    "error_rate": 0.03,
    "hallucination_rate": 0.12
  },
  "distribution": {
    "difficulty": {
      "easy": {"count": 40, "accuracy": 0.95},
      "medium": {"count": 45, "accuracy": 0.87},
      "hard": {"count": 15, "accuracy": 0.67}
    }
  },
  "errors": [
    {
      "question_id": 56,
      "type": "timeout",
      "message": "Max iterations exceeded"
    }
  ]
}
```

---

## 🧪 테스트 데이터 생성

### 자동 생성 (LLM 사용)

```bash
/agent-evaluator --generate-dataset --topic "종합소득세" --count 50
```

**생성 예시:**
```json
[
  {
    "id": 1,
    "question": "2026년 종합소득세 최고 세율은?",
    "ground_truth": "45% (과세표준 10억원 초과)",
    "difficulty": "easy",
    "category": "tax_rate",
    "requires_retrieval": true
  },
  {
    "id": 2,
    "question": "프리랜서의 필요경비율은?",
    "ground_truth": "업종에 따라 다름. 인적용역 60-80%, 기타 30-50%",
    "difficulty": "medium",
    "category": "deduction",
    "requires_retrieval": true
  },
  {
    "id": 3,
    "question": "사업소득과 근로소득을 모두 받는 경우 종합소득세 계산 방법은?",
    "ground_truth": "1. 각 소득금액 합산 2. 종합소득공제 적용 3. 과세표준 계산 4. 세액 계산",
    "difficulty": "hard",
    "category": "calculation",
    "requires_retrieval": true
  }
]
```

---

## 🔄 지속적 모니터링

### CI/CD 통합

```yaml
# .github/workflows/agent-eval.yml
name: Agent Evaluation

on:
  pull_request:
    paths:
      - 'src/ontology/**'
      - 'src/prompts/**'
      - 'backend/routes/og_rag/**'

jobs:
  evaluate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Evaluation
        run: |
          /agent-evaluator --dataset qa_smoke_test --threshold 85
      - name: Comment PR
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              body: '## 🤖 Agent Evaluation\n\n' + results
            })
```

**효과**:
- PR마다 자동 평가
- 성능 회귀 자동 탐지
- 배포 전 품질 검증

---

## 📊 대시보드

### Grafana 통합

```python
# backend/monitoring/metrics.py
from prometheus_client import Histogram, Counter

agent_response_time = Histogram(
    'agent_response_seconds',
    'Agent response time'
)

agent_accuracy = Counter(
    'agent_accuracy_total',
    'Agent accuracy count',
    ['is_correct']
)

@agent_response_time.time()
def handle_query(query: str):
    result = agent.run(query)

    # 정확도 추적
    is_correct = evaluate(result)
    agent_accuracy.labels(is_correct=is_correct).inc()

    return result
```

**Grafana 대시보드:**
- 실시간 정확도 추이
- P50/P90/P99 응답 시간
- 에러율 모니터링
- 비용 추적

---

## 🎓 벤치마크 비교

### 외부 벤치마크

| 벤치마크 | 우리 점수 | SOTA | 평균 |
|----------|-----------|------|------|
| **BEIR (Retrieval)** | 0.68 | 0.75 | 0.52 |
| **RAGAS (RAG)** | 0.81 | 0.88 | 0.65 |
| **TruthfulQA (환각)** | 0.88 | 0.92 | 0.78 |

**분석**:
- Retrieval: 평균 이상, SOTA 대비 -9%
- RAG 전체: 평균 대비 +25%, 우수
- 환각 방지: 평균 대비 +13%, 우수

**개선 목표**: Retrieval을 SOTA 수준으로 (Reranker 적용)

---

## 💡 사용 팁

### 1. 빠른 테스트 (개발 중)
```bash
/agent-evaluator --quick --count 10
# 10개 질문으로 빠르게 테스트 (1분)
```

### 2. 특정 주제만
```bash
/agent-evaluator --filter "category:tax_rate"
# 세율 관련 질문만 테스트
```

### 3. 회귀 테스트
```bash
/agent-evaluator --compare-with v8
# 이전 버전과 비교
```

### 4. 실시간 모니터링
```bash
/agent-evaluator --watch --interval 1h
# 1시간마다 자동 평가
```

---

## 🎯 목표 설정 예시

```yaml
# evaluation_config.yml
targets:
  accuracy: 90%
  context_precision: 0.85
  context_recall: 0.80
  faithfulness: 0.90
  answer_relevancy: 0.88
  avg_response_time: 2.0s
  avg_cost: $0.015
  error_rate: <1%
  hallucination_rate: <8%

alerts:
  - metric: accuracy
    threshold: 85%
    action: slack_notify
  - metric: error_rate
    threshold: 5%
    action: pagerduty
```

---

## 📚 참고 메트릭 설명

### RAGAS Framework
- **Context Precision**: 검색 정확도
- **Context Recall**: 검색 재현율
- **Faithfulness**: 답변 근거 충실도
- **Answer Relevancy**: 답변 관련성

### 추가 메트릭
- **Latency P50/P90/P99**: 응답 시간 분포
- **Token Efficiency**: 출력 토큰/품질 비율
- **Hallucination Rate**: 환각 비율
- **User Satisfaction**: 사용자 만족도 (피드백 기반)
