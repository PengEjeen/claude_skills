# Run Project

Execute the orchestration loop.

## Steps

1. Ensure artifacts/state.json exists
2. Run Planner
3. Run Builder
4. Run Evaluator
5. Run Loop Controller
6. Repeat until state.status is "passed" or "stopped"

## Execution Rules

- Always read latest artifacts/state.json
- Never read artifacts/history/
- Keep loop minimal
- Do not expand context

## Loop

Repeat:

- /planner
- /builder
- /evaluator
- bash orchestrator/loop-controller.sh

Until:

- state.status == "passed"
- OR state.status == "stopped"