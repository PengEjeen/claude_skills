# ReAct Agent

Reasoning and Acting agent for iterative tool-based problem solving.

## Purpose

Interleave reasoning (thinking) with actions (tool use) to solve complex tasks that require multiple steps of information gathering and execution.

## ReAct Pattern

```
Thought → Action → Observation → Thought → Action → ...
```

## Activation

Use for:
- Multi-step debugging requiring investigation
- Tasks needing information from multiple sources
- Complex refactoring with dependencies
- Problems requiring trial and error

## Process

### Loop Structure
```
[THOUGHT 1]
What do I need to find out? What's my hypothesis?

[ACTION 1]
Tool: [Grep/Read/Bash/etc.]
Input: [specific parameters]

[OBSERVATION 1]
[Tool output summary]

[THOUGHT 2]
Based on observation, what does this tell me?
What should I investigate next?

[ACTION 2]
...

[FINAL THOUGHT]
I now have enough information to [solve/answer/implement].
```

## Action Types

| Action | Tool | Use When |
|--------|------|----------|
| Search | Grep, Glob | Finding patterns, files |
| Read | Read | Understanding code |
| Execute | Bash | Running commands, tests |
| Modify | Edit, Write | Making changes |
| Verify | Bash | Confirming fixes |

## Reasoning Guidelines

### Good Thoughts
- "The error mentions X, so I should look for where X is defined"
- "This import failed, let me check if the module exists"
- "The test passed, but I should verify the edge case"

### Bad Thoughts
- "Let me randomly try something" (no reasoning)
- "This might work" (no investigation)

## Iteration Limits

- **Max iterations**: 10 (prevent infinite loops)
- **Early termination**: When goal is achieved
- **Stuck detection**: 3 similar observations = try different approach

## Output Format

```markdown
## ReAct Trace

### Goal
[What we're trying to achieve]

### Iteration 1
**Thought**: [reasoning about what to do]
**Action**: [tool] - [brief description]
**Observation**: [key findings]

### Iteration 2
**Thought**: [updated reasoning]
**Action**: [tool] - [brief description]
**Observation**: [key findings]

...

### Conclusion
**Solution**: [final answer/fix]
**Confidence**: [HIGH/MEDIUM/LOW]
**Verification**: [how we confirmed it works]
```

## Error Recovery

If stuck:
1. Re-read the original goal
2. List what we've learned
3. Identify what we haven't tried
4. Change approach (different tools, different search terms)

## Example: Debugging

```
[THOUGHT 1]
User reports "undefined is not a function" in UserService.
I should find where UserService is defined.

[ACTION 1]
Tool: Grep
Pattern: "class UserService"

[OBSERVATION 1]
Found in src/services/UserService.ts:15

[THOUGHT 2]
Let me read the class to understand its methods.

[ACTION 2]
Tool: Read
File: src/services/UserService.ts

[OBSERVATION 2]
The getUser method calls this.repository.find()
but repository is initialized in constructor...

[THOUGHT 3]
I should check if repository is properly injected.
Let me find where UserService is instantiated.

...
```

## Integration

- Combine with `debugger` for complex bugs
- Use before `code-reviewer` for investigation
- Chain with `tdd-guide` for test-driven fixes
