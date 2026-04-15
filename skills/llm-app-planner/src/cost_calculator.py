#!/usr/bin/env python3
# LLM Cost Calculator for App Planning

from typing import Dict, Tuple
from dataclasses import dataclass


@dataclass
class UsageEstimate:
    """LLM usage estimate"""
    queries_per_month: int
    avg_input_tokens: int
    avg_output_tokens: int


@dataclass
class CostBreakdown:
    """Cost breakdown"""
    model: str
    monthly_cost: float
    cost_per_query: float
    input_cost: float
    output_cost: float


class LLMCostCalculator:
    """
    Calculate LLM API costs for different use cases

    Pricing as of 2026-01-29 (USD per 1M tokens)
    """

    PRICING = {
        # OpenAI
        'gpt-4o': {
            'input': 2.50,
            'output': 10.00,
            'context_window': 128000
        },
        'gpt-4o-mini': {
            'input': 0.15,
            'output': 0.60,
            'context_window': 128000
        },
        'gpt-3.5-turbo': {
            'input': 0.50,
            'output': 1.50,
            'context_window': 16000
        },

        # Anthropic
        'claude-opus-4-5': {
            'input': 15.00,
            'output': 75.00,
            'context_window': 200000
        },
        'claude-sonnet-4-5': {
            'input': 3.00,
            'output': 15.00,
            'context_window': 200000
        },
        'claude-haiku-4': {
            'input': 0.25,
            'output': 1.25,
            'context_window': 200000
        },

        # Google
        'gemini-2.0-flash': {
            'input': 0.10,
            'output': 0.40,
            'context_window': 1000000
        },
        'gemini-1.5-pro': {
            'input': 1.25,
            'output': 5.00,
            'context_window': 2000000
        }
    }

    def calculate_cost(
        self,
        model: str,
        usage: UsageEstimate
    ) -> CostBreakdown:
        """
        Calculate monthly cost for given usage

        Args:
            model: Model name (e.g., 'gpt-4o', 'claude-sonnet-4-5')
            usage: Usage estimate

        Returns:
            Cost breakdown

        Raises:
            ValueError: If model is unknown or usage values are invalid
        """
        if model not in self.PRICING:
            raise ValueError(f"Unknown model: {model}")

        # Input validation
        if usage.queries_per_month <= 0:
            raise ValueError(f"queries_per_month must be positive, got {usage.queries_per_month}")
        if usage.avg_input_tokens < 0:
            raise ValueError(f"avg_input_tokens cannot be negative, got {usage.avg_input_tokens}")
        if usage.avg_output_tokens < 0:
            raise ValueError(f"avg_output_tokens cannot be negative, got {usage.avg_output_tokens}")

        pricing = self.PRICING[model]

        # Calculate token costs
        total_input_tokens = usage.queries_per_month * usage.avg_input_tokens
        total_output_tokens = usage.queries_per_month * usage.avg_output_tokens

        input_cost = (total_input_tokens / 1_000_000) * pricing['input']
        output_cost = (total_output_tokens / 1_000_000) * pricing['output']

        monthly_cost = input_cost + output_cost
        cost_per_query = monthly_cost / usage.queries_per_month

        return CostBreakdown(
            model=model,
            monthly_cost=monthly_cost,
            cost_per_query=cost_per_query,
            input_cost=input_cost,
            output_cost=output_cost
        )

    def compare_models(
        self,
        usage: UsageEstimate,
        models: list = None
    ) -> Dict[str, CostBreakdown]:
        """
        Compare costs across multiple models

        Args:
            usage: Usage estimate
            models: List of model names (default: all)

        Returns:
            Dict of model -> cost breakdown
        """
        if models is None:
            models = list(self.PRICING.keys())

        results = {}
        for model in models:
            results[model] = self.calculate_cost(model, usage)

        return results

    def optimize_for_budget(
        self,
        budget: float,
        usage: UsageEstimate
    ) -> Tuple[str, CostBreakdown]:
        """
        Find best model within budget

        Args:
            budget: Monthly budget (USD)
            usage: Usage estimate

        Returns:
            (model_name, cost_breakdown)
        """
        all_costs = self.compare_models(usage)

        # Filter models within budget
        within_budget = {
            model: cost
            for model, cost in all_costs.items()
            if cost.monthly_cost <= budget
        }

        if not within_budget:
            cheapest = min(all_costs.items(), key=lambda x: x[1].monthly_cost)
            raise ValueError(
                f"No model within budget ${budget:.2f}. "
                f"Cheapest option: {cheapest[0]} at ${cheapest[1].monthly_cost:.2f}/month. "
                f"You need at least ${cheapest[1].monthly_cost - budget:.2f} more."
            )

        # Select most powerful model within budget
        # Heuristic: Higher pricing = more powerful
        best_model = max(
            within_budget.items(),
            key=lambda x: self.PRICING[x[0]]['input'] + self.PRICING[x[0]]['output']
        )

        return best_model

    def estimate_rag_cost(
        self,
        queries_per_month: int,
        avg_retrieved_docs: int = 5,
        doc_length: int = 500,
        response_length: int = 300
    ) -> Dict[str, CostBreakdown]:
        """
        Estimate RAG system cost

        Args:
            queries_per_month: Number of queries
            avg_retrieved_docs: Average number of retrieved documents
            doc_length: Average document length (tokens)
            response_length: Average response length (tokens)

        Returns:
            Cost breakdown for different models
        """
        # Calculate input tokens:
        # System prompt (300) + Query (50) + Retrieved docs (5 × 500) = 2,850
        system_prompt = 300
        query = 50
        context = avg_retrieved_docs * doc_length

        avg_input_tokens = system_prompt + query + context
        avg_output_tokens = response_length

        usage = UsageEstimate(
            queries_per_month=queries_per_month,
            avg_input_tokens=avg_input_tokens,
            avg_output_tokens=avg_output_tokens
        )

        return self.compare_models(usage)

    def estimate_agent_cost(
        self,
        tasks_per_month: int,
        avg_tool_calls: int = 3,
        planner_tokens: int = 1000,
        executor_tokens_per_tool: int = 500,
        aggregator_tokens: int = 800
    ) -> float:
        """
        Estimate multi-agent system cost

        Assumes:
        - Planner: GPT-4o (1000 input + 200 output)
        - Executor: Haiku (500 input + 100 output per tool)
        - Aggregator: Sonnet (800 input + 400 output)

        Returns:
            Monthly cost (USD)
        """
        # Planner cost
        planner_usage = UsageEstimate(
            queries_per_month=tasks_per_month,
            avg_input_tokens=planner_tokens,
            avg_output_tokens=200
        )
        planner_cost = self.calculate_cost('gpt-4o', planner_usage).monthly_cost

        # Executor cost (per tool call)
        executor_usage = UsageEstimate(
            queries_per_month=tasks_per_month * avg_tool_calls,
            avg_input_tokens=executor_tokens_per_tool,
            avg_output_tokens=100
        )
        executor_cost = self.calculate_cost('claude-haiku-4', executor_usage).monthly_cost

        # Aggregator cost
        aggregator_usage = UsageEstimate(
            queries_per_month=tasks_per_month,
            avg_input_tokens=aggregator_tokens,
            avg_output_tokens=400
        )
        aggregator_cost = self.calculate_cost('claude-sonnet-4-5', aggregator_usage).monthly_cost

        total_cost = planner_cost + executor_cost + aggregator_cost

        return total_cost

    def generate_report(
        self,
        use_case: str,
        costs: Dict[str, CostBreakdown]
    ) -> str:
        """
        Generate cost analysis report

        Args:
            use_case: Description of use case
            costs: Cost breakdowns for different models

        Returns:
            Markdown report
        """
        # Sort by cost (ascending)
        sorted_costs = sorted(costs.items(), key=lambda x: x[1].monthly_cost)

        report = f"""# LLM Cost Analysis: {use_case}

## Cost Comparison

| Model | Monthly Cost | Cost/Query | Input Cost | Output Cost |
|-------|--------------|------------|------------|-------------|
"""

        for model, cost in sorted_costs:
            report += f"| {model} | ${cost.monthly_cost:.2f} | ${cost.cost_per_query:.4f} | ${cost.input_cost:.2f} | ${cost.output_cost:.2f} |\n"

        # Recommendations
        cheapest = sorted_costs[0]
        most_expensive = sorted_costs[-1]

        savings = most_expensive[1].monthly_cost - cheapest[1].monthly_cost
        savings_pct = (savings / most_expensive[1].monthly_cost) * 100

        report += f"""
---

## Recommendations

### Most Cost-Effective
**{cheapest[0]}** - ${cheapest[1].monthly_cost:.2f}/month
- Best for: High volume, budget-conscious applications
- Trade-off: May have lower quality than premium models

### Premium Option
**{most_expensive[0]}** - ${most_expensive[1].monthly_cost:.2f}/month
- Best for: High-stakes applications, complex reasoning
- Trade-off: {savings_pct:.0f}% more expensive (${savings:.2f}/month)

### Balanced Approach
Consider a **hybrid strategy**:
1. Use {cheapest[0]} for simple queries (70% of traffic)
2. Use {most_expensive[0]} for complex queries (30% of traffic)
3. **Estimated savings:** {savings_pct * 0.7:.0f}% ({savings * 0.7:.2f} USD/month)

---

## Cost Optimization Tips

1. **Prompt Caching** (Beta)
   - Cache system prompts and common context
   - Reduce input tokens by up to 90%
   - Estimated savings: ${cheapest[1].input_cost * 0.9:.2f}/month

2. **Streaming Responses**
   - Reduce perceived latency
   - Stop generation early if user is satisfied
   - Potential savings: 10-20% on output tokens

3. **Batch Processing**
   - Process multiple queries in one API call
   - Reduce overhead
   - Some providers offer batch discounts

4. **Model Routing**
   - Route simple queries to cheaper models
   - Use classification to determine complexity
   - Estimated savings: 30-50%

---

*Report generated on {__import__('datetime').datetime.now().strftime("%Y-%m-%d %H:%M")}*
"""

        return report


# CLI usage
if __name__ == "__main__":
    import sys

    calculator = LLMCostCalculator()

    # Example: RAG system
    print("=" * 60)
    print("RAG System Cost Estimate")
    print("=" * 60)

    rag_costs = calculator.estimate_rag_cost(
        queries_per_month=10_000,
        avg_retrieved_docs=5,
        doc_length=500,
        response_length=300
    )

    report = calculator.generate_report("RAG Q&A System (10K queries/month)", rag_costs)
    print(report)

    # Example: Agent system
    print("\n" + "=" * 60)
    print("Multi-Agent System Cost Estimate")
    print("=" * 60)

    agent_cost = calculator.estimate_agent_cost(
        tasks_per_month=1_000,
        avg_tool_calls=3
    )

    print(f"Estimated monthly cost: ${agent_cost:.2f}")
    print(f"Cost per task: ${agent_cost / 1000:.4f}")

    # Optimization recommendation
    print("\n" + "=" * 60)
    print("Budget Optimization")
    print("=" * 60)

    usage = UsageEstimate(
        queries_per_month=10_000,
        avg_input_tokens=3000,
        avg_output_tokens=300
    )

    budget = 500.0  # $500/month

    try:
        best_model, cost = calculator.optimize_for_budget(budget, usage)
        print(f"Best model within ${budget} budget: {best_model[0]}")
        print(f"Estimated cost: ${cost.monthly_cost:.2f}/month")
        print(f"Remaining budget: ${budget - cost.monthly_cost:.2f}")
    except ValueError as e:
        print(f"Error: {e}")
