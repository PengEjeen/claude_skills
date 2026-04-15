---
name: product-planner
description: 20년 시니어 PM 수준의 제품 기획을 자동화합니다. "제품 기획", "PRD 작성", "로드맵", "시장 조사", "경쟁 분석", "비즈니스 모델", "product planning", "PRD", "roadmap", "market research" 등의 요청 시 사용합니다. TAM/SAM/SOM, JTBD, RICE, Lean Canvas 프레임워크를 포함합니다.
---

# 🎯 Product Planner Skill (20-Year Senior PM)

**World-Class Product Planning Automation**

> **English Summary:** AI-powered product planning assistant with 20-year senior PM expertise. Automatically conducts market research, competitor analysis, business model validation, PRD writing, and roadmap creation for any domain. Supports multi-domain classification, TAM/SAM/SOM calculation, and comprehensive PM frameworks (JTBD, RICE, Lean Canvas).

---

**세계적 수준의 제품 기획 자동화 스킬**

## 개요

20년차 시니어 PM의 전문성을 구현한 AI 기획 도우미입니다. 사용자가 어떤 도메인에서든 아이디어를 제시하면, 자동으로:
- 도메인 파악 및 시장 조사
- 경쟁사 분석 및 벤치마킹
- 비즈니스 모델 검증
- PRD 작성 및 요구사항 정의
- 우선순위 결정 및 로드맵 생성

## 핵심 철학

> "Good products solve problems. Great products anticipate needs."
> - 20년차 PM의 통찰력으로 문제의 본질을 파악하고 혁신적 솔루션을 제시

### PM 마인드셋

1. **고객 중심 (Customer-Centric)**
   - 사용자 페인 포인트 깊이 이해
   - Jobs-to-be-Done 프레임워크 적용
   - 페르소나 기반 의사결정

2. **데이터 기반 (Data-Driven)**
   - 시장 규모 및 성장률 분석
   - 경쟁사 포지셔닝 정량화
   - 가설 검증 프레임워크

3. **실행 가능성 (Feasibility)**
   - 기술적 실현 가능성
   - 비즈니스 모델 지속가능성
   - Go-to-Market 전략

## 사용 방법

### 기본 사용

```bash
/product-planner "숏폼 영상 기반 온라인 교육 플랫폼"
```

**자동 실행 프로세스:**
1. 도메인 인식 (EdTech, Video Platform)
2. 시장 조사 (TAM/SAM/SOM 계산)
3. 경쟁사 분석 (YouTube Shorts, TikTok, Coursera)
4. 아이디어 평가 (RICE Score)
5. PRD 생성
6. 로드맵 수립

### 고급 옵션

```bash
# 특정 PM 프레임워크 지정
/product-planner --framework jobs-to-be-done "AI 기반 재무 상담 챗봇"

# 시장 조사 심화
/product-planner --deep-market-research "B2B SaaS 인사관리 솔루션"

# 경쟁사 비교 중점
/product-planner --competitive-analysis "배달 음식 앱"

# Lean Canvas 생성
/product-planner --lean-canvas "구독형 헬스케어 서비스"
```

---

## 1. 도메인 자동 인식 & 시장 조사

### 1.1 도메인 분류 체계

사용자 입력 → 자동 도메인 매핑:

| 입력 예시 | 인식 도메인 | 서브 카테고리 |
|-----------|-------------|---------------|
| "온라인 교육 플랫폼" | EdTech | MOOC, Video Learning |
| "배달 음식 앱" | FoodTech | Delivery, Aggregator |
| "AI 챗봇" | AI/ML | Conversational AI, SaaS |
| "헬스케어 앱" | HealthTech | mHealth, Telemedicine |
| "핀테크 앱" | FinTech | Payments, Lending |
| "부동산 중개" | PropTech | Marketplace, CRM |
| "HR 솔루션" | HRTech | Recruiting, Payroll |

### 1.2 시장 조사 자동화

**TAM (Total Addressable Market) 계산:**

```python
# 자동 계산 예시: "숏폼 영상 교육 플랫폼"

도메인: EdTech + Video Platform
지역: 글로벌 (우선 한국)

TAM 계산:
- 전 세계 온라인 교육 시장: $350B (2026)
- 동영상 기반 교육 비중: 45%
- TAM = $350B × 45% = $157.5B

SAM (Serviceable Addressable Market):
- 한국 온라인 교육 시장: $8.5B
- 숏폼 콘텐츠 소비층 (15-35세): 60%
- SAM = $8.5B × 60% = $5.1B

SOM (Serviceable Obtainable Market):
- 초기 3년 목표 시장 점유율: 3%
- SOM = $5.1B × 3% = $153M (≈ 2,000억원)

성장률 (CAGR 2024-2028):
- 온라인 교육: 12.3%
- 숏폼 비디오: 28.7%
- 예상 복합 성장률: 18-22%
```

**시장 트렌드 분석:**

```markdown
## 2026년 EdTech + Video 시장 트렌드

### 거시적 트렌드
1. **숏폼 콘텐츠 폭발적 성장**
   - TikTok: 10억 MAU, 평균 시청 시간 95분/일
   - YouTube Shorts: 500억 조회/일 (2026 Q1)
   - 사용자들의 주의 집중 시간 감소 → 5분 이하 콘텐츠 선호

2. **AI 개인화 학습**
   - ChatGPT Tutor 모드 출시 (2025)
   - 개인 맞춤형 커리큘럼 자동 생성
   - 학습 속도 실시간 조정

3. **마이크로 러닝 (Micro-learning)**
   - 하루 10분 학습 트렌드
   - 출퇴근 시간 활용 교육
   - 완강률 70% (기존 MOOC 15%)

### 소비자 행동 변화
- Z세대(15-25세): 텍스트보다 비디오 선호 (85%)
- 직장인(26-40세): 스킬 업스킬링 수요 증가
- 시니어(50+): 디지털 리터러시 교육 폭증

### 기술 발전
- 5G 보급률 95% (한국 기준)
- AR/VR 교육 콘텐츠 등장
- AI 음성 번역 (다국어 자막 실시간 생성)
```

---

## 2. 경쟁사 분석 (Competitive Analysis)

### 2.1 경쟁 구도 매핑

**자동 생성 예시:**

```markdown
## 숏폼 영상 교육 - 경쟁 지형도

### 직접 경쟁사 (Direct Competitors)

#### 1. Brilliant (미국, $100M 펀딩)
**포지셔닝:** 인터랙티브 STEM 교육
**강점:**
- 게임화된 학습 경험
- 일일 5-10분 마이크로 레슨
- 퀴즈 기반 학습 검증

**약점:**
- 숏폼 비디오 미지원 (텍스트/애니메이션)
- STEM 외 분야 부족
- 한국어 미지원

**MAU:** 1,200만 (글로벌)
**가격:** $12.99/월
**완강률:** 68%

---

#### 2. Reforge (미국, 프리미엄 교육)
**포지셔닝:** 시니어 직군 대상 코호트 학습
**강점:**
- 업계 최고 전문가 강의
- 또래 학습 (Cohort-based)
- 네트워킹 기회

**약점:**
- 고가 ($2,000-4,000/코스)
- 숏폼 아님 (2-4시간 세션)
- B2C 대중화 어려움

**MAU:** 50만
**가격:** $2,500/코스
**완강률:** 82%

---

### 간접 경쟁사 (Indirect Competitors)

#### 3. YouTube Shorts (교육 채널들)
**강점:**
- 무료, 방대한 콘텐츠
- 알고리즘 추천
- 글로벌 도달

**약점:**
- 체계적 커리큘럼 부재
- 품질 관리 어려움
- 수료증 없음

**DAU:** 20억+ (Shorts 전체)
**교육 콘텐츠 비중:** 18%

---

#### 4. Udemy (기존 MOOC)
**강점:**
- 20만+ 코스
- 저렴한 가격 ($10-50)
- B2B 시장 진출 (Udemy Business)

**약점:**
- 긴 강의 시간 (평균 8시간/코스)
- 완강률 낮음 (15%)
- 숏폼 트렌드 미대응

**MAU:** 6,400만
**가격:** $10-50/코스
**완강률:** 15%

---

### 경쟁 우위 분석 (Competitive Advantage Matrix)

| 요소 | Brilliant | Reforge | YouTube Shorts | Udemy | **우리 제품** |
|------|-----------|---------|----------------|-------|---------------|
| 숏폼 포맷 | ❌ | ❌ | ✅ | ❌ | ✅ |
| 체계적 커리큘럼 | ✅ | ✅ | ❌ | ✅ | ✅ |
| 완강률 | 68% | 82% | N/A | 15% | **70% 목표** |
| 가격 경쟁력 | $ | $$$ | Free | $ | $$ |
| AI 개인화 | ⭐⭐⭐ | ⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| 한국 시장 | ❌ | ❌ | ✅ | ✅ | ✅ |
| 수료증 | ✅ | ✅ | ❌ | ✅ | ✅ |
| 커뮤니티 | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |

### 전략적 포지셔닝

```
고가 (Premium)
      ↑
      │         Reforge
      │         (코호트)
      │
      │
가격  │  Brilliant        [우리 제품]
      │  (인터랙티브)     (숏폼+AI)
      │
      │         Udemy             YouTube
      │        (MOOC)             (무료)
      │
저가  └─────────────────────────────────→
      짧은 콘텐츠         긴 콘텐츠
         시간
```

**우리의 독보적 위치:**
- 숏폼 + 체계적 커리큘럼 + AI 개인화 (3가지 모두 갖춤)
- 중간 가격대 ($15-20/월) - 가성비 최고
- 한국 시장 특화 (한국어, 한국 문화)
```

---

## 3. PM 프레임워크 적용

### 3.1 Jobs-to-be-Done (JTBD)

**사용자가 진짜 원하는 것:**

```markdown
## JTBD 분석: 숏폼 영상 교육 플랫폼

### Job Statement
"When I **[상황]**,
I want to **[동기]**,
So I can **[결과]**."

### 페르소나 1: 직장인 김철수 (29세, 마케터)
**상황:** 점심시간이나 출퇴근 시간 (하루 30분)
**동기:** 데이터 분석 스킬을 빠르게 배우고 싶다
**결과:** 다음 프로젝트에서 바로 써먹을 수 있다

**기존 솔루션 문제점:**
- Udemy: 8시간 강의를 언제 다 봐? (완강 실패)
- YouTube: 검색해도 체계적이지 않음
- 책: 읽을 시간 없음

**우리의 솔루션:**
- ✅ 5분 영상 × 6개 = 하루 30분 완강
- ✅ AI가 추천하는 순서대로 학습
- ✅ 다음 날 복습 퀴즈로 정착

---

### 페르소나 2: 대학생 이영희 (21세, 경영학과)
**상황:** 취업 준비, 스펙 쌓기 (매일 1-2시간)
**동기:** 포트폴리오에 넣을 수료증 따기
**결과:** 실무 스킬 어필하여 대기업 합격

**기존 솔루션 문제점:**
- Coursera: 너무 이론적, 실무와 거리 있음
- YouTube: 수료증 없음
- 부트캠프: 비싸고 시간 맞추기 어려움

**우리의 솔루션:**
- ✅ 프로젝트 기반 학습 (포트폴리오 자동 생성)
- ✅ 수료증 + LinkedIn 인증
- ✅ 월 $15 (부트캠프 대비 1/100 가격)

---

### 페르소나 3: 시니어 박영수 (55세, 자영업)
**상황:** 디지털 전환 필요성 느낌 (주 3회, 30분씩)
**동기:** 유튜브 채널 운영, 온라인 마케팅 배우기
**결과:** 매출 20% 증가

**기존 솔루션 문제점:**
- Udemy: 용어가 어려워서 포기
- YouTube: 뭐부터 봐야 할지 모름
- 학원: 부끄럽고 비쌈

**우리의 솔루션:**
- ✅ 시니어 친화적 UI (큰 글씨, 간단한 용어)
- ✅ 기초부터 단계별 커리큘럼
- ✅ 1:1 질문 채팅봇 (AI 튜터)
```

### 3.2 Value Proposition Canvas

```markdown
## Value Proposition Canvas

### Customer Jobs (고객이 해결하려는 일)
1. **기능적 Jobs**
   - 새로운 스킬 빠르게 습득
   - 바쁜 일상에서 짬내서 학습
   - 실무에 바로 적용 가능한 지식

2. **사회적 Jobs**
   - 동료보다 앞서 나가기
   - 이력서에 쓸 수료증
   - 자기계발하는 이미지

3. **감정적 Jobs**
   - 성취감 느끼기
   - 뒤처지지 않았다는 안심
   - 새로운 것 배우는 즐거움

### Pains (고통)
- 😫 긴 강의는 지루하고 완강 못 함
- 😫 무엇부터 배워야 할지 모름
- 😫 비싼 교육비 부담
- 😫 배운 것 금방 까먹음
- 😫 실무와 동떨어진 이론

### Gains (이득)
- 🎉 짧은 시간에 배우는 효율
- 🎉 체계적인 로드맵 제공
- 🎉 저렴한 가격
- 🎉 반복 학습으로 장기 기억
- 🎉 실무 프로젝트로 포트폴리오

---

### Products & Services (제품/서비스)
1. **5분 숏폼 영상 라이브러리**
   - 1,000+ 코스 × 평균 20개 영상
   - 매주 신규 콘텐츠 30개 추가

2. **AI 학습 플래너**
   - 사용자 수준 진단
   - 맞춤형 커리큘럼 생성
   - 학습 속도 조절

3. **인터랙티브 퀴즈**
   - 영상 후 즉시 퀴즈
   - 틀린 문제 복습 알림
   - 간격 반복 학습 (Spaced Repetition)

4. **프로젝트 기반 학습**
   - 코스 완료 시 포트폴리오 생성
   - GitHub/Notion 자동 업로드
   - 채용 공고 연동

### Pain Relievers (고통 해소)
- ✅ 5분 영상 → 지루함 해소
- ✅ AI 추천 → 선택 고민 해소
- ✅ $15/월 → 가격 부담 해소
- ✅ 간격 반복 → 망각 방지
- ✅ 프로젝트 학습 → 실무 연계

### Gain Creators (이득 창출)
- 🚀 완강률 70% (업계 평균 15% 대비)
- 🚀 학습 시간 90% 단축 (8시간 → 50분)
- 🚀 수료증 + LinkedIn 배지
- 🚀 포트폴리오 자동 생성
- 🚀 커뮤니티 네트워킹
```

### 3.3 RICE Score (우선순위 결정)

**Formula:** `RICE Score = (Reach × Impact × Confidence) / Effort`

```markdown
## Feature 우선순위 (RICE Score)

| 기능 | Reach | Impact | Confidence | Effort | RICE | 우선순위 |
|------|-------|--------|------------|--------|------|----------|
| AI 학습 플래너 | 10,000 | 3 | 90% | 8 | **3,375** | 🥇 1위 |
| 숏폼 영상 라이브러리 | 10,000 | 3 | 100% | 13 | 2,308 | 🥈 2위 |
| 간격 반복 퀴즈 | 8,000 | 2 | 80% | 5 | 2,560 | 🥉 3위 |
| 커뮤니티 포럼 | 5,000 | 1 | 70% | 5 | 700 | 4위 |
| 1:1 화상 멘토링 | 2,000 | 3 | 50% | 13 | 231 | 5위 |
| AR/VR 학습 | 1,000 | 3 | 30% | 21 | 43 | 6위 |

### 설명:
- **Reach**: 분기당 몇 명의 사용자가 이 기능을 사용할까?
- **Impact**: 사용자 경험 개선 정도 (1=작음, 2=중간, 3=큼)
- **Confidence**: 추정치에 대한 확신 (0-100%)
- **Effort**: 개발에 필요한 person-weeks

### MVP (Minimum Viable Product) 범위
1위-3위 기능 우선 개발 (총 26 person-weeks ≈ 6개월)
```

---

## 4. PRD 자동 생성

### 4.1 PRD 템플릿

```markdown
# Product Requirements Document (PRD)

## 제품명
**EduShorts** - AI 기반 숏폼 영상 교육 플랫폼

---

## 1. Executive Summary

### Vision
"5분이면 충분하다. 누구나 매일 새로운 스킬을 배우는 세상"

### Mission
바쁜 현대인에게 TikTok처럼 중독적이지만 교육적인 학습 경험을 제공하여, 평생 학습 문화를 만든다.

### 목표 (6개월 MVP)
- MAU 10만 달성
- 완강률 70% (업계 평균 15% 대비)
- NPS 50+ (업계 평균 30)
- ARR $1M (월 $15 × 5,000 유료 전환)

---

## 2. Problem Statement

### 현재 문제
1. **긴 강의는 완강률 15%** - Udemy, Coursera 평균
2. **YouTube는 체계적이지 않음** - 무엇부터 볼지 모름
3. **바쁜 직장인은 시간 없음** - 8시간 강의 언제 봐?
4. **배운 것 금방 까먹음** - 복습 시스템 부재

### 시장 기회
- 온라인 교육 시장: $350B (CAGR 12%)
- 숏폼 비디오 시장: $120B (CAGR 28%)
- 한국 EdTech 시장: $8.5B
- **Untapped Opportunity**: 숏폼 + 교육 융합

---

## 3. Target Users

### Primary Persona
**직장인 김철수 (27-35세, 60% of users)**
- 직군: 마케터, 기획자, 개발자
- 연봉: 4,000-7,000만원
- 교육 수준: 대졸 이상
- 거주: 서울/수도권

**Pain Points:**
- 퇴근 후 피곤해서 긴 강의 못 봄
- 주말엔 쉬고 싶음
- 하지만 뒤처지는 게 불안함

**Goals:**
- 점심시간 30분으로 스킬 업
- 다음 프로젝트에 바로 적용
- 이력서에 쓸 수료증

### Secondary Persona
**대학생 이영희 (19-23세, 30% of users)**
- 전공: 비IT 전공 (경영, 디자인)
- 목표: 취업 준비
- 예산: 월 1-2만원

**Pain Points:**
- 학원은 비싸고 시간 맞추기 어려움
- 유튜브로 배우면 수료증 없음
- 무엇부터 배워야 할지 모름

**Goals:**
- 포트폴리오 만들기
- 자격증/수료증 취득
- 저렴한 비용

---

## 4. User Stories

### Epic 1: 온보딩 & 학습 플래너

**US-001:** 스킬 레벨 진단
```
As a 신규 사용자
I want to 내 현재 스킬 레벨을 진단받고 싶다
So that 나에게 맞는 커리큘럼을 추천받을 수 있다

Acceptance Criteria:
- [ ] 5분 이내 완료되는 진단 퀴즈 (10문항)
- [ ] 초급/중급/고급 자동 판정
- [ ] 추천 학습 경로 3가지 제시
- [ ] 예상 학습 시간 표시 (e.g., "하루 20분, 4주 완료")

Priority: P0 (Must-have)
Effort: 5 person-days
```

**US-002:** AI 맞춤형 커리큘럼 생성
```
As a 사용자
I want to AI가 나만의 학습 로드맵을 만들어주길 원한다
So that 무엇부터 배워야 할지 고민하지 않고 바로 시작할 수 있다

Acceptance Criteria:
- [ ] 사용자 목표 입력 (e.g., "웹 개발자 되기")
- [ ] 필수 코스 + 선택 코스 자동 선정
- [ ] 총 학습 시간 & 예상 완료일 표시
- [ ] 매일 푸시 알림 (학습 리마인더)

Priority: P0
Effort: 8 person-days
```

---

### Epic 2: 숏폼 영상 학습

**US-003:** 5분 영상 시청
```
As a 사용자
I want to 5분 이하 영상으로 핵심만 배우고 싶다
So that 짧은 시간에 효율적으로 학습할 수 있다

Acceptance Criteria:
- [ ] 영상 길이: 3-7분
- [ ] 1.5배속, 2배속 지원
- [ ] 자막 자동 생성 (한/영)
- [ ] 북마크 기능 (나중에 다시 보기)
- [ ] 오프라인 다운로드 (프리미엄)

Priority: P0
Effort: 13 person-days
```

**US-004:** 인터랙티브 퀴즈
```
As a 사용자
I want to 영상 시청 후 즉시 퀴즈를 풀고 싶다
So that 내가 제대로 이해했는지 확인할 수 있다

Acceptance Criteria:
- [ ] 영상 종료 후 자동으로 퀴즈 팝업
- [ ] 객관식 3-5문항
- [ ] 즉시 정답/해설 표시
- [ ] 틀린 문제는 복습 리스트에 자동 추가
- [ ] 80% 이상 정답 시 다음 영상 언락

Priority: P1
Effort: 5 person-days
```

---

### Epic 3: 학습 관리 & 동기부여

**US-005:** 학습 스트릭 (연속 학습 일수)
```
As a 사용자
I want to 연속으로 학습한 날짜를 추적하고 싶다
So that 매일 학습하는 동기부여를 받을 수 있다

Acceptance Criteria:
- [ ] 홈 화면에 스트릭 표시 ("🔥 7일 연속!")
- [ ] 7일, 30일, 100일 달성 시 배지 획득
- [ ] 스트릭 끊기기 전 알림 ("오늘 학습 안 하면 끊겨요!")
- [ ] 친구와 스트릭 경쟁 (리더보드)

Priority: P1
Effort: 3 person-days
```

**US-006:** 수료증 발급
```
As a 사용자
I want to 코스 완료 시 수료증을 받고 싶다
So that LinkedIn에 공유하여 커리어에 도움이 되길 원한다

Acceptance Criteria:
- [ ] 코스 100% 완료 시 자동 발급
- [ ] PDF 다운로드 지원
- [ ] LinkedIn "Add to Profile" 원클릭 연동
- [ ] 수료증에 NFT 옵션 (블록체인 인증)

Priority: P1
Effort: 5 person-days
```

---

## 5. Functional Requirements

### 5.1 Core Features

| Feature ID | 기능 | 설명 | Priority |
|------------|------|------|----------|
| F-001 | 숏폼 영상 플레이어 | 3-7분 영상, 자막, 배속 조절 | P0 |
| F-002 | AI 학습 플래너 | 스킬 진단 + 맞춤 커리큘럼 | P0 |
| F-003 | 인터랙티브 퀴즈 | 영상 후 즉시 퀴즈, 복습 시스템 | P0 |
| F-004 | 간격 반복 학습 | Spaced Repetition 알고리즘 | P1 |
| F-005 | 학습 스트릭 | 연속 학습 일수, 배지, 리더보드 | P1 |
| F-006 | 수료증 발급 | PDF + LinkedIn 연동 | P1 |
| F-007 | 프로젝트 포트폴리오 | 코스 완료 시 포트폴리오 자동 생성 | P2 |
| F-008 | 커뮤니티 Q&A | 질문/답변 포럼 | P2 |
| F-009 | 1:1 AI 튜터 챗봇 | 24/7 질문 응답 | P2 |

### 5.2 Non-Functional Requirements

| NFR ID | 요구사항 | 측정 기준 |
|--------|----------|-----------|
| NFR-001 | 성능 | 영상 로딩 < 2초 (p95) |
| NFR-002 | 가용성 | 99.9% uptime (월 43분 다운타임) |
| NFR-003 | 확장성 | 동시 접속 10만 지원 |
| NFR-004 | 보안 | HTTPS, OAuth 2.0, 개인정보 암호화 |
| NFR-005 | 접근성 | WCAG 2.1 AA 준수, 시각장애인 지원 |
| NFR-006 | 국제화 | 한국어, 영어 지원 (향후 10개국어) |

---

## 6. Technical Architecture

### 6.1 시스템 아키텍처

```
┌─────────────────────────────────────────────────┐
│                  Client Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │   Web    │  │  Mobile  │  │   API    │      │
│  │  (React) │  │(RN/Swift)│  │  Client  │      │
│  └──────────┘  └──────────┘  └──────────┘      │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│              API Gateway (FastAPI)               │
│  - Auth (JWT)                                    │
│  - Rate Limiting                                 │
│  - Request Routing                               │
└────────────────────┬────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
┌───────▼──────┐ ┌──▼────────┐ ┌▼──────────────┐
│   User       │ │  Learning │ │   Content     │
│   Service    │ │  Service  │ │   Service     │
│              │ │           │ │               │
│- Profile     │ │- AI Plan  │ │- Video CDN    │
│- Auth        │ │- Quiz     │ │- Transcoding  │
│- Subscription│ │- Progress │ │- Subtitles    │
└──────┬───────┘ └─────┬─────┘ └───────┬───────┘
       │               │               │
┌──────▼───────────────▼───────────────▼─────────┐
│            Data Layer (PostgreSQL)              │
│  - Users, Profiles                              │
│  - Courses, Videos, Quizzes                     │
│  - Learning Progress, Certificates              │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│          Supporting Services                     │
│                                                  │
│  - Redis (Caching)                              │
│  - Elasticsearch (Search)                       │
│  - S3 (Video Storage)                           │
│  - CloudFront (CDN)                             │
│  - OpenAI API (AI Tutor, Content Gen)          │
│  - Firebase (Push Notifications)                │
└─────────────────────────────────────────────────┘
```

### 6.2 Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **Frontend** | React (Web), React Native (Mobile) | 코드 재사용, 빠른 개발 |
| **Backend** | FastAPI (Python) | 빠른 개발, AI/ML 통합 용이 |
| **Database** | PostgreSQL | 안정성, ACID 보장 |
| **Cache** | Redis | 학습 진도 실시간 업데이트 |
| **Search** | Elasticsearch | 영상/코스 검색 최적화 |
| **Video** | AWS S3 + CloudFront | 글로벌 CDN, 저렴한 비용 |
| **AI/ML** | OpenAI GPT-4o, Claude | AI 플래너, 챗봇, 콘텐츠 생성 |
| **Analytics** | Mixpanel, Amplitude | 사용자 행동 분석 |

---

## 7. Go-to-Market Strategy

### 7.1 런칭 전략 (3단계)

**Phase 1: Private Beta (월 1-2)**
- 목표: PMF (Product-Market Fit) 검증
- 대상: 100명 얼리어답터 (지인, SNS 모집)
- 핵심 지표:
  - 완강률 70% 달성
  - NPS 50+
  - 일 7일 리텐션 40%+

**Phase 2: Public Beta (월 3-4)**
- 목표: 1,000 MAU
- 마케팅:
  - 인스타그램/페이스북 광고 ($5,000/월)
  - 인플루언서 협업 (교육 유튜버 10명)
  - 레퍼럴 프로그램 (친구 초대 시 1개월 무료)
- 핵심 지표:
  - CAC < $20
  - LTV > $100
  - Viral Coefficient 1.2+

**Phase 3: Official Launch (월 5-6)**
- 목표: 10,000 MAU
- 마케팅:
  - PR (테크크런치, 벤처비트 피처)
  - 네이버/구글 검색 광고 ($10,000/월)
  - 오프라인 이벤트 (강남 코워킹 스페이스)
- 핵심 지표:
  - 유료 전환율 5%
  - ARR $1M
  - Churn Rate < 5%/월

### 7.2 가격 전략

```markdown
## Pricing Tiers

### Free (Freemium)
**$0/월**
- 월 5개 영상 시청
- 기본 퀴즈
- 수료증 워터마크 포함

→ 목표: 신규 유입, 바이럴 확산

---

### Pro (핵심 타겟)
**$15/월 (연간 $144, 20% 할인)**
- 무제한 영상 시청
- AI 학습 플래너
- 간격 반복 복습
- 수료증 (워터마크 없음)
- LinkedIn 연동
- 오프라인 다운로드

→ 목표: 60% 매출 기여

---

### Premium (파워 유저)
**$49/월 (연간 $470, 20% 할인)**
- Pro 모든 기능
- 1:1 AI 튜터 무제한
- 프로젝트 포트폴리오 생성
- 커리어 코칭 월 1회 (화상)
- 얼리 액세스 신규 코스
- 커뮤니티 VIP 배지

→ 목표: 40% 매출 기여 (소수 고객)

---

### Enterprise (B2B)
**Custom Pricing**
- 기업 대시보드 (직원 학습 현황)
- SSO 통합 (SAML)
- 맞춤형 콘텐츠 제작
- 전담 CS

→ 목표: 장기 안정 매출
```

### 7.3 성장 전략

**North Star Metric:** "주간 활성 학습 시간 (Weekly Active Learning Hours)"
- 목표: 사용자당 주 3시간 (하루 25분 × 7일)

**Growth Loops:**

1. **Content Loop**
   ```
   좋은 콘텐츠 → 높은 완강률 → 수료증 SNS 공유
   → 신규 유입 → 더 많은 콘텐츠 제작 (매출 증가)
   ```

2. **Social Loop**
   ```
   친구 초대 → 함께 학습 → 스트릭 경쟁
   → 더 많은 학습 시간 → 친구에게 자랑 → 더 많은 초대
   ```

3. **SEO Loop**
   ```
   수강생 리뷰 → 검색 노출 증가 → 유기적 유입
   → 더 많은 리뷰 → 더 높은 순위
   ```

---

## 8. Success Metrics

### 8.1 OKR (6개월 목표)

**Objective 1: PMF 달성**
- KR1: NPS 50+ 달성
- KR2: 완강률 70% 유지
- KR3: 월간 리텐션 60%+

**Objective 2: 성장 가속화**
- KR1: MAU 10만 달성
- KR2: 유료 전환율 5%
- KR3: CAC < LTV × 0.3 ($20 < $100 × 0.3)

**Objective 3: 재무 건전성**
- KR1: ARR $1M 달성
- KR2: Churn Rate < 5%/월
- KR3: Unit Economics 흑자

### 8.2 North Star Metric Framework

| 단계 | 지표 | 목표 | 측정 방법 |
|------|------|------|-----------|
| Acquisition | 신규 가입 | 5,000/월 | Google Analytics |
| Activation | 첫 영상 완강 | 70% | Mixpanel Funnel |
| Engagement | 주간 활성 사용자 | 40% WAU/MAU | Amplitude |
| Retention | D7 리텐션 | 40% | Cohort Analysis |
| Revenue | ARPU | $5 | Stripe |
| Referral | Viral Coefficient | 1.2 | 초대 추적 |

---

## 9. Risks & Mitigation

| 리스크 | 영향 | 확률 | 완화 전략 |
|--------|------|------|-----------|
| 콘텐츠 품질 낮음 | HIGH | MED | 엄격한 크리에이터 심사, 사용자 평점 시스템 |
| AI 플래너 부정확 | MED | MED | 사람 큐레이션 + AI 하이브리드 |
| 경쟁사 카피 | HIGH | HIGH | 브랜드 차별화, 커뮤니티 강화 |
| 법적 문제 (저작권) | HIGH | LOW | 자체 제작 or 라이센스 구매 |
| 기술 부채 | MED | HIGH | 코드 리뷰, 리팩토링 주기 설정 |
| Churn Rate 높음 | HIGH | MED | 온보딩 개선, 푸시 알림 최적화 |

---

## 10. Roadmap

### Q1 2026 (월 1-3): MVP 개발
- Week 1-4: 아키텍처 설계, DB 스키마
- Week 5-8: 숏폼 플레이어, 퀴즈 시스템
- Week 9-12: AI 학습 플래너 (v1)
- Week 13: Private Beta 런칭 (100명)

### Q2 2026 (월 4-6): PMF 검증 & 성장
- Week 14-16: 피드백 반영, 버그 수정
- Week 17-20: 간격 반복 학습, 수료증
- Week 21-24: Public Beta 런칭 (1,000 MAU)
- Week 25-26: Official Launch (10,000 MAU)

### Q3 2026 (월 7-9): 스케일업
- AI 튜터 챗봇 고도화
- 프로젝트 포트폴리오 자동 생성
- B2B Enterprise 기능
- 국제화 (영어 시장 진출)

### Q4 2026 (월 10-12): 수익화 극대화
- Premium Tier 출시
- 크리에이터 마켓플레이스
- NFT 수료증
- AR/VR 학습 (실험)

---

## 11. Team & Resources

### 필요 인력 (6개월 MVP 기준)

| 역할 | 인원 | 책임 |
|------|------|------|
| Product Manager | 1 | 제품 전략, 우선순위, 로드맵 |
| Frontend Engineer | 2 | Web (React), Mobile (RN) |
| Backend Engineer | 2 | API, DB, Infrastructure |
| AI/ML Engineer | 1 | AI 플래너, 추천 알고리즘 |
| Designer (UI/UX) | 1 | 와이어프레임, 디자인 시스템 |
| Content Creator | 3 | 영상 제작, 큐레이션 |
| QA Engineer | 1 | 테스트 자동화, 품질 관리 |
| **Total** | **11명** | - |

### 예산 (6개월)

| 항목 | 비용 (월) | 6개월 총액 |
|------|-----------|------------|
| 인건비 (11명 × $5K) | $55,000 | $330,000 |
| AWS/GCP 인프라 | $3,000 | $18,000 |
| OpenAI API | $2,000 | $12,000 |
| 마케팅 (Phase 2-3) | $10,000 | $30,000 |
| 기타 (디자인툴, 법무) | $2,000 | $12,000 |
| **Total** | **$72,000** | **$402,000** |

---

## 12. Appendix

### A. 경쟁사 상세 분석
(별도 문서 참조: `docs/planning/competitive-analysis.md`)

### B. 사용자 인터뷰 스크립트
(별도 문서 참조: `docs/planning/user-interview.md`)

### C. Wireframes & Mockups
(Figma 링크: figma.com/edushorts-mvp)

### D. API Specification
(Swagger 문서: api.edushorts.com/docs)

---

## 승인 & 변경 이력

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|-----------|
| 1.0 | 2026-01-29 | Claude PM | 초안 작성 |
| 1.1 | 2026-02-05 | 팀 리뷰 | RICE Score 추가, 예산 조정 |
| 2.0 | 2026-02-10 | CEO 승인 | 최종 승인, 개발 시작 |
```

---

## 5. 사용 시나리오 예시

### 시나리오 1: B2B SaaS 아이디어 검증

```bash
사용자: /product-planner "중소기업용 AI 재무 자동화 SaaS"

→ 자동 실행:
1. 도메인: FinTech + B2B SaaS + AI
2. 시장 조사:
   - 한국 중소기업 수: 650만 개
   - 회계 소프트웨어 시장: $2.5B
   - TAM/SAM/SOM 계산
3. 경쟁사: 더존, 사람인, QuickBooks
4. JTBD: "월말 마감 시 수작업 줄이기"
5. PRD 생성: B2B 특화 요구사항
6. 가격: Freemium + $50/월/user
7. GTM: LinkedIn 광고 + 회계사 파트너십
```

### 시나리오 2: 헬스케어 앱 기획

```bash
사용자: /product-planner --framework lean-canvas "당뇨병 환자용 식단 관리 앱"

→ 자동 실행:
1. Lean Canvas 생성:
   - Problem: 당뇨 환자 67% 식단 관리 실패
   - Solution: AI 식단 추천 + 혈당 모니터링
   - Key Metrics: 일일 활성 사용자 (DAU)
   - Unfair Advantage: 병원 데이터 연동
2. 규제 분석: 의료기기 인증 필요성 검토
3. 파트너십: 병원, 보험사, 식품 회사
4. 수익 모델: B2C 구독 + B2B2C (병원 제휴)
```

---

## 6. 출력 파일 구조

```
docs/planning/
├── PRD.md                    # 제품 요구사항 문서
├── market-research.md        # 시장 조사 결과
├── competitive-analysis.md   # 경쟁사 분석
├── user-personas.md          # 타겟 페르소나
├── user-stories.md           # 사용자 스토리
├── feature-prioritization.md # RICE Score
├── business-model-canvas.md  # 비즈니스 모델
├── lean-canvas.md            # Lean Canvas (선택)
├── roadmap.md                # 제품 로드맵
├── gtm-strategy.md           # Go-to-Market 전략
└── financial-projection.md   # 재무 예측
```

---

## 7. 통합 기능

### 7.1 AI Research 연동

```bash
# 최신 트렌드 자동 조사
/product-planner --with-research "메타버스 교육 플랫폼"

→ ai-research-integration 스킬 호출:
- arXiv/Semantic Scholar에서 "metaverse education" 논문 검색
- 최신 기술 트렌드 요약
- PRD에 "기술 혁신 섹션" 추가
```

### 7.2 Agent Evaluator 연동

```bash
# 아이디어 평가 자동화
/product-planner --evaluate-idea "AI 반려동물 헬스케어"

→ agent-evaluator 스킬 호출:
- 아이디어 점수 (0-100)
- 시장 기회 점수
- 기술 실현 가능성 점수
- 종합 추천: "진행 권장 (85/100)"
```

---

## 모범 사례

### ✅ Do
- 사용자 페인 포인트부터 시작 (Problem-first)
- 데이터 기반 의사결정
- MVP 범위 명확히 정의
- 경쟁사 장점 배우기

### ❌ Don't
- 기술부터 시작 (Technology-first)
- 감으로 결정
- 처음부터 완벽한 제품 만들기
- 경쟁사 무시하기

---

## 20년차 PM의 조언

> "아이디어는 10점 만점에 1점, 실행이 9점이다."
> - 좋은 PRD보다 빠른 실행과 학습이 중요

> "사용자는 그들이 원하는 걸 모른다. 그들이 가진 문제를 해결하라."
> - Jobs-to-be-Done 프레임워크의 핵심

> "첫 100명 사용자는 직접 만나라. 스케일은 그 다음이다."
> - PMF 전까지는 효율보다 학습

---

## 참고 자료

- [Lean Canvas Template](https://leanstack.com/lean-canvas)
- [JTBD Framework](https://jtbd.info/)
- [RICE Prioritization](https://www.intercom.com/blog/rice-simple-prioritization-for-product-managers/)
- [Product-Market Fit Guide](https://pmarchive.com/guide_to_startups_part4.html)
