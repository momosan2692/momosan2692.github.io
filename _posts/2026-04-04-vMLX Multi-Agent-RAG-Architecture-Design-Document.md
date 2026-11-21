---
layout: post
title: vMLX Multi-Agent RAG — Architecture Design Document
subtitle: Phase:** P1 
cover-img: /assets/img/header/2026-04-04/design-doc.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-04/design-doc.png
published: true
pinned: false
tags: [draft, ArchDoc, Phase-P1]
---



# vMLX Multi-Agent RAG — Architecture Design Document
**Variant:** Medical (Diagnostic Reasoning + Clinical Data)  
**Phase:** P1  
**Version:** v1.1 — all open decisions locked  
**Hardware:** 3× Mac mini M4 Pro 48 GB  
**Inference engine:** vMLX (vmlx.net · PyPI: vmlx · Apache 2.0)  
**Date:** 2026-04-03  
**Author:** CJH  
**Compliance baseline:** HIPAA Safe Harbor · FDA SaMD awareness · Human-in-the-loop required

---

## Table of Contents

1. [Scope and Goals](#1-scope-and-goals)
2. [Hardware Topology](#2-hardware-topology)
3. [Node Responsibilities](#3-node-responsibilities)
4. [vMLX Configuration per Node](#4-vmlx-configuration-per-node)
5. [SSH Tunnel Transport](#5-ssh-tunnel-transport)
6. [Medical Aggregator Agent Design](#6-medical-aggregator-agent-design)
7. [Agent Definitions](#7-agent-definitions)
8. [PHI Boundary and De-identification](#8-phi-boundary-and-de-identification)
9. [Data Flow](#9-data-flow)
10. [Timer-Gated Decision Policy](#10-timer-gated-decision-policy)
11. [Audit Log Design](#11-audit-log-design)
12. [PKM Plugin Contract](#12-pkm-plugin-contract)
13. [Security Model](#13-security-model)
14. [P1 Milestone Breakdown](#14-p1-milestone-breakdown)
15. [Open Decisions](#15-open-decisions)

---

## 1. Scope and Goals

### 1.1 What P1 Delivers

A fully operational **Medical Multi-Agent RAG** system across 3 Mac mini M4 Pro nodes, with:

- vMLX inference engines on Node 1 (Clinical Data RAG) and Node 2 (Diagnostic Reasoning)
- **PHI confined to Node 1 and Node 2 only** — never transmitted to cloud endpoints
- De-identification layer on Node 0 before any cloud agent sub-task is constructed
- Medical Aggregator as a full reasoning agent — not a router — with timer-gated decision policy
- Append-only audit log on Node 0 (PHI-free; records what happened, not what was asked)
- Mandatory AI-generated disclaimer on all outputs
- PKM platform integration via `pkm.plugin.json`
- Temporal workflow engine with per-agent activity timeout mapped to timer-gated policy

### 1.2 What P1 Explicitly Excludes

- Generic Coding Agent variant — covered in `vmlx_multiagent_arch_v1.md`
- Real EMR system integration (Epic, Cerner) — P1 uses local FHIR-format fixture data
- Fine-tuning or LoRA adaptation — deferred
- Multi-clinician session management — single-user P1
- Full HIPAA BAA / formal compliance audit — architecture is designed to be compliant; formal audit deferred
- Automated failover — manual fallback only in P1

### 1.3 Core Design Constraints

| Constraint | Rule |
|-----------|------|
| **PHI boundary** | PHI stays on Node 1 and Node 2 only. Node 0 holds PHI transiently in Aggregator memory during reasoning — never persists it |
| **Cloud dispatch** | Agents 3 and 4 (cloud-facing) receive only de-identified sub-tasks. Zero PHI crosses the cloud boundary |
| **Aggregator is a reasoning agent** | Decomposes, dispatches, reads, conflict-checks, re-assigns, sanitizes. Never a passive router |
| **Context isolation** | Each agent receives its sub-task only — no other agent's sub-task or result included |
| **Timer-gated synthesis** | Aggregator does not wait indefinitely. At Tw per agent, it synthesizes with what has arrived |
| **Audit trail required** | All dispatch events logged (PHI-free). Clinician ID + encounter ID + query hash only |
| **Disclaimer required** | All outputs carry: *AI-generated · not clinical advice · review by licensed clinician required* |
| **Human-in-the-loop** | Any `CONFLICT_UNRESOLVED` or `STALE_DATA` or high-risk output requires clinician confirmation |

---

## 2. Hardware Topology

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Local Clinical Network                         │
│                      (private LAN — no public exposure)             │
│                                                                      │
│  ┌───────────────────────┐  SSH   ┌────────────────────────────┐   │
│  │       NODE 0          │───────▶│         NODE 1             │   │
│  │   Mac mini M4 Pro     │◀───────│     Mac mini M4 Pro        │   │
│  │       48 GB           │ tunnel │         48 GB              │   │
│  │                       │        │                            │   │
│  │  Medical Aggregator   │        │  vMLX  :8000               │   │
│  │  Agent 3  Literature  │        │  Agent 1  Clinical RAG     │   │
│  │  Agent 4  Drug/Rx     │        │  EMR fixtures (FHIR)       │   │
│  │  De-id layer          │        │  Lab / imaging reports     │   │
│  │  Audit log            │        │  PHI stays here            │   │
│  │  PKM platform         │        │  Vector store (clinical)   │   │
│  │  Temporal server      │        └────────────────────────────┘   │
│  │                       │  SSH   ┌────────────────────────────┐   │
│  │  localhost:8001       │───────▶│         NODE 2             │   │
│  │  (→ N1:8000)          │◀───────│     Mac mini M4 Pro        │   │
│  │  localhost:8002       │ tunnel │         48 GB              │   │
│  │  (→ N2:8000)          │        │                            │   │
│  └───────────────────────┘        │  vMLX  :8000               │   │
│              │                    │  Agent 2  Dx Reasoning     │   │
│   PHI never  │ HTTPS (de-id only) │  Differential Dx engine    │   │
│   crosses    ▼                    │  PHI stays here            │   │
│         External APIs             └────────────────────────────┘   │
│         PubMed · WHO · FDA Drug                                     │
│         Anthropic / OpenAI  ← de-identified sub-tasks only         │
└─────────────────────────────────────────────────────────────────────┘

PHI boundary:  ████ Node 1 + Node 2 only ████
Cloud boundary: ─ ─ ─ de-identified sub-tasks only ─ ─ ─
```

### 2.1 Node Addressing

| Node | Hostname | Role | Notes |
|------|----------|------|-------|
| Node 0 | `cjh-node0.local` | Medical Aggregator, PKM, Temporal, Audit | No model weights; no PHI persistence |
| Node 1 | `cjh-node1.local` | Clinical Data RAG — PHI node | EMR fixtures, labs, imaging reports |
| Node 2 | `cjh-node2.local` | Diagnostic Reasoning — PHI node | Differential Dx, clinical CoT |

---

## 3. Node Responsibilities

### Node 0 — Medical Orchestration Node

**Runs:** Medical Aggregator agent, Agent 3 (Literature API proxy), Agent 4 (Drug/Rx API proxy), de-identification module, append-only audit log, PKM platform, Temporal server  
**Does not run:** any vMLX inference instance  
**PHI status:** Holds PHI transiently in Aggregator working memory during reasoning step; **never persists PHI to disk, logs, or external calls**  
**Outbound:** SSH to Node 1 and Node 2; HTTPS to PubMed/WHO/FDA APIs (de-identified only); HTTPS to cloud LLM (de-identified only)  
**Memory allocation:** ~6 GB for PKM + Temporal + Aggregator + de-id module headroom

### Node 1 — Clinical Data RAG Node (PHI node)

**Runs:** vMLX serving a medical domain LLM; Agent 1 (Clinical Data RAG) process; local FHIR-format clinical fixture store; clinical vector index  
**PHI status:** PHI lives here — EMR records, lab panels, imaging reports, allergy records, medication history  
**Agent:** Agent 1 calls vMLX on `localhost:8000`; performs retrieval from local clinical store and returns result summary to Aggregator via SSH tunnel  
**Model target:** `mlx-community/BioMistral-7B-4bit` or `mlx-community/Llama3-OpenBioLLM-8B-4bit` (TBD — see §15)  
**Memory allocation:** ~20 GB model weights + KV cache + fixture data + vector index

### Node 2 — Diagnostic Reasoning + Synthesis Node (PHI node)

**Runs:** vMLX serving Qwen3-8B-4bit; Agent 2 (Diagnostic Reasoning) process  
**PHI status:** PHI lives here during Agent 2 sub-task B; STEP 5 synthesis input is de-identified before routing here  
**Agent:** Agent 2 calls vMLX on `localhost:8000`; generates differential diagnosis lists, clinical reasoning chains, and structured clinical assessments  
**Synthesis:** Aggregator STEP 5 also routes to Node 2 vMLX for final output generation — same model instance, served via continuous batching. Agent 2 and STEP 5 calls are sequential per query; no contention.  
**Model target:** `mlx-community/Qwen3-8B-4bit` with `--reasoning-parser auto` (locked)  
**Memory allocation:** ~20 GB model weights + KV cache + reasoning headroom

---

## 4. vMLX Configuration per Node

### 4.1 Node 1 — Clinical Data RAG

```bash
vmlx serve mlx-community/BioMistral-7B-4bit \
  --host 127.0.0.1 \
  --port 8000 \
  --api-key ${VMLX_NODE1_KEY} \
  --continuous-batching \
  --enable-prefix-cache \
  --use-paged-cache \
  --kv-cache-quantization q8 \
  --enable-disk-cache \
  --enable-jit \
  --tool-call-parser auto
```

**Embedding sidecar** (for clinical vector index):

```bash
# If vMLX co-serving not available: second instance on port 8001
vmlx serve mlx-community/bge-m3 \
  --host 127.0.0.1 \
  --port 8001 \
  --api-key ${VMLX_NODE1_EMB_KEY} \
  --embedding-only
```

### 4.2 Node 2 — Diagnostic Reasoning

```bash
vmlx serve mlx-community/Qwen3-8B-4bit \
  --host 127.0.0.1 \
  --port 8000 \
  --api-key ${VMLX_NODE2_KEY} \
  --continuous-batching \
  --enable-prefix-cache \
  --use-paged-cache \
  --kv-cache-quantization q8 \
  --enable-disk-cache \
  --enable-jit \
  --reasoning-parser auto \
  --tool-call-parser auto
```

`--reasoning-parser auto` enables structured CoT output — critical for differential diagnosis chains that the Aggregator must read and evaluate.

### 4.3 KV Cache Budget

| Node | Model | Est. weight (4-bit) | KV cache (q8) | Disk cache |
|------|-------|---------------------|---------------|------------|
| Node 1 | BioMistral-7B-4bit | ~4.0 GB | ~10 GB | enabled |
| Node 2 | Qwen3-8B-4bit | ~4.5 GB | ~10 GB | enabled |

48 GB unified memory per node gives substantial headroom. Clinical RAG on Node 1 holds additional fixture + vector index data (~2–4 GB depending on corpus size).

---

## 5. SSH Tunnel Transport

### 5.1 Persistent Tunnels (Node 0)

```bash
# Node 0 startup — autossh persistent tunnels

autossh -M 0 -N \
  -o "ServerAliveInterval 30" \
  -o "ServerAliveCountMax 3" \
  -o "ExitOnForwardFailure yes" \
  -L 8001:127.0.0.1:8000 cjh-node1.local &   # Node 1 chat model

autossh -M 0 -N \
  -o "ServerAliveInterval 30" \
  -o "ServerAliveCountMax 3" \
  -o "ExitOnForwardFailure yes" \
  -L 8011:127.0.0.1:8001 cjh-node1.local &   # Node 1 embedding model

autossh -M 0 -N \
  -o "ServerAliveInterval 30" \
  -o "ServerAliveCountMax 3" \
  -o "ExitOnForwardFailure yes" \
  -L 8002:127.0.0.1:8000 cjh-node2.local &   # Node 2 reasoning model
```

### 5.2 Endpoint Map (from Node 0)

| Agent | Endpoint on Node 0 | Resolves to | PHI in transit? |
|-------|--------------------|-------------|-----------------|
| Agent 1 — Clinical RAG | `http://localhost:8001/v1/chat/completions` | Node 1 vMLX | **YES** — SSH encrypted |
| Agent 1 — Embeddings | `http://localhost:8011/v1/embeddings` | Node 1 vMLX | **YES** — SSH encrypted |
| Agent 2 — Dx Reasoning | `http://localhost:8002/v1/chat/completions` | Node 2 vMLX | **YES** — SSH encrypted |
| Agent 3 — Literature | `https://pubmed.ncbi.nlm.nih.gov/` etc. | External API | **NO** — de-identified |
| Agent 4 — Drug/Rx | `https://api.fda.gov/` etc. | External API | **NO** — de-identified |

PHI in transit between Node 0 and Node 1/2 is always inside SSH tunnel — encrypted, private-key authenticated.

---

## 6. Medical Aggregator Agent Design

### 6.1 The Five Steps (Medical Variant)

```
STEP 1  READ & DECOMPOSE
        Read full clinical query — may include PHI.
        Reason: which agents are needed for this query?
        Not all 4 agents are invoked on every query.
        For each agent determine: does this sub-task require PHI?
          · Agent 1 (Clinical RAG)  → YES — sub-task includes PHI
          · Agent 2 (Dx Reasoning)  → YES — sub-task includes PHI
          · Agent 3 (Literature)    → NO  — construct de-identified sub-task
          · Agent 4 (Drug/Rx)       → NO  — construct de-identified sub-task
        Produce: sub-tasks A, B (with PHI), C, D (de-identified).

STEP 2  DISPATCH (parallel)
        Send sub-tasks A, B via SSH tunnels to Node 1, Node 2.
        Send sub-tasks C, D via HTTPS to external APIs.
        Start per-agent countdown timers.
        Log dispatch event to audit log (PHI-free — query hash + agent IDs + timestamp).

STEP 3  WAIT (timer-gated)
        Buffer results as they arrive.
        At each agent's Tw deadline:
          · arrived  → mark ARRIVED
          · absent   → mark TIMEOUT → apply fallback (§10)
        At Tw_max = 30 000 ms: proceed regardless.

STEP 4  READ & CONFLICT-CHECK
        Read all arrived results.
        Apply clinical evidence hierarchy (§6.3) to weight results.
        If contradiction detected → re-assign clarification sub-task.
        If timeout on safety-critical agent → hard-block affected recommendation.
        If conflict unresolvable → flag CONFLICT_UNRESOLVED → route to human-in-the-loop.

STEP 5  MERGE, SANITIZE & SYNTHESIZE
        Construct final clinical summary from weighted results.
        Strip any residual PHI identifiers from synthesis input.
        Route to Node 2 vMLX (Qwen3-8B-4bit) for final synthesis generation.
        Synthesis input is de-identified before crossing to Node 2.
        Full inference pipeline stays on-premise — no cloud call in STEP 5.
        Append mandatory AI disclaimer to output.
        Stream via PKM SSE.
        Log synthesis event to audit log (PHI-free).
```

### 6.2 Clinical Evidence Hierarchy

```
Patient-specific data (Agent 1: EMR, labs, allergies, medications)  ← highest
      ↓
Diagnostic reasoning chain (Agent 2: differential Dx, clinical CoT)
      ↓
Clinical guidelines & RCT evidence (Agent 3: PubMed, WHO, Cochrane)
      ↓
Drug / interaction database (Agent 4: FDA, DrugBank, RxNorm)        ← domain-specific
```

**Safety override:** any contraindication flag from Agent 1 (allergy, renal impairment, existing medication conflict) or Agent 4 (DDI) takes absolute precedence and hard-blocks the conflicting recommendation regardless of hierarchy position.

### 6.3 Mandatory Output Disclaimer

Appended to every output by the Aggregator before streaming:

```
---
⚕ AI-GENERATED CLINICAL SUMMARY
This output was generated by an AI system. It is not clinical advice,
not a diagnosis, and not a treatment recommendation. It must be
reviewed and validated by a licensed clinician before any clinical
decision is made. The system may be incomplete or incorrect.
---
```

---

## 7. Agent Definitions

### Agent 1 — Clinical Data RAG

| Property | Value |
|----------|-------|
| **Node** | Node 1 (PHI node) |
| **Access from Node 0** | `http://localhost:8001/v1/chat/completions` |
| **Model** | BioMistral-7B-4bit (via vMLX) |
| **Role** | Retrieval over local clinical data; returns relevant clinical context |
| **Data sources** | FHIR-format EMR fixtures, lab results, imaging reports, medication history, allergy records |
| **Vector store** | FAISS on Node 1 (P1); indexed from FHIR fixture corpus |
| **Embedding model** | bge-m3 on Node 1 port 8001 |
| **PHI handling** | Sub-task A includes PHI; result returned to Aggregator via SSH tunnel only |
| **Receives** | Sub-task A only (PHI-inclusive) |
| **Returns** | Retrieved clinical passages + short synthesis; structured with LOINC/ICD-10 codes where applicable |

### Agent 2 — Diagnostic Reasoning

| Property | Value |
|----------|-------|
| **Node** | Node 2 (PHI node) |
| **Access from Node 0** | `http://localhost:8002/v1/chat/completions` |
| **Model** | Qwen3-8B-4bit with `--reasoning-parser auto` (via vMLX) |
| **Role** | Differential diagnosis generation; clinical reasoning chains (CoT); structured clinical assessment |
| **PHI handling** | Sub-task B includes PHI; result returned to Aggregator via SSH tunnel only |
| **Receives** | Sub-task B only (PHI-inclusive); may include clinical context pre-fetched by Aggregator from Agent 1 result |
| **Returns** | Ranked differential diagnosis list + CoT reasoning chain + confidence scores + flags for urgent findings |

**Structured output format (returned to Aggregator):**

```json
{
  "differential_dx": [
    {"rank": 1, "condition": "...", "icd10": "...", "confidence": 0.82, "rationale": "..."},
    {"rank": 2, "condition": "...", "icd10": "...", "confidence": 0.61, "rationale": "..."}
  ],
  "urgent_flags": ["..."],
  "reasoning_chain": "...",
  "recommended_workup": ["..."],
  "confidence_overall": 0.74
}
```

### Agent 3 — Medical Literature

| Property | Value |
|----------|-------|
| **Node** | Node 0 (cloud-proxy) |
| **Access** | PubMed API, Cochrane, WHO guidelines, UpToDate (HTTPS direct) |
| **Role** | Evidence retrieval: RCTs, systematic reviews, clinical practice guidelines, drug monographs |
| **PHI handling** | Sub-task C is **de-identified** — zero PHI; clinical question only |
| **Receives** | Sub-task C only (de-identified clinical question) |
| **Returns** | Evidence summaries with source citations (PMID, guideline ID, publication year) |

### Agent 4 — Drug / Rx

| Property | Value |
|----------|-------|
| **Node** | Node 0 (cloud-proxy) |
| **Access** | FDA Drug API (`api.fda.gov`), DrugBank, RxNorm API (HTTPS direct) |
| **Role** | Drug interaction check, contraindication lookup, dosing calculator, allergy cross-check |
| **PHI handling** | Sub-task D is **de-identified** — drug names and condition only, no patient identifiers |
| **Receives** | Sub-task D only (de-identified: drug list + clinical condition) |
| **Returns** | DDI flags, contraindication alerts, dosing guidance, allergy warnings; structured JSON |

**Structured output format (returned to Aggregator):**

```json
{
  "interactions": [
    {"drug_a": "...", "drug_b": "...", "severity": "major|moderate|minor", "description": "..."}
  ],
  "contraindications": ["..."],
  "dosing": {"drug": "...", "recommended_dose": "...", "adjustment": "..."},
  "allergy_flags": ["..."]
}
```

---

## 8. PHI Boundary and De-identification

### 8.1 PHI Boundary Map

```
╔══════════════════════════════════════════════════╗
║               PHI ZONE                          ║
║                                                  ║
║  Node 1  — EMR fixtures, labs, imaging           ║
║  Node 2  — Diagnostic reasoning with PHI         ║
║  Node 0 Aggregator working memory (transient)    ║
║                                                  ║
║  PHI never written to:                           ║
║    · audit log                                   ║
║    · cloud sub-tasks (C, D)                      ║
║    · PKM SSE stream (output is synthesized)      ║
║    · Temporal workflow history                   ║
╚══════════════════════════════════════════════════╝

─ ─ ─ ─ ─ ─  DE-IDENTIFICATION BOUNDARY  ─ ─ ─ ─ ─ ─

╔══════════════════════════════════════════════════╗
║           NON-PHI ZONE                          ║
║                                                  ║
║  Sub-tasks C, D (de-identified)                  ║
║  External APIs (Literature, Drug/Rx)             ║
║  Cloud LLM (synthesis step)                      ║
║  Audit log                                       ║
╚══════════════════════════════════════════════════╝
```

### 8.2 HIPAA Safe Harbor — 18 Identifiers Stripped

The de-identification module on Node 0 strips or replaces all 18 Safe Harbor identifiers before constructing sub-tasks C and D:

| # | Identifier | De-id action |
|---|-----------|--------------|
| 1 | Names | Replace with `[PATIENT]` |
| 2 | Geographic data (below state) | Replace with `[LOCATION]` |
| 3 | Dates (except year) | Replace with `[DATE]` or year only |
| 4 | Phone numbers | Remove |
| 5 | Fax numbers | Remove |
| 6 | Email addresses | Remove |
| 7 | Social security numbers | Remove |
| 8 | Medical record numbers | Replace with `[MRN]` |
| 9 | Health plan beneficiary numbers | Remove |
| 10 | Account numbers | Remove |
| 11 | Certificate / license numbers | Remove |
| 12 | Vehicle identifiers | Remove |
| 13 | Device identifiers | Remove |
| 14 | URLs | Remove |
| 15 | IP addresses | Remove |
| 16 | Biometric identifiers | Remove |
| 17 | Full-face photographs | Remove |
| 18 | Any other unique identifier | Flag for review |

**Implementation (P1):** rule-based NER using `spacy` + `presidio-analyzer` (Microsoft Presidio) on Node 0. No ML model required for de-id in P1 — rule-based is sufficient for structured FHIR-format data.

### 8.3 De-identification Module Interface

```python
class DeidentificationModule:
    def deidentify(self, text: str, context: DeIdContext) -> DeIdResult:
        """
        Strip all 18 Safe Harbor identifiers from text.
        Returns: cleaned text + list of redacted spans for audit.
        Raises: DeIdFailureError if any identifier cannot be
                safely handled — blocks dispatch to cloud.
        """
        ...

    def verify(self, text: str) -> bool:
        """
        Post-strip verification pass.
        Returns False if any residual identifier pattern detected.
        If False: dispatch is BLOCKED; Aggregator logs and escalates.
        """
        ...
```

De-identification is a **blocking step** — if `verify()` returns `False`, the cloud sub-task is not dispatched. The Aggregator proceeds with PHI-node agents only and flags the output `DEIDENTIFICATION_FAILED`.

---

## 9. Data Flow

### 9.1 Happy Path

```
Clinician query (full — may include PHI)
    │
    ▼
Medical Aggregator (Node 0)
  STEP 1: decompose → sub-tasks A, B (PHI), C, D (de-id)
    │
    ├── sub-task A (PHI) ──SSH──▶ Agent 1 (Node 1 vMLX)
    │                              EMR + lab retrieval
    │                              ◀── clinical context ──────────┐
    │                                                              │
    ├── sub-task B (PHI) ──SSH──▶ Agent 2 (Node 2 vMLX)          │
    │                              differential Dx + CoT           │
    │                              ◀── structured Dx result ───────┤
    │                                                              │
    ├── sub-task C (de-id) ──HTTPS──▶ Agent 3 (PubMed/WHO)        │
    │                                  evidence summaries          │
    │                                  ◀── citations + summaries ──┤
    │                                                              │
    └── sub-task D (de-id) ──HTTPS──▶ Agent 4 (FDA/DrugBank)      │
                                       DDI + contraindications     │
                                       ◀── drug safety flags ──────┘
                                                              │
    Aggregator STEP 3: wait (timer-gated)                    │
    Aggregator STEP 4: evidence hierarchy + conflict check   │
    Aggregator STEP 5: merge + strip residual PHI ◀──────────┘
                       → cloud synthesis (de-identified)
                       → append disclaimer
    │
    ▼
PKM SSE stream ──▶ Clinician client
```

### 9.2 Timeout Paths

```
Agent 1 (Clinical RAG) timeout:
  → NO patient-specific context available
  → HARD BLOCK: drug dosing, allergy-dependent recommendations suppressed
  → flag: ⚠ CLINICAL_DATA_UNAVAILABLE
  → escalate to clinician: manual record lookup required
  → proceed with Agents 2, 3, 4 only if safe to do so

Agent 2 (Dx Reasoning) timeout:
  → no differential Dx available
  → flag: ⚠ DIAGNOSTIC_REASONING_UNAVAILABLE
  → Aggregator can attempt basic Dx synthesis from Agent 1 + Agent 3 evidence
  → output marked: INCOMPLETE — diagnostic reasoning unavailable

Agent 3 (Literature) timeout:
  → no evidence citations available
  → flag: ⚠ LITERATURE_UNAVAILABLE
  → degrade: proceed without guideline citations
  → output still generated from PHI-node results

Agent 4 (Drug/Rx) timeout:
  → no drug interaction / dosing data
  → HARD BLOCK: any drug-related recommendation suppressed
  → flag: ⚠ DRUG_DB_UNAVAILABLE
  → clinician must perform manual drug check before acting
```

### 9.3 Conflict Path

```
Agent 2 Dx result contradicts Agent 3 guideline evidence:
  │
  ├─ Apply clinical evidence hierarchy:
  │     Agent 1 patient-specific data (allergies, labs)
  │           → if determinative: resolve
  │     Agent 3 RCT / CPG evidence
  │           → if determinative: resolve
  │
  ├─ Still unresolved?
  │     → re-assign: Agent 2 re-queries with Agent 3 evidence included
  │       inner Tw = 5 000 ms
  │
  └─ Still unresolved after re-assignment?
        → flag: CONFLICT_UNRESOLVED
        → surface both results with provenance labels to clinician
        → BLOCK final recommendation on conflicted dimension
        → human-in-the-loop review required
```

---

## 10. Timer-Gated Decision Policy

```
T = 0 ms      Medical Aggregator dispatches Agents 1–4 in parallel
              Per-agent timers start simultaneously

T = n ms      Result arrives early → buffered; timer still running

T = Tw(A1)    Agent 1 deadline = 12 000 ms
              · arrived  → ARRIVED; proceed
              · absent   → TIMEOUT; apply Agent 1 fallback (§9.2)

T = Tw(A4)    Agent 4 deadline = 6 000 ms
              · arrived  → ARRIVED
              · absent   → TIMEOUT; hard-block drug recommendations

T = Tw(A3)    Agent 3 deadline = 8 000 ms
              · arrived  → ARRIVED
              · absent   → TIMEOUT; degrade gracefully

T = Tw(A2)    Agent 2 deadline = 20 000 ms
              · arrived  → ARRIVED (reasoning model needs time)
              · absent   → TIMEOUT; flag Dx reasoning unavailable

T = Tw_max    Global hard deadline = 30 000 ms
              Aggregator proceeds with whatever has arrived
              All absent agents treated as TIMEOUT
```

### Per-Agent Timeout Table

| Agent | Backend | Tw | Safety action on timeout |
|-------|---------|-----|--------------------------|
| Agent 1 Clinical RAG | Node 1 vMLX (local) | **12 000 ms** | Hard-block drug + allergy recommendations |
| Agent 2 Dx Reasoning | Node 2 vMLX (local) | **20 000 ms** | Flag DIAGNOSTIC_UNAVAILABLE; degrade |
| Agent 3 Literature | PubMed / WHO (HTTPS) | **8 000 ms** | Degrade; no citations in output |
| Agent 4 Drug/Rx | FDA / DrugBank (HTTPS) | **6 000 ms** | Hard-block any drug recommendation |
| Re-assignment inner loop | Any | **5 000 ms** | On miss: CONFLICT_UNRESOLVED |
| **Tw_max global** | All agents | **30 000 ms** | Partial synthesis; all flags surfaced |

All values configurable in `pkm_config.yaml` under `medical_aggregator.timeouts`.

---

## 11. Audit Log Design

### 11.1 What Is Logged (PHI-free)

```json
{
  "event_type": "dispatch|result|conflict|timeout|synthesis|disclaimer_appended",
  "ts_utc": "2026-04-03T10:23:41.123Z",
  "session_id": "sha256-hash-of-session",
  "query_hash": "sha256-of-query-text",
  "clinician_id": "cjh-001",
  "encounter_id": "ENC-20260403-001",
  "agent": "agent_1_clinical_rag",
  "status": "ARRIVED|TIMEOUT|PARTIAL|CONFLICT_UNRESOLVED",
  "latency_ms": 4210,
  "flags": ["STALE_DATA", "DRUG_DB_UNAVAILABLE"],
  "note": "..."
}
```

**What is NOT logged:** patient name, DOB, MRN, diagnosis, medications, any free-text clinical content, any PHI.

### 11.2 Audit Log Storage

- **Format:** append-only NDJSON (one JSON object per line)
- **Location:** Node 0 local filesystem — `/var/log/medical-rag/audit.ndjson`
- **Rotation:** daily, retained 7 years (HIPAA minimum)
- **Integrity:** each entry SHA-256 chained to previous entry hash — tamper detection
- **Access:** read-only to PKM platform; write-only to Aggregator process
- **Backup:** rsync to encrypted external volume; P1 manual backup

### 11.3 Audit Log Writer Interface

```python
class AuditLog:
    def log(self, event: AuditEvent) -> None:
        """
        Append PHI-free audit event.
        Raises: AuditWriteError if write fails.
        On error: Aggregator HALTS — cannot proceed without audit trail.
        """
        ...
```

Audit log failure is a **hard stop** — the Aggregator will not process a clinical query if it cannot write to the audit log.

---

## 12. PKM Plugin Contract

### 12.1 `pkm.plugin.json`

```json
{
  "plugin": "vmlx-multiagent-medical",
  "version": "1.0.0",
  "description": "Medical Multi-Agent RAG — Clinical Decision Support variant",
  "transport": "ssh_tunnel",
  "compliance": ["HIPAA_SafeHarbor"],

  "agents": {
    "clinical_rag": {
      "node": "node1",
      "base_url": "http://localhost:8001/v1",
      "api_key_env": "VMLX_NODE1_KEY",
      "model": "mlx-community/BioMistral-7B-4bit",
      "role": "clinical_data_retrieval",
      "phi_bearing": true,
      "timeout_ms": 12000,
      "embedding_url": "http://localhost:8011/v1/embeddings",
      "embedding_model": "mlx-community/bge-m3"
    },
    "diagnostic_reasoning": {
      "node": "node2",
      "base_url": "http://localhost:8002/v1",
      "api_key_env": "VMLX_NODE2_KEY",
      "model": "mlx-community/Qwen3-8B-4bit",
      "role": "differential_diagnosis",
      "phi_bearing": true,
      "timeout_ms": 20000
    },
    "literature": {
      "node": "node0",
      "type": "api",
      "providers": ["pubmed", "who_guidelines", "cochrane"],
      "role": "evidence_retrieval",
      "phi_bearing": false,
      "timeout_ms": 8000
    },
    "drug_rx": {
      "node": "node0",
      "type": "api",
      "providers": ["fda_drug_api", "rxnorm", "drugbank"],
      "role": "drug_interaction_check",
      "phi_bearing": false,
      "timeout_ms": 6000
    }
  },

  "medical_aggregator": {
    "synthesis_agent": "diagnostic_reasoning",
    "synthesis_base_url": "http://localhost:8002/v1",
    "synthesis_api_key_env": "VMLX_NODE2_KEY",
    "synthesis_model": "mlx-community/Qwen3-8B-4bit",
    "synthesis_note": "STEP 5 routes to Node 2 vMLX — same instance as Agent 2; input is de-identified before dispatch",
    "global_timeout_ms": 30000,
    "max_reassignment_depth": 2,
    "conflict_policy": "clinical_evidence_hierarchy",
    "deidentification": {
      "module": "presidio",
      "verify_pass": true,
      "block_on_failure": true
    },
    "audit_log": {
      "path": "/var/log/medical-rag/audit.ndjson",
      "required": true,
      "block_on_write_failure": true
    },
    "disclaimer_required": true,
    "human_in_loop_triggers": [
      "CONFLICT_UNRESOLVED",
      "STALE_DATA",
      "CLINICAL_DATA_UNAVAILABLE",
      "DEIDENTIFICATION_FAILED"
    ]
  },

  "tunnels": {
    "node1_chat": {"local_port": 8001, "remote_host": "cjh-node1.local", "remote_port": 8000},
    "node1_embed": {"local_port": 8011, "remote_host": "cjh-node1.local", "remote_port": 8001},
    "node2_chat": {"local_port": 8002, "remote_host": "cjh-node2.local", "remote_port": 8000}
  },

  "sse": {
    "endpoint": "/v1/medical/stream",
    "intermediate_events": true,
    "agent_progress_events": true,
    "disclaimer_event": true
  },

  "temporal": {
    "namespace": "vmlx-medical",
    "task_queue": "medical-aggregator-queue",
    "workflow_execution_timeout_s": 60,
    "activity_retry_max_attempts": 1
  }
}
```

> `activity_retry_max_attempts: 1` — medical queries do not auto-retry silently. A failed agent is handled by the timeout fallback policy, not by transparent retry.

### 12.2 SSE Event Schema (Medical)

```
event: agent_dispatch
data: {"agent": "clinical_rag", "phi_bearing": true, "task_id": "...", "ts": 0}

event: agent_result
data: {"agent": "clinical_rag", "status": "ARRIVED", "latency_ms": 3210, "ts": 3210}

event: deidentification
data: {"status": "PASS|FAIL", "agents_cleared": ["literature", "drug_rx"]}

event: conflict_detected
data: {"agents": ["diagnostic_reasoning", "literature"], "resolution": "pending|resolved|escalated"}

event: synthesis_chunk
data: {"chunk": "...", "done": false}

event: synthesis_chunk
data: {"chunk": "", "done": true,
       "flags": ["DRUG_DB_UNAVAILABLE"],
       "disclaimer": true}

event: human_review_required
data: {"trigger": "CONFLICT_UNRESOLVED", "dimension": "treatment_recommendation"}
```

### 12.3 Temporal Workflow Skeleton

```python
@workflow.defn
class MedicalRAGWorkflow:
    @workflow.run
    async def run(self, query: str, clinician_id: str, encounter_id: str) -> MedicalResponse:

        # STEP 1: decompose (PHI-aware)
        tasks = await workflow.execute_activity(
            medical_decompose, (query, clinician_id, encounter_id),
            schedule_to_close_timeout=timedelta(seconds=10)
        )

        # STEP 2: dispatch in parallel (no retry — timeout = fallback)
        results = await asyncio.gather(
            workflow.execute_activity(
                run_phi_agent, ("clinical_rag", tasks.A),
                schedule_to_close_timeout=timedelta(milliseconds=12000)
            ),
            workflow.execute_activity(
                run_phi_agent, ("diagnostic_reasoning", tasks.B),
                schedule_to_close_timeout=timedelta(milliseconds=20000)
            ),
            workflow.execute_activity(
                run_deidentified_agent, ("literature", tasks.C),
                schedule_to_close_timeout=timedelta(milliseconds=8000)
            ),
            workflow.execute_activity(
                run_deidentified_agent, ("drug_rx", tasks.D),
                schedule_to_close_timeout=timedelta(milliseconds=6000)
            ),
            return_exceptions=True  # timeout = exception, not crash
        )

        # STEP 4: conflict check + safety evaluation
        checked = await workflow.execute_activity(
            medical_conflict_check, (results, clinician_id),
            schedule_to_close_timeout=timedelta(seconds=8)
        )

        # STEP 5: sanitize + synthesize + disclaimer
        return await workflow.execute_activity(
            medical_synthesize, (checked, encounter_id),
            schedule_to_close_timeout=timedelta(seconds=15)
        )
```

---

## 13. Security Model

| Control | Detail |
|---------|--------|
| **vMLX bind** | `127.0.0.1` only — no LAN exposure on Node 1 or Node 2 |
| **Cross-node transport** | SSH tunnel (autossh); Node 0 is the only client authorized |
| **SSH auth** | Public key only; Node 0 key authorized on Node 1 and Node 2 |
| **vMLX API key** | Per-node key; checked before inference |
| **PHI confinement** | PHI written only to Node 1 and Node 2 storage; never to Node 0 disk |
| **Audit log write** | Aggregator process only; read-only to PKM; no PHI in log |
| **De-identification** | Blocking step + verify pass before any cloud dispatch |
| **Cloud dispatch** | Sub-tasks C and D are de-identified; verified before send |
| **Temporal history** | No PHI in Temporal workflow history — query hash only |
| **SSE stream** | Output is synthesized (not raw retrieved PHI); disclaimer appended |
| **Secret management** | All API keys via environment variables; never in `pkm.plugin.json` on disk |

---

## 14. P1 Milestone Breakdown

### M1 — Infrastructure (week 1)
- [ ] Install vMLX on Node 1 and Node 2
- [ ] Serve BioMistral-7B-4bit on Node 1 port 8000; verify `/v1/chat/completions`
- [ ] Serve bge-m3 embedding model on Node 1 port 8001; verify `/v1/embeddings`
- [ ] Serve Qwen3-8B-4bit with `--reasoning-parser auto` on Node 2; verify response
- [ ] Configure SSH keys Node 0 → Node 1, Node 0 → Node 2
- [ ] Establish 3 autossh tunnels (8001, 8011, 8002); verify health probes from Node 0

### M2 — Clinical data fixtures + pgvector (week 1–2)
- [ ] Install PostgreSQL + pgvector extension on Node 1
- [ ] Create `clinical_rag` database; enable `vector` extension; configure `127.0.0.1` bind
- [ ] Prepare FHIR R4 format clinical fixture dataset (synthetic patients — no real PHI in dev)
- [ ] Define pgvector schema: `documents(id, content, embedding vector(1024), metadata jsonb, fhir_resource_type text)`
- [ ] Build vector index on Node 1: embed fixture corpus with bge-m3 → store in pgvector
- [ ] Implement hybrid retrieval: pgvector ANN search + FHIR field filter (SQL `WHERE` on `metadata`)
- [ ] Implement Agent 1 stub: pgvector retrieval + vMLX synthesis; verify round-trip via tunnel
- [ ] Implement Agent 2 stub: pass clinical context to Qwen3 reasoning; verify structured Dx output

### M3 — De-identification module (week 2)
- [ ] Install `presidio-analyzer` and `presidio-anonymizer` on Node 0
- [ ] Implement `DeidentificationModule.deidentify()` for all 18 Safe Harbor identifiers
- [ ] Implement `DeidentificationModule.verify()` — post-strip residual check
- [ ] Unit test: 18 identifier categories with synthetic PHI fixtures
- [ ] Integration test: verify cloud sub-tasks C, D contain zero PHI after de-id pass

### M4 — External API agents (week 2)
- [ ] Implement Agent 3 stub: PubMed API query + summarization; verify citation return
- [ ] Implement Agent 4 stub: FDA Drug API + RxNorm query; verify DDI structured output
- [ ] Test Agent 3 + 4 with de-identified sub-tasks only

### M5 — Medical Aggregator + audit log (week 2–3)
- [ ] Implement `AuditLog` — append-only NDJSON, SHA-256 chain, write-failure hard stop
- [ ] Implement `medical_decompose` — PHI-aware sub-task generation
- [ ] Implement parallel dispatch with per-agent Tw timers
- [ ] Implement `medical_conflict_check` — clinical evidence hierarchy; re-assignment logic
- [ ] Implement `medical_synthesize` — de-identified synthesis input → Node 2 vMLX (Qwen3-8B) → disclaimer append
- [ ] Implement `human_review_required` SSE event emission for defined triggers

### M6 — PKM integration (week 3)
- [ ] Write `pkm.plugin.json` medical variant (see §12.1)
- [ ] Register plugin with PKM platform
- [ ] Implement Temporal `MedicalRAGWorkflow` (see §12.3)
- [ ] Wire three-endpoint SSE to Aggregator output stream
- [ ] Verify all 7 SSE event types emitted in correct order

### M7 — E2E validation (week 3–4)
- [ ] Run 10 synthetic clinical queries end-to-end; measure per-agent latency
- [ ] Verify PHI boundary: no PHI in audit log, no PHI in sub-tasks C and D
- [ ] Verify de-id: inject all 18 identifier types in test query; confirm all stripped
- [ ] Simulate Agent 1 (Clinical RAG) timeout: verify drug recommendations hard-blocked
- [ ] Simulate Agent 4 (Drug/Rx) timeout: verify drug recommendations hard-blocked
- [ ] Simulate audit log write failure: verify Aggregator halts
- [ ] Simulate de-id `verify()` failure: verify cloud dispatch blocked
- [ ] Simulate Node 1 unreachable: verify PKM health probe + CLINICAL_DATA_UNAVAILABLE flag
- [ ] Verify disclaimer appended to every output without exception
- [ ] Confirm `CONFLICT_UNRESOLVED` → `human_review_required` SSE event emitted

---

## 15. Locked Decisions

All open decisions resolved. No remaining open items for P1.

| # | Decision | Resolution | Notes |
|---|----------|-----------|-------|
| 1 | **Node 1 model** | `BioMistral-7B-4bit` | Best availability on HuggingFace MLX community |
| 2 | **Node 2 model** | `Qwen3-8B-4bit` | Strong CoT on Apple Silicon; `--reasoning-parser auto` |
| 3 | **Clinical vector store** | **pgvector (PostgreSQL)** | Hybrid retrieval: ANN + SQL FHIR field filter |
| 4 | **Embedding model** | `bge-m3` on Node 1 port 8001 | On-premise; no PHI leaves node |
| 5 | **Literature APIs** | **PubMed + WHO** (free) | Sufficient for P1; Cochrane deferred to P2 |
| 6 | **Drug/Rx APIs** | **FDA Drug API + RxNorm** (free) | DrugBank license deferred to P2 |
| 7 | **De-id implementation** | **Presidio** (rule-based) | No ML model required; deterministic for FHIR-structured data |
| 8 | **Synthesis routing (STEP 5)** | **Node 2 vMLX — Qwen3-8B-4bit** | Full on-premise pipeline; Agent 2 and STEP 5 are sequential — no contention |
| 9 | **Audit log backup** | **Time Machine (local)** | Simple; automated offsite deferred to P2 |

### Key implication — Node 2 dual role

Node 2 serves both Agent 2 (Diagnostic Reasoning) and the Aggregator STEP 5 synthesis call on the same vMLX instance. These calls are **sequential within a single query cycle** — Agent 2 completes and returns its result to the Aggregator before STEP 5 synthesis is dispatched. Continuous batching handles any overlap from concurrent queries across sessions without model reload.

Synthesis input to STEP 5 is **de-identified** before dispatch to Node 2 — even though Node 2 is a PHI node, the synthesis call carries no raw PHI.

### P1 cloud dependency

With synthesis on Node 2, **P1 has zero mandatory cloud LLM dependency**. The Anthropic API key in `pkm.plugin.json` is retained for Agent 3 (Literature) summarization if needed, but is not required for the core inference pipeline. This is intentional — P1 validates the full on-premise architecture before introducing cloud routing.

---

*v1.0 — Medical Multi-Agent RAG · Clinical Decision Support variant · P1 arch design*  
*Companion document: `vmlx_multiagent_arch_v1.md` (Generic variant)*  
*Reference blog post: momosan2692.github.io/2026/04/03/Multi-Agent_RAG_Architecture.html*
