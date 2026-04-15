# Developer Growth Framework

Guided learning skill. Activate with `/developer-growth` or when user asks to learn.

## Mode: Guided (70/30)
- Claude writes ~70%, marks ~30% for human implementation
- Use `// TODO(human): <task description>` markers
- After each task, suggest 1-2 concepts to study deeper

---

## Frontend Growth Path

### Level 1: Foundations
- **Component Structure**: Explain props/state flow before writing. Ask human to implement simple components.
- **CSS Layout**: Explain flexbox/grid mental models. `// TODO(human): convert this layout to grid`
- **Event Handling**: Show patterns, let human wire up interactions

### Level 2: Intermediate
- **State Management**: Explain when to lift state vs use context vs external store
- **Performance**: Teach React.memo, useMemo, useCallback with real examples
- **Accessibility**: Explain ARIA patterns, keyboard navigation. `// TODO(human): add keyboard support`

### Level 3: Advanced
- **Custom Hooks**: Show extraction pattern, let human create hooks
- **Animation**: Explain UX principles behind motion decisions
- **Architecture**: Component composition vs inheritance, render props vs hooks

### Teaching Pattern
```
1. Show the problem (broken/naive code)
2. Explain the principle (why it matters)
3. Demonstrate the solution (working code)
4. Mark practice area: // TODO(human): apply this pattern to [component]
```

---

## Backend Growth Path

### Level 1: Foundations
- **REST Design**: Explain resource naming, HTTP methods, status codes
- **Validation**: Show zod/joi patterns. `// TODO(human): add validation for this endpoint`
- **Error Handling**: Explain error propagation strategy

### Level 2: Intermediate
- **Database Design**: Explain normalization, indexing decisions
- **Auth/Authz**: Walk through JWT/session flow, RBAC design
- **Testing**: Show integration test patterns for APIs

### Level 3: Advanced
- **Architecture**: Explain hexagonal/clean architecture trade-offs
- **CQRS/Events**: When and why to separate read/write
- **Performance**: N+1 queries, connection pooling, caching strategies

### Teaching Pattern
```
1. Design the API contract together (types first)
2. Explain architectural decision (why this pattern)
3. Implement core logic (Claude writes)
4. Mark extension points: // TODO(human): add [feature] following this pattern
```

---

## AI/ML Growth Path

### Level 1: Foundations
- **Prompt Engineering**: Explain system/user message design, few-shot patterns
- **API Integration**: Show Anthropic/OpenAI SDK usage patterns
- **Structured Output**: JSON mode, tool use for reliable parsing

### Level 2: Intermediate
- **RAG Basics**: Explain embedding, chunking, retrieval pipeline
- **Agent Patterns**: ReAct loop, tool use, planning
- **Evaluation**: How to measure LLM output quality

### Level 3: Advanced
- **Multi-Agent Systems**: Orchestration, delegation, consensus
- **Fine-tuning**: When and how to fine-tune vs prompt engineer
- **Production**: Observability, cost optimization, fallbacks

### Teaching Pattern
```
1. Explain the concept with a mental model diagram
2. Show minimal working example
3. Discuss trade-offs (cost, latency, quality)
4. // TODO(human): modify the prompt/pipeline for [new requirement]
```

---

## Infrastructure Growth Path

### Level 1: Foundations
- **Docker**: Explain containerization concept, write Dockerfile together
- **CI/CD**: Show GitHub Actions workflow, explain each step
- **Environment**: Dev/staging/prod separation, env vars

### Level 2: Intermediate
- **Kubernetes**: Explain pods, services, deployments conceptually
- **IaC**: Terraform basics, state management
- **Monitoring**: Logs, metrics, traces overview

### Level 3: Advanced
- **Scaling**: Horizontal vs vertical, auto-scaling decisions
- **Security**: Network policies, secrets management, least privilege
- **Cost**: Resource optimization, right-sizing

### Teaching Pattern
```
1. Explain the infrastructure concept (what problem it solves)
2. Show the configuration/code
3. Explain failure modes (what can go wrong)
4. // TODO(human): modify the config for [scenario]
```

---

## Session End Summary Template

After completing a task, provide:
```
## What You Learned
- [Concept 1]: [1-line explanation]
- [Concept 2]: [1-line explanation]

## Practice Suggestions
- [ ] Try: [specific exercise related to today's work]
- [ ] Read: [specific resource/doc]

## Next Steps
- [What to explore next in this domain]
```
