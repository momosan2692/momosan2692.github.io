---
layout: post
title: Model Governance Layer Design Spec
subtitle: 從AlpacaTradingAgent -- LangGraph multi-agent pipeline
cover-img: /assets/img/header/2026-04-24/ROCE.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-24/ROCE.png
published: true
pinned: true
mathjax: true
tags: [draft, MODELS]
---

# Model Governance Layer — Design Spec
### For: AlpacaTradingAgent (LangGraph multi-agent pipeline)
### Scope: Governance Gate + Model Registry + Drift Monitor + Shadow-Trading Harness + RL Reward Audit Checklist
### Status: Design doc, no code — architecture and interfaces only


## 1. Purpose

Today, a signal-producing model (Two-Pole Oscillator, JEPA_1m/JEPA_30m, any future RL policy) reaches the live pipeline based on informal judgment — "it passed backtest, ship it." This spec defines a **standing layer between model development and live trading** that makes that judgment call explicit, auditable, and revocable — without adding LLM reasoning to anything safety-critical.

Core principle carried over from the earlier discussion: **validation is a system-level concern, not an agent's job.** Every component below is code/rule-driven. No LLM sits in this layer's decision path.

## 2. Where This Sits

```
[Research / Training]
        │
        ▼
[MODEL GOVERNANCE GATE]  ← this spec, Section 3
        │  (approved)
        ▼
[MODEL REGISTRY]         ← this spec, Section 4
        │
        ▼
[SHADOW-TRADING HARNESS] ← this spec, Section 6
        │  (passes shadow criteria)
        ▼
[LIVE — LangGraph analyst layer]
   (market / social / news / fundamentals / macro analysts,
    incl. Two-Pole Oscillator, JEPA, any RL policy)
        │
        ▼
[Risk debaters → Trader / Risk Manager node]  ← existing, unchanged
        │
        ▼
[Alpaca order execution]

Running in parallel, always-on, for anything live:
[DRIFT MONITOR]  ← this spec, Section 5 — can demote a live model back to shadow at any time
```

The Gate and Registry are **pre-deployment**. The Drift Monitor is **continuous, in production**. The Shadow Harness sits **between approval and live capital**. None of these replace the existing Risk Manager node — they gate what's *allowed to reach* the Risk Manager in the first place.

## 3. Model Governance Gate

**Function:** Binary approve/reject checkpoint. A model cannot enter the Shadow-Trading Harness without passing this gate.

### 3.1 Inputs required from the model owner (you, or a future automated training job)

| Field | Description |
|---|---|
| Model identifier | Name + version (e.g. `two_pole_oscillator_v4.5`, `jepa_1m_v3`) |
| Model class | Rule-based / statistical / supervised ML / RL policy |
| Training/fit window | Date range of data used |
| Validation methodology used | e.g. purged K-fold CV, walk-forward optimization, combinatorial purged CV |
| Validation metrics | D²_weighted, Sharpe (out-of-sample), max drawdown (out-of-sample), hit rate, abstain rate |
| Feature set | List of inputs the model consumes, with source (OHLCV, Two-Pole Oscillator derived features, news sentiment, etc.) |
| Reward function definition (RL only) | See Section 7 |
| Known limitations | Explicit statement of regimes/conditions where the owner expects the model to underperform |

### 3.2 Gate checks (all must pass — no partial credit)

1. **Temporal generalization** — validation used purged/embargoed cross-validation or walk-forward, not naive k-fold (which leaks future information into training folds for time series).
2. **Regime generalization** — model has been backtested against at minimum: one high-volatility shock period, one low-volatility grind period, one trend regime, one mean-reverting/choppy regime. A model that was only ever validated in one regime is rejected regardless of its metrics.
3. **Abstain behavior verified** — the model has a defined "no signal / no position" output, and that output was actually exercised during validation (not just theoretically available). Consistent with the abstain-first-class-output principle.
4. **Degenerate-strategy check** — reject if the validated strategy's return profile shows the classic RL/ML failure signature: small consistent gains with a fat left tail (asymmetric risk the reward function didn't penalize). This is a manual review step, not automatable with a single metric.
5. **Feature leakage check** — confirm no feature in the input set is computed using information not available at decision time (a common bug source given your history with `bar_time` field issues).
6. **Reproducibility** — training/validation can be re-run from stored config and produces materially the same result. A model that can't be reproduced can't be re-audited later, and is rejected on that basis alone.

### 3.3 Output

A **Gate Decision Record**: model ID, decision (approved / rejected / approved-with-conditions), reviewer (you), date, and the specific evidence for each of the six checks above. This record is immutable once issued (append corrections as new records, don't edit history) — same audit-chain principle as your medical RAG project's SHA-256 chain.

### 3.4 Re-review trigger

Any live model must return through the Gate on: (a) any material retraining, (b) every 90 days regardless of retraining ("periodic re-review" — performance validity isn't permanent), or (c) immediately if the Drift Monitor (Section 5) demotes it.

---

## 4. Model Registry

**Function:** Single source of truth for "what trained artifact is live, and why" — separate from your existing git-based code versioning, because a model's identity is its weights/parameters + training data lineage, not its code.

### 4.1 What it tracks per model version

| Field | Purpose |
|---|---|
| Model ID + version | Unique key |
| Artifact location | Where the trained weights/parameters live (e.g. path to `JEPA_1m.pt`) |
| Gate Decision Record reference | Link to Section 3 output that approved this version |
| Training data window + hyperparameters | Full lineage for reproducibility |
| Reward function version (RL only) | Which reward spec (Section 7) this model was trained against |
| Current lifecycle state | `pending_gate` / `approved` / `shadow` / `live` / `demoted` / `retired` |
| Live-since timestamp | When it entered live trading (null if never live) |
| Demotion history | Every demotion event with cause (drift, drawdown breach, manual) |

### 4.2 Why this matters for your stack specifically

Right now, "which version of Two-Pole Oscillator is running" or "which JEPA checkpoint is live" is implicit in whatever file is referenced in config. The Registry makes it explicit and queryable — so a bad live model can be rolled back to a specific prior known-good version independently of any code deploy, and so the Drift Monitor and Gate have something concrete to reference.

### 4.3 Lifecycle state machine

```
pending_gate → approved → shadow → live → demoted → shadow (retest) → live
                                      │
                                      └──→ retired (permanent, requires new Gate pass to resurrect)
```

Transitions between states are triggered only by: a Gate Decision Record, a Shadow Harness pass/fail (Section 6), or a Drift Monitor demotion event (Section 5). No manual state edits without a corresponding record — the registry's integrity depends on every transition being traceable to a cause.

---

## 5. Drift Monitor

**Function:** Always-on, code-driven, live production process that watches whether the world the model is currently seeing still resembles the world it was validated on. This is the piece that doesn't exist for static, non-learned strategies (a rule-based indicator doesn't "drift" the same way) but is mandatory for any DL/RL model, and useful even for Two-Pole Oscillator's regime assumptions.

### 5.1 What it watches

- **Feature distribution drift** — compare live feature distributions (the same features listed in the Gate's input feature set) against the training-time distribution, using a distributional distance measure (e.g. population stability index or KL divergence). Runs on a rolling window, not single-observation basis.
- **Output distribution drift** — is the model's signal/action distribution (long/short/abstain frequency, confidence/magnitude distribution) statistically consistent with what was observed during validation and shadow trading?
- **Realized performance drift** — live Sharpe/drawdown vs. the validated out-of-sample expectation, checked over a meaningful rolling window (not single-trade reactive, to avoid whipsawing a model in and out on noise).

### 5.2 Action on breach

Drift Monitor breaches are **automatic and code-enforced**, not advisory:

| Severity | Trigger | Action |
|---|---|---|
| Watch | Feature drift exceeds soft threshold | Log + notify, no state change |
| Demote | Feature drift exceeds hard threshold, OR output distribution diverges materially, OR realized drawdown exceeds validated worst-case by a defined margin | Registry state → `demoted`, model pulled from live capital allocation, routed back to Shadow Harness for retest |
| Halt | Multiple models demoted concurrently, or a single demotion coincides with an unclassified regime (nothing in the regime library matches current conditions) | Escalate beyond auto-demotion — pipeline-wide pause pending manual review |

This is the same class of mechanism as your existing risk limits: a hard, code-enforced ceiling that no upstream reasoning (LLM or otherwise) can override.

---

## 6. Shadow-Trading Harness

**Function:** The step between "approved by the Gate" and "trusted with live capital." Every approved model must run here before promotion to live, and every demoted model must return here before re-promotion.

### 6.1 Mechanics

- Model runs against **live market data in real time**, generating signals exactly as it would in production, but signals are logged and scored — never forwarded to the Trader/Risk Manager node or Alpaca execution.
- Runs in parallel with whatever model currently holds the live slot (if any), so you get a direct paper-vs-live comparison under identical market conditions, not a backtest-vs-live comparison across different time periods.

### 6.2 Duration and criteria

- **Duration is not fixed** — it should be long enough to observe the model's behavior across at least one meaningful regime transition, not just a fixed calendar period. For a DL/RL model this should be materially longer than for a rule-based signal like Two-Pole Oscillator, per the earlier point that sandbox performance is a weaker predictor of live robustness for learned policies.
- **Promotion criteria**: shadow performance must fall within the confidence interval established during Gate validation (not just "positive PnL") — a shadow run that beats backtest expectations by an implausible margin is itself a flag (possible look-ahead bug), not a pass.
- **Failure handling**: a model that fails shadow does not get manually patched and re-run in the same shadow slot — it returns to Registry state `approved` (not `live`) and requires a fresh Gate cycle if changed materially, preserving the audit trail.

---

## 7. RL Reward Audit Checklist

**Function:** A specific, mandatory review applied only to RL-class models before they're eligible for the Governance Gate at all — because reward design errors don't show up as validation metric failures, they show up as *technically-correct optimization of the wrong thing*.

### 7.1 Checklist (all items require explicit sign-off, not inference from metrics)

1. **Does the reward function include a risk term**, not just realized PnL? (e.g. penalize drawdown, variance, or tail-risk exposure directly — not just reward terminal return.)
2. **Is abstain/no-position a reachable, non-penalized action** in the reward structure, or does the reward function implicitly punish inaction (making the policy over-trade to avoid an opportunity-cost penalty)?
3. **Is the reward horizon aligned with the intended holding period?** (A reward computed too short-sighted vs. the strategy's actual intended horizon creates myopic policies; too long delays credit assignment past the point of being learnable.)
4. **Has the reward function been stress-tested against adversarial/edge scenarios** — i.e., could a policy maximize this reward through a degenerate strategy that technically satisfies the formula but isn't the intended behavior? (Classic reward-hacking check — walk through the formula and try to "break" it by hand before trusting the trained result.)
5. **Is position-sizing/actuation excluded from the RL action space**, or does the policy directly emit order size/execution actions? Per the earlier architecture decision, an RL policy should propose a signal or state assessment — it should not have direct actuation power over position sizing or order submission. If the action space includes actuation, this is a hard blocker, not a note.
6. **Was the simulator/backtest environment's fill/slippage model validated as realistic**, or could the policy be exploiting simulator quirks (perfect fills, no slippage curve, no latency) that don't exist live? This connects directly to the regime-stress-testing requirement in the Gate.

### 7.2 Output

An **RL Reward Audit Record**, same immutability principle as the Gate Decision Record — a permanent artifact tied to the specific reward function version referenced in the Model Registry (Section 4.1), so any future model trained against a *changed* reward function requires a fresh audit, not a carry-over approval.

---

## 8. Summary: What's Code vs. What's Human Judgment

Consistent with the earlier LLM-vs-code framework — everything in this layer is either deterministic code or explicit human sign-off. Nothing here is LLM-mediated.

| Component | Driven by |
|---|---|
| Gate checks 1, 2, 3, 5, 6 (Section 3.2) | Code (automatable, deterministic pass/fail) |
| Gate check 4 — degenerate-strategy check | Human judgment (you), recorded in the Gate Decision Record |
| Model Registry state transitions | Code (triggered by upstream records, no manual override without a record) |
| Drift Monitor thresholds and demotion | Code, fully automatic |
| Shadow Harness pass/fail | Code (statistical criteria) + human review for "implausibly good" flags |
| RL Reward Audit (all 6 items) | Human judgment (you), recorded permanently |

## 9. Phasing Note

This is the full-scope design; it doesn't need to be built all at once. A reasonable build order, if you want it:

1. Model Registry first (it's the data structure everything else references).
2. Governance Gate (formalizes what you're likely already doing informally).
3. Shadow-Trading Harness (highest leverage before any RL model touches live capital).
4. Drift Monitor (becomes necessary once something DL/RL-based, i.e. JEPA, is actually live).
5. RL Reward Audit — apply retroactively to JEPA now, since it's mid-development, rather than waiting for it to be "done."
