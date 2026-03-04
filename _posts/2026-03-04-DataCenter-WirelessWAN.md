---
layout: post
title: Wireless WAN for AI Data Centers
subtitle: From Earth to Space
tags: [report, analysis,draft]
***



# Wireless WAN for AI Data Centers: From Earth to Space
### A Comprehensive Strategic & Technical Report
**Date:** March 2026 | **Classification:** Industry Analysis
**  Sample about Multiple Agent helper, comfirmed by men **
***

## Opening: The Network That Must Think

We stand at an inflection point in the history of computing. The rise of artificial intelligence has not only transformed what computers *do* — it has fundamentally changed what the networks connecting them must *become*.[1]

For decades, Wide Area Networks (WAN) were passive highways — moving data from point A to point B as cheaply and reliably as possible. Today, that model is obsolete. AI data centers demand networks that are intelligent, adaptive, power-aware, geographically strategic, and increasingly — orbital.[2]

This report traces the full arc of Wireless WAN evolution for AI infrastructure: from today's enterprise SD-WAN to gigawatt terrestrial campuses, distributed "Connected Bigs" architectures, and ultimately to the laser-linked satellite clusters now launching into low Earth orbit. The central question is no longer *"how fast is your connection?"* but **"how intelligently does your network manage compute, power, latency, security, and physics — simultaneously?"**[3][1]

The answer will define who controls AI in the 2030s.

***

## 1. Why AI Changes Everything About WAN

Traditional data center WAN was designed around predictable, asymmetric, north-south traffic — users pulling data from servers. AI infrastructure inverts this model entirely.[1]

| Dimension | Traditional DC WAN | AI DC WAN |
|---|---|---|
| **Traffic Pattern** | North-South (user ↔ server) | East-West (GPU ↔ GPU) [2] |
| **Bandwidth** | 10–100G | 800G → 1.6 Tbps [4] |
| **Latency Priority** | Best effort | Mission critical [1] |
| **Traffic Shape** | Predictable, steady | Bursty, unpredictable [5] |
| **Growth Rate** | 20–30% CAGR | 100%+ CAGR [5] |
| **Primary Driver** | Cost | GPU utilization [2] |

AI model training requires chips to constantly synchronize parameters — every millisecond of network delay wastes expensive GPU cycles. AI inference requires responses delivered to users in real time — every millisecond of WAN latency degrades user experience. The network is no longer infrastructure. **It is the AI.**[1]

***

## 2. Wireless WAN Solutions — The Technology Stack

### 2.1 SD-WAN (Software-Defined WAN)
The foundation layer for AI DC connectivity. Modern AI-native SD-WAN goes far beyond traditional path selection.[1]

- **VeloRAIN (Broadcom):** *未確認產品名，可能內部代號* ML-based prediction of network conditions, bonding 5G + satellite links for generative AI traffic **(Not Firmed)**
- **Arista + VeloCloud:** Any-to-any bidirectional architecture for agentic AI across cloud, edge, and branch[1]
- **Cisco Catalyst SD-WAN:** Cloud OnRamp automation with direct secure connections to GPU-as-a-Service (GPUaaS) offerings[1]
- **Palo Alto Prisma:** Zero-trust integrated SD-WAN with inline AI security[1]

### 2.2 5G Private Networks & FWA
5G is the access layer connecting inference zones to end users.[6]
- Ultra-low latency: ~1ms radio access[6]
- Network slicing for AI traffic prioritization[6]
- Fixed Wireless Access (FWA) as primary or backup inter-DC links[6]
- CBRS (3.5 GHz) for private campus data center networks[6]

### 2.3 Optical Wavelength Services (DWDM)
The high-speed backbone for inter-DC AI traffic.[4]
- 800G wavelengths rolling out widely in 2025 → 1.6 Tbps by 2026[7]
- 40–60% CAGR in DCI bandwidth demand — 6× growth expected in 5 years[5]
- Ciena WaveLogic 6 Extreme: 1.6T Coherent-Lite with quantum-safe encryption built in[7]

### 2.4 Microwave / Free-Space Optical (FSO)
Point-to-point wireless for campus and building-to-building connectivity.[8]
- Microwave: up to 10 Gbps, <5ms latency, Ericsson MINI-LINK / Cambium Networks[8]
- FSO (laser): up to 10 Gbps, <1ms latency, line-of-sight required[8]
- Weather-sensitive but zero spectrum licensing required[8]

### 2.5 LEO Satellite (Starlink / OneWeb)
Emerging WAN option for remote and disaster-recovery AI sites.[3]
- Starlink Business: 50–500 Mbps, 20–40ms latency[3]
- Telesat Lightspeed (2026): optical ISL mesh with SDN-based autonomous routing[3]

***

## 3. WAN Specs by AI Workload State

### 3.1 Model Training Phase
Training is **bandwidth-first, latency-tolerant, east-west dominant.**[2]

| Spec | Requirement |
|---|---|
| **Bandwidth (WAN)** | 800 Gbps → 1.6 Tbps per DCI link [4] |
| **WAN Latency** | 10–50ms acceptable [2] |
| **Intra-cluster Latency** | Sub-microsecond (InfiniBand / RoCEv2) [2] |
| **Packet Loss** | Zero — any loss stalls GPU cluster [2] |
| **Traffic Pattern** | East-West GPU parameter synchronization [1] |
| **DCI Growth** | 40–60% CAGR — 6× in 5 years [5] |

Training workloads require chips to be physically co-located. GPU clusters must synchronize model parameters constantly — making high-bandwidth, lossless intra-cluster fabric (InfiniBand or 800GbE Ethernet) the primary engineering challenge, with WAN handling inter-DC checkpoint transfer and dataset movement.[2]

### 3.2 Inference Phase
Inference is **latency-first, geographically distributed, north-south dominant.**[1]

| Spec | Requirement |
|---|---|
| **WAN Latency** | <20ms regional / <5ms real-time AI [1] |
| **Bandwidth per Edge Node** | 10–400G [5] |
| **Traffic Pattern** | North-South (user-facing) [1] |
| **Topology** | Geo-distributed inference zones [1] |
| **Scaling** | Nonlinear, demand-driven, spiky [5] |
| **Growth Forecast** | *~200-300% of training by 2027 (調整自400%)* [5] **(Not Firmed: 原400%過高)** |

Inference must happen close to users — inside metro "Inference Zones" reachable via 5G in <3ms. By 2027, inference demand is projected to significantly exceed training workloads, driven by AI copilots, real-time multimodal interfaces, and personalization engines across healthcare, fintech, and e-commerce.[5][1]

> **Key Principle: Training = Bandwidth wins. Inference = Latency wins.**

***

## 4. Security Requirements

### 4.1 Why AI DC Security is Different
AI data centers represent an unprecedented concentration of value — model weights, training data, and proprietary algorithms — making them targets for nation-state-level threats. Traditional perimeter security is insufficient.[1]

### 4.2 Training Phase Security
| Requirement | Detail |
|---|---|
| **Zero-Trust East-West** | Every GPU-to-GPU flow authenticated [1] |
| **Quantum-Safe Encryption** | WaveLogic 6E / Nokia 800G pluggable optics [7] |
| **Supply Chain Security** | GPU, NIC, DPU, switch firmware verified [1] |
| **Checkpoint Integrity** | Cryptographic signing to detect poisoning [1] |
| **Management Plane Isolation** | BMCs, orchestration, firmware hardened [1] |

### 4.3 Inference Phase Security
| Requirement | Detail |
|---|---|
| **Rate Limiting** | Stops API brute-force and model inversion [1] |
| **Adversarial Input Filtering** | WAN-edge preprocessing of malicious prompts [1] |
| **mTLS / API Gateway** | Mutual authentication for all inference endpoints [1] |
| **Runtime Behavioral Monitoring** | Detect anomalous inference patterns in real time [1] |
| **DDoS Protection** | Inference endpoints are public-facing and high-value [1] |

### 4.4 Critical Security Gap
The most commonly used security standards were **not designed to secure AI training infrastructure.** Frontier labs are improvising bespoke controls without a consistent, proven framework — meaning most AI data centers today are under-secured relative to their threat profile. The EU AI Act and NIST SP 800-53 are beginning to address this, but standardization lags behind deployment.[1]

***

## 5. Power & Electricity — The Existential Constraint

### 5.1 The Scale Problem

| Year | Global DC Power Demand |
|---|---|
| 2024 | 460 TWh [9] |
| 2030 | ~800-1,000 TWh **(Not Firmed: 原>1,000高估)** [9] |
| 2035 | ~1,000-1,200 TWh **(Not Firmed: 原>1,300過高)** [9] |

Inference power demand alone is projected to grow rapidly through 2028. Modern AI GPUs consume 700–1,200W per chip vs. 150–200W for traditional CPUs.[9]

### 5.2 Power Source Strategy by Company

| Company | Strategy | Commitment |
|---|---|---|
| **Microsoft** | Three Mile Island nuclear restart | 835 MW, 20-year deal with Constellation [10][11] |
| **Meta** | Nuclear + Hyperion campus | 2 GW Louisiana DC (scaling to 5 GW) [12][13] |
| **Google** | SMR + TPU orbital solar | Kairos 500 MW SMR by 2030 + Project Suncatcher [14] |
| **Amazon** | SMR + Virginia grid | MOU with Dominion for SMR development [9] |
| **xAI** | Own power plant (Memphis) | Gas turbines + substations, operational [15] |
| **All major players** | White House Power Pact | *March 4, 2026: "Build, bring, or buy" own electricity* **(Not Firmed: 報導提及但非官方確認)** [16] |

### 5.3 The Grid Timeline Problem
```
AI DC Construction:        1–2 years
Grid Interconnection:      4–8 years
Transmission Line Build:  ~10 years
Nuclear SMR Build:         5–10 years
⚠️ AI buildout is 5–8× faster than the grid can respond [web:9]
```

***

## 6. Can WAN Solve the Power Problem?

### 6.1 WAN as Power Load Balancer
WAN can act as a **spatial and temporal power manager** — routing workloads to where clean energy is abundant rather than moving power to where compute is fixed.[2]

- **Spatial flexibility:** Route training batches to Texas solar surplus, Iceland geothermal, or Norway hydro[2]
- **Temporal flexibility:** Defer non-urgent training during peak grid hours[2]
- **Geographic arbitrage:** Shift inference to low-carbon regions without user-facing latency impact[2]

### 6.2 What WAN Can and Cannot Do

| WAN CAN ✅ | WAN CANNOT ❌ |
|---|---|
| Route training to cheap/clean power | Fix real-time inference latency over long WAN [2] |
| Distribute inference to reduce grid stress | Eliminate local grid stress at training sites [2] |
| Enable temporal workload shifting | Reduce WAN's own power consumption [2] |
| Enable geographic power arbitrage for batch | Solve data sovereignty when crossing borders [2] |

### 6.3 WAN Side Effects
- **Latency penalty:** Geographic routing adds 10–50ms — unacceptable for real-time inference[1]
- **Bandwidth explosion:** Distributed compute requires 800G–1.6T WAN links at massive scale[4]
- **Power consumed BY WAN:** Optical amplifiers, routers, and switches add significant load[7]
- **Data sovereignty:** Moving workloads across borders may violate GDPR, EU AI Act, or data residency laws[1]
- **Security exposure:** Every WAN hop is an attack surface[1]

***

## 7. Super-Big vs. Connected Bigs

### 7.1 The Gigawatt Monster (Super-Big)
Real facilities under construction now.[9]

| Facility | Owner | Power | Scale |
|---|---|---|---|
| **Stargate I** | OpenAI/Oracle | ~1.2 GW | *400k+ GB200 GPUs (Abilene, TX)* **(Not Firmed: 確有計畫但GPU數/功率細節推測)** [17] |
| **Hyperion** | Meta | 2 GW → 5 GW | $10B+, 2,250 acres, Louisiana [12][13] |
| **Prometheus** | Meta | 1 GW | Ohio supercluster, 2026 [12] |
| **Colossus 2** | xAI | ~1.4 GW equiv | Largest single facility 2026 [15][17] |
| **Stargate Total** | OpenAI/Oracle/SoftBank | Up to 10 GW | *$500B, multi-state* [17] |

### 7.2 Connected Bigs (Federated Architecture)
Microsoft's global network represents the clearest "Connected Bigs" model.[9]
- 70+ Azure regions, 400+ data centers globally[9]
- 120,000 miles of dedicated fiber on AI WAN[9]
- Treating the entire network as one distributed AI supercomputer[9]

### 7.3 The Right Architecture by Workload

| Workload | Winning Model | Reason |
|---|---|---|
| LLM Training | Super-Big | Chips must be physically co-located [2] |
| Fine-tuning | Connected Bigs | Moderate scale, flexible placement [2] |
| Inference | Connected Bigs | Must be near users [1] |
| Agentic AI | Connected Bigs | Multi-region, real-time [1] |
| Sovereign AI | Connected Bigs | Data must stay in-country [1] |

> **The ultimate architecture:** Super-Big training cores + Connected Bigs inference edges, all stitched together by 800G–1.6T WAN fabric.[4]

***

## 8. Space Data Centers — The Final Frontier

### 8.1 Why Space Solves the Power Problem
```
EARTH PROBLEM                  SPACE SOLUTION
────────────────────           ──────────────────────────
Power grid crisis         →    Unlimited free solar 24/7 [web:8]
Water cooling scarce      →    Deep space infinite heat sink [web:8]
Land scarcity/cost        →    Orbit is borderless & free [web:8]
Data sovereignty limits   →    Orbital jurisdiction is new [web:8]
```

### 8.2 The Players Racing to Orbit

| Company | Project | Status |
|---|---|---|
| **SpaceX + xAI** | 1M satellite megaconstellation | *FCC filed, Feb 2026* **(Not Firmed: 計畫階段，非即時部署)** [18] |
| **Google** | Project Suncatcher (TPUs in orbit) | *Research, radiation tests passed; 81-sat cluster concept (非2 spacecraft 2027)* **(Not Firmed: 早期階段)** [14] |
| **Starcloud** | 88,000-satellite orbital DC | FCC filed Feb 2026 **(確認申請，但第一LLM 2025不可能)** [18] |
| **Axiom Space** | AxDCU-1 + ODC nodes | *Live on ISS, nodes proposed (非2 launched Jan 2026)* **(Not Firmed)** [3] |
| **China** | Three-Body Computing (2,800 satellites) | *計畫存在，首批發射但規模未達* **(Not Firmed)** [3] |

### 8.3 Wireless WAN for Space — The Technology Stack

In space, **there is no fiber. Everything is wireless WAN.**[3]

#### Three-Layer Space WAN Architecture

| Layer | Link Type | Technology | Speed | Latency |
|---|---|---|---|---|
| **Layer 1** | Intra-cluster (formation) | Free-Space Optical (FSO) | 1–400 Tbps | Sub-ms [3] |
| **Layer 2** | Inter-orbit (cluster to cluster) | Optical ISL / Laser | 400G–1.6T | 1–10ms [3] |
| **Layer 3** | Space-to-Ground | Optical + Ka-band RF hybrid | 2.5–100 Gbps | 20–40ms [3] |

#### Key Technologies
- **Optical Inter-Satellite Links (OISLs):** The backbone of space WAN — Axiom Space nodes already operate 2.5 Gbps-capable OISLs meeting SDA Tranche 1 standards[3]
- **Formation Flying + Close-Proximity Optics:** Google Suncatcher's 81-satellite cluster flying within 1 km radius to maximize optical link bandwidth[14]
- **Delay Tolerant Network (DTN):** Lonestar Data Holdings tested Solar System Internet on a lunar mission in August 2025 — extending WAN beyond Earth orbit[3]
- **China Laser Starcom:** 400 Gbps laser link demonstrated in LEO[3]

### 8.4 Space WAN Unique Challenges

| Challenge | Why It's Unique | Mitigation |
|---|---|---|
| **Pointing & Tracking** | Satellites move at 7.8 km/s | ML-based precision pointing [3] |
| **Doppler Shift** | Relative motion shifts laser frequency | Adaptive optics compensation [3] |
| **Radiation Bit-Flips** | Cosmic rays corrupt data | Advanced ECC codes [14] |
| **Atmospheric Turbulence** | Ground links pass through weather | Multi-aperture receivers [3] |
| **Kessler Syndrome** | 1M satellites could make orbit unusable | International coordination needed [18] |
| **5-Year Lifespan** | Satellites degrade in radiation | Replacement constellation planning [14] |

### 8.5 The Economics of Space vs. Earth

| Factor | Terrestrial 1 GW DC | Orbital 1 GW DC | Break-Even |
|---|---|---|---|
| **Build Cost** | ~$16 billion | ~$50 billion | *2032–2035 (推測，視發射成本降至$200/kg)* **(Not Firmed)** [14] |
| **Power Cost** | $60–100/MWh | ~$0 (solar) | Already better [3] |
| **Cooling Cost** | Significant (water) | $0 (vacuum) | Already better [3] |
| **Land Cost** | $50–500M/site | $0 | Already better [3] |
| **CO₂ Savings** | Baseline | 10× better (post-launch) | Already better [18] |

***

## 9. The Players, the Users, and the Money

### 9.1 Hyperscaler Capex 2026

| Company | 2026 Capex | YoY Growth |
|---|---|---|
| **Amazon** | *$~75B (AI重點)* **(Not Firmed: 報告$200B高估)** [19] |
| **Google** | *$~50-60B* **(Not Firmed: $175B高估)** [19] |
| **Meta** | $115–135B **(Not Firmed: 高端可能)** [19] |
| **Microsoft** | *$~80-100B* **(Not Firmed: $99B合理範圍)** [19] |
| **Oracle** | *$~40-80B* **(Not Firmed: 快速成長)** [17][19] |
| **TOTAL** | **~$500-600B** **(Not Firmed: 原660-690B略高)** [19] |

### 9.2 The Biggest Deals

- **OpenAI + Oracle:** *$~40B Nvidia chips for Stargate (非$300B總額)* **(Not Firmed: 規模確認但金額細節推測)**[17]
- **OpenAI + AWS:** $38B deal, November 2025 **(Not Firmed)**
- **Google + Anthropic:** 1 million TPUs + 1 gigawatt of AI compute by 2026 **(方向正確，細節未全確認)**
- **Meta + Constellation:** 1.1 GW nuclear power, 20-year deal **(Not Firmed: Meta核能計畫存在但非此合約)**
- **Stargate Project:** $500B total, OpenAI + SoftBank + Oracle joint venture[17]
- **Microsoft + Anthropic:** $5B investment, Claude committed to $30B Azure compute **(投資確認，commit未詳)**

***

## 10. The Evolution Timeline

```
2024  ──────────────────────────────────────────────────── 2035+
 │                                                              │
 │  TERRESTRIAL      DISTRIBUTED     EDGE           ORBITAL    │
 │  Gigawatt DCs     Connected Bigs  Inference Zones Space DCs  │
 │  Training         Train+Infer     Real-time AI   All tasks  │
 │  800G WAN         1.6T WAN        5G / SD-WAN    FSO/Laser  │
 │  Nuclear power    Renewable mesh  Grid-edge       Solar/∞   │
 │  (Today)          (2025–2026)     (2026–2027)    *(2030+調整)* **(Not Firmed: 太空時程過早)** [web:8][web:16]
```

***

## Closing: The Network IS the AI

What began as a question about wireless WAN solutions for data centers has led us to one of the most profound infrastructure transformations in human history. The story told in this report is not simply about faster networks or bigger buildings — it is about the physical manifestation of artificial intelligence itself.[1]

Several fundamental truths have emerged:

**1. The Network and the AI are Inseparable.** GPU clusters cannot function without sub-microsecond interconnects. Inference cannot serve users without sub-20ms WAN. Distributed training cannot scale without lossless 800G links. The boundary between "compute" and "network" has dissolved.[2][1]

**2. Power is the Master Constraint.** Every architectural decision — Super-Big vs. Connected Bigs, centralized vs. distributed, terrestrial vs. orbital — ultimately traces back to power availability. The companies that control clean, abundant, always-on power will control AI compute.[9]

**3. Space is Not the Future — It is the Present.** Orbital data centers are no longer theoretical. *They are in early testing.* The race between American commercial players (SpaceX, Google, Starcloud, Axiom) and Chinese state programs (Three-Body Computing) for orbital AI compute supremacy is underway.[18][14][3]

**4. Security has Not Kept Up.** The most critical infrastructure in human economic history is being built without agreed security standards. Nation-state actors are already targeting model weights, training runs, and inference APIs. This gap must close before the infrastructure scales further.[1]

**5. WAN is the Intelligence Layer.** The wireless WAN connecting all of this — from terrestrial SD-WAN to orbital optical ISLs — is not a passive pipe. It is becoming an active, AI-driven routing intelligence that balances compute, power, latency, security, cost, and carbon simultaneously. The WAN must be as smart as the AI it carries.[3][1]

The data center of 2030 will not be a building. It will not be a campus. It will be a **planetary-scale distributed computer** — training models in gigawatt ground clusters, running inference in metropolitan edge zones, and executing agentic AI workloads on laser-linked satellite clusters in low Earth orbit — all connected by a wireless WAN fabric that spans from the ground to the stars.[3]

The question for every organization, government, and nation is no longer *"do we need AI infrastructure?"* It is: **"Are we building the right network to carry civilization's most powerful technology — safely, sustainably, and at the speed the future demands?"**

***

*Report compiled March 4, 2026. Sources: Fortinet, Arista, Cisco, Equinix, Ciena, Nokia, Microsoft, Google, Meta, Amazon, OpenAI, Axiom Space, Starcloud, SpaceX/xAI, Goldman Sachs AI Infrastructure Analysis, Gartner SD-WAN Magic Quadrant 2025 [-20]. **Not Firmed items marked in italics with footer remarks.** *[10][12][15][14][18][17][9][3]

來源
[1] Five Emerging WAN Trends for the AI Era - Cisco ThousandEyes https://www.thousandeyes.com/blog/five-emerging-wan-trends-ai-era
[2] [PDF] When Wires Can't Keep Up: Reconfigurable AI Data Centers ... - arXiv https://www.arxiv.org/pdf/2512.24110v2.pdf
[3] The next great space race: Building data centers in orbit https://news.northeastern.edu/2026/01/06/ai-data-centers-in-space/
[4] How AI Data Centers Are Quietly Rewriting Enterprise Fiber ... https://www.fiberquotes.com/how-ai-data-centers-are-quietly-rewriting-enterprise-fiber-design-in-2026/
[5] AI's Impact on Wide Area Networking - Omdia - Informa https://omdia.tech.informa.com/-/media/tech/omdia/marketing/commissioned-research/pdfs/ais-impact-on-wide-area-networking-v3.pdf?rev=c90ff02e0c1e4fad90a7ed2a8524a4a3
[6] Hpe Juniper Networking Wired... https://www.hpe.com/us/en/networking/wired-wireless-wan.html
[7] [PDF] Sustainable WAN Transformation for the AI Era | Juniper Networks https://www.juniper.net/content/dam/www/assets/white-papers/us/en/sustainable-wan-transformation-for-the-ai-era.pdf
[8] Future-Proofing Data Center Networking in the Era of AI https://www.datacenterfrontier.com/special-reports/whitepaper/55313253/commscope-future-proofing-data-center-networking-in-the-era-of-ai
[9] 2026 Predictions: AI Sparks Data Center Power Revolution https://www.datacenterknowledge.com/operations-and-management/2026-predictions-ai-sparks-data-center-power-revolution
[10] Three Mile Island nuclear power plant to return as Microsoft signs 20 ... https://www.datacenterdynamics.com/en/news/three-mile-island-nuclear-power-plant-to-return-as-microsoft-signs-20-year-835mw-ai-data-center-ppa/
[11] Three Mile Island nuclear power plant will reopen for Microsoft - NPR https://www.npr.org/2024/09/20/nx-s1-5120581/three-mile-island-nuclear-power-plant-microsoft-ai
[12] Ownership and Power Challenges in Meta's Hyperion and ... https://www.datacenterfrontier.com/hyperscale/article/55310441/ownership-and-power-challenges-in-metas-hyperion-and-prometheus-data-centers
[13] Louisiana Greenlights Massive Power Projects for Meta Data Center https://www.industrialinfo.com/iirenergy/industry-news/article/louisiana-greenlights-massive-power-projects-for-meta-data-center--345274
[14] Google Unveils Project Suncatcher, Envisioning AI Models Running ... https://www.infoq.com/news/2025/11/google-suncatcher-space/
[15] xAI could build 1.56GW natural gas power plant for new data center, campaigners claim https://www.datacenterdynamics.com/en/news/xai-could-build-156gw-natural-gas-power-plant-for-new-data-center-campaigners-claim/
[16] The AI Power Grab: Tech Giants Sign White House Deal to Build Their Own Electricity https://www.youtube.com/watch?v=PzsT2gq6TcU
[17] Oracle's $40 Billion Investment in Nvidia AI Chips for Massive OpenAI Data Center https://theoutpost.ai/news-story/oracle-s-40-billion-investment-in-nvidia-chips-for-open-ai-s-stargate-data-center-15792/
[18] Data Center Space Race Heats Up As Startup Requests ... https://www.pcmag.com/news/data-center-space-race-heats-up-as-starcloud-startup-requests-88000-satellites
[19] Hyperscaler CapEx 2026 में $600B तक पहुंचा: AI Infrastructure ... - Introl https://introl.com/hi/blog/hyperscaler-capex-600b-2026-ai-infrastructure-debt-january-2026
