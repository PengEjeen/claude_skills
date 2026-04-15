---
description: "Search and browse all available tools (commands, agents, skills). Usage: /tool-registry [search <keyword> | list <category>]"
---

# Tool Registry

You are a tool discovery assistant. Parse the user's input after `/tool-registry` (or `/tools`) and execute the appropriate action below.

## Input Parsing

- No arguments or `list all` -> Show **Full Registry** (all categories)
- `search <keyword>` -> Search all tools by keyword, show matching results
- `list <category>` -> Show tools in that category only
- A natural language task description -> **Smart Suggest** mode: recommend the best tools for the task

## Full Registry

When showing the full registry or a specific category, use this catalog. Each entry format:
`[type] name` -- description

---

### code-quality

| Type | Name | Description |
|------|------|-------------|
| command | `/code-review` | Security and quality review of uncommitted changes |
| command | `/refactor-clean` | Dead code cleanup and refactoring |
| agent | `code-reviewer` | Expert code review for quality, security, maintainability |
| agent | `refactor-cleaner` | Dead code removal, duplicate cleanup, consolidation |
| agent | `critic-agent` | Evaluate and improve outputs through systematic self-critique |
| skill | `code-review` | 5-layer code review (correctness/design/security/perf/maintenance) |
| skill | `clean-code` | Clean code principles and coding standards |
| skill | `refactoring` | Safe, systematic refactoring with test verification |

**Related**: If using code-review, also consider `security-audit` and `tdd-workflow`.

---

### testing

| Type | Name | Description |
|------|------|-------------|
| command | `/tdd` | Enforce TDD workflow: scaffold, test first, implement, 80%+ coverage |
| command | `/e2e` | Generate and run Playwright end-to-end tests |
| command | `/test-coverage` | Analyze and improve test coverage |
| command | `/go-test` | TDD workflow for Go with table-driven tests |
| agent | `tdd-guide` | TDD specialist enforcing write-tests-first methodology |
| agent | `e2e-runner` | E2E testing with Vercel Agent Browser / Playwright fallback |
| skill | `tdd-workflow` | Red-Green-Refactor cycle with 80%+ coverage enforcement |

**Related**: Pair `/tdd` with `code-reviewer` for post-implementation review.

---

### security

| Type | Name | Description |
|------|------|-------------|
| agent | `security-reviewer` | OWASP Top 10, secret detection, injection, SSRF, unsafe crypto |
| skill | `security-audit` | Full security audit: vulnerability scan, dependency audit, secret detection |

**Related**: Always run `security-reviewer` alongside `code-reviewer` for auth/API/input code.

---

### planning

| Type | Name | Description |
|------|------|-------------|
| command | `/plan` | Requirements analysis, risk assessment, step-by-step implementation plan |
| command | `/orchestrate` | Multi-agent orchestration for complex tasks |
| command | `/multi-agent` | Coordinate multiple agents on a single task |
| command | `/define-dod` | Define Definition of Done for a feature |
| command | `/setup-pm` | Configure preferred package manager |
| agent | `planner` | Expert planning for features and refactoring |
| agent | `architect` | System design, scalability, technical decision-making |
| agent | `coordinator` | Multi-agent coordination, task dependencies, result aggregation |
| agent | `tree-of-thoughts` | Explore multiple solution paths, evaluate branches, select optimal |
| agent | `react-agent` | ReAct pattern: interleave reasoning with actions for multi-step tasks |
| skill | `architecture-design` | ADR writing, system design docs, Clean Architecture, DDD, microservices |

**Related**: Start with `/plan`, then use `architect` for system-level decisions.

---

### frontend

| Type | Name | Description |
|------|------|-------------|
| command | `/frontend-codemap` | Generate UI structure and component mapping docs |
| command | `/modern-frontend` | Modern frontend patterns and best practices |
| agent | `a11y-reviewer` | WCAG 2.1 compliance, ARIA patterns, inclusive design |
| agent | `react-agent` | ReAct pattern agent (also useful for React component reasoning) |
| skill | `react-component` | React component development with TypeScript, hooks, accessibility |
| skill | `frontend-codemap` | UI structure analysis and component mapping documentation |
| skill | `mobile-tablet-redesign` | Mobile/tablet UX redesign without affecting PC version |

**Related**: Use `a11y-reviewer` alongside any frontend component work.

---

### backend

| Type | Name | Description |
|------|------|-------------|
| command | `/go-build` | Fix Go build errors, vet warnings, linter issues |
| command | `/go-review` | Go code review for idiomatic patterns, concurrency, security |
| command | `/rust` | Rust development patterns and best practices |
| agent | `go-build-resolver` | Go build/vet/compilation error resolution |
| agent | `go-reviewer` | Idiomatic Go, concurrency patterns, error handling, performance |
| agent | `python-reviewer` | Python type hints, async, imports, Pydantic, security |
| agent | `rust-expert` | Rust ownership, lifetimes, concurrency, systems programming |
| agent | `graphql-expert` | GraphQL schema design, resolver optimization, security |
| agent | `database-reviewer` | PostgreSQL optimization, schema design, Supabase best practices |
| skill | `backend-api` | FastAPI-based backend API implementation and testing |
| skill | `api-design` | RESTful/GraphQL API design principles and OpenAPI documentation |
| skill | `api-spec-generator` | PM/developer API specs, workflow docs, feature specifications |
| skill | `database-schema` | ERD generation, schema design, migrations, query optimization |

**Related**: Use `database-reviewer` when writing migrations. Pair `api-design` with `backend-api`.

---

### ai-ml

| Type | Name | Description |
|------|------|-------------|
| agent | `vector-db-agent` | Vector DB design, embedding pipelines, RAG system optimization |
| skill | `ml-training` | ML/AI model training, fine-tuning, embeddings, evaluation |
| skill | `rag-2.0` | Advanced RAG: hybrid search, GraphRAG, retrieval patterns |
| skill | `prompt-optimizer` | Prompt engineering and LangGraph optimization |
| skill | `llm-app-planner` | Quick reference for LLM app patterns (RAG vs Agent vs etc.) |
| skill | `chatbot-designer` | Chatbot/conversational AI system design |
| skill | `agent-evaluator` | AI agent and chatbot automated testing and benchmarking |
| skill | `agentic-workflows` | Multi-agent systems, orchestration, ReAct/Plan-Execute patterns |
| skill | `ai-research-integration` | AI research paper analysis and implementation |
| skill | `research-agent-tech` | Research agent technologies and patterns |

**Related**: Start with `llm-app-planner` to pick the right pattern, then use specialized skills.

---

### devops

| Type | Name | Description |
|------|------|-------------|
| command | `/build-fix` | Fix build errors incrementally |
| command | `/verify` | Run verification checks before commit |
| agent | `build-error-resolver` | Build/TypeScript error resolution with minimal diffs |
| agent | `infrastructure-agent` | Container orchestration, IaC, deployment pipelines |
| agent | `performance-optimizer` | API response time, token efficiency, query performance |
| skill | `performance-optimization` | Profiling, benchmarking, DB query optimization, bundle optimization |
| skill | `git-workflow` | Conventional commits, auto PR, branch strategy |

**Related**: Use `build-error-resolver` immediately when builds fail. Pair with `infrastructure-agent` for deployment issues.

---

### documentation

| Type | Name | Description |
|------|------|-------------|
| command | `/update-docs` | Update project documentation |
| command | `/update-codemaps` | Regenerate codemap documentation |
| command | `/handoff` | Create session handoff notes for continuity |
| agent | `doc-updater` | Documentation and codemap specialist |
| skill | `documentation-gen` | README, API docs, ADR, CHANGELOG, onboarding guide generation |
| skill | `dev-blog-writer` | Technical blog posts with E-E-A-T, SEO, global standards |
| skill | `portfolio-generator` | Project portfolio docs with architecture diagrams and metrics |
| skill | `dev-journal` | Development log: project history, decisions, problem-solving records |
| skill | `context-compressor` | Context compression for token optimization |

**Related**: Run `/update-codemaps` after major refactors. Use `dev-journal` to track decisions.

---

### learning

| Type | Name | Description |
|------|------|-------------|
| command | `/learn` | Extract and save patterns from current session |
| command | `/eval` | Evaluate code or approach quality |
| command | `/token-analysis` | Analyze token usage and optimization opportunities |
| command | `/checkpoint` | Save progress checkpoint for session continuity |
| command | `/skill-create` | Extract coding patterns from git history into SKILL.md |
| command | `/evolve` | Cluster related instincts into skills, commands, or agents |
| command | `/instinct-status` | Show all learned instincts with confidence levels |
| command | `/instinct-export` | Export instincts for sharing |
| command | `/instinct-import` | Import instincts from external sources |
| agent | `debugger` | Bug diagnosis and fix, test failures, runtime errors |
| skill | `debugging` | Systematic debugging: hypothesis-based, bisect, log analysis, RCA |
| skill | `learning-journal` | Auto-generate learning notes from errors, patterns, decisions |
| skill | `developer-growth` | Guided learning framework (70/30 practice/theory) |
| skill | `ai-developer-practice` | AI-assisted development practices and workflows |
| skill | `mcp-integration` | MCP server setup and external tool integration |

**Related**: Use `/learn` before `/clear` to preserve session knowledge.

---

### product

| Type | Name | Description |
|------|------|-------------|
| command | `/setup-pm` | Configure package manager preferences |
| skill | `product-planner` | PRD, roadmap, market research, TAM/SAM/SOM, JTBD, RICE, Lean Canvas |

**Related**: Use `product-planner` before `/plan` for product-level decisions.

---

## Search Mode

When the user provides `search <keyword>`:

1. Search ALL tool names and descriptions (case-insensitive) across every category
2. Return matching tools in a table with columns: Category, Type, Name, Description
3. If no matches found, suggest the closest category or alternative keywords
4. Show a maximum of 15 results, sorted by relevance

## Smart Suggest Mode

When the user describes a task in natural language:

1. Identify the task type (new feature, bug fix, refactor, review, deploy, etc.)
2. Recommend a **workflow** of 2-4 tools in execution order
3. Format as:

```
Recommended workflow for: "<task description>"

Step 1: [tool-type] tool-name -- why
Step 2: [tool-type] tool-name -- why
Step 3: [tool-type] tool-name -- why

Also consider: tool-a, tool-b
```

### Common Workflow Templates

| Task | Recommended Flow |
|------|-----------------|
| New feature | `/plan` -> `/tdd` -> `code-reviewer` -> `security-reviewer` |
| Bug fix | `debugger` -> `debugging` skill -> `/tdd` (regression test) -> `code-reviewer` |
| Refactor | `/plan` -> `/refactor-clean` -> `code-reviewer` -> `/verify` |
| API development | `api-design` -> `/tdd` -> `backend-api` -> `security-reviewer` |
| Frontend component | `react-component` -> `a11y-reviewer` -> `/e2e` |
| Performance issue | `performance-optimization` -> `performance-optimizer` -> `/verify` |
| Security audit | `security-audit` -> `security-reviewer` -> `/verify` |
| LLM/AI app | `llm-app-planner` -> `chatbot-designer` or `rag-2.0` -> `agent-evaluator` |
| Go development | `/go-build` -> `/go-test` -> `/go-review` |
| Documentation | `/update-codemaps` -> `/update-docs` -> `doc-updater` |

## Output Format

Always display results in clean markdown tables. Include:
- Tool count summary at the top: `Found X tools across Y categories`
- Category headers with horizontal rules
- The "Related" suggestions after each category
- A footer tip: `Tip: Use /tool-registry search <keyword> to find specific tools`

## Stats Summary

When showing the full registry, display this header:

```
Tool Registry: 91 tools available
  30 commands (/) | 24 agents | 37 skills
  11 categories: code-quality, testing, security, planning, frontend,
                 backend, ai-ml, devops, documentation, learning, product
```
