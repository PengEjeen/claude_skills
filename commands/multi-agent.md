# /multi-agent Command

Launch multi-agent workflows with specified patterns.

## Usage

```
/multi-agent <pattern> [options]
```

## Patterns

### debate

Two agents argue opposing positions, then synthesize:

```
/multi-agent debate "Should we use microservices for this project?"
```

**Process**:
1. Pro Agent: Arguments in favor
2. Con Agent: Arguments against
3. Synthesis: Balanced conclusion with recommendation

**Output**:
```markdown
## Debate: Microservices Architecture

### Pro Arguments
1. Independent scaling of services
2. Technology flexibility per service
3. Fault isolation

### Con Arguments
1. Operational complexity
2. Network latency overhead
3. Distributed debugging difficulty

### Synthesis
For a team of 5 with moderate traffic, recommend starting monolithic
with clear module boundaries. Migrate to microservices when scaling
demands exceed single-service capacity.
```

### ensemble

Multiple specialist agents analyze the same problem:

```
/multi-agent ensemble "Review auth module security"
```

**Process**:
1. Security Agent: Vulnerability analysis
2. Performance Agent: Efficiency review
3. Code Quality Agent: Maintainability check
4. Aggregation: Combined findings

**Output**:
```markdown
## Ensemble Analysis: Auth Module

### Security Agent Findings
- [HIGH] JWT secret in code → Move to env
- [MEDIUM] No rate limiting → Add throttle

### Performance Agent Findings
- Token validation on every request (acceptable)
- Consider caching validated tokens

### Code Quality Findings
- Good separation of concerns
- Missing error type definitions

### Aggregated Recommendations
1. [CRITICAL] Move JWT secret to environment
2. [HIGH] Add rate limiting
3. [MEDIUM] Add token cache
4. [LOW] Define error types
```

### tree-of-thoughts

Explore multiple solution paths for complex problems:

```
/multi-agent tree-of-thoughts "Optimize database query taking 10s"
```

**Process**:
1. Generate 3-5 solution branches
2. Evaluate each branch (pros, cons, effort, impact)
3. Prune low-scoring branches
4. Deep-dive on best branch

**Output**:
```markdown
## Tree of Thoughts: Query Optimization

### Branches Explored
| Branch | Description | Score |
|--------|-------------|-------|
| Index | Add composite index | 8.5/10 |
| Cache | Redis query cache | 7.0/10 |
| Rewrite | Restructure query | 6.5/10 |
| Denorm | Denormalize table | 5.0/10 |

### Selected: Index Optimization
**Implementation**:
CREATE INDEX idx_user_orders ON orders(user_id, status, created_at);

**Expected Result**: 10s → 0.2s
**Risk**: Low (non-breaking change)
```

### critic

Self-critique and iterative refinement:

```
/multi-agent critic "Review and improve this function: [code]"
```

**Process**:
1. Initial analysis
2. Identify weaknesses (correctness, performance, security, readability)
3. Generate improved version
4. Verify improvements

**Output**:
```markdown
## CRITIC Analysis

### Initial Assessment
Function works but has issues with error handling and edge cases.

### Critiques
- [C1] No null check on input
- [C2] Synchronous file read blocks event loop
- [C3] Magic number 1000 not explained

### Refined Version
[Improved code with issues addressed]

### Verification
- C1: ✓ Added input validation
- C2: ✓ Changed to async/await
- C3: ✓ Extracted to named constant
```

## Options

### --parallel

Run analysis agents in parallel (default: true):
```
/multi-agent ensemble "Review API" --parallel
```

### --depth

Set exploration depth for tree-of-thoughts:
```
/multi-agent tree-of-thoughts "..." --depth 3
```

### --iterations

Set iteration count for critic pattern:
```
/multi-agent critic "..." --iterations 5
```

### --model

Specify model for agents:
```
/multi-agent debate "..." --model opus
```

## Examples

### Architecture Decision
```
/multi-agent debate "REST vs GraphQL for our API"
```

### Comprehensive Code Review
```
/multi-agent ensemble "Review src/services/"
```

### Complex Problem Solving
```
/multi-agent tree-of-thoughts "Reduce memory usage by 50%"
```

### Code Improvement
```
/multi-agent critic "Improve error handling in UserService"
```

## Integration

Multi-agent patterns can be combined:
```
/multi-agent tree-of-thoughts "..." | /multi-agent critic
```

First explores options, then critiques the selected approach.
