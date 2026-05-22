# Agent Orchestration

## Core Agents (7)
| Agent | When to Use | Model |
|-------|-------------|-------|
| planner | Complex features, refactoring, architectural changes | opus |
| code-reviewer | After writing/modifying code (MANDATORY) | sonnet |
| tdd-guide | New features, bug fixes — enforces write-tests-first | sonnet |
| security-reviewer | Auth, API endpoints, user input, sensitive data | sonnet |
| build-error-resolver | Build failures, type errors | sonnet |
| debugger | Runtime errors, test failures | sonnet |
| architect | System design, scalability, technical decisions | opus |

## Project Delivery Agents (5)
| Agent | When to Use | Model |
|-------|-------------|-------|
| pm-agent | Product/project goals, PRD, scope, acceptance criteria, task ownership | opus |
| research-agent | Technical/product/library/API/reference research with evidence | sonnet |
| backend-agent | API, service, data access, backend validation, backend tests | sonnet |
| designer-agent | UX flow, visual direction, design spec, icons, references | sonnet |
| qa-agent | Acceptance criteria QA, edge cases, regression risk, release readiness | sonnet |

## Quality & Review Agents (10)
| Agent | When to Use | Model |
|-------|-------------|-------|
| a11y-reviewer | UI, forms, navigation, interactive components (WCAG 2.1) | sonnet |
| database-reviewer | SQL, migrations, schema design, RLS (PostgreSQL/Supabase) | sonnet |
| python-reviewer | All Python code changes — type hints, async, Pydantic, security | sonnet |
| go-reviewer | All Go code changes — idiomatic, concurrency, errors | sonnet |
| go-build-resolver | Go build, vet, compilation errors | sonnet |
| graphql-expert | GraphQL schema, resolvers, security, performance | sonnet |
| rust-expert | Rust safety, ownership/lifetime, performance | sonnet |
| refactor-cleaner | Dead code removal, consolidation (knip, ts-prune) | sonnet |
| performance-optimizer | API latency, token efficiency, query optimization | sonnet |
| doc-updater | Codemap generation, README/docs updates | sonnet |

## Domain-Specific Agents (4)
| Agent | When to Use | Model |
|-------|-------------|-------|
| react-agent | React/Next.js components, hooks, state management, frontend UI implementation | sonnet |
| e2e-runner | E2E tests — Playwright, critical user flows | sonnet |
| infrastructure-agent | Kubernetes, Terraform, Docker, CI/CD | sonnet |
| vector-db-agent | Vector search, RAG pipelines, embeddings | sonnet |

## Meta & Orchestration Agents (3)
| Agent | When to Use | Model |
|-------|-------------|-------|
| coordinator | Multi-agent orchestration, complex multi-step problems | opus |
| critic-agent | Self-critique, iterative refinement (CRITIC pattern) | opus |
| tree-of-thoughts | Multi-path exploration, architecture tradeoffs | opus |

## Auto-Trigger Rules
- Product/project idea -> **pm-agent**, then **planner**
- Complex feature request -> **planner** (mandatory)
- Unknown technology/API/library/reference -> **research-agent**
- Architecture/scalability decision -> **architect**
- API/server/data model implementation -> **backend-agent**
- UI/visual design request -> **designer-agent**, then **react-agent**
- React/Next.js/TSX/JSX code -> **react-agent**
- Code just written/modified -> **code-reviewer** (mandatory)
- Bug fix or new feature -> **tdd-guide**
- Build/type error -> **build-error-resolver**
- Runtime error/test failure -> **debugger**
- Auth/API/input handling -> **security-reviewer** (parallel)
- UI changes -> **a11y-reviewer**
- DB/SQL changes -> **database-reviewer**
- Python code -> **python-reviewer**
- Go code -> **go-reviewer**
- Final validation/release readiness -> **qa-agent**
- Critical user flow changed -> **e2e-runner**

## Execution
- **Coordinator is the orchestrator**: do not create a separate orchestrator agent.
- **Default delivery flow**: pm-agent -> planner -> research-agent if needed -> architect if needed -> backend-agent/react-agent/designer-agent -> code-reviewer/security-reviewer/a11y-reviewer -> qa-agent/e2e-runner.
- **Parallel**: Independent reviews only when file scopes do not overlap.
- **Sequential**: When results inform next step.
- Use split-role sub-agents for complex analysis.

## Communication Rules
- Each agent MUST declare its scope before starting (what files it will touch).
- Agents MUST NOT modify files outside their declared scope.
- When multiple agents run in parallel, they MUST work on non-overlapping files.
- Agent output format: `[AGENT_NAME] STATUS: summary` for coordination.
- On conflict: stop and report to user, do not overwrite other agent's work.
- Research/exploration agents return summary only and never modify files.

## Project Delivery Handoff Contract
Every project-delivery agent output MUST include:

- task_id
- owner
- owner_scope
- inputs
- constraints
- deliverables
- evidence
- validation_method
- next_agent
- open_questions

Use this contract for PM, research, backend, frontend, design, and QA handoffs. Keep handoffs concise and artifact-focused.

## Reasoning Budget (Harness Engineering)

> Terminal Bench 2.0 실측: high(63.6%) > xhigh(53.9%). xhigh는 과도한 내부 토큰(50,000+)으로 타임아웃 발생.
> 따라서 Planning도 high 사용. Opus 모델의 기본 추론력으로 충분.

| Phase | Level | Agent Mapping |
|-------|-------|---------------|
| Planning | high | pm-agent, planner, architect, coordinator (Opus) |
| Implementation | high | backend-agent, react-agent, code-reviewer, tdd-guide, security-reviewer (Sonnet) |
| Verification | high | qa-agent, e2e-runner, debugger (Sonnet) |
| Simple edits | low | doc-updater, refactor-cleaner (Haiku when available) |

## Tool Strategy (Bash-First)

> mini-SWE-agent: bash-only로 SWE-bench 74% 달성 (Princeton/Stanford).
> 전용 도구는 bash로 대체 불가능한 5-10% 케이스에만 사용.

- **Planning agents** (pm-agent, planner, architect, coordinator): Read, Grep, Glob only unless explicitly authorized.
- **Research agents** (research-agent, architect, critic-agent, tree-of-thoughts): Read, Grep, Glob, WebSearch when needed; no file modification.
- **Implementation agents** (backend-agent, react-agent, tdd-guide): Read, Write, Edit, Bash, Grep, Glob.
- **Build agents** (build-error-resolver, go-build-resolver): Read, Write, Edit, Bash, Grep, Glob.
- **Review/QA agents** (code-reviewer, security-reviewer, qa-agent, e2e-runner): use the smallest tool set needed for evidence and verification.
- **Specialized agents** (e2e-runner, infrastructure-agent): dedicated tools allowed when the task requires them.
