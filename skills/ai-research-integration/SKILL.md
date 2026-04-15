---
name: ai-research-integration
description: 범용 AI 연구 방법론 — 모든 AI 기술에 대한 체계적 논문 조사, 평가, POC 구현, ADR 작성을 수행합니다. "논문 조사", "AI 연구", "최신 기술 적용", "연구 통합", "literature review", "paper review", "research integration", "SOTA 비교" 등의 요청 시 사용합니다. 5가지 평가 기준(관련성/참신성/재현성/적용성/성숙도) 기반 논문 스코어링, 통합 리스크 평가, 벤치마킹을 포함합니다. (LLM/Agent 특화 트렌드는 research-agent-tech 스킬 참조)
---

# AI Research & Integration Skill

Systematically research, evaluate, and integrate cutting-edge AI techniques from papers and case studies into your project.

## Purpose

Stay ahead of the curve by discovering and implementing the latest AI research findings. This skill helps you:
- Search for relevant papers and techniques
- Evaluate applicability to your project
- Design integration strategy
- Generate proof-of-concept implementations
- Track citations and references

## When to Use

Use this skill when:
- Exploring new AI techniques for a specific problem
- Evaluating state-of-the-art approaches
- Implementing research papers in production code
- Comparing multiple research approaches
- Building literature review for technical decisions

## Research Strategy

### 1. Problem Definition

First, clearly define what you're trying to solve:
```markdown
Problem: Need to improve RAG retrieval accuracy by 30%
Current approach: Simple semantic search with embeddings
Constraints: Must work with existing vector DB (Weaviate)
Timeline: 2 weeks for POC
```

### 2. Paper Search Sources

**Primary Sources (2026):**
- arXiv.org (CS.AI, CS.CL, CS.LG)
- Semantic Scholar API
- Papers with Code
- Google Scholar
- ACL Anthology (NLP)
- NeurIPS/ICML/ICLR proceedings

**Search Query Construction:**
```
Basic: "retrieval augmented generation improvements"
Advanced: "hybrid retrieval vector database 2025..2026"
Specific: "instructed retriever metadata RAG"
```

### 3. Evaluation Framework

Rate papers on 5 criteria (1-5 scale):

| Criterion | Weight | Questions |
|-----------|--------|-----------|
| **Relevance** | 25% | Does it solve our exact problem? |
| **Novelty** | 15% | Is it significantly better than baselines? |
| **Reproducibility** | 20% | Is code/data available? Clear methodology? |
| **Applicability** | 25% | Can we implement it with our stack? |
| **Maturity** | 15% | Is it production-ready or research-only? |

**Scoring Example:**
```
Paper: "Instructed Retriever with Metadata" (Databricks, 2026)
- Relevance: 5/5 (exact problem: metadata-aware retrieval)
- Novelty: 5/5 (70% improvement over baseline)
- Reproducibility: 4/5 (methodology clear, no open-source code yet)
- Applicability: 4/5 (requires fine-tuning pipeline, doable)
- Maturity: 3/5 (new technique, limited production case studies)

Total: (5*0.25 + 5*0.15 + 4*0.20 + 4*0.25 + 3*0.15) = 4.15/5 ✅ HIGH PRIORITY
```

### 4. Integration Risk Assessment

Before implementing, evaluate risks:

| Risk Category | Questions | Mitigation |
|--------------|-----------|------------|
| **Technical Debt** | Will this complicate our architecture? | Start with isolated module |
| **Dependencies** | New libraries? Version conflicts? | Use virtual env, Docker |
| **Performance** | Latency/throughput impact? | Benchmark with production data |
| **Maintenance** | Who maintains? Documentation? | Assign owner, write ADR |
| **Rollback** | Can we revert if it fails? | Feature flag, A/B test |

## Implementation Workflow

### Phase 1: Literature Review

**Output Format:**
```markdown
## Literature Review: [Topic]

**Search Date:** 2026-01-29
**Query:** "[search terms]"
**Papers Reviewed:** 12
**Papers Shortlisted:** 3

### Top 3 Papers

#### 1. [Paper Title]
- **Authors:** [Names]
- **Venue:** [Conference/Journal, Year]
- **Link:** [URL or arXiv ID]
- **Score:** 4.2/5

**Key Contributions:**
- [Contribution 1]
- [Contribution 2]

**Relevance to Our Project:**
[2-3 sentences on why this matters]

**Implementation Complexity:** Medium
**Estimated Timeline:** 2 weeks

---

[Repeat for papers 2-3]
```

### Phase 2: Proof of Concept

Generate minimal implementation:

```python
# POC: Instructed Retriever Pattern
# Based on: Databricks (2026)
# Estimated LOC: ~200 lines

from typing import List, Dict
import weaviate

class InstructedRetriever:
    """
    Implements metadata-aware retrieval from Databricks research.

    Key innovation: Uses instruction + metadata to guide retrieval,
    improving accuracy by 70% on complex queries.

    Reference: https://venturebeat.com/data/databricks-instructed-retriever
    """

    def __init__(self, client: weaviate.Client, index_name: str):
        self.client = client
        self.index_name = index_name

    def retrieve(
        self,
        query: str,
        instruction: str,
        metadata_filters: Dict[str, any],
        top_k: int = 5
    ) -> List[Dict]:
        """
        Retrieve with instruction and metadata guidance.

        Args:
            query: User query
            instruction: Task instruction (e.g., "Find technical documentation")
            metadata_filters: Metadata constraints (e.g., {"category": "API"})
            top_k: Number of results

        Returns:
            List of retrieved documents with scores
        """
        # Combine instruction with query for better retrieval
        enhanced_query = f"{instruction}\n\nQuery: {query}"

        # Build Weaviate query with metadata filters
        where_filter = self._build_where_filter(metadata_filters)

        result = (
            self.client.query
            .get(self.index_name, ["content", "metadata"])
            .with_near_text({"concepts": [enhanced_query]})
            .with_where(where_filter)
            .with_limit(top_k)
            .with_additional(["distance"])
            .do()
        )

        return self._parse_results(result)

    def _build_where_filter(self, metadata: Dict) -> Dict:
        """Convert metadata dict to Weaviate where filter."""
        # Implementation details...
        pass

    def _parse_results(self, raw_results: Dict) -> List[Dict]:
        """Parse Weaviate response into clean format."""
        # Implementation details...
        pass


# Usage example
retriever = InstructedRetriever(weaviate_client, "Documents")

results = retriever.retrieve(
    query="How do I configure authentication?",
    instruction="Find setup guides and configuration documentation",
    metadata_filters={"doc_type": "guide", "version": "2.0"},
    top_k=5
)
```

### Phase 3: Benchmarking

Compare new technique against baseline:

```python
# Benchmark script
import time
from typing import List, Tuple

def benchmark_retrieval(
    retriever,
    test_queries: List[str],
    ground_truth: List[List[str]]
) -> Dict[str, float]:
    """
    Benchmark retrieval quality and performance.

    Returns:
        - accuracy@5: How often correct doc is in top 5
        - mrr: Mean Reciprocal Rank
        - latency_p50: Median latency (ms)
        - latency_p95: 95th percentile latency (ms)
    """
    results = []
    latencies = []

    for query, truth in zip(test_queries, ground_truth):
        start = time.time()
        retrieved = retriever.retrieve(query, top_k=5)
        latency = (time.time() - start) * 1000

        latencies.append(latency)
        results.append(evaluate_retrieval(retrieved, truth))

    return {
        "accuracy@5": sum(r["hit@5"] for r in results) / len(results),
        "mrr": sum(r["reciprocal_rank"] for r in results) / len(results),
        "latency_p50": sorted(latencies)[len(latencies)//2],
        "latency_p95": sorted(latencies)[int(len(latencies)*0.95)]
    }

# Run benchmark
baseline_metrics = benchmark_retrieval(baseline_retriever, test_queries, ground_truth)
new_metrics = benchmark_retrieval(instructed_retriever, test_queries, ground_truth)

print(f"Accuracy improvement: {(new_metrics['accuracy@5'] / baseline_metrics['accuracy@5'] - 1) * 100:.1f}%")
print(f"Latency change: {new_metrics['latency_p50'] - baseline_metrics['latency_p50']:.1f}ms")
```

### Phase 4: Decision Record

Document the decision using ADR (Architecture Decision Record):

```markdown
# ADR-XXX: Adopt Instructed Retriever for RAG Pipeline

**Status:** Accepted
**Date:** 2026-01-29
**Deciders:** [Engineering team]

## Context

Current RAG pipeline has 65% accuracy on complex queries. Users complain about
irrelevant results when queries are ambiguous or require domain knowledge.

## Decision

We will implement Instructed Retriever pattern from Databricks research (2026),
which uses task instructions and metadata filters to guide retrieval.

## Consequences

**Positive:**
- +70% accuracy on complex queries (per paper's benchmark)
- Better handling of ambiguous queries
- Reuses existing Weaviate infrastructure

**Negative:**
- Requires fine-tuning instruction encoder (~1 week)
- Adds 50ms latency per query
- New dependency: sentence-transformers 3.x

**Neutral:**
- Need to design instruction templates for each use case
- Monitoring dashboard needs new metrics

## Alternatives Considered

1. **Multi-Query RAG**: Generate multiple query variations
   - Rejected: 3x latency increase unacceptable

2. **HyDE (Hypothetical Document Embeddings)**: Generate fake answer, embed it
   - Rejected: Works better for long-form content, not our use case

3. **Self-RAG**: Let model decide when to retrieve
   - Deferred: Too complex, revisit in Q3 if needed

## References

- [Databricks Instructed Retriever](https://venturebeat.com/data/databricks-instructed-retriever)
- [Internal POC Results](link-to-internal-doc)
- [Benchmark Dataset](link-to-dataset)
```

## 2026 Techniques to Consider

Based on latest research, here are high-impact techniques:

### Multi-Agent Orchestration

| Framework | Best For | Maturity |
|-----------|----------|----------|
| **LangGraph** | Complex stateful workflows, max control | Production-ready |
| **CrewAI** | Role-based team collaboration, fast setup | Production-ready |
| **AutoGen** | Conversational agents, human-in-the-loop | Research/Early prod |

**Key Pattern: Plan-and-Execute**
- Reduces token usage by 90%
- Use small model for planning, large model for execution
- Example: GPT-4o for planning, GPT-4o-mini for tasks

### RAG Improvements

| Technique | Use Case | Complexity |
|-----------|----------|------------|
| **Instructed Retriever** | Complex queries with metadata | Medium |
| **Hybrid Search** | Exact term + semantic matching | Low |
| **Multi-Modal RAG** | Images + text retrieval | High |
| **Late Interaction (ColBERT)** | Precise ranking after retrieval | Medium |
| **Self-RAG** | Adaptive retrieval decisions | High |

**Chunk Size Recommendation (2026):**
- 512 tokens generally optimal
- Use ANN (Approximate Nearest Neighbor) over KNN for speed

### Prompt Engineering

| Technique | Improvement | When to Use |
|-----------|-------------|-------------|
| **Tree of Thoughts** | Multiple reasoning paths explored | Complex decisions |
| **Self-Consistency** | Generate multiple answers, vote | Reasoning tasks |
| **Multimodal CoT** | Reasoning across text/image/audio | Multimodal inputs |
| **Reflexion** | Model critiques and refines output | Iterative refinement |

### Observability (CRITICAL for Production)

**2026 Standard: OpenTelemetry GenAI Semantic Conventions**

```python
# Instrument LLM calls with OpenTelemetry
from opentelemetry import trace
from opentelemetry.instrumentation.openai import OpenAIInstrumentor

# Auto-instrument all OpenAI calls
OpenAIInstrumentor().instrument()

tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("rag_pipeline") as span:
    span.set_attribute("gen_ai.request.model", "gpt-4o")
    span.set_attribute("gen_ai.operation.name", "retrieve_and_generate")

    # Your RAG code here
    results = retriever.retrieve(query)
    response = generator.generate(results, query)

    span.set_attribute("gen_ai.usage.input_tokens", response.usage.input_tokens)
    span.set_attribute("gen_ai.usage.output_tokens", response.usage.output_tokens)
```

**Supported Platforms (2026):**
- Datadog LLM Observability
- Langfuse
- Grafana + Prometheus
- Custom (export to any OTel backend)

## Citation Management

Track all papers and techniques used:

```markdown
## References

### Papers Implemented

1. **Instructed Retriever with Metadata**
   - Authors: Databricks Research Team
   - Year: 2026
   - Link: https://venturebeat.com/data/databricks-instructed-retriever
   - Implemented in: `src/retrieval/instructed_retriever.py`
   - ADR: ADR-042

2. **Tree of Thoughts Prompting**
   - Authors: Yao et al.
   - Year: 2023
   - Link: https://arxiv.org/abs/2305.10601
   - Implemented in: `src/agents/planner.py`
   - ADR: ADR-038

### Frameworks Used

- LangGraph 0.2.x - Multi-agent orchestration
- Weaviate 1.28.x - Vector database with hybrid search
- OpenTelemetry 1.37+ - GenAI observability

### Blogs & Case Studies

- [RAG in 2026: Practical Blueprint](https://dev.to/suraj_khaitan_f893c243958/-rag-in-2026-a-practical-blueprint-for-retrieval-augmented-generation-16pp)
- [AI Agent Orchestration Patterns](https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns)
```

## Output Format

When using this skill, provide:

1. **Research Summary**
   - Papers reviewed
   - Top 3 candidates with scores
   - Recommendation with justification

2. **Integration Plan**
   - POC implementation (code)
   - Benchmarking strategy
   - Rollout plan (phased/A-B test)

3. **Decision Record**
   - ADR document
   - Risk assessment
   - Alternatives considered

4. **References**
   - All papers cited
   - Implementation code links
   - Related ADRs

## Example Usage

```markdown
User: "Research latest techniques to improve our RAG accuracy. Current system
has 65% accuracy on complex queries."