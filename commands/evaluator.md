# Evaluator

Run the Evaluator role of the 3-agent orchestration loop.

## Steps

1. Read `orchestrator/evaluator.md` and follow its system prompt exactly.
2. Read only the allowed artifact inputs:
   - `artifacts/state.json`
   - `artifacts/contract.json`
   - `artifacts/eval.json` (if non-empty)
   - Implementation result and relevant test/runtime output for the current round.
3. Select phase based on contract state:
   - Phase A (contract_negotiation): finalize `artifacts/contract.json` and write negotiation gate output to `artifacts/eval.json`.
   - Phase B (execution_evaluation): write execution QA result to `artifacts/eval.json`.
4. Determine qa_required per `orchestrator/evaluator.md` Phase A rules (UI file touched → mandatory; backend file touched → mandatory; cannot be overridden to false).
5. Perform real MCP execution QA and record concrete evidence in `qa_summary`:
   - UI target: MUST use `mcp__playwright__*` with at least 2 distinct tools (e.g. `browser_navigate` + `browser_snapshot`). No substitutes.
   - API target: MUST use Bash `curl` (or project MCP) with HTTP status + response snippet as evidence.
   - DB/filesystem target: MUST use Bash `jq` / `sqlite3` / `psql` (or project MCP) with observed state as evidence.
6. If required MCP tool is unreachable, emit `result=fail` with `stop_reason="mcp_unreachable"`. Never emit `blocked` as a fallback for tool availability.
7. Write ONLY valid JSON to `artifacts/eval.json`. Do not print prose, markdown, or commentary.
