---
layout: post
title: Agentic Long-Term Memory
subtitle: Framework, Critique, and Architecture
cover-img: /assets/img/header/2026-03-04/DATACENTER.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-03-04/DATACENTER.jpeg
published: true    # ← add this, post won't show on blog
pinned: false # true — pin a post to the top
tags: []
---


# Agentic Long-Term Memory: Framework, Critique, and Architecture
**ARK Research Session — 2026-04-14**

---

## Overview

This report captures a full reasoning session on agentic long-term memory — from surveying the current platform landscape, through critiquing the Karpathy compiler analogy, to designing a durable archive schema for the Medical RAG system. The final section applies the framework reflexively to Anthropic's own memory system for Claude.

---

## Part I: The Memory Platform Landscape (2026)

### Thinking Steps

The starting point was mapping the current ecosystem not by marketing claims but by **architectural primitives** — what each platform actually stores, how it writes, and how it fails.

Key discrimination axis: **personalization** (remembering the user) vs. **institutional knowledge** (learning how to act better over time). Most platforms conflate these.

### Platform Map

| Platform | Architecture | Strength | Critical Weakness |
|---|---|---|---|
| **Mem0** | Vector + graph (Pro), ADD/UPDATE/DELETE/NOOP extraction | Largest community, framework-agnostic | Graph behind paywall; flat-fact ceiling; no temporal validity |
| **Zep / Graphiti** | Temporal knowledge graph | Episodic sequencing, low latency | 600K+ token memory footprint; post-ingestion retrieval lag |
| **Letta** (MemGPT) | OS-paging metaphor, editable memory blocks | Transparent memory state, long-horizon agents | Agentic loop overhead; complexity cost |
| **Cognee** | Local-first knowledge graph | Privacy-critical deployments, fully self-hostable | No managed infra, no compliance certs |
| **LangMem** | Native LangGraph extension, typed namespace store | Semantic + episodic + procedural; behavior-level memory | p95 latency ~60s; LangGraph-coupled |
| **Hindsight** | 4-strategy retrieval (semantic, BM25, graph, temporal) + reranking | Catches what single-strategy systems miss | Newer, less adoption |

### Key Insight

The fundamental shared assumption across all platforms:

> **Memory serves the agent. The agent architecture is stable.**

This assumption is the root of every long-term failure mode.

---

## Part II: Why Users Feel Agents "Forget"

### Thinking Steps

User complaints about agents forgetting are almost universally misdiagnosed as retrieval failures. The actual failure is a category mismatch: users expect **world model updates**; platforms deliver **personal fact retrieval**.

### Five Failure Modes

**1. No world model update**
The agent's knowledge of the external world is frozen at training cutoff. Memory platforms only store user-interaction facts. If the macro regime shifts and the user never mentions it, the agent operates on a stale world assumption — confidently.

**2. Write is conversation-triggered**
If the user doesn't interact for two weeks, nothing is written. The world moves; the memory store doesn't. Stale facts return with full confidence on next session.

**3. No temporal contradiction detection**
Most systems append or overwrite atomically. A stored belief formed under rate environment X coexists silently with a new interaction under rate environment Y. No system currently invalidates beliefs when the conditions that produced them change.

**4. Retrieval scope is too narrow**
Top-k semantic similarity retrieval surfaces facts *similar to the query*, not facts *causally relevant to the decision*. Regime duration memory may be critical context for a sizing decision but semantically distant from the query surface.

**5. No shared / global memory**
Every user's memory is siloed. Cross-user institutional signal — "many agents are hitting ABSTAIN this week" — is architecturally absent everywhere.

### Root Diagnosis

> Users are implicitly asking for **continual learning** (world model updates).  
> The industry is selling them **key-value stores** (personal fact retrieval).

These are different problems. No current production platform solves the former.

---

## Part III: LangMem as First Choice for the Trading Stack

### Thinking Steps

Given the constraint of LangGraph as the existing orchestration layer, LangMem is the path of least resistance — but must be scoped correctly to avoid the platform-wide failure modes.

### Why LangMem Fits

- Memory stored as typed, namespaced documents — can scope per-agent, per-symbol, per-regime
- Supports **procedural memory** (how to act) not just semantic (what is true) — directly useful for strategy policy evolution
- `manage_memory` tool allows agents to self-write during the agentic loop — no separate consolidation daemon
- Native integration with LangGraph `StateGraph` checkpointer — memory and state lifecycle unified

### Correct Scoping

| Memory type | Content | Scope |
|---|---|---|
| Semantic | Macro regime narratives, event summaries | global |
| Episodic | Past ABSTAIN decisions + outcomes | per-symbol |
| Procedural | Regime → signal bias corrections | per-regime |

### Known Gap

LangMem has no decay or forgetting mechanism. Stale regime memories from 6 months prior will pollute retrieval. A scheduled pruning node in the LangGraph pipeline is required — TTL or relevance-decay policy, implemented explicitly.

### JEPA Relationship

The JEPA world model replacing Layer 4 is a form of **implicit procedural memory** — learned world dynamics from market microstructure. LangMem handles **explicit episodic memory** of past decisions and outcomes. These are complementary, not redundant:

- JEPA: numerical world model, continuously trained
- LangMem: semantic decision history, explicitly managed

---

## Part IV: The Karpathy Compiler Analogy

### Thinking Steps

Karpathy's framing is the most coherent existing mental model for LLM-based knowledge management. The question is: where does it hold, and where does it fail?

### The Analogy

| Software | Knowledge |
|---|---|
| Source code | Raw articles, papers, transcripts, notes |
| Compiler | LLM |
| Compiled executable | Synthesized wiki (Markdown) |

**Why it works for medium-term use:**
- LLMs tolerate noisy input better than compilers — redundancy is handled during synthesis
- The wiki is human-readable, human-editable, and re-injectable into future LLM calls
- Contradiction resolution and structure happen during compilation, not at query time
- Plain Markdown is schema-minimal and tool-agnostic

**Why Markdown specifically works:**
The wiki is the target artifact for LLM consumption. Markdown is the format that minimizes friction between human editing and LLM ingestion — no proprietary lock-in, no vector opacity.

### The Compiler Analogy's Own Metaphor Betrays It

In software: executables compiled for x86 don't run on ARM. Change the architecture → recompile from source.

The wiki IS the executable. At 10-year scale:

**Ontological drift** — categories that mattered in 2024 are wrong in 2034. The wiki's structure reflects a 2024 understanding of what is important. A 2034 agent with different conceptual structure cannot cleanly consume it.

**Belief half-life** — compiled facts carry no validity window. "Fed in tightening cycle" has no expiry. 10 years later that entry is poison, not knowledge.

**Schema-agent coupling** — the wiki was structured to feed a specific agent's context pattern. Architecture change → consumption interface changes → compiled format is wrong even if facts are still true.

**Recompilation cost grows non-linearly** — at 10 years of accumulated source, full recompilation is computationally and semantically expensive. Partial recompilation creates consistency gaps.

### The Correct Verdict

> The Karpathy wiki is a **medium-term tactical tool**, not a long-term memory architecture.  
> For 10-year continuity, the provenance archive is the primary artifact.  
> Compilation is a periodic ephemeral operation on top of it — not the other way around.

---

## Part V: The Fundamental Architecture Inversion

### Current Assumption (Wrong at Scale)

```
Memory serves the agent.
Agent architecture is stable.
```

### Correct Inversion for Long-Term Systems

```
Memory must outlive any specific agent architecture.
The agent serves the memory.
```

### Three-Layer Separation

```
Layer 1: Raw Provenance Archive     → append-only, schema-free, permanent
Layer 2: Interpreted Knowledge      → versioned, compiled for current ontology  
Layer 3: Agent Consumption Format   → ephemeral, recompiled per agent arch generation
```

Only Layer 1 has genuine longevity. Layers 2 and 3 are compiled artifacts — they expire when the target architecture changes.

This maps onto how human institutions handle knowledge:
- **Raw records** (legal, financial, operational) persist indefinitely — Layer 1
- **Strategy documents, playbooks** get rewritten each generation — Layer 2
- **Current leadership / agent structure** changes — Layer 3
- The raw archive remains queryable across all generations

---

## Part VI: Long-Term Archive Schema for the Medical RAG System

### Design Principle

Every record stored must be:
- **Agent-architecture agnostic** — raw enough that any future agent can recompile
- **Temporally anchored** — every record knows *when* it was true and *under what conditions*
- **Provenance-complete** — source, confidence, generator identity
- **Schema-minimal** — structure only where necessary

---

### Class 1: Clinical Encounter Records

```json
{
  "type": "clinical_encounter",
  "encounter_datetime": "ISO8601",
  "fhir_version": "R4",
  "phi_status": "presidio_stripped",
  "presidio_version": "2.x",
  "bundle": { "...FHIR R4 JSON..." },
  "ingest_agent_version": "medical_rag_v1.1",
  "validity": "perpetual"
}
```

**Why permanent:** Future agents need longitudinal patient patterns.  
**Temporal anchor:** `encounter_datetime` + `ingest_date` (both required).

---

### Class 2: Evidence Provenance Records

```json
{
  "type": "evidence_provenance",
  "source": "PubMed | WHO | FDA",
  "doi": "...",
  "publication_date": "ISO8601",
  "ingest_date": "ISO8601",
  "abstract": "...",
  "full_text_hash": "SHA-256",
  "extraction_agent_version": "...",
  "confidence_score": 0.0,
  "validity": "perpetual"
}
```

**Why permanent:** Raw literature outlasts any interpretation of it.  
**Critical distinction:** `publication_date` ≠ `ingest_date`. Both are required. The interpretation layer expires; the source record does not.

---

### Class 3: Clinical Reasoning Traces

```json
{
  "type": "reasoning_trace",
  "session_datetime": "ISO8601",
  "query": "...",
  "agent_steps": [],
  "tools_called": [],
  "conflicts_detected": [],
  "resolution_method": "...",
  "abstain_triggered": false,
  "final_output": "...",
  "model_version": "...",
  "agent_arch_version": "medical_rag_v1.1",
  "validity": "perpetual as artifact"
}
```

**Why permanent:** Future agents learn from *how* decisions were made, not just outcomes.  
**Note:** Interpretation requires arch context — record the arch version, always.

---

### Class 4: Belief State Snapshots *(Priority Gap — Add First)*

```json
{
  "type": "belief_state",
  "topic": "drug_interaction | regime | guideline | ...",
  "assertion": "...",
  "confidence": 0.0,
  "supporting_evidence_ids": ["provenance_record_id_1", "..."],
  "valid_from": "ISO8601",
  "valid_until": null,
  "superseded_by": null,
  "conditions_of_validity": "...",
  "jurisdiction": "JX-A",
  "regulatory_body": "Local Health Authority",
  "applicable_standard": "ICH-E6-R2"
}
```

**Why permanent:** Enables temporal reasoning — "what did the system believe in March 2026?"  
**`valid_until`:** Updated when belief is superseded. Null = still active.  
**`conditions_of_validity`:** The regime/context under which this belief holds. Critical for temporal invalidation.  
**This is the bridge layer** — both permanent record AND recompilation target for the next agent generation.

---

### Class 5: Drug / Protocol Version Records

```json
{
  "type": "drug_protocol_version",
  "drug_id": "RxNorm CUI",
  "rxnorm_version": "...",
  "indication": "...",
  "contraindications": [],
  "approval_date": "ISO8601",
  "withdrawal_date": null,
  "source_url": "FDA Drug API endpoint",
  "jurisdiction": "TW | US | EU",
  "validity": "bounded by withdrawal_date"
}
```

**Why permanent:** Drug interactions change. Future agents need historical ground truth to reason over what was known and when.

---

### Class 6: Audit Log (Already Correct)

```
Existing SHA-256-chained append-only log.
Regulatory, compliance, legal — non-negotiable perpetual retention.
Temporal anchor embedded in chain. Immutable.
```

No changes required. This is the one component already correctly designed for long-term permanence.

---

### Class 7: Conflict and Uncertainty Records *(Highest Signal)*

```json
{
  "type": "conflict_uncertainty",
  "session_datetime": "ISO8601",
  "query": "...",
  "agent_outputs": [],
  "conflict_type": "evidence_contradiction | agent_disagreement | guideline_gap",
  "resolution": "abstain | human_override | majority_vote",
  "human_override": null,
  "outcome_if_known": null,
  "validity": "perpetual"
}
```

**Why permanent:** Cases where agents disagreed or ABSTAIN was triggered are the highest signal for future agent calibration and training. Uncertainty history is itself knowledge.

---

### What NOT to Archive Long-Term

| Data | Reason |
|---|---|
| Compiled wiki summaries | Architecture-coupled; expires with agent generation |
| Vector embeddings | Model-specific; meaningless to future architecture |
| Prompt templates | Agent-specific; rewrite per arch generation |
| Cached LLM outputs | Stale, not provenance |
| Raw PHI before Presidio | Hard stop — never persisted |

---

### Full Layer Map

```
PERMANENT ARCHIVE (Classes 1–7)
  ↓  recompile trigger: arch change / scheduled / drift detected
INTERPRETED KNOWLEDGE (Class 4: Belief State Snapshots)
  ↓  compiled for current agent ontology
AGENT CONSUMPTION FORMAT (pgvector embeddings, FHIR filters)
  ↓  ephemeral — rebuilt each arch generation
CURRENT vMLX AGENTS (Node 1 RAG / Node 2 Reasoning)
```

### Jurisdictional Tag (Medical-Specific Requirement)

Every Class 1–5 record requires:

```json
{
  "jurisdiction": "JX-A",
  "regulatory_body": "Local Health Authority",
  "applicable_standard": "ICH-E6-R2",
  "as_of": "2026-04-14"
}
```

Medical knowledge is not universal. Local Health Authority ≠ FDA ≠ EMA. Future agents operating in different regulatory contexts must know which regulatory world each record lived in.

---

## Part VII: Reflexive Application — What Anthropic Stores About ARK

### Thinking Steps

The session concluded by applying the framework to the system we were using. The `userMemories` block injected into Claude's context is itself a memory artifact — what class does it belong to?

### What Is Actually Stored

| Memory class | Anthropic implementation | Status |
|---|---|---|
| Class 1: Raw provenance archive | Not accessible to user | ❌ Absent |
| Class 2: Evidence provenance | Not present | ❌ Absent |
| Class 3: Reasoning traces | Partial — some decisions have rationale | ⚠️ Partial |
| Class 4: Belief state snapshots | Present but no `valid_until` | ⚠️ Incomplete |
| Class 5: Protocol versions | Not present | ❌ Absent |
| Class 6: Audit log | Not exposed | ❌ Not accessible |
| Class 7: Conflict records | Not present | ❌ Absent |

### The Critical Limitations

**No temporal validity bounds** — stored facts carry no `valid_until`. Project states recorded weeks ago may be stale; the system has no mechanism to detect this.

**No confidence scores** — every stored fact carries equal weight. A casual remark and a confirmed architectural decision are indistinguishable.

**No contradiction detection** — newer records may silently coexist with older contradictory ones.

**Recompilation is opaque** — the compilation process is Anthropic's, not the user's. The user cannot control, inspect, or audit what gets distilled.

**Architecture coupling** — the memory format was compiled for the current Claude version. Future architectures may weight, parse, or miss context embedded in current formatting assumptions.

### Verdict

> What Anthropic stores is a **Karpathy-style compiled wiki** — synthesized, structured, readable.  
> Exactly what this session identified as insufficient for long-term continuity.

The raw conversation transcripts — the true provenance archive — are not exposed to the memory system in a way the user can control.

**The user experienced the problem we were designing a solution for.**

---

## Summary: Key Conclusions

1. **Current memory platforms solve personalization, not world-model continuity.** Users complaining about agents forgetting are asking for continual learning; platforms deliver key-value retrieval.

2. **The Karpathy compiler analogy is correct for medium-term use** — 6 months to 2 years. At 10-year scale, ontological drift, belief half-life, and schema-agent coupling make compiled artifacts obsolete.

3. **The correct inversion:** Memory must outlive any specific agent architecture. Build Layer 1 (provenance archive) as the permanent primary artifact. Treat Layers 2 and 3 as ephemeral compiled outputs.

4. **For the Medical RAG system,** the priority gap is **Class 4: Belief State Snapshots** with explicit `valid_from` / `valid_until` / `conditions_of_validity`. The SHA-256 audit log (Class 6) is already correctly designed. Class 7 (Conflict Records) has the highest signal value for future agent calibration.

5. **For the Trading Stack,** LangMem scoped to episodic decision history + procedural regime corrections is the correct choice within LangGraph. JEPA handles the numerical world model; LangMem handles the semantic decision archive. They are complementary.

6. **No current production platform** implements temporal belief invalidation, ontology versioning, or agent-agnostic raw archival at production level. This remains an open architectural problem.

---

*Report generated: 2026-04-14*  
*Session: ARK — Agentic Long-Term Memory Research*  
*Architecture context: Medical RAG v1.1 / Trading Stack / JEPA Layer 4 replacement*