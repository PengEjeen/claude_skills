---
name: react-component
description: Anti-AI Frontend Design — 인간 중심의 프론트엔드 디자인 종합 스킬. AI가 만들었다고 느껴지지 않는, 심리학·미학·UX 연구 기반의 최고 품질 웹사이트를 만든다. 웹사이트, 랜딩페이지, 대시보드, SaaS UI, 포트폴리오, React 컴포넌트, HTML/CSS 등 모든 프론트엔드 작업에 적용. 타이포그래피, 색채 심리학, 레이아웃, 인터랙션, 반응형, 컴포넌트, 네비게이션을 포괄하는 종합 디자인 시스템. Triggers: "웹사이트 만들어", "랜딩페이지", "프론트엔드", "React", "컴포넌트", "UI 디자인", "CSS", "대시보드", "frontend", "website", "landing page", "dashboard".
---

# Anti-AI Frontend Design System

> "AI가 만들어낸 것이 아닌, 사람이 의도와 감성을 담아 설계한 것처럼 보이는 디자인"

이 스킬은 2026년 기준 가장 진보된 Anti-AI 디자인 철학과 인지심리학, 미학 연구를 결합하여 **AI가 절대 만들었다고 느껴지지 않는** 프론트엔드를 생성하기 위한 종합 가이드이다.

---

## 0. 핵심 원칙: AI 미학의 안티테제

### AI가 만드는 디자인의 특징 (반드시 피할 것)
- 균일한 그라디언트 (특히 보라-파랑 계열)
- Inter, Roboto, Arial 같은 무난한 시스템 폰트
- 완벽한 대칭과 정렬
- 모든 요소가 동일한 border-radius
- 과도한 글래스모피즘 (blur + transparency 남용)
- "bento box" 그리드의 무비판적 사용
- 동일한 카드 패턴의 무한 반복
- 의미 없는 gradient blob 배경
- 매끄럽고 기계적인 ease-in-out 애니메이션만 사용
- 모든 곳에 동일한 shadow 강도
- 아이콘이 모두 같은 스타일 (Lucide/Heroicons 일색)
- 과도하게 둥근 모서리 (border-radius: 9999px 남용)

### 대신 추구할 것: 인간의 손길 (Human Touch)
- 의도적 비대칭 (Intentional Asymmetry)
- 텍스처와 질감 (Grain, Noise, Paper, Ink)
- 손으로 그린 듯한 요소 (Hand-drawn Overlays)
- 예측 불가능한 리듬감 (Controlled Chaos)
- 물리적 세계의 메타포 (물질성, 촉각적 느낌)
- 개성 있는 마이크로카피
- 문화적 맥락이 반영된 디테일

---

## 1. 타이포그래피 — 글씨체가 가장 중요하다

### 심리학적 근거
- **인지 유창성 (Cognitive Fluency)**: 읽기 쉬운 폰트는 콘텐츠 신뢰도를 높인다 (Kurosu & Kashimura, 1995)
- **성격 인식 (Font Personality)**: 서체는 브랜드 성격을 즉시 전달한다 (Henderson et al., 2004)
- **감정 유발 (Emotional Typography)**: 서체 선택이 사용자의 감정 상태에 영향을 미친다 (Koch, 2012)

### 폰트 선택 전략

**절대 사용 금지 (AI 냄새가 나는 폰트들)**:
- Inter, Roboto, Open Sans, Lato, Montserrat, Poppins, Nunito
- Space Grotesk, DM Sans, Plus Jakarta Sans (AI가 특히 좋아하는 폰트들)
- 어떤 시스템 기본 폰트도 단독 사용 금지

**추천 전략별 폰트 조합** (Google Fonts 기준):

| 카테고리 | Display / Heading | Body / Text | 분위기 |
|---------|------------------|-------------|--------|
| Editorial Elegance | Playfair Display, Cormorant Garamond, Libre Baskerville | Source Serif 4, Literata, Crimson Pro | 격조, 신뢰, 지적 |
| Warm Humanist | Fraunces, Bricolage Grotesque, Sora | Atkinson Hyperlegible, Karla, Outfit | 따뜻함, 접근성, 친근 |
| Bold Statement | Clash Display (Fontshare), Bebas Neue, Archivo Black | Manrope, General Sans (Fontshare), Switzer | 강렬, 현대적, 자신감 |
| Artistic Craft | Instrument Serif, Gambetta, Zodiak (Fontshare) | Cabinet Grotesk (Fontshare), Satoshi (Fontshare) | 예술적, 세련, 독특 |
| Technical Honest | JetBrains Mono, IBM Plex Mono, Fira Code | IBM Plex Sans, Geist (Vercel), Söhne | 정직, 기술적, 투명 |
| 한글 조합 | Noto Serif KR, KoPub바탕체 | Pretendard, SUIT, KoPub돋움체 | 한국적 세련미 |

**한글 특화 폰트 전략**:
- 본문: Pretendard (가독성 최고), SUIT, Wanted Sans
- 제목: Noto Serif KR, 마루부리, RIDIBatang
- 강조: Black Han Sans, Do Hyeon (절제하여 사용)
- 손글씨/캐릭터: Gaegu, Gamja Flower, Nanum Pen Script

### 타이포그래피 규칙

```
1. 폰트 페어링은 반드시 2개, 최대 3개
2. Heading과 Body는 반드시 다른 카테고리에서 선택 (Serif + Sans 또는 Display + Text)
3. font-weight 변화를 적극 활용 (300, 400, 500, 700, 900 — 최소 3개 웨이트)
4. letter-spacing은 제목에서 미세하게 조정 (-0.02em ~ -0.04em)
5. line-height는 본문 1.6~1.8, 제목 1.1~1.3
6. 큰 제목은 font-size: clamp(2rem, 5vw, 4.5rem) 형태로 유동적
7. 가변 폰트(Variable Font) 적극 활용 — wght, wdth, slnt 축 활용
8. 텍스트 렌더링: -webkit-font-smoothing: antialiased 필수
9. 단락 최대 너비: max-width: 65ch (가독성 최적)
10. 한글+영문 혼용 시: 한글 폰트를 먼저 선언하고 영문 fallback
```

### Anti-AI 타이포그래피 비법
- 제목에 `font-feature-settings: "ss01", "liga"` 등 OpenType 기능 활성화
- 특정 단어만 italic이나 다른 weight로 강조 (전체 bold 금지)
- `text-decoration: underline wavy` 같은 비정형 밑줄 활용
- `::first-letter` 의사 클래스로 드롭캡 효과
- 인용구에 큰 따옴표를 장식 요소로 활용 (font-size: 6rem; opacity: 0.1)
- 행간과 자간을 섹션마다 미세하게 다르게 (monotone 방지)

---

## 2. 색채 심리학 — 색이 감정을 만든다

### 연구 근거
- **색채와 감정 (Labrecque & Milne, 2012)**: 색채가 브랜드 인식과 구매 의도에 직접 영향
- **색채 조화 이론 (Itten, 1961)**: 보색, 유사색, 분할보색의 심리적 효과
- **문화적 색채 인식 (Madden et al., 2000)**: 같은 색이 문화권마다 다른 의미

### 금지된 색채 패턴 (AI가 만드는 전형적 조합)
```
❌ #6366F1 → #8B5CF6 → #A855F7 (보라 그라디언트 — AI의 상징색)
❌ #3B82F6 → #6366F1 (파랑-보라 — AI 스타트업 클리셰)
❌ 흰 배경 + 파랑 CTA + 회색 텍스트 (SaaS 템플릿 느낌)
❌ 모든 요소에 동일한 opacity/투명도 적용
❌ 순수한 검정(#000000)과 순수한 흰색(#FFFFFF)만 사용
```

### 추천 색채 시스템

**1. 팔레트 구축 원칙**
```css
:root {
  /* 순수 흑백 대신 톤이 있는 뉴트럴 사용 */
  --ink: #1a1a2e;          /* 따뜻한 검정 */
  --paper: #faf8f5;        /* 따뜻한 흰색 */

  /* 주조색 (1개): 브랜드 성격을 결정 */
  --primary: #c1440e;      /* 예: 테라코타 — 따뜻함, 대지, 인간적 */

  /* 보조색 (1~2개): 주조색과 조화 */
  --secondary: #2d6a4f;    /* 예: 포레스트 그린 — 균형, 자연 */
  --tertiary: #dda15e;     /* 예: 앰버 — 따뜻한 악센트 */

  /* 기능색: 상태 표현 */
  --success: #40916c;
  --warning: #e76f51;
  --error: #bc4749;
  --info: #457b9d;
}
```

**2. 팔레트 생성 패턴 (프로젝트마다 다르게)**

| 무드 | 주조색 계열 | 뉴트럴 톤 | 악센트 | 심리 효과 |
|------|-----------|-----------|--------|----------|
| Earthy Warm | 테라코타, 시에나, 번트오렌지 | 아이보리, 크림 | 올리브, 세이지 | 신뢰, 진정성, 따뜻함 |
| Ocean Calm | 틸, 페트롤, 슬레이트블루 | 오프화이트, 미스트 | 코랄, 피치 | 차분, 전문성, 깊이 |
| Forest Deep | 헌터그린, 에메랄드 | 린넨, 에크루 | 골드, 머스타드 | 안정, 성장, 고급 |
| Sunset Bold | 버밀리온, 마젠타 | 차콜, 다크슬레이트 | 라벤더, 라일락 | 에너지, 창의성, 열정 |
| Midnight Edit | 네이비, 미드나잇블루 | 실버그레이, 쿨그레이 | 골드, 앰버 | 격조, 권위, 프리미엄 |
| Mono Craft | 순수 무채색 | 다양한 그레이 톤 | 단 하나의 선명한 색 | 정직, 미니멀, 집중 |

**3. Anti-AI 색채 비법**
```
- 그라디언트를 쓸 때: linear-gradient보다 radial-gradient, conic-gradient 활용
- 배경에 미세한 noise 텍스처 overlay (opacity: 0.03~0.08)
- 같은 계열 색이라도 미세하게 다른 톤 사용 (모든 회색이 동일하면 AI 느낌)
- mix-blend-mode: multiply, overlay 등으로 레이어 깊이감
- 그림자에 순수 검정 금지: box-shadow: 0 4px 20px rgba(26, 26, 46, 0.08)
- 색상에 따뜻한 톤 추가: hsl(h, s%, l%) 에서 채도 10~15% 낮추기
- backdrop-filter는 최소한으로, 쓸 때도 saturate(1.2)와 함께
```

---

## 3. 레이아웃 & 공간 구성 — 시선의 흐름을 설계한다

### 심리학적 근거
- **게슈탈트 원리 (Gestalt Principles)**: 근접, 유사, 연속, 폐합 법칙
- **F 패턴 & Z 패턴 (Nielsen, 2006)**: 사용자 시선 추적 연구 기반
- **인지 부하 이론 (Cognitive Load Theory, Sweller)**: 정보 과부하 방지
- **피츠의 법칙 (Fitts's Law)**: 타겟 크기와 거리가 조작 시간을 결정
- **힉의 법칙 (Hick's Law)**: 선택지가 많을수록 결정 시간 증가

### 레이아웃 원칙

**1. 그리드 시스템 — 규칙을 만들고, 의도적으로 깨기**
```css
/* 기본 그리드: 12컬럼이지만 비대칭 활용 */
.container {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: clamp(1rem, 2vw, 2rem);
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 clamp(1rem, 4vw, 3rem);
}

/* Anti-AI 비대칭 레이아웃 */
.hero-asymmetric {
  grid-template-columns: 7fr 5fr;  /* 완벽한 반반 금지 */
}

.content-offset {
  grid-template-columns: 2fr 8fr 2fr; /* 오프셋된 콘텐츠 */
}

.editorial {
  grid-template-columns: 1fr min(65ch, 100%) 1fr; /* 활자 중심 */
}
```

**2. 수직 리듬 (Vertical Rhythm)**
```css
/* 8px 기반 스페이싱 시스템 — 하지만 비선형으로 */
:root {
  --space-3xs: clamp(0.25rem, 0.5vw, 0.375rem);
  --space-2xs: clamp(0.5rem, 1vw, 0.75rem);
  --space-xs:  clamp(0.75rem, 1.5vw, 1rem);
  --space-s:   clamp(1rem, 2vw, 1.5rem);
  --space-m:   clamp(1.5rem, 3vw, 2.5rem);
  --space-l:   clamp(2rem, 4vw, 4rem);
  --space-xl:  clamp(3rem, 6vw, 6rem);
  --space-2xl: clamp(4rem, 8vw, 8rem);
  --space-3xl: clamp(6rem, 12vw, 12rem);
}

/* 섹션 간 간격은 크게, 요소 간 간격은 작게 — 호흡감 */
section + section { margin-top: var(--space-2xl); }
h2 + p { margin-top: var(--space-xs); }
p + p { margin-top: var(--space-s); }
```

**3. Anti-AI 레이아웃 비법**
```
- 완벽한 50/50 분할 금지 → 55/45, 60/40, 70/30 사용
- 콘텐츠를 가운데에만 배치하지 않기 → 좌측 정렬 + 우측 여백 활용
- "떠 있는" 요소 배치: position: relative로 미세한 offset
- 요소가 그리드를 "넘치는" 순간 만들기 (overflow: visible)
- 섹션마다 레이아웃 패턴 변화 (단조로운 반복 방지)
- 이미지/요소의 크기를 섹션마다 급격히 변화 (작은→큰→작은)
- 여백(Negative Space)을 디자인 요소로 의도적으로 활용
- 텍스트 블록의 최대 너비를 55~75ch로 제한 (가독성 연구 근거)
```

---

## 4. 메뉴 & 네비게이션 — 첫인상을 결정한다

### 심리학적 근거
- **야콥의 법칙 (Jakob's Law)**: 사용자는 다른 사이트와 유사한 동작을 기대
- **밀러의 법칙 (Miller's Law)**: 한 번에 7±2개 항목만 처리 가능
- **진행성 공개 (Progressive Disclosure)**: 복잡성을 단계적으로 노출

### 네비게이션 설계 원칙

**1. 메뉴 항목 수**: 5~7개 (절대 10개 이상 금지)

**2. Anti-AI 네비게이션 스타일**

```css
/* 스타일 A: 에디토리얼 내비 — 밑줄 애니메이션 */
.nav-editorial a {
  position: relative;
  text-decoration: none;
  font-family: var(--font-body);
  font-size: 0.875rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}
.nav-editorial a::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 0;
  height: 1px;
  background: currentColor;
  transition: width 0.4s cubic-bezier(0.22, 1, 0.36, 1);
}
.nav-editorial a:hover::after { width: 100%; }

/* 스타일 B: 부티크 내비 — 번호 매기기 */
.nav-boutique a::before {
  content: attr(data-index);
  font-family: var(--font-mono);
  font-size: 0.65rem;
  opacity: 0.4;
  margin-right: 0.5em;
  vertical-align: super;
}

/* 스타일 C: 인터랙티브 내비 — 호버 시 배경색 변화 */
.nav-interactive a {
  padding: 0.5em 1em;
  border-radius: 2px; /* 과도한 둥글기 금지 */
  transition: background 0.3s ease, color 0.3s ease;
}
.nav-interactive a:hover {
  background: var(--primary);
  color: var(--paper);
}
```

**3. 모바일 메뉴 — 햄버거 너머**
```
- 기본 햄버거 아이콘 ≡ 대신 "Menu" 텍스트 사용 (Nielsen 연구: 텍스트가 더 명확)
- 열린 메뉴는 전체 화면 (풀스크린 오버레이) — 여유 있는 터치 타겟
- 메뉴 아이템에 스태거드 애니메이션 (순차 등장)
- 닫기 버튼은 × 대신 "Close" 텍스트 또는 스와이프 제스처
- 현재 페이지 표시: 점(dot), 밑줄, 또는 색상 변화로 명확히
```

**4. 스크롤 기반 헤더 동작**
```css
/* 스크롤 시 축소되는 헤더 */
.header {
  position: sticky;
  top: 0;
  transition: padding 0.3s ease, backdrop-filter 0.3s ease;
}
.header--scrolled {
  padding-block: 0.5rem;
  backdrop-filter: blur(12px) saturate(1.1);
  background: rgba(250, 248, 245, 0.85);
  border-bottom: 1px solid rgba(0,0,0,0.06);
}
```

---

## 5. 컴포넌트 디자인 — 디테일이 인간미를 만든다

### 버튼
```css
/* Anti-AI 버튼: 과도한 둥글기, 그라디언트, 그림자 금지 */
.btn-primary {
  font-family: var(--font-body);
  font-weight: 500;
  font-size: 0.9375rem;
  letter-spacing: 0.02em;
  padding: 0.75em 2em;
  border: 1.5px solid var(--ink);
  border-radius: 3px;              /* 9999px 절대 금지 */
  background: var(--ink);
  color: var(--paper);
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.22, 1, 0.36, 1);
  position: relative;
  overflow: hidden;
}
.btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(26, 26, 46, 0.15);
}
.btn-primary:active {
  transform: translateY(0);
  box-shadow: none;
}

/* 보조 버튼: ghost 스타일 */
.btn-secondary {
  background: transparent;
  color: var(--ink);
  border: 1.5px solid rgba(26, 26, 46, 0.2);
}
.btn-secondary:hover {
  border-color: var(--ink);
  background: rgba(26, 26, 46, 0.03);
}
```

### 카드
```css
/* Anti-AI 카드: 동일한 카드 반복 금지, 변화를 줄 것 */
.card {
  background: var(--paper);
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 4px;
  padding: var(--space-m);
  transition: transform 0.3s cubic-bezier(0.22, 1, 0.36, 1),
              box-shadow 0.3s ease;
}
.card:hover {
  transform: translateY(-3px) rotate(-0.3deg); /* 미세한 회전 = 인간적 */
  box-shadow: 0 8px 30px rgba(26, 26, 46, 0.08);
}

/* 카드 그리드에서 크기 변화 */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: var(--space-m);
}
.card-grid .card:nth-child(3n+1) {
  grid-row: span 1;  /* 높이 변화 */
}
```

### 입력 필드
```css
.input {
  font-family: var(--font-body);
  font-size: 1rem;
  padding: 0.75em 1em;
  border: 1.5px solid rgba(0, 0, 0, 0.12);
  border-radius: 3px;
  background: transparent;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
  width: 100%;
}
.input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(193, 68, 14, 0.08); /* primary 색상 기반 */
}
.input::placeholder {
  color: rgba(26, 26, 46, 0.35);
  font-style: italic;
}

/* 라벨은 위에 배치, 작은 크기 */
.label {
  display: block;
  font-size: 0.8125rem;
  font-weight: 500;
  letter-spacing: 0.03em;
  margin-bottom: 0.375rem;
  color: rgba(26, 26, 46, 0.65);
}
```

---

## 6. 인터랙션 & 애니메이션 — 살아 있는 느낌

### 심리학적 근거
- **예측적 코딩 (Predictive Coding)**: 뇌는 예측 가능한 패턴을 선호하되, 적절한 놀라움에 도파민 분비
- **미적-사용성 효과 (Aesthetic-Usability Effect, Kurosu & Kashimura, 1995)**: 아름다운 인터페이스를 더 사용하기 쉽다고 인지
- **ZEIGARNIK 효과**: 미완성된 동작이 기억에 남음 → 프로그레스 바, 로딩 애니메이션

### 커스텀 이징 함수 (기계적 ease-in-out 금지)
```css
:root {
  /* 자연스러운 커스텀 이징 */
  --ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
  --ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1);
  --ease-in-out-circ: cubic-bezier(0.85, 0, 0.15, 1);
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);

  /* 스태거 딜레이 */
  --stagger: 60ms;
}
```

### 필수 인터랙션 패턴

**1. 스크롤 기반 등장 애니메이션 (CSS only)**
```css
@keyframes reveal-up {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.reveal {
  animation: reveal-up 0.8s var(--ease-out-expo) both;
  animation-timeline: view();
  animation-range: entry 0% entry 30%;
}

/* 순차 등장 */
.reveal:nth-child(1) { animation-delay: 0ms; }
.reveal:nth-child(2) { animation-delay: var(--stagger); }
.reveal:nth-child(3) { animation-delay: calc(var(--stagger) * 2); }
```

**2. 호버 마이크로인터랙션**
```css
/* 이미지 호버: 미세한 확대 + 색 보정 */
.image-hover {
  overflow: hidden;
  border-radius: 4px;
}
.image-hover img {
  transition: transform 0.6s var(--ease-out-expo),
              filter 0.6s ease;
}
.image-hover:hover img {
  transform: scale(1.04);
  filter: brightness(1.05) contrast(1.02);
}

/* 링크 호버: 밑줄이 왼→오로 그려지는 효과 */
.link-draw {
  background: linear-gradient(var(--primary), var(--primary)) no-repeat left bottom;
  background-size: 0% 1.5px;
  transition: background-size 0.35s var(--ease-out-expo);
  text-decoration: none;
  padding-bottom: 2px;
}
.link-draw:hover {
  background-size: 100% 1.5px;
}
```

**3. 페이지 전환 효과**
```css
/* View Transitions API 활용 */
@view-transition {
  navigation: auto;
}
::view-transition-old(root) {
  animation: fade-out 0.3s ease forwards;
}
::view-transition-new(root) {
  animation: fade-in 0.3s ease forwards;
}

/* 커스텀 커서 (선택적) */
.custom-cursor {
  cursor: none;
}
.cursor-dot {
  width: 8px;
  height: 8px;
  background: var(--primary);
  border-radius: 50%;
  position: fixed;
  pointer-events: none;
  z-index: 9999;
  transition: transform 0.1s ease;
  mix-blend-mode: difference;
}
```

**4. Parallax & Depth (성능 최적화)**
```css
/* CSS-only parallax — will-change와 transform으로 GPU 가속 */
.parallax-section {
  perspective: 1000px;
  overflow-x: hidden;
}
.parallax-bg {
  transform: translateZ(-1px) scale(2);
  will-change: transform;
}

/* 또는 scroll-driven animations (2026 표준) */
.float-element {
  animation: float-y linear both;
  animation-timeline: scroll();
  animation-range: 0% 100%;
}
@keyframes float-y {
  from { transform: translateY(50px); }
  to { transform: translateY(-50px); }
}
```

---

## 7. 반응형 디자인 — 모든 화면에서 아름답게

### 브레이크포인트 전략
```css
/* 콘텐츠 기반 브레이크포인트 (기기 기반 금지) */
/* Mobile-first 접근 */
:root {
  --bp-sm: 640px;
  --bp-md: 768px;
  --bp-lg: 1024px;
  --bp-xl: 1280px;
  --bp-2xl: 1536px;
}

/* Container queries 적극 활용 (2026 표준) */
.card-container {
  container-type: inline-size;
  container-name: card;
}
@container card (min-width: 400px) {
  .card { flex-direction: row; }
}
@container card (min-width: 700px) {
  .card { grid-template-columns: 1fr 2fr; }
}
```

### 반응형 Anti-AI 원칙
```
1. 모바일에서 콘텐츠 순서가 자연스러운지 항상 확인
2. 터치 타겟: 최소 44x44px (Apple HIG), 이상적으로 48x48px
3. 모바일에서 hover 효과 → tap/focus 효과로 대체
4. 이미지: <picture> + srcset으로 해상도별 최적화
5. 폰트 크기: 모바일에서도 최소 16px (iOS 자동 줌 방지)
6. 횡스크롤은 의도적인 경우에만 (캐러셀, 갤러리)
7. 세로 스크롤 우선, 가로 레이아웃은 큰 화면에서만
8. clamp()로 모든 크기를 유동적으로 — 하드코딩 금지
9. prefers-reduced-motion 미디어 쿼리 반드시 지원
10. prefers-color-scheme으로 다크모드 지원
```

---

## 8. 텍스처 & 질감 — AI 느낌을 완전히 제거

### 배경 텍스처 레시피
```css
/* Noise 텍스처 (SVG 기반 — 외부 이미지 불필요) */
.grain-overlay::before {
  content: '';
  position: fixed;
  inset: 0;
  opacity: 0.04;
  pointer-events: none;
  z-index: 9999;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E");
}

/* 종이 질감 배경 */
.paper-texture {
  background-color: var(--paper);
  background-image:
    radial-gradient(circle at 25% 25%, rgba(0,0,0,0.01) 1px, transparent 1px),
    radial-gradient(circle at 75% 75%, rgba(0,0,0,0.01) 1px, transparent 1px);
  background-size: 4px 4px;
}

/* 미세한 선 패턴 */
.line-pattern {
  background-image: repeating-linear-gradient(
    0deg,
    transparent,
    transparent 39px,
    rgba(0, 0, 0, 0.03) 39px,
    rgba(0, 0, 0, 0.03) 40px
  );
}
```

### 장식 요소
```css
/* 손으로 그린 듯한 구분선 */
.divider-hand {
  border: none;
  height: 2px;
  background: linear-gradient(
    90deg,
    transparent 0%,
    var(--ink) 15%,
    var(--ink) 50%,
    transparent 60%,
    var(--ink) 70%,
    var(--ink) 85%,
    transparent 100%
  );
  opacity: 0.15;
  max-width: 200px;
}

/* 불규칙한 border */
.organic-border {
  border-radius: 30% 70% 70% 30% / 30% 30% 70% 70%;
  /* 또는 각 모서리 다르게: */
  border-radius: 4px 12px 4px 16px;
}
```

---

## 9. 성능 & 접근성 — 아름다움과 기능의 균형

### 성능 필수 사항
```
1. LCP (Largest Contentful Paint) < 2.5초
2. FID (First Input Delay) < 100ms
3. CLS (Cumulative Layout Shift) < 0.1
4. 이미지: WebP/AVIF 포맷, lazy loading, 적절한 dimensions 속성
5. 폰트: font-display: swap + preload
6. CSS: critical CSS 인라인, 나머지 defer
7. JavaScript: 최소화, defer/async, 번들 사이즈 < 100KB
8. 애니메이션: transform과 opacity만 사용 (reflow/repaint 최소화)
9. will-change는 필요한 곳에만 (남용 금지)
10. IntersectionObserver로 뷰포트 밖 요소는 비활성화
```

### 접근성 필수 사항 (WCAG 2.2 AA 기준)
```
1. 색 대비: 본문 4.5:1 이상, 큰 텍스트 3:1 이상
2. 키보드 네비게이션: 모든 인터랙티브 요소 tab으로 접근 가능
3. focus-visible 스타일 반드시 제공 (outline 제거만 하면 안 됨)
4. alt 텍스트: 모든 의미 있는 이미지에 필수
5. semantic HTML: header, nav, main, section, article, footer
6. aria-label: 아이콘만 있는 버튼에 필수
7. skip-to-content 링크 제공
8. prefers-reduced-motion: 모든 애니메이션 비활성화 옵션
9. prefers-color-scheme: 다크모드 지원
10. prefers-contrast: 고대비 모드 지원
```

```css
/* 접근성 기본 설정 */
:focus-visible {
  outline: 2px solid var(--primary);
  outline-offset: 3px;
  border-radius: 2px;
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}

.skip-link {
  position: absolute;
  top: -100%;
  left: 1rem;
  padding: 0.5rem 1rem;
  background: var(--ink);
  color: var(--paper);
  z-index: 10000;
  border-radius: 0 0 4px 4px;
}
.skip-link:focus { top: 0; }
```

---

## 10. 다크 모드 — 단순 반전이 아닌 재설계

```css
@media (prefers-color-scheme: dark) {
  :root {
    --ink: #e8e4de;
    --paper: #151518;
    --primary: #e07a5f;       /* 밝은 톤으로 조정 */
    --secondary: #52b788;

    /* 다크모드에서 그림자는 더 강하게 */
    --shadow-color: rgba(0, 0, 0, 0.3);

    /* 텍스트 대비 미세 조정 — 순백 금지 */
    --text-primary: #e8e4de;    /* 약간 따뜻한 오프화이트 */
    --text-secondary: #a8a4a0;
    --text-muted: #6b6966;

    /* 표면 색상 미세 단계 */
    --surface-1: #1c1c20;
    --surface-2: #232328;
    --surface-3: #2a2a30;
  }
}
```

---

## 11. 구현 체크리스트

프론트엔드를 만들기 전 반드시 확인:

### Phase 1: 디자인 결정
- [ ] 프로젝트 무드/톤 결정 (이 스킬의 팔레트 표 참조)
- [ ] Display + Body 폰트 페어링 선택 (금지 폰트 확인)
- [ ] 색채 팔레트 3~5색 확정 (CSS 변수로)
- [ ] 전체 레이아웃 전략 결정 (비대칭 비율 결정)
- [ ] 핵심 인터랙션 2~3개 결정 (과하지 않게)

### Phase 2: 기반 구축
- [ ] CSS 변수 체계 설정 (색상, 스페이싱, 타이포, 이징)
- [ ] 반응형 타이포 스케일 설정 (clamp 기반)
- [ ] 그리드 시스템 설정
- [ ] 접근성 기본 설정 (focus-visible, skip-link, reduced-motion)
- [ ] Noise/grain 텍스처 오버레이 적용

### Phase 3: 컴포넌트 구현
- [ ] 네비게이션 (모바일 포함)
- [ ] 버튼 시스템 (primary, secondary, ghost)
- [ ] 카드 (변형 포함)
- [ ] 입력 필드 + 라벨
- [ ] 섹션 구분 요소 (비정형 구분선 등)

### Phase 4: 인터랙션 & 마무리
- [ ] 스크롤 등장 애니메이션
- [ ] 호버 마이크로인터랙션
- [ ] 페이지 로딩 연출
- [ ] 다크 모드 테스트
- [ ] 모바일 반응형 테스트
- [ ] Lighthouse 성능 점수 확인 (90+ 목표)
- [ ] 색 대비 검증

---

## 12. Anti-AI 최종 점검표

코드를 완성한 후, 다음 질문에 "아니오"가 하나라도 있으면 수정:

| 점검 항목 | 통과? |
|----------|------|
| Inter, Roboto, Poppins 등 AI 선호 폰트를 사용하지 않았는가? | |
| 보라-파랑 그라디언트를 사용하지 않았는가? | |
| 모든 border-radius가 동일하지 않은가? (변화가 있는가?) | |
| 레이아웃에 의도적 비대칭이 포함되어 있는가? | |
| 배경에 질감/텍스처가 있는가? (순수한 flat color만이 아닌가?) | |
| 애니메이션 이징이 기본 ease-in-out만이 아닌가? | |
| 호버 효과에 미세한 회전/기울기 등 "불완전한" 움직임이 있는가? | |
| 폰트 페어링에서 Display와 Body가 다른 카테고리인가? | |
| 카드/요소의 크기와 간격에 변화가 있는가? | |
| 색 대비가 WCAG AA를 통과하는가? | |
| prefers-reduced-motion을 지원하는가? | |
| 순수한 #000000과 #FFFFFF를 사용하지 않았는가? | |
| 한 가지 스타일이 아닌 시각적 "리듬감"이 느껴지는가? | |
| 누군가 보고 "이거 AI가 만들었네"라고 말할 가능성이 낮은가? | |

---

## 13. 구현 예시: HTML+CSS 기본 구조

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Title</title>

  <!-- 폰트: Google Fonts 예시 (프로젝트마다 다르게) -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,600;1,400&family=Karla:wght@400;500;700&display=swap" rel="stylesheet">

  <style>
    /* === CSS Variables === */
    :root {
      --font-display: 'Cormorant Garamond', serif;
      --font-body: 'Karla', sans-serif;

      --ink: #1a1a2e;
      --paper: #faf8f5;
      --primary: #c1440e;
      --secondary: #2d6a4f;
      --muted: rgba(26, 26, 46, 0.55);

      --ease-out: cubic-bezier(0.22, 1, 0.36, 1);
      --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);

      --space-s: clamp(1rem, 2vw, 1.5rem);
      --space-m: clamp(1.5rem, 3vw, 2.5rem);
      --space-l: clamp(2rem, 4vw, 4rem);
      --space-xl: clamp(3rem, 6vw, 6rem);
    }

    /* === Base === */
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: var(--font-body);
      background: var(--paper);
      color: var(--ink);
      line-height: 1.7;
      -webkit-font-smoothing: antialiased;
    }

    /* Grain overlay */
    body::before {
      content: '';
      position: fixed;
      inset: 0;
      opacity: 0.035;
      pointer-events: none;
      z-index: 9999;
      background-image: url("data:image/svg+xml,..."); /* SVG noise */
    }
  </style>
</head>
<body>
  <a href="#main" class="skip-link">본문으로 건너뛰기</a>

  <header class="header">
    <nav><!-- 네비게이션 --></nav>
  </header>

  <main id="main">
    <!-- 콘텐츠 -->
  </main>

  <footer><!-- 푸터 --></footer>
</body>
</html>
```

---

## 참고 연구 & 자료

- Kurosu, M. & Kashimura, K. (1995). "Apparent Usability vs. Inherent Usability"
- Norman, D. (2004). "Emotional Design: Why We Love (or Hate) Everyday Things"
- Tractinsky, N. (1997). "Aesthetics and Apparent Usability"
- Nielsen, J. (2006). "F-Shaped Pattern For Reading Web Content"
- Labrecque, L. & Milne, G. (2012). "Exciting Red and Competent Blue"
- Sweller, J. (1988). "Cognitive Load During Problem Solving"
- Henderson, P., Cote, J., Leong, S., & Schmitt, B. (2004). "Building Strong Brands in Asia"
- Fitts, P. (1954). "The Information Capacity of the Human Motor System"
- Hick, W. E. (1952). "On the Rate of Gain of Information"
- Miller, G. A. (1956). "The Magical Number Seven, Plus or Minus Two"
- Itten, J. (1961). "The Art of Color"
- Creative Bloq (2025). "Anti-AI Crafting: Texture, Warmth and Tactile Rebellion"
- Graphic Design Junction (2025). "15 Web Design Trends Shaping 2026"

---

**이 스킬은 매 프로젝트마다 다른 미학적 방향을 선택하도록 설계되었다. 동일한 디자인을 두 번 만들지 말 것. 매번 새로운 폰트, 새로운 색채, 새로운 레이아웃으로 시작하라.**
