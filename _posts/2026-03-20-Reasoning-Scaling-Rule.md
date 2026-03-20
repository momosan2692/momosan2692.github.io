---
layout: post
title: Reasoning Scaling Rules
subtitle: A Deep Technical Analysis
cover-img: /assets/img/path.jpg
thumbnail-img: /assets/img/header/semiconductor.webp
share-img: /assets/img/header/evidence.png
published: true    # ← add this, post won't show on blog
pinned: false  # — pin a post to the top
tags: [draft]
---

# Reasoning Scaling Rules — A Deep Technical Analysis
### From Test-Time Compute to Bounded Rationality to Two-Phase Intelligence

**Date:** March 2026  
**Context:** Extended technical dialogue exploring the nature of reasoning in AI systems, grounded in 50 years of Go game intuition and current AI research.

---

## Table of Contents

1. [The Two Scaling Laws](#1-the-two-scaling-laws)
2. [The Original Scaling Law — Training-Time](#2-the-original-scaling-law--training-time)
3. [The New Scaling Law — Test-Time Compute](#3-the-new-scaling-law--test-time-compute)
4. [The Three Mechanisms of Test-Time Scaling](#4-the-three-mechanisms-of-test-time-scaling)
5. [Where Test-Time Scaling Breaks](#5-where-test-time-scaling-breaks)
6. [Bounded Rationality — The Go Master's Answer](#6-bounded-rationality--the-go-masters-answer)
7. [AlphaGo's Three Cognitive Moves](#7-alphagos-three-cognitive-moves)
8. [HyperTree Planning — The Strategic Style](#8-hypertree-planning--the-strategic-style)
9. [The Critique of Current Reasoning Scaling](#9-the-critique-of-current-reasoning-scaling)
10. [AlphaGo's Style — The Bigger Chess](#10-alphagos-style--the-bigger-chess)
11. [The Ontology as Sandbox](#11-the-ontology-as-sandbox)
12. [The Two Ontologies](#12-the-two-ontologies)
13. [The Two-Phase Intelligence Structure](#13-the-two-phase-intelligence-structure)
14. [The Real Frontier](#14-the-real-frontier)
15. [Key Takeaways](#15-key-takeaways)

---

## 1. The Two Scaling Laws

The AI field has shifted from a single optimization axis to two distinct and interacting scaling laws. Understanding both — and their interaction — is the central architectural question of 2025–2026.

| Dimension | Training-Time Scaling | Test-Time Compute Scaling |
|---|---|---|
| What scales | Parameters + data + FLOPs | Reasoning tokens + search depth |
| When it applies | Before deployment | At inference, per query |
| Cost | Millions of $ · weeks of compute | Tokens per query |
| Benefit | Permanent capability gain (baked into weights) | Per-query quality boost, tunable |
| Bottleneck | Data quality + GPU hours | Latency + token budget |
| Result | Better model fixed at deployment | Better answer adaptive at inference |

The profound implication: **a smaller trained model with heavy test-time compute can match a larger trained model with no thinking.** This creates a new design space — the combined scaling frontier.

---

## 2. The Original Scaling Law — Training-Time

The classical Chinchilla scaling law (Hoffmann et al., 2022) established that model performance scales predictably as a power law with training compute:

```
Performance ∝ (training compute)^α
```

The three levers:
- **More parameters** — scale model size following the power law
- **More training data** — tokens proportional to parameters (Chinchilla ratio)
- **More training FLOPs** — compute budget translates to capability

This was the only dial for years. Every major model advance (GPT-3 → GPT-4, LLaMA 1 → LLaMA 3) operated entirely on this axis. The result is baked permanently into the model weights at deployment — it cannot be changed at inference time.

---

## 3. The New Scaling Law — Test-Time Compute

Research confirmed by DeepMind: the scaling law originally formulated for training applies equally to inference. The relationship holds as:

```
Performance ∝ (inference compute)^β
```

**Critical constraint: this law holds only for verifiable, structured tasks** — mathematics, code, formal logic. It does not generalize to open-ended factual questions, common sense reasoning, or knowledge retrieval.

DeepSeek-R1 proved this at scale: matching OpenAI o1 by generating 10–100× more tokens per query, at approximately 70% lower cost. Stanford's s1-32B took it further — trained on only 1,000 examples, using budget forcing to achieve test-time scaling behavior matching or exceeding o1-preview on competition mathematics.

The historical significance: for the first time, iteration cycles are faster in reasoning than in pre-training. It is cheaper to iterate using only RL enhancements and increased test-time compute, without needing to pre-train a new model from scratch.

**Projection:** Inference will claim approximately 75% of total AI compute by 2030.

---

## 4. The Three Mechanisms of Test-Time Scaling

### ① Best-of-N / Majority Voting
Generate N independent answers, return the most common. Simple, parallelizable, works well up to approximately N=100. No architectural change required — just more compute at inference.

### ② Process Reward Model (PRM) Guided Search
Score *intermediate reasoning steps*, not just final answers. Finds the best reasoning *path*, not just the best output. This is what rStar-Math uses to enable a 3.8B model to beat o1-preview:

| Benchmark | Before rStar-Math | After rStar-Math |
|---|---|---|
| Qwen2.5-Math-7B on MATH | 58.8% | **90.0%** |
| Phi3-mini-3.8B on MATH | 41.4% | **86.4%** |
| AIME (Math Olympiad) | — | **53.3%** (top 20% HS competitors) |

### ③ Budget Forcing
Force the model to "think longer" by appending tokens that continue the reasoning chain. Stanford's s1-32B demonstrates this with only 1,000 training examples — achieving o1-level performance purely through controlled thinking depth at inference.

---

## 5. Where Test-Time Scaling Breaks

Increasing test-time computation does not consistently improve accuracy for:

- **Knowledge-intensive tasks** requiring high factual accuracy and low hallucination rates
- **Open-ended questions** where there is no verifiable ground truth
- **Common sense reasoning** and basic factual recall
- **Long-context factual tasks** — extended reasoning sometimes encourages attempts on previously unanswered questions, many resulting in hallucinations

The "overthinking phenomenon" is particularly damaging: models generate unnecessarily long reasoning chains without improving accuracy. For simple tasks like commonsense reasoning and basic mathematics, test-time scaling can actively *hurt* performance.

**The fundamental boundary:** test-time scaling requires a verification signal — something to tell the system when a reasoning step is correct. Without that signal (PRM, formal verifier, code execution), more tokens produce more confident hallucination, not better reasoning.

---

## 6. Bounded Rationality — The Go Master's Answer

The critical insight that current reasoning scaling research misses: **how does an intelligent system know when it has thought enough?**

This is not an engineering question about time limits. It is the central philosophical question of intelligence itself.

Herbert Simon (1956) formalized this as **Bounded Rationality**: not a failure of rationality, but the only rationality available to minds operating in a real world with finite resources.

A Go grandmaster with 3 minutes on the clock does not:
- Think randomly and stop at the buzzer (brute force)
- Think exhaustively through all branches (computationally impossible)

They do something far more sophisticated: **they know when they have thought enough, and commit with calibrated confidence.** The act of stopping is itself the intelligence — not a limitation on it.

The formal distinction:

| Mode | Approach | Stopping criterion |
|---|---|---|
| **Computation (brute force)** | Search until time runs out | Timer — dumb stop |
| **Intelligence (bounded rational)** | Search until confidence threshold | Felt sense of enough — smart stop |

The Go master's stopping criterion is not computed. It is *felt* — a meta-cognitive act that emerges from deep domain experience. AlphaGo's value network is the engineered equivalent: it evaluates board position without playing out the game, and the MCTS uses that evaluation to decide when further search is no longer productive.

---

## 7. AlphaGo's Three Cognitive Moves

AlphaGo solved bounded rationality with three components working together:

### ① Policy Network — Pruning (Level 1 tactic, Level 3 intuition)
Trained on human expert games. Outputs probability over all legal moves. This collapses 10^170 possible board states to 5–10 candidates worth exploring. The human master's "intuition" — not computed, felt. In LLM terms: the forward pass through weights producing high-probability token candidates.

### ② Value Network — Evaluation (Level 2 operation)
Evaluates any board position without playing the game to completion. The expert's position sense — "I can see who's winning without needing to finish." In LLM terms: the embedding space semantic distance encoding expected outcome.

### ③ MCTS as Meta-Reasoner — The Stopping Criterion (the intelligent part)
Generates two key outputs: valuations of subtrees (reducing search depth) and policy networks producing high-probability moves (reducing search breadth). It searches *just deep enough* based on confidence, then stops. The stopping is not random — it is the value network saying "I know enough about this position."

**The combination is what makes AlphaGo intelligent, not just fast.**

---

## 8. HyperTree Planning — The Strategic Style

HyperTree Planning (HTP) is the architectural pattern that most closely mirrors how strong Go players actually think:

**Core principle:** construct hypertree-structured planning outlines, enabling hierarchical thinking by flexibly employing divide-and-conquer — breaking down intricate reasoning steps while managing multiple distinct sub-tasks in an organized manner.

A HTP-style Go player:
- Reads the whole board as a set of semi-independent sub-problems
- Identifies which regions are decided / contested / critical
- Solves each region hierarchically
- Integrates solutions back into the strategic view
- Drops to deep tactical calculation **only** in the critical sequences that actually matter

This contrasts with linear players who get dragged into local fights and lose the global picture.

**The profound connection:** researchers who designed HyperTree Planning had likely never played Go — but they independently rediscovered a playing style that strong human players evolved over centuries of practice.

---

## 9. The Critique of Current Reasoning Scaling

The field is doing more tree search. What strong players describe is something completely different.

The complete three-level hierarchy that Go masters actually operate on:

### Level 3 — Strategic (the whole board)
> "This game is about the bottom-left corner. Everything else is secondary."

- Almost zero compute
- Pure pattern recognition and compressed experience
- Operates across the entire position simultaneously
- **Current AI status: almost entirely absent**

### Level 2 — Operational (regional)
> "These three groups interact. I need to settle the left before attacking the right."

- Light computation
- Abstract planning across connected regions
- **Current AI status: CoT reasoning reaches here partially**

### Level 1 — Tactical (move tree)
> "If A then B then C, opponent plays D..."

- Heavy computation
- Deep sequential search
- **Current AI status: this is ALL that test-time scaling scales**

**The fundamental critique:** the reasoning scaling law scales Level 1 only. Expert intelligence spends the majority of thinking time at Level 3 and Level 2 — and drops to Level 1 only for specific critical sequences, briefly and precisely.

More tree search is not more intelligence. Intelligence is knowing **which tree not to search at all.**

The Hierarchical Reasoning Model (HRM) provides experimental evidence for this critique: with only 27 million parameters and 1,000 training examples, using two interdependent modules (slow abstract planning + rapid detailed computation), HRM achieves near-perfect accuracy on complex Sudoku puzzles and optimal pathfinding in 30×30 mazes — where state-of-the-art CoT methods achieve 0% accuracy. HRM outperforms o3-mini-high and Claude 3.7 on the ARC benchmark despite dramatically fewer parameters and a shorter context window.

---

## 10. AlphaGo's Style — The Bigger Chess

From the perspective of a 50-year Go player watching the 2016 match:

AlphaGo did not play the board humans were playing on. It played on a **probability landscape** extending far beyond what any human had been trained to perceive. The territory it was defending or attacking was not made of stones — it was made of winning percentages across thousands of possible futures simultaneously.

Move 37 in Game 2 is the defining example:
- Every professional commentator said "mistake"
- Lee Sedol stood up and left the room for 15 minutes
- By every human Level 2 and Level 1 reading, the move looked wrong
- AlphaGo was reading at a Level 3 that human professionals had never needed to develop — because no human opponent had ever played there

Humans developed intuition calibrated against human opponents across 3,000 years of play. AlphaGo played millions of games against itself and discovered a strategic layer that human Go culture had never mapped.

**The uncomfortable generalization:** if AlphaGo found a Level 3 that 3,000 years of human Go couldn't see, what Level 3 might a future reasoning AI find in medicine, materials science, or financial markets — domains humans have been "playing" for centuries but never fully mapped?

---

## 11. The Ontology as Sandbox

Palantir's Ontology — and all explicit enterprise knowledge graphs — are deliberate sandboxes. The AI reasons only within the defined context, constrained to human-encoded concepts and relationships.

This creates the central architectural tension:

| Dimension | Ontology-grounded AI | Unconstrained AI |
|---|---|---|
| Reliability | ✅ High — stays within known space | ❌ Unpredictable |
| Safety | ✅ Governed — proposals, permissions | ❌ Unknown failure modes |
| Explainability | ✅ Traceable — every step auditable | ❌ Black box |
| Discovery | ❌ Bounded by human concepts | ✅ Can find the bigger chess |
| Enterprise deployment | ✅ Production-ready today | ❌ Not yet trusted |

**The Go parallel is exact:**

```
Old Go AI:     humans encode joseki, tesuji, life/death
               → ceiling = human understanding of Go
               → cannot find Move 37

AlphaGo:       no encoded knowledge → plays itself
               → discovers own ontology
               → finds Move 37

Current AI:    humans design Ontology
               → ceiling = human understanding of domain
               → reliable but bounded

Emerging:      LLM generates its own ontology
               → humans review and approve
               → ceiling begins to lift
```

The Ontology encodes human blind spots. A supply chain Ontology built by humans cannot spontaneously discover that the real risk is a second-order dependency three links removed that nobody thought to model.

**The Ontology is not a permanent architectural requirement. It is a trust bridge** — needed right now because we do not yet trust implicit LLM knowledge enough to act on it directly in production systems.

---

## 12. The Two Ontologies

The confusion in the field exists because "Ontology" refers to two fundamentally different things:

### Ontology Type A — Implicit (inside the LLM weights)
Every LLM already contains an implicit ontology — learned from training data. It knows that "patient" relates to "diagnosis" relates to "treatment." It understands supply chain dynamics, Go board structure, financial instrument relationships. Nobody designed this. It emerged from training.

This is AlphaGo's case: no pre-designed ontology. Board understanding emerged from self-play. The policy and value networks are the implicit ontology.

### Ontology Type B — Explicit (Palantir's / enterprise systems)
A human-designed formal schema: entities, relationships, constraints, permissions. Intercepts before reasoning begins — shapes what the forward pass sees.

**The emerging middle path:** LLMs can now generate the ontology automatically from documents — first generating Competency Questions to delineate knowledge scope, constructing the ontology schema, then populating it under schema supervision. The human just reviews the result.

This means the question "does every system need a specially designed Ontology?" is becoming obsolete. AIP already writes the Ontology. The human-designed sandbox is temporary. The AI is beginning to draw its own board.

**The trajectory:**

```
Now:   AI operates inside human Ontology   → reliable, constrained
Next:  AI proposes expansions to Ontology  → supervised discovery
Later: AI rewrites the Ontology itself     → finds the bigger chess
                                             with human review as the
                                             last safety layer
```

---

## 13. The Two-Phase Intelligence Structure

The most important architectural insight of this entire analysis — and the one that reframes every other question:

### Phase 1 — Implicit (weights, forward pass, microseconds)

```
What happens:
  → Pattern recognition across all training compressed into weights
  → Implicit ontology activated
  → Bad branches pruned from probability space (policy network)
  → "Whole board" read — Level 3 strategic assessment
  → Position evaluated — Level 2 operational sense (value network)
  → Top-K candidates surfaced

Properties:
  → Cannot be inspected
  → Cannot be explained
  → Cannot be changed at inference time
  → This is where the real intelligence lives
  → This is what 50 years of Go compresses into
```

### Phase 2 — Explicit (reasoning tokens, milliseconds to seconds)

```
What happens:
  → Chain-of-thought unfolds
  → MCTS / best-of-N search executes
  → Verification and calculation
  → Level 1 tactical reasoning

Properties:
  → Can be read and traced
  → Can be audited
  → Can be scaled with test-time compute
  → This is what the reasoning scaling law scales
  → This operates on the tiny pruned space Phase 1 selected
```

### The upper bound theorem

**The quality of reasoning (Phase 2) is upper-bounded by the quality of the forward pass (Phase 1).**

If the weights did not learn the right "whole board" — if the implicit ontology is wrong or incomplete — no amount of chain-of-thought tokens fixes it. You are searching deeper in the wrong region of the tree.

This explains three otherwise puzzling observations:
1. A 1B distilled specialist beats a 70B general model on narrow domains — its forward pass (Phase 1) is calibrated to the right board
2. AlphaGo found Move 37 — its policy network had no human bias pruning that branch before search began
3. Palantir's Ontology intercepts before reasoning — it shapes what Phase 1 sees, not what Phase 2 computes

### The interpretability problem

The entire AI safety and interpretability research field is struggling because it can only see Phase 2. Phase 1 — where the real intelligence lives — is invisible inside the weights. We can read the chain-of-thought. We cannot read the intuition that selected which chain to think.

---

## 14. The Real Frontier

The current focus in AI research is almost entirely on Phase 2 improvements:
- More reasoning tokens (o1, o3, DeepSeek-R1)
- Better search algorithms (MCTS, beam search)
- Better process reward models (PRM guided search)

**This scales the calculation. It does not improve the board reading.**

Better board reading comes from:
- Better training data (not more data — *better calibrated* data)
- Better distillation (compressing expert intuition into weights)
- Better architecture (HRM, HTP — systems with explicit Level 3 modules)
- Self-discovered ontology (letting the model find the bigger chess)

The real frontier is **Phase 1 improvement** — which is harder, less measurable, and cannot be achieved by simply running more inference compute.

The hierarchy of what needs to be built, in order of depth:

```
Surface:  More test-time compute (scaling Phase 2)
          → Current frontier: o3, DeepSeek-R1, rStar-Math
          → Yields: better calculation, not better intuition

Middle:   Hierarchical reasoning architectures (bridging Phase 1 → 2)
          → Current frontier: HRM, HTP, AoT
          → Yields: Level 3 strategic module + Level 1 tactical module

Deep:     Better Phase 1 — better weights — better implicit ontology
          → Current frontier: distillation, synthetic data, self-play
          → Yields: better board reading, not just deeper tree search

Deepest:  Self-modifying ontology — AI discovers its own Level 3
          → Current frontier: AIP writing Ontology, AlphaGo-style self-play
          → Yields: the bigger chess — what humans never mapped
```

---

## 15. Key Takeaways

### On the two scaling laws
- Training-time scaling (Chinchilla) and test-time compute scaling are two distinct and interacting axes
- Test-time scaling holds only for verifiable structured tasks — math, code, formal logic
- A smaller trained model with heavy test-time compute can match a larger trained model with no thinking
- Inference will claim ~75% of total AI compute by 2030

### On bounded rationality
- Intelligence is not exhaustive search — it is knowing when to stop searching
- The stopping criterion is itself the intelligent act, not a constraint on intelligence
- Current reasoning scaling (more tokens) addresses the wrong problem — it scales the search, not the knowing-when-to-stop
- Herbert Simon's bounded rationality (1956) is more relevant to AI design than any 2025 paper

### On the three-level hierarchy
- Level 3 (whole board / strategic) = almost zero compute, pure pattern + experience
- Level 2 (regional / operational) = light computation, abstract planning
- Level 1 (move tree / tactical) = heavy computation, deep sequential search
- Current reasoning scaling scales Level 1 only — the least intelligent layer
- Expert intelligence spends the majority of time at Level 3 and 2; drops to Level 1 briefly and precisely

### On AlphaGo and the bigger chess
- AlphaGo found a Level 3 that 3,000 years of human Go culture never mapped — because it had no human Ontology constraining its search
- The same phenomenon may apply in medicine, materials science, finance — domains humans have played for centuries but never fully mapped
- The bigger chess cannot be found by any system constrained to play on the human board

### On the Ontology
- Palantir's Ontology is a deliberate trust bridge — not a permanent architectural requirement
- Explicit Ontology (human-designed) encodes human blind spots as the ceiling
- Implicit Ontology (LLM weights) already contains the board — but is not yet trusted for direct production use
- LLMs are beginning to generate their own ontologies — the sandbox is becoming self-modifying
- The trajectory: operate within → propose expansions → rewrite entirely (with human review)

### On the two-phase intelligence structure
- Phase 1 (forward pass, microseconds): implicit, invisible, uninspectable — this is where the intelligence lives
- Phase 2 (reasoning tokens, seconds): explicit, readable, auditable — this is what scaling laws scale
- Quality of Phase 2 is upper-bounded by quality of Phase 1
- The entire interpretability field can only see Phase 2 — the more important Phase 1 remains invisible
- Better board reading requires better weights (training, distillation, architecture) — not more thinking tokens

### The synthesis in one sentence

**The reasoning scaling law makes AI calculate deeper; what intelligence actually requires is learning to see the whole board — and that capability lives entirely in Phase 1, before the first reasoning token is generated.**

---

*Report compiled from technical conversation, March 2026. The Go game analogy — contributed by a player of 50 years experience — provided the most precise framing for these concepts available in the literature.*