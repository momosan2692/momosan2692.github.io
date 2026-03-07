---
layout: post
title: World Model From Video Generation to the Edge of AGI
subtitle: A Discussion Report — March 2026
cover-img: /assets/img/path.jpg
thumbnail-img: /assets/img/header/semiconductor.webp
share-img: /assets/img/header/evidence.png
published: true    # ← add this, post won't show on blog
pinned: true  # — pin a post to the top
tags: [report, draft]
---

# World Model: From Video Generation to the Edge of AGI
### A Discussion Report — March 2026

---

## 1. What Is a "World Model"?

A **world model** is an internal representation that an agent (human, animal, or AI) builds to understand, simulate, and predict how the world works — allowing it to reason about cause and effect, plan ahead, and make decisions *without* experiencing every situation directly.

Rather than reacting to inputs, an agent with a world model can:
- **Predict** what will happen next given an action
- **Plan** by simulating future states mentally before acting
- **Generalize** — applying learned structure to entirely new situations

The concept traces back to cognitive scientist Kenneth Craik (1943), who proposed that the brain constructs small-scale models of reality to anticipate events. In modern AI, it distinguishes an agent that *reacts* from one that genuinely *thinks ahead*.

---

## 2. Is Seedance 2.0 a World Model?

**ByteDance's Seedance 2.0** (February 2026) is an image-to-video and text-to-video model that adopts a unified multimodal audio-video joint generation architecture. While some describe it as entering the "world model era," the honest assessment is:

- ✅ Physics-aware video generation (collision weight, fabric tearing, realistic movement)
- ✅ Multi-shot story generation with transitions and pacing
- ❌ Not a true world model — no internal simulation, no causal reasoning engine
- ❌ It is a statistical pattern learner, not a physics simulator

**Analogy:** Seedance 2.0 is like a very talented cinematographer — it produces realistic-looking footage — but it isn't running an actual simulation underneath.

---

## 3. Next Frontiers Beyond Video Generation

The world model field is expanding rapidly into six major areas:

| Area | Key Development |
|---|---|
| **4D World (3D + Time)** | AR/VR spatial memory; Meta Orion glasses use case |
| **Robotics & Physical AI** | Training robots in simulated environments before real deployment |
| **Interactive Real-Time Simulation** | DeepMind Genie 3 — navigable 3D worlds at 24 FPS |
| **Video Games** | PitchBook projects $276B market by 2030 |
| **Autonomous Vehicles** | Simulating dangerous scenarios without real-world risk |
| **Healthcare & Science** | Simulating fluid dynamics, molecular behavior, surgical robots |

The progression:
```
LLMs (text) → Video generators (pixels) → 4D world models (space + time)
  → Interactive simulations (agents can act)
    → Embodied AI / Robots (physical world)
      → AGI?
```

---

## 4. Key Research Teams

### 🧠 AMI Labs — Yann LeCun
LeCun departed Meta in December 2025 after 12 years and launched **Advanced Machine Intelligence (AMI) Labs**, raising €500 million at a €3 billion valuation. Their core architecture — **I-JEPA (Image Joint Embedding Predictive Architecture)** — learns by predicting abstract representations of visual scenes without explicit labels.

### 🌐 World Labs — Fei-Fei Li
Founded by AI pioneer Fei-Fei Li, World Labs focuses on building spatially intelligent world models from images and prompts. Their product **Marble** is positioned as "the first step toward a truly spatially intelligent world model."

### 🤖 Google DeepMind — Genie Team
Released **Genie 3**, the first real-time interactive world model, generating persistent navigable 3D environments at 24 FPS. The model learns physics purely through observation.

### ⚡ NVIDIA — Cosmos Team
**Cosmos Predict 2.5** was trained on 200 million curated video clips and unifies text-to-world, image-to-world, and video-to-world generation for robotics and autonomous vehicle training. Downloaded over 2 million times by early 2026.

### 🤝 Boston Dynamics + Google DeepMind
Electric Atlas robots integrated with Gemini Robotics models — combining world model research directly with physical hardware.

### 🔬 Meta FAIR
Continues I-JEPA and V-JEPA lineage after LeCun's departure; V-JEPA 2 (January 2026) achieved 65–80% success on robotic pick-and-place tasks in novel environments with only 62 hours of robot training data.

---

## 5. Product-Ready Projects (2026)

| Product | Company | Status | Price | Best For |
|---|---|---|---|---|
| **Marble** | World Labs | ✅ Live | Free–$95/mo | Gaming, VFX, VR |
| **Cosmos** | NVIDIA | ✅ Live | Enterprise | Robotics, AutoDrive |
| **GWM-1** | Runway | ✅ Live | Subscription | Film, Creative |
| **SAM 3D** | Meta | ✅ Open | Free | AR/VR Developers |
| **Genie 3** | DeepMind | 🔬 Research Preview | — | Research |

---

## 6. Tesla FSD — How Close to a World Model?

Tesla FSD is arguably the **closest deployed approximation of a world model in the physical world today**, though not by theoretical elegance — by sheer scale.

- **FSD v12** deleted 300,000+ lines of rule-based code, replacing them with a single end-to-end neural network
- **FSD v14** adds reinforcement learning and reasoning — key ingredients of true world models
- By February 2026, Tesla vehicles had accumulated **8.3 billion FSD miles**
- In January 2026, Tesla launched **Robotaxi services in Austin** without a safety driver

Key gap: FSD currently lacks geographic generalization — it is US-centric and needs localization data for new markets.

| Feature | True World Model | Tesla FSD (2026) |
|---|---|---|
| Simulates future states | ✅ | ⚠️ Partial |
| Physical reasoning | ✅ | ⚠️ Learned patterns |
| Generalizes to new environments | ✅ | ❌ Needs localization |
| Operates unsupervised | ✅ | 🔄 Limited zones |

---

## 7. Hardware Requirements

### Training Scale
AI data center capex is projected to reach $400–450B globally in 2026, rising toward $1 trillion annually by 2028. A single 400,000-chip NVIDIA cluster costs approximately $17 billion.

### The Memory Bottleneck
Memory bandwidth is the decisive hardware limit for world models:

| Deployment | Memory Bandwidth |
|---|---|
| Mobile/Edge devices | 50–90 GB/s |
| Data center GPUs | 2–3 TB/s |
| **Gap** | **30–50x** |

### Second-Gen Inference Chips
- **Microsoft Maia 200** — 216GB HBM3e at 7 TB/s, 10+ petaFLOPS in FP4
- **NVIDIA Vera Rubin** — 3.6 exaFLOPS NVFP4, 10x token cost reduction vs. Blackwell
- **Tenstorrent (Jim Keller)** — inference-first, GDDR6 instead of HBM, open RISC-V architecture, sparsity-aware
- **AMD Helios** — rack-scale, HBM co-packaging, Q3 2026

### Cloud Dependency Timeline
```
2026–2027 (Gen 1–2):  Cloud-only for full world models
2028–2029 (Gen 3):    Hybrid — cloud reasons, edge acts
2030+     (Gen 4):    True edge world models viable
```

---

## 8. Jim Keller & Tenstorrent

Jim Keller — designer behind AMD Zen, Apple A4, and Tesla's Autopilot chip — became CEO of **Tenstorrent** in 2023. His thesis: the world needs cheap, fast, efficient inference everywhere, not more training giants.

- Raised **$700M Series D** at $2.6B valuation (Samsung, LG, Bezos Expeditions)
- Partnered with Japan's LSTC for a **2nm AI accelerator**
- Architecture avoids expensive HBM, uses GDDR6 + sparsity computation
- Perfectly positioned for edge/robotics world model inference

---

## 9. Do Second-Gen Inference Chips Meet World Model Needs?

**Verdict: Cloud yes. Edge, not yet.**

| Layer | Status |
|---|---|
| Datacenter video/3D inference | ✅ Ready today |
| Large model capacity (200GB+) | ✅ Handled |
| Edge robotics/vehicle inference | ⚠️ Power and bandwidth gap |
| Real-time interactive simulation | ❌ Needs purpose-built silicon |

---

## 10. Beyond LLMs — The Path to AGI

A 2025 AAAI report found **76% of AI researchers** believe scaling LLMs is "unlikely" or "very unlikely" to achieve AGI alone.

### Why LLMs Hit a Fundamental Wall
- They are next-token predictors — statistical correlations, not comprehension
- They fail basic physics benchmarks (IntPhys 2) that 3-year-old children pass easily
- They generate "near-random accuracy when distinguishing motion trajectories"

### The Two Camps

| Camp | Leaders | Approach |
|---|---|---|
| LLM can reach AGI | OpenAI, Anthropic, Meta (Zuckerberg) | GPT-5, o3, Claude reasoning |
| World Model needed | LeCun, Hassabis, Fei-Fei Li | JEPA, Genie, Marble, Cosmos |

### AGI Timeline Estimates
- Eric Schmidt: 3–5 years
- Elon Musk / Dario Amodei: ~2026
- Sam Altman: "a few thousand days" (~2035)

---

## 11. The 抽象概念 (Abstract Concept) Problem — The Deepest Gap

This is the **biggest unsolved problem** in world model research.

### What's Solved vs. What's Missing

```
✅ SOLVED:         Physical world (gravity, collision, motion)
✅ SOLVED:         Spatial world (3D, geometry, navigation)
⚠️ PARTIAL:        Causal reasoning ("because X, Y happened")
⚠️ PARTIAL:        Social behavior (basic human action prediction)
❌ UNSOLVED:       Moral / ethical concepts
❌ UNSOLVED:       Cultural context and social norms
❌ UNSOLVED:       Abstract metaphors ("the economy is cold")
❌ UNSOLVED:       Theory of Mind (A thinks B believes C doesn't know X)
❌ NOT ON ROADMAP: Philosophical / existential abstraction
```

### The Symbol Grounding Problem
Current world models reduce meaning symbolically from other symbols — never from genuine lived experience. Addressing this may require architectures where meaning *emerges* from ongoing interaction with the world, not pre-training on frozen datasets.

### What Is Being Attempted
- **Neuro-Symbolic Hybrids** — combining LLM generative power with symbolic knowledge graphs
- **Mental World Models** — modeling other agents' mental states (Theory of Mind)
- **Abstract World Model Theory** — grounding in category theory and causal graphs (largely theoretical)

---

## 12. The Big Picture Map

```
GPT Era (2020–2024)
  ✅ Language, reasoning, knowledge
  ❌ Physics, causality, planning, generalization

World Model Era (2025–2026, now)
  ✅ Physics, spatial reasoning, prediction
  ✅ Generalization to new environments
  ✅ Planning by simulating future states
  ❌ Abstract concepts, social norms, emotion

AGI (target — date unknown)
  = World Model
  + LLM reasoning
  + Persistent memory
  + Agency
  + Abstract concept grounding
  = "Street smarts" + "Book smarts" unified
```

---

## References

| # | Source |
|---|---|
| 1 | Ilya Sutskever — AAAI 2025 Keynote: "The Age of Research Returns" |
| 2 | DeepMind Blog — Genie 3 announcement, August 2025 |
| 3 | World Labs — Marble product launch, January 2026 |
| 4 | NVIDIA — Cosmos World Foundation Model technical report, January 2025 |
| 5 | ByteDance — Seedance 2.0 release notes, February 2026 |
| 6 | Tenstorrent — Series D funding announcement, 2024 |
| 7 | Yann LeCun — NVIDIA GTC keynote: "LLMs are too limiting," 2025 |
| 8 | Tesla — FSD v12 architecture blog post, 2024 |
| 9 | Tesla Robotaxi Austin launch coverage, January 2026 |
| 10 | AAAI 2025 Survey Report — "AI Researcher Views on AGI Scaling" |
| 11 | PitchBook — World Model Gaming Market Forecast 2030 |
| 12 | Demis Hassabis — CNBC Interview: "LLMs cannot unlock human-level intelligence alone," January 2026 |
| 13 | Axelera — Titania D-IMC Chiplet announcement, targeting 2028 |
| 14 | IntPhys 2 Benchmark Paper, ICCV 2025 |
| 15 | Meta — V-JEPA 2 research paper, January 2026 |
| 16 | AMI Labs — Launch announcement, €500M funding, December 2025 |
| 17 | Runway — GWM-1 World Model release, December 2025 |
| 18 | NVIDIA — Vera Rubin architecture brief, 2026 |
| 19 | Microsoft — Maia 200 inference chip specification, 2025 |
| 20 | SK Hynix — HBM4 technical specification, 2025 |

---

> ## 💡 Closing Thought
>
> The deepest unresolved question in world model research — abstract concept grounding — cannot be solved by scaling video data or improving chip bandwidth. It requires a fundamentally new paradigm: AI that learns meaning through *interaction*, not *observation*.
>
> Physical world models are tractable. Abstract understanding requires something closer to how humans develop meaning through lived experience, culture, and relationship.
>
> Until that is solved, the path from world model to AGI remains open — and the most honest answer to "when will we get there?" is simply:
>
> **"Give me the *pictures* about the future — I will give you the answer."**

---
*Report compiled: March 2026 | Based on research discussion across public AI announcements, technical papers, and industry analyses.*