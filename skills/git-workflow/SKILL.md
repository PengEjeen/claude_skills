---
name: git-workflow
description: 고급 Git 워크플로우를 수행합니다. "커밋해줘", "PR 만들어", "브랜치 전략", "conventional commit", "변경사항 정리", "git 히스토리 정리", "릴리즈 준비" 등의 요청 시 사용합니다. Conventional Commits, 자동 PR 생성, 체계적 브랜치 전략을 포함합니다.
---

# Git Workflow Skill — Production Grade

## 목적
깔끔한 Git 히스토리, 의미 있는 커밋 메시지, 체계적 브랜치 관리,
자동화된 PR 워크플로우를 제공한다.

## Conventional Commits

모든 커밋 메시지는 Conventional Commits 규칙을 따른다:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### 타입 (Type)
| Type | 용도 | 예시 |
|------|------|------|
| `feat` | 새 기능 | `feat(auth): add OAuth2 login` |
| `fix` | 버그 수정 | `fix(cart): correct price calculation` |
| `refactor` | 리팩토링 (동작 변경 없음) | `refactor(api): extract validation logic` |
| `test` | 테스트 추가/수정 | `test(auth): add login failure cases` |
| `docs` | 문서 변경 | `docs(readme): update setup instructions` |
| `chore` | 빌드, 설정, 도구 | `chore(deps): upgrade vitest to 3.x` |
| `perf` | 성능 개선 | `perf(query): add index for user lookup` |
| `ci` | CI/CD 변경 | `ci(github): add deploy workflow` |
| `style` | 포맷팅 (코드 로직 변경 없음) | `style: apply prettier formatting` |

### 스코프 (Scope)
프로젝트의 모듈/디렉토리 구조를 기반으로 자동 감지:
- 변경된 파일의 최상위 디렉토리 사용
- 모노레포의 경우 패키지명 사용

### Breaking Changes
```
feat(api)!: change response format for /users endpoint

BREAKING CHANGE: response now wraps data in { data: [], meta: {} }
```

## 스마트 커밋 프로세스

### Step 1: 변경사항 분석
```bash
git diff --staged --stat      # 변경 파일 및 규모
git diff --staged              # 상세 diff
```

### Step 2: 논리적 단위로 분리
하나의 커밋 = 하나의 논리적 변경.
여러 관심사가 섞여 있으면 분리 제안:

```bash
# 예: auth 로직 + UI 변경이 섞여 있을 때
git add src/auth/
git commit -m "feat(auth): implement JWT refresh token"

git add src/components/LoginForm.tsx
git commit -m "feat(ui): add auto-login with refresh token"
```

### Step 3: 커밋 메시지 생성
- diff를 분석하여 적절한 type, scope, description 생성
- body에는 "왜" 이 변경이 필요한지 설명
- 50자 이내 subject line

## PR 생성 워크플로우

### Step 1: 브랜치 확인
```bash
git branch --show-current   # 현재 브랜치
git log --oneline main..HEAD  # main 대비 커밋 목록
```

### Step 2: PR 생성
```bash
gh pr create \
  --title "feat(auth): implement OAuth2 login flow" \
  --body "$(cat <<'EOF'
## Summary
OAuth2 로그인 플로우를 구현합니다.

## Changes
- Google OAuth2 provider 추가
- 로그인 콜백 핸들러 구현
- JWT 토큰 발급 로직 추가
- 관련 테스트 추가

## Test Plan
- [x] 단위 테스트: OAuth callback 핸들러
- [x] 통합 테스트: 전체 로그인 플로우
- [ ] 수동 테스트: Google 로그인 버튼 동작

## Screenshots
(해당 시 첨부)

## Checklist
- [x] 테스트 통과
- [x] 타입 체크 통과
- [x] 린트 통과
- [x] 문서 업데이트
EOF
)" \
  --assignee @me
```

## 브랜치 전략

### 네이밍 컨벤션
```
feature/{ticket-id}-{short-description}
bugfix/{ticket-id}-{short-description}
hotfix/{ticket-id}-{short-description}
release/v{major}.{minor}.{patch}
chore/{short-description}

예:
feature/AUTH-123-oauth2-login
bugfix/CART-456-price-rounding
hotfix/PAY-789-critical-payment-fix
```

### 워크플로우
```
main ← develop ← feature/*
         ↑
         └── bugfix/*

hotfix: main ← hotfix/* (직접 머지)
```

## 히스토리 정리

### Interactive Rebase (push 전)
```bash
# 최근 N개 커밋 정리
git rebase -i HEAD~N

# 일반적인 정리 패턴:
# - fixup: 이전 커밋에 합치기 (메시지 버림)
# - squash: 이전 커밋에 합치기 (메시지 합침)
# - reword: 커밋 메시지 수정
# - drop: 커밋 삭제
```

### 주의사항
- MUST NOT: 이미 push된 커밋을 rebase하지 않기
- MUST: rebase 전 백업 브랜치 생성
- PREFER: squash merge over regular merge for feature branches

## 충돌 해결 가이드

```
1. 충돌 발생 시 각 파일의 충돌 마커 확인
2. 양쪽 변경의 의도를 파악
3. 비즈니스 로직 기준으로 올바른 결과를 선택
4. 충돌 해결 후 관련 테스트 실행
5. 해결 내용을 커밋 메시지에 명시
```

## 릴리즈 워크플로우
```bash
# 1. 릴리즈 브랜치 생성
git checkout -b release/v1.2.0

# 2. 버전 범프
npm version minor  # or major/patch

# 3. CHANGELOG 업데이트
# conventional commits 기반으로 자동 생성

# 4. 태그 및 머지
git tag -a v1.2.0 -m "Release v1.2.0"
gh pr create --title "release: v1.2.0" --base main
```
