---
name: clean-code
description: Project Guardian — 프로젝트 품질 관리 종합 스킬. 클린 코드(SOLID/DRY/KISS/YAGNI), Dockerfile 작성·보안·배포, DB 스키마 문서화, CI/CD, 프로젝트 구조 관리를 포괄한다. 코드를 작성하거나 수정할 때 이 스킬의 원칙을 적용하여 깔끔하고 안전하며 유지보수 가능한 프로젝트를 만든다. Use this skill whenever writing, reviewing, or refactoring code. Also use for Dockerfiles, CI/CD, DB schemas, migrations. Triggers: "클린 코드", "코드 품질", "SOLID", "Dockerfile", "docker-compose", "배포", "deploy", "DB 스키마", "마이그레이션", "프로젝트 구조", "clean code", "code quality". (코드 스멜 제거·구조 개선은 refactoring, 리뷰 관점은 code-review 스킬 참조)
---

# Project Guardian — 프로젝트 품질 관리 종합 스킬

> "코드는 한 번 쓰고 수백 번 읽힌다. 읽는 사람을 위해 써라." — Robert C. Martin

---

# Part 1: 클린 코드 & 리팩토링

## 1.1 6대 원칙 — 모든 코드에 항상 적용

### SOLID 원칙
```
S — Single Responsibility (단일 책임)
    하나의 모듈/클래스/함수는 하나의 이유로만 변경되어야 한다.
    위반 신호: "그리고(and)"가 들어가는 함수명 (validateAndSave, fetchAndRender)

O — Open/Closed (개방/폐쇄)
    확장에는 열려있고, 수정에는 닫혀있어야 한다.
    위반 신호: 새 기능 추가 시 기존 코드를 수정해야 하는 경우

L — Liskov Substitution (리스코프 치환)
    하위 타입은 상위 타입을 대체할 수 있어야 한다.
    위반 신호: instanceof/typeof 체크가 난무하는 코드

I — Interface Segregation (인터페이스 분리)
    클라이언트가 사용하지 않는 메서드에 의존하지 않아야 한다.
    위반 신호: 빈 메서드 구현, NotImplementedError 투성이

D — Dependency Inversion (의존 역전)
    고수준 모듈이 저수준 모듈에 의존하지 않고, 추상화에 의존해야 한다.
    위반 신호: import가 구체 클래스를 직접 참조
```

### DRY (Don't Repeat Yourself)
```
규칙: 동일한 로직이 3번 이상 나타나면 반드시 추출 (Rule of Three)
주의: 과도한 추상화는 오히려 가독성을 해침. "약간의 중복 > 잘못된 추상화"
적용: 함수 추출, 상수 정의, 유틸리티 모듈, 컴포넌트 재사용
```

### KISS (Keep It Simple, Stupid)
```
규칙: 가장 단순한 해결책이 거의 항상 최선
위반 신호: "영리한(clever)" 코드, 원-라이너 집착, 불필요한 디자인 패턴
적용: 읽기 쉬운 코드 > 짧은 코드 > 빠른 코드
```

### YAGNI (You Aren't Gonna Need It)
```
규칙: 현재 필요하지 않은 기능을 미리 만들지 않기
위반 신호: "나중에 필요할 수도 있으니까", 사용되지 않는 인터페이스
적용: 현재 요구사항에 집중, 미래 확장은 리팩토링으로 대응
```

### SoC (Separation of Concerns)
```
규칙: 각 모듈은 하나의 관심사만 다룸
적용: 비즈니스 로직 / 데이터 접근 / UI / 설정을 명확히 분리
```

### TDD (Test-Driven Development)
```
연구: TDD는 "두려움 제거 장치" — 리팩토링의 심리적 안전망
     테스트 없이는 리팩토링 불가, 테스트가 있으면 자유롭게 개선 가능
사이클: Red → Green → Refactor
```

---

## 1.2 네이밍 컨벤션 — 이름이 문서다

### 규칙
```
✅ 좋은 이름:
  - getUserById(), calculateTotalPrice(), isAuthenticated
  - MAX_RETRY_COUNT, DEFAULT_PAGE_SIZE
  - userRepository, paymentService, authMiddleware

❌ 나쁜 이름:
  - data, temp, result, info, item, stuff, thing
  - doStuff(), handleIt(), process()
  - d, n, x (단, 루프 인덱스 i/j/k와 좌표 x/y/z는 허용)
  - Manager, Helper, Util (의미가 모호한 접미사)

언어별 컨벤션:
  JavaScript/TypeScript: camelCase (변수/함수), PascalCase (클래스/컴포넌트), UPPER_SNAKE (상수)
  Python: snake_case (변수/함수), PascalCase (클래스), UPPER_SNAKE (상수)
  Go: camelCase (비공개), PascalCase (공개), 약어는 전체 대문자 (userID, httpURL)
  CSS: kebab-case (클래스), BEM 또는 Tailwind 컨벤션

불리언 네이밍: is/has/can/should 접두사
  isLoading, hasPermission, canEdit, shouldRefresh

함수 네이밍: 동사로 시작
  get/fetch (조회), create/add (생성), update/modify (수정),
  delete/remove (삭제), validate/check (검증), convert/transform (변환)
```

---

## 1.3 함수 설계 규칙

```
1. 길이: 20줄 이내 권장, 50줄 초과 시 반드시 분리
   연구: Google — 모듈식 아키텍처 사용 시 배포 오류율 30% 감소

2. 매개변수: 3개 이하 권장, 4개 이상 → 객체로 묶기
   나쁜 예: createUser(name, email, age, role, team, isActive)
   좋은 예: createUser({ name, email, age, role, team, isActive })

3. 반환값: 하나의 타입만 반환 (null/undefined 대신 Optional 패턴)

4. 부수효과(Side Effects): 명시적으로 분리
   순수 함수: 같은 입력 → 항상 같은 출력, 부수효과 없음
   비순수 함수: DB 접근, API 호출, 파일 I/O → 별도 레이어

5. 에러 처리: 에러를 삼키지 말고, 적절히 전파하거나 처리
   ❌ catch (e) {} — 빈 catch 금지
   ✅ catch (e) { logger.error('Context:', e); throw new AppError(...) }

6. 조기 반환 (Early Return): 중첩 줄이기
   ❌ if (condition) { ... 100줄 ... } else { return error; }
   ✅ if (!condition) { return error; } ... 핵심 로직 ...
```

---

## 1.4 코드 리뷰 체크리스트

코드를 작성하거나 수정한 후, 또는 코드 리뷰 시 이 체크리스트를 적용:

```
□ 가독성
  - 코드를 처음 보는 사람이 5분 내에 이해할 수 있는가?
  - 네이밍이 의도를 명확히 전달하는가?
  - 매직 넘버 대신 명명된 상수를 사용했는가?
  - 불필요한 주석 없이 코드 자체가 설명적인가?

□ 구조
  - 함수/클래스가 단일 책임을 가지는가?
  - 중복 코드가 없는가? (3회 이상 반복 → 추출)
  - 적절한 추상화 수준인가? (과하지도, 부족하지도 않게)
  - import/의존성이 깔끔한가? (순환 의존 없음)

□ 정확성
  - 엣지 케이스를 처리했는가? (null, 빈 배열, 0, 음수)
  - 에러 처리가 적절한가?
  - 타입이 정확한가? (TypeScript/Python type hints)
  - 비동기 처리가 올바른가? (race condition, await 누락)

□ 성능
  - 불필요한 반복/재계산이 없는가?
  - N+1 쿼리 문제가 없는가?
  - 메모리 누수 가능성이 없는가?
  - 큰 데이터셋에 대한 페이지네이션이 있는가?

□ 보안
  - 사용자 입력을 검증/이스케이프했는가?
  - SQL 인젝션/XSS 방어가 되어 있는가?
  - 민감 정보가 로그에 남지 않는가?
  - 인증/인가 체크가 빠지지 않았는가?

□ 테스트
  - 핵심 로직에 대한 테스트가 있는가?
  - 테스트가 독립적으로 실행 가능한가?
  - 테스트 이름이 시나리오를 설명하는가?
```

---

## 1.5 주석 작성 원칙

```
황금 규칙: "왜(Why)"를 설명하는 주석만 작성. "무엇(What)"은 코드가 말하게.

✅ 좋은 주석:
  // 결제 게이트웨이 API가 가끔 timeout을 반환하므로 3회 재시도
  // RFC 7231 섹션 6.5.1에 따라 400 반환
  // HACK: 라이브러리 v3.2의 버그 우회 (이슈 #1234 참고)
  // TODO: 인덱스 추가 후 이 쿼리 최적화 필요

❌ 나쁜 주석:
  // 사용자를 가져온다
  const user = getUser(id);
  // 카운터를 1 증가시킨다
  counter++;
  // 생성자
  constructor() { }

주석이 필요한 경우:
  - 비즈니스 규칙의 이유 설명
  - 성능 최적화의 근거
  - 외부 시스템의 제약 사항
  - 의도적으로 "이상하게" 보이는 코드의 이유
  - 정규식의 의미 설명
  - 공개 API의 JSDoc/docstring
```

---

## 1.6 프로젝트 디렉토리 구조

### 범용 구조 (프론트엔드+백엔드)
```
project-root/
├── .github/                    # GitHub Actions, PR 템플릿, 이슈 템플릿
│   └── workflows/
├── .docker/                    # Docker 관련 파일 (prod, dev Dockerfile 분리)
│   ├── Dockerfile.dev
│   ├── Dockerfile.prod
│   └── .dockerignore
├── docs/                       # 프로젝트 문서
│   ├── ARCHITECTURE.md         # 아키텍처 결정 기록
│   ├── API.md                  # API 문서
│   ├── DATABASE.md             # DB 스키마 문서
│   └── DEPLOYMENT.md           # 배포 가이드
├── scripts/                    # 빌드/배포/유틸 스크립트
│   ├── setup.sh
│   ├── seed-db.sh
│   └── deploy.sh
├── src/                        # 소스 코드
│   ├── config/                 # 설정 (환경변수, 상수)
│   ├── modules/                # 기능 모듈 (도메인별 분리)
│   │   ├── auth/
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.repository.ts
│   │   │   ├── auth.dto.ts
│   │   │   ├── auth.types.ts
│   │   │   └── __tests__/
│   │   ├── user/
│   │   └── payment/
│   ├── shared/                 # 공유 유틸, 미들웨어, 타입
│   │   ├── middleware/
│   │   ├── utils/
│   │   ├── types/
│   │   └── errors/
│   ├── infrastructure/         # DB, 외부 서비스, 캐시
│   │   ├── database/
│   │   ├── cache/
│   │   └── external/
│   └── main.ts                 # 엔트리 포인트
├── tests/                      # 통합 테스트, E2E 테스트
│   ├── integration/
│   └── e2e/
├── docker-compose.yml
├── docker-compose.dev.yml
├── .env.example                # 환경변수 템플릿 (실제 .env는 gitignore)
├── .gitignore
├── .eslintrc / .prettierrc     # 린터/포매터 설정
├── tsconfig.json / pyproject.toml
├── CLAUDE.md                   # Claude Code 스킬/지시
├── README.md                   # 프로젝트 소개, 시작 가이드
├── CHANGELOG.md                # 변경 이력
└── LICENSE
```

### 모듈 분리 원칙
```
기능 모듈 (Feature Module) 구조:
  modules/
  └── [feature-name]/
      ├── [feature].controller.ts   # 요청 처리, 라우팅
      ├── [feature].service.ts      # 비즈니스 로직
      ├── [feature].repository.ts   # 데이터 접근
      ├── [feature].dto.ts          # 입출력 데이터 정의
      ├── [feature].types.ts        # 타입/인터페이스
      ├── [feature].validator.ts    # 입력 검증
      ├── [feature].constants.ts    # 모듈 상수
      └── __tests__/                # 단위 테스트 (코드 옆에)
          ├── [feature].service.test.ts
          └── [feature].controller.test.ts

분리 기준:
  - 한 모듈의 파일이 10개 초과 → 하위 모듈로 분리
  - 두 모듈이 항상 함께 변경 → 하나로 합치기 고려
  - 다른 모듈 직접 참조 금지 → shared/ 또는 인터페이스를 통해
```

---

## 1.7 Git 컨벤션

### 커밋 메시지 (Conventional Commits)
```
형식: <type>(<scope>): <description>

type:
  feat:     새 기능
  fix:      버그 수정
  refactor: 동작 변경 없는 구조 개선
  docs:     문서 변경
  style:    포맷팅 (세미콜론, 들여쓰기 등)
  test:     테스트 추가/수정
  chore:    빌드, 설정 변경
  perf:     성능 개선
  ci:       CI/CD 변경

예시:
  feat(auth): add OAuth2 Google login
  fix(payment): handle null amount in refund calculation
  refactor(user): extract address validation to shared util
  docs(api): update endpoint descriptions for v2

규칙:
  - 제목 50자 이내
  - 본문은 빈 줄 후 작성, 72자 줄바꿈
  - 이슈 번호 참조: Closes #123, Refs #456
  - 하나의 커밋 = 하나의 논리적 변경
```

### 브랜치 전략
```
main        ← 프로덕션 (항상 배포 가능)
  └── develop    ← 개발 통합
       ├── feature/auth-google-login
       ├── feature/payment-refund
       ├── fix/user-email-validation
       └── hotfix/critical-security-patch
```

---

# Part 2: Dockerfile & 배포

## 2.1 Dockerfile 작성 원칙

### 필수 규칙 (2026 기준)
```
1. 항상 Multi-Stage Build 사용 — 빌드와 런타임 분리
2. 절대 root로 실행하지 않기 — 전용 사용자 생성
3. 이미지 태그 고정 — :latest 금지, 정확한 버전 사용
4. .dockerignore 필수 — node_modules, .git, .env 제외
5. 레이어 캐싱 최적화 — 변경 빈도 낮은 것을 위에 배치
6. 비밀 정보 절대 이미지에 포함 금지
7. HEALTHCHECK 포함
8. LABEL로 메타데이터 추가
9. RUN 명령 합치기 — 레이어 수 최소화
10. 보안 스캐닝 — Trivy 또는 Docker Scout
```

### Node.js Dockerfile 템플릿 (프로덕션)
```dockerfile
# ============================================
# Stage 1: Dependencies
# ============================================
FROM node:20.11-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production && npm cache clean --force

# ============================================
# Stage 2: Build
# ============================================
FROM node:20.11-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# ============================================
# Stage 3: Production Runtime
# ============================================
FROM node:20.11-alpine AS runtime

# 보안: 비-root 사용자
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# 메타데이터
LABEL org.opencontainers.image.title="app-name" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.description="Production image"

WORKDIR /app

# 프로덕션 의존성만 복사
COPY --from=deps --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=build --chown=appuser:appgroup /app/dist ./dist
COPY --from=build --chown=appuser:appgroup /app/package.json ./

# 환경변수
ENV NODE_ENV=production
ENV PORT=3000

# 비-root 사용자로 전환
USER appuser

# 포트 노출
EXPOSE 3000

# 헬스체크
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# 실행
CMD ["node", "dist/main.js"]
```

### Python Dockerfile 템플릿
```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --target=/app/deps -r requirements.txt

FROM python:3.12-slim
RUN useradd -m -r appuser && mkdir /app && chown appuser:appuser /app
WORKDIR /app
COPY --from=builder --chown=appuser:appuser /app/deps /usr/local/lib/python3.12/site-packages
COPY --chown=appuser:appuser ./src .

ENV PYTHONUNBUFFERED=1
USER appuser
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### .dockerignore 필수 내용
```
node_modules
.git
.github
.env
.env.*
*.md
!README.md
docker-compose*.yml
.dockerignore
Dockerfile*
.vscode
.idea
coverage/
dist/
__pycache__
*.pyc
.pytest_cache
.mypy_cache
```

## 2.2 Docker Compose 템플릿
```yaml
# docker-compose.yml — 프로덕션 기반
services:
  app:
    build:
      context: .
      dockerfile: .docker/Dockerfile.prod
      args:
        - NODE_ENV=production
    ports:
      - "${PORT:-3000}:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/health"]
      interval: 30s
      timeout: 5s
      retries: 3
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 512M

  db:
    image: postgres:16.2-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:7.2-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

## 2.3 보안 체크리스트

```
□ 이미지 보안
  - [ ] 공식 이미지만 사용 (Docker Hub Verified Publisher)
  - [ ] 이미지 태그 고정 (node:20.11-alpine, NOT node:latest)
  - [ ] 멀티스테이지 빌드로 빌드 도구 제외
  - [ ] Trivy/Docker Scout으로 취약점 스캔
  - [ ] 불필요한 패키지 설치 금지

□ 런타임 보안
  - [ ] 비-root 사용자로 실행
  - [ ] 읽기 전용 파일시스템 (가능한 경우)
  - [ ] CPU/메모리 제한 설정
  - [ ] 필요한 포트만 노출
  - [ ] Docker Content Trust 활성화

□ 비밀 정보 관리
  - [ ] .env 파일은 .gitignore에 포함
  - [ ] Docker Secrets 또는 외부 vault 사용
  - [ ] ARG/ENV에 비밀번호 하드코딩 금지
  - [ ] 빌드 시 --secret 플래그 사용
  - [ ] .env.example에 키만 표시, 값은 비우기
```

## 2.4 CI/CD 파이프라인 (GitHub Actions)
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm run lint
      - run: npm run type-check
      - run: npm test -- --coverage
      - uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: fs
          severity: CRITICAL,HIGH

  build-and-push:
    needs: [lint-and-test, security-scan]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build and push Docker image
        run: |
          docker build -f .docker/Dockerfile.prod -t app:${{ github.sha }} .
          # Push to registry...
```

---

# Part 3: 데이터베이스 문서화 & 관리

## 3.1 DB 스키마 문서 작성 규칙

**모든 프로젝트에서 `docs/DATABASE.md` 파일을 유지한다.**

(DATABASE.md 템플릿, DB 설계 원칙, 쿼리 최적화 체크리스트는 원문 그대로 적용)

## 3.2 DB 설계 원칙

```
1. 정규화: 3NF까지 기본 적용, 성능이 필요한 곳만 역정규화
2. 명명 규칙:
   - 테이블: 복수형 snake_case (users, order_items)
   - 컬럼: 단수형 snake_case (user_id, created_at)
   - PK: id (UUID 권장) 또는 [table]_id
   - FK: [참조테이블_단수]_id (user_id, order_id)
   - 타임스탬프: created_at, updated_at, deleted_at
   - 불리언: is_ 또는 has_ 접두사 (is_active, has_verified)

3. 필수 컬럼:
   - id: 모든 테이블의 PK
   - created_at: 생성 시각 (TIMESTAMPTZ)
   - updated_at: 수정 시각 (자동 갱신 트리거)

4. 소프트 삭제: deleted_at NULL이면 활성, NOT NULL이면 삭제됨

5. 인덱스 전략:
   - FK는 항상 인덱스
   - WHERE/ORDER BY에 자주 사용되는 컬럼
   - 복합 인덱스: 선택도 높은 컬럼을 앞에
   - 부분 인덱스: 활성 레코드만 (WHERE deleted_at IS NULL)

6. 마이그레이션 규칙:
   - 마이그레이션은 항상 롤백 가능하게 (up + down)
   - 데이터 파괴적 변경은 별도 마이그레이션으로 분리
   - 프로덕션에서 테이블 잠금이 필요한 변경은 주의
   - 컬럼 추가는 안전, 컬럼 삭제는 2단계로 (deprecated → 삭제)
```

## 3.3 쿼리 최적화 체크리스트

```
□ N+1 문제 방지: JOIN 또는 Eager Loading 사용
□ SELECT *: 금지. 필요한 컬럼만 명시
□ 페이지네이션: OFFSET 대신 Cursor-based (대규모 데이터)
□ 인덱스 활용: EXPLAIN ANALYZE로 확인
□ 트랜잭션: 최소 범위로, 장시간 잠금 방지
□ 커넥션 풀: 적절한 크기 설정 (일반적으로 CPU 코어 수 * 2 + 1)
□ 벌크 작업: 개별 INSERT 대신 배치 INSERT
□ 캐싱: 자주 읽고 드물게 쓰는 데이터는 Redis 캐시
```

---

# Part 4: 프로젝트 문서화

## 4.1 필수 문서 목록

```
모든 프로젝트에 다음 문서를 유지:

1. README.md — 프로젝트 소개, 시작 방법, 기술 스택
2. CLAUDE.md — Claude Code 지시사항, 프로젝트 규칙
3. CHANGELOG.md — 버전별 변경 이력 (Keep a Changelog 형식)
4. .env.example — 환경변수 목록 (값 없이 키만)
5. docs/ARCHITECTURE.md — 아키텍처 결정 기록 (ADR)
6. docs/DATABASE.md — DB 스키마 문서
7. docs/API.md — API 엔드포인트 문서 (또는 OpenAPI/Swagger)
8. docs/DEPLOYMENT.md — 배포 절차, 환경별 설정
```

---

# Part 5: 환경변수 관리

## .env.example 템플릿
```bash
# ================================
# Application
# ================================
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000
LOG_LEVEL=debug

# ================================
# Database
# ================================
DB_HOST=localhost
DB_PORT=5432
DB_NAME=
DB_USER=
DB_PASSWORD=
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}

# ================================
# Redis
# ================================
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# ================================
# Authentication
# ================================
JWT_SECRET=
JWT_EXPIRES_IN=7d

# ================================
# External Services
# ================================
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASSWORD=

# ================================
# API Keys
# ================================
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
```

---

# Part 6: 종합 프로젝트 체크리스트

새 프로젝트를 시작하거나 기존 프로젝트를 점검할 때 사용:

```
□ 코드 품질
  - [ ] ESLint/Pylint + Prettier/Black 설정됨
  - [ ] TypeScript strict mode (또는 Python type hints)
  - [ ] 모듈별 기능 분리 완료
  - [ ] SOLID 원칙 위반 없음
  - [ ] 테스트 커버리지 80%+ (핵심 로직)

□ 프로젝트 구조
  - [ ] 디렉토리 구조가 일관적
  - [ ] README.md 작성 완료
  - [ ] CLAUDE.md 작성 완료
  - [ ] .env.example 최신 상태
  - [ ] .gitignore 적절히 설정

□ Docker & 배포
  - [ ] Multi-stage Dockerfile 작성
  - [ ] 비-root 사용자로 실행
  - [ ] HEALTHCHECK 포함
  - [ ] docker-compose.yml 작성 (dev + prod)
  - [ ] .dockerignore 작성
  - [ ] CI/CD 파이프라인 설정

□ 데이터베이스
  - [ ] docs/DATABASE.md 작성
  - [ ] 마이그레이션 파일 관리됨
  - [ ] 인덱스 적절히 설정
  - [ ] 시드 데이터 스크립트 존재
  - [ ] 백업 전략 문서화

□ 보안
  - [ ] 환경변수로 시크릿 관리 (.env)
  - [ ] 입력 검증/살균 적용
  - [ ] CORS 설정 적절
  - [ ] Rate limiting 적용
  - [ ] Helmet/보안 헤더 설정
  - [ ] 의존성 취약점 스캔 (npm audit / safety)

□ 문서
  - [ ] API 문서 (OpenAPI/Swagger)
  - [ ] 아키텍처 결정 기록
  - [ ] 배포 가이드
  - [ ] 기여 가이드
```

---

## 참고 자료

- Martin, R.C. (2008). "Clean Code: A Handbook of Agile Software Craftsmanship"
- Martin, R.C. (2017). "Clean Architecture"
- Fowler, M. (2018). "Refactoring: Improving the Design of Existing Code"
- Hunt, A. & Thomas, D. (1999). "The Pragmatic Programmer"
- Docker Official Best Practices (2025). docs.docker.com/build/building/best-practices
- Google (2024). 모듈식 아키텍처 → 배포 오류율 30% 감소
- GitHub (2025). 코드 리뷰 → 구현 후 버그 50% 감소
- McKinsey (2024). 체계적 리팩토링 → 완료 시간 40-50% 단축
- Atlassian (2025). 기술 부채 추적 → 프로젝트 성공률 40% 향상

---

**핵심: 이 스킬의 모든 규칙은 "코드를 작성할 때" 자동으로 적용되어야 한다. 별도로 요청하지 않아도, 모든 코드가 이 기준을 충족하도록 한다.**
