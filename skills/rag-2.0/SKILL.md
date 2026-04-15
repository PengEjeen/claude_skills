---
name: rag-2.0
description: 2026년 기준 고급 RAG 시스템을 설계하고 구현합니다. "RAG", "검색 증강 생성", "벡터 검색", "하이브리드 검색", "임베딩", "RAG system", "retrieval", "vector search", "hybrid search" 등의 요청 시 사용합니다. Hybrid Search, GraphRAG, Advanced Retrieval 패턴을 포함합니다.
---

# RAG 2.0 Skill

Advanced retrieval-augmented generation patterns for 2026.

## Purpose

Implement state-of-the-art RAG systems with hybrid search, advanced retrieval patterns, and comprehensive evaluation.

## Core Patterns

### 1. Hybrid Search

Combine lexical (BM25) and semantic (vector) search:

```python
from rank_bm25 import BM25Okapi
import numpy as np

class HybridSearcher:
    def __init__(self, documents, embedder, alpha=0.5):
        self.documents = documents
        self.embedder = embedder
        self.alpha = alpha  # 0 = BM25 only, 1 = vector only

        # BM25 index
        tokenized = [doc.split() for doc in documents]
        self.bm25 = BM25Okapi(tokenized)

        # Vector index
        self.embeddings = embedder.encode(documents)

    def search(self, query: str, top_k: int = 10):
        # BM25 scores
        bm25_scores = self.bm25.get_scores(query.split())
        bm25_scores = bm25_scores / (bm25_scores.max() + 1e-6)

        # Vector scores
        query_emb = self.embedder.encode(query)
        vector_scores = np.dot(self.embeddings, query_emb)
        vector_scores = (vector_scores + 1) / 2  # Normalize cosine

        # Combine
        combined = (1 - self.alpha) * bm25_scores + self.alpha * vector_scores

        # Return top-k
        top_indices = np.argsort(combined)[-top_k:][::-1]
        return [(self.documents[i], combined[i]) for i in top_indices]
```

### 2. HyDE (Hypothetical Document Embeddings)

Generate hypothetical answer, then search:

```python
class HyDERetriever:
    def __init__(self, llm, embedder, index):
        self.llm = llm
        self.embedder = embedder
        self.index = index

    def retrieve(self, query: str, top_k: int = 5):
        # Generate hypothetical answer
        hypothetical = self.llm.generate(
            f"Write a detailed passage that answers: {query}"
        )

        # Embed hypothetical (not the query)
        embedding = self.embedder.encode(hypothetical)

        # Search with hypothetical embedding
        return self.index.search(embedding, top_k)
```

### 3. Multi-Query Retrieval

Generate query variants for broader coverage:

```python
class MultiQueryRetriever:
    def __init__(self, llm, retriever):
        self.llm = llm
        self.retriever = retriever

    def retrieve(self, query: str, top_k: int = 10):
        # Generate query variants
        variants = self.llm.generate(
            f"""Generate 3 different versions of this question.
            Each should capture a different aspect or phrasing.

            Original: {query}

            Variants:"""
        ).split('\n')

        # Retrieve for each variant
        all_results = []
        for variant in [query] + variants:
            results = self.retriever.search(variant, top_k=5)
            all_results.extend(results)

        # Deduplicate and rerank
        return self.deduplicate_and_rank(all_results, top_k)
```

### 4. Parent-Child Retrieval

Search small chunks, return larger context:

```python
class ParentChildRetriever:
    def __init__(self, embedder, child_size=256, parent_size=1024):
        self.embedder = embedder
        self.child_size = child_size
        self.parent_size = parent_size
        self.child_to_parent = {}  # Maps child_id -> parent_id
        self.parents = {}          # parent_id -> full text
        self.child_index = None    # Vector index of children

    def index_document(self, doc_id: str, text: str):
        # Create parent chunks
        parent_chunks = self.chunk(text, self.parent_size)
        for i, parent in enumerate(parent_chunks):
            parent_id = f"{doc_id}_p{i}"
            self.parents[parent_id] = parent

            # Create child chunks from parent
            child_chunks = self.chunk(parent, self.child_size)
            for j, child in enumerate(child_chunks):
                child_id = f"{parent_id}_c{j}"
                self.child_to_parent[child_id] = parent_id
                # Index child
                self.child_index.add(child_id, self.embedder.encode(child))

    def retrieve(self, query: str, top_k: int = 5):
        # Search children
        query_emb = self.embedder.encode(query)
        child_results = self.child_index.search(query_emb, top_k * 2)

        # Map to parents and deduplicate
        parent_ids = list(set(
            self.child_to_parent[child_id]
            for child_id, _ in child_results
        ))

        # Return parent chunks
        return [self.parents[pid] for pid in parent_ids[:top_k]]
```

### 5. Self-RAG

Retrieve only when needed, with self-critique:

```python
class SelfRAG:
    def __init__(self, llm, retriever):
        self.llm = llm
        self.retriever = retriever

    def generate(self, query: str):
        # Decide if retrieval needed
        needs_retrieval = self.llm.generate(
            f"Does this question need external knowledge? {query}\nAnswer YES or NO:"
        ).strip().upper() == "YES"

        if needs_retrieval:
            # Retrieve and generate
            contexts = self.retriever.search(query, top_k=3)
            context_text = "\n".join(contexts)

            response = self.llm.generate(
                f"Context:\n{context_text}\n\nQuestion: {query}\nAnswer:"
            )

            # Critique: Is response supported by context?
            is_grounded = self.llm.generate(
                f"Is this answer fully supported by the context?\n"
                f"Answer: {response}\nContext: {context_text}\n"
                f"Reply SUPPORTED or NOT_SUPPORTED:"
            ).strip().upper() == "SUPPORTED"

            if not is_grounded:
                # Retry with more context or flag
                return self.generate_with_more_context(query)

            return response
        else:
            # Direct generation
            return self.llm.generate(query)
```

### 6. CRAG (Corrective RAG)

Evaluate and correct retrieval:

```python
class CorrectiveRAG:
    def __init__(self, llm, retriever, web_search):
        self.llm = llm
        self.retriever = retriever
        self.web_search = web_search

    def generate(self, query: str):
        # Initial retrieval
        docs = self.retriever.search(query, top_k=5)

        # Evaluate relevance
        relevance_scores = [
            self.evaluate_relevance(query, doc)
            for doc in docs
        ]

        # Classify retrieval quality
        avg_relevance = sum(relevance_scores) / len(relevance_scores)

        if avg_relevance > 0.7:
            # Good retrieval - use as is
            return self.generate_with_context(query, docs)
        elif avg_relevance > 0.3:
            # Ambiguous - supplement with web search
            web_results = self.web_search(query)
            combined = docs + web_results
            return self.generate_with_context(query, combined)
        else:
            # Poor retrieval - rely on web search
            web_results = self.web_search(query)
            return self.generate_with_context(query, web_results)
```

## Evaluation: RAGAS Metrics

```python
from ragas import evaluate
from ragas.metrics import (
    faithfulness,
    answer_relevancy,
    context_relevancy,
    context_recall
)

# Evaluate your RAG pipeline
results = evaluate(
    dataset,
    metrics=[
        faithfulness,        # Is answer grounded in context?
        answer_relevancy,    # Does answer match question?
        context_relevancy,   # Is retrieved context relevant?
        context_recall       # Is all needed info retrieved?
    ]
)

# Target scores
TARGETS = {
    "faithfulness": 0.9,
    "answer_relevancy": 0.85,
    "context_relevancy": 0.75,
    "context_recall": 0.8
}
```

## Chunking Strategies

| Strategy | Chunk Size | Overlap | Best For |
|----------|------------|---------|----------|
| Fixed | 512 | 50 | General purpose |
| Semantic | Variable | Sentence | Documents |
| Code | Function | None | Source code |
| Markdown | Section | Headers | Documentation |
| Parent-Child | 256/1024 | - | Precision + Context |

## Quick Reference

```markdown
Retrieval Patterns:
- Hybrid Search: BM25 + Vector (α=0.5)
- HyDE: Generate hypothetical → search
- Multi-Query: Query variants → merge
- Parent-Child: Small search → large return

Self-Correcting:
- Self-RAG: Retrieve if needed, critique
- CRAG: Evaluate → correct → fallback

Metrics (RAGAS):
- Faithfulness > 0.9
- Answer Relevancy > 0.85
- Context Relevancy > 0.75
- Context Recall > 0.8
```
