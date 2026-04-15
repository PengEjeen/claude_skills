---
name: performance-optimization
description: 코드 및 시스템 성능을 분석하고 최적화합니다. "느려", "성능", "최적화", "병목", "메모리", "로딩 시간", "응답 시간", "CPU", "latency" 등의 요청 시 사용합니다. 프로파일링, 벤치마킹, 데이터베이스 쿼리 최적화, 프론트엔드 번들 최적화를 포함합니다.
---

# Performance Optimization Skill — Measure First

## 목적
추측이 아닌 측정 기반으로 성능 병목을 찾고 최적화한다.
"느린 것 같아서 최적화했다"가 아닌 "X를 측정했더니 Y가 병목이어서 Z로 개선했다"를 목표로 한다.

## 핵심 원칙
- MUST: 최적화 전에 반드시 측정 (벤치마크/프로파일링)
- MUST: 최적화 후 동일 조건에서 재측정하여 효과 검증
- MUST: 가독성과 성능의 트레이드오프를 명시적으로 판단
- MUST NOT: 측정 없이 "이게 더 빠를 것 같아서" 최적화하지 않기
- MUST NOT: 조기 최적화(premature optimization) — 병목이 아닌 코드 최적화하지 않기

## 성능 분석 프로세스

### Step 1: 현재 상태 측정

#### 백엔드 (API 응답 시간)
```bash
# 단순 응답 시간 측정
time curl -s http://localhost:3000/api/users > /dev/null

# 여러 번 측정 (평균, p95, p99)
for i in {1..100}; do
  curl -o /dev/null -s -w "%{time_total}\n" http://localhost:3000/api/users
done | sort -n | awk '{a[NR]=$1} END {
  print "p50:", a[int(NR*0.5)];
  print "p95:", a[int(NR*0.95)];
  print "p99:", a[int(NR*0.99)];
  print "avg:", s/NR
}'

# 로드 테스트 (동시 접속)
# wrk, k6, autocannon 등 사용
npx autocannon -c 100 -d 30 http://localhost:3000/api/users
```

#### 프론트엔드 (Core Web Vitals)
```bash
# Lighthouse CI
npx lighthouse http://localhost:3000 --output=json --output-path=./report.json

# 핵심 지표:
# - LCP (Largest Contentful Paint): < 2.5s
# - INP (Interaction to Next Paint): < 200ms
# - CLS (Cumulative Layout Shift): < 0.1
# - TTFB (Time to First Byte): < 800ms
```

#### 번들 크기 분석
```bash
# webpack
npx webpack-bundle-analyzer stats.json

# vite
npx vite-bundle-visualizer

# Next.js
ANALYZE=true npm run build
```

### Step 2: 병목 식별

#### 데이터베이스 쿼리
```sql
-- 슬로우 쿼리 확인 (PostgreSQL)
SELECT query, calls, mean_exec_time, total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;

-- 실행 계획 분석
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE user_id = 123;
```

#### N+1 쿼리 탐지
```
1. ORM 쿼리 로그 활성화
2. 반복문 내 개별 쿼리 실행 패턴 확인
3. eager loading / join으로 해결

예 (TypeORM):
// ❌ N+1
const users = await userRepo.find();
for (const user of users) {
  const orders = await orderRepo.find({ where: { userId: user.id } });
}

// ✅ Join
const users = await userRepo.find({ relations: ['orders'] });
```

#### Node.js 프로파일링
```bash
# CPU 프로파일링
node --prof app.js
node --prof-process isolate-*.log > profile.txt

# 메모리 프로파일링
node --inspect app.js
# Chrome DevTools → Memory → Heap Snapshot
```

### Step 3: 최적화 기법

#### 캐싱 전략
```
Layer 1 - 어플리케이션 캐시 (인메모리)
  - 자주 조회, 거의 변경 없는 데이터
  - LRU 캐시, TTL 설정

Layer 2 - 분산 캐시 (Redis)
  - 세션, 자주 조회되는 쿼리 결과
  - Cache-Aside 패턴

Layer 3 - CDN
  - 정적 자산 (이미지, JS, CSS)
  - 적절한 Cache-Control 헤더

Layer 4 - 브라우저 캐시
  - Service Worker 전략
  - HTTP 캐시 헤더
```

#### 데이터베이스 최적화
```
1. 인덱스 추가 (WHERE, JOIN, ORDER BY에 사용되는 컬럼)
2. 쿼리 리팩토링 (서브쿼리 → JOIN, UNION 등)
3. 파티셔닝 (대규모 테이블)
4. 읽기 전용 레플리카 활용
5. Connection pooling 설정 최적화
6. 필요한 컬럼만 SELECT (SELECT * 금지)
```

#### 프론트엔드 최적화
```
1. 코드 스플리팅 (dynamic import)
   - 라우트 기반 분할
   - 컴포넌트 레벨 lazy loading

2. 이미지 최적화
   - WebP/AVIF 포맷 사용
   - 적절한 사이즈 (srcset)
   - lazy loading (loading="lazy")

3. 렌더링 최적화
   - React: React.memo, useMemo, useCallback
   - 가상화 (virtualization) — 긴 리스트
   - debounce/throttle — 빈번한 이벤트

4. 번들 최적화
   - Tree shaking 확인
   - 대형 라이브러리 대체 (moment → dayjs, lodash → es-toolkit)
   - Dynamic import로 초기 번들 축소
```

## 최적화 결과 보고서

```markdown
## Performance Optimization Report

### 측정 환경
- 하드웨어: {사양}
- 데이터: {데이터 규모}
- 동시 사용자: {수}

### Before
| 지표 | 값 |
|------|-----|
| API 응답시간 (p95) | 850ms |
| 번들 크기 | 2.1MB |
| LCP | 3.2s |

### After
| 지표 | 값 | 개선율 |
|------|-----|--------|
| API 응답시간 (p95) | 120ms | 85% ↓ |
| 번들 크기 | 680KB | 68% ↓ |
| LCP | 1.4s | 56% ↓ |

### 적용된 최적화
1. {최적화 내용} → {효과}
2. {최적화 내용} → {효과}

### 트레이드오프
- {무엇을 포기했는지} / {왜 괜찮은지}
```
