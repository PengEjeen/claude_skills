---
name: agentic-workflows
description: 멀티 에이전트 시스템 및 자율 워크플로우를 설계하고 구현합니다. "멀티 에이전트", "워크플로우 자동화", "에이전트 협업", "오케스트레이션", "multi-agent", "agentic workflow", "orchestration" 등의 요청 시 사용합니다. ReAct, Plan-Execute, 멀티에이전트 패턴을 포함합니다.
---

# Agentic Workflows Skill

Design and implement multi-agent systems and autonomous workflows.

## Purpose

Build reliable agentic systems using proven patterns for reasoning, tool use, collaboration, and error recovery.

## Core Patterns

### 1. ReAct (Reasoning + Acting)

Interleave thinking and actions:

```markdown
[THOUGHT] The user wants to find memory leaks. I should first check the heap usage.
[ACTION] Bash: node --expose-gc --inspect app.js
[OBSERVATION] Heap used: 156MB, growing steadily
[THOUGHT] Memory is growing. Let me take a heap snapshot to identify the source.
[ACTION] Bash: node --heapsnapshot app.js
[OBSERVATION] Snapshot saved. Top retainers: EventEmitter (45%), Cache (30%)
[THOUGHT] EventEmitter is the main issue. Let me find where listeners aren't removed.
[ACTION] Grep: pattern="addEventListener|on\(" path="src/"
[OBSERVATION] Found 23 listeners, 18 without corresponding removeEventListener
[CONCLUSION] Memory leak caused by unremoved event listeners. Locations identified.
```

**Implementation**:
```python
class ReActAgent:
    def __init__(self, llm, tools):
        self.llm = llm
        self.tools = tools
        self.max_iterations = 10

    def run(self, goal: str):
        history = []
        for i in range(self.max_iterations):
            # Think
            thought = self.llm.generate(
                f"Goal: {goal}\nHistory: {history}\nWhat should I do next?"
            )

            if "CONCLUSION" in thought:
                return self.extract_conclusion(thought)

            # Act
            action = self.parse_action(thought)
            observation = self.tools.execute(action)

            history.append({
                "thought": thought,
                "action": action,
                "observation": observation
            })

        return {"status": "max_iterations", "history": history}
```

### 2. CRITIC (Self-Critique)

Generate → Critique → Refine:

```markdown
[GENERATION]
def quicksort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[0]
    left = [x for x in arr[1:] if x < pivot]
    right = [x for x in arr[1:] if x >= pivot]
    return quicksort(left) + [pivot] + quicksort(right)

[CRITIQUE]
- Issue 1: Always picks first element as pivot (worst case O(n²) for sorted)
- Issue 2: Creates new lists (O(n) extra space per recursion)
- Issue 3: No handling for equal elements distribution

[REFINEMENT]
def quicksort(arr, low=0, high=None):
    if high is None:
        high = len(arr) - 1
    if low < high:
        # Median-of-three pivot selection
        mid = (low + high) // 2
        pivot_idx = sorted([(arr[low], low), (arr[mid], mid), (arr[high], high)])[1][1]
        arr[pivot_idx], arr[high] = arr[high], arr[pivot_idx]

        # In-place partition
        pivot = arr[high]
        i = low - 1
        for j in range(low, high):
            if arr[j] <= pivot:
                i += 1
                arr[i], arr[j] = arr[j], arr[i]
        arr[i + 1], arr[high] = arr[high], arr[i + 1]

        quicksort(arr, low, i)
        quicksort(arr, i + 2, high)
    return arr

[VERIFICATION]
- Median-of-three prevents worst case
- In-place reduces space complexity
- Equal elements handled correctly
```

### 3. Tree of Thoughts (ToT)

Explore multiple solution paths:

```markdown
[PROBLEM]
Optimize database query taking 5 seconds

[BRANCH 1: Index Optimization]
├── Add composite index on (user_id, created_at)
├── Estimated improvement: 80%
├── Risk: Index maintenance overhead
└── Score: 8/10

[BRANCH 2: Query Rewrite]
├── Replace subquery with JOIN
├── Estimated improvement: 60%
├── Risk: Logic change might affect results
└── Score: 6/10

[BRANCH 3: Caching]
├── Add Redis cache with 5min TTL
├── Estimated improvement: 95% for repeated queries
├── Risk: Cache invalidation complexity
└── Score: 7/10

[EVALUATION]
Branch 1 selected: Best balance of improvement and simplicity

[EXECUTION]
CREATE INDEX idx_user_created ON orders(user_id, created_at);
-- Query time reduced from 5s to 0.3s
```

### 4. Debate (Multi-Perspective)

Agents argue different positions:

```python
class DebateOrchestrator:
    def __init__(self, llm):
        self.llm = llm

    def debate(self, topic: str, rounds: int = 3):
        pro_history = []
        con_history = []

        for round in range(rounds):
            # Pro argument
            pro_arg = self.llm.generate(
                f"Topic: {topic}\n"
                f"Previous arguments: {pro_history + con_history}\n"
                f"Argue IN FAVOR of this approach. Be specific and cite evidence."
            )
            pro_history.append(pro_arg)

            # Con argument
            con_arg = self.llm.generate(
                f"Topic: {topic}\n"
                f"Previous arguments: {pro_history + con_history}\n"
                f"Argue AGAINST this approach. Address the pro arguments."
            )
            con_history.append(con_arg)

        # Synthesize
        synthesis = self.llm.generate(
            f"Topic: {topic}\n"
            f"Pro arguments: {pro_history}\n"
            f"Con arguments: {con_history}\n"
            f"Synthesize a balanced conclusion with recommendations."
        )

        return synthesis
```

### 5. Ensemble

Multiple agents, aggregate results:

```python
class EnsembleAgent:
    def __init__(self, agents: list, aggregator):
        self.agents = agents
        self.aggregator = aggregator

    def execute(self, task: str):
        # Run all agents in parallel
        results = parallel_execute([
            agent.run(task) for agent in self.agents
        ])

        # Aggregate results
        if self.aggregator == "vote":
            return self.majority_vote(results)
        elif self.aggregator == "merge":
            return self.merge_unique(results)
        elif self.aggregator == "best":
            return self.select_best(results)
```

## State Management

### Checkpointing

```python
class StatefulAgent:
    def __init__(self, checkpoint_dir: str):
        self.checkpoint_dir = checkpoint_dir
        self.state = {}

    def save_checkpoint(self, step: int):
        checkpoint = {
            "step": step,
            "state": self.state,
            "timestamp": datetime.now().isoformat()
        }
        path = f"{self.checkpoint_dir}/checkpoint_{step}.json"
        with open(path, 'w') as f:
            json.dump(checkpoint, f)

    def restore_checkpoint(self, step: int = None):
        if step is None:
            # Find latest
            checkpoints = glob(f"{self.checkpoint_dir}/checkpoint_*.json")
            if not checkpoints:
                return False
            path = max(checkpoints)
        else:
            path = f"{self.checkpoint_dir}/checkpoint_{step}.json"

        with open(path) as f:
            checkpoint = json.load(f)
        self.state = checkpoint["state"]
        return True
```

### Persistent Memory

```python
class AgentMemory:
    def __init__(self, db_path: str):
        self.db = sqlite3.connect(db_path)
        self._init_schema()

    def remember(self, key: str, value: any, ttl: int = None):
        expires = datetime.now() + timedelta(seconds=ttl) if ttl else None
        self.db.execute(
            "INSERT OR REPLACE INTO memory (key, value, expires) VALUES (?, ?, ?)",
            (key, json.dumps(value), expires)
        )
        self.db.commit()

    def recall(self, key: str) -> any:
        row = self.db.execute(
            "SELECT value FROM memory WHERE key = ? AND (expires IS NULL OR expires > ?)",
            (key, datetime.now())
        ).fetchone()
        return json.loads(row[0]) if row else None
```

## Error Recovery

### Retry with Backoff

```python
class ResilientAgent:
    def execute_with_retry(self, action, max_retries=3):
        for attempt in range(max_retries):
            try:
                return action()
            except RecoverableError as e:
                wait = 2 ** attempt  # Exponential backoff
                logger.warning(f"Attempt {attempt + 1} failed: {e}. Retrying in {wait}s")
                time.sleep(wait)
            except FatalError as e:
                logger.error(f"Fatal error: {e}")
                raise

        raise MaxRetriesExceeded(f"Failed after {max_retries} attempts")
```

### Fallback Chain

```python
class FallbackAgent:
    def __init__(self, primary, fallbacks: list):
        self.primary = primary
        self.fallbacks = fallbacks

    def execute(self, task):
        try:
            return self.primary.execute(task)
        except Exception as e:
            logger.warning(f"Primary failed: {e}")

        for fallback in self.fallbacks:
            try:
                return fallback.execute(task)
            except Exception as e:
                logger.warning(f"Fallback failed: {e}")
                continue

        raise AllAgentsFailed("No agent could complete the task")
```

## Coordination Patterns

### Sequential Pipeline
```
Agent A → Agent B → Agent C
```

### Parallel Fan-Out
```
       ┌→ Agent A ─┐
Input ─┼→ Agent B ─┼→ Aggregate
       └→ Agent C ─┘
```

### Supervisor
```
Supervisor ─┬─ Worker 1
            ├─ Worker 2
            └─ Worker 3
```

## Quick Reference

```markdown
Patterns:
- ReAct: Think → Act → Observe loop
- CRITIC: Generate → Critique → Refine
- ToT: Branch → Evaluate → Prune → Select
- Debate: Pro vs Con → Synthesis
- Ensemble: Multiple agents → Aggregate

State:
- Checkpoint frequently
- Persistent memory for long-running
- Clear state between tasks

Recovery:
- Retry with exponential backoff
- Fallback chains
- Graceful degradation
```
