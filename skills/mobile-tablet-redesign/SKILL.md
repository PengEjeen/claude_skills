# Mobile & Tablet UX Redesign (2026)

모바일/태블릿 전용 UX 리디자인. PC 버전에 영향 없이 독립적으로 터치 디바이스에 최적화된 인터페이스를 구현합니다.

## Context

PC 레이아웃을 단순히 축소하는 것이 아니라, 각 디바이스의 물리적 특성(터치, 뷰포트, 한 손 조작, 네트워크)에 맞는 **네이티브급 경험**을 설계합니다. 기존 데스크톱 코드는 건드리지 않고, 모바일/태블릿 전용 코드를 분리합니다.

---

## 핵심 원칙

### 1. PC 격리 (Zero Desktop Impact)

```
절대 규칙: 데스크톱 렌더링 경로를 수정하지 않는다.

방법 A: Breakpoint 컴포넌트로 분기
  <Breakpoint desktop><DesktopLayout /></Breakpoint>
  <Breakpoint belowDesktop><MobileTabletLayout /></Breakpoint>

방법 B: useResponsive() 훅으로 분기
  const { isMobile, isTablet, belowDesktop } = useResponsive();
  if (belowDesktop) return <MobileView />;
  return <DesktopView />;  // 기존 코드 그대로

방법 C: CSS Media Query 격리
  /* 데스크톱 스타일은 건드리지 않음 */
  @media (max-width: 1023px) { /* 모바일/태블릿 전용 */ }
```

### 2. 디바이스 물리 특성 존중

```
┌─────────────────────────────────────────────────┐
│  모바일 (0-767px)                                │
│  ─────────────────                               │
│  • 한 손 조작 (엄지 영역: 하단 1/3)              │
│  • 뷰포트: 360-428px 폭                         │
│  • 터치 타겟: 최소 48px × 48px                   │
│  • 세로 모드 우선                                │
│  • 네트워크: 4G/5G (지연 고려)                   │
│  • 키보드: 가상 키보드 (뷰포트 축소)             │
├─────────────────────────────────────────────────┤
│  태블릿 (768-1023px)                             │
│  ─────────────────                               │
│  • 양 손 조작 (양쪽 엄지 + 검지)                │
│  • 뷰포트: 768-1024px 폭                        │
│  • 터치 타겟: 최소 44px × 44px                   │
│  • 가로/세로 모드 모두 고려                      │
│  • Apple Pencil / S-Pen 지원 가능                │
│  • Split View 고려                               │
└─────────────────────────────────────────────────┘
```

### 3. Mobile-First 사고방식

```
"모바일에서 뭘 보여줄까?"가 아니라
"모바일에서 뭘 할 수 있을까?"로 사고한다.

❌ 데스크톱 콘텐츠를 축소/숨김
✅ 모바일에서의 핵심 태스크를 정의하고 그에 맞는 UI 설계
```

---

## 프로젝트 반응형 시스템

### Breakpoints (src/constants/designTokens.ts)
```typescript
BREAKPOINTS = {
  sm: '640px',    // 작은 모바일
  md: '768px',    // 태블릿 시작
  lg: '1024px',   // 데스크톱 시작
  xl: '1280px',   // 대형 데스크톱
  '2xl': '1536px' // 울트라와이드
}
```

### 사용 가능한 도구
```typescript
// Hook
const { isMobile, isTablet, isDesktop, belowDesktop, isSmallMobile } = useResponsive();

// Component
<Breakpoint mobile>...</Breakpoint>
<Breakpoint tablet>...</Breakpoint>
<Breakpoint belowDesktop>...</Breakpoint>

// Grid
<ResponsiveGrid columns={3} tabletColumns={2} mobileColumns={1}>
  {children}
</ResponsiveGrid>

// CSS
MEDIA_QUERIES.mobile     // @media (max-width: 767px)
MEDIA_QUERIES.tablet     // @media (min-width: 768px) and (max-width: 1023px)
MEDIA_QUERIES.belowDesktop // @media (max-width: 1023px)
```

---

## 모바일 UX 패턴 (2026)

### A. 네비게이션

```
❌ 햄버거 메뉴 → 클릭 2번 필요, 발견성 낮음
✅ Bottom Tab Bar → 핵심 4-5개 항목, 엄지 영역

❌ 상단 고정 헤더 (공간 낭비)
✅ 스크롤 시 숨김, 위로 스크롤 시 노출 (auto-hide header)

❌ Breadcrumb (모바일에서 길어짐)
✅ 뒤로 가기 + 현재 섹션 제목
```

```tsx
// Bottom Tab Bar 패턴
const MobileNavBar = () => (
  <nav style={{
    position: 'fixed',
    bottom: 0,
    left: 0,
    right: 0,
    height: '64px',
    paddingBottom: 'env(safe-area-inset-bottom)',
    background: '#FFFFFF',
    borderTop: '1px solid #E5E7EB',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-around',
    zIndex: 1000,
  }}>
    {tabs.map(tab => (
      <button key={tab.id} style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '2px',
        padding: '8px 16px',
        minWidth: '64px',
        minHeight: '48px', // 터치 타겟
      }}>
        <tab.Icon size={20} />
        <span style={{ fontSize: '11px' }}>{tab.label}</span>
      </button>
    ))}
  </nav>
);
```

### B. 스크롤 & 콘텐츠

```
❌ 긴 스크롤 페이지 (모바일에서 끝이 안 보임)
✅ 섹션 스냅 스크롤 또는 카드 스와이프

❌ 큰 이미지/비디오 자동 로드
✅ Intersection Observer로 lazy load + placeholder

❌ 모달/팝업 (모바일에서 닫기 어려움)
✅ Bottom Sheet (아래에서 올라오는 패널)

❌ 호버 효과에 의존
✅ 탭 피드백 (ripple, scale, haptic)
```

```tsx
// Bottom Sheet 패턴
const BottomSheet = ({ open, onClose, children }) => (
  <AnimatePresence>
    {open && (
      <>
        <motion.div  // Backdrop
          initial={{ opacity: 0 }}
          animate={{ opacity: 0.5 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
          style={{ position: 'fixed', inset: 0, background: '#000', zIndex: 999 }}
        />
        <motion.div  // Sheet
          initial={{ y: '100%' }}
          animate={{ y: 0 }}
          exit={{ y: '100%' }}
          transition={{ type: 'spring', damping: 30, stiffness: 300 }}
          drag="y"
          dragConstraints={{ top: 0 }}
          dragElastic={0.2}
          onDragEnd={(_, info) => {
            if (info.offset.y > 100) onClose();
          }}
          style={{
            position: 'fixed',
            bottom: 0,
            left: 0,
            right: 0,
            maxHeight: '85vh',
            background: '#FFFFFF',
            borderRadius: '20px 20px 0 0',
            padding: '12px 20px 20px',
            paddingBottom: 'calc(20px + env(safe-area-inset-bottom))',
            zIndex: 1000,
            overflowY: 'auto',
          }}
        >
          {/* Drag Handle */}
          <div style={{
            width: '36px',
            height: '4px',
            borderRadius: '2px',
            background: '#D1D5DB',
            margin: '0 auto 16px',
          }} />
          {children}
        </motion.div>
      </>
    )}
  </AnimatePresence>
);
```

### C. 폼 & 입력

```
❌ 작은 input + 작은 버튼
✅ 전체 폭 input (height: 52px+) + 큰 CTA 버튼

❌ 다단 폼 레이아웃
✅ 단일 컬럼, 한 번에 하나씩

❌ Select 드롭다운 (모바일에서 불편)
✅ Action Sheet 또는 네이티브 select

❌ 날짜 입력 커스텀 UI
✅ input type="date" (네이티브 날짜 피커)

❌ 키보드 올라올 때 UI 깨짐
✅ visualViewport API 활용 + scroll-into-view
```

```tsx
// 모바일 최적화 입력 필드
const MobileInput = ({ label, ...props }) => (
  <div style={{ marginBottom: '16px' }}>
    <label style={{
      display: 'block',
      fontSize: '13px',
      fontWeight: 600,
      color: '#374151',
      marginBottom: '6px',
    }}>{label}</label>
    <input
      {...props}
      style={{
        width: '100%',
        height: '52px',
        padding: '0 16px',
        fontSize: '16px', // 16px 미만이면 iOS에서 자동 줌
        border: '2px solid #E5E7EB',
        borderRadius: '12px',
        background: '#F9FAFB',
        WebkitAppearance: 'none', // iOS 기본 스타일 제거
        ...props.style,
      }}
    />
  </div>
);
```

### D. 터치 인터랙션

```
2026 터치 UX 기준:
─────────────────
• 터치 타겟: 최소 48×48px (WCAG 2.2 Level AA)
• 간격: 인접 터치 타겟 사이 8px 이상
• 제스처: 스와이프(뒤로), 핀치(줌), 길게 누르기(컨텍스트)
• 피드백: 탭 시 시각적 피드백 100ms 이내
• 스크롤: -webkit-overflow-scrolling: touch (관성 스크롤)
• 실수 방지: 파괴적 동작은 확인 단계 추가
```

```css
/* 터치 최적화 CSS */
.touch-target {
  min-height: 48px;
  min-width: 48px;
  -webkit-tap-highlight-color: transparent;
  touch-action: manipulation; /* 더블탭 줌 비활성화 */
  user-select: none;
}

/* 터치 피드백 */
.touch-target:active {
  transform: scale(0.97);
  opacity: 0.8;
  transition: transform 0.1s ease, opacity 0.1s ease;
}

/* 관성 스크롤 */
.scroll-container {
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  overscroll-behavior-y: contain; /* 부모 스크롤 방지 */
}

/* 수평 스와이프 */
.swipe-container {
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
}
.swipe-container::-webkit-scrollbar { display: none; }
.swipe-item {
  scroll-snap-align: start;
  flex-shrink: 0;
}
```

### E. 성능 (모바일 우선)

```
모바일 성능 예산 (2026):
────────────────────────
• FCP (First Contentful Paint): < 1.8s (4G)
• LCP (Largest Contentful Paint): < 2.5s
• CLS (Cumulative Layout Shift): < 0.1
• INP (Interaction to Next Paint): < 200ms
• 번들 크기: 모바일 초기 로드 < 200KB (gzip)
```

```tsx
// 모바일 이미지 최적화
const MobileImage = ({ src, alt, ...props }) => (
  <img
    src={src}
    alt={alt}
    loading="lazy"
    decoding="async"
    fetchPriority={props.priority ? 'high' : 'auto'}
    style={{
      width: '100%',
      height: 'auto',
      aspectRatio: props.aspectRatio || '16/9',
      objectFit: 'cover',
      ...props.style,
    }}
  />
);

// 모바일 비디오: 자동재생 대신 포스터 + 탭 재생
const MobileVideo = ({ src, poster }) => {
  const [playing, setPlaying] = useState(false);
  const ref = useRef<HTMLVideoElement>(null);

  return (
    <div style={{ position: 'relative' }} onClick={() => {
      if (ref.current) {
        playing ? ref.current.pause() : ref.current.play();
        setPlaying(!playing);
      }
    }}>
      <video
        ref={ref}
        src={playing ? src : undefined}
        poster={poster}
        playsInline
        muted
        preload="none"
        style={{ width: '100%', aspectRatio: '16/9', objectFit: 'cover' }}
      />
      {!playing && (
        <div style={{
          position: 'absolute', inset: 0,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          background: 'rgba(0,0,0,0.3)',
        }}>
          <div style={{
            width: '56px', height: '56px', borderRadius: '50%',
            background: 'rgba(255,255,255,0.9)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>▶</div>
        </div>
      )}
    </div>
  );
};
```

---

## 태블릿 UX 패턴 (2026)

### 태블릿 고유 특성

```
태블릿은 모바일도 데스크톱도 아닌 "제3의 디바이스"

✅ 활용할 것:
  • 넓은 화면 → 2컬럼 레이아웃, Split View
  • 멀티태스킹 → iPadOS Split View 대응
  • Apple Pencil → 정밀 인터랙션 (선택적)
  • 가로 모드 → 별도 레이아웃 고려

❌ 피할 것:
  • 모바일 레이아웃 그대로 늘리기
  • 데스크톱 레이아웃 그대로 줄이기
  • 한 손 조작 가정 (양 손 조작이 기본)
```

```tsx
// 태블릿 Split View 레이아웃
const TabletSplitLayout = ({ sidebar, main }) => (
  <div style={{
    display: 'grid',
    gridTemplateColumns: '320px 1fr',
    height: '100vh',
    overflow: 'hidden',
  }}>
    <aside style={{
      borderRight: '1px solid #E5E7EB',
      overflowY: 'auto',
      padding: '24px',
    }}>
      {sidebar}
    </aside>
    <main style={{
      overflowY: 'auto',
      padding: '24px 32px',
    }}>
      {main}
    </main>
  </div>
);

// 태블릿 2-Column Card Grid
const TabletCardGrid = ({ items }) => (
  <div style={{
    display: 'grid',
    gridTemplateColumns: 'repeat(2, 1fr)',
    gap: '20px',
    padding: '24px',
  }}>
    {items.map((item, i) => (
      <div key={i} style={{
        padding: '24px',
        background: '#FFFFFF',
        border: '1px solid #E5E7EB',
        borderRadius: '16px',
      }}>
        {item}
      </div>
    ))}
  </div>
);
```

---

## Safe Area & 노치/펀치홀 대응

```css
/* iOS Safe Area (노치, 다이나믹 아일랜드) */
.mobile-layout {
  padding-top: env(safe-area-inset-top);
  padding-bottom: env(safe-area-inset-bottom);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}

/* 하단 고정 요소 (Bottom Bar, FAB) */
.bottom-fixed {
  position: fixed;
  bottom: 0;
  padding-bottom: env(safe-area-inset-bottom);
}

/* iOS 가상 키보드 대응 */
.input-area {
  /* visualViewport API로 키보드 높이 감지 */
  padding-bottom: var(--keyboard-height, 0px);
}
```

---

## 리디자인 작업 프로세스

### Phase 1: 분석
```
1. 대상 페이지/컴포넌트 식별
2. 현재 모바일 렌더링 스크린샷 캡처
3. 터치 타겟 크기 감사 (48px 미만 식별)
4. 스크롤 깊이 & 콘텐츠 계층 분석
5. 핵심 사용자 태스크 정의
```

### Phase 2: 설계
```
1. 모바일 와이어프레임 (콘텐츠 우선순위)
2. 태블릿 와이어프레임 (2컬럼 활용)
3. 터치 인터랙션 정의
4. 애니메이션 계획 (성능 고려)
5. PC 격리 전략 확인
```

### Phase 3: 구현
```
1. 모바일 전용 컴포넌트 생성 (Mobile*.tsx)
2. Breakpoint 또는 useResponsive()로 분기
3. CSS 격리 (@media max-width: 1023px)
4. 터치 이벤트 & 제스처 구현
5. Safe Area 적용
```

### Phase 4: 검증
```
1. Chrome DevTools 모바일 시뮬레이터
2. 실기기 테스트 (iOS Safari, Android Chrome)
3. 터치 타겟 크기 검증
4. 성능 측정 (Lighthouse Mobile)
5. 데스크톱 회귀 테스트 (PC 영향 없음 확인)
```

---

## 파일 구조 컨벤션

```
src/
├── features/
│   └── home/
│       ├── sections/
│       │   ├── HeroSection.tsx          # 기존 (공통 또는 데스크톱)
│       │   ├── HeroSection.mobile.tsx   # 모바일 전용 (신규)
│       │   └── HeroSection.tablet.tsx   # 태블릿 전용 (필요시)
│       └── layouts/
│           └── MobileHomeLayout.tsx     # 모바일 전체 레이아웃
├── shared/
│   └── mobile/
│       ├── BottomSheet.tsx
│       ├── BottomTabBar.tsx
│       ├── SwipeCarousel.tsx
│       ├── MobileInput.tsx
│       ├── TouchFeedback.tsx
│       └── AutoHideHeader.tsx
└── styles/
    └── mobile.css                       # 모바일 전용 글로벌 스타일
```

```tsx
// 분기 패턴 (기존 컴포넌트에서)
import { Breakpoint } from '@/shared/responsive/Breakpoint';

const HeroSection = () => (
  <>
    <Breakpoint desktop>
      <DesktopHero />  {/* 기존 코드 그대로 */}
    </Breakpoint>
    <Breakpoint belowDesktop>
      <MobileHero />   {/* 새로 만든 모바일 버전 */}
    </Breakpoint>
  </>
);
```

---

## 체크리스트

### 구현 전
```
□ 대상 페이지/컴포넌트 목록 작성
□ 핵심 사용자 태스크 정의
□ PC 격리 전략 확정 (Breakpoint vs useResponsive vs CSS)
□ 터치 인터랙션 목록
```

### 구현 중
```
□ 터치 타겟 48px 이상
□ 폰트 크기 16px 이상 (input: iOS 자동 줌 방지)
□ Safe Area 적용
□ 가상 키보드 대응
□ 이미지/비디오 lazy loading
□ 스크롤 성능 (will-change, transform 사용)
□ 호버 의존 없음 (터치 대체)
```

### 구현 후
```
□ 데스크톱 렌더링 변경 없음 확인
□ 모바일 Lighthouse 점수 90+
□ 실기기 테스트 (iPhone, Galaxy, iPad)
□ 가로/세로 모드 확인
□ 다크모드 대응 (있는 경우)
□ 접근성 (VoiceOver, TalkBack)
```

---

## 2026 모바일 트렌드

### 적용할 것
```
1. Scroll-Driven Animations (CSS scroll-timeline)
2. View Transitions API (페이지 전환)
3. Container Queries (컴포넌트 기반 반응형)
4. Subgrid (중첩 그리드 정렬)
5. :has() 선택자 (부모 기반 스타일링)
6. Popover API (네이티브 팝오버)
7. Dialog element (네이티브 모달)
8. Anchor Positioning (CSS 앵커)
```

### 피할 것
```
1. 과도한 JS 애니메이션 (CSS 우선)
2. 커스텀 스크롤바 (네이티브 유지)
3. Pull-to-refresh 커스텀 (브라우저 기본 사용)
4. 뷰포트 단위 vh (lvh, svh, dvh 사용)
5. position: fixed 남용 (iOS 이슈)
6. 무한 스크롤 (페이지네이션 + "더 보기" 권장)
```

### CSS 뷰포트 단위 (2026)
```css
/* ❌ 기존: 주소바에 의해 변동 */
height: 100vh;

/* ✅ 2026: 정확한 뷰포트 */
height: 100svh;  /* Small Viewport Height (주소바 펼쳐진 상태) */
height: 100lvh;  /* Large Viewport Height (주소바 접힌 상태) */
height: 100dvh;  /* Dynamic Viewport Height (실시간 반영) */
```
