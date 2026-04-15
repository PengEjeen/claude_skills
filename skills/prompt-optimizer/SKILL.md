---
name: prompt-optimizer
description: 프롬프트 엔지니어링과 LangGraph 구성을 자동 최적화합니다. "프롬프트 최적화", "프롬프트 개선", "LangGraph", "프롬프트 튜닝", "prompt optimization", "prompt tuning", "LangGraph optimization" 등의 요청 시 사용합니다. 성능, 비용, 속도 측면에서 프롬프트를 개선합니다.
---

# 🎯 Prompt & LangGraph Optimizer (2026)

## 개요
프롬프트 엔지니어링과 LangGraph 구성을 자동으로 최적화하여 성능, 비용, 속도를 개선합니다.

## 주요 기능

### 1️⃣ Prompt 자동 최적화
- **토큰 압축**: 의미 유지하면서 길이 20-40% 감소
- **명확성 개선**: 모호한 표현 제거, 구체적 지시사항 추가
- **Few-shot 자동 생성**: 예제 자동 선별 및 추가
- **A/B 테스트**: 여러 버전 비교 및 최적 선택

### 2️⃣ LangGraph 구조 분석
- **노드 효율성 분석**: 불필요한 노드 탐지
- **병렬화 가능성 검토**: 순차 실행을 병렬로 전환
- **에러 핸들링 개선**: Retry 로직, Fallback 추가
- **상태 관리 최적화**: 불필요한 상태 제거

### 3️⃣ 비용 최적화
- **모델 선택 자동화**: Haiku vs Sonnet vs Opus 비교
- **Prompt Caching 적용**: 재사용 가능한 부분 캐싱
- **Batch 처리**: 가능한 요청 묶음 처리

### 4️⃣ 성능 프로파일링
- **노드별 실행 시간**: 병목 지점 탐지
- **토큰 사용량 추적**: 노드별 input/output 토큰
- **비용 분석**: API 호출당 비용 계산

---

## 사용 방법

### Case 1: Prompt 최적화

```bash
/prompt-optimizer --file src/prompts/templates/tax_expert_system.txt
```

**분석 결과:**
```markdown
# 🎯 Prompt 최적화 보고서

## 현재 프롬프트 분석

**파일**: `src/prompts/templates/tax_expert_system.txt`
**토큰 수**: 487 tokens
**예상 비용** (1,000회 호출):
- Input: $1.46 (Claude 3.5 Sonnet)
- **Caching 가능**: $0.15 (90% 절감)

---

## 🔍 발견된 문제점

### 1. 중복 표현 (토큰 낭비)
```diff
- 당신은 대한민국 국세청 기준 세무 전문가입니다.
- 2026년 현재 시행 중인 세법을 기준으로 정확하게 답변합니다.
+ 당신은 2026년 대한민국 세법 기준 세무 전문가입니다.
```
**절감**: 8 tokens (-1.6%)

### 2. 모호한 지시사항
```diff
- 구체적 금액 계산 시 산출 과정 단계별 표시
+ 금액 계산 시 반드시 다음 형식 사용:
  1. 과세표준: 50,000,000원
  2. 적용 세율: 24%
  3. 산출세액: 50,000,000 × 0.24 - 576만원 = 6,240,000원
```
**효과**: 계산 오류 50% 감소 (실험 결과)

### 3. Few-shot 예제 부족
**추천**: 2-3개 예제 추가
```
【예제 1: 사업소득 계산】
질문: 연 매출 8,000만원, 필요경비 3,000만원인 경우 종합소득세는?

답변:
1. 사업소득금액: 8,000만원 - 3,000만원 = 5,000만원
2. 과세표준 (소득공제 없음 가정): 5,000만원
3. 산출세액: 5,000만원 × 0.24 - 576만원 = 624만원
4. 지방소득세: 62.4만원
5. 총 납부세액: 686.4만원

근거: 「소득세법」 제55조 (2026년 기준)
```
**효과**: 형식 준수율 90% → 98%

---

## ✨ 최적화된 버전

### Version A (토큰 최소화)
- **목표**: 비용 절감
- **토큰**: 487 → 389 (-20%)
- **명확성**: 유지
- **추천 상황**: API 호출 빈도 높을 때

### Version B (정확도 우선)
- **목표**: 성능 향상
- **토큰**: 487 → 612 (+26%)
- **Few-shot 예제**: 3개 추가
- **추천 상황**: 복잡한 계산 많을 때

### Version C (균형)
- **목표**: 비용-성능 밸런스
- **토큰**: 487 → 445 (-9%)
- **개선 사항**: 중복 제거 + 명확성 개선
- **추천**: ⭐ 기본 권장

---

## 📊 A/B 테스트 결과 (100개 질문)

| 버전 | 정확도 | 비용 | 평균 응답 시간 | 형식 준수율 |
|------|--------|------|----------------|-------------|
| 현재 | 87% | $0.146 | 2.3초 | 92% |
| Ver A | 85% | $0.117 | 2.1초 | 90% |
| Ver B | 94% | $0.183 | 2.5초 | 98% |
| Ver C | 91% | $0.133 | 2.2초 | 96% |

**추천**: Version C (정확도 +4%, 비용 -9%)

---

## 🚀 즉시 적용 가능한 개선

### 1. Prompt Caching 설정
```python
# backend/routes/og_rag/generation.py
response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    system=[{
        "type": "text",
        "text": system_prompt,
        "cache_control": {"type": "ephemeral"}  # ← 추가
    }],
    messages=[...]
)
```
**예상 절감**: 월 $380 → $50 (87% 절감)

### 2. 모델 선택 최적화
```python
# 간단한 질문 (30% of queries)
model = "claude-3-haiku-20240307"  # $0.25/1M tokens

# 복잡한 질문 (70% of queries)
model = "claude-3-5-sonnet-20241022"  # $3/1M tokens
```
**예상 절감**: 평균 비용 40% 감소

### 3. 구조화된 출력 강제
```python
response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    response_format={"type": "json_object"},  # ← JSON 강제
    messages=[...]
)
```
**효과**: 파싱 에러 0%, 재시도 불필요

---

## 💾 저장 옵션

```bash
# 최적화된 버전 저장
/prompt-optimizer --save version_c

# 결과:
# - src/prompts/templates/tax_expert_system.txt (백업)
# - src/prompts/templates/tax_expert_system_v2.txt (최적화 버전)
# - docs/optimization/tax_expert_system_report.md (보고서)
```
```

---

### Case 2: LangGraph 구조 최적화

```bash
/prompt-optimizer --langgraph src/multi_excel/graph.py
```

**분석 결과:**
```markdown
# 🧩 LangGraph 최적화 보고서

## 현재 그래프 분석

**파일**: `src/multi_excel/graph.py`
**노드 수**: 6개
**총 실행 시간**: 평균 12.3초
**병렬 처리**: 2/6 노드만 병렬

---

## 📊 노드별 성능 프로파일

| 노드 | 평균 시간 | 토큰 사용 | 비용 | 병목? |
|------|-----------|-----------|------|-------|
| parse_files | 1.2초 | 0 | $0 | ✅ |
| analyze_sheets | 4.5초 | 3,200 | $0.0096 | ⚠️ |
| validate | 2.1초 | 1,500 | $0.0045 | ✅ |
| synthesize | 3.8초 | 2,800 | $0.0084 | ⚠️ |
| extract_company | 0.7초 | 800 | $0.0024 | ✅ |
| **Total** | **12.3초** | **8,300** | **$0.0249** | |

**병목 지점**: analyze_sheets (37%), synthesize (31%)

---

## 🔍 발견된 문제점

### 1. 순차 실행 (병렬화 가능)

**현재:**
```python
# 순차 실행 (느림)
result = graph.invoke({
    "files": files,
    "processing_status": "parsing"
})
# parse → analyze → validate → synthesize (순차)
```

**개선안:**
```python
# 병렬 실행 (빠름)
from langgraph.pregel import Send

def route_to_parallel(state):
    # 각 파일을 독립적으로 처리
    return [
        Send("analyze_file", {"file": file})
        for file in state["files"]
    ]

graph = StateGraph(MultiExcelState)
graph.add_node("parse_files", parse_files_node)
graph.add_node("analyze_file", analyze_single_file)  # 병렬
graph.add_conditional_edges("parse_files", route_to_parallel)
```

**예상 효과**:
- 3개 파일: 12.3초 → 5.8초 (53% 개선)
- 5개 파일: 19.2초 → 6.1초 (68% 개선)

---

### 2. 불필요한 LLM 호출

**현재:**
```python
# analyze_sheets_node에서 모든 시트에 LLM 호출
for sheet in file.sheets:
    sheet_type = llm.classify(sheet)  # LLM 호출 (느림)
```

**개선안:**
```python
# Rule-based + LLM Fallback
for sheet in file.sheets:
    # 1. 빠른 규칙 기반 분류 시도
    sheet_type = rule_based_classifier(sheet)

    # 2. 불확실한 경우만 LLM 호출
    if sheet_type == "unknown":
        sheet_type = llm.classify(sheet)
```

**예상 효과**:
- LLM 호출: 100% → 20% (80% 감소)
- 비용: $0.025 → $0.008 (68% 절감)
- 시간: 4.5초 → 1.2초 (73% 개선)

---

### 3. 중복 검증 (validate 노드)

**현재:**
```python
# 모든 파일/시트를 다시 검증
def validate_node(state):
    for file in state["files"]:
        for sheet in file.sheets:
            validate_sheet(sheet)  # 중복 작업
```

**개선안:**
```python
# analyze 단계에서 검증도 함께
def analyze_sheets_node(state):
    for sheet in file.sheets:
        sheet.data = extract_data(sheet)
        sheet.validation_status = validate_inline(sheet.data)  # 동시에
```

**예상 효과**:
- 노드 제거: 6개 → 5개
- 시간: 2.1초 절약
- 코드 복잡도: 감소

---

## ✨ 최적화된 그래프 구조

### Before (순차)
```
START → parse → analyze → validate → synthesize → END
         1.2s    4.5s      2.1s       3.8s        = 12.3s
```

### After (병렬 + 통합)
```
START → parse → [analyze_file1, analyze_file2, analyze_file3] → synthesize → END
         1.2s           2.3s (병렬)                               2.1s      = 5.6s
```

**개선율**: 54% 빨라짐

---

## 🎯 구현 계획

### Step 1: 파일별 병렬 처리 (우선순위: High)
```python
# src/multi_excel/graph.py
def create_parallel_graph():
    graph = StateGraph(MultiExcelState)

    # 노드 정의
    graph.add_node("parse_files", parse_files_node)
    graph.add_node("analyze_file", analyze_single_file_node)
    graph.add_node("synthesize", synthesize_node)

    # 엣지: parse 후 각 파일로 분산 (Send API)
    graph.add_conditional_edges(
        "parse_files",
        lambda state: [
            Send("analyze_file", {"file": f})
            for f in state["files"]
        ]
    )

    # 모든 analyze_file 완료 후 synthesize
    graph.add_edge("analyze_file", "synthesize")
    graph.add_edge("synthesize", END)

    return graph.compile()
```

**예상 시간**: 2-3시간
**예상 효과**: 50-70% 속도 개선

---

### Step 2: Rule-based Classifier (우선순위: Medium)
```python
# src/multi_excel/utils/sheet_classifier.py
def rule_based_classify(sheet_name: str, data: dict) -> str:
    """빠른 규칙 기반 분류"""
    name_lower = sheet_name.lower()

    # 키워드 매칭
    if any(k in name_lower for k in ["손익", "income", "pl"]):
        return "income_statement"
    elif any(k in name_lower for k in ["재무상태", "balance", "bs"]):
        return "balance_sheet"
    elif any(k in data.keys() for k in ["매출액", "영업이익"]):
        return "income_statement"

    return "unknown"  # LLM 호출 필요
```

**예상 시간**: 1-2시간
**예상 효과**: 비용 70% 절감

---

### Step 3: Analyze + Validate 통합 (우선순위: Low)
```python
# src/multi_excel/agents/analyzer.py
def analyze_with_validation(sheet: SheetData) -> SheetData:
    """분석과 검증을 동시에"""
    # 1. 데이터 추출
    sheet.data = extract_financial_data(sheet.raw_data)

    # 2. 동시에 검증
    sheet.validation_errors = validate_data(sheet.data)
    sheet.validation_status = "valid" if not sheet.validation_errors else "invalid"

    return sheet
```

**예상 시간**: 1시간
**예상 효과**: 2초 절약 + 코드 간결화

---

## 📊 최적화 전후 비교

### 성능 지표
| 지표 | Before | After | 개선 |
|------|--------|-------|------|
| **평균 처리 시간 (3 파일)** | 12.3초 | 5.6초 | -54% |
| **평균 처리 시간 (5 파일)** | 19.2초 | 6.1초 | -68% |
| **토큰 사용** | 8,300 | 2,500 | -70% |
| **비용** | $0.025 | $0.008 | -68% |
| **LLM 호출 횟수** | 15회 | 3회 | -80% |

### 비용 절감 (월 1,000 요청 기준)
- Before: $25/월
- After: $8/월
- **절감**: $17/월 (68%)

---

## 🔧 추가 최적화 옵션

### 1. Streaming 지원
```python
# 중간 결과를 실시간으로 반환
async for chunk in graph.astream(state):
    if chunk.get("processing_status"):
        await websocket.send_json({
            "status": chunk["processing_status"],
            "progress": chunk["progress_percent"]
        })
```

**효과**: UX 개선 (사용자가 진행 상황 확인)

---

### 2. Checkpointing (장애 복구)
```python
# 노드 실행 결과 저장
graph = create_graph().compile(
    checkpointer=MemorySaver()  # 또는 PostgresSaver
)

# 실패 시 마지막 체크포인트부터 재개
result = graph.invoke(state, config={
    "configurable": {"thread_id": session_id}
})
```

**효과**: 신뢰성 향상 (실패 시 처음부터 재시작 불필요)

---

### 3. 모델 선택 자동화
```python
def select_model(sheet_complexity: str) -> str:
    """시트 복잡도에 따라 모델 선택"""
    if sheet_complexity == "simple":
        return "claude-3-haiku-20240307"  # 빠르고 저렴
    elif sheet_complexity == "medium":
        return "claude-3-5-sonnet-20241022"  # 균형
    else:
        return "claude-opus-4-20250514"  # 정확도 최우선
```

**효과**: 비용-성능 최적화

---

## 💾 최적화 결과 저장

```bash
# 최적화된 그래프 저장
/prompt-optimizer --save optimized_graph

# 결과:
# - src/multi_excel/graph.py (백업)
# - src/multi_excel/graph_v2.py (최적화 버전)
# - docs/optimization/multi_excel_graph_report.md (보고서)
```
```

---

### Case 3: 자동 Few-shot 생성

```bash
/prompt-optimizer --generate-examples --task "재무제표 분석"
```

**출력:**
```markdown
# 🎓 Few-shot 예제 자동 생성

## 태스크: 재무제표 분석

### 예제 1: 손익계산서 기본 분석
```json
{
  "input": {
    "sheet_name": "손익계산서",
    "data": {
      "매출액": 150000000,
      "매출원가": 80000000,
      "판매관리비": 30000000
    }
  },
  "output": {
    "sheet_type": "income_statement",
    "key_metrics": {
      "매출액": 150000000,
      "매출원가": 80000000,
      "매출총이익": 70000000,
      "영업이익": 40000000,
      "매출총이익률": 46.67,
      "영업이익률": 26.67
    },
    "analysis": "매출총이익률 46.67%, 영업이익률 26.67%로 건전한 수익구조"
  }
}
```

### 예제 2: 재무상태표 기본 분석
```json
{
  "input": {
    "sheet_name": "재무상태표",
    "data": {
      "자산총계": 500000000,
      "부채총계": 200000000,
      "자본총계": 300000000
    }
  },
  "output": {
    "sheet_type": "balance_sheet",
    "key_metrics": {
      "자산총계": 500000000,
      "부채총계": 200000000,
      "자본총계": 300000000,
      "부채비율": 66.67,
      "자기자본비율": 60.00
    },
    "analysis": "부채비율 66.67%, 안정적인 재무구조"
  }
}
```

### 예제 3: 비정형 데이터 (Unknown)
```json
{
  "input": {
    "sheet_name": "메모",
    "data": {
      "비고": "2026년 사업 계획",
      "담당자": "홍길동"
    }
  },
  "output": {
    "sheet_type": "unknown",
    "key_metrics": {},
    "analysis": "재무 데이터가 아님"
  }
}
```

---

## 📥 프롬프트 적용

### Before (Few-shot 없음)
```python
prompt = "다음 시트 데이터를 분석하세요: {data}"
```
**정확도**: 82%

### After (Few-shot 3개 추가)
```python
prompt = """
다음 예제를 참고하여 시트 데이터를 분석하세요:

[예제 1]
입력: ...
출력: ...

[예제 2]
입력: ...
출력: ...

[예제 3]
입력: ...
출력: ...

이제 다음 데이터를 분석하세요:
{data}
"""
```
**정확도**: 94% (+12%p)

---

## 💡 적용 방법

```python
# src/multi_excel/agents/sheet_analyzer.py
FEW_SHOT_EXAMPLES = load_template("sheet_analysis_examples.txt")

def analyze_sheet(sheet: SheetData) -> SheetData:
    prompt = f"""
{FEW_SHOT_EXAMPLES}

실제 데이터:
{sheet.to_dict()}
"""
    result = llm.generate(prompt)
    return result
```
```

---

## 핵심 기능

### 1. Prompt 분석
- 토큰 수 계산
- 중복 표현 탐지
- 모호한 지시사항 발견
- 구조 개선 제안

### 2. LangGraph 프로파일링
- 노드별 실행 시간
- 병렬화 가능성 분석
- 불필요한 노드 탐지
- 상태 크기 최적화

### 3. 비용 분석
- 토큰 사용량 추적
- 모델별 비용 비교
- 캐싱 효과 예측
- ROI 계산

### 4. A/B 테스트
- 여러 버전 자동 생성
- 100개 질문으로 테스트
- 정확도, 비용, 속도 비교
- 최적 버전 추천

---

## 출력 형식

1. **분석 보고서** (Markdown)
2. **최적화된 파일** (백업 + 새 버전)
3. **성능 비교표** (Before/After)
4. **구현 가이드** (단계별 코드)

---

## 자동화 옵션

```bash
# CI/CD에 통합
/prompt-optimizer --auto --threshold 10%

# 10% 이상 개선 시 자동으로 PR 생성
```
