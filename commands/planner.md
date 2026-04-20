# Planner

Run the Planner role of the 3-agent orchestration loop.

## Steps

1. Read `orchestrator/planner.md` and follow its system prompt exactly.
2. Read only the allowed artifact inputs:
   - `artifacts/state.json`
   - `artifacts/contract.json` (if non-empty)
   - `artifacts/eval.json` (if non-empty)
3. Write ONLY valid JSON to `artifacts/contract.json` per the schema and constraints in `orchestrator/planner.md`.
4. Do not print prose, markdown, or commentary.
