---
name: security-audit
description: 코드 및 인프라 보안 감사를 수행합니다. "보안 검토", "취약점 분석", "보안 감사", "security review", "OWASP", "인젝션 검사", "인증/인가 검토" 등의 요청 시 사용합니다. OWASP Top 10 기반 취약점 스캔, 의존성 감사, 시크릿 탐지를 포함합니다.
---

# Security Audit Skill — OWASP-Aligned

## 목적
코드베이스의 보안 취약점을 체계적으로 탐지하고,
수정 방안과 예방 가이드라인을 제공한다.

## 감사 범위

### Level 1: 빠른 스캔 (5분)
긴급하거나 특정 파일 대상의 빠른 점검.

### Level 2: 표준 감사 (30분)
PR 머지 전 또는 정기 점검용. 전체 변경사항 대상.

### Level 3: 심층 감사 (2시간+)
릴리즈 전 또는 보안 사고 후 전체 코드베이스 대상.

## OWASP Top 10 (2025) 기반 점검

### A01: Broken Access Control
```
점검 항목:
□ API 엔드포인트별 인가(authorization) 검사 존재 여부
□ IDOR (Insecure Direct Object Reference) 가능성
  - URL 파라미터로 다른 사용자 리소스 접근 가능한지
  - /api/users/123 → 123을 바꿔서 다른 유저 접근 가능?
□ 수평적 권한 상승 (같은 역할의 다른 사용자 리소스 접근)
□ 수직적 권한 상승 (일반 사용자가 관리자 기능 접근)
□ CORS 설정 검토
□ HTTP 메서드 제한 (OPTIONS, DELETE 등)
```

### A02: Cryptographic Failures
```
점검 항목:
□ 민감정보 평문 저장 여부 (비밀번호, 카드번호, SSN)
□ 약한 해시 알고리즘 사용 (MD5, SHA1)
□ 하드코딩된 암호화 키
□ HTTPS 미적용 구간
□ JWT 서명 알고리즘 (none, HS256 vs RS256)
□ 솔트(salt) 없는 비밀번호 해시
```

### A03: Injection
```
점검 항목:
□ SQL Injection
  - 문자열 연결(concatenation)로 쿼리 생성하는 코드
  - Parameterized query / ORM 사용 확인
□ NoSQL Injection
  - MongoDB $where, $regex 등에 사용자 입력 직접 전달
□ XSS (Cross-Site Scripting)
  - dangerouslySetInnerHTML, v-html, innerHTML
  - 사용자 입력이 DOM에 삽입되는 경로
□ Command Injection
  - exec(), system(), child_process에 사용자 입력 전달
□ LDAP / XML / Template Injection
```

### A04: Insecure Design
```
점검 항목:
□ Rate limiting 부재 (로그인, API 호출, OTP 검증)
□ 비즈니스 로직 우회 가능성
  - 주문 금액을 클라이언트에서 계산?
  - 할인/쿠폰 검증을 서버에서 수행하는지?
□ 실패 시 안전 (Fail-safe defaults)
  - 인증 실패 시 기본값이 "허용"이 아닌지?
□ 다단계 인증(MFA) 미적용 중요 작업
```

### A05: Security Misconfiguration
```
점검 항목:
□ 디버그 모드 프로덕션 활성화
□ 기본 계정/비밀번호 미변경
□ 불필요한 포트/서비스 노출
□ 에러 메시지에 스택 트레이스/내부 정보 노출
□ 보안 헤더 설정
  - Content-Security-Policy
  - X-Content-Type-Options: nosniff
  - Strict-Transport-Security
  - X-Frame-Options
□ 불필요한 HTTP 메서드 비활성화
```

## 자동화 점검 명령

```bash
# 시크릿 탐지
grep -rn "password\|secret\|api_key\|token\|private_key" \
  --include="*.ts" --include="*.js" --include="*.py" \
  --include="*.env" --include="*.yaml" --include="*.json" \
  --exclude-dir=node_modules --exclude-dir=.git

# .env 파일이 gitignore에 포함되어 있는지
grep -q "\.env" .gitignore && echo "OK" || echo "⚠️ .env not in .gitignore"

# 의존성 취약점 스캔
npm audit                # Node.js
pip audit                # Python (pip-audit)
cargo audit              # Rust

# 알려진 취약 패턴 검색
grep -rn "eval(" --include="*.js" --include="*.ts"
grep -rn "innerHTML\|dangerouslySetInnerHTML" --include="*.tsx" --include="*.jsx"
grep -rn "child_process\|exec(" --include="*.js" --include="*.ts"
grep -rn "SELECT.*+\|INSERT.*+" --include="*.js" --include="*.ts" --include="*.py"
```

## 보안 감사 보고서 형식

```markdown
# Security Audit Report

**대상**: {프로젝트명} v{버전}
**일시**: {날짜}
**범위**: Level {1|2|3}
**감사자**: Claude Code + {리뷰어}

## 요약
- 🔴 Critical: {N}건
- 🟠 High: {N}건
- 🟡 Medium: {N}건
- 🔵 Low: {N}건
- ℹ️ Informational: {N}건

## 발견사항

### [CRITICAL] {제목}
- **위치**: `src/auth/login.ts:42`
- **유형**: A03 Injection - SQL Injection
- **설명**: 사용자 입력이 직접 SQL 쿼리에 삽입됨
- **영향**: 데이터베이스 전체 접근 가능
- **재현**: `' OR 1=1 --` 입력 시 모든 레코드 반환
- **수정 방안**: Parameterized query 사용
- **참고**: https://cheatsheetseries.owasp.org/...

## 권장사항
1. ...
2. ...
```

## 중요 원칙
- 발견된 취약점의 실제 악용 가능성(exploitability)을 평가
- 오탐(false positive)을 최소화하되, 놓치는 것보다 보수적으로 보고
- 수정 우선순위: Critical → High → Medium → Low
- 수정 방안은 구체적 코드 예시 포함
