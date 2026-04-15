---
name: api-design
description: RESTful API 및 GraphQL API 설계 원칙과 문서화 표준을 제공합니다. "API 설계", "엔드포인트 설계", "REST API", "GraphQL 스키마", "API 스펙", "OpenAPI", "API 버전 관리", "API design", "endpoint design", "REST convention" 등의 요청 시 사용합니다. RESTful 컨벤션, OpenAPI 3.x, RFC 9457 에러 응답, 페이지네이션, Rate Limiting을 포함합니다. (구현은 backend-api, PM용 명세는 api-spec-generator 스킬 참조)
---

# API Design Skill — Production-Ready

## 목적
일관성 있고 확장 가능하며 사용하기 쉬운 API를 설계한다.
"좋은 API는 올바른 일을 쉽게, 잘못된 일을 어렵게 만든다."

## RESTful API 설계 원칙

### URL 컨벤션
```
✅ Good
GET    /api/v1/users              # 목록 조회
GET    /api/v1/users/123          # 단건 조회
POST   /api/v1/users              # 생성
PUT    /api/v1/users/123          # 전체 수정
PATCH  /api/v1/users/123          # 부분 수정
DELETE /api/v1/users/123          # 삭제

# 관계 리소스
GET    /api/v1/users/123/orders   # 특정 사용자의 주문 목록
POST   /api/v1/users/123/orders   # 특정 사용자의 주문 생성

# 검색/필터
GET    /api/v1/users?role=admin&status=active
GET    /api/v1/orders?created_after=2026-01-01&sort=-created_at

# 행위(Action) — 동사가 필요할 때
POST   /api/v1/orders/123/cancel
POST   /api/v1/users/123/verify-email

❌ Bad
GET    /api/v1/getUsers
POST   /api/v1/createUser
GET    /api/v1/user_list
DELETE /api/v1/deleteUser/123
```

### 응답 형식 표준

#### 성공 응답
```json
// 단건
{
  "data": {
    "id": "123",
    "type": "user",
    "attributes": { "name": "Kim", "email": "kim@example.com" }
  }
}

// 목록 (페이지네이션 포함)
{
  "data": [
    { "id": "1", "name": "Kim" },
    { "id": "2", "name": "Lee" }
  ],
  "meta": {
    "total": 150,
    "page": 1,
    "per_page": 20,
    "total_pages": 8
  },
  "links": {
    "self": "/api/v1/users?page=1",
    "next": "/api/v1/users?page=2",
    "last": "/api/v1/users?page=8"
  }
}
```

#### 에러 응답 (RFC 9457 Problem Details)
```json
{
  "type": "https://api.example.com/errors/validation",
  "title": "Validation Error",
  "status": 422,
  "detail": "요청 데이터가 유효하지 않습니다.",
  "instance": "/api/v1/users",
  "errors": [
    {
      "field": "email",
      "code": "INVALID_FORMAT",
      "message": "유효한 이메일 형식이 아닙니다."
    },
    {
      "field": "password",
      "code": "TOO_SHORT",
      "message": "비밀번호는 8자 이상이어야 합니다."
    }
  ]
}
```

### HTTP 상태 코드 가이드
```
2xx 성공
  200 OK           — 조회, 수정 성공
  201 Created      — 생성 성공 (Location 헤더 포함)
  204 No Content   — 삭제 성공 (본문 없음)

4xx 클라이언트 에러
  400 Bad Request       — 잘못된 요청 형식
  401 Unauthorized      — 인증 필요 (토큰 없음/만료)
  403 Forbidden         — 인가 실패 (권한 없음)
  404 Not Found         — 리소스 없음
  409 Conflict          — 충돌 (중복 생성 등)
  422 Unprocessable Entity — 유효성 검증 실패
  429 Too Many Requests — Rate limit 초과

5xx 서버 에러
  500 Internal Server Error — 예상치 못한 서버 에러
  502 Bad Gateway          — 업스트림 서비스 에러
  503 Service Unavailable  — 일시적 서비스 불가
```

### 페이지네이션 전략
```
1. Offset 기반 (간단, 작은 데이터셋)
   GET /api/v1/users?page=3&per_page=20

2. Cursor 기반 (대규모 데이터, 실시간 데이터)
   GET /api/v1/users?cursor=eyJpZCI6MTIzfQ&limit=20

   장점: 일관된 결과, 대규모 데이터에서 성능 우수
   단점: 임의 페이지 이동 불가
```

### 버전 관리 전략
```
1. URL Path (권장)
   /api/v1/users
   /api/v2/users

2. Header
   Accept: application/vnd.myapp.v1+json

규칙:
- 하위 호환(backward compatible) 변경은 버전 올리지 않음
  - 필드 추가, 선택적 파라미터 추가
- 하위 호환 깨지는 변경만 새 버전
  - 필드 제거, 필수 파라미터 추가, 응답 구조 변경
- 이전 버전 최소 12개월 지원
- Deprecation 헤더로 예고
```

### 인증/인가 패턴
```
1. Bearer Token (JWT)
   Authorization: Bearer eyJhbGciOiJSUzI1NiIs...

2. API Key (서버 간 통신)
   X-API-Key: sk_live_abc123

3. OAuth 2.0 (서드파티 연동)
   Authorization Code Flow
```

### Rate Limiting
```
응답 헤더:
  X-RateLimit-Limit: 1000
  X-RateLimit-Remaining: 999
  X-RateLimit-Reset: 1640995200
  Retry-After: 60  (429 응답 시)

전략:
  - 인증된 사용자: 1000 req/min
  - 미인증: 60 req/min
  - 특정 엔드포인트(로그인): 10 req/min
```

## OpenAPI 3.x 스펙 생성

API 설계 완료 후 OpenAPI 스펙을 자동 생성:

```yaml
openapi: 3.1.0
info:
  title: My API
  version: 1.0.0
  description: API 설명
servers:
  - url: https://api.example.com/v1
paths:
  /users:
    get:
      summary: 사용자 목록 조회
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: 성공
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserList'
components:
  schemas:
    User:
      type: object
      required: [id, email]
      properties:
        id:
          type: string
          format: uuid
        email:
          type: string
          format: email
```

## 설계 체크리스트

```
□ URL이 명사 기반이며 복수형인가?
□ HTTP 메서드가 올바르게 사용되었는가?
□ 에러 응답이 RFC 9457 형식인가?
□ 페이지네이션이 구현되었는가?
□ Rate limiting이 설정되었는가?
□ 인증/인가가 모든 엔드포인트에 적용되었는가?
□ 입력 유효성 검증이 서버에서 수행되는가?
□ 멱등성(idempotency)이 보장되는가? (PUT, DELETE)
□ 버전 관리 전략이 정해졌는가?
□ OpenAPI 스펙이 생성되었는가?
```
