---
name: dev-journal
description: 개발 일지를 자동으로 생성하고 관리합니다. "개발 일지", "작업 기록", "개발 로그", "변경 이력", "dev journal", "development log", "work log" 등의 요청 시 사용합니다. 프로젝트 히스토리, 의사결정 과정, 문제 해결 기록을 체계적으로 문서화합니다. (README·API 문서·코드 문서화는 documentation-gen 스킬 참조)
---

# Development Journal Skill

자동으로 개발 일지를 생성하고 관리하여 프로젝트 히스토리, 의사결정, 문제 해결 과정을 체계적으로 문서화합니다.

## Purpose

개발 과정에서 발생하는 모든 중요한 정보를 자동으로 추적하고 문서화하여:
- 신규 팀원 온보딩 가속화
- 의사결정 근거 추적
- 반복적인 문제 해결 시간 단축
- 프로젝트 회고 자료 확보
- 지식 손실 방지

## When to Use

다음 상황에서 이 스킬을 사용하세요:
- 스프린트 종료 후 주간 요약 필요
- 중요한 아키텍처 결정 기록
- 버그 수정 과정 문서화
- 월간 개발 리포트 생성
- 프로젝트 인수인계 준비

## 일지 유형

### 1. Daily Log (일일 로그)

Git commit 기반 자동 생성:

```markdown
# 2026-01-29 개발 일지

## 커밋 요약 (3 commits)

### [feat] Add user authentication (#42)
**Time:** 10:23 AM
**Author:** 홍길동
**Files:** `src/auth/`, `tests/auth/`

- JWT 기반 인증 구현
- Access token + Refresh token 패턴
- 80% 테스트 커버리지 달성

**Related Issue:** #38
**Review:** https://github.com/org/repo/pull/42

---

### [fix] Resolve race condition in cache (#43)
**Time:** 2:15 PM
**Author:** 김철수
**Files:** `src/cache/redis.ts`

**Problem:** 동시 요청 시 캐시 miss로 DB 폭증
**Solution:** Redis distributed lock 적용
**Impact:** DB 쿼리 95% 감소

**Related Issue:** #40
**Before/After:**
- Before: 1000 req/s → 800 DB queries/s
- After: 1000 req/s → 50 DB queries/s

---

### [refactor] Simplify error handling (#44)
**Time:** 4:45 PM
**Author:** 이영희
**Files:** `src/utils/errors.ts`

- Result<T, E> 타입 도입
- try-catch 제거 (30개 → 5개)
- 에러 핸들링 일관성 확보

---

## 의사결정 (Decisions Made)

### 인증 방식: JWT vs Session
**Decision:** JWT (stateless)
**Rationale:**
- 마이크로서비스 아키텍처에 적합
- 수평 확장 용이
- 모바일 앱 지원 필요

**Trade-offs:**
- ✅ Stateless, 확장 용이
- ❌ Token revocation 어려움 → Refresh token으로 완화

**Alternatives Considered:**
- Session (rejected: Redis 의존성, 확장 복잡)
- OAuth 2.0 (deferred: 현재 불필요)

**ADR:** docs/adr/0042-jwt-authentication.md

---

## 문제 해결 (Problems Solved)

### 1. Race Condition in Cache
**Impact:** HIGH
**Root Cause:** 동시 요청 시 캐시 miss 발생 → 모두 DB 조회
**Solution:** Redis SETNX로 distributed lock
**Time to Resolve:** 3 hours
**Learnings:** 분산 환경에서 캐시 warming 전략 필요

---

## 버그 (Bugs Fixed)

| ID | 제목 | 심각도 | 소요 시간 | 커밋 |
|----|------|--------|----------|------|
| #40 | Cache race condition | HIGH | 3h | abc1234 |
| #41 | User creation 500 error | MEDIUM | 1h | def5678 |

---

## 테스트 (Tests Written)

- **Unit Tests:** 12 added (auth module)
- **Integration Tests:** 3 added (API endpoints)
- **E2E Tests:** 1 added (login flow)
- **Coverage:** 78% → 82% (+4%)

---

## 메트릭 (Metrics)

- **Commits:** 3
- **Lines Added:** +450
- **Lines Deleted:** -230
- **Files Changed:** 15
- **Pull Requests:** 2 merged, 1 pending
- **Code Review Comments:** 8 resolved

---

## 내일 할 일 (Tomorrow)

- [ ] Refresh token rotation 구현
- [ ] 인증 E2E 테스트 추가
- [ ] 성능 테스트 (1000 req/s)
- [ ] 문서 업데이트 (API 명세서)
```

### 2. Weekly Summary (주간 요약)

```markdown
# 주간 요약 (2026-01-23 ~ 2026-01-29)

## Highlights

### 🚀 주요 성과
1. **사용자 인증 시스템 완료** (Issue #38)
   - JWT 기반 인증 구현
   - 80%+ 테스트 커버리지
   - 보안 리뷰 통과

2. **성능 개선** (Issue #40)
   - 캐시 race condition 해결
   - DB 쿼리 95% 감소
   - 응답 시간 200ms → 50ms

3. **코드 품질 향상**
   - Result 타입 도입으로 에러 처리 개선
   - ESLint 위반 30개 → 0개

### 📊 통계

| 지표 | 이번 주 | 지난 주 | 변화 |
|------|---------|---------|------|
| Commits | 18 | 12 | +50% |
| PRs Merged | 6 | 4 | +50% |
| Issues Closed | 8 | 5 | +60% |
| Test Coverage | 82% | 78% | +4% |
| Code Review Time | 3h avg | 5h avg | -40% |

### 🐛 버그 해결

- **HIGH:** 1개 (cache race condition)
- **MEDIUM:** 3개
- **LOW:** 2개
- **Total MTTR:** 2.5 hours (평균)

### 🎯 목표 달성률

- ✅ 인증 시스템 구현 (100%)
- ✅ 성능 최적화 (100%)
- ⏳ API 문서화 (60% - 진행 중)
- ❌ 모바일 SDK 시작 (0% - 다음 주)

---

## Architecture Decisions

### ADR-042: JWT Authentication
**Status:** ✅ Accepted
**Date:** 2026-01-27
**Impact:** HIGH

**Context:** 사용자 인증 방식 결정 필요
**Decision:** JWT (stateless) 채택
**Consequences:** 확장 용이, token revocation 어려움
**Link:** docs/adr/0042-jwt-authentication.md

### ADR-043: Redis Distributed Lock
**Status:** ✅ Accepted
**Date:** 2026-01-29
**Impact:** MEDIUM

**Context:** 캐시 race condition 해결 필요
**Decision:** Redis SETNX로 distributed lock 구현
**Consequences:** 캐시 일관성 확보, Redis 의존성 증가
**Link:** docs/adr/0043-redis-distributed-lock.md

---

## Technical Debt

### 추가된 부채
1. **Refresh token rotation 미구현**
   - Priority: HIGH
   - Estimated: 2 days
   - Reason: 시간 부족, 우선순위 낮음

### 해결된 부채
1. ✅ **Error handling 불일치**
   - Result 타입 도입으로 해결
   - 30개 try-catch → 5개

---

## Learnings & Insights

### 배운 것
1. **분산 환경 캐싱**
   - 단순 캐시는 race condition 발생
   - Distributed lock 필수
   - Cache warming 전략 필요

2. **JWT 보안**
   - Access token 짧게 (15분)
   - Refresh token rotation 필요
   - HttpOnly cookie 권장

### 개선 포인트
1. **코드 리뷰 시간 단축**
   - Before: 5h avg
   - After: 3h avg
   - How: PR 크기 제한 (300 LOC), 자동화된 체크리스트

2. **테스트 커버리지 증가**
   - 78% → 82%
   - TDD 워크플로우 적용 효과

---

## Risks & Issues

### 🔴 HIGH Risk
- **Refresh token rotation 미구현**
  - Impact: 보안 취약점
  - Mitigation: 다음 주 우선 처리

### 🟡 MEDIUM Risk
- **API 문서 미완성**
  - Impact: 프론트엔드 개발 지연 가능
  - Mitigation: 이번 주 금요일까지 완료

---

## Next Week Goals

1. **Refresh token rotation** (HIGH)
2. **API 문서 완성** (MEDIUM)
3. **모바일 SDK 시작** (MEDIUM)
4. **E2E 테스트 확대** (LOW)

---

## Team Updates

- **홍길동:** 인증 시스템 리드, 다음 주 모바일 SDK 시작
- **김철수:** 성능 최적화 완료, 다음 주 캐싱 전략 문서화
- **이영희:** 코드 품질 개선, 다음 주 리팩토링 계속
```

### 3. Architecture Decision Record (ADR)

```markdown
# ADR-042: JWT 기반 인증 채택

**Status:** Accepted
**Date:** 2026-01-27
**Deciders:** 홍길동, 김철수, 이영희
**Tags:** #authentication #security #architecture

---

## Context

사용자 인증 시스템 구현이 필요합니다. 현재 시스템:
- 모놀리식 → 마이크로서비스 전환 예정
- 웹 + 모바일 앱 동시 지원 필요
- 사용자 5만 명 예상 (6개월 내)

**요구사항:**
- Stateless (수평 확장 가능)
- CORS 지원
- 모바일 친화적
- 보안 표준 준수

---

## Decision

**JWT (JSON Web Token) 기반 인증**을 채택합니다.

**구현 방식:**
```
Access Token (JWT):
- Expiry: 15 minutes
- Storage: Memory (React state)
- Claims: user_id, email, roles

Refresh Token:
- Expiry: 7 days
- Storage: HttpOnly cookie
- Purpose: Access token 재발급

Token Rotation:
- Refresh 시 새로운 Refresh token 발급 (미구현, 다음 주 추가)
```

---

## Consequences

### Positive

1. **확장성**
   - Stateless: 서버 간 세션 공유 불필요
   - 수평 확장 용이

2. **마이크로서비스 친화적**
   - 각 서비스가 JWT 검증 가능
   - API Gateway에서 중앙 검증 가능

3. **모바일 지원**
   - Token 기반이라 네이티브 앱에 적합
   - Cookie 의존성 없음

4. **CORS 간단**
   - Authorization 헤더 사용
   - Preflight 요청 최소화

### Negative

1. **Token Revocation 어려움**
   - JWT는 발급 후 취소 불가능
   - Mitigation: 짧은 expiry (15분) + Refresh token

2. **Token 크기**
   - 세션 ID보다 큼 (200-300 bytes)
   - 매 요청마다 전송
   - Impact: 무시 가능 (gzip 적용 시)

3. **보안 리스크**
   - XSS 공격 시 Access token 탈취 가능
   - Mitigation: HttpOnly cookie에 Refresh token 저장

### Neutral

1. **추가 구현 필요**
   - Refresh token rotation (다음 주)
   - Token blacklist (optional, 우선순위 낮음)

---

## Alternatives Considered

### 1. Session-based Authentication
**Pros:**
- 서버에서 세션 취소 가능
- 간단한 구현

**Cons:**
- Stateful: Redis/DB 필요
- 수평 확장 복잡
- 마이크로서비스에 부적합

**Decision:** ❌ Rejected

---

### 2. OAuth 2.0 (Authorization Code Flow)
**Pros:**
- 표준 프로토콜
- 써드파티 로그인 지원

**Cons:**
- 현재 불필요 (자체 인증만)
- 구현 복잡도 높음
- 추가 인프라 필요 (Authorization Server)

**Decision:** ⏸️ Deferred (향후 소셜 로그인 추가 시 재검토)

---

### 3. Opaque Token + Introspection
**Pros:**
- Token revocation 가능
- Payload 노출 없음

**Cons:**
- 매 요청마다 DB 조회
- 성능 병목 가능

**Decision:** ❌ Rejected (Stateless 요구사항 위배)

---

## Implementation Plan

### Phase 1: 기본 구현 (완료)
- [x] JWT 발급 (Access + Refresh)
- [x] 토큰 검증 미들웨어
- [x] Login/Logout 엔드포인트
- [x] 80%+ 테스트 커버리지

### Phase 2: 보안 강화 (다음 주)
- [ ] Refresh token rotation
- [ ] Rate limiting (login endpoint)
- [ ] Brute-force 방어

### Phase 3: 모니터링 (2주 후)
- [ ] Token 발급/검증 메트릭
- [ ] 실패 로그 수집
- [ ] 알림 설정

---

## References

- [RFC 7519: JSON Web Token](https://tools.ietf.org/html/rfc7519)
- [OWASP JWT Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html)
- [Internal Security Review](link-to-doc)
- [PR #42: JWT Implementation](https://github.com/org/repo/pull/42)

---

## Related ADRs

- ADR-038: API Gateway Architecture
- ADR-040: Microservices Communication
- ADR-043: Redis Distributed Lock (related: token blacklist 검토)

---

## Follow-up

- **2주 후 리뷰:** Refresh token rotation 효과 측정
- **1개월 후 회고:** 보안 이슈 발생 여부 확인
- **3개월 후 재평가:** OAuth 2.0 필요성 재검토
```

### 4. Problem-Solution Log

```markdown
# 문제 해결 로그

## 2026-01-29: Cache Race Condition

### 문제 (Problem)
**Severity:** HIGH
**Impact:** DB 쿼리 10배 증가, 응답 시간 5배 증가
**Reporter:** 모니터링 알림 (Datadog)

**증상:**
- 동시 요청 1000 req/s 시 DB 쿼리 800 queries/s
- Expected: 50 queries/s (cache hit ratio 95%)
- 피크 타임에 DB CPU 100%

**재현 조건:**
```bash
# 동시 요청 100개
ab -n 100 -c 100 http://localhost:8000/api/users/123
```

**에러 로그:**
```
[ERROR] Cache miss for key: user:123
[ERROR] Cache miss for key: user:123
[ERROR] Cache miss for key: user:123
... (동시에 100개 발생)
```

---

### 근본 원인 (Root Cause)

**분석 과정:**
1. 캐시 로직 확인 → Cache-Aside 패턴 사용
2. 동시 요청 시 모두 cache miss 발생
3. 모두 DB 조회 → 모두 캐시 저장 (race condition)

**Root Cause:**
```typescript
// 기존 코드 (문제)
async function getUser(id: string): Promise<User> {
  // 1. 모두 캐시 확인 → miss
  const cached = await cache.get(`user:${id}`);
  if (cached) return cached;

  // 2. 모두 DB 조회 (동시에 100개 쿼리!)
  const user = await db.users.findById(id);

  // 3. 모두 캐시 저장
  await cache.set(`user:${id}`, user, 3600);

  return user;
}
```

**Diagram:**
```
Request 1: [Cache Miss] → [DB Query] → [Cache Set]
Request 2: [Cache Miss] → [DB Query] → [Cache Set]  ← 동시 발생
Request 3: [Cache Miss] → [DB Query] → [Cache Set]
...
```

---

### 해결 방법 (Solution)

**Approach:** Redis Distributed Lock (SETNX)

```typescript
// 개선된 코드
import Redis from 'ioredis';

const redis = new Redis();

async function getUser(id: string): Promise<User> {
  const cacheKey = `user:${id}`;
  const lockKey = `lock:${cacheKey}`;

  // 1. 캐시 확인
  const cached = await cache.get(cacheKey);
  if (cached) return cached;

  // 2. Lock 획득 시도 (10초 TTL)
  const lockAcquired = await redis.set(
    lockKey,
    'locked',
    'EX', 10,
    'NX'  // SET if Not eXists
  );

  if (lockAcquired) {
    try {
      // 3. Double-check cache (다른 프로세스가 저장했을 수 있음)
      const cachedAgain = await cache.get(cacheKey);
      if (cachedAgain) return cachedAgain;

      // 4. DB 조회 (lock 획득한 1개만 실행)
      const user = await db.users.findById(id);

      // 5. 캐시 저장
      await cache.set(cacheKey, user, 3600);

      return user;
    } finally {
      // 6. Lock 해제
      await redis.del(lockKey);
    }
  } else {
    // 7. Lock 대기 (다른 프로세스가 DB 조회 중)
    await sleep(100);  // 100ms 대기
    return getUser(id);  // 재시도 (이번엔 캐시 hit)
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}
```

**개선 결과:**
```
Before:
  1000 req/s → 800 DB queries/s
  Response time: 200ms avg

After:
  1000 req/s → 50 DB queries/s (95% cache hit)
  Response time: 50ms avg

Improvement:
  - DB queries: -94%
  - Response time: -75%
```

---

### 학습 내용 (Learnings)

1. **Cache-Aside 패턴의 한계**
   - 고트래픽 환경에서 race condition 발생
   - Distributed lock 필수

2. **Distributed Lock 구현**
   - Redis SETNX 사용
   - TTL 설정으로 deadlock 방지
   - Double-check 패턴으로 불필요한 대기 방지

3. **모니터링 중요성**
   - 문제를 조기에 발견 (Datadog 알림)
   - 메트릭 추적으로 개선 효과 측정

---

### 추가 개선 사항

1. **Cache Warming**
   - 서버 시작 시 인기 데이터 미리 캐싱
   - Cold start 문제 해결

2. **Lock 최적화**
   - Redlock 알고리즘 적용 (고가용성)
   - Lock timeout 튜닝 (10초 → 5초)

3. **모니터링 강화**
   - Lock 획득 시간 메트릭 추가
   - Lock 대기 횟수 추적

---

### 관련 자료

- **PR:** #43 - Add Redis distributed lock
- **ADR:** docs/adr/0043-redis-distributed-lock.md
- **Issue:** #40 - Cache race condition
- **Commit:** def5678 - Fix cache race condition

---

### 시간 소요

- **분석:** 1 hour
- **구현:** 1.5 hours
- **테스트:** 0.5 hour
- **Total:** 3 hours
```

---

## 자동 생성 워크플로우

### Git Commit 기반 일지 생성

```bash
# 오늘 커밋들로 일지 생성
git log --since="today" --pretty=format:"%h|%an|%ad|%s" --date=format:"%H:%M" \
  | while IFS='|' read hash author time subject; do
    echo "### [$subject]"
    echo "**Time:** $time"
    echo "**Author:** $author"
    echo "**Commit:** $hash"
    echo ""
    # 파일 목록
    git show --name-only --pretty="" $hash | head -5
    echo ""
  done > journal/$(date +%Y-%m-%d).md
```

### Claude Code로 일지 생성

```bash
# 일일 로그
/dev-journal --daily

# 주간 요약
/dev-journal --weekly

# ADR 생성
/dev-journal --adr "JWT Authentication"

# 문제 해결 로그
/dev-journal --problem "Cache race condition"
```

---

## 출력 형식

이 스킬 사용 시 다음 형식으로 출력:

1. **Markdown 파일 생성**
   - 위치: `docs/journal/YYYY-MM-DD.md`
   - Git에 자동 커밋 (optional)

2. **요약 통계**
   - 커밋 수, PR 수, 이슈 수
   - 테스트 커버리지 변화
   - 주요 변경 사항

3. **자동 태그**
   - #bug, #feature, #refactor
   - #high-impact, #performance
   - #security, #architecture

---

## 통합 기능

### GitHub Integration

```yaml
# .github/workflows/dev-journal.yml
name: Daily Journal

on:
  schedule:
    - cron: '0 18 * * *'  # 매일 저녁 6시 (KST)

jobs:
  generate-journal:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 100  # 최근 100 커밋

      - name: Generate daily log
        run: |
          # 오늘 커밋 수집
          git log --since="today" --pretty=format:"%h|%an|%ad|%s" \
            > temp_commits.txt

          # Claude Code로 일지 생성
          claude-code /dev-journal --daily --input temp_commits.txt

      - name: Commit journal
        run: |
          git config user.name "Journal Bot"
          git config user.email "bot@example.com"
          git add docs/journal/
          git commit -m "docs: Add daily journal $(date +%Y-%m-%d)"
          git push
```

### Slack 알림

```typescript
// 주간 요약을 Slack에 자동 전송
import { WebClient } from '@slack/web-api';

const slack = new WebClient(process.env.SLACK_TOKEN);

async function sendWeeklySummary() {
  const summary = generateWeeklySummary();  // 일지 생성

  await slack.chat.postMessage({
    channel: '#dev-updates',
    text: '이번 주 개발 요약',
    blocks: [
      {
        type: 'header',
        text: { type: 'plain_text', text: '📊 주간 개발 요약' }
      },
      {
        type: 'section',
        text: { type: 'mrkdwn', text: summary }
      }
    ]
  });
}
```

---

## 검색 & 태그

### 태그 기반 검색

```bash
# 특정 태그로 검색
/dev-journal --search "#authentication"

# 여러 태그
/dev-journal --search "#bug #high-impact"

# 날짜 범위
/dev-journal --search --from 2026-01-01 --to 2026-01-31
```

### 전문 검색

```bash
# 키워드 검색
/dev-journal --search "race condition"

# 특정 작성자
/dev-journal --search --author "홍길동"

# ADR만 검색
/dev-journal --search --type adr
```

---

## 사용 예시

### 신규 팀원 온보딩

```bash
# 최근 한 달 주요 결정 사항
/dev-journal --summary --last 30days --type adr

# 출력:
# 📋 Architecture Decisions (Last 30 Days)
#
# 1. ADR-042: JWT Authentication (Jan 27)
#    - JWT 기반 인증 채택
#    - Impact: HIGH
#
# 2. ADR-043: Redis Distributed Lock (Jan 29)
#    - 캐시 race condition 해결
#    - Impact: MEDIUM
#
# 3. ADR-041: GraphQL → REST (Jan 25)
#    - GraphQL 제거, REST로 단순화
#    - Impact: HIGH
```

### 프로젝트 회고

```bash
# 이번 달 모든 활동 요약
/dev-journal --monthly --month 2026-01

# 출력:
# 📊 월간 리포트 (2026년 1월)
#
# ## Highlights
# - 인증 시스템 완료
# - 성능 95% 개선
# - 20개 버그 해결
#
# ## Metrics
# - 72 commits
# - 24 PRs merged
# - 32 issues closed
# - 테스트 커버리지: 78% → 85%
```

### 인수인계

```bash
# 프로젝트 전체 히스토리 생성
/dev-journal --export --output handover.md

# 출력:
# - 모든 ADR
# - 주요 버그 해결 과정
# - 아키텍처 변경 이력
# - 미해결 기술 부채
```

---

## 설정

### .clauderc 설정

```json
{
  "dev-journal": {
    "output_dir": "docs/journal",
    "auto_commit": true,
    "tags": {
      "enabled": true,
      "auto_detect": ["bug", "feature", "performance", "security"]
    },
    "slack": {
      "enabled": true,
      "channel": "#dev-updates",
      "weekly_summary": true
    },
    "templates": {
      "daily": "templates/daily-log.md",
      "weekly": "templates/weekly-summary.md",
      "adr": "templates/adr.md"
    }
  }
}
```

---

## 모범 사례

1. **매일 작성**
   - Git commit 기반 자동 생성
   - 저녁에 하루 요약 리뷰

2. **주간 회고**
   - 매주 금요일 주간 요약 생성
   - 팀과 공유

3. **ADR 필수**
   - 중요한 결정은 ADR 작성
   - 미래의 나를 위한 문서

4. **태그 활용**
   - 검색을 위한 일관된 태그
   - #bug, #feature, #performance 등

5. **링크 연결**
   - Issue, PR, Commit 링크 포함
   - 맥락 추적 용이
