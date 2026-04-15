---
name: code-review
description: 시니어 엔지니어 수준의 코드 리뷰를 수행합니다. "리뷰해줘", "코드 검토", "PR 리뷰", "코드 봐줘", "code review", "review PR", "pull request review", "diff 분석" 등의 요청 시 사용합니다. 5-Layer 리뷰(정확성/설계/보안/성능/유지보수), diff 분석, 버그 탐지, 설계 패턴 검증, 테스트 커버리지 점검을 포함합니다.
---

# Code Review Skill — Senior Engineer Level

## 목적
프로덕션 수준의 코드 리뷰를 수행한다. 단순 스타일 지적이 아니라,
설계 결함, 엣지 케이스, 보안 취약점, 성능 병목을 찾아낸다.

## 리뷰 프로세스

### Phase 1: 변경 범위 파악
1. `git diff` 또는 `git diff --staged` 또는 `gh pr diff`로 변경사항 확인
2. 변경된 파일 목록과 변경 규모(추가/삭제 라인) 파악
3. 관련 테스트 파일 존재 여부 확인

### Phase 2: 5-Layer 리뷰 체크리스트

**Layer 1 — 정확성 (Correctness)**
- 로직 오류, off-by-one, null/undefined 미처리
- 비동기 코드: race condition, 에러 전파 누락, await 빠짐
- 타입 안전성: any 남용, 타입 단언(as) 남용, 제네릭 미활용
- 엣지 케이스: 빈 배열, 빈 문자열, 0, NaN, 큰 숫자

```typescript
// 🔴 Before — await 누락, 에러 미전파
function fetchUser(id: string) {
  const res = fetch(`/api/users/${id}`);  // await 빠짐!
  return res.json();  // Promise에 .json() 호출 → TypeError
}

// ✅ After
async function fetchUser(id: string): Promise<User> {
  const res = await fetch(`/api/users/${id}`);
  if (!res.ok) throw new ApiError(res.status, await res.text());
  return res.json();
}
```

**Layer 2 — 설계 (Design)**
- 단일 책임 원칙 위반 여부
- 의존성 방향: 안쪽 레이어가 바깥 레이어를 모르는지
- 추상화 수준 일관성: 한 함수 안에서 고수준/저수준 혼재 여부
- 불필요한 결합(coupling) 발생 여부

```typescript
// 🟡 Before — 한 함수에 고수준/저수준 혼재
async function createOrder(cart: Cart) {
  const conn = await pool.getConnection();           // 저수준 (DB)
  const total = cart.items.reduce((s, i) => s + i.price * i.qty, 0); // 비즈니스 로직
  await conn.query('INSERT INTO orders ...', [total]); // 저수준 (SQL)
  await smtp.send({ to: cart.email, subject: '주문 확인' }); // 저수준 (SMTP)
}

// ✅ After — 추상화 수준 통일
async function createOrder(cart: Cart) {
  const total = calculateTotal(cart);
  const order = await orderRepository.save({ ...cart, total });
  await notificationService.sendOrderConfirmation(order);
}
```

**Layer 3 — 보안 (Security)**
- 사용자 입력 검증 및 새니타이징
- SQL injection, XSS, CSRF 가능성
- 인증/인가 검사 누락
- 민감정보(API 키, 비밀번호) 하드코딩
- 로그에 민감정보 노출

```typescript
// 🔴 Before — SQL injection + 민감정보 로깅
app.post('/login', (req, res) => {
  const { email, password } = req.body;
  const user = db.query(`SELECT * FROM users WHERE email = '${email}'`); // SQL injection!
  console.log(`Login attempt: ${email} / ${password}`);  // 비밀번호 로깅!
});

// ✅ After — 파라미터 바인딩 + 안전한 로깅
app.post('/login', async (req, res) => {
  const { email, password } = loginSchema.parse(req.body); // 입력 검증
  const user = await db.query('SELECT * FROM users WHERE email = $1', [email]);
  logger.info('Login attempt', { email, ip: req.ip }); // 비밀번호 제외
});
```

**Layer 4 — 성능 (Performance)**
- N+1 쿼리, 불필요한 루프 내 I/O
- 대규모 데이터셋 처리 시 메모리 사용 패턴
- 캐싱 기회 누락
- 불필요한 리렌더링(프론트엔드)

```typescript
// 🟡 Before — N+1 쿼리
const orders = await db.query('SELECT * FROM orders');
for (const order of orders) {
  order.user = await db.query('SELECT * FROM users WHERE id = $1', [order.user_id]);
  // 주문 100개 → DB 101회 호출!
}

// ✅ After — JOIN으로 1회 호출
const orders = await db.query(`
  SELECT o.*, u.name as user_name, u.email as user_email
  FROM orders o JOIN users u ON o.user_id = u.id
`);
```

**Layer 5 — 유지보수성 (Maintainability)**
- 매직 넘버, 하드코딩된 문자열
- 함수/변수 네이밍 명확성
- 주석: 불필요한 주석 vs 필요하지만 없는 주석
- 테스트 가능성(testability)

```typescript
// 🟢 Before — 매직 넘버, 모호한 이름
function calc(d: number) {
  if (d > 30) return d * 0.1;
  if (d > 7) return d * 0.05;
  return 0;
}

// ✅ After — 의미 있는 이름과 상수
const MONTHLY_DISCOUNT_RATE = 0.1;
const WEEKLY_DISCOUNT_RATE = 0.05;
const MONTHLY_THRESHOLD_DAYS = 30;
const WEEKLY_THRESHOLD_DAYS = 7;

function calculateSubscriptionDiscount(durationDays: number): number {
  if (durationDays > MONTHLY_THRESHOLD_DAYS) return durationDays * MONTHLY_DISCOUNT_RATE;
  if (durationDays > WEEKLY_THRESHOLD_DAYS) return durationDays * WEEKLY_DISCOUNT_RATE;
  return 0;
}
```

### Phase 3: 피드백 작성

리뷰 결과는 다음 형식으로 작성:

```
## 코드 리뷰 결과

### 🔴 반드시 수정 (Must Fix)
심각한 버그, 보안 취약점, 데이터 손실 가능성

### 🟡 권장 수정 (Should Fix)
설계 개선, 성능 이슈, 잠재적 문제

### 🟢 제안 (Nice to Have)
가독성, 컨벤션, 더 나은 대안

### ✅ 좋은 점 (Praise)
잘 작성된 부분도 반드시 언급
```

## 중요 원칙
- "이게 왜 문제인지"를 반드시 설명. 단순 지적 금지.
- 문제를 지적할 때 해결 방안도 함께 제시.
- 주관적 취향과 객관적 결함을 구분하여 표시.
- 전체 맥락(비즈니스 로직, 데드라인, 팀 컨벤션)을 고려.
- 리뷰 대상 코드가 새 기능인지, 버그 수정인지, 리팩토링인지에 따라 기준 조정.

## 실전 리뷰 시나리오

### 리뷰 결과 작성 예시
```
## 코드 리뷰 결과 — PR #42: Add user authentication

### 🔴 반드시 수정 (Must Fix)

1. **SQL injection 취약점** `src/auth/login.ts:23`
   문자열 보간으로 쿼리를 구성하고 있어 SQL injection이 가능합니다.
   → 파라미터 바인딩($1, $2)으로 교체 필요

2. **비밀번호 평문 로깅** `src/auth/login.ts:31`
   console.log에 password가 포함됩니다. 프로덕션에서 민감정보가 노출됩니다.
   → 비밀번호 필드를 로그에서 제외하세요

### 🟡 권장 수정 (Should Fix)

1. **N+1 쿼리** `src/auth/session.ts:45-52`
   세션 목록 조회 후 루프 안에서 사용자를 개별 조회합니다.
   → JOIN 또는 IN 절로 변경하면 DB 호출 O(N) → O(1)

2. **에러 메시지 노출** `src/auth/login.ts:40`
   "사용자를 찾을 수 없습니다" → 공격자에게 이메일 존재 여부를 노출합니다.
   → "이메일 또는 비밀번호가 올바르지 않습니다"로 통일

### 🟢 제안 (Nice to Have)

1. **타입 강화** `src/auth/types.ts:5`
   role 필드가 string → 'admin' | 'user' | 'guest' union type으로 제한하면 안전

### ✅ 좋은 점 (Praise)

- Refresh token rotation 패턴이 잘 구현되어 있습니다
- 테스트 커버리지 85%로 핵심 로직이 모두 커버됩니다
- Early return 패턴을 일관되게 사용하여 가독성이 좋습니다
```

## 커맨드라인 사용 예시
```bash
# staged 변경사항 리뷰
> 현재 staged된 변경사항을 시니어 레벨로 리뷰해줘

# PR 리뷰
> gh pr diff 42를 리뷰해줘

# 특정 파일 리뷰
> src/auth/login.ts를 리뷰해줘
```

## 관련 스킬
- **clean-code** — 코드 작성 시 품질 기준 (리뷰 대신 작성 시점 적용)
- **security-audit** — 보안 레이어를 더 깊이 점검할 때
- **refactoring** — 리뷰에서 발견된 코드 스멜을 개선할 때
