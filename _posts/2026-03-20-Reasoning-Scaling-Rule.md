---
layout: post
title: Reasoning Scaling Rules
subtitle: A Deep Technical Analysis
cover-img: /assets/img/path.jpg
thumbnail-img: /assets/img/header/thinkingtree.gif
share-img: /assets/img/header/evidence.png
published: true    # ← add this, post won't show on blog
pinned: false  # — pin a post to the top
tags: []
---

# Reasoning Scaling Rules — A Deep Technical Analysis
### From Test-Time Compute to Bounded Rationality to Two-Phase Intelligence

**Date:** March 2026  
**Context:** Continuation of "Small Models, Specialist Agents & the Agentic AI Fabric" report  
**Key insight thread:** Go game player's intuition → AlphaGo's "bigger chess" → the two-phase intelligence structure

---

## Table of Contents

1. [The Original Scaling Law — Training-Time](#1-the-original-scaling-law--training-time)
2. [The New Scaling Law — Test-Time Compute](#2-the-new-scaling-law--test-time-compute)
3. [The Three Mechanisms of Test-Time Scaling](#3-the-three-mechanisms-of-test-time-scaling)
4. [The Honest Limits — Where Test-Time Scaling Breaks](#4-the-honest-limits--where-test-time-scaling-breaks)
5. [Bounded Rationality — The Go Game Parallel](#5-bounded-rationality--the-go-game-parallel)
6. [The Go Master's Three Cognitive Moves](#6-the-go-masters-three-cognitive-moves)
7. [The Three Levels of Thinking](#7-the-three-levels-of-thinking)
8. [AlphaGo's "Bigger Chess"](#8-alphagos-bigger-chess)
9. [Hierarchical Reasoning — the Research Response](#9-hierarchical-reasoning--the-research-response)
10. [The Ontology as Sandbox — and Its Limits](#10-the-ontology-as-sandbox--and-its-limits)
11. [Two-Phase Intelligence — The Deepest Frame](#11-two-phase-intelligence--the-deepest-frame)
12. [Key Takeaways](#12-key-takeaways)

---

## 1. The Original Scaling Law — Training-Time

The classical **Chinchilla scaling law** (Hoffmann et al., 2022) established that model performance scales predictably as a power law with training compute:

```
Performance ∝ (Parameters × Training_tokens × FLOPs)^α
```

Three levers, all training-side:
- **More parameters** — scale model size
- **More training data** — tokens proportional to parameters (Chinchilla ratio)
- **More training FLOPs** — compute budget translates directly to capability

The critical characteristic: capability is **baked in at training time** and fixed at deployment. Once trained, the model does not change.

**Cost**: Millions of dollars, weeks of compute  
**Benefit**: Permanent capability gain, reusable across all queries  
**Bottleneck**: Data quality, GPU hours, training infrastructure

---

## 2. The New Scaling Law — Test-Time Compute

The paradigm shift of 2024–2025: performance also scales with **inference-time compute**, following the same power law shape as the training scaling law.

Research by DeepMind confirmed: the scaling law originally formulated for training applies equally to inference — validated across benchmarks in mathematics, physics, and chemistry.

```
Performance ∝ (Inference_compute)^β
```

The core insight: **letting models "think longer"** through extended chain-of-thought produces reasoning capabilities that training alone cannot achieve.

**Landmark results:**

| Model | Method | Achievement |
|---|---|---|
| DeepSeek-R1 | RL + extended CoT | Matches o1 at 70% lower cost — generates 10–100× more tokens per query |
| rStar-Math 3.8B | MCTS at inference | Beats o1-preview on competition math |
| s1-32B (Stanford) | Budget forcing | 1,000 training examples → o1 level on MATH benchmark |
| OpenAI o1/o3 | Extended thinking | State-of-the-art reasoning across domains |

**The two-variable paradigm:**

Historically, increased training compute was the primary driver of AI progress. Test-time compute now represents an additional variable — with multiple dials to optimize rather than just one:

- **Training compute** → better weights → permanent capability
- **Test-time compute** → deeper search → per-query quality boost

**Key observation**: Iteration cycles are now faster in the reasoning research field. More low-hanging fruit exists because it is cheaper to iterate using only RL enhancements and increased test-time compute — without needing to pre-train a new model.

---

## 3. The Three Mechanisms of Test-Time Scaling

### ① Best-of-N / Majority Voting

Generate N independent answers, take the most common (majority vote) or the highest-scoring.

- Simple and parallelizable
- Works well up to N ≈ 100
- No specialized training required
- Diminishing returns beyond N ≈ 32 for most tasks

### ② Process Reward Model (PRM) Guided Search

Score **intermediate reasoning steps**, not just final answers. Find the best *path*, not just the best output.

This is the key innovation behind rStar-Math: the small model acts as a **critic of intermediate steps**, not a solver of the final answer. A 1B model as PRM can guide a larger model's search with dramatic effectiveness.

The PRM is the AI equivalent of a Go master's **position sense** — evaluating the board without needing to play the game to completion.

### ③ Budget Forcing (Stanford s1)

Force the model to "think longer" by appending tokens that continue the reasoning chain. The s1-32B model trained on only 1,000 examples uses budget forcing to achieve test-time scaling behavior — matching or exceeding o1-preview on competition math.

Remarkably efficient: no MCTS, no PRM, just controlled extension of the thinking chain. The model learns to use thinking time proportionally to problem difficulty.

---

## 4. The Honest Limits — Where Test-Time Scaling Breaks

**Critical finding**: Test-time scaling does NOT apply universally.

The scaling law for reasoning holds **only where correctness can be verified**:

| Domain | Test-time scaling | Reason |
|---|---|---|
| Mathematics | ✅ Strong | Verifiable, symbolic, closed |
| Formal logic | ✅ Strong | Verifiable, structured |
| Code generation | ✅ Good | Executable = verifiable |
| Knowledge-intensive QA | ❌ Fails | Cannot verify factual correctness |
| Common sense reasoning | ❌ Fails | No ground truth during search |
| Open-ended questions | ❌ Fails | Hallucination increases with more tokens |

**The overthinking problem**: Increasing test-time computation does not consistently improve accuracy on knowledge-intensive tasks — in many cases it leads to **more hallucinations**. Extended reasoning sometimes encourages attempts on previously unanswered questions, many of which result in confident-but-wrong outputs.

**Implication**: Current o1/o3/DeepSeek-R1 reasoning scaling is powerful but **domain-specific**. It is not a general intelligence amplifier.

---

## 5. Bounded Rationality — The Go Game Parallel

This is the insight that reframes the entire reasoning scaling discussion.

### Herbert Simon's Bounded Rationality (1956)

> "Bounded rationality is not a failure of rationality. It is the only rationality available to minds operating in a real world."

A Go grandmaster with 3 minutes on the clock does not think randomly and stop at the buzzer. They do something far more sophisticated: **they know when they have thought enough, and commit with confidence.** That meta-cognitive act — the decision to stop thinking and act — is itself the intelligence.

### What this means for reasoning scaling

**Current reasoning scaling approach:**
Think for N tokens regardless of whether the model is confident. Stop when the token budget is exhausted. Return the best answer found.

This is **computation**, not intelligence. It is a brute-force search that stops at a timer.

**Bounded rational approach:**
Think until **confidence crosses a threshold**, then commit. The stopping is not a timeout — it is a **felt sense of enough**, driven by calibrated self-assessment.

AlphaGo's bounded rationality is super-human. Human bounded rationality is the product of evolution and physical embodiment. The two are different — but both arrive at good decisions without exhaustive search.

### The key distinction

Thinking only a few steps ahead does not make a player irrational. When players expect that others have limited reasoning capacity, it is rational to stop early too. **Stopping is itself a rational strategic act** — not a failure of reasoning.

Metareasoning — reasoning about the reasoning process itself — is the most promising approach to bounded rationality in AI. The goal is seldom to make an agent as rational as possible. Some degree of bounded rationality is often **optimal** in the right scenario.

---

## 6. The Go Master's Three Cognitive Moves

These map precisely to the components of any intelligent decision system:

### Move ① — Prune the search space (Policy Network)

**Human**: "This board shape feels wrong" — years of pattern training compressed into intuition. Eyes land on 3–4 candidate moves instantly, ignoring the other 350+ legal moves entirely.

**AI equivalent**: Policy network P(move) outputs probability over all legal moves, collapsing 10^170 possible board states to 5–10 candidates worth exploring. This is not computed at move time — it is **trained in** and fires instantly.

**LLM equivalent**: The forward pass through weights surfaces high-probability token candidates. Bad branches are killed before reasoning begins. This happens in microseconds.

### Move ② — Evaluate without playing out (Value Network)

**Human**: "I'm ahead / behind" — reading the whole board position without needing to play the game to completion. The expert's position sense.

**AI equivalent**: Value network V(state) outputs expected win probability from any board position. Stop calculating before the game ends.

**LLM equivalent**: The embedding space encodes semantic distance and relevance. The model "knows" approximately how good a direction is before generating the full chain.

### Move ③ — The stopping criterion (Meta-cognition)

**Human**: "I've thought enough. I'll play here." — Not a timer. Not exhaustion. A *felt sense of enough.*

**AI equivalent**: MCTS runs simulations until the value network says "I know enough about this position." The stopping is driven by **confidence reaching a threshold**, not by a clock.

**LLM equivalent**: This is the least developed component in current systems. Budget forcing approximates it. A true meta-reasoning layer — "I have high enough confidence, stop generating" — is the frontier.

### Move ④ — Satisficing (not optimizing)

**Human**: "Good enough to win" — not seeking the theoretically perfect move, seeking the best reachable move given current information and time.

**AI equivalent**: Best-of-N with early stopping. Stop when the PRM score plateaus — the marginal value of more search falls below a threshold.

---

## 7. The Three Levels of Thinking

This is the central critique of the current reasoning scaling paradigm — and the most important insight in this report.

```
Level 3 — Strategic (whole board)
    "This game is about the bottom-left corner.
     Everything else is secondary."

    → Almost zero compute
    → Pure pattern + experience
    → Instant, pre-conscious
    → Current AI: almost entirely absent
    → Scaling approach: ignored

Level 2 — Operational (regional)
    "These three groups interact. I need to
     settle the left before attacking the right."

    → Light computation
    → Abstract planning
    → Structured decomposition
    → Current AI: CoT partially reaches here
    → Scaling approach: partially addressed

Level 1 — Tactical (move tree)
    "If A then B then C, opponent plays D..."

    → Heavy computation
    → Deep search
    → Explicit step-by-step
    → Current AI: this is ALL current scaling does more of
    → Scaling approach: heavily addressed
```

**The fundamental critique**: The reasoning scaling law — all those extra thinking tokens in o1/o3/DeepSeek-R1 — scales **Level 1 only**. It makes the calculation deeper, not the board reading better.

**The Go master's practice**: Most thinking time is spent at Level 3 and Level 2. Level 1 calculation is invoked only for specific critical sequences, briefly and precisely, after the board has already been read at the higher levels.

**The implication**: More tree search is not more intelligence. Intelligence is knowing **which tree not to search at all.**

---

## 8. AlphaGo's "Bigger Chess"

A 50-year Go player's observation upon watching the AlphaGo vs. Lee Sedol match (2016):

> "Not as usual. AlphaGo looks at a much bigger chess."

This observation — from someone with board sense built over five decades — is more precise than almost anything in the academic literature.

### What "bigger chess" actually means

AlphaGo was not playing the board humans were playing on. It was playing on a **probability landscape** that extended far beyond what any human had been trained to perceive. The territory it was defending or attacking was not made of stones — it was made of **winning percentages across thousands of possible futures simultaneously.**

### Move 37, Game 2 — the perfect example

Every professional commentator called it a mistake. Lee Sedol stood up and left the room for 15 minutes. By every human Level 2 and Level 1 reading — regionally and tactically — it looked wrong.

But AlphaGo was reading at a Level 3 that human professionals had never needed to develop, because **no human opponent had ever played there.**

Humans developed intuition calibrated against human opponents across centuries. AlphaGo played millions of games against itself — and discovered a strategic layer that human Go culture had never mapped.

### The deeper implication for AI

If AlphaGo found a Level 3 that 3,000 years of human Go couldn't see — what Level 3 might a future reasoning AI find in domains like medicine, materials science, or financial markets that humans have been "playing" for centuries but never fully mapped?

The critical architectural question: **Is the Ontology giving AI the board humans play on — or is it preventing AI from finding the bigger one?**

---

## 9. Hierarchical Reasoning — the Research Response

The research community is beginning to address the Level 3 / Level 2 gap directly, inspired precisely by the Go parallel.

### HyperTree Planning (HTP)

HyperTree Planning constructs hypertree-structured planning outlines, enabling LLMs to engage in hierarchical thinking by flexibly employing divide-and-conquer — breaking down intricate reasoning steps while managing multiple distinct sub-tasks in an organised manner.

This is the style of a Go player who thinks: "The top-right is already decided. The bottom is the real game. These two middle groups are the bridge." Not reading one long sequence — managing a **structured decomposition** of the whole board simultaneously.

HTP-style players stay at Level 3, delegate local calculations only when necessary, and re-integrate results back into the strategic view.

### Hierarchical Reasoning Model (HRM)

Two interdependent recurrent modules:
- **High-level module** — slow, abstract planning (Level 3 + Level 2)
- **Low-level module** — rapid, detailed computation (Level 1)

Results: With only **27 million parameters** and 1,000 training examples, HRM achieves near-perfect accuracy on complex Sudoku puzzles and optimal pathfinding in 30×30 mazes — where state-of-the-art CoT methods achieve **0% accuracy**. HRM outperforms o3-mini-high and Claude 3.7 on the ARC benchmark despite dramatically fewer parameters and a shorter context window.

27M parameters beating o3. No chain-of-thought. No pre-training at scale. Just two levels talking to each other — the board reader and the move calculator.

### Abstraction of Thought (AoT)

A structured reasoning format that explicitly incorporates multiple levels of abstraction — teaching AI to think at different levels rather than plowing through problems linearly. Demonstrates dramatic improvements in reasoning performance by forcing the model to operate at Level 3 before descending to Level 1.

### The common thread

All three architectures independently rediscovered what Go players evolved over centuries: **read the whole board first, calculate locally second.** The researchers probably never played Go — but they found the same truth.

---

## 10. The Ontology as Sandbox — and Its Limits

### The Ontology is a sandbox by design

Palantir's Ontology constrains the solution space before generation occurs. It forces AI systems to respect limits that matter outside the model. It is an explicit human-designed schema: entities, relationships, constraints, permissions.

The Ontology is deliberately a **sandbox**:
- AI reasons only within the defined context
- Focused on the variables provided
- Recommendations grounded in defined relationships
- Reasoning kept narrow, accurate, and aligned with the business

This is safe, explainable, and production-deployable. It is also, by definition, bounded by human knowledge.

### The Go parallel — exact and uncomfortable

```
Old Go AI:     humans encode joseki, tesuji, life/death
               → AI operates within human Go knowledge
               → ceiling = human understanding

AlphaGo:       no encoded knowledge
               → plays itself → discovers own ontology
               → finds Move 37 that humans never conceptualized

Palantir today: humans design Ontology
                → AI operates within human business knowledge
                → ceiling = human understanding of the domain

Emerging:      LLM reads domain → generates its own Ontology
               → humans review and approve
               → ceiling starts to lift
```

### Two types of Ontology

**Ontology Type A — implicit (inside the LLM)**
Every LLM already contains an implicit ontology learned from training. It knows that "patient" relates to "diagnosis" relates to "treatment." Nobody designed this — it emerged. This is AlphaGo's case.

**Ontology Type B — explicit (Palantir's)**
A human-designed formal schema. Reliable, governed, explainable. But bounded by what humans thought to encode.

### The Ontology is not a permanent requirement — it is a trust bridge

LLMs can now generate the Ontology automatically from documents — first generating Competency Questions to delineate knowledge scope, constructing the ontology schema, then populating it under schema supervision.

The trajectory:
```
Now:   AI operates inside human Ontology   → reliable, constrained
Next:  AI proposes expansions to Ontology  → supervised discovery
Later: AI rewrites the Ontology itself     → finds the bigger chess
                                             with human review as the
                                             last safety layer
```

The Ontology dissolves back into the implicit one the LLM already has — as trust is established through better calibration, verification, and interpretability.

---

## 11. Two-Phase Intelligence — The Deepest Frame

This is the insight that subsumes everything else in this report — and represents a genuine contribution to how we should think about AI reasoning architecture.

### What happens before the first reasoning token

The LLM's forward pass — before any chain-of-thought begins — is already doing everything the Go master does at Level 3 and Level 2:

```
Forward pass (weights, microseconds):
  → Pattern recognition across all training
  → Implicit Ontology activated
  → Bad branches pruned from probability space
  → "Whole board" read at embedding level
  → Top-K candidates surfaced to reasoning
  ↓
Only NOW does reasoning begin — on a tiny pruned space
```

### Phase 1 — Implicit (the weights)

| Property | Description |
|---|---|
| Mechanism | Weights, forward pass |
| Speed | Microseconds |
| Nature | Intuition, pattern, ontology, pruning |
| Transparency | Cannot be inspected, cannot be explained |
| Go equivalent | 50 years of board sense — just IS |
| AI safety view | The invisible phase — where real intelligence lives |
| Scaling approach | Training-time scaling, distillation |

### Phase 2 — Explicit (the reasoning tokens)

| Property | Description |
|---|---|
| Mechanism | Chain-of-thought, MCTS, token generation |
| Speed | Milliseconds to seconds |
| Nature | Calculation, verification, step-by-step |
| Transparency | Can be read, traced, audited |
| Go equivalent | Local sequence reading — invoked after board is read |
| AI safety view | The visible phase — where interpretability research works |
| Scaling approach | Test-time compute scaling |

### The critical implication

**The quality of reasoning is upper-bounded by the quality of the forward pass.**

If the weights did not learn the right "whole board" — if the implicit Ontology is wrong or incomplete — no amount of chain-of-thought tokens fixes it. You are searching deeper in the **wrong region of the tree.**

This is why:
- A 1B distilled specialist beats a 70B general model on narrow domains — its forward pass is calibrated to the right board
- AlphaGo found Move 37 — its policy network had no human bias pruning that branch before search began
- Palantir's Ontology intercepts **before** reasoning — it shapes what the forward pass sees, not what the reasoning computes

### The mapping to current AI architectures

```
AlphaGo policy network  ←→  LLM forward pass (Phase 1)
AlphaGo value network   ←→  PRM / confidence estimation
AlphaGo MCTS            ←→  Chain-of-thought / test-time compute (Phase 2)
Human expert intuition  ←→  Distilled specialist model's Phase 1
Whole board reading     ←→  Hierarchical Reasoning (HRM, HTP, AoT)
```

### The frontier nobody is stating clearly

The entire AI safety and interpretability field struggles because they can only see Phase 2. Phase 1 — where the real intelligence lives — is invisible inside the weights.

Better reasoning does not come from more thinking tokens. It comes from:
- Better training (better Phase 1 weights)
- Better distillation (calibrated Phase 1 for specific domains)
- Hierarchical architectures (HRM, HTP) that operate at Level 3 before Level 1
- A true meta-reasoning layer that knows when to stop — the real frontier

**The reasoning scaling law scales Phase 2 only. The real intelligence lives in Phase 1. Almost nobody is saying this clearly yet.**

---

## 12. Key Takeaways

### On test-time compute scaling
- Confirmed power-law relationship: more inference compute → better reasoning
- Holds **only** for verifiable, structured domains: math, code, formal logic
- Breaks for knowledge-intensive tasks — increases hallucination
- Current approach (o1/o3/DeepSeek-R1) scales **Level 1 tactical thinking only**
- 27M parameter HRM beats o3 on ARC by operating at Level 3 — suggests the frontier is hierarchical, not deeper tree search

### On bounded rationality
- Stopping is not a failure of reasoning — it IS the reasoning
- Meta-cognition (knowing when to stop) is more valuable than more search
- The Go master's stopping criterion is a **confidence threshold**, not a timer
- Current AI has no genuine meta-reasoning layer — budget forcing is an approximation
- True bounded rationality requires Phase 1 calibration, not Phase 2 extension

### On the whole board vs. the move tree
- Masters spend most time at Level 3 (strategic) and Level 2 (operational)
- Level 1 (tactical) calculation is brief, precise, and invoked last
- Current reasoning scaling inverts this — all compute goes to Level 1
- HyperTree Planning, HRM, and AoT are beginning to address Levels 2 and 3
- The real scaling opportunity is hierarchical reasoning, not deeper CoT

### On AlphaGo's lesson
- AlphaGo found a Level 3 that 3,000 years of human Go never mapped — because it had no human Ontology constraining its search
- The Ontology is a trust bridge, not a permanent architectural requirement
- As AI begins to write its own Ontology, the ceiling lifts
- The question for every domain: what is the "Move 37" hiding in your field?

### On two-phase intelligence
- Phase 1 (weights, implicit) = the whole board — where real intelligence lives
- Phase 2 (reasoning tokens, explicit) = the local sequence — what current scaling addresses
- Reasoning quality is upper-bounded by Phase 1 quality
- Better distillation, better training, and hierarchical architectures improve Phase 1
- More thinking tokens only improve Phase 2 — and only where verification is possible

### The synthesis
```
Training-time scaling   → improves Phase 1 (the board reading)
Test-time scaling       → improves Phase 2 (the sequence calculation)
Distillation            → compresses expert Phase 1 into a smaller model
Hierarchical reasoning  → makes Phase 1 / Phase 2 boundary explicit
Bounded rationality     → the meta-layer that manages the boundary
Ontology                → temporary scaffold until Phase 1 is trusted
```

Intelligence is not the deepest search. Intelligence is knowing **what not to search at all** — and knowing when what you have found is enough.

---

*Report compiled from technical conversation, March 2026.*  
*Insight thread initiated by a 50-year Go player observing that AlphaGo "looked at a much bigger chess" — a more precise description of hierarchical reasoning than most academic papers achieve.*