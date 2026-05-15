---
layout: post
title: AI-Native WAN: Architecture, Problems, and Solutions
subtitle: AI Token Traffic Stresses Traditional WAN
cover-img: /assets/img/header/2026-05-14/AI-NATIVE-WAN.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-14/AI-NATIVE-WAN.png
published: true
pinned: false
tags: [draft, AI-NativeWAN, NaaS, CloudWAN, Equinix, Megaport, CoreWeave, 網路主權, TICC, 美國企業AI]
---


# AI-Native WAN: Architecture, Problems, and Solutions

> Technical research notes · May 2026  
> Covers: AI-Native WAN definition, LLM traffic stress vectors, QoS solutions, embedded model architecture, Juniper Mist AI, Cisco Silicon One, decision speed tiers, wire-speed ML constraints

---

## Table of Contents

1. [What Is AI-Native WAN?](#1-what-is-ai-native-wan)
2. [Why AI Token Traffic Stresses Traditional WAN](#2-why-ai-token-traffic-stresses-traditional-wan)
3. [Problem 1: Asymmetric Flow Profiles](#3-problem-1-asymmetric-flow-profiles)
4. [Problem 2: Latency Sensitivity and Jitter Cascade](#4-problem-2-latency-sensitivity-and-jitter-cascade)
5. [Problem 3: Bursty Aggregation — Synchronized Surge Patterns](#5-problem-3-bursty-aggregation--synchronized-surge-patterns)
6. [Problem 4: RAG Traffic Invisibility to Legacy QoS](#6-problem-4-rag-traffic-invisibility-to-legacy-qos)
7. [Embedded Models in Network Devices](#7-embedded-models-in-network-devices)
8. [L2 vs L3: Which Devices Need Embedded Models?](#8-l2-vs-l3-which-devices-need-embedded-models)
9. [MPLS as the Persistent Core](#9-mpls-as-the-persistent-core)
10. [Model Heterogeneity: The Configuration Reality](#10-model-heterogeneity-the-configuration-reality)
11. [Juniper Mist AI — Architecture and Decision Speed Tiers](#11-juniper-mist-ai--architecture-and-decision-speed-tiers)
12. [Cisco Silicon One — On-Device AI Reality](#12-cisco-silicon-one--on-device-ai-reality)
13. [The Wire-Speed ML Constraint](#13-the-wire-speed-ml-constraint)
14. [Synthesis: AI-Native WAN Architecture Reference Model](#14-synthesis-ai-native-wan-architecture-reference-model)

---

## 1. What Is AI-Native WAN?

**AI-Native WAN** (Wide Area Network) refers to enterprise networking infrastructure where AI/ML is embedded as a foundational design principle — not bolted on as a feature — to manage, optimize, and automate wide-area network operations end-to-end.

### Core Distinction

| | Traditional WAN / SD-WAN | AI-Native WAN |
|---|---|---|
| AI role | Optional analytics layer | Core control plane |
| Policy | Human-defined rules | ML-inferred, self-tuning |
| Reaction | Reactive (post-event) | Predictive (pre-emptive) |
| Ops model | NOC-driven | Autonomous with human oversight |

### Key Capabilities

**Predictive Traffic Engineering**  
ML models forecast congestion, link degradation, and demand shifts — rerouting traffic before problems manifest rather than reacting to alarms.

**Autonomous Path Selection**  
Goes beyond SD-WAN's policy-based path selection. AI continuously scores available paths (MPLS, broadband, 5G, satellite) against real-time latency, jitter, loss, and application SLA requirements.

**Self-Healing**  
Anomaly detection identifies brownouts, BGP instabilities, or security events and executes remediation (failover, rate limiting, re-peering) without human intervention.

**Application-Aware QoS**  
AI classifies traffic flows dynamically — including encrypted flows via behavioral fingerprinting — and enforces per-application SLAs adaptively.

**AIOps Integration**  
Closes the loop: network telemetry feeds the AI, AI generates intent, intent is pushed to the network as configuration, and outcomes retrain the model.

### Architecture Pattern

```
Telemetry Collection (streaming NetFlow, gRPC, SNMP)
        ↓
Feature Engineering & Time-Series Modeling
        ↓
Intent Engine (ML policy inference)
        ↓
Orchestration Layer (pushes config to edge devices)
        ↓
Feedback Loop (outcome → retraining)
```

---

## 2. Why AI Token Traffic Stresses Traditional WAN

Several converging forces make AI-native WAN timely:

- **Traffic unpredictability** — SaaS, UCaaS, and cloud-burst workloads create highly variable demand that static policies cannot track.
- **Edge proliferation** — Branch offices, retail sites, OT networks, and remote workers push the management surface beyond human scale.
- **LLM/AI workloads** — GPU cluster training and inference traffic has extreme bandwidth and latency requirements that need dynamic prioritization.
- **Security posture** — AI can detect lateral movement and exfiltration patterns in real time across the WAN fabric.

### Four Core Stress Vectors

| Vector | Core Problem |
|---|---|
| Asymmetric flow profiles | Unpredictable response size + streaming delivery |
| Latency sensitivity / jitter cascade | Single jitter event triggers retry storm |
| Bursty aggregation | Synchronized human behavioral rhythms create 10–20× peak-to-mean ratio |
| RAG traffic invisibility | Multi-flow pipeline indistinguishable to legacy QoS |

---

## 3. Problem 1: Asymmetric Flow Profiles

### Problem Definition

```
Client → WAN → LLM Endpoint:   small payload  (prompt, ~100B–4KB)
Client ← WAN ← LLM Endpoint:   large payload  (response, streaming, ~1KB–100KB+)
                                + time-extended (token generation is not instantaneous)
```

This differs fundamentally from HTTP request/response asymmetry (like video streaming):

- **Response size is unpredictable** — depends on model, temperature, max_tokens. Unknown at connection establishment.
- **Response is not a bulk transfer** — it is a stream of small chunks (SSE / chunked HTTP), each chunk ~few bytes, arriving at token generation rate (~30–80 tok/sec).
- **Connection stays open** — long-lived HTTP/2 or WebSocket, not short TCP transactions.

### Solution Space

#### 1. Transport Layer — TCP Tuning

Traditional TCP slow-start is hostile to streaming token responses:

- **BBR congestion control** instead of CUBIC — better handles intermittent low-bandwidth streams
- **Larger initial congestion window** (IW10 → IW30) to avoid slow-start penalty on short-lived prompt requests
- **TCP SACK** must be enabled — retransmit only lost chunks, not entire stream

#### 2. QoS Reclassification

Legacy DSCP marking does not account for directional asymmetry:

- **Bidirectional asymmetric queuing** — upstream (prompt) gets low-latency small-queue; downstream (response stream) gets separate jitter-controlled queue
- **Flow-aware scheduling** — identify LLM API connections and apply per-flow QoS, not per-DSCP

#### 3. WAN Optimization — Selective

Classic WAN-OPT (dedup, compression) is largely ineffective on LLM traffic because responses are not repetitive at byte level and HTTPS kills dedup.

What does work:

- **Header compression** (HTTP/2 HPACK, HTTP/3 QPACK) — reduces per-chunk overhead on token stream
- **Protocol acceleration** — proxy the SSE stream at the WAN edge, buffer and re-pace to absorb jitter before delivering to client

#### 4. Edge Proxy / Stream Buffer

Most practical near-term solution:

```
Client → Edge POP (thin proxy) → WAN → LLM API
                ↑
        Buffer + re-pace token stream here
        Absorb upstream jitter
        Present smooth stream to client
```

This decouples client-perceived latency from WAN variability. Vendors like Cato, Zscaler ZIA, and Cloudflare Gateway already sit in this path — the gap is LLM-aware stream handling.

#### 5. AI-Native Layer — Predictive Bandwidth Reservation

- At prompt submission, **pre-reserve downstream bandwidth** for expected response window
- Estimate response size from prompt length + model type heuristic
- Release reservation on stream close

Analogous to RSVP but ML-driven and ephemeral.

### Solution Summary

| Layer | Solution | Maturity |
|---|---|---|
| Transport | BBR + large IW | Available now |
| QoS | Asymmetric bidirectional queuing | Needs vendor support |
| WAN-OPT | HTTP/2/3 header compression | Available now |
| Edge | Stream buffer proxy | Emerging |
| AI-Native | Predictive BW reservation | Research / early vendor |

---

## 4. Problem 2: Latency Sensitivity and Jitter Cascade

### Problem Definition

```
Traditional app:   latency spike → user notices slowness → recovers
LLM token stream:  latency spike → timeout → retry → amplified load → cascade
```

The non-linearity is the key insight. LLM traffic does not degrade gracefully.

### Token Inter-Arrival Time (IAT)

For streaming inference, what matters is:

```
IAT = time between consecutive token chunks arriving at client
```

- Normal IAT: ~12–30ms (depends on model speed)
- User perceives stutter at IAT > ~150ms
- Client SDK timeout typically fires at IAT > 30–60s (enterprise proxies often much lower)

### The Cascade Mechanism

```
Step 1:  WAN link congestion spike → 200ms jitter event
Step 2:  Token IAT exceeds enterprise proxy timeout threshold
Step 3:  Proxy kills connection, issues retry
Step 4:  Retry = new prompt submission = full LLM generation restart
Step 5:  N users hit same jitter window → N simultaneous retries
Step 6:  N retries hit LLM API endpoint simultaneously → rate limit / queue buildup
Step 7:  Queue buildup → higher latency → more timeouts → more retries
         ↑_________________________feedback loop________________________|
```

This is a **retry storm** with a **positive feedback loop** — classic distributed systems failure mode appearing in enterprise WAN context.

### Amplification Factors

| Factor | Why It Amplifies |
|---|---|
| Synchronized user behavior | 9am surge means N users prompt simultaneously → N retries in same window |
| Short proxy timeouts | Enterprise security proxies (Zscaler, Netskope) default timeouts not tuned for LLM streams |
| No exponential backoff | Most LLM client SDKs retry immediately or with fixed delay |
| Stateless LLM API | No resume — every retry restarts generation from token 0 |
| RAG pre-fetch | Each retry also re-triggers vector DB queries upstream |

### Solution Space

#### 1. Client-Side — Retry Discipline

```python
# Conceptual
@retry(wait=wait_exponential(min=1, max=30),
       stop=stop_after_attempt(3),
       retry=retry_if_exception_type(TimeoutError))
def call_llm(prompt): ...
```

- **Exponential backoff with jitter** — applied at LLM client layer specifically
- **Retry budget** — cap total retries per user session, not per request
- **Circuit breaker** — if error rate exceeds threshold, surface degraded-mode UI instead of hammering endpoint

#### 2. Proxy Layer — Timeout Recalibration

Enterprise security proxies are the silent killer:

- Default idle timeout (60s) fires during normal long-generation responses
- Solution: **LLM API domain bypass** or **extended timeout profile** for known LLM endpoints
- Zscaler, Netskope, Palo Alto SASE all support domain-based timeout policy — requires explicit configuration

#### 3. WAN Edge — Jitter Buffer

Analogous to VoIP jitter buffer, applied to token streams:

```
LLM API → WAN → Edge POP (jitter buffer) → Client
                      ↑
              absorb IAT variance here
              re-pace delivery at stable IAT
              hold up to N tokens in buffer
              only surface stall if buffer drains completely
```

Key parameter: **buffer depth** — deeper buffer = smoother stream but higher perceived first-token latency. Needs to be tunable per application SLA.

#### 4. Transport — QUIC / HTTP/3

TCP has a fundamental problem for token streams: **head-of-line blocking**

```
TCP:   lost packet N → entire stream stalls until N retransmitted
QUIC:  lost packet N → only stream N stalls, others continue
```

For multiplexed LLM calls, QUIC eliminates cross-session jitter amplification.

#### 5. AI-Native Layer — Jitter Prediction and Pre-emptive Rerouting

```
Telemetry:  per-link IAT variance monitored continuously (μs granularity)
Model:      LSTM or transformer predicting jitter spike probability next 30–60s
Action:     pre-emptively migrate active LLM sessions to lower-jitter path
            BEFORE spike occurs, not after timeout fires
```

Key distinction from SD-WAN: SD-WAN reacts to SLA breach. AI-native predicts and avoids.

### Failure Mode Summary

```
Jitter event
    ↓
IAT spike → proxy timeout → retry storm
                                  ↓
                         rate limit → queue buildup
                                           ↓
                                    higher latency → more timeouts
                                           ↑___________|  (loop)
```

Break the loop at: jitter buffer (prevent IAT spike), timeout recalibration (prevent premature kill), retry discipline (prevent storm), predictive rerouting (prevent jitter event).

---

## 5. Problem 3: Bursty Aggregation — Synchronized Surge Patterns

### Problem Definition

```
Traditional app:  traffic = sum of independent random user actions → smooth Poisson
LLM enterprise:   traffic = synchronized bursts driven by shared behavioral rhythms → spiky
```

The independence assumption that WAN capacity planning relies on **breaks** for LLM workloads.

### Why LLM Traffic Is Synchronized

#### Human Behavioral Clocking

```
08:55–09:05  Login surge → "summarize my overnight emails" → prompt burst
10:00        Meeting ends → "draft follow-up" → prompt burst
12:00        Lunch return → "catch me up" → prompt burst
14:00        Standup cycle → code assistant queries → prompt burst
17:00        EOD → "write status report" → prompt burst
```

#### Compounding Factor: Agent Chains

```
User: "Prepare my weekly report"
  → Agent step 1: fetch calendar (API call)
  → Agent step 2: summarize emails (LLM call 1)
  → Agent step 3: pull metrics (API call)
  → Agent step 4: draft report (LLM call 2)
  → Agent step 5: format output (LLM call 3)
```

One user prompt = 3–5 LLM API calls. At 9am surge with 500 users: **1,500–2,500 simultaneous LLM calls**.

### Traffic Shape Comparison

```
Traditional (Poisson):
▁▂▂▃▃▂▃▃▂▃▂▂▃▃▂▂▃▂▃▂  ← manageable, predictable

LLM enterprise (correlated bursts):
▁▁▁▁████▁▁▁▁▁████▁▁▁  ← 10× peak-to-mean ratio
         ↑9am      ↑lunch
```

Traditional capacity planning sizes for mean + 2σ. LLM burst peaks can reach **10–20× mean** for 5–10 minute windows.

### Solution Space

#### 1. Demand Shaping — Token Consumption Throttling

- **Per-user token rate limiting** — sliding window budget (e.g., 10K tokens/5min per user)
- **Priority queuing by role** — executive / engineer / analyst tiers with different burst allowances
- **Soft throttle vs. hard block** — degrade to smaller model or cached response before rejecting

Enterprise AI gateways (**LiteLLM**, **Portkey**, **Kong AI Gateway**) implement this today.

#### 2. Temporal Smoothing — Request Scheduling

```
Naive:    all 500 users hit "generate report" at 09:00 → burst
Smoothed: gateway staggers execution over 09:00–09:15 → flat load
```

- **Deadline-aware scheduler** — user specifies "ready by 09:30", system dispatches at optimal time
- **Background vs. foreground queue** — interactive prompts get immediate path, batch jobs fill off-peak capacity

#### 3. Caching Layer — Semantic Response Cache

- **Exact cache** — hash prompt + context → return cached response (high precision, low hit rate)
- **Semantic cache** — embed prompt → cosine similarity lookup → return if similarity > threshold
- **GPTCache**, **Redis** with vector extension, **Momento** all support this pattern

Cache hit = **zero WAN traffic**. Even 20% hit rate during surge window dramatically flattens peak.

#### 4. WAN Layer — Adaptive QoS Burst Absorption

```
Normal:   LLM traffic gets 30% of WAN bandwidth allocation
Burst:    AI-native controller detects surge → temporarily reallocates
          background sync / backup traffic → preempted
          LLM traffic → expands to 60% for surge window duration
```

#### 5. AI-Native Layer — Behavioral Clock Model

```
Training data:  historical per-site token consumption time series
                + calendar events (meeting cadence, timezone)
                + application telemetry (Copilot/Claude usage patterns)

Model output:   per-site burst probability curve, next 60 minutes
                predicted peak magnitude + duration

Actions:
  T-10min:  pre-provision additional path capacity
  T-5min:   pre-warm semantic cache with likely queries
  T-0:      burst arrives into pre-expanded, pre-warmed infrastructure
  T+15min:  release reserved capacity back to baseline
```

### Solution Summary

| Layer | Solution | Key Metric Targeted |
|---|---|---|
| Demand | Token rate limiting + priority queuing | Peak request rate |
| Demand | Deadline-aware scheduler | Burst concentration |
| Application | Semantic response cache | Unique request volume |
| WAN | Adaptive QoS preemption | Burst bandwidth |
| WAN | Predictive link pre-activation | Time-to-capacity |
| AI-Native | Behavioral clock model | Surge prediction accuracy |

The **semantic cache + behavioral clock model** combination is highest leverage — cache reduces unique traffic volume, clock model gives infrastructure time to prepare for what remains.

---

## 6. Problem 4: RAG Traffic Invisibility to Legacy QoS

### Problem Definition

```
Legacy QoS assumption:  one user action = one identifiable network flow
RAG reality:            one user prompt = multiple flows, multiple protocols,
                        multiple destinations, all HTTPS, all indistinguishable
```

### What RAG Traffic Looks Like on the Wire

A single user prompt to a RAG-enabled LLM assistant:

```
User: "What were our Q1 revenue figures?"

Flow 1:  Client → Embedding API (OpenAI/local)     HTTPS POST  ~200B payload
Flow 2:  Client → Vector DB (Pinecone/Weaviate)    HTTPS POST  ~1KB query
Flow 3:  Vector DB → Object Store (S3/GCS)         HTTPS GET   ~50KB retrieval
Flow 4:  Client → LLM API (Anthropic/OpenAI)       HTTPS POST  ~8KB (prompt + context)
Flow 5:  LLM API → Client                          HTTPS SSE   ~2KB streaming response
```

From the WAN firewall's perspective, all five flows are indistinguishable HTTPS calls to different SaaS endpoints. **Zero semantic relationship visible to QoS engine.**

### Three Core Problems

#### Problem 1: Priority Inversion

```
Flow 3 (S3 document retrieval, RAG context fetch):  → classified as "cloud storage" → low priority
Flow 4 (LLM API call, depends on Flow 3):           → classified as "API" → medium priority

Result: high-priority LLM call stalls waiting for low-priority prerequisite
```

#### Problem 2: Bandwidth Accounting Blindness

Network team sees S3 up 300%, Pinecone traffic appeared, OpenAI API 10× — but cannot see these are all one workload. Siloed flow accounting prevents coherent capacity planning.

#### Problem 3: Security / DLP Gap

```
Legacy DLP rule:  block upload of files > 10MB to external destinations
RAG reality:      sensitive document chunked into 100× 100KB embeddings
                  sent to external vector DB over HTTPS
                  each chunk = 100KB → each chunk passes DLP rule
                  semantic content = entire sensitive document → policy violated
```

### The Encryption Problem

TLS 1.3 eliminates most classical DPI signals:

```
Still visible:   Destination domain (SNI), Port (always 443 — useless)
Encrypted:       URL path, Payload, Request headers, Response content type
```

SNI gives domain (`api.openai.com`) but not **which API endpoint** (`/v1/embeddings` vs `/v1/chat/completions`) — two flows with completely different QoS requirements, indistinguishable from outside.

### Solution Space

#### 1. Application-Layer Tagging — DSCP at Source

```
RAG orchestrator (LangChain / LlamaIndex / custom):
  embedding_call()  → tag DSCP AF21 (low latency, medium priority)
  vector_query()    → tag DSCP AF31 (low latency, high priority)
  context_fetch()   → tag DSCP AF11 (bulk, low priority)
  llm_inference()   → tag DSCP EF   (expedited forwarding, highest)
```

Most practical near-term solution. Requires orchestration framework support and enterprise WAN policy to honor markings.

#### 2. Behavioral Flow Classification — ML on Metadata

Features available without decryption: packet size distribution, inter-packet timing, flow duration, bytes sent/received ratio, connection multiplexing pattern, destination domain sequence and timing, TLS handshake characteristics.

```
Pattern:  short POST to embedding API
          followed within 50ms by POST to vector DB
          followed within 200ms by GET to object store
          followed within 300ms by POST to LLM API
          → classify entire flow group as RAG session
          → apply coordinated QoS to all five flows
```

This is the **AI-native WAN core capability** — flow relationship inference from encrypted metadata.

#### 3. Service Graph Abstraction

```yaml
service: rag-assistant
flows:
  - name: embed
    destination: api.openai.com/v1/embeddings
    priority: AF21
    max_latency_ms: 100
  - name: vector-query
    destination: "*.pinecone.io"
    priority: AF31
    max_latency_ms: 50
    depends_on: embed
  - name: context-fetch
    destination: "*.s3.amazonaws.com"
    priority: AF11
    max_latency_ms: 500
    depends_on: vector-query
  - name: inference
    destination: api.anthropic.com
    priority: EF
    max_latency_ms: 200
    depends_on: context-fetch
```

WAN controller enforces **dependency-aware scheduling** — critical path flows get bandwidth reservation, non-critical path flows yield.

#### 4. Selective TLS Inspection

```
TLS inspection proxy (Zscaler / Palo Alto):
  decrypt → inspect URL path + headers → re-encrypt → forward

  /v1/embeddings       → DSCP AF21
  /v1/chat/completions → DSCP EF
  /query (Pinecone)    → DSCP AF31
```

Cost: privacy / compliance complexity, certificate management, performance overhead.

#### 5. eBPF at the Edge

```
eBPF probe on edge router:
  - intercepts socket calls at kernel level
  - correlates flows by process, timing, connection metadata
  - tags related flows before they hit the WAN interface
  - no payload decryption required
```

Flow correlation happens inside the trust boundary before encryption. High technical complexity but architecturally clean.

### DLP Gap — Separate Solution Required

```
Solution: RAG-aware DLP policy
  - classify documents at ingest time (before chunking)
  - tag embeddings with source document classification
  - enforce policy at vector DB query time, not chunk upload time
  - requires DLP engine integrated with RAG orchestrator, not WAN layer
```

### Solution Summary

| Problem | Solution | Layer |
|---|---|---|
| Priority inversion | Application DSCP tagging | App / Orchestrator |
| Flow relationship blindness | ML behavioral classification | AI-Native WAN |
| Dependency-unaware scheduling | Service graph abstraction | WAN Controller |
| URL path invisibility | Selective TLS inspection | Security Proxy |
| In-process correlation | eBPF edge probes | Edge OS |
| Semantic DLP gap | RAG-aware DLP at ingest | Data Plane |

The **service graph abstraction + ML behavioral classification** combination is the architectural target.

---

## 7. Embedded Models in Network Devices

"Embedded model" has two distinct meanings in this context:

### Meaning 1: Embedding Model (RAG context)

A model that converts text into a dense vector representation:

```
Text:    "What were our Q1 revenue figures?"
  ↓  embedding model
Vector:  [0.021, -0.847, 0.334, 0.012, ...]  ← 1536 dimensions (OpenAI ada-002)
```

- Captures semantic meaning as a point in high-dimensional space
- Similar meaning → vectors are geometrically close (cosine similarity)
- Enables vector DB lookup: find chunks semantically similar to this query

Examples: `text-embedding-ada-002` (OpenAI), `embed-english-v3` (Cohere), `nomic-embed` (local)

### Meaning 2: Embedded Model (AI-Native WAN context)

An ML inference model running **directly inside network hardware** — router, switch ASIC, WAN appliance — rather than in a separate analytics server:

```
Traditional:  device → telemetry → central analytics platform → policy decision → device
Embedded:     device → local ML inference → policy decision  (all on-device)
```

- Sub-millisecond reaction time (no round-trip to cloud)
- Enables real-time per-packet or per-flow decisions
- Constrained by hardware — typically small models (gradient boosted trees, tiny NNs)

### The Heterogeneity Problem

If each device runs its own embedded model:

```
Edge Router A:   model v2.1, trained on Dataset X → classifies RAG traffic → priority HIGH
Edge Router B:   model v1.8, trained on Dataset Y → classifies same traffic → priority MEDIUM
Core Switch C:   model v3.0, trained on Dataset Z → classifies same flow → priority LOW
```

Same packet, three different decisions across the path. **Policy coherence breaks.**

#### Why This Happens

- Hardware refresh cycles differ per site
- Vendor model update cadence ≠ network upgrade cadence
- Branch office devices are often generations behind core
- Different vendors at different layers (Juniper edge, Cisco core, Aruba branch)

#### Consequences

| Problem | Effect |
|---|---|
| Inconsistent classification | Flow gets different priority at each hop |
| Split-brain policy | QoS decision at ingress contradicted at egress |
| Audit impossibility | Cannot prove end-to-end SLA was honored |
| Training drift | Each device learns different local patterns, diverges over time |

#### Solution Approaches

**1. Centralized Decision, Distributed Enforcement**
```
Embedded model → only collects features locally
Central AI controller → makes all classification decisions
Pushes labels/tags back to devices
Devices → only enforce, never decide independently
```

**2. Model Versioning + Synchronized Rollout**  
Treat embedded models like firmware — central model registry, synchronized pull, rollout gating.

**3. Feature Standardization — Model-Agnostic**  
Standardize the output schema, not the model:
```
Any model version → must output canonical labels:
  flow_class: [interactive_llm | rag_fetch | batch_embed | background]
  priority:   [0–7]
  confidence: [0.0–1.0]
```

**4. Federated Learning**  
Each device trains locally, uploads gradients to central server, receives updated global model. Privacy-preserving but complex and slow to converge.

#### The Real Tension

```
Embedded model advantage:     speed (local inference, microseconds)
Heterogeneity disadvantage:   inconsistency across hops

Current industry direction:   HYBRID
  Fast path:  embedded model (per-packet, latency-critical, simple classification)
  Slow path:  central model (flow-level, policy-level, complex decisions)
  Sync:       lightweight label propagation (DSCP, segment routing metadata)
```

---

## 8. L2 vs L3: Which Devices Need Embedded Models?

### The Intuitive Answer

```
Layer 2 (switches):  forward by MAC address, no routing decisions → no model needed
Layer 3 (routers):   forward by IP, sees flows, makes path decisions → needs model
```

This is partially correct but incomplete.

### Where It Breaks Down

**L2 Devices Have AI-Relevant Roles:**

- **Congestion visibility** — L2 switch fabric carries ALL east-west traffic. Queue depth, port utilization, microburst events are valuable telemetry input — but the model doesn't need to live in the L2 device.
- **802.1p QoS marking** — If L2 is the first network touch point (campus switch) and L3 hasn't tagged yet, L2 must act on untagged traffic.
- **VXLAN / Overlay termination** — Modern L2 fabrics (EVPN/VXLAN) terminate tunnels. At termination point, flow metadata is briefly visible — a classification opportunity.

### Cleaner Mental Model: By Function

```
Function                        Needs Embedded Model?
─────────────────────────────────────────────────────
Path selection (routing)        YES — core use case
QoS enforcement                 NO  — obeys tags set upstream
Traffic classification          YES — whoever sees the flow FIRST
Telemetry collection            NO  — feeds model elsewhere
Tunnel termination              MAYBE — brief visibility window
Congestion control              MAYBE — local fast-path decisions
```

### Practical Enterprise Topology

```
Client
  ↓
[L2 Access Switch]     ← no model, telemetry source only
  ↓
[L3 Distribution]      ← first classification point, model HERE
  ↓
[L3 Core / WAN Edge]   ← path selection, model HERE
  ↓
[WAN]
  ↓
[L3 Remote Edge]       ← re-classification after WAN, model HERE
  ↓
[L2 Remote Access]     ← no model, enforcement only
```

### Key Exception: WAN Demarcation

If WAN provider delivers L2 service (Metro Ethernet, MPLS pseudowire handoff), the provider's L2 device carries enterprise traffic. The embedded model in the provider L2 device is the **provider's** problem — not the enterprise's.

### Summary

```
L2 devices:   telemetry sources, enforcement nodes — no embedded model needed
L3 devices:   classification + path selection — embedded model lives here
Exception:    whoever sees the untagged flow FIRST needs classification capability
              regardless of layer label
```

---

## 9. MPLS as the Persistent Core

### Why MPLS Persists

MPLS is widely declared "dead" by SD-WAN vendors. That is marketing, not reality.

**Traffic Engineering Is Still Unmatched**
```
MPLS-TE:  explicit path control, bandwidth reservation, fast-reroute (50ms)
SD-WAN:   policy-based overlay, best-effort path selection, seconds-level failover
```

For deterministic latency SLA — financial trading, real-time control systems, carrier voice — MPLS-TE has no peer.

**Metro Ethernet / Carrier Ethernet Handoff**
```
Enterprise WAN edge
  ↓
Carrier Metro Ethernet (L2)
  ↓
Carrier MPLS Core (L3)     ← still here, invisible to enterprise
  ↓
Remote site
```

Enterprise sees "internet" or "private WAN." Underneath, the carrier is running MPLS. The enterprise's SD-WAN overlay **rides on top of** MPLS — not instead of it.

**Segment Routing Evolution**

MPLS did not die — it evolved:

```
Classic MPLS-TE:   distributed RSVP signaling, complex, hard to scale
SR-MPLS:           source routing, centralized controller, simplified
SRv6:              segment routing over IPv6, no MPLS label stack needed
```

SR-MPLS and SRv6 are the core fabric of every major carrier today — AT&T, NTT, Chunghwa Telecom.

### The Actual Production Stack

```
Application layer:    SD-WAN overlay (Meraki, Viptela, Versa)
                           ↓ tunnel over
Transport layer:      Internet broadband / 5G / MPLS VPN
                           ↓ carried by
Metro layer:          Carrier Ethernet / Metro Ethernet (L2)
                           ↓ switched by
Core layer:           SR-MPLS or SRv6 (carrier backbone)
```

SD-WAN is an **overlay** on top of MPLS, not a replacement.

### AI-Native WAN Implication: The Visibility Gap

```
AI-Native WAN controller:
  ✓ sees: enterprise edge → internet
  ✓ sees: SD-WAN overlay metrics
  ✗ blind: inside carrier MPLS/Metro core
  ✗ blind: carrier traffic engineering decisions
```

ThousandEyes partially addresses this via synthetic probing — but you are inferring carrier internals from external observations, not true telemetry.

The AI-Native WAN controller must treat the carrier MPLS segment as a black box with contractual SLA, observable via active probing, but with no internal visibility.

### Taiwan Context

Chunghwa Telecom HiNet backbone and enterprise leased line products are SR-MPLS based. Most enterprise WAN in Taiwan follows this pattern:

```
Enterprise site (Taipei/Hsinchu/Taichung)
  ↓ L2 Metro Ethernet handoff
CHT / APTG / FarEasTone MPLS core
  ↓ L2 Metro Ethernet handoff
Remote enterprise site or data center
```

SD-WAN overlays are deployed **on top** of CHT MPLS — not replacing it for tier-1 enterprise.

### Summary

```
MPLS declared dead:   2015 — SD-WAN hype cycle peak
MPLS actual status:   SR-MPLS/SRv6 = carrier backbone standard
                      Metro Ethernet = L2 enterprise handoff standard

SD-WAN role:          overlay intelligence on top of MPLS
AI-Native WAN role:   optimizes what enterprise can see and control
                      treats carrier MPLS as contractual black box
```

MPLS is the floor, not the ceiling. AI-Native WAN builds upward from it.

---

## 10. Model Heterogeneity: The Configuration Reality

Even with a centralized policy model, inconsistency persists across hops because of where **DSCP trust boundaries** are set.

### The DSCP Trust Stripping Problem

```
Device A (enterprise edge):   marks flow → DSCP EF (highest priority)
        ↓
Device B (carrier handoff):   strips DSCP → resets to 0
        ↓
Device C (carrier core):      sees DSCP 0 → default best-effort
        ↓
Device D (remote edge):       re-marks based on local policy → DSCP AF21
```

The marking was correct at origin. It was **administratively erased** at a trust boundary.

### Five Reasons Inconsistency Persists

#### 1. Carrier Default Behavior — Intentional

```
Carrier SLA contract:   guarantees aggregate bandwidth, not per-flow priority
Carrier incentive:      customer could mark everything EF → gaming QoS
Default policy:         strip all customer DSCP at ingress PE router
```

This is intentional from the carrier's perspective. Rational, but breaks enterprise end-to-end QoS.

#### 2. Misconfigured Trust Boundaries

```
Correct config:   trust DSCP from known internal sources
                  re-mark from unknown sources (guest WiFi, unmanaged devices)

Common mistake:   blanket "trust none" on all interfaces ← QoS breaks
                  blanket "trust all" on all interfaces  ← security risk
```

Many enterprises set blanket untrust as safe default — including on interfaces where they should trust their own application markings.

#### 3. Vendor DSCP Queue Mapping Differences

```
Cisco IOS:      DSCP EF  → internal DSCP queue 5
Juniper JunOS:  DSCP EF  → forwarding class "expedited"
Aruba OS:       DSCP EF  → priority queue 7
```

Even if DSCP value is preserved end-to-end, the **queuing treatment differs per device**.

#### 4. Tunnel Interface QoS Gap

```
Template pushed from central controller:
  → applies to physical interfaces  ✓
  → applies to sub-interfaces       ✓
  → applies to tunnel interfaces    ✗  ← commonly missed
```

SD-WAN overlays run over **tunnel interfaces**. QoS policy must be explicitly applied to the tunnel — not just the physical underlay. This is a frequently missed configuration step.

#### 5. Policy-to-Device Sync Latency

```
Policy lifecycle:         changes frequently (new apps, new SLAs)
Device config lifecycle:  changes slowly (change management, maintenance windows)

Central policy update:   minutes
Change ticket approval:  days
Maintenance window:      weeks
```

The operational process velocity cannot keep up with policy velocity. The gap is a **structural inconsistency window**.

### Summary

| Reason | Type |
|---|---|
| Carrier trust stripping | Architectural / contractual |
| Blanket trust misconfiguration | Human error |
| Vendor DSCP queue mapping differences | Vendor heterogeneity |
| Tunnel interface QoS gap | Configuration omission |
| Policy-to-device sync latency | Operational process gap |

The heterogeneity problem is not primarily a model problem — it is a combination of contractual boundaries, vendor implementation differences, and operational process velocity.

---

## 11. Juniper Mist AI — Architecture and Decision Speed Tiers

### Overview

Mist AI is a cloud-based AI platform managing wireless, wired, and WAN. The AI lives primarily in the **Mist Cloud** — but pushes compiled decisions down to edge hardware as standing instructions.

**Reference:** https://www.juniper.net/us/en/products/mist-ai.html

### The Core Tension

```
WAN event occurs at branch edge device
       ↓
Signal must travel:  Device → Internet → Mist Cloud → Decision → Internet → Device
       ↓
By the time decision arrives... packet is already gone
```

Cloud-based AI and wire-speed networking are physically incompatible for fast-path decisions. Mist solves this by splitting decisions across three tiers by time horizon.

### Three-Tier Decision Architecture

#### Tier 1 — Hardware Fast Path (nanoseconds)

```
Who decides:  Session Smart Router (SSR) ASIC on device
What:         per-packet forwarding, QoS queue selection
Cloud role:   NONE — policy already downloaded, executing locally
Example:      packet arrives → DSCP EF → put in priority queue → forward
              decision time: ~100–500 nanoseconds
```

#### Tier 2 — Local Software (milliseconds)

```
Who decides:  SSR software stack on device CPU
What:         session-level decisions, link failover, SLA breach reaction
Cloud role:   NONE — local agent acting on pre-downloaded policy
Example:      WAN link latency exceeds SLA threshold
              → local agent switches session to backup path
              reaction time: ~100–500ms
```

This is the Marvis autonomous port bounce — executes locally, reported to cloud after.

#### Tier 3 — Mist Cloud AI (seconds to minutes)

```
Who decides:  Mist Cloud ML models
What:         policy updates, anomaly detection, capacity recommendations,
              new classification rules, configuration changes
Cloud role:   FULL — telemetry up, decision down
Example:      Mist detects new traffic pattern across 500 branch sites
              → trains updated classification model
              → pushes new policy to all devices
              round-trip latency: 2–30 seconds for policy push
```

### Round-Trip Reality

```
Device → Mist Cloud:
  Telemetry streaming interval:  30–60 seconds (aggregated)
  Event-driven alerts:           ~1–5 seconds

Mist Cloud → Device:
  Policy push (config change):   ~5–30 seconds
  Emergency remediation:         ~2–10 seconds

Total cloud decision loop:       ~10–60 seconds minimum
```

For a WAN jitter event lasting 200ms, the cloud loop is **100× too slow**.

### How Mist Bridges the Gap: Pre-Downloaded Policy

```
Cloud AI runs continuously:
  → analyzes traffic patterns
  → computes optimal policy
  → compiles into local forwarding rules
  → pushes to device as standing instructions

Device executes standing instructions locally:
  → no cloud needed at decision time
  → cloud only needed when policy needs to change
```

The cloud decides the rules. The device executes the rules. **The cloud is not in the data path.**

### Telemetry Architecture

```
Device → Mist Cloud:
  Per-session telemetry:    streaming, ~1s granularity
  Per-packet telemetry:     sampled (not every packet)
  Anomaly events:           pushed immediately on detection

Mist Cloud:
  Cross-site pattern detection:  "this jitter pattern appearing at 47 branches"
  Single-site fast reaction:     too slow — relies on local tier
```

Cross-site intelligence is where cloud genuinely wins. No single-device agent can see patterns across 500 branches simultaneously.

### Decision Speed Summary

| Decision Type | Where | Latency | Example |
|---|---|---|---|
| Per-packet forwarding | On-chip ASIC | ~100ns | QoS queue selection |
| Session failover | Local software | ~100–500ms | Link SLA breach → reroute |
| Port bounce / self-heal | Local Marvis agent | ~1–3s | ARP failure recovery |
| Policy update from cloud | Mist Cloud → device | ~10–30s | New app classification rule |
| Cross-site anomaly detection | Mist Cloud | ~30–120s | Jitter pattern across branches |
| Capacity recommendation | Mist Cloud | minutes–hours | "Add bandwidth at site X" |

### Mental Model

```
Mist Cloud AI = strategic brain     (slow, omniscient, cross-site)
Local device  = tactical reflexes   (fast, limited visibility, pre-programmed)

Brain programs the reflexes in advance.
Reflexes act without waiting for brain.
Brain watches outcomes and reprograms reflexes periodically.
```

Analogous to human motor control — cerebral cortex does not control individual muscle fibers in real time. It pre-programs movement patterns; spinal cord executes them locally.

### Concrete Examples

**Example 1: Marvis Autonomous WAN Healing**  
When Marvis detects a WAN Edge uplink unable to pass traffic (ARP failure or missing ISP IP address), it automatically bounces the port up to three times. No NOC engineer involved. Alert sent with full action log.

**Example 2: Marvis Minis — Predictive**  
Before Minis, an event had to occur before Mist reported it. Marvis Minis continuously performs simulation testing to spot issues before they disrupt service.

```
Old model:   user complains → NOC investigates → root cause found → fix
Mist model:  Marvis simulates connection → detects degradation → fixes before user notices
```

---

## 12. Cisco Silicon One — On-Device AI Reality

### Overview

Cisco Silicon One takes a different approach from Mist — intelligence **embedded in the silicon itself**, not in a cloud platform.

**Reference:** https://blogs.cisco.com/sp/cisco-silicon-one-g300-the-next-wave-of-ai-innovation

### G300 Key Specifications

- 102.4 Tbps Ethernet switching capacity in a single device
- 1.6T Ethernet ports with on-chip integrated 200 Gbps SerDes
- Up to 512 ports ("flatter" network topology)
- 252MB fully shared on-chip packet buffer

### Intelligent Collective Networking Features

**1. Fully Shared Packet Buffer (252MB)**
```
Any packet from any port can occupy any available buffer space.
2.5× increased burst absorption vs. industry alternatives.
Absorbs 9am LLM surge bursts without packet drop.
```

**2. Path-Based Load Balancing**
```
Reacts to instantaneous congestion events in hardware.
100,000× faster than software-based tuning.
~nanoseconds reaction time vs. ~seconds for SD-WAN.
```

**3. Adaptive Packet Processing**
```
P4-programmable pipeline.
Operators write custom packet processing logic.
Compiled to hardware tables at deployment time.
Executes at wire speed as table lookup — not live inference.
```

### What "On-Device AI" Actually Means

Cisco is careful with language. What G300 actually embeds is **not ML inference** in the traditional sense:

```
What they claim:    "AI-optimized silicon"
What actually runs: deterministic algorithms that behave like ML outputs
                    but implemented as hardware logic gates
```

The path-based load balancing is hardware flowlet-based ECMP with congestion feedback — measuring queue depth per port and steering new flowlets away from congestion. This is a **pure hardware state machine**, not model inference.

### Side-by-Side Comparison

| | Juniper Mist AI | Cisco Silicon One G300 |
|---|---|---|
| Intelligence location | Mist Cloud | On-chip silicon |
| Decision path | Cloud → push down | In-hardware, nanoseconds |
| Strength | End-to-end visibility | Wire-speed reaction |
| Weakness | Cloud round-trip lag | Limited to Cisco silicon |
| Layer focus | L2 / L3 / WAN unified | Data center fabric |

### Complementary, Not Competing

```
Mist AI:       solves "what is happening across my whole network"
Silicon One:   solves "react faster than software can"

Combined:      Mist sees the pattern → Silicon One executes the fix
```

---

## 13. The Wire-Speed ML Constraint

### The Fundamental Physics

```
Wire speed constraint (G300):   102.4 Tbps
Per-packet budget at 100G:      ~6.7 nanoseconds per packet
ML inference minimum:           microseconds to milliseconds
Gap:                            100× to 1,000,000× too slow
```

**ML inference and wire-speed forwarding operate in completely different time universes.**

### What "AI at Wire Speed" Actually Means

```
Vendor claim:           "AI at wire speed"
Engineering reality:    AI-informed wire speed

                        AI ──trains──→ rules/tables
                                            ↓
                        Wire speed executes pre-compiled rules

                        AI is NOT in the forwarding path
                        AI is in the RULE GENERATION path
```

No vendor has solved true adaptive ML inference at nanosecond wire speed. The physics does not allow it today.

### Where It Breaks Down

```
Pre-compiled rules work when:     traffic patterns match training distribution
Pre-compiled rules fail when:     novel pattern appears that training didn't cover

Example:
  New RAG framework deployed → new traffic signature
  Silicon table: no matching rule → falls back to default behavior
  Cloud detects anomaly → retrains → pushes new table
  Lag: minutes to hours
  During lag: wrong treatment
```

### What Would Actually Be Needed

**Option 1: Dedicated ML Inference Silicon on Forwarding ASIC**
```
Tiny model (decision tree / small NN) hardwired to silicon.
Latency: ~50–200ns theoretically possible.
Problem: model update requires silicon respin.
```

**Option 2: Near-Chip Inference Accelerator**
```
Small NPU on-package next to forwarding ASIC.
Ultra-low latency on-package bus.
Latency: ~500ns–2μs.
Problem: still 10–100× slower than forwarding ASIC.
         Would cause forwarding pipeline stall.
```

**Option 3: Two Separate Planes (Architecturally Honest)**
```
Forwarding ASIC:  wire speed, rule-based
Inference NPU:    microseconds, ML-based
Slow path:        send flow metadata to NPU
NPU:              updates forwarding rules asynchronously
```

**Option 3 is where the industry is actually heading.** Nobody calls it that because "two separate planes" is less marketable than "AI at wire speed."

### Mist vs. Silicon One — Same Fundamental Architecture

```
Juniper Mist:      AI in cloud    → programs local reflexes → device executes
Cisco Silicon One: AI offline     → compiles to tables      → silicon executes

Both are:          AI-informed forwarding
Neither is:        AI-in-forwarding-path
```

---

## 14. Synthesis: AI-Native WAN Architecture Reference Model

### The Four-Problem Stack

```
Problem                          Solution Layer
────────────────────────────────────────────────────────────
Asymmetric flow profiles         Edge proxy + TCP tuning + predictive BW reservation
Latency / jitter cascade         Jitter buffer + retry discipline + predictive rerouting
Bursty aggregation               Semantic cache + behavioral clock model + adaptive QoS
RAG traffic invisibility         Service graph + behavioral flow classification + eBPF
```

### Full Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    MIST CLOUD / AI CONTROLLER                │
│  Behavioral clock model  │  Cross-site anomaly detection     │
│  Service graph registry  │  Policy compilation & push        │
│  Federated model sync    │  Capacity recommendations         │
└──────────────────────────────────────────────────────────────┘
                    ↕ 10–60s policy loop
┌─────────────────────────────────────────────────────────────┐
│                    ENTERPRISE WAN EDGE (L3)                  │
│  Local Marvis agent      │  Pre-downloaded policy            │
│  Session failover        │  Jitter buffer                    │
│  Link SLA monitoring     │  Stream re-pacing                 │
│  Reaction: ~100–500ms    │                                   │
└──────────────────────────────────────────────────────────────┘
                    ↕ contractual SLA / black box
┌─────────────────────────────────────────────────────────────┐
│              CARRIER CORE (SR-MPLS / SRv6)                   │
│  Metro Ethernet handoff  │  MPLS-TE / Segment Routing        │
│  Zero enterprise visibility inside carrier core              │
└──────────────────────────────────────────────────────────────┘
                    ↕ contractual SLA / black box
┌─────────────────────────────────────────────────────────────┐
│                    REMOTE EDGE (L3)                          │
│  Re-classification after WAN transit                         │
│  Local policy enforcement                                    │
└──────────────────────────────────────────────────────────────┘
```

### Decision Speed Reference

| Layer | Mechanism | Latency | AI Role |
|---|---|---|---|
| Silicon (L2/L3 ASIC) | Hardware state machine | ~100ns | Pre-compiled rules |
| Local software | SSR / local agent | ~100ms | Pre-downloaded policy |
| WAN edge | Jitter buffer / stream proxy | ~1–3s | Rule-based execution |
| Cloud fast path | Emergency remediation push | ~10–30s | Live inference |
| Cloud slow path | Pattern detection + retraining | ~30–120s | Live inference |
| Planning | Capacity + behavioral modeling | minutes–hours | Live inference |

### Key Architectural Principles

1. **Cloud is not in the data path.** AI decides rules; hardware executes rules. Speed comes from pre-compilation, not real-time inference.

2. **MPLS is the floor.** SD-WAN and AI-Native WAN are overlays. Carrier core remains a visibility black box — optimize what you can see.

3. **L2 devices are telemetry sources, not decision nodes.** Model intelligence lives at L3 boundary points where routing decisions and flow visibility intersect.

4. **Heterogeneity is structural, not solvable.** Trust stripping, vendor mapping differences, and operational process velocity create permanent inconsistency windows. Design for resilience to inconsistency, not elimination of it.

5. **"AI at wire speed" is marketing compression.** True architecture is always: AI-informed wire speed — ML in the rule generation path, hardware in the forwarding path.

---

*Document generated from technical research session — May 2026*
