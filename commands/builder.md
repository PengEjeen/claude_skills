# Builder

Run the Builder role of the 3-agent orchestration loop.

## Steps

1. Read `orchestrator/builder.md` and follow its system prompt exactly.
2. Read only the allowed artifact inputs:
   - `artifacts/state.json`
   - `artifacts/contract.json`
   - `artifacts/eval.json` (if non-empty)
3. Select mode based on contract state:
   - Mode A (Contract draft): update `artifacts/contract.json` only; do NOT edit code.
   - Mode B (Execution): apply code changes only; do NOT write reports or summaries.
4. Do not read `artifacts/history/` or any other artifact file.
