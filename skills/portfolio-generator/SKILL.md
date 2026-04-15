---
name: portfolio-generator
description: 프로젝트 코드베이스를 스캔·분석하여 2026년 글로벌 표준 포트폴리오 문서를 자동 생성합니다. "포트폴리오 작성", "포폴 만들어", "프로젝트 정리", "portfolio generate", "case study", "프로젝트 소개 작성" 등의 요청 시 사용합니다. 아키텍처 다이어그램, 기술 선택 근거, 트러블슈팅 스토리, 성과 지표를 포함한 면접관 선호 형식으로 출력합니다.
---

# Portfolio Generator Skill — 2026 Global Standard

## 목적
프로젝트 코드베이스를 자동 분석하여, 면접관과 채용 담당자가 선호하는 형식의
포트폴리오 프로젝트 문서를 생성한다. 2026년 글로벌 채용 트렌드 기반.

## 핵심 원칙
- **3~5개 프로젝트, 깊이 > 넓이**: 10개 얕은 프로젝트보다 3개 깊은 케이스 스터디
- **동작하는 결과물**: 84% 고용주가 코드가 아닌 동작하는 앱을 원함
- **Why 중심**: 기술 나열이 아니라 "왜 이 기술을 선택했는가"
- **정량 지표**: TPS, 응답시간, 가용성, 코드 커버리지 등 측정 가능한 수치
- **클론 프로젝트 금지**: Netflix/Spotify 클론은 튜토리얼 따라했다는 신호

## Phase 1: 코드베이스 스캔 및 분석

### 1.1 자동 수집 항목
다음을 코드베이스에서 자동 추출한다:

```
수집 대상:
├── package.json / pyproject.toml / go.mod → 기술 스택, 의존성
├── docker-compose*.yml / Dockerfile → 인프라 구성
├── .github/workflows/ → CI/CD 파이프라인
├── src/ 구조 → 아키텍처 패턴 (레이어드, 모듈러, 마이크로서비스)
├── tests/ → 테스트 전략 (단위, 통합, E2E)
├── API 라우트 파일 → 엔드포인트 목록, REST/GraphQL
├── DB 마이그레이션/스키마 → 데이터 모델링
├── 환경 설정 (.env.example) → 외부 서비스 연동
├── README.md → 기존 문서 참조
└── git log → 개발 히스토리, 기여도, 커밋 패턴
```

### 1.2 분석 체크리스트
```
[ ] 프로젝트 유형 판별 (SaaS, API, CLI, 라이브러리, 인프라, AI/ML)
[ ] 아키텍처 패턴 식별 (MVC, Clean Architecture, Hexagonal, CQRS, Event-Driven)
[ ] 기술 스택 분류 (언어, 프레임워크, DB, 캐시, 메시지 큐, 모니터링)
[ ] 외부 서비스 연동 식별 (AWS, GCP, OpenAI, Stripe 등)
[ ] 테스트 커버리지 및 전략 파악
[ ] CI/CD 파이프라인 구성 파악
[ ] 코드 규모 산정 (총 라인, 파일 수, 언어 비율)
[ ] 특이 기술 (RAG, Vector DB, WebSocket, gRPC 등) 식별
```

## Phase 2: 포트폴리오 문서 생성

### 출력 포맷 — 프로젝트별 케이스 스터디

각 프로젝트에 대해 아래 구조로 문서를 생성한다:

```markdown
# [프로젝트명]

> 한 줄 설명 — 이 프로젝트가 해결하는 문제

## 📋 Overview
| 항목 | 내용 |
|------|------|
| **기간** | YYYY.MM ~ YYYY.MM (N개월) |
| **팀 규모** | N명 (역할: 백엔드 리드 / 풀스택 / 인프라) |
| **나의 기여도** | 구체적 담당 영역과 비율 |
| **배포 상태** | 운영 중 / 데모 가능 / 아카이브 |
| **링크** | [Live Demo](url) · [GitHub](url) · [API Docs](url) |

## 🎯 Problem & Context
- 어떤 문제를 해결하는가? (비즈니스/기술적 배경)
- 기존에 왜 해결되지 않았는가?
- 타겟 사용자와 주요 유스케이스

## 🏗️ Architecture
\```mermaid
graph TB
    subgraph Client
        A[React SPA] --> B[API Gateway]
    end
    subgraph Backend
        B --> C[Auth Service]
        B --> D[Core Service]
        D --> E[(PostgreSQL)]
        D --> F[(Redis Cache)]
    end
    subgraph Infra
        G[Docker] --> H[Nginx]
        I[GitHub Actions] --> G
    end
\```

### 주요 설계 결정
| 결정 | 선택 | 대안 | 선택 이유 |
|------|------|------|-----------|
| DB | PostgreSQL | MongoDB | 관계형 데이터 + ACID 트랜잭션 필요 |
| 캐시 | Redis | Memcached | Pub/Sub + 다양한 자료구조 활용 |
| 배포 | Docker Compose | K8s | 소규모 서비스, 운영 복잡도 최소화 |

## 🔧 Tech Stack
### Backend
- **Language**: Python 3.12 / TypeScript 5.x
- **Framework**: FastAPI / Next.js
- **Database**: PostgreSQL 16 + pgvector
- **Cache**: Redis 7
- **Message Queue**: (해당 시)

### Infrastructure
- **Container**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Monitoring**: (해당 시)
- **Cloud**: AWS / GCP (해당 시)

### AI/ML (해당 시)
- **LLM**: Claude API / OpenAI
- **Embeddings**: text-embedding-3-small
- **Vector DB**: pgvector / Qdrant
- **Framework**: LangChain / LangGraph

## 💡 Key Features & Implementation
### Feature 1: [기능명]
**문제**: ...
**해결**: ...
**코드 하이라이트**:
\```python
# 핵심 구현 코드 (10~20줄)
\```

### Feature 2: [기능명]
(동일 구조)

## 🔥 Challenges & Solutions (트러블슈팅)
### Challenge 1: [제목]
- **상황**: 무엇이 문제였는가
- **원인 분석**: 왜 발생했는가 (근본 원인)
- **해결 과정**: 어떻게 진단하고 해결했는가
- **결과**: 개선된 수치 (Before → After)
- **교훈**: 이 경험에서 배운 원칙

### Challenge 2: [제목]
(동일 구조)

## 📊 Results & Metrics
| 지표 | 수치 |
|------|------|
| API 응답시간 (p95) | XXms |
| 처리량 (TPS) | XX req/s |
| 가용성 | 99.X% |
| 테스트 커버리지 | XX% |
| 코드 라인 수 | XX,XXX |

## 🎓 What I Learned
- **기술적 성장**: 이 프로젝트를 통해 깊이 이해하게 된 기술
- **설계 관점**: 아키텍처/설계에서 얻은 인사이트
- **다시 한다면**: 개선할 점 (솔직한 회고)

## 🔮 Future Improvements
- 확장 계획 또는 개선 아이디어 (선택)
```

## Phase 3: 추가 산출물

### 3.1 포트폴리오 요약 (1-pager)
모든 프로젝트를 한 페이지로 요약한 Overview 문서도 함께 생성:

```markdown
# [이름] — AI/Backend/Infra Engineer Portfolio

## About Me
(2~3문장: 핵심 역량, 관심 분야, 차별화 포인트)

## Projects
| # | 프로젝트 | 핵심 기술 | 역할 | 주요 성과 |
|---|----------|-----------|------|-----------|
| 1 | [이름](링크) | Python, FastAPI, PostgreSQL | 백엔드 리드 | p95 45ms, 99.9% 가용성 |
| 2 | [이름](링크) | LangGraph, RAG, pgvector | 풀스택 | 검색 정확도 92% |
| 3 | [이름](링크) | Docker, Nginx, GitHub Actions | 인프라 | 배포 시간 15분→2분 |

## Technical Skills
(카테고리별 정리: Languages, Frameworks, Databases, Cloud, AI/ML, DevOps)

## Open Source & Blog
- [기여 PR 링크]
- [기술 블로그 링크]
```

### 3.2 GitHub README 프로필용 요약
GitHub 프로필 README에 바로 넣을 수 있는 형식도 생성.

## AI/Backend/Infra 특화 포인트

### AI Engineer 포트폴리오 필수 항목
- [ ] RAG 파이프라인 구축 경험 (Chunking, Embedding, Retrieval 전략)
- [ ] LLM API 통합 및 프롬프트 엔지니어링
- [ ] Vector DB 선택/운영 경험
- [ ] Observability (LangSmith, Langfuse 등)
- [ ] 모델 평가 방법론 (자동 평가, 인간 평가)
- [ ] 비용 최적화 (토큰 사용량, 캐싱 전략)

### Backend Engineer 포트폴리오 필수 항목
- [ ] RESTful API 설계 (또는 GraphQL)
- [ ] 데이터베이스 설계 및 최적화 (인덱싱, 쿼리 튜닝)
- [ ] 인증/인가 시스템 (JWT, OAuth, RBAC)
- [ ] 동시성/비동기 처리
- [ ] 에러 핸들링 및 로깅 전략
- [ ] 테스트 전략 (단위, 통합, E2E)

### Infra/DevOps 포트폴리오 필수 항목
- [ ] 컨테이너화 및 오케스트레이션 (Docker, K8s)
- [ ] CI/CD 파이프라인 구축
- [ ] IaC (Terraform, Ansible 등)
- [ ] 모니터링/알림 시스템
- [ ] 보안 (시크릿 관리, 네트워크 정책)
- [ ] 비용 최적화

## 실행 절차

1. **스캔**: 대상 프로젝트 디렉토리의 코드베이스 자동 분석
2. **질문**: 자동 추출 불가능한 정보를 사용자에게 질문
   - 프로젝트 배경/동기
   - 팀 구성 및 본인 역할
   - 핵심 트러블슈팅 경험
   - 성과 지표 (정량)
3. **생성**: 케이스 스터디 문서 초안 생성
4. **리뷰**: 사용자와 함께 내용 검토 및 보완
5. **출력**: 최종 문서를 `docs/portfolio/` 디렉토리에 저장

## 출력 위치
```
docs/portfolio/
├── README.md              # 포트폴리오 요약 (1-pager)
├── project-1-[name].md    # 프로젝트별 케이스 스터디
├── project-2-[name].md
├── project-3-[name].md
└── github-profile.md      # GitHub 프로필 README용
```

## 품질 기준
- [ ] 모든 기술 선택에 "왜?"가 있는가
- [ ] 정량 지표가 1개 이상 포함되었는가
- [ ] 아키텍처 다이어그램이 있는가 (Mermaid)
- [ ] 트러블슈팅 스토리가 2개 이상인가
- [ ] "다시 한다면" 회고가 솔직한가
- [ ] 처음 보는 사람이 3분 안에 프로젝트를 이해할 수 있는가
