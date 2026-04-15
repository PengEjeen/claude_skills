---
name: ml-training
description: ML/AI 모델 학습, 평가, RAG 시스템을 구축합니다. "모델 학습", "파인튜닝", "임베딩", "벡터 검색", "모델 평가", "데이터셋", "ML training", "fine-tuning", "embeddings", "model evaluation", "dataset" 등의 요청 시 사용합니다. LLM 통합, 임베딩 생성, 검색 시스템 개발을 포함합니다.
allowed-tools: Read, Write, Edit, Bash
---

# ML/AI 개발 가이드

## 📋 개발 프로세스

1. **데이터 준비**: 학습/평가 데이터셋 구축
2. **모델 설계**: 아키텍처 선택 및 구성
3. **학습/평가**: 모델 훈련 및 성능 측정
4. **최적화**: 하이퍼파라미터 튜닝 및 성능 개선
5. **배포**: 프로덕션 환경 준비

## 🎯 ML 개발 원칙 (2026 Best Practices)

### 필수 원칙
- ✅ **재현 가능성**: Random seed 고정, 버전 관리
- ✅ **평가 메트릭**: 정량적 성능 측정
- ✅ **실험 추적**: MLflow, Weights & Biases 활용
- ✅ **데이터 버전 관리**: DVC 또는 Git LFS
- ✅ **모델 버전 관리**: 체크포인트 저장

### 선택적 개선
- 🔧 **분산 학습**: Multi-GPU, Distributed training
- 🔧 **자동화**: CI/CD for ML (MLOps)
- 🔧 **모니터링**: 실시간 성능 추적

## 📁 권장 파일 구조

```
ml_project/
├── data/                   # 데이터
│   ├── raw/               # 원본 데이터
│   ├── processed/         # 전처리된 데이터
│   └── external/          # 외부 데이터
├── models/                # 학습된 모델
│   ├── checkpoints/
│   └── final/
├── notebooks/             # Jupyter 노트북
│   ├── exploratory/       # 탐색적 분석
│   └── experiments/       # 실험 노트북
├── src/                   # 소스 코드
│   ├── data/             # 데이터 처리
│   │   ├── preprocessing.py
│   │   └── data_loader.py
│   ├── models/           # 모델 정의
│   │   ├── model.py
│   │   └── trainer.py
│   ├── evaluation/       # 평가
│   │   ├── metrics.py
│   │   └── evaluator.py
│   └── utils/            # 유틸리티
│       ├── logger.py
│       └── helpers.py
├── scripts/              # 실행 스크립트
│   ├── train.py
│   ├── evaluate.py
│   └── predict.py
├── tests/                # 테스트
│   ├── test_data.py
│   └── test_models.py
├── configs/              # 설정 파일
│   └── config.yaml
└── requirements.txt      # 의존성
```

## 🛠️ 주요 패턴

### 1. RAG (Retrieval-Augmented Generation) 시스템

#### 기본 RAG 파이프라인

```python
# src/rag/retriever.py
from typing import List, Dict, Any
import numpy as np
from sentence_transformers import SentenceTransformer

class VectorRetriever:
    """벡터 기반 검색기"""

    def __init__(self, embedding_model: str = "sentence-transformers/all-MiniLM-L6-v2"):
        self.model = SentenceTransformer(embedding_model)
        self.documents = []
        self.embeddings = None

    def index_documents(self, documents: List[str]) -> None:
        """문서 인덱싱"""
        self.documents = documents
        self.embeddings = self.model.encode(documents, convert_to_numpy=True)

    def retrieve(self, query: str, top_k: int = 5) -> List[Dict[str, Any]]:
        """쿼리와 유사한 문서 검색"""
        query_embedding = self.model.encode([query], convert_to_numpy=True)[0]

        # 코사인 유사도 계산
        similarities = np.dot(self.embeddings, query_embedding) / (
            np.linalg.norm(self.embeddings, axis=1) * np.linalg.norm(query_embedding)
        )

        # 상위 k개 선택
        top_indices = np.argsort(similarities)[-top_k:][::-1]

        results = [
            {
                "text": self.documents[idx],
                "score": float(similarities[idx]),
                "index": int(idx)
            }
            for idx in top_indices
        ]

        return results


# src/rag/generator.py
from anthropic import Anthropic

class RAGGenerator:
    """RAG 생성기"""

    def __init__(self, api_key: str, model: str = "claude-3-sonnet-20240229"):
        self.client = Anthropic(api_key=api_key)
        self.model = model

    def generate(
        self,
        query: str,
        contexts: List[str],
        system_prompt: str = "You are a helpful assistant."
    ) -> str:
        """컨텍스트 기반 답변 생성"""
        # 컨텍스트를 프롬프트에 포함
        context_text = "\n\n".join([f"Context {i+1}: {ctx}" for i, ctx in enumerate(contexts)])

        user_prompt = f"""Based on the following contexts, answer the question.

Contexts:
{context_text}

Question: {query}

Answer:"""

        response = self.client.messages.create(
            model=self.model,
            max_tokens=1024,
            system=system_prompt,
            messages=[
                {"role": "user", "content": user_prompt}
            ]
        )

        return response.content[0].text


# src/rag/rag_system.py
class RAGSystem:
    """통합 RAG 시스템"""

    def __init__(self, retriever: VectorRetriever, generator: RAGGenerator):
        self.retriever = retriever
        self.generator = generator

    def query(self, query: str, top_k: int = 3) -> Dict[str, Any]:
        """RAG 질의"""
        # 1. 검색
        retrieved_docs = self.retriever.retrieve(query, top_k=top_k)
        contexts = [doc["text"] for doc in retrieved_docs]

        # 2. 생성
        answer = self.generator.generate(query, contexts)

        return {
            "query": query,
            "answer": answer,
            "sources": retrieved_docs
        }
```

### 2. 하이브리드 검색 (Keyword + Semantic)

```python
# src/rag/hybrid_retriever.py
from typing import List, Dict, Any
import numpy as np
from rank_bqm import rank_bm25

class HybridRetriever:
    """키워드 + 시맨틱 하이브리드 검색"""

    def __init__(self, vector_retriever: VectorRetriever, alpha: float = 0.5):
        self.vector_retriever = vector_retriever
        self.bm25 = None
        self.alpha = alpha  # 벡터 검색 가중치

    def index_documents(self, documents: List[str]) -> None:
        """문서 인덱싱"""
        # 벡터 인덱싱
        self.vector_retriever.index_documents(documents)

        # BM25 인덱싱
        tokenized_docs = [doc.split() for doc in documents]
        self.bm25 = rank_bm25.BM25Okapi(tokenized_docs)

    def retrieve(self, query: str, top_k: int = 5) -> List[Dict[str, Any]]:
        """하이브리드 검색"""
        # 벡터 검색
        vector_results = self.vector_retriever.retrieve(query, top_k=top_k * 2)

        # BM25 검색
        tokenized_query = query.split()
        bm25_scores = self.bm25.get_scores(tokenized_query)

        # 스코어 정규화 및 결합
        combined_scores = {}
        for result in vector_results:
            idx = result["index"]
            vector_score = result["score"]
            bm25_score = bm25_scores[idx]

            # 정규화 (0-1 범위)
            normalized_bm25 = bm25_score / (bm25_scores.max() + 1e-8)

            # 가중 평균
            combined_scores[idx] = (
                self.alpha * vector_score +
                (1 - self.alpha) * normalized_bm25
            )

        # 상위 k개 선택
        top_indices = sorted(combined_scores.keys(), key=lambda x: combined_scores[x], reverse=True)[:top_k]

        results = [
            {
                "text": self.vector_retriever.documents[idx],
                "score": combined_scores[idx],
                "index": idx
            }
            for idx in top_indices
        ]

        return results
```

### 3. Reranker 패턴

```python
# src/rag/reranker.py
from typing import List, Dict, Any
from sentence_transformers import CrossEncoder

class Reranker:
    """재순위화 모델"""

    def __init__(self, model_name: str = "cross-encoder/ms-marco-MiniLM-L-6-v2"):
        self.model = CrossEncoder(model_name)

    def rerank(
        self,
        query: str,
        documents: List[Dict[str, Any]],
        top_k: int = 3
    ) -> List[Dict[str, Any]]:
        """문서 재순위화"""
        # 쿼리-문서 쌍 생성
        pairs = [[query, doc["text"]] for doc in documents]

        # 점수 예측
        scores = self.model.predict(pairs)

        # 재순위화
        for doc, score in zip(documents, scores):
            doc["rerank_score"] = float(score)

        reranked = sorted(documents, key=lambda x: x["rerank_score"], reverse=True)

        return reranked[:top_k]
```

### 4. 환각(Hallucination) 감지

```python
# src/evaluation/hallucination_detector.py
from typing import List, Dict, Any
import re

class HallucinationDetector:
    """LLM 환각 감지"""

    def detect(
        self,
        answer: str,
        contexts: List[str],
        threshold: float = 0.7
    ) -> Dict[str, Any]:
        """환각 감지"""
        # 답변에서 주요 주장 추출
        claims = self._extract_claims(answer)

        # 각 주장의 근거 확인
        unsupported_claims = []
        for claim in claims:
            if not self._is_supported(claim, contexts, threshold):
                unsupported_claims.append(claim)

        is_hallucinated = len(unsupported_claims) > 0

        return {
            "is_hallucinated": is_hallucinated,
            "unsupported_claims": unsupported_claims,
            "total_claims": len(claims),
            "support_rate": 1 - (len(unsupported_claims) / max(len(claims), 1))
        }

    def _extract_claims(self, text: str) -> List[str]:
        """주장 추출 (간단한 문장 분리)"""
        sentences = re.split(r'[.!?]\s+', text)
        return [s.strip() for s in sentences if len(s.strip()) > 10]

    def _is_supported(self, claim: str, contexts: List[str], threshold: float) -> bool:
        """주장이 컨텍스트에 근거하는지 확인"""
        # 간단한 키워드 매칭 (실제로는 더 정교한 방법 필요)
        claim_words = set(claim.lower().split())

        for context in contexts:
            context_words = set(context.lower().split())
            overlap = len(claim_words.intersection(context_words))
            similarity = overlap / len(claim_words) if claim_words else 0

            if similarity >= threshold:
                return True

        return False
```

### 5. 평가 메트릭

```python
# src/evaluation/metrics.py
from typing import List, Dict, Any
import numpy as np
from sklearn.metrics import precision_recall_fscore_support

class RAGEvaluator:
    """RAG 시스템 평가"""

    @staticmethod
    def context_precision(
        retrieved_docs: List[Dict],
        relevant_docs: List[str],
        k: int = 5
    ) -> float:
        """Context Precision@K"""
        retrieved_ids = [doc["index"] for doc in retrieved_docs[:k]]
        relevant_count = sum(1 for doc_id in retrieved_ids if doc_id in relevant_docs)
        return relevant_count / k if k > 0 else 0.0

    @staticmethod
    def context_recall(
        retrieved_docs: List[Dict],
        relevant_docs: List[str]
    ) -> float:
        """Context Recall"""
        if not relevant_docs:
            return 0.0

        retrieved_ids = [doc["index"] for doc in retrieved_docs]
        relevant_count = sum(1 for doc_id in relevant_docs if doc_id in retrieved_ids)
        return relevant_count / len(relevant_docs)

    @staticmethod
    def mean_reciprocal_rank(
        retrieved_docs: List[Dict],
        relevant_docs: List[str]
    ) -> float:
        """Mean Reciprocal Rank"""
        for rank, doc in enumerate(retrieved_docs, 1):
            if doc["index"] in relevant_docs:
                return 1.0 / rank
        return 0.0

    @staticmethod
    def ndcg_at_k(
        retrieved_docs: List[Dict],
        relevance_scores: Dict[str, float],
        k: int = 5
    ) -> float:
        """Normalized Discounted Cumulative Gain@K"""
        dcg = 0.0
        for rank, doc in enumerate(retrieved_docs[:k], 1):
            relevance = relevance_scores.get(doc["index"], 0.0)
            dcg += (2 ** relevance - 1) / np.log2(rank + 1)

        # IDCG (Ideal DCG)
        ideal_relevances = sorted(relevance_scores.values(), reverse=True)[:k]
        idcg = sum(
            (2 ** rel - 1) / np.log2(rank + 1)
            for rank, rel in enumerate(ideal_relevances, 1)
        )

        return dcg / idcg if idcg > 0 else 0.0
```

### 6. 실험 추적 (MLflow)

```python
# scripts/train_with_tracking.py
import mlflow
import mlflow.sklearn
from src.models.model import MyModel

def train_with_tracking():
    """MLflow로 실험 추적"""

    # 실험 설정
    mlflow.set_experiment("rag-optimization")

    with mlflow.start_run(run_name="hybrid-retrieval-v1"):
        # 하이퍼파라미터 로깅
        params = {
            "embedding_model": "all-MiniLM-L6-v2",
            "alpha": 0.5,  # 하이브리드 가중치
            "top_k": 5,
            "reranker": "cross-encoder",
        }
        mlflow.log_params(params)

        # 모델 학습
        model = MyModel(**params)
        model.train(data)

        # 메트릭 로깅
        metrics = evaluate_model(model)
        mlflow.log_metrics({
            "precision@5": metrics["precision"],
            "recall@5": metrics["recall"],
            "mrr": metrics["mrr"],
            "latency_ms": metrics["latency"]
        })

        # 모델 저장
        mlflow.sklearn.log_model(model, "model")

        # 아티팩트 로깅
        mlflow.log_artifact("results/confusion_matrix.png")

    print(f"Run completed. View at: {mlflow.get_tracking_uri()}")
```

## 📊 성능 최적화 전략

### 1. 토큰 효율성

```python
# 프롬프트 압축
def compress_context(contexts: List[str], max_tokens: int = 2000) -> str:
    """컨텍스트 압축"""
    compressed = []
    total_tokens = 0

    for ctx in contexts:
        tokens = len(ctx.split())  # 간단한 토큰 추정
        if total_tokens + tokens > max_tokens:
            break
        compressed.append(ctx)
        total_tokens += tokens

    return "\n\n".join(compressed)


# 캐싱
from functools import lru_cache

@lru_cache(maxsize=1000)
def get_embeddings(text: str) -> np.ndarray:
    """임베딩 캐싱"""
    return model.encode([text])[0]
```

### 2. 배치 처리

```python
# 병렬 처리
import asyncio
from typing import List

async def process_batch(queries: List[str], batch_size: int = 10) -> List[Dict]:
    """배치 병렬 처리"""
    results = []

    for i in range(0, len(queries), batch_size):
        batch = queries[i:i + batch_size]
        tasks = [rag_system.query(q) for q in batch]
        batch_results = await asyncio.gather(*tasks)
        results.extend(batch_results)

    return results
```

### 3. 인덱스 최적화

```python
# FAISS 벡터 인덱스
import faiss

class FAISSRetriever:
    """FAISS 기반 고속 검색"""

    def __init__(self, embedding_dim: int = 384):
        self.index = faiss.IndexFlatL2(embedding_dim)
        self.documents = []

    def index_documents(self, documents: List[str], embeddings: np.ndarray) -> None:
        """대용량 문서 인덱싱"""
        self.documents = documents
        self.index.add(embeddings.astype('float32'))

    def retrieve(self, query_embedding: np.ndarray, top_k: int = 5) -> List[Dict]:
        """고속 검색"""
        distances, indices = self.index.search(
            query_embedding.astype('float32').reshape(1, -1),
            top_k
        )

        results = [
            {
                "text": self.documents[idx],
                "score": 1 / (1 + float(dist)),  # 거리를 유사도로 변환
                "index": int(idx)
            }
            for idx, dist in zip(indices[0], distances[0])
        ]

        return results
```

## 🧪 테스트 및 평가

```bash
# 모델 학습
python scripts/train.py --config configs/config.yaml

# 평가
python scripts/evaluate.py --model models/best_model.pt --test-data data/test.jsonl

# 추론
python scripts/predict.py --input "Your query here"

# MLflow UI 실행
mlflow ui --port 5000
```

## 📚 추가 리소스

- [Hugging Face Transformers](https://huggingface.co/docs/transformers)
- [LangChain 문서](https://python.langchain.com/)
- [FAISS 문서](https://faiss.ai/)
- [MLflow 문서](https://mlflow.org/docs/latest/index.html)
