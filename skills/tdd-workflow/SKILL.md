---
name: tdd-workflow
description: 테스트 주도 개발(TDD) 워크플로우를 실행합니다. "TDD로 구현", "테스트 먼저 작성", "테스트부터", "테스트 코드", "test-driven", "TDD", "Red-Green-Refactor", "unit test", "test first" 등의 요청 시 사용합니다. 실패하는 테스트 작성 → 최소 구현 → 리팩토링의 사이클을 엄격하게 따릅니다.
---

# TDD Workflow Skill — Production Grade

## 목적
Red-Green-Refactor 사이클을 엄격하게 따르는 테스트 주도 개발을 수행한다.
구현 전에 반드시 테스트가 먼저 존재해야 한다.

## 핵심 규칙
- MUST: 구현 코드 작성 전에 실패하는 테스트부터 작성
- MUST: 테스트가 실패하는 것을 확인(Red) 후 구현
- MUST: 테스트 통과(Green) 후 리팩토링
- MUST: 각 사이클은 가능한 한 작게 유지
- MUST NOT: 한 번에 여러 기능을 테스트/구현하지 않기
- MUST NOT: 테스트를 통과시키기 위해 테스트를 수정하지 않기

## 워크플로우

### Step 1: 요구사항 분해
사용자의 요구사항을 테스트 가능한 단위로 분해한다.

```
요구사항: "사용자 로그인 기능 구현"
→ 테스트 케이스:
  1. 유효한 이메일/비밀번호로 로그인 성공
  2. 잘못된 비밀번호로 로그인 실패
  3. 존재하지 않는 이메일로 로그인 실패
  4. 이메일 형식 검증
  5. 비밀번호 최소 길이 검증
  6. 로그인 실패 횟수 제한
```

### Step 2: Red — 실패하는 테스트 작성
```
1. 가장 단순한 케이스부터 테스트 작성
2. 테스트 실행하여 실패 확인
3. 실패 이유가 "구현이 없어서"인지 확인
   - 컴파일 에러가 아닌 어설션 실패여야 함
```

### Step 3: Green — 최소한의 구현
```
1. 테스트를 통과시키는 가장 단순한 코드 작성
2. 하드코딩이라도 괜찮음 (다음 테스트가 일반화를 강제)
3. 모든 기존 테스트도 여전히 통과하는지 확인
```

### Step 4: Refactor — 리팩토링
```
1. 중복 제거
2. 네이밍 개선
3. 함수 추출 (Extract Function)
4. 리팩토링 후 모든 테스트 통과 확인
5. 커밋
```

### Step 5: 반복
다음 테스트 케이스로 넘어가 Step 2부터 반복한다.

## 테스트 작성 원칙

### AAA 패턴 (Arrange-Act-Assert)
```
// ✅ Good
test('유효한 자격증명으로 로그인 성공', () => {
  // Arrange - 테스트 데이터 준비
  const credentials = { email: 'user@test.com', password: 'valid123!' };

  // Act - 테스트 대상 실행
  const result = authService.login(credentials);

  // Assert - 결과 검증
  expect(result.success).toBe(true);
  expect(result.token).toBeDefined();
});
```

### 테스트 네이밍
```
// ✅ Good - 행위를 설명
"유효한 토큰으로 요청 시 사용자 정보를 반환한다"
"만료된 토큰으로 요청 시 401을 반환한다"

// ❌ Bad - 구현을 설명
"getUserById 테스트"
"토큰 검증 테스트"
```

### 테스트 독립성
- 각 테스트는 다른 테스트에 의존하지 않는다
- 공유 상태(shared state)를 사용하지 않는다
- beforeEach로 클린 상태를 보장한다

### 테스트 경계
- **단위 테스트**: 외부 의존성은 모킹. 빠르고 결정적(deterministic)
- **통합 테스트**: 실제 의존성 사용. DB, API 등
- **E2E 테스트**: 사용자 시나리오. 브라우저/HTTP 수준

## 커밋 전략
```
각 Red-Green-Refactor 사이클 완료 시 커밋:
  feat(auth): add email validation for login
  test(auth): add test for invalid email format

테스트와 구현을 같은 커밋에 포함:
  한 기능 단위 = 한 커밋 (테스트 + 구현)
```

## 프레임워크별 명령어 참조

프로젝트의 테스트 러너를 자동 감지하되, 단일 테스트 실행을 선호:
```bash
# JavaScript/TypeScript
npx vitest run path/to/file.test.ts
npx jest path/to/file.test.ts --no-coverage
npx mocha path/to/file.test.js

# Python
python -m pytest path/to/test_file.py -x -v
python -m pytest path/to/test_file.py::TestClass::test_method -v

# Go
go test ./path/to/package -run TestFunctionName -v

# Rust
cargo test test_name -- --nocapture
```

## 안티패턴 감지
다음을 발견하면 경고:
- 테스트 없이 구현 코드가 먼저 작성됨
- 테스트가 구현 세부사항에 결합됨 (private method 테스트 등)
- 과도한 모킹으로 테스트가 의미 없어짐
- 테스트가 항상 통과하는 트리비얼한 어설션
- snapshot 테스트 남용
