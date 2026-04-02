---
layout: post
title: Multi-Agent RAG Architecture
subtitle: Generic and Medical Application
cover-img: /assets/img/header/2026-03-29/COT-CONSTITUTION.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-03-29/COT-CONSTITUTION.jpeg
published: true
pinned: false
tags: [draft, AI, trading, CoT, RAG, compliance, architecture]
---

# Multi-Agent RAG Architecture: Generic and Medical Application

**Document version:** v1.0  
**Date:** 2026-04-02  
**Reference:** CJH — PKM Platform · oMLX-Cluster architecture pivot

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Design Principles](#2-design-principles)
3. [Infrastructure: vMLX Engine](#3-infrastructure-vmlx-engine)
4. [Infrastructure: SSH Tunnel Transport](#4-infrastructure-ssh-tunnel-transport)
5. [Generic Multi-Agent RAG — 3-Node Architecture](#5-generic-multi-agent-rag--3-node-architecture)
6. [Medical Multi-Agent RAG — 3-Node Architecture](#6-medical-multi-agent-rag--3-node-architecture)
7. [Aggregator Agent Design](#7-aggregator-agent-design)
8. [Context Isolation and Sub-Task Dispatch](#8-context-isolation-and-sub-task-dispatch)
9. [Security Model](#9-security-model)
10. [PKM Integration](#10-pkm-integration)
11. [Comparison: Generic vs Medical](#11-comparison-generic-vs-medical)

 **Interactive version:** [Medical Multi-Agent RAG, medical App](/assets/html/RAG/RKLmedical_RAG_3nodes.html)
---

## 1. Architecture Overview

Both the generic and medical architectures share a common 3-node pattern: one orchestration node running the Aggregator and cloud-proxy agents, and two local inference nodes each running a vMLX Engine instance serving a resident model. The key structural distinction is that no model weights are shared across nodes, no inter-node tensor communication occurs, and the Aggregator is the sole entity that holds full context at any time.

This architecture emerged from the pivot away from oMLX distributed tensor-parallel clustering. Rather than splitting a single large model across nodes via collective communication (AllReduce over Thunderbolt 5), each node runs a complete, independent model optimized for its domain. The result is simpler failure isolation, no EOS broadcast synchronization, and no JACCL dependency.

---

## 2. Design Principles

**Context isolation by design.** Every agent receives only its sub-task. No agent sees the full user query, other agents' sub-tasks, or other agents' results. The Aggregator is the only entity that holds the complete picture at all times. This is not a performance optimization — it is a structural security and privacy constraint.

**Single context firewall.** The Aggregator acts as a context firewall. It decomposes the incoming query into sub-tasks, dispatches each sub-task independently, collects results, and synthesizes the final response. This unidirectional information flow prevents any agent from accumulating cross-task context across calls.

**Model stays hot.** Each vMLX instance loads its model once into unified memory. Subsequent requests from multiple agents are served via continuous batching — no model reload between calls. This eliminates cold-start latency for sequential or near-simultaneous agent dispatches.

**No clustering complexity.** Tensor parallelism across nodes introduces AllReduce synchronization, EOS broadcast coordination, and transport-layer failure modes. The 3-node pattern avoids all of these. Each node fails independently. Node replacement does not require cluster reconfiguration.

**SSH tunnel as transport.** Cross-node agent calls from the Aggregator are routed through SSH tunnels. The vMLX engine on each inference node binds to `127.0.0.1` only. No inference endpoint is exposed on any network interface. API key authentication provides an additional layer over the tunnel.

---

## 3. Infrastructure: vMLX Engine

vMLX is an open-source MLX inference engine for Apple Silicon, published on PyPI under the Apache 2.0 license at `github.com/jjang-ai/vmlx`.

**Installation:**

```bash
# Recommended
brew install uv
uv tool install vmlx

# Alternative
pip install vmlx
```

**Serve command (production configuration):**

```bash
vmlx serve <hf-repo-or-local-path> \
  --host 127.0.0.1 \
  --port 8000 \
  --api-key sk-your-key \
  --continuous-batching \
  --enable-prefix-cache \
  --use-paged-cache \
  --kv-cache-quantization q8 \
  --enable-disk-cache \
  --enable-jit \
  --reasoning-parser auto \
  --tool-call-parser auto
```

**Key capabilities relevant to multi-agent use:**

vMLX exposes an OpenAI-compatible `/v1/chat/completions` endpoint and an Anthropic Messages API `/v1/messages` endpoint. Both support streaming. A dedicated `/v1/embeddings` endpoint can serve an embedding model alongside the chat model without session interruption.

The continuous batching scheduler accepts up to 256 concurrent inference sequences. Requests from multiple agents dispatched to the same endpoint are batched per decode step — the model weights remain resident in unified memory and a single Metal forward pass processes tokens from all active sequences simultaneously. This is not true parallelism at the GPU kernel level (Apple Metal executes one compute kernel at a time), but it eliminates reload overhead entirely and achieves high throughput for the sequential-dominant dispatch pattern of multi-agent RAG.

**KV cache layers (vMLX terminology):**

vMLX describes its caching as 5-layer, referring to five concurrent cache features: prefix cache, paged KV cache, KV quantization (q4 or q8), continuous batching, and persistent disk cache. In terms of storage tiers, this maps to two physical levels — L1 (in-memory, prefix-aware paged cache) and L2 (SSD disk cache). KV quantization applies at the storage boundary: inference runs at float16 precision; cached states are compressed to q8 (approximately 2x savings) or q4 (approximately 4x savings) before write.

---

## 4. Infrastructure: SSH Tunnel Transport

Inference endpoints on Node 1 and Node 2 bind exclusively to `127.0.0.1`. The Aggregator on Node 0 accesses them via SSH port forwarding:

```bash
# On Node 0 — establish tunnels to Node 1 and Node 2
ssh -N -L 8001:127.0.0.1:8000 node1-hostname &
ssh -N -L 8002:127.0.0.1:8000 node2-hostname &
```

The Aggregator then calls `http://localhost:8001/v1/chat/completions` and `http://localhost:8002/v1/chat/completions`. All traffic is encrypted in transit. No inference port is reachable from any external network.

For persistent tunnel management, `autossh` is recommended:

```bash
autossh -M 0 -N -o "ServerAliveInterval 30" \
  -L 8001:127.0.0.1:8000 node1-hostname

autossh -M 0 -N -o "ServerAliveInterval 30" \
  -L 8002:127.0.0.1:8000 node2-hostname
```

---

## 5. Generic Multi-Agent RAG — 3-Node Architecture

### 5.1 Node Layout

**Node 0 — Aggregator Node**

Runs no local inference. Contains the Aggregator agent process, Agent 2 (Search), and Agent 3 (Cloud Model). Outbound traffic is HTTPS only toward external search APIs and cloud LLM providers.

**Node 1 — Local Data RAG**

Runs vMLX serving a general-purpose chat or RAG-optimized model. Agent 1 (Local Data) operates here, performing vector retrieval against local document stores and returning retrieved context to the Aggregator.

**Node 2 — Coding Agent**

Runs vMLX serving a coding-capable model (e.g., a Qwen-Coder or DeepSeek-Coder variant). Agent 4 (Coding) operates here with access to MCP tools for file I/O, shell execution, git operations, and code search.

### 5.2 Agent Roles

**Aggregator Agent (Node 0)**  
The sole holder of full user context. Decomposes the incoming query into sub-tasks A, B, C, D. Dispatches each sub-task independently. Collects results and synthesizes the final response via a generative synthesis step. Owns the full query, all intermediate results, and the response.

**Agent 1 — Local Data RAG (Node 1, :8000)**  
Receives sub-task A only. Performs embedding-based retrieval over local knowledge stores (documents, notes, code repositories). Returns retrieved passages to the Aggregator.

**Agent 2 — Search (Node 0)**  
Receives sub-task B only. Issues web search queries to Brave or DuckDuckGo APIs. Fetches and summarizes relevant URLs. Returns search results to the Aggregator. Runs on Node 0 as a lightweight Python process — no local LLM required.

**Agent 3 — Cloud Model (Node 0)**  
Receives sub-task C only. Issues requests to Anthropic or OpenAI APIs. Returns the cloud model response. The sub-task payload it receives contains no information from other agents' tasks. Runs on Node 0 as an API proxy — no local LLM required.

**Agent 4 — Coding Agent (Node 2, :8001)**  
Receives sub-task D only. Uses the local coding model via vMLX for code generation, refactoring, test synthesis, and static analysis. Has access to MCP tools for file editing, shell commands, git operations, and code-aware vector retrieval.

### 5.3 Data Flow

```
User query (full)
    ↓
Aggregator (Node 0) — full context
    ├── sub-task A → Agent 1 (Node 1 via SSH tunnel) → result A
    ├── sub-task B → Agent 2 (Node 0, Search API)   → result B
    ├── sub-task C → Agent 3 (Node 0, Cloud API)    → result C
    └── sub-task D → Agent 4 (Node 2 via SSH tunnel) → result D
         ↓ all results
    Aggregator — merge + synthesis
         ↓
    User response
```

### 5.4 Configuration

**PKM plugin config (`pkm.plugin.json` excerpt):**

```json
{
  "agents": {
    "local_rag": {
      "base_url": "http://localhost:8001/v1",
      "api_key": "sk-node1-key",
      "model": "mlx-community/Qwen3-8B-4bit",
      "role": "local_data_retrieval"
    },
    "search": {
      "type": "api",
      "provider": "brave",
      "role": "web_search"
    },
    "cloud": {
      "base_url": "https://api.anthropic.com",
      "api_key": "sk-ant-...",
      "model": "claude-sonnet-4-6",
      "role": "cloud_reasoning"
    },
    "coding": {
      "base_url": "http://localhost:8002/v1",
      "api_key": "sk-node2-key",
      "model": "mlx-community/Qwen2.5-Coder-7B-4bit",
      "role": "code_generation"
    }
  }
}
```

---

## 6. Medical Multi-Agent RAG — 3-Node Architecture

The medical architecture applies the same 3-node structural pattern with four critical additions: HIPAA-aware PHI handling, de-identification before any cloud dispatch, timer-gated decision policy in the Aggregator, and an AI disclaimer on all outputs.

### 6.1 Node Layout

**Node 0 — Medical Aggregator Node**

Runs no local inference. Contains the Medical Aggregator agent (a full reasoning agent, not a passive router), Agent 3 (Medical Literature), and Agent 4 (Drug/Rx API). All cloud-bound sub-tasks are stripped of PHI before dispatch. Maintains an audit log of all dispatches. PHI is never written to this log.

**Node 1 — Clinical Data RAG**

Runs vMLX serving a medical domain LLM. Agent 1 (Clinical Data) operates here with access to local EMR data, patient records, lab results, and imaging reports. PHI remains on this node. No data leaves this node except result summaries returned to the Aggregator via SSH tunnel.

**Node 2 — Diagnostic Reasoning**

Runs vMLX serving a reasoning-capable LLM. Agent 2 (Diagnostic Reasoning) operates here, performing differential diagnosis generation and clinical reasoning chains. PHI remains on this node. Returns structured reasoning outputs to the Aggregator via SSH tunnel.

### 6.2 Agent Roles

**Medical Aggregator (Node 0)**  
A full reasoning agent — not a passive router. Receives the full clinical query including PHI. Before dispatching to any cloud agent, it performs de-identification to produce Safe Harbor-compliant sub-tasks. Owns the timer-gated decision policy: each agent has a per-agent timeout threshold, and the Aggregator synthesizes a partial response if any agent exceeds its timeout. Maintains an audit trail. Appends an AI-generated disclaimer to all outputs.

**Agent 1 — Clinical Data RAG (Node 1, :8000)**  
Receives sub-task A including PHI. Performs retrieval over local clinical databases: EMR, lab panels, imaging reports, allergy records. PHI stays on Node 1. Returns retrieved clinical context to the Aggregator.

**Agent 2 — Diagnostic Reasoning (Node 2, :8001)**  
Receives sub-task B including PHI. Generates differential diagnosis lists, clinical reasoning chains, and structured clinical assessments using a reasoning-capable local model. PHI stays on Node 2. Returns structured diagnostic reasoning to the Aggregator.

**Agent 3 — Medical Literature (Node 0)**  
Receives sub-task C — de-identified, containing no PHI. Queries PubMed, clinical guideline repositories (WHO, UpToDate, Cochrane), and relevant medical literature APIs. Returns evidence summaries. Runs as an API proxy on Node 0.

**Agent 4 — Drug / Rx (Node 0)**  
Receives sub-task D — de-identified, containing no PHI. Queries FDA drug databases, DrugBank, and interaction APIs. Returns drug interaction flags, contraindication alerts, and dosage guidance. Runs as an API proxy on Node 0.

### 6.3 HIPAA Compliance Design

**PHI boundary.** PHI is confined to Node 1 and Node 2. The Aggregator holds PHI transiently during its reasoning step but does not persist it. PHI is never dispatched to any cloud endpoint.

**De-identification layer.** Before the Aggregator dispatches sub-tasks C or D to cloud agents, a de-identification step strips or replaces all 18 HIPAA Safe Harbor identifiers: names, dates (except year), geographic data below state level, ages over 89, contact information, ID numbers, biometrics, and full-face photographs. Only the clinically relevant, de-identified question is sent.

**Audit log.** The Aggregator maintains an append-only audit log recording: query hash, timestamp, sub-task dispatch sequence, per-agent response latency, and timer-gate events. PHI is never written to the log. The log records that a query occurred and how it was handled, not what was asked or answered.

**Timer-gated decision policy.** Each agent has a configured timeout threshold. If an agent exceeds its threshold, the Aggregator does not wait — it synthesizes a partial response from available results and notes which agent timed out. This prevents a slow external API from blocking a time-sensitive clinical query.

**AI disclaimer.** All outputs carry a mandatory disclaimer: the response is AI-generated, is not clinical advice, and should be reviewed by a licensed clinician before any clinical decision is made.

### 6.4 Data Flow

```
Clinician query (full, includes PHI)
    ↓
Medical Aggregator (Node 0) — full context + PHI
    ├── sub-task A (with PHI)  → Agent 1 (Node 1 via SSH)     → clinical context
    ├── sub-task B (with PHI)  → Agent 2 (Node 2 via SSH)     → diagnostic reasoning
    ├── sub-task C (de-id)     → Agent 3 (Node 0, PubMed API) → evidence summary
    └── sub-task D (de-id)     → Agent 4 (Node 0, FDA API)    → drug/interaction data
         ↓ all results (timer-gated)
    Medical Aggregator — merge + synthesis + disclaimer
         ↓
    Clinician report (AI-generated · not clinical advice)
```

### 6.5 Timer-Gated Policy Configuration

```python
AGENT_TIMEOUTS = {
    "agent_1_clinical_rag":  12.0,  # seconds — local, fast
    "agent_2_diagnostic":    20.0,  # seconds — reasoning model, longer
    "agent_3_literature":     8.0,  # seconds — external API
    "agent_4_drug_rx":        6.0,  # seconds — external API, simple lookup
}

AGGREGATOR_HARD_DEADLINE = 30.0  # seconds — total max before partial synthesis
```

If `agent_2_diagnostic` exceeds 20 seconds, the Aggregator proceeds with results from agents 1, 3, and 4, notes the diagnostic reasoning timeout in the output, and appends a flag for the clinician to request a retry.

---

## 7. Aggregator Agent Design

### 7.1 Role Distinction

The Aggregator is not a router. It is a reasoning agent that performs at minimum three distinct cognitive steps:

**Decomposition.** Given a full user query, the Aggregator reasons about which sub-tasks are needed, what each sub-task should contain, and whether any agent is irrelevant for this query. Not all four agents are invoked on every query.

**Dispatch.** The Aggregator constructs each sub-task prompt independently. Each sub-task prompt is crafted to be self-contained — the receiving agent needs no additional context beyond what is in the prompt.

**Synthesis.** After collecting results, the Aggregator merges them into a coherent response. This is not concatenation. The Aggregator must resolve conflicts between agent results, weight evidence, and produce a unified answer.

### 7.2 Aggregator as Context Firewall

The Aggregator's context firewall property is structural, not procedural. Because each agent receives only its sub-task, and because agent results flow only back to the Aggregator (not to other agents), no agent can observe what any other agent was asked or what it returned. This holds even if an agent is compromised or returns unexpected output — the damage is bounded to its own sub-task result.

### 7.3 Generative Synthesis Step

The final synthesis step uses a generative model co-located with the Aggregator. In the medical architecture, this synthesis step appends the mandatory AI disclaimer. In the generic architecture, it merges results into a natural language response. This step can be performed by a local lightweight model or by routing to Agent 3 (Cloud) if high synthesis quality is required.

---

## 8. Context Isolation and Sub-Task Dispatch

### 8.1 What Each Agent Receives

| Agent | Receives | Does Not Receive |
|-------|----------|-----------------|
| Agent 1 — Local RAG | Sub-task A prompt only | Full query, tasks B/C/D, results of other agents |
| Agent 2 — Search / Diagnostic | Sub-task B prompt only | Full query, tasks A/C/D, results of other agents |
| Agent 3 — Literature / Cloud | Sub-task C prompt only (de-id in medical) | Full query, tasks A/B/D, any PHI |
| Agent 4 — Drug / Coding | Sub-task D prompt only (de-id in medical) | Full query, tasks A/B/C, any PHI |

### 8.2 Sub-Task Prompt Structure

Each sub-task prompt is structured as a standalone instruction:

```
You are a [role] assistant.

Task: [specific, self-contained question or instruction]

[Optional: relevant retrieved context pre-fetched by Aggregator]

Respond with: [expected output format]
Do not include: [exclusions]
```

The Aggregator never includes the original user query verbatim in a sub-task prompt. It translates the query into a targeted instruction appropriate for the agent's capability.

### 8.3 Result Collection

Results from all agents are collected by the Aggregator. Each result is tagged with its source agent and dispatch latency. The Aggregator's synthesis step has access to all tagged results simultaneously, enabling it to weight, conflict-resolve, and merge with full awareness of provenance.

---

## 9. Security Model

### 9.1 Network Isolation

All vMLX inference endpoints bind to `127.0.0.1`. No inference port is reachable from the local network or externally. Cross-node access is exclusively via SSH tunnel from Node 0. This means Node 1 and Node 2 are not reachable as inference servers by any process other than the Aggregator on Node 0.

### 9.2 Authentication Layers

Two authentication layers apply to every cross-node inference call:

SSH public key authentication controls tunnel establishment. Only Node 0's key is authorized on Node 1 and Node 2.

vMLX API key authentication (`--api-key`) is checked on every HTTP request within the tunnel. A request without the correct API key is rejected at the vMLX server layer before any model inference occurs.

### 9.3 Cloud Agent Data Minimization

Agents 3 and 4 (cloud-facing) receive sub-tasks constructed by the Aggregator to contain only the information necessary for the task. In the generic architecture, this is natural sub-task scoping. In the medical architecture, this additionally requires explicit PHI removal before the sub-task is constructed.

### 9.4 Summary Table

| Control | Generic | Medical |
|---------|---------|---------|
| vMLX bind address | 127.0.0.1 | 127.0.0.1 |
| Cross-node transport | SSH tunnel | SSH tunnel |
| API key auth | Per node | Per node |
| Context isolation | Sub-task only | Sub-task only |
| PHI boundary | N/A | Node 1 + Node 2 only |
| De-identification | N/A | Before cloud dispatch |
| Audit log | Optional | Required |
| AI disclaimer | Optional | Required |

---

## 10. PKM Integration

Both architectures integrate into the PKM platform via the plugin contract (`pkm.plugin.json`). The PKM platform manages the Aggregator process lifecycle, SSH tunnel health, and agent endpoint configuration. The plugin contract exposes:

**Endpoint registration.** Each agent registers its `base_url`, `api_key`, `model`, and `role`. The Aggregator reads this at startup and builds its dispatch table.

**SSE streaming.** The PKM's three-endpoint SSE architecture surfaces the Aggregator's streaming response to the client. Sub-task dispatch events can optionally be streamed as intermediate events, allowing the client to observe agent progress in real time.

**Temporal workflow integration.** Long-running multi-agent queries are wrapped in Temporal workflows. Each agent dispatch is a Temporal activity with configured retry and timeout policies. The timer-gated decision policy in the medical architecture maps directly to Temporal's activity timeout mechanism.

**Health monitoring.** The PKM platform monitors SSH tunnel liveness and vMLX server health on Node 1 and Node 2. A failed node triggers a configurable fallback: the Aggregator synthesizes a partial response from available agents and flags the unavailable agent in the output.

---

## 11. Comparison: Generic vs Medical

| Dimension | Generic | Medical |
|-----------|---------|---------|
| **Node 0 agents** | Aggregator, Search, Cloud | Medical Aggregator, Literature, Drug/Rx |
| **Node 1 agent** | Local Data RAG | Clinical Data RAG (EMR, labs, imaging) |
| **Node 2 agent** | Coding Agent | Diagnostic Reasoning Agent |
| **Node 1 model** | General-purpose LLM | Medical domain LLM |
| **Node 2 model** | Coding-capable LLM | Reasoning-capable LLM |
| **Aggregator type** | Routing + synthesis | Full reasoning agent |
| **PHI handling** | N/A | On-premise only (Node 1 + 2) |
| **Cloud dispatch** | Full sub-task | De-identified sub-task only |
| **Timer policy** | Optional | Required (per-agent timeout) |
| **Audit log** | Optional | Required |
| **Output disclaimer** | None | AI-generated · not clinical advice |
| **Compliance** | General | HIPAA Safe Harbor |
| **MCP tools (Node 2)** | File I/O, shell, git, code search | Diagnostic tooling, structured output |
| **Embedding endpoint** | `/v1/embeddings` on Node 1 | `/v1/embeddings` on Node 1 (de-id corpus) |

Both architectures share the same transport, authentication, vMLX configuration, context isolation principle, and PKM plugin contract structure. The medical architecture adds the PHI boundary, de-identification layer, timer-gated policy, audit log, and disclaimer as non-optional constraints on top of the generic pattern.

---

*// CJH — PKM Platform · oMLX-Cluster architecture pivot · 2026-04-02*
