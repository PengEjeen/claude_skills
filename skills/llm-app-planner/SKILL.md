---
name: llm-app-planner
description: LLM 앱 기획 빠른 참조 가이드. 상세 설계는 chatbot-designer 스킬을 사용합니다. "LLM 앱 유형", "어떤 LLM 패턴", "RAG vs Agent", "LLM 앱 비교", "quick reference" 등의 요청 시 빠른 의사결정을 지원합니다.
---

# LLM App Planner — Quick Decision Guide

> 빠른 의사결정을 위한 참조 카드. 상세 설계는 **chatbot-designer** 스킬을 사용하세요.

## LLM 앱 유형 선택 매트릭스

| 요구사항 | 추천 패턴 | 복잡도 | 비용 |
|----------|-----------|--------|------|
| 단순 Q&A, 텍스트 변환 | **Prompt-based** | Low | $ |
| 기업 문서 기반 답변 | **RAG** | Medium | $$ |
| 외부 시스템 연동 필요 | **Tool-use Agent** | Medium-High | $$$ |
| 복잡한 다단계 작업 | **Multi-Agent** | High | $$$$ |
| 특수 도메인 용어/형식 | **Fine-tuning + RAG** | High | $$$$ |

## 기술 스택 빠른 선택

```
오케스트레이션: LangGraph (복잡) | CrewAI (간단) | 자체 구현 (최대 제어)
벡터DB: Pinecone (관리형) | Weaviate (하이브리드) | pgvector (PostgreSQL 통합)
서빙: FastAPI + SSE | Next.js + WebSocket
모니터링: Langfuse (OSS) | LangSmith | Datadog LLM Obs
평가: RAGAS | custom golden set
```

## 비용 최적화 체크리스트

```
□ 프롬프트 캐싱 적용했는가?
□ 모델 라우팅 (간단→작은 모델, 복잡→큰 모델) 구현했는가?
□ 응답 캐시 (동일 질문) 적용했는가?
□ 청킹 전략이 최적화되었는가? (512 토큰 권장)
□ 불필요한 컨텍스트를 제거했는가?
```

## 상세 설계 가이드 → chatbot-designer 스킬

다음이 필요하면 `chatbot-designer` 스킬을 사용하세요:
- 아키텍처 패턴 상세 (ReAct, Plan-Execute 등)
- 프롬프트 엔지니어링 (CRAFT 프레임워크)
- 대화 UX 설계 (심리학 원칙)
- 메모리 & 컨텍스트 관리
- MCP/Function Calling 통합
- 평가 프레임워크 & 안전성
- 모델 선택 가이드
