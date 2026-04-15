---
name: documentation-gen
description: 기술 문서를 자동 생성하고 관리합니다. "문서화", "README 작성", "docs 생성", "JSDoc", "API 문서", "변경 로그", "CHANGELOG", "온보딩 가이드", "기술 문서 업데이트" 등의 요청 시 사용합니다. README, API 문서, ADR, CHANGELOG, 온보딩 가이드를 코드베이스 분석 기반으로 생성합니다. (개발 일지·ADR·문제 해결 기록은 dev-journal 스킬 참조)
---

# Documentation Generation Skill — Living Docs

## 목적
코드베이스를 분석하여 정확하고 유지보수 가능한 기술 문서를 생성한다.
문서가 코드와 동기화된 상태를 유지하도록 돕는다.

## 문서 유형별 생성 가이드

### 1. README.md

프로젝트 루트의 README는 다음 구조를 따른다:

```markdown
# 프로젝트명

한 줄 설명. 이 프로젝트가 무엇을 하고, 왜 존재하는지.

## Quick Start

프로젝트를 3분 안에 실행하는 최소 단계.

## Prerequisites

- Node.js >= 20
- Docker (선택)
- ...

## Installation

설치 명령어 (복사-붙여넣기 가능하도록)

## Development

개발 서버 실행, 테스트, 빌드 명령어.

## Project Structure

주요 디렉토리와 역할 (전체 트리 아님, 중요한 것만).

## Contributing

기여 방법, PR 규칙, 코드 스타일 가이드 (또는 CONTRIBUTING.md 링크).

## License

라이선스 정보.
```

### README 생성 프로세스
```
1. package.json / pyproject.toml / Cargo.toml 분석 → 프로젝트 메타
2. 디렉토리 구조 스캔 → Project Structure 섹션
3. scripts/Makefile 분석 → 명령어 섹션
4. .env.example 분석 → 환경 변수 섹션
5. 기존 README가 있으면 diff 기반 업데이트
```

### 2. CHANGELOG.md

Conventional Commits 기반으로 자동 생성:

```bash
# git log에서 conventional commits 추출
git log --oneline v1.0.0..HEAD --format="%s"
```

```markdown
# Changelog

## [1.2.0] - 2026-02-08

### Added
- OAuth2 로그인 지원 (#123)
- 사용자 프로필 이미지 업로드 (#145)

### Fixed
- 장바구니 가격 계산 소수점 오류 (#167)
- 모바일에서 메뉴 닫히지 않는 문제 (#172)

### Changed
- API 응답 형식을 RFC 9457로 표준화 (#180)

### Deprecated
- v1 인증 엔드포인트 (v1.4.0에서 제거 예정)

### Security
- XSS 취약점 수정 (CVE-2026-XXXX)
```

### 3. 코드 문서화 (JSDoc / TSDoc / Docstring)

#### TypeScript / JavaScript
```typescript
/**
 * 주문의 최종 결제 금액을 계산합니다.
 *
 * 상품 금액, 할인, 세금, 배송비를 종합하여 최종 금액을 산출합니다.
 * 할인은 쿠폰 할인과 등급 할인이 순차적으로 적용됩니다.
 *
 * @param order - 주문 정보 객체
 * @param options - 계산 옵션
 * @param options.includeTax - 세금 포함 여부 (기본값: true)
 * @param options.currency - 통화 코드 (기본값: 'KRW')
 * @returns 최종 결제 금액 (통화 최소 단위)
 * @throws {InvalidOrderError} 주문 항목이 비어있을 때
 * @throws {PricingError} 가격 계산 중 오류 발생 시
 *
 * @example
 * const total = calculateTotal(order, { includeTax: true });
 * // => 54000
 */
export function calculateTotal(
  order: Order,
  options?: CalculateOptions
): number { ... }
```

#### Python
```python
def calculate_total(
    order: Order,
    *,
    include_tax: bool = True,
    currency: str = "KRW",
) -> int:
    """주문의 최종 결제 금액을 계산합니다.

    상품 금액, 할인, 세금, 배송비를 종합하여 최종 금액을 산출합니다.

    Args:
        order: 주문 정보 객체
        include_tax: 세금 포함 여부. Defaults to True.
        currency: 통화 코드. Defaults to "KRW".

    Returns:
        최종 결제 금액 (통화 최소 단위).

    Raises:
        InvalidOrderError: 주문 항목이 비어있을 때.
        PricingError: 가격 계산 중 오류 발생 시.

    Example:
        >>> total = calculate_total(order, include_tax=True)
        >>> total
        54000
    """
```

### 문서화 대상 판단 기준
```
반드시 문서화:
  - public API (export된 함수/클래스)
  - 복잡한 비즈니스 로직
  - 비직관적인 구현 (workaround, 성능 최적화)
  - 매개변수가 3개 이상인 함수
  - 에러를 throw하는 함수

문서화 불필요:
  - 이름만으로 명확한 간단한 함수 (getName, isEmpty)
  - private 헬퍼 (간단한 경우)
  - getter/setter
  - 테스트 코드
```

### 4. 온보딩 가이드 (ONBOARDING.md)

새 팀원이 첫 PR을 올리기까지 필요한 모든 것:

```markdown
# 온보딩 가이드

## Day 1: 환경 설정
1. 저장소 클론 및 의존성 설치
2. 환경 변수 설정 (.env.example → .env)
3. 로컬 DB 설정 (Docker)
4. 개발 서버 실행 및 확인

## Day 1-2: 코드베이스 이해
1. 아키텍처 개요 (docs/architecture.md)
2. 핵심 도메인 모델 이해 (src/domain/)
3. 데이터 흐름 따라가기 (요청 → 응답)
4. 주요 ADR 읽기 (docs/adr/)

## Day 2-3: 첫 기여
1. Good First Issue 선택
2. 브랜치 생성 규칙
3. 코드 스타일 가이드
4. PR 작성 방법
5. 코드 리뷰 프로세스

## 참고 자료
- 기술 스택 문서 링크
- 팀 위키/Notion 링크
- Slack 채널 정보
```

### 5. CONTRIBUTING.md

```markdown
# Contributing Guide

## 개발 환경 설정
(설치 단계)

## 워크플로우
1. Issue 확인 또는 생성
2. 브랜치 생성: `feature/{issue-id}-{description}`
3. 구현 및 테스트
4. PR 생성
5. 코드 리뷰
6. 머지

## 커밋 규칙
Conventional Commits 사용 (feat, fix, refactor, ...)

## PR 규칙
- 제목: conventional commit 형식
- 본문: 변경 사유, 테스트 계획 포함
- 리뷰어 1명 이상 승인 필요

## 코드 스타일
(린터/포매터 설정 및 실행 방법)
```

## 문서 생성 프로세스

```
1. 코드베이스 분석
   - 파일 구조, 패키지 정보, 스크립트 목록
   - 기존 문서 확인

2. 초안 생성
   - 분석 결과 기반으로 문서 생성
   - 불확실한 부분은 [TODO: 확인 필요] 마크

3. 검증
   - 명령어가 실제로 동작하는지 실행하여 확인
   - 파일 경로가 실제로 존재하는지 확인

4. 출력
   - Markdown 파일로 저장
   - 기존 문서가 있으면 diff 표시 후 업데이트

5. 커밋
   - docs(scope): add/update documentation
```

## 중요 원칙
- 문서는 코드와 같은 리뷰 프로세스를 거친다
- "어떻게(How)"보다 "왜(Why)"를 우선 설명한다
- 복사-붙여넣기로 바로 실행 가능한 명령어를 제공한다
- 스크린샷보다 텍스트 기반 설명을 선호한다 (검색 가능, 버전 관리 용이)
- 불필요한 문서는 없는 것보다 나쁘다 — 정확하지 않으면 작성하지 않기
