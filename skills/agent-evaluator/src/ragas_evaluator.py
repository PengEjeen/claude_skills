# RAGAS Metrics Implementation
# Complete evaluation framework for RAG systems

from typing import List, Dict, Any, Optional
from dataclasses import dataclass
import numpy as np
from sentence_transformers import SentenceTransformer
import json


@dataclass
class EvaluationResult:
    """Evaluation result for a single query"""
    query: str
    response: str
    retrieved_contexts: List[str]
    ground_truth: str

    # Metrics
    context_precision: float
    context_recall: float
    faithfulness: float
    answer_relevancy: float

    # Performance
    response_time: float
    cost: float

    # Metadata
    error: Optional[str] = None


class RAGASEvaluator:
    """
    RAGAS (Retrieval Augmented Generation Assessment) Evaluator

    Implements 4 core metrics:
    1. Context Precision: Retrieval accuracy
    2. Context Recall: Retrieval completeness
    3. Faithfulness: Grounding to retrieved context
    4. Answer Relevancy: Answer quality
    """

    def __init__(self, embedding_model: str = "BAAI/bge-large-en-v1.5"):
        self.embedder = SentenceTransformer(embedding_model)

    def evaluate(
        self,
        query: str,
        response: str,
        retrieved_contexts: List[str],
        ground_truth: str,
        response_time: float = 0.0,
        cost: float = 0.0
    ) -> EvaluationResult:
        """
        Evaluate a single RAG query-response pair

        Args:
            query: User query
            response: Generated response
            retrieved_contexts: List of retrieved context chunks
            ground_truth: Expected correct answer
            response_time: Response time in seconds
            cost: API cost in dollars

        Returns:
            EvaluationResult with all metrics
        """
        try:
            # Calculate metrics
            context_precision = self._calculate_context_precision(
                query, retrieved_contexts, ground_truth
            )

            context_recall = self._calculate_context_recall(
                retrieved_contexts, ground_truth
            )

            faithfulness = self._calculate_faithfulness(
                response, retrieved_contexts
            )

            answer_relevancy = self._calculate_answer_relevancy(
                query, response
            )

            return EvaluationResult(
                query=query,
                response=response,
                retrieved_contexts=retrieved_contexts,
                ground_truth=ground_truth,
                context_precision=context_precision,
                context_recall=context_recall,
                faithfulness=faithfulness,
                answer_relevancy=answer_relevancy,
                response_time=response_time,
                cost=cost
            )

        except Exception as e:
            return EvaluationResult(
                query=query,
                response=response,
                retrieved_contexts=retrieved_contexts,
                ground_truth=ground_truth,
                context_precision=0.0,
                context_recall=0.0,
                faithfulness=0.0,
                answer_relevancy=0.0,
                response_time=response_time,
                cost=cost,
                error=str(e)
            )

    def _calculate_context_precision(
        self,
        query: str,
        contexts: List[str],
        ground_truth: str
    ) -> float:
        """
        Context Precision: Proportion of retrieved contexts that are relevant

        Formula: (# relevant contexts) / (# retrieved contexts)
        """
        if not contexts:
            return 0.0

        # Embed query and contexts
        query_emb = self.embedder.encode(query)
        gt_emb = self.embedder.encode(ground_truth)
        context_embs = self.embedder.encode(contexts)

        # Calculate relevance scores
        relevant_count = 0

        for ctx_emb in context_embs:
            # Cosine similarity with query
            query_sim = np.dot(query_emb, ctx_emb) / (
                np.linalg.norm(query_emb) * np.linalg.norm(ctx_emb)
            )

            # Cosine similarity with ground truth
            gt_sim = np.dot(gt_emb, ctx_emb) / (
                np.linalg.norm(gt_emb) * np.linalg.norm(ctx_emb)
            )

            # Relevant if similarity is high enough
            if query_sim > 0.5 or gt_sim > 0.6:
                relevant_count += 1

        return relevant_count / len(contexts)

    def _calculate_context_recall(
        self,
        contexts: List[str],
        ground_truth: str
    ) -> float:
        """
        Context Recall: Proportion of ground truth covered by retrieved contexts

        Measures: How much of the correct answer can be found in retrieved contexts?
        """
        if not contexts:
            return 0.0

        # Embed ground truth and contexts
        gt_emb = self.embedder.encode(ground_truth)
        context_embs = self.embedder.encode(contexts)

        # Find max similarity with any context
        max_similarity = max(
            np.dot(gt_emb, ctx_emb) / (
                np.linalg.norm(gt_emb) * np.linalg.norm(ctx_emb)
            )
            for ctx_emb in context_embs
        )

        return float(max_similarity)

    def _calculate_faithfulness(
        self,
        response: str,
        contexts: List[str]
    ) -> float:
        """
        Faithfulness: Degree to which response is grounded in retrieved contexts

        Measures: Does the answer come from the contexts or is it hallucinated?
        """
        if not contexts:
            return 0.0

        # Split response into sentences
        sentences = self._split_sentences(response)

        if not sentences:
            return 0.0

        # Check each sentence against contexts
        grounded_count = 0

        for sentence in sentences:
            if self._is_grounded(sentence, contexts):
                grounded_count += 1

        return grounded_count / len(sentences)

    def _calculate_answer_relevancy(
        self,
        query: str,
        response: str
    ) -> float:
        """
        Answer Relevancy: How relevant is the response to the query?

        Measures: Does the answer address the question?
        """
        # Embed query and response
        query_emb = self.embedder.encode(query)
        response_emb = self.embedder.encode(response)

        # Cosine similarity
        similarity = np.dot(query_emb, response_emb) / (
            np.linalg.norm(query_emb) * np.linalg.norm(response_emb)
        )

        return float(similarity)

    def _split_sentences(self, text: str) -> List[str]:
        """Simple sentence splitter"""
        import re

        # Split by period, question mark, exclamation
        sentences = re.split(r'[.!?]+', text)

        # Clean and filter
        sentences = [s.strip() for s in sentences if s.strip()]

        return sentences

    def _is_grounded(self, sentence: str, contexts: List[str]) -> bool:
        """Check if sentence is grounded in any context"""
        # Embed sentence
        sent_emb = self.embedder.encode(sentence)

        # Check against all contexts
        for context in contexts:
            ctx_emb = self.embedder.encode(context)

            similarity = np.dot(sent_emb, ctx_emb) / (
                np.linalg.norm(sent_emb) * np.linalg.norm(ctx_emb)
            )

            # Threshold for grounding
            if similarity > 0.7:
                return True

        return False

    def batch_evaluate(
        self,
        test_cases: List[Dict[str, Any]]
    ) -> List[EvaluationResult]:
        """
        Evaluate multiple test cases

        Args:
            test_cases: List of dicts with keys:
                - query: str
                - response: str
                - retrieved_contexts: List[str]
                - ground_truth: str
                - response_time: float (optional)
                - cost: float (optional)

        Returns:
            List of EvaluationResult
        """
        results = []

        for test_case in test_cases:
            result = self.evaluate(
                query=test_case['query'],
                response=test_case['response'],
                retrieved_contexts=test_case['retrieved_contexts'],
                ground_truth=test_case['ground_truth'],
                response_time=test_case.get('response_time', 0.0),
                cost=test_case.get('cost', 0.0)
            )
            results.append(result)

        return results

    def generate_report(self, results: List[EvaluationResult]) -> Dict[str, Any]:
        """
        Generate comprehensive evaluation report

        Returns:
            Report dict with aggregate metrics
        """
        if not results:
            return {'error': 'No results to report'}

        # Filter out errors
        valid_results = [r for r in results if r.error is None]

        if not valid_results:
            return {'error': 'All evaluations failed'}

        # Calculate aggregate metrics
        report = {
            'total_queries': len(results),
            'successful_queries': len(valid_results),
            'error_rate': 1.0 - len(valid_results) / len(results),

            'metrics': {
                'context_precision': {
                    'mean': np.mean([r.context_precision for r in valid_results]),
                    'std': np.std([r.context_precision for r in valid_results]),
                    'min': np.min([r.context_precision for r in valid_results]),
                    'max': np.max([r.context_precision for r in valid_results])
                },
                'context_recall': {
                    'mean': np.mean([r.context_recall for r in valid_results]),
                    'std': np.std([r.context_recall for r in valid_results]),
                    'min': np.min([r.context_recall for r in valid_results]),
                    'max': np.max([r.context_recall for r in valid_results])
                },
                'faithfulness': {
                    'mean': np.mean([r.faithfulness for r in valid_results]),
                    'std': np.std([r.faithfulness for r in valid_results]),
                    'min': np.min([r.faithfulness for r in valid_results]),
                    'max': np.max([r.faithfulness for r in valid_results])
                },
                'answer_relevancy': {
                    'mean': np.mean([r.answer_relevancy for r in valid_results]),
                    'std': np.std([r.answer_relevancy for r in valid_results]),
                    'min': np.min([r.answer_relevancy for r in valid_results]),
                    'max': np.max([r.answer_relevancy for r in valid_results])
                }
            },

            'performance': {
                'avg_response_time': np.mean([r.response_time for r in valid_results]),
                'p50_response_time': np.percentile([r.response_time for r in valid_results], 50),
                'p95_response_time': np.percentile([r.response_time for r in valid_results], 95),
                'avg_cost': np.mean([r.cost for r in valid_results]),
                'total_cost': np.sum([r.cost for r in valid_results])
            },

            'errors': [
                {'query': r.query, 'error': r.error}
                for r in results if r.error is not None
            ]
        }

        # Calculate overall score
        report['overall_score'] = (
            report['metrics']['context_precision']['mean'] * 0.2 +
            report['metrics']['context_recall']['mean'] * 0.2 +
            report['metrics']['faithfulness']['mean'] * 0.3 +
            report['metrics']['answer_relevancy']['mean'] * 0.3
        ) * 100

        return report


# Example usage
if __name__ == "__main__":
    evaluator = RAGASEvaluator()

    # Example test case
    test_cases = [
        {
            'query': '2026년 종합소득세 최고 세율은?',
            'response': '2026년 종합소득세 최고 세율은 45%입니다. 과세표준 10억원을 초과하는 구간에 적용됩니다.',
            'retrieved_contexts': [
                '종합소득세율: 6~45%의 누진세율 적용. 10억원 초과 45%',
                '2026년 세법 개정으로 최고 세율 구간 조정'
            ],
            'ground_truth': '45% (과세표준 10억원 초과)',
            'response_time': 2.3,
            'cost': 0.018
        }
    ]

    results = evaluator.batch_evaluate(test_cases)
    report = evaluator.generate_report(results)

    print(json.dumps(report, indent=2, ensure_ascii=False))
