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
| react-agent | React components, hooks, state management, performance | sonnet |
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
- Complex feature request → **planner** (mandatory)
- Code just written/modified → **code-reviewer** (mandatory)
- Bug fix or new feature → **tdd-guide**
- Build/type error → **build-error-resolver**
- Runtime error/test failure → **debugger**
- Auth/API/input handling → **security-reviewer** (parallel)
- UI changes → **a11y-reviewer**
- DB/SQL changes → **database-reviewer**
- Python code → **python-reviewer**
- Go code → **go-reviewer**
- React code → **react-agent**

## Execution
- **Parallel**: Independent reviews (security + performance + type check)
- **Sequential**: When results inform next step (plan → implement → review)
- Use split-role sub-agents for complex analysis

## Communication Rules
- Each agent MUST declare its scope before starting (what files it will touch)
- Agents MUST NOT modify files outside their declared scope
- When multiple agents run in parallel, they MUST work on non-overlapping files
- Agent output format: `[AGENT_NAME] STATUS: summary` for coordination
- On conflict: stop and report to user, do not overwrite other agent's work
- Research/exploration agents: return summary only, never modify files

## Reasoning Budget (Harness Engineering)

> Terminal Bench 2.0 실측: high(63.6%) > xhigh(53.9%). xhigh는 과도한 내부 토큰(50,000+)으로 타임아웃 발생.
> 따라서 Planning도 high 사용. Opus 모델의 기본 추론력으로 충분.

| Phase | Level | Agent Mapping |
|-------|-------|---------------|
| Planning | high | planner, architect (Opus) |
| Implementation | high | code-reviewer, tdd-guide, security-reviewer (Sonnet) |
| Verification | high | e2e-runner, debugger (Sonnet) |
| Simple edits | low | doc-updater, refactor-cleaner (Haiku when available) |

## Tool Strategy (Bash-First)

> mini-SWE-agent: bash-only로 SWE-bench 74% 달성 (Princeton/Stanford).
> 전용 도구는 bash로 대체 불가능한 5-10% 케이스에만 사용.

- **Core agents** (planner, code-reviewer, tdd-guide): Read, Grep, Glob, Bash만 사용
- **Build agents** (build-error-resolver, go-build-resolver): + Edit, Write 추가
- **Specialized agents** (e2e-runner, infrastructure-agent): 전용 도구 허용
- **Research agents** (architect, critic-agent, tree-of-thoughts): Read, Grep, Glob만 (수정 금지)
