# /token-analysis Command

Analyze token usage and get optimization recommendations.

## Usage

```
/token-analysis [scope]
```

## Scopes

### conversation (default)

Analyze current conversation:
```
/token-analysis conversation
```

**Output**:
```markdown
## Token Analysis: Current Conversation

### Usage Summary
| Metric | Value |
|--------|-------|
| Total Tokens | 45,230 |
| Context Used | 22.6% (of 200K) |
| Input Tokens | 38,500 |
| Output Tokens | 6,730 |

### Breakdown by Type
| Type | Tokens | % |
|------|--------|---|
| Code | 28,000 | 62% |
| Conversation | 12,000 | 27% |
| Tool Results | 5,230 | 11% |

### Status: ✅ Healthy
Context usage is low. No optimization needed.
```

### session

Analyze full session including agents:
```
/token-analysis session
```

**Output**:
```markdown
## Token Analysis: Session

### Total Usage
- Main Conversation: 45,230 tokens
- Sub-agents: 23,450 tokens
- **Total**: 68,680 tokens

### Agent Breakdown
| Agent | Input | Output | Total |
|-------|-------|--------|-------|
| code-reviewer | 8,200 | 2,100 | 10,300 |
| tdd-guide | 6,500 | 3,200 | 9,700 |
| planner | 2,100 | 1,350 | 3,450 |

### Model Distribution
| Model | Tokens | Est. Cost |
|-------|--------|-----------|
| Sonnet | 52,000 | $0.94 |
| Haiku | 16,680 | $0.02 |

### Recommendations
1. ✅ Good use of Haiku for simple tasks
2. ⚠️ code-reviewer used Sonnet - consider Haiku
```

### file

Analyze token cost of a specific file:
```
/token-analysis file:src/services/UserService.ts
```

**Output**:
```markdown
## Token Analysis: UserService.ts

### File Stats
| Metric | Value |
|--------|-------|
| Lines | 342 |
| Characters | 12,450 |
| Estimated Tokens | 3,200 |

### Impact Analysis
- Reading once: 3,200 tokens
- Full context inclusion: 3,200 tokens
- Skeleton only: ~400 tokens (88% savings)

### Compression Options
| Method | Tokens | Savings |
|--------|--------|---------|
| Full file | 3,200 | - |
| Skeleton | 400 | 88% |
| Key methods only | 800 | 75% |
| Imports + exports | 200 | 94% |

### Recommendation
For reference purposes, use skeleton extraction.
For active editing, include full file.
```

### estimate

Estimate tokens for planned operation:
```
/token-analysis estimate "review all files in src/services/"
```

**Output**:
```markdown
## Token Estimate: Review src/services/

### Files to Process
| File | Lines | Est. Tokens |
|------|-------|-------------|
| UserService.ts | 342 | 3,200 |
| OrderService.ts | 456 | 4,100 |
| AuthService.ts | 289 | 2,700 |
| ... (5 more) | 1,234 | 11,500 |

### Total Estimate
- Input: ~21,500 tokens
- Expected Output: ~5,000 tokens
- **Total**: ~26,500 tokens

### Context Impact
- Current usage: 45,230 (22.6%)
- After operation: 71,730 (35.9%)
- Status: ✅ Safe to proceed

### Cost Estimate
- Sonnet: $0.72
- Haiku (alternative): $0.08
```

## Optimization Recommendations

Based on analysis, get specific recommendations:

### High Context Usage (>60%)
```markdown
⚠️ Context at 65% - Consider:
1. Summarize older conversation
2. Use skeleton references for read files
3. Clear unused tool results
```

### High Cost
```markdown
💰 Session cost: $5.20 - Consider:
1. Switch simple tasks to Haiku
2. Use cached file references
3. Batch similar operations
```

### Inefficient Patterns
```markdown
📊 Inefficiency detected:
- Same file read 4 times → Use references
- Large tool outputs → Filter/summarize
- Verbose prompts → Use shorthand
```

## Output Format Options

### --json
```
/token-analysis conversation --json
```

Returns JSON for programmatic use:
```json
{
  "total_tokens": 45230,
  "context_percentage": 22.6,
  "breakdown": {
    "code": 28000,
    "conversation": 12000,
    "tool_results": 5230
  },
  "recommendations": []
}
```

### --brief
```
/token-analysis --brief
```

One-line summary:
```
Tokens: 45,230 (22.6%) | Status: ✅ | Cost: $0.94
```

## Alerts

Automatic warnings when:
- Context > 60%: Yellow warning
- Context > 80%: Red warning with action items
- Single file > 10K tokens: Compression suggestion
- Repeated file reads: Reference suggestion
