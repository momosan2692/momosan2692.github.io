---
layout: post
title: Space Data Centers
subtitle: From GTC 2026 to the Long Paradox
cover-img: /assets/img/path.jpg
thumbnail-img: /assets/img/header/semiconductor.webp
share-img: /assets/img/header/evidence.png
published: true
pinned: true
tags: [report]
---

# Space Data Centers — From GTC 2026 to the Long Paradox
### A Comprehensive Research Report
*Based on public information as of March 18, 2026*

---

## Table of Contents

1. [The Announcement — NVIDIA GTC 2026](#1-the-announcement)
2. [Hardware Stack — Three Platform Tiers](#2-hardware-stack)
3. [Partner Companies](#3-partner-companies)
4. [Launch Platforms — Beyond SpaceX](#4-launch-platforms)
5. [SpaceX's Own ODC Plan](#45-spacexs-own-odc-plan)
6. [SpaceX vs NVIDIA — Competitive Forecast](#46-spacex-vs-nvidia--competitive-forecast)
7. [Component Readiness — The Full Stack Audit](#5-component-readiness)
6. [Phased Launch Roadmap — Step by Step](#6-phased-launch-roadmap)
7. [The Disruption Question — Can Efficiency Kill ODCs?](#7-the-disruption-question)
8. [The Concluding Paradox](#8-the-concluding-paradox)

---

## 1. The Announcement

At GTC 2026 on March 16, Jensen Huang declared **"Space computing, the final frontier, has arrived."**

NVIDIA announced that its latest accelerated computing platforms are unlocking a new era of space innovation, bringing AI compute to **Orbital Data Centers (ODCs)**, geospatial intelligence, and autonomous space operations — enabling AI applications to run seamlessly from ground to space, and space to space.

> *"As we deploy satellite constellations and explore deeper into space, intelligence must live wherever data is generated. AI processing across space and ground systems enables real-time sensing, decision-making and autonomy."*
> — Jensen Huang, NVIDIA CEO

### Why Now?

The explosive growth of generative AI has decoupled the demand for compute from the capacity of local power grids. Goldman Sachs projects global data center power demand will rise **165% by 2030** vs. 2023 levels, growing from 4 GW to 123 GW in the US alone by 2035 — a thirtyfold increase. This terrestrial bottleneck is what's driving ODCs into space as a structural demand relief valve.

---

## 2. Hardware Stack — Three Platform Tiers

NVIDIA is deploying three purpose-built hardware platforms, each targeting a different constraint level:

### NVIDIA Space-1 Vera Rubin Module (Flagship)
- Delivers up to **25x more AI compute** vs. the H100 for space-based inferencing
- Tightly integrated CPU-GPU architecture with high-bandwidth interconnect
- Capable of running large language models and foundation models directly in orbit
- Enables on-orbit analytics, autonomous scientific discovery, and real-time insight generation

### NVIDIA IGX Thor
- Industrial-grade durability for mission-critical edge environments
- Supports real-time AI processing, functional safety, and secure boot
- Enables spacecraft to process sensor data locally and optimize bandwidth use
- Extends and complements ground control systems

### NVIDIA Jetson Orin
- Ultra-compact, energy-efficient module built for SWaP-constrained edge deployment
- High-performance AI inference in minimal form factor
- Optimized for satellite constellation-scale deployment

### Ground Processing (NVIDIA RTX PRO 6000 Blackwell)
- Up to **100x faster** than legacy CPU-based batch systems for geospatial intelligence
- High-throughput, on-demand ground processing for massive imagery archives

### The Key Engineering Challenge
Jensen himself acknowledged at GTC:

> *"There is no convection in space, only radiation. We must solve system cooling issues, and research toward that end is underway."*

---

## 3. Partner Companies

All six companies below are explicitly named in the NVIDIA official press release News Summary:
*"Aetherflux, Axiom Space, Kepler Communications, Planet Labs PBC, Sophia Space and Starcloud are using NVIDIA accelerated computing platforms to power next-generation space missions."*

| Company | NVIDIA Platform | Why Selected | Statement Source |
|---|---|---|---|
| **Aetherflux** | Space-1 Vera Rubin Module | The only company whose core business model is **solar-powered orbital AI compute** — directly showcasing Space-1's SWaP advantages and autonomous operation capability in the most power-constrained environment possible | CEO Baiju Bhatt — official statement in NVIDIA press release |
| **Axiom Space** | Not specified (named partner only) | Represents the **commercial space station** ecosystem entering the ODC landscape; Axiom is currently the only private company with an ISS commercial module license, signaling NVIDIA's intent to cover crewed orbital platforms | **No CEO quote** — listed by name only; no further public elaboration in the press release |
| **Kepler Communications** | Jetson Orin | Builds the **inter-satellite data relay network** that ODCs depend on for connectivity; Jetson Orin handles intelligent routing decisions onboard, validating NVIDIA's platform for constellation-scale network management beyond single-node inference | CEO Mina Mitry — official statement in NVIDIA press release |
| **Planet Labs PBC** | Full stack: Space-1 to RTX PRO 6000 | Daily global imaging generates the largest continuous Earth-observation dataset in existence — simultaneously demonstrating **ground-based GPU-accelerated processing** (RTX PRO 6000) and **orbital real-time inference**, with NVIDIA CorrDiff AI model integration | CEO Will Marshall — official statement in NVIDIA press release |
| **Sophia Space** | Jetson Orin | Specializes in **passively cooled hosted compute platforms** — directly addressing the orbital thermal management gap; its modular architecture is the most concrete evidence of Jetson Orin's positioning within strict SWaP constraints | CEO Rob DeMillo — official statement in NVIDIA press release |
| **Starcloud** | Not specified (full ODC stack) | The only company whose entire identity is the **dedicated orbital data center** — not satellite-attached compute as a secondary capability; serves as NVIDIA's flagship partner for the "orbital cloud infrastructure" narrative | CEO Philip Johnston — official statement in NVIDIA press release |

> **Note:** Axiom Space is the only partner without a CEO quote in the press release. The other five all have executive statements directly traceable to the same NVIDIA source document.

### Competitive / Adjacent Players

| Player | Country | Approach |
|---|---|---|
| **SpaceX / xAI** | USA | Vertically integrated (launch + ODC); merged Feb 2026 at $1.25T |
| **Google Project Suncatcher** | USA | Solar-powered TPU v6 satellites; direct hyperscaler entry |
| **OpenAI** | USA | Exploring rocket acquisition; no deal announced |
| **Lonestar Data Holdings** | USA | First commercial lunar data center |
| **ESA ASCEND** | EU | €300M funded; data sovereignty focus; demo 2026 |
| **ADA Space / Beijing Astro-Future** | China | 200,000-satellite constellation; state-coordinated |

---

## 4. Launch Platforms — Beyond SpaceX

### SpaceX — Dominant but Conflicted

SpaceX remains the primary launch provider for most ODC operators. However, following the **$1.25 trillion SpaceX/xAI merger in February 2026**, SpaceX is simultaneously a launch provider *and* a direct competitor building its own orbital data centers.

SpaceX filed with the FCC in January 2026 for approval to launch **1 million satellites** for space-based AI data centers — opposed by scientists citing orbital debris concerns.

Current pricing: **~$2,500/kg to LEO** on Falcon 9 (up from ~$6,000/kg to $7,000/kg after recent price increases).

### Rocket Lab — The Independent Alternative

Rocket Lab is strategically positioned as the non-SpaceX option, critical for ODC operators who don't want dependency on a competitor.

**Launch Complex 1 — Māhia Peninsula, New Zealand**
- First private spaceport to host a successful orbital launch
- FAA-licensed, up to **120 launch opportunities per year**
- Orbital inclinations from sun-synchronous through 30 degrees

**Current rocket — Electron**
- 150 kg to 500 km SSO
- Under $5M per launch
- Too small for meaningful ODC hardware at present

**Coming Q4 2026 — Neutron**
- **13,000 kg to LEO** (15,000 kg expendable)
- Designed to launch 98% of all payloads forecast through 2029
- Unique "Hungry Hippo" fairing for first-stage reuse
- First flight vehicle shipped to Wallops Island, Virginia Q1 2026
- 3 launches planned in 2026, 5 in 2027

| Site | Location | Rocket | Status |
|---|---|---|---|
| LC-1A / LC-1B | Māhia, New Zealand | Electron | ✅ Active |
| LC-2 | Wallops Island, Virginia | Electron | ✅ Active |
| LC-3 | Wallops Island, Virginia | Neutron | 🔜 Q4 2026 debut |

Even with Neutron at 13,000 kg, Rocket Lab is a **complementary player, not a Starship replacement** for large-scale ODCs. But for near-term individual compute node deployment, Neutron will be a competitive and politically neutral alternative to Falcon 9.

### The Cost Gap

Google's own feasibility study concluded costs must fall to **$200/kg** for ODCs to be competitive. The projection: this may only occur around **2035** if Starship scales to 180+ launches per year.

---

## 4.5 SpaceX's Own ODC Plan — and What It Means for NVIDIA

### The FCC Filing: 1 Million Satellites

On January 30–31, 2026, SpaceX submitted a filing to the FCC requesting authorization for up to **1 million compute-capable satellites** — a distributed orbital data center constellation designed to process AI workloads and harvest solar energy continuously.

The filing stated SpaceX would "operate a constellation of satellites with unprecedented computing power, enabling advanced AI models and their applications." Satellites would be deployed between **500 and 2,000 km altitude**, at inclinations ranging from 30 degrees to sun-synchronous orbit, with clusters separated by 50 km intervals targeting different workloads and latency requirements.

The stated technical target: **100 kW of compute per ton of satellite mass**. If SpaceX launches 1 million tons of satellites per year, this implies an annual addition of **100 GW** of orbital AI capacity.

### The Vertical Integration Strategy

SpaceX's plan is not simply an ODC business — it is a three-layer vertical stack:

| Layer | Asset | Function |
|---|---|---|
| **Launch** | Starship | Drives cost to LEO toward ~$10/kg at scale |
| **Connectivity** | Starlink V3 | Laser mesh network; 200 Gbps per sat today, 1 Tbps next-gen |
| **Compute** | xAI (merged Feb 2026) | AI workloads, training, inference; target: Tesla chip migration |

Musk's stated rationale: *"Global AI power demand simply cannot be met by ground-based solutions without enormous environmental cost."*

The data center satellites will connect through high-bandwidth optical links to Starlink, which relays back to ground stations via laser mesh. Each Starlink satellite already carries three lasers capable of 200 Gbps; the next generation targets 1 Tbps per node.

### Starship as the Economic Prerequisite

SpaceX explicitly stated that Starship full reusability is the precondition that makes this plan viable — not an assumption, but the foundation. SpaceX plans to launch **60 high-capacity Starlink V3 satellites per Starship flight**. At Starship's projected cadence, this is the only path to $200/kg or below.

Musk's own framing on the matter: *"Simply scale up the Starlink V3 satellites — they already have high-speed laser links. SpaceX will do this."*

### External Resistance

**Amazon (March 6, 2026)** formally objected to the FCC filing, calling SpaceX's application "purely speculative" and accusing it of attempting to "squat" on orbital slots between 500–2,000 km to block competitors from deploying their own satellites.

**Astronomers** raised concerns over light pollution and orbital debris at the unprecedented scale of 1 million satellites. Astronomer Peter Plavchan noted: *"Whoever can occupy the majority of available orbits around Earth first can effectively prevent others from deploying there — this is the ultimate land-grab in a regulatory vacuum."*

SpaceX also requested an exemption from FCC milestone requirements — which typically mandate that half the constellation be deployed within six years of authorization, and the full constellation within nine.

### The Civilization-Scale Framing

SpaceX's FCC filing contained a passage that defines its ambition beyond commercial terms:

> *"Launching 1 million orbital data center satellites is the first step toward a Type II Kardashev civilization — one capable of harnessing the full energy output of the Sun — while simultaneously powering the AI applications of billions of people today and securing humanity's multi-planetary future."*

This is not product positioning. It is a claim on infrastructure at civilizational scale — designed as much to set a regulatory and narrative precedent as to describe a technical roadmap.

---

## 4.6 SpaceX vs NVIDIA — Competitive Forecast

### The Core Tension

SpaceX/xAI today operates Colossus-1 — a supercomputing cluster of 200,000 H100/H200 GPUs and 30,000 GB200 units, all NVIDIA silicon. Colossus-2 plans to deploy over 1 million GB200/GB300 nodes. This makes xAI simultaneously **NVIDIA's largest customer class** and its most dangerous long-term orbital competitor.

The question is not whether SpaceX can out-engineer NVIDIA. The question is whether SpaceX can make NVIDIA's entire orbital partner ecosystem **structurally dependent** on SpaceX infrastructure — and whether it needs to win on chips at all to do so.

### Competition Across Three Distinct Layers

**Layer 1 — Chip Technology: NVIDIA's Dominant Ground**

SpaceX has no AI chip of its own today. The Tesla Dojo chip is designed for autonomous driving training, not general inference — adapting it for radiation-hardened orbital deployment would require a multi-year re-architecture program. Until then, SpaceX/xAI buys NVIDIA.

NVIDIA's Space-1 Vera Rubin Module delivers 25x the inference performance of an H100 in a space-grade SWaP-constrained form factor. No equivalent exists in the SpaceX portfolio. For the 2026–2028 window, SpaceX cannot realistically field a competing compute module for its ODC partners — it would need to use NVIDIA's own hardware.

*Forecast: SpaceX chip-layer threat — LOW for 3–5 years. Possible shift post-2028 if Tesla Dojo lineage adapts.*

**Layer 2 — Launch: SpaceX's Structural Chokehold**

Every company in NVIDIA's orbital partner ecosystem — Starcloud, Kepler, Aetherflux, Planet, Sophia Space — currently launches on SpaceX Falcon 9, or plans to launch on Starship. Rocket Lab Neutron (13,000 kg, Q4 2026) is the only near-term alternative, but at 13 tonnes versus Starship's 150+ tonnes, it is a supplement, not a substitute.

SpaceX does not need to match NVIDIA's chip performance to exert leverage. It only needs to prioritize its own satellite launches, raise prices for competitor payloads, or delay manifest slots. Regulatory frameworks do not currently require SpaceX to treat competitor payloads as common carriers.

*Forecast: SpaceX launch-layer structural advantage — VERY HIGH. No near-term resolution without regulatory intervention.*

**Layer 3 — Orbital Resource Allocation: The Silent Battle**

The FCC filing for 1 million satellites is best understood not as a product announcement, but as an **orbital slot reservation at unprecedented scale**. At 500–2,000 km altitude, spectrum and positional slots are finite. First-movers that secure ITU/FCC coordination effectively set the physical ceiling for what competitors can deploy.

If the FCC approves SpaceX's request — even partially — NVIDIA's partner ecosystem faces a future where the best orbital altitudes and radio frequency bands are already allocated before their larger clusters are ready to launch.

*Forecast: Orbital resource threat — HIGH and asymmetric. Amazon's FCC objection is the industry's best near-term countermeasure.*

### The Competitive Matrix

| Dimension | SpaceX / xAI | NVIDIA Ecosystem | Decisive Factor |
|---|---|---|---|
| AI chip technology | ❌ Behind; dependent on NVIDIA | ✅ Deep moat, Space-1 in class of its own | Tesla Dojo space adaptation (2028+) |
| Launch capability | ✅ Monopoly; Starship is generational | ❌ Entirely dependent on opponent | Rocket Lab Neutron scale-up (2027+) |
| Orbital slot control | ✅ FCC filing; 100M+ km² reserved | ❌ Reactive; waiting on regulators | FCC ruling + Amazon / ESA pushback |
| Ground compute ecosystem | 🟡 Massive but buys NVIDIA | ✅ Supplier position stable | xAI self-chip timeline |
| Partner openness | ❌ Closed vertical stack | ✅ Six independent partners; open platform | Whether partners stay independent |

### The Strategic Verdict

> **NVIDIA sells shovels to everyone mining the frontier. SpaceX mines the frontier itself — and owns the only road into the mine.**

NVIDIA's strongest position is its role as the neutral chip layer: regardless of which orbital operator wins, they all run NVIDIA hardware. This is the classic platform play — profit from the infrastructure race without picking a winner.

SpaceX's strategic threat is not technical superiority on chips. It is **infrastructure-layer capture**: control launch pricing, control orbital slot allocation, and the economics of every NVIDIA partner degrade — not because their technology failed, but because the road to orbit became too expensive or too congested to reach.

The outcome depends on two decisions neither company controls:

1. **How the FCC rules** on SpaceX's 1 million satellite application — and whether it imposes common-carrier or non-discrimination obligations on launch services.
2. **How fast Starship scales** — if it achieves 180+ flights per year and drives costs below $200/kg, it validates SpaceX's entire stack simultaneously and obsoletes the economics of every competing launch provider.

If both go SpaceX's way, NVIDIA wins the chip layer but loses leverage over the delivery layer. If regulators intervene and Starship timelines slip, NVIDIA's open ecosystem — with Rocket Lab as the independent alternative — has a genuine window to establish itself before the orbital land-grab closes.

---

## 5. Component Readiness — The Full Stack Audit

### ✅ Ready / Operational

**Wireless WAN / Inter-Satellite Links**
Kepler Communications selected TESAT's SCOT80 optical terminals for its ÆTHER constellation, delivering up to 2.5 Gbps per satellite with S-band always-on inter-satellite links plus Ku-band backhaul. The full Kepler constellation went live **March 16, 2026**, transitioning from data transport to cloud-native on-orbit AI processing.

**Ground Backhaul (RF + Optical Ground Stations)**
Proven multi-orbit relay using Kepler Ku-band and SES O3b mPOWER. Space-to-earth connectivity is mature for current scales.

**Orchestration Software**
Kepler's cloud-native ODC orchestration layer is operational. Starcloud-2 (Oct 2026) will deploy the first AWS Outposts hardware in space, routing data through Starlink, Amazon Kuiper, and Blue Origin TeraWave laser links.

### 🟡 Partial / Demo Stage

**Compute Hardware (GPU in orbit)**
Radiation hardening adds 30–50% to hardware costs and reduces performance by 20–30% versus terrestrial equivalents. Single nodes are flying (Starcloud-1 ran NanoGPT on Shakespeare in Nov 2025). Multi-node clusters in orbit remain unproven.

**Power / Solar Arrays**
Rocket Lab introduced silicon solar arrays in February 2026 — radiation-hardened, flexible, lightweight, designed for constellation-scale production. However, GW-scale solar infrastructure (requiring ~1 square mile per gigawatt at 30% efficiency) has not been deployed.

**Launch Economics**
Viable economics require: Starship launch costs below $100/kg, solar panel efficiency above 40%, and 5-year satellite lifespan in LEO radiation environments. None of these three conditions are currently met simultaneously.

### ❌ Critical Gaps

**Thermal Management — The #1 Unsolved Problem**
To dissipate 1 megawatt of heat while keeping electronics at 20°C, an ODC requires a radiator surface of approximately **1,200 square meters — roughly four tennis courts**. The ISS's full active thermal control system only rejects 70 kW across 422 m² of radiators. For MW-scale ODCs, this remains fundamentally unsolved.

The vacuum of space provides no convection — only radiation. Satellites experience temperature swings from 100K to 400K, requiring specialized components that cost roughly 1,000 times more than terrestrial counterparts.

**On-Orbit Robotic Assembly**
Starcloud's 5 GW Hypercluster concept requires 4km-wide solar and cooling arrays assembled autonomously in orbit using Rendezvous Robotics' electromagnetic tile-based system (derived from MIT's TESSERAE project). This system has not yet been tested in space.

Current satellites hosting computers are typically 300 kg or less — "the size of a mini-fridge." A true data center requires substantially more hardware than any single launch can deliver.

**Radiation Hardening at Scale**
Triple modular redundancy (running three identical systems in parallel) is required for reliable operation — tripling launch costs and capital expenditure. Radiation-hardened chips lag multiple generations behind leading chips in compute performance.

---

## 6. Phased Launch Roadmap — Step by Step

### Wave 1 — Proof of Concept (Nov–Dec 2025)
**What launched:** Starcloud-1 (60 kg, 1 kW solar, single NVIDIA H100), Axiom AxDCU-1 (ISS-hosted prototype)

**What was skipped:** Cooling at scale, GW-class power, robotic assembly, economic viability

**What was proven:** A GPU can run AI workloads in orbit. NanoGPT trained on Shakespeare — the first neural network trained in space.

### Wave 2 — Constellation Networking (Jan–Mar 2026)
**What launched:** Kepler ÆTHER 10-satellite optical relay constellation (Jan 11), Axiom ODC nodes, full Kepler constellation (Mar 16)

**What was skipped:** MW-class thermal, Starship launch economics, GW solar

**What was proven:** Space-to-ground AI workloads can be orchestrated in real time. Inter-satellite optical links at 200 Gbps are viable.

### Wave 3 — Multi-GPU + Cloud Integration (Oct 2026 – Q1 2027)
**Target launches:** Starcloud-2 (multi H100+Blackwell, AWS Outposts, Oct 2026), Aetherflux Galactic Brain (teraflop-class solar-powered node, Q1 2027)

**Still skipped:** MW-class cooling, km-scale assembly, Starship economics

**Target proofs:** Multi-GPU cluster operations, enterprise-grade cloud API in orbit, 30 satellites per Falcon 9 batch for solar power demo

### Wave 4 — Hyperscale / Starship Era (2028–2030)
**Target launches:** Starcloud 5 GW Hypercluster (4km solar+cooling array, robotic assembly), Aetherflux petaflop constellation

**Requires:** Starship full commercial reusability (~$100/kg), MW-class thermal solutions, robotic on-orbit assembly proven, Gartner cost threshold (~$200/kg) approaching

**Honest assessment:** BIS Research projects the in-orbit data center market reaching $1.77 billion in 2029 and $39.09 billion by 2035. Wave 4 economics depend entirely on Starship and thermal engineering breakthroughs that are not yet solved.

---

## 7. The Disruption Question — Can Efficiency Kill ODCs?

### Threats Assessed

| Disruption Vector | Threat Level | Why |
|---|---|---|
| Inference-only ASICs (Groq, Cerebras, TPU) | Medium | Fewer GPUs needed, but not fewer data centers |
| On-device AI (Apple A19, Qualcomm NPU) | Medium | Offloads simple inference only; complex reasoning stays cloud |
| Model compression (quantization, SLMs, MoE) | Low | Jevons Paradox: efficiency creates more total demand |
| Grid power breakthrough (SMR, fusion) | Low–Medium | Helps terrestrial DCs; doesn't eliminate space use case |
| Neuromorphic / analog AI (Loihi, NorthPole) | High IF mature | 1,000x efficiency claim; but post-2030 at earliest |
| Agentic AI + test-time compute scaling | Inverse — raises demand | More reasoning steps per query = exponentially more compute |

### The Jevons Paradox in AI

Every chip efficiency gain gets immediately consumed by new model capabilities or new applications. As inference becomes cheaper, more applications are built. As more applications are built, total compute consumption rises. This is the structural reason why efficiency improvements have historically *increased* data center demand rather than reducing it.

Deloitte predicts that even as inference-optimized chips become dramatically cheaper, the majority of computations will still be performed on cutting-edge, power-hungry AI chips in large data centers — because improvements in efficiency unlock entirely new use cases that create more demand, not less.

### On-Device AI Is Real but Bounded

Edge AI chips handle the *easy* part — tasks requiring sub-10ms response or operating with no connectivity. But the hard reasoning tasks — large model inference, multi-step agentic chains, foundation model training — stay centralized. Edge and cloud are complementary, not competitive.

### The One Genuine Wildcard

A single breakthrough architecture achieving 1,000x efficiency of brain-like sparse computation (neuromorphic/analog) would collapse demand for both terrestrial AND orbital data centers simultaneously. But this is a post-2030 scenario, and ODC Wave 1–3 launches happen well before then. And if it does occur, ODCs are the *last* to be hurt — terrestrial hyperscalers bear the disruption first.

---

## 8. The Concluding Paradox

The fundamental question — *"can efficiency improvements make space data centers unnecessary?"* — reveals a deeper structural paradox:

> **The better terrestrial AI gets, the more compute it demands.**
> **The more compute it demands, the stronger the case for space.**
> **The stronger the case for space, the more companies launch with unsolved problems.**
> **The more they launch with unsolved problems, the longer the roadmap gets.**

**It doesn't resolve. It compounds.**

Space data centers are not racing against time — they are racing against their own prerequisites. Every missing piece today (cooling, cheap launches, robotic assembly) is also the thing that justifies launching anyway, because the moment those problems are solved, the company that waited will be behind.

This is not a technology project. It is a **land grab dressed as an engineering roadmap.**

The companies launching now are not betting they've solved the hard problems. They are betting that **being in orbit first** is worth more than waiting to do it perfectly. And so far, the market is rewarding them for it.

---

## Key Data Points Summary

| Metric | Current | Required for viability |
|---|---|---|
| Launch cost to LEO | ~$2,500/kg (Falcon 9) | ~$200/kg |
| Radiator area for 1 MW cooling | ~1,200 m² | Must be launchable |
| Solar array area for 1 GW | ~1 sq mile | Must be assembled in orbit |
| GPU performance penalty (radiation) | -20–30% | Acceptable for early missions |
| Hardware cost premium (rad-hard) | +30–50% | Accepted as Wave 1–3 cost |
| Market size 2029 (BIS Research) | — | $1.77 billion |
| Market size 2035 (BIS Research) | — | $39.09 billion |
| CIOs with ODC in 3–5yr roadmap | <10% | — |

---

*Report compiled from NVIDIA GTC 2026 press releases, Kepler Communications, Starcloud, Aetherflux, Planet Labs, SpaceX FCC filings (Jan 2026), Amazon FCC objection (Mar 2026), Gartner, Deloitte, BIS Research, and public statements. All figures as of March 18, 2026.*


