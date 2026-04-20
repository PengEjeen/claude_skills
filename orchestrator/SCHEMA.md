# Orchestration Artifact Schema

## state.json
```json
{
  "project": "string",
  "round": 1,
  "status": "planned | retry | passed | stopped",
  "goal": "string",
  "focus": ["string"],
  "budget": {
    "max_rounds": 5,
    "remaining_rounds": 5,
    "mode": "balanced"
  },
  "last_eval": {
    "phase": "contract_negotiation | execution_evaluation",
    "result": "pass | fail | blocked",
    "score": 0,
    "gate_passed": false,
    "qa_required": false,
    "qa_performed": false,
    "critical_dod_failed": 0
  },
  "updated_at": "2026-04-17T00:00:00Z"
}
```

## contract.json
```json
{
  "round": 1,
  "objective": "string",
  "in_scope": ["string"],
  "out_of_scope": ["string"],
  "dod": ["[CRITICAL] string", "string"],
  "constraints": ["string"],
  "handoff_to_builder": ["string"],
  "contract_status": "draft | drafted_by_builder | agreed",
  "execution_authorized": false,
  "gate_policy": {
    "min_score": 75,
    "min_dod_ratio": 0.85,
    "rubric_categories": ["design_quality", "originality", "sophistication", "functionality"],
    "rubric_weights": { "design_quality": 0.25, "originality": 0.25, "sophistication": 0.25, "functionality": 0.25 }
  },
  "qa_mode": "none | mcp_execution",
  "qa_required": false,
  "qa_targets": ["string"],
  "acceptance_checks": ["string"],
  "critical_checks": ["string"],
  "negotiation": {
    "builder_draft": {},
    "evaluator_adjustments": ["string"],
    "agreed_at": ""
  }
}
```

## eval.json
```json
{
  "round": 1,
  "phase": "contract_negotiation | execution_evaluation",
  "result": "pass | fail | blocked",
  "score": 0,
  "rubric": {
    "design_quality":  { "score": 0, "notes": "string" },
    "originality":     { "score": 0, "notes": "string" },
    "sophistication":  { "score": 0, "notes": "string" },
    "functionality":   { "score": 0, "notes": "string" }
  },
  "gate_passed": false,
  "qa_required": false,
  "qa_performed": false,
  "qa_summary": {
    "mode": "none | mcp_execution",
    "tools_used": ["string"],
    "checks_run": ["string"],
    "evidence": ["string"],
    "skipped_reason": ""
  },
  "blocking_issues": ["string"],
  "passed_checks": ["string"],
  "failed_checks": ["string"],
  "next_actions": ["[P1] string"],
  "critical_dod_failed": 0,
  "stop_reason": "",
  "updated_at": "2026-04-17T00:00:00Z"
}
```

### Rubric semantics

- `score` (integer 0..100): overall gate score. Used by `gate_policy.min_score`. This remains the single source of truth for gating.
- `rubric`: 4-dimensional breakdown for human-readable evaluation calibration. Default dimensions follow the "Harness design" blueprint and are optimized for product UX quality:
  - `design_quality` — coherence of the whole (layout, naming, API shape)
  - `originality` — evidence of custom decisions, not boilerplate
  - `sophistication` — technical execution (edge cases, performance, idiom)
  - `functionality` — usability independent of aesthetics (does it do the thing?)
- Each dimension is an integer 0..100 with a short notes string.
- Overall `score` SHOULD be computed as the weighted mean of the 4 dimensions (default: equal weights). Evaluator may override weights via `contract.gate_policy.rubric_weights` when set.
- Projects that are not UX-facing (e.g. CLI tools, library code) MAY redefine the 4 dimension keys via `contract.gate_policy.rubric_categories` (array of 4 strings). Evaluator must then use those exact keys in `eval.rubric`.

## history/

Per-round snapshots written by `orchestrator/loop-controller.sh` after each round. Each file is a full JSON dump of `{state, contract, eval}` at archive time, named `round-<N>-<ts>.json`.

### Purpose
- Human audit — answering "why did round 3 fail?" without replaying the loop.
- External analysis — dashboards, rubric trend charts, success-rate aggregation.
- Session handoff — feeding `/handoff` or a new session with "here's what happened last time".

### Readers
- **Allowed:** humans, `/handoff`, external analysis scripts (e.g. `jq` one-liners over `history/*.json`).
- **Forbidden:** Planner, Builder, Evaluator. These agents must read only the latest `state.json`, `contract.json`, and `eval.json`.

### Rationale
Letting agents read history defeats the harness's context-reset strategy. The blog's core claim — "context windows fill up and long-running models lose coherence" — is prevented by keeping each round's agent view narrow. History is for post-hoc review by humans, not for loop input.

### Retention policy
- Default: keep the most recent **20 rounds**. Older archives are pruned by `loop-controller.sh` at the end of each round.
- Override: set env var `ORCHESTRATOR_HISTORY_RETENTION=<N>` (integer >= 1) before invoking the loop controller. `N=0` disables pruning (unbounded history — not recommended for long-running projects).
- Pruning removes the oldest files first (by filename timestamp suffix, stable ordering).
- If you need permanent archival for compliance or research, copy snapshots out of `history/` into an external store before pruning runs.

## contract_status transitions

The `contract.contract_status` field is a 3-state machine. Each role writes a disjoint subset of values:

```
(no contract)
    │
    ▼
  draft  ────(Builder, Mode A)────▶  drafted_by_builder  ────(Evaluator, Phase A)────▶  agreed
    ▲                                                                                      │
    │                                                                                      │
    └──(Planner, new sprint round, Policy 2)───────────────────────────────────────────────┘
                                                                                           │
                                                                                           ▼
                                                                             Planner Policy 1:
                                                                             preserve `agreed`,
                                                                             refresh handoff only
```

Role-specific write sets:
- Planner writes `draft` (new round) or keeps `agreed` (Policy 1 preservation). Never writes `drafted_by_builder`.
- Builder writes `drafted_by_builder` (Mode A only). Never writes `draft` or `agreed`.
- Evaluator writes `agreed` (Phase A finalization only). Never writes `draft` or `drafted_by_builder`.
- Loop controller never writes `contract.json`.

`execution_authorized` is coupled: only Evaluator can flip it to `true`, and only when `contract_status = agreed`.
