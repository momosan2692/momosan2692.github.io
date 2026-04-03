---
layout: post
title: Medical Multi-Agent RAG 
subtitle: Architecture Notes (v2)
cover-img: /assets/img/header/2026-03-04/DATACENTER.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-03-04/DATACENTER.jpeg
published: false    # ← add this, post won't show on blog
pinned: false # true — pin a post to the top
tags: []
---

# Medical Multi-Agent RAG — Architecture Notes (v2)

> **Slice modification** of the Multi-Agent RAG pattern.  
> Agent 4 → **Clinical Decision Support** agent backed by a dedicated MCP server cluster.  
> ⚠️ **v2 corrections:** Aggregator re-characterized as a full reasoning agent; quiz answers added; data flow corrected.

---

## 1. System Overview

A **Multi-Agent Retrieval-Augmented Generation** (RAG) system adapted for clinical environments.

The **Aggregator Agent** is the **sole entry point and sole reasoning controller** of the system. It is not a passive router or a simple result-merger. It must:

- **Read and understand** every incoming query before dispatching any sub-task
- **Assign early-stage tasks** to agents based on query decomposition
- **Read and evaluate** every agent result that returns to it
- **Detect conflicts** between agent results and re-assign new clarification tasks
- **Handle failures** by re-designing the task set with available information
- **Sanitize** the final merged context before handing off to the LLM

No raw query, no raw PHI, and no unresolved agent conflict ever passes directly to the cloud Generative Model.

```
Clinician/Patient Query
        │
        ▼  ← ALL input enters here; nothing bypasses this node
╔══════════════════════════════════════════════════════════╗
║              Aggregator Agent  (REASONING)               ║
║                                                          ║
║  STEP 1 · READ query → decompose into sub-tasks          ║
║  STEP 2 · ASSIGN early-stage tasks to Agents 1–4         ║
║  STEP 3 · READ all returning results                     ║
║  STEP 4 · DETECT conflict / failure → re-assign if needed║
║  STEP 5 · MERGE & SANITIZE → de-identified summary only  ║
╚══╤═══════════╤══════════════╤═══════════╤════════════════╝
   │           │              │           │
   ▼           ▼              ▼           ▼
Agent 1     Agent 2        Agent 3    Agent 4 (NEW)
EHR/FHIR   Literature     Imaging    Medical AI / CDS
   │           │              │           │
   ▼           ▼              ▼           ▼
[All MCP calls stay inside private clinical network boundary]
   │           │              │           │
   └───────────┴──────────────┴───────────┘
                      │
         ┌────────────▼────────────┐
         │  Back to Aggregator     │  ← results ALWAYS return here
         │  read · conflict check  │
         │  re-assign if needed    │
         └────────────┬────────────┘
                      │
         [Memory & Planning feedback loop]
         Short-term · Long-term · ReACT · CoT
                      │
                      ▼  ← de-identified structured summary ONLY
         Generative Model (Clinical LLM)
         [cloud or on-prem per policy]
                      │
                      ▼
                   Output
```

> **Why Aggregator-first and Aggregator-last matters:** the Aggregator is both the firewall and the brain. Raw queries and raw PHI never reach the cloud LLM. Agent results that contradict each other never silently corrupt the LLM context — the Aggregator resolves them first.

---

## 2. Memory & Planning Layer

The Memory & Planning layer feeds **into** the Aggregator Agent only — not directly to agents or the LLM.

| Component | Role |
|-----------|------|
| **Short-Term Memory** | Active patient session, chief complaint, visit context, current symptom set |
| **Long-Term Memory** | EHR longitudinal history, chronic condition registry, allergy / adverse-event profile; also used as fallback cache when live data sources are unreachable |
| **ReACT Planning** | Observe → Reason → Act loop; drives the Aggregator's task decomposition and re-assignment decisions |
| **Chain-of-Thought (CoT)** | Step-by-step differential diagnosis reasoning; prevents diagnostic shortcuts and makes Aggregator's reasoning auditable |

---

## 3. Agents

Each agent is a **narrow specialist**. It receives a scoped sub-task from the Aggregator, executes MCP calls, and returns a structured result object **back to the Aggregator only**. Agents do not communicate with each other and do not send results to the LLM.

### Agent 1 — EHR / Records
- **MCP backend:** FHIR R4 server, HL7 adapter
- **Data accessed:** Patient demographics, lab results, medication history, encounter notes
- **Standards:** ICD-10, SNOMED-CT, LOINC
- **Integrations:** Epic, Cerner, OpenMRS
- **Returns to:** Aggregator only

### Agent 2 — Medical Literature
- **MCP backend:** PubMed API, Cochrane RCT index, NICE guidelines store
- **Data accessed:** Randomized controlled trials, systematic reviews, drug monographs, FDA drug labels
- **Sources:** PubMed · Cochrane · Semantic Scholar · arXiv · UpToDate
- **Returns to:** Aggregator only

### Agent 3 — Imaging / DICOM
- **MCP backend:** PACS server, DICOM store, AI inference endpoint
- **Data accessed:** CT scans, MRI, X-Ray, whole-slide pathology images (WSI)
- **AI models:** CheXpert (chest X-Ray), radiology NLP report parsers
- **Standard:** DICOM 3.0
- **Returns to:** Aggregator only

### Agent 4 — Medical AI *(NEW)*
- **MCP backend:** Clinical Decision Support MCP Server (6-module cluster, see §4)
- **Role:** Synthesizes clinical signals into decision-support outputs using validated medical knowledge bases
- **Returns to:** Aggregator only — structured clinical result with confidence scores and source citations

---

## 4. Clinical Decision Support MCP Server (Agent 4 Backend)

Six sub-modules, each a discrete MCP-connected service inside the private network:

| Module | Function | Key Standards / Sources |
|--------|----------|------------------------|
| **Drug DB** | Drug-drug interaction (DDI) check, dosing calculator, contraindication flags | RxNorm, WHO EML, DrugBank |
| **Dx Engine** | Symptom-to-diagnosis mapping, differential diagnosis ranking | ICD-10-CM, Isabel DDx |
| **Risk Scoring** | Validated clinical risk scores | APACHE II, CHADS₂-VASc, SOFA, Wells Score |
| **Lab Interpreter** | Reference range lookup, critical-value alerts, trend analysis | LOINC, AACC guidelines |
| **Tx Protocol** | Clinical Practice Guideline (CPG) retrieval, order set templates | WHO, NICE, AHA/ACC, UpToDate |
| **Clinical RAG** | Vector-indexed past cases, similar-patient retrieval, embedding search | Custom FAISS / pgvector index |

---

## 5. Data Flow (Corrected)

```
Query
  │
  ▼
Aggregator ← STEP 1: READ query, decompose into sub-tasks
  │
  ├─ STEP 2: ASSIGN ──▶ Agent 1 ──▶ FHIR/EHR MCP
  ├─ STEP 2: ASSIGN ──▶ Agent 2 ──▶ Literature MCP
  ├─ STEP 2: ASSIGN ──▶ Agent 3 ──▶ DICOM/Imaging MCP
  └─ STEP 2: ASSIGN ──▶ Agent 4 ──▶ CDS MCP
                                       ├── Drug DB
                                       ├── Dx Engine
                                       ├── Risk Scoring
                                       ├── Lab Interpreter
                                       ├── Tx Protocol
                                       └── Clinical RAG

  All results return to Aggregator — no exceptions
  │
  ▼
Aggregator ← STEP 3: WAIT (timer-gated) then READ arrived results
  │
  │  ┌──────────────────────────────────────────────────────┐
  │  │            AGGREGATOR TIMER POLICY                   │
  │  │                                                      │
  │  │  T=0ms    agents dispatched (parallel)               │
  │  │  T=Tw     default wait threshold fires               │
  │  │                                                      │
  │  │  before Tw: buffer each result as it arrives         │
  │  │  at Tw:                                              │
  │  │    · arrived results  → proceed to STEP 4            │
  │  │    · missing results  → treat as timeout failure     │
  │  │                         apply agent fallback (§6 Q2) │
  │  │                                                      │
  │  │  per-agent Tw examples (tunable):                    │
  │  │    Agent 1  EHR / FHIR      Tw = 2000 ms            │
  │  │    Agent 2  Literature      Tw = 3000 ms            │
  │  │    Agent 3  Imaging / DICOM Tw = 5000 ms  (heavy)   │
  │  │    Agent 4  CDS MCP         Tw = 2500 ms            │
  │  │                                                      │
  │  │  re-assignment inner loop:  Tw = 1500 ms  (tighter) │
  │  └──────────────────────────────────────────────────────┘
  │
  ├─ STEP 4: conflict detected?
  │     YES → re-assign clarification task to relevant agent(s)
  │             └──▶ agent re-executes with refined sub-query
  │                  └──▶ result returns to Aggregator again
  │                       (inner Tw = 1500 ms applies)
  │     NO  → proceed
  │
  ├─ STEP 4: agent failure / timeout detected?
  │     YES → fallback policy (see §6 Q2); re-assign or degrade gracefully
  │     NO  → proceed
  │
  ▼
Aggregator ← STEP 5: MERGE & SANITIZE
  │  · strip patient ID, DOB, MRN
  │  · structure as evidence-ranked clinical summary
  │  · flag CONFLICT_UNRESOLVED / STALE_DATA / LOW_CONFIDENCE items
  │
  ▼  ← no raw PHI crosses this boundary
Generative Model (Clinical LLM)
  │
  ▼
Output → clinician, with CoT trace + source citations attached
```

**Critical constraint:** All MCP calls (Agents 1–4) execute within the private clinical network. The Aggregator is the only node that touches both the private network and the LLM boundary. It is the HIPAA firewall.

---

## 6. Quiz: Architecture Questions — Answered

### Q1 — How is agent conflict handled?
> *Example: Agent 2 (literature) contradicts Agent 4 (Dx Engine)*

All results return to the **Aggregator Agent**, which reads and reasons over them. This is precisely why the Aggregator must be a reasoning agent.

**Resolution process:**

1. **Aggregator detects contradiction** — e.g., Agent 2 returns RCT evidence recommending Drug X; Agent 4 Dx Engine flags Drug X as contraindicated given this patient's renal profile from Agent 1.

2. **Evidence hierarchy applied** — the Aggregator weights evidence by clinical validity:

   ```
   Patient-specific data (EHR, labs, allergy profile)   ← highest priority
        ↓
   Validated clinical risk scores (SOFA, CHADS₂-VASc)
        ↓
   RCT / systematic review (Cochrane, NICE CPG)
        ↓
   Dx Engine / algorithmic inference                     ← lower priority
   ```

   In this example: patient-specific renal data (Agent 1) + contraindication from Drug DB (Agent 4) outweigh the general RCT recommendation from Agent 2. Conflict resolved in favor of patient safety.

3. **Re-assignment if unresolved** — if the evidence hierarchy alone cannot resolve the conflict, the Aggregator assigns a **new clarification sub-task**: e.g., re-query Agent 1 for renal function trend over 30 days, or re-query Agent 2 for literature specific to renally-impaired patients.

4. **Escalate to human-in-the-loop** — if conflict remains after re-assignment with high clinical stakes, output is flagged `CONFLICT_UNRESOLVED` and routed to clinician review before any recommendation is finalized. The LLM is not called with unresolved conflicts.

5. **Audit trail** — both conflicting results, the resolution logic, and the final decision are logged with timestamps and evidence sources.

> Conflicts are never silently averaged or suppressed. The Aggregator surfaces them explicitly with full provenance.

---

### Q2 — What is the fallback if the FHIR server is unreachable?

Agent 1 reports a failure signal to the **Aggregator Agent**, which re-designs the task plan:

```
Agent 1 timeout / connection error
        │
        ▼
  Aggregator reads failure signal
        │
        ├─ 1. RETRY with exponential backoff (1s → 3s → 9s → give up)
        │        └─ if FHIR recovers → resume normal flow
        │
        ├─ 2. CHECK Long-Term Memory cache
        │        └─ if recent EHR snapshot exists → use it
        │           flag output: ⚠ STALE_DATA (date of last sync shown)
        │
        ├─ 3. RE-ASSIGN to alternative source
        │        └─ e.g., local HL7 v2 ADT feed, hospital CDR read API
        │
        ├─ 4. DEGRADE GRACEFULLY
        │        └─ proceed with Agents 2, 3, 4 results only
        │           mark output: ⚠ PATIENT RECORD UNAVAILABLE
        │           hard-block: drug dosing and allergy-dependent
        │           recommendations suppressed until EHR restored
        │
        └─ 5. ESCALATE if safety-critical
                 └─ block LLM call entirely
                    alert clinician: manual EHR lookup required
                    do not generate a recommendation without patient record
```

> The Aggregator re-designs the task plan on failure — it does not crash, does not silently proceed with incomplete data, and does not forward a partial context to the LLM without explicit flags. Drug and allergy-dependent recommendations are **hard-blocked** if EHR data is unavailable.

---

## 6b. Aggregator Timer Policy (Response-Time Gating)

Because agents call different MCP backends — FHIR, PACS, PubMed, CDS — their response times vary significantly. The Aggregator cannot wait indefinitely, nor can it proceed too early. A **timer-gated decision policy** governs when the Aggregator moves to STEP 4.

### Timer Model

```
T = 0 ms
  Aggregator dispatches all agents in parallel
  └─ starts per-agent countdown timers simultaneously

T = n ms  (result arrives early)
  └─ buffered in Aggregator result queue; timer still running

T = Tw ms  (per-agent deadline fires)
  ├─ result present in buffer → use it, mark ARRIVED
  └─ result absent           → mark TIMEOUT, trigger fallback

T = Tw_max ms  (global hard deadline)
  └─ Aggregator proceeds with whatever has arrived
     all missing agents treated as TIMEOUT regardless
```

### Per-Agent Default Thresholds

| Agent | Backend | Default Tw | Rationale |
|-------|---------|-----------|-----------|
| Agent 1 | FHIR / EHR | **2000 ms** | Structured DB query; fast if healthy |
| Agent 2 | Literature / PubMed | **3000 ms** | External API; network variable |
| Agent 3 | Imaging / DICOM | **5000 ms** | Large payload; AI inference on image |
| Agent 4 | CDS MCP cluster | **2500 ms** | 6 sub-modules run in parallel internally |
| Re-assignment loop | Any agent | **1500 ms** | Tighter; scoped clarification sub-query only |
| Global hard deadline | All agents | **6000 ms** | Aggregator proceeds regardless |

All thresholds are **tunable per deployment** and should be calibrated against observed p95 latency of each MCP backend.

### Decision Tree at Tw

```
Agent result at Tw:
  │
  ├─ ARRIVED (within Tw)
  │     └─ include in STEP 4 reasoning normally
  │
  ├─ TIMEOUT (no result by Tw)
  │     ├─ safety-critical agent (Agent 1 EHR)?
  │     │     └─ apply full fallback chain (§6 Q2)
  │     │        hard-block drug/allergy recommendations
  │     └─ non-critical agent (Agent 2 / 3)?
  │           └─ degrade gracefully
  │              flag output: ⚠ PARTIAL_CONTEXT [agent name]
  │              continue with arrived results
  │
  └─ PARTIAL (result arrived but incomplete, e.g. imaging AI still processing)
        └─ use partial result if safe to do so
           flag: ⚠ PARTIAL_RESULT [agent name]
```

### Re-Assignment Loop Timer

When the Aggregator detects a conflict and re-assigns a clarification sub-task, a **tighter inner timer (Tw = 1500 ms)** applies. This prevents re-assignment loops from compounding latency unboundedly. Maximum re-assignment depth must also be capped (see §9).

### Latency Budget Example (happy path)

```
T=0      Aggregator dispatches Agents 1–4 in parallel
T=800    Agent 1 (FHIR) responds  → buffered
T=1200   Agent 4 (CDS)  responds  → buffered
T=2500   Agent 2 (Lit.) responds  → buffered
T=2500   Tw fires for Agents 1, 2, 4 → all ARRIVED
T=5000   Tw fires for Agent 3 (Imaging) → ARRIVED
T=5100   Aggregator begins STEP 4 (conflict check, merge, sanitize)
T=5400   De-identified summary sent to Clinical LLM
T=7000   LLM response returned → Output to clinician
```

Total round-trip target: **≤ 8 seconds** for standard clinical workflow. Emergency triage mode (Agents 1 + 4 only, no imaging, Tw = 1500 ms global) targets **≤ 3 seconds**.

---

## 7. Safety & Compliance Guardrails

> ⚠️ **Medical AI systems require mandatory safety boundaries regardless of architecture.**

| Requirement | Detail |
|-------------|--------|
| **HIPAA compliance** | All MCP calls use TLS 1.3; PHI never logged in plain text; de-identification at Aggregator before LLM handoff |
| **Human-in-the-loop** | Any `CONFLICT_UNRESOLVED`, `STALE_DATA`, or high-risk recommendation requires clinician confirmation before action |
| **FDA SaMD classification** | Intended use determines Class I/II/III; pre-market review may be required |
| **Audit trail** | Every Aggregator reasoning step, agent call, conflict resolution decision, and LLM inference logged with full provenance |
| **Hallucination mitigation** | All drug, dosing, and diagnostic outputs grounded in retrieved context; unsupported claims flagged `LOW_CONFIDENCE` |
| **Explainability** | Full CoT chain including conflict resolution steps exposed to clinician alongside output; no black-box recommendations |

---

## 8. Key Design Decisions (v2)

1. **Aggregator is a reasoning agent, not a router** — it reads queries, assigns tasks, reads results, resolves conflicts, re-assigns when needed, and sanitizes before LLM handoff. Active reasoning at every step.
2. **Query enters Aggregator first — always** — raw query never reaches agents or the LLM directly. This is the primary PHI firewall.
3. **All results return to Aggregator — always** — agents never communicate with each other or with the LLM. Every result passes through Aggregator reasoning before affecting the final output.
4. **Early-stage task assignment is dynamic** — the Aggregator's initial task decomposition can change mid-cycle. Conflict and failure both trigger new task assignments.
5. **Timer-gated decision policy governs Aggregator waiting** — agents run in parallel with per-agent Tw deadlines. At Tw the Aggregator proceeds with arrived results; timed-out agents trigger fallback. A global hard deadline (Tw_max) prevents unbounded waiting regardless of agent state.
6. **Evidence hierarchy governs conflict resolution** — patient-specific data beats population-level RCT; clinical risk scores beat algorithmic inference; safety always wins.
6. **Agent 4 is a specialist, not a generalist** — exclusively calls validated clinical knowledge services; no web search, no file lookup.
7. **MCP boundary enforces modularity** — each sub-module is independently versionable without changing agent logic.
8. **Long-term memory doubles as fallback cache** — when live sources (FHIR) are unreachable, Aggregator draws from last known EHR snapshot, always flagged `STALE_DATA`.
9. **CoT is mandatory and must be auditable** — reasoning chain is required for clinical and regulatory accountability; it is delivered to the clinician alongside the output.

---

## 9. Open Questions (Remaining)

- [ ] **Model selection** — fine-tuned medical model (Med-PaLM 2, BioMistral) vs. frontier model with RAG grounding + strict system-prompt guardrails; depends on intended use and SaMD classification.
- [ ] **Latency budget** — 4 parallel agents + 6 MCP sub-calls + potential re-assignment loops may be too slow for emergency triage. A triage-mode (Agent 1 + Agent 4 only, no re-assignment loop) may be required.
- [ ] **Consent & data residency** — cross-border patient data retrieval may violate GDPR, Taiwan PDPA, or other local regulations. Aggregator must enforce data residency policy per patient jurisdiction.
- [ ] **Re-assignment loop termination** — maximum re-assignment depth must be defined and hard-capped (suggested: 2 rounds). Each re-assignment loop applies its own inner Tw (1500 ms). Total re-assignment budget must fit within global Tw_max.

---

*v2 — Aggregator reasoning model corrected; conflict resolution and FHIR fallback answered; data flow fixed*  
*Reference diagram: `multi_agent_rag_medical.html`*