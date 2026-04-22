---
layout: post
title: vMLX + oMLX-Cluster
subtitle: Local Inference Architecture for Apple Silicon — Technical Deep Dive
cover-img: /assets/img/path.jpg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/path.jpg
published: false
pinned: false
tags: [draft, AI, MLX, AppleSilicon, inference, oMLX, AgentCore]
---

# vMLX + oMLX-Cluster: Local Inference Architecture for Apple Silicon

> Technical deep dive into vMLX engine capabilities and their integration pathway into the oMLX-Cluster distributed inference roadmap · April 2026  
> Covers: vMLX 5-layer KV cache, JANG quantization, dual API, 256 concurrent sequences, JANG vs BitNet b1.58, oMLX-Cluster Phase 1a/1b/1c, AgentCore integration

---

## 1. Context and Motivation

Running large language models locally on Apple Silicon has moved from hobbyist experiment to production-viable
inference in 2026. The key enabler is Apple's unified memory architecture (UMA), which eliminates the
PCIe bus bottleneck between CPU and GPU. Every byte of the 16–512 GB unified pool is equally accessible
to the Neural Engine, GPU cores, and CPU — meaning the GPU's effective "VRAM" equals the machine's total RAM.

This document covers two interconnected systems:

- **vMLX** — an open-source MLX inference engine (`pip install vmlx`) that represents the current
  state of the art for single-node Apple Silicon inference
- **oMLX-Cluster** — a planned distributed inference layer built on top of MLX/JACCL, extending
  the single-node ceiling via Thunderbolt 5 / RDMA across multiple Mac mini M4 Pro units

The relationship is complementary: vMLX maximizes what a single node can extract from fixed hardware;
oMLX-Cluster expands the hardware ceiling itself via tensor parallelism.

---

## 2. Memory Budget: The Fundamental Constraint

Before examining engine features, the memory budget must be understood precisely. On a 16 GB Mac mini M4:

```
16 GB total unified memory
├── macOS + background processes    ≈ 2–3 GB   (fixed overhead)
├── Model weights (Qwen3.5-9B 4bit) ≈ 5–6 GB   (fixed at load time)
├── KV Cache budget                 ≈ 5–7 GB   ← vMLX 5-layer stack operates here
└── Headroom                        ≈ 1–2 GB
```

**Critical distinction:** Engine optimizations like the vMLX cache stack operate entirely on the
KV Cache budget — they do not compress or modify model weights. A 9B model loaded at 4-bit
quantization will always occupy ~5–6 GB regardless of how sophisticated the cache layer is.

The correct mental model:

```
5-layer cache optimization
         ↓
Same model weights (unchanged)
         ↓
KV Cache memory used more efficiently
       ↙              ↘
More context         More users
per session          per machine
(~8K → 100K+)       (1 → 256 concurrent)
```

---

## 3. vMLX Technical Pillars

### 3.1 Architecture Overview

<div align="center">

<svg width="680" height="320" viewBox="0 0 680 320" xmlns="http://www.w3.org/2000/svg" style="max-width:100%;font-family:system-ui,sans-serif;">
  <!-- Outer container -->
  <rect x="10" y="10" width="660" height="300" rx="14" fill="#f0fdf4" stroke="#0f6e56" stroke-width="1.5"/>
  <text x="340" y="36" text-anchor="middle" font-size="14" font-weight="600" fill="#0a4a3a">vMLX engine — single node capabilities</text>

  <!-- Tile 1: 5-layer cache -->
  <rect x="26" y="52" width="296" height="78" rx="8" fill="#d1fae5" stroke="#059669" stroke-width="1"/>
  <text x="174" y="82" text-anchor="middle" font-size="13" font-weight="600" fill="#065f46">5-layer KV Cache</text>
  <text x="174" y="100" text-anchor="middle" font-size="11" fill="#047857">prefix · paged · q4/q8 quant · cont. batch · disk</text>
  <text x="174" y="116" text-anchor="middle" font-size="11" fill="#047857">9.7× faster TTFT · 100K+ context on 16 GB</text>

  <!-- Tile 2: Dual API -->
  <rect x="358" y="52" width="296" height="78" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="1"/>
  <text x="506" y="82" text-anchor="middle" font-size="13" font-weight="600" fill="#1e3a8a">Dual API endpoint</text>
  <text x="506" y="100" text-anchor="middle" font-size="11" fill="#1d4ed8">Anthropic Messages API (/v1/messages)</text>
  <text x="506" y="116" text-anchor="middle" font-size="11" fill="#1d4ed8">OpenAI-compat (/v1/chat/completions)</text>

  <!-- Tile 3: JANG -->
  <rect x="26" y="148" width="296" height="78" rx="8" fill="#fef3c7" stroke="#d97706" stroke-width="1"/>
  <text x="174" y="178" text-anchor="middle" font-size="13" font-weight="600" fill="#78350f">JANG quantization</text>
  <text x="174" y="196" text-anchor="middle" font-size="11" fill="#92400e">Adaptive mixed-precision · attention@8bit</text>
  <text x="174" y="212" text-anchor="middle" font-size="11" fill="#92400e">MoE experts@2bit · 94% MMLU @ 3.99 bits</text>

  <!-- Tile 4: 256 concurrent -->
  <rect x="358" y="148" width="296" height="78" rx="8" fill="#ede9fe" stroke="#7c3aed" stroke-width="1"/>
  <text x="506" y="178" text-anchor="middle" font-size="13" font-weight="600" fill="#3b0764">256 concurrent sequences</text>
  <text x="506" y="196" text-anchor="middle" font-size="11" fill="#5b21b6">vLLM-style paged attention on Apple Silicon</text>
  <text x="506" y="212" text-anchor="middle" font-size="11" fill="#5b21b6">multi-session cache · Mamba/SSM support</text>

  <!-- Tile 5: Speculative + extras -->
  <rect x="26" y="244" width="620" height="52" rx="8" fill="#f1f5f9" stroke="#94a3b8" stroke-width="1"/>
  <text x="340" y="268" text-anchor="middle" font-size="13" font-weight="600" fill="#334155">Additional: speculative decoding · 50+ arch detection · 14 tool parsers · 4 reasoning parsers · VL models · embeddings</text>
  <text x="340" y="286" text-anchor="middle" font-size="11" fill="#475569">Claude Code · Cursor · Continue · Aider · LangChain — all work via localhost:8000</text>
</svg>

</div>

### 3.2 The 5-Layer KV Cache Stack

The KV cache is the memory region storing intermediate attention states computed during inference.
For a model with context length C, the KV cache grows linearly with C. Without optimization,
a 100K token context would require ~40 GB of KV cache memory alone — impossible on a 16 GB machine.
vMLX solves this with five independent but composable optimizations:

<div align="center">

<svg width="680" height="390" viewBox="0 0 680 390" xmlns="http://www.w3.org/2000/svg" style="max-width:100%;font-family:system-ui,sans-serif;">
  <defs>
    <marker id="arr2" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M2 1L8 5L2 9" fill="none" stroke="#64748b" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <!-- Layer 1: Prefix Cache -->
  <rect x="40" y="18" width="600" height="56" rx="10" fill="#dbeafe" stroke="#3b82f6" stroke-width="1.2"/>
  <text x="160" y="41" text-anchor="middle" font-size="13" font-weight="600" fill="#1e40af">Layer 1 — Prefix Cache</text>
  <text x="160" y="59" text-anchor="middle" font-size="11" fill="#2563eb">reuse shared prefixes (system prompt, codebase)</text>
  <text x="490" y="41" text-anchor="middle" font-size="12" font-weight="600" fill="#1e40af">Benefit</text>
  <text x="490" y="59" text-anchor="middle" font-size="11" fill="#2563eb">9.7× faster TTFT on warm context</text>

  <line x1="340" y1="74" x2="340" y2="92" stroke="#64748b" stroke-width="1" marker-end="url(#arr2)"/>

  <!-- Layer 2: Paged KV Cache -->
  <rect x="40" y="94" width="600" height="56" rx="10" fill="#d1fae5" stroke="#059669" stroke-width="1.2"/>
  <text x="160" y="117" text-anchor="middle" font-size="13" font-weight="600" fill="#065f46">Layer 2 — Paged KV Cache</text>
  <text x="160" y="135" text-anchor="middle" font-size="11" fill="#047857">vLLM-style paged attention, up to 1000 blocks</text>
  <text x="490" y="117" text-anchor="middle" font-size="12" font-weight="600" fill="#065f46">Benefit</text>
  <text x="490" y="135" text-anchor="middle" font-size="11" fill="#047857">256 sessions cached simultaneously</text>

  <line x1="340" y1="150" x2="340" y2="168" stroke="#64748b" stroke-width="1" marker-end="url(#arr2)"/>

  <!-- Layer 3: KV Quant -->
  <rect x="40" y="170" width="600" height="56" rx="10" fill="#fef3c7" stroke="#d97706" stroke-width="1.2"/>
  <text x="160" y="193" text-anchor="middle" font-size="13" font-weight="600" fill="#78350f">Layer 3 — KV Cache Quantization (q4/q8)</text>
  <text x="160" y="211" text-anchor="middle" font-size="11" fill="#92400e">full precision during generation, compressed at storage boundary</text>
  <text x="490" y="193" text-anchor="middle" font-size="12" font-weight="600" fill="#78350f">Benefit</text>
  <text x="490" y="211" text-anchor="middle" font-size="11" fill="#92400e">2–4× KV memory reduction, zero quality loss</text>

  <line x1="340" y1="226" x2="340" y2="244" stroke="#64748b" stroke-width="1" marker-end="url(#arr2)"/>

  <!-- Layer 4: Continuous Batching -->
  <rect x="40" y="246" width="600" height="56" rx="10" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.2"/>
  <text x="160" y="269" text-anchor="middle" font-size="13" font-weight="600" fill="#3b0764">Layer 4 — Continuous Batching</text>
  <text x="160" y="287" text-anchor="middle" font-size="11" fill="#5b21b6">256 concurrent inference sequences, intelligent scheduling</text>
  <text x="490" y="269" text-anchor="middle" font-size="12" font-weight="600" fill="#3b0764">Benefit</text>
  <text x="490" y="287" text-anchor="middle" font-size="11" fill="#5b21b6">team-scale inference from one Mac mini</text>

  <line x1="340" y1="302" x2="340" y2="320" stroke="#64748b" stroke-width="1" marker-end="url(#arr2)"/>

  <!-- Layer 5: Persistent Disk Cache -->
  <rect x="40" y="322" width="600" height="56" rx="10" fill="#fce7f3" stroke="#db2777" stroke-width="1.2"/>
  <text x="160" y="345" text-anchor="middle" font-size="13" font-weight="600" fill="#831843">Layer 5 — Persistent Disk Cache</text>
  <text x="160" y="363" text-anchor="middle" font-size="11" fill="#be185d">KV blocks written to SSD, survive restarts</text>
  <text x="490" y="345" text-anchor="middle" font-size="12" font-weight="600" fill="#831843">Benefit</text>
  <text x="490" y="363" text-anchor="middle" font-size="11" fill="#be185d">instant warm TTFT on next-day same-context queries</text>
</svg>

</div>

**Benchmark result on Apple M3 Ultra:** At 100K token context, vMLX achieves 154,121 prompt tokens/sec
(cold) versus LM Studio's 686 tok/s — a **224× speedup**. At 100K context warm (cached), 222,462 tok/s
versus LM Studio's 78,635 tok/s.

### 3.3 JANG Quantization

JANG (Jang Adaptive N-bit Grading) is a post-training quantization format for MLX, analogous to
GGUF K-quants for llama.cpp. Its core insight: not all layers in a transformer are equally sensitive
to quantization precision.

<div align="center">

<svg width="680" height="280" viewBox="0 0 680 280" xmlns="http://www.w3.org/2000/svg" style="max-width:100%;font-family:system-ui,sans-serif;">
  <defs>
    <marker id="arr3" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M2 1L8 5L2 9" fill="none" stroke="#64748b" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <!-- Title row -->
  <text x="170" y="22" text-anchor="middle" font-size="13" font-weight="600" fill="#374151">MLX uniform 2-bit</text>
  <text x="510" y="22" text-anchor="middle" font-size="13" font-weight="600" fill="#374151">JANG adaptive 2-bit</text>

  <!-- MLX side: attention block -->
  <rect x="30" y="34" width="280" height="52" rx="8" fill="#fecaca" stroke="#dc2626" stroke-width="1.2"/>
  <text x="170" y="58" text-anchor="middle" font-size="13" font-weight="600" fill="#7f1d1d">Attention layers</text>
  <text x="170" y="74" text-anchor="middle" font-size="11" fill="#991b1b">2-bit (same as experts) → BREAKS</text>

  <!-- MLX side: expert block -->
  <rect x="30" y="100" width="280" height="52" rx="8" fill="#fecaca" stroke="#dc2626" stroke-width="1.2"/>
  <text x="170" y="124" text-anchor="middle" font-size="13" font-weight="600" fill="#7f1d1d">MoE Expert MLPs</text>
  <text x="170" y="140" text-anchor="middle" font-size="11" fill="#991b1b">2-bit · 95–99% of parameters</text>

  <!-- MLX result -->
  <rect x="30" y="166" width="280" height="52" rx="8" fill="#fee2e2" stroke="#ef4444" stroke-width="1.2"/>
  <text x="170" y="190" text-anchor="middle" font-size="13" font-weight="600" fill="#991b1b">Result: model failure</text>
  <text x="170" y="208" text-anchor="middle" font-size="11" fill="#b91c1c">~25% MMLU (= random chance) / NaN / crash</text>

  <!-- JANG side: attention block -->
  <rect x="370" y="34" width="280" height="52" rx="8" fill="#d1fae5" stroke="#059669" stroke-width="1.2"/>
  <text x="510" y="58" text-anchor="middle" font-size="13" font-weight="600" fill="#065f46">Attention layers</text>
  <text x="510" y="74" text-anchor="middle" font-size="11" fill="#047857">8-bit PROTECTED (1–5% of params, controls coherence)</text>

  <!-- JANG side: expert block -->
  <rect x="370" y="100" width="280" height="52" rx="8" fill="#d1fae5" stroke="#059669" stroke-width="1.2"/>
  <text x="510" y="124" text-anchor="middle" font-size="13" font-weight="600" fill="#065f46">MoE Expert MLPs</text>
  <text x="510" y="140" text-anchor="middle" font-size="11" fill="#047857">2-bit compressed · 95–99% of parameters</text>

  <!-- JANG result -->
  <rect x="370" y="166" width="280" height="52" rx="8" fill="#dcfce7" stroke="#16a34a" stroke-width="1.2"/>
  <text x="510" y="190" text-anchor="middle" font-size="13" font-weight="600" fill="#14532d">Result: 74–94% MMLU</text>
  <text x="510" y="208" text-anchor="middle" font-size="11" fill="#166534">average ~2.1 bits · quality near 4-bit</text>

  <!-- Divider label -->
  <text x="340" y="136" text-anchor="middle" font-size="12" fill="#6b7280">vs</text>

  <!-- Bottom label -->
  <text x="340" y="256" text-anchor="middle" font-size="11" fill="#6b7280">JANG stays quantized in GPU memory via MLX native quantized_matmul — no float16 expansion</text>
</svg>

</div>

#### JANG vs Microsoft BitNet b1.58 — Comparison

These two technologies are fundamentally different in category:

| Dimension | JANG | BitNet b1.58 |
|---|---|---|
| **Technical category** | Post-Training Quantization (PTQ) | Quantization-Aware Training (QAT) |
| **Input** | Any existing float16 model | Train from scratch |
| **Minimum precision** | ~2-bit (mixed; attention@8bit) | 1.58-bit (uniform, all layers) |
| **Model availability** | Any HuggingFace model convertible | Only natively-trained BitNet models (very few) |
| **MoE support** | ✅ JANG's primary strength | ❌ Existing BitNet models are dense only |
| **Hardware target** | Apple Silicon Metal GPU (MLX) | Ideal: BitNet-dedicated hardware (adder arrays) |
| **Practical usability now** | ✅ Immediately usable | ❌ Almost no production models |

JANG operates as a compression tool on the **weight storage** dimension. BitNet redesigns the
weight representation during training. They are orthogonal and non-competing: a BitNet-trained model
would have no use for JANG. In the context of the oMLX-Cluster stack, JANG is the only relevant
option for the foreseeable future.

---

## 4. vMLX vs Competing Runtimes

<div align="center">

<svg width="680" height="300" viewBox="0 0 680 300" xmlns="http://www.w3.org/2000/svg" style="max-width:100%;font-family:system-ui,sans-serif;">
  <!-- Header row -->
  <rect x="10" y="10" width="660" height="36" rx="8" fill="#1e293b"/>
  <text x="130" y="33" text-anchor="middle" font-size="12" font-weight="600" fill="#f8fafc">Capability</text>
  <text x="300" y="33" text-anchor="middle" font-size="12" font-weight="600" fill="#f8fafc">vMLX</text>
  <text x="440" y="33" text-anchor="middle" font-size="12" font-weight="600" fill="#f8fafc">LM Studio</text>
  <text x="590" y="33" text-anchor="middle" font-size="12" font-weight="600" fill="#f8fafc">Ollama</text>

  <!-- Row data -->
  <!-- Row 1 -->
  <rect x="10" y="48" width="660" height="30" rx="0" fill="#f8fafc"/>
  <text x="130" y="67" text-anchor="middle" font-size="11" fill="#374151">KV cache layers</text>
  <rect x="268" y="52" width="64" height="22" rx="4" fill="#dcfce7"/><text x="300" y="67" text-anchor="middle" font-size="11" fill="#065f46">5 layers</text>
  <rect x="408" y="52" width="64" height="22" rx="4" fill="#fef9c3"/><text x="440" y="67" text-anchor="middle" font-size="11" fill="#713f12">1 (single-slot)</text>
  <rect x="558" y="52" width="64" height="22" rx="4" fill="#fee2e2"/><text x="590" y="67" text-anchor="middle" font-size="11" fill="#991b1b">none</text>

  <!-- Row 2 -->
  <rect x="10" y="80" width="660" height="30" rx="0" fill="#f1f5f9"/>
  <text x="130" y="99" text-anchor="middle" font-size="11" fill="#374151">Concurrent sequences</text>
  <rect x="268" y="84" width="64" height="22" rx="4" fill="#dcfce7"/><text x="300" y="99" text-anchor="middle" font-size="11" fill="#065f46">256</text>
  <rect x="408" y="84" width="64" height="22" rx="4" fill="#fee2e2"/><text x="440" y="99" text-anchor="middle" font-size="11" fill="#991b1b">1</text>
  <rect x="558" y="84" width="64" height="22" rx="4" fill="#fee2e2"/><text x="590" y="99" text-anchor="middle" font-size="11" fill="#991b1b">1</text>

  <!-- Row 3 -->
  <rect x="10" y="112" width="660" height="30" rx="0" fill="#f8fafc"/>
  <text x="130" y="131" text-anchor="middle" font-size="11" fill="#374151">Anthropic Messages API</text>
  <rect x="268" y="116" width="64" height="22" rx="4" fill="#dcfce7"/><text x="300" y="131" text-anchor="middle" font-size="11" fill="#065f46">✓</text>
  <rect x="408" y="116" width="64" height="22" rx="4" fill="#fee2e2"/><text x="440" y="131" text-anchor="middle" font-size="11" fill="#991b1b">✗</text>
  <rect x="558" y="116" width="64" height="22" rx="4" fill="#fee2e2"/><text x="590" y="131" text-anchor="middle" font-size="11" fill="#991b1b">✗</text>

  <!-- Row 4 -->
  <rect x="10" y="144" width="660" height="30" rx="0" fill="#f1f5f9"/>
  <text x="130" y="163" text-anchor="middle" font-size="11" fill="#374151">VL + full cache stack</text>
  <rect x="268" y="148" width="64" height="22" rx="4" fill="#dcfce7"/><text x="300" y="163" text-anchor="middle" font-size="11" fill="#065f46">✓ (5 layers)</text>
  <rect x="408" y="148" width="64" height="22" rx="4" fill="#fee2e2"/><text x="440" y="163" text-anchor="middle" font-size="11" fill="#991b1b">✗</text>
  <rect x="558" y="148" width="64" height="22" rx="4" fill="#fee2e2"/><text x="590" y="163" text-anchor="middle" font-size="11" fill="#991b1b">✗</text>

  <!-- Row 5 -->
  <rect x="10" y="176" width="660" height="30" rx="0" fill="#f8fafc"/>
  <text x="130" y="195" text-anchor="middle" font-size="11" fill="#374151">Speculative decoding</text>
  <rect x="268" y="180" width="64" height="22" rx="4" fill="#dcfce7"/><text x="300" y="195" text-anchor="middle" font-size="11" fill="#065f46">✓</text>
  <rect x="408" y="180" width="64" height="22" rx="4" fill="#fee2e2"/><text x="440" y="195" text-anchor="middle" font-size="11" fill="#991b1b">✗</text>
  <rect x="558" y="180" width="64" height="22" rx="4" fill="#fee2e2"/><text x="590" y="195" text-anchor="middle" font-size="11" fill="#991b1b">✗</text>

  <!-- Row 6 -->
  <rect x="10" y="208" width="660" height="30" rx="0" fill="#f1f5f9"/>
  <text x="130" y="227" text-anchor="middle" font-size="11" fill="#374151">JANG mixed-precision</text>
  <rect x="268" y="212" width="64" height="22" rx="4" fill="#dcfce7"/><text x="300" y="227" text-anchor="middle" font-size="11" fill="#065f46">✓</text>
  <rect x="408" y="212" width="64" height="22" rx="4" fill="#fee2e2"/><text x="440" y="227" text-anchor="middle" font-size="11" fill="#991b1b">✗</text>
  <rect x="558" y="212" width="64" height="22" rx="4" fill="#fee2e2"/><text x="590" y="227" text-anchor="middle" font-size="11" fill="#991b1b">✗</text>

  <!-- Row 7 -->
  <rect x="10" y="240" width="660" height="30" rx="0" fill="#f8fafc"/>
  <text x="130" y="259" text-anchor="middle" font-size="11" fill="#374151">100K context TTFT</text>
  <rect x="268" y="244" width="64" height="22" rx="4" fill="#dcfce7"/><text x="300" y="259" text-anchor="middle" font-size="11" fill="#065f46">0.65s cold</text>
  <rect x="408" y="244" width="64" height="22" rx="4" fill="#fee2e2"/><text x="440" y="259" text-anchor="middle" font-size="11" fill="#991b1b">131s cold</text>
  <rect x="558" y="244" width="64" height="22" rx="4" fill="#fef3c7"/><text x="590" y="259" text-anchor="middle" font-size="11" fill="#78350f">N/A</text>
</svg>

</div>

---

## 5. AgentCore Integration

For the AgentCore multi-agent framework, vMLX functions as the local inference backend.
The endpoint-agnostic architecture (`config/models.yaml` + `POST /admin/reassign`) maps
directly to vMLX's dual API without modification.

<div align="center">

<svg width="680" height="340" viewBox="0 0 680 340" xmlns="http://www.w3.org/2000/svg" style="max-width:100%;font-family:system-ui,sans-serif;">
  <defs>
    <marker id="arr4" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M2 1L8 5L2 9" fill="none" stroke="#64748b" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <!-- AgentCore box -->
  <rect x="10" y="10" width="660" height="130" rx="12" fill="#faf5ff" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="340" y="32" text-anchor="middle" font-size="13" font-weight="600" fill="#4c1d95">AgentCore — LangGraph orchestrator</text>

  <!-- 5 agent roles -->
  <rect x="26" y="44" width="110" height="80" rx="6" fill="#ede9fe" stroke="#7c3aed" stroke-width="0.8"/>
  <text x="81" y="68" text-anchor="middle" font-size="11" font-weight="600" fill="#3b0764">Planner</text>
  <text x="81" y="84" text-anchor="middle" font-size="10" fill="#5b21b6">ToT</text>
  <text x="81" y="100" text-anchor="middle" font-size="10" fill="#5b21b6">long context</text>
  <text x="81" y="115" text-anchor="middle" font-size="10" fill="#5b21b6">system prompt</text>

  <rect x="152" y="44" width="110" height="80" rx="6" fill="#ede9fe" stroke="#7c3aed" stroke-width="0.8"/>
  <text x="207" y="68" text-anchor="middle" font-size="11" font-weight="600" fill="#3b0764">Coder</text>
  <text x="207" y="84" text-anchor="middle" font-size="10" fill="#5b21b6">GoT</text>
  <text x="207" y="100" text-anchor="middle" font-size="10" fill="#5b21b6">codebase ctx</text>
  <text x="207" y="115" text-anchor="middle" font-size="10" fill="#5b21b6">tool use</text>

  <rect x="278" y="44" width="110" height="80" rx="6" fill="#ede9fe" stroke="#7c3aed" stroke-width="0.8"/>
  <text x="333" y="68" text-anchor="middle" font-size="11" font-weight="600" fill="#3b0764">Researcher</text>
  <text x="333" y="84" text-anchor="middle" font-size="10" fill="#5b21b6">ReAct+RAG</text>
  <text x="333" y="100" text-anchor="middle" font-size="10" fill="#5b21b6">large ctx</text>
  <text x="333" y="115" text-anchor="middle" font-size="10" fill="#5b21b6">ChromaDB</text>

  <rect x="404" y="44" width="110" height="80" rx="6" fill="#ede9fe" stroke="#7c3aed" stroke-width="0.8"/>
  <text x="459" y="68" text-anchor="middle" font-size="11" font-weight="600" fill="#3b0764">Reasoner</text>
  <text x="459" y="84" text-anchor="middle" font-size="10" fill="#5b21b6">native CoT</text>
  <text x="459" y="100" text-anchor="middle" font-size="10" fill="#5b21b6">thinking mode</text>
  <text x="459" y="115" text-anchor="middle" font-size="10" fill="#5b21b6">R1/Qwen3</text>

  <rect x="530" y="44" width="120" height="80" rx="6" fill="#ede9fe" stroke="#7c3aed" stroke-width="0.8"/>
  <text x="590" y="68" text-anchor="middle" font-size="11" font-weight="600" fill="#3b0764">Watcher</text>
  <text x="590" y="84" text-anchor="middle" font-size="10" fill="#5b21b6">MCTS eval</text>
  <text x="590" y="100" text-anchor="middle" font-size="10" fill="#5b21b6">rollout judge</text>
  <text x="590" y="115" text-anchor="middle" font-size="10" fill="#5b21b6">quality gate</text>

  <!-- All agents → vMLX (256 concurrent) -->
  <line x1="81" y1="140" x2="200" y2="188" stroke="#94a3b8" stroke-width="1" marker-end="url(#arr4)"/>
  <line x1="207" y1="140" x2="260" y2="188" stroke="#94a3b8" stroke-width="1" marker-end="url(#arr4)"/>
  <line x1="333" y1="140" x2="333" y2="188" stroke="#94a3b8" stroke-width="1" marker-end="url(#arr4)"/>
  <line x1="459" y1="140" x2="400" y2="188" stroke="#94a3b8" stroke-width="1" marker-end="url(#arr4)"/>
  <line x1="590" y1="140" x2="470" y2="188" stroke="#94a3b8" stroke-width="1" marker-end="url(#arr4)"/>

  <text x="340" y="174" text-anchor="middle" font-size="10" fill="#6b7280">all 5 roles → simultaneous requests via continuous batching</text>

  <!-- vMLX box -->
  <rect x="140" y="192" width="400" height="72" rx="10" fill="#d1fae5" stroke="#059669" stroke-width="1.5"/>
  <text x="340" y="216" text-anchor="middle" font-size="13" font-weight="600" fill="#065f46">vMLX — localhost:8000</text>
  <text x="340" y="234" text-anchor="middle" font-size="11" fill="#047857">/v1/messages (Anthropic) · /v1/chat/completions (OpenAI)</text>
  <text x="340" y="252" text-anchor="middle" font-size="11" fill="#047857">256 concurrent · 5-layer cache · JANG weights · 100K+ context</text>

  <!-- vMLX → model -->
  <line x1="340" y1="264" x2="340" y2="298" stroke="#059669" stroke-width="1.2" marker-end="url(#arr4)"/>

  <!-- Model box -->
  <rect x="200" y="300" width="280" height="32" rx="8" fill="#f0fdf4" stroke="#059669" stroke-width="1"/>
  <text x="340" y="320" text-anchor="middle" font-size="12" font-weight="600" fill="#14532d">Qwen3.5-9B 4bit (or JANG variant)</text>
</svg>

</div>

**Key integration point:** All 5 AgentCore roles can send concurrent requests to vMLX via the
256-sequence continuous batching pool. The `POST /admin/reassign` hot-swap endpoint allows
reassigning any role's model between local vMLX and remote (vLLM / Anthropic API) without
restarting the orchestrator.

---

## 6. oMLX-Cluster Phase Roadmap

The oMLX-Cluster project extends single-node inference to multi-node tensor parallelism using
JACCL (MLX over RDMA) across Thunderbolt 5. Three development phases are planned:

<div align="center">

<svg width="680" height="380" viewBox="0 0 680 380" xmlns="http://www.w3.org/2000/svg" style="max-width:100%;font-family:system-ui,sans-serif;">
  <defs>
    <marker id="arr5" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M2 1L8 5L2 9" fill="none" stroke="#64748b" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <!-- Phase labels -->
  <text x="133" y="22" text-anchor="middle" font-size="12" font-weight="600" fill="#374151">Phase 1a</text>
  <text x="340" y="22" text-anchor="middle" font-size="12" font-weight="600" fill="#374151">Phase 1b</text>
  <text x="547" y="22" text-anchor="middle" font-size="12" font-weight="600" fill="#374151">Phase 1c</text>

  <!-- Phase 1a -->
  <rect x="20" y="32" width="226" height="320" rx="12" fill="#d1fae5" stroke="#059669" stroke-width="1.5"/>
  <text x="133" y="58" text-anchor="middle" font-size="12" font-weight="600" fill="#065f46">Single M4 Pro</text>
  <text x="133" y="76" text-anchor="middle" font-size="11" fill="#047857">vMLX runtime (ring backend)</text>

  <rect x="36" y="90" width="194" height="44" rx="6" fill="#f0fdf4" stroke="#059669" stroke-width="0.8"/>
  <text x="133" y="108" text-anchor="middle" font-size="11" font-weight="600" fill="#065f46">Hardware</text>
  <text x="133" y="125" text-anchor="middle" font-size="10" fill="#047857">Mac mini M4 Pro 24–48 GB</text>

  <rect x="36" y="144" width="194" height="56" rx="6" fill="#f0fdf4" stroke="#059669" stroke-width="0.8"/>
  <text x="133" y="162" text-anchor="middle" font-size="11" font-weight="600" fill="#065f46">vMLX引用</text>
  <text x="133" y="178" text-anchor="middle" font-size="10" fill="#047857">5-layer cache baseline</text>
  <text x="133" y="194" text-anchor="middle" font-size="10" fill="#047857">Dual API for AgentCore</text>

  <rect x="36" y="210" width="194" height="56" rx="6" fill="#f0fdf4" stroke="#059669" stroke-width="0.8"/>
  <text x="133" y="228" text-anchor="middle" font-size="11" font-weight="600" fill="#065f46">Model target</text>
  <text x="133" y="244" text-anchor="middle" font-size="10" fill="#047857">Qwen3.5-9B 4bit</text>
  <text x="133" y="260" text-anchor="middle" font-size="10" fill="#047857">(~6 GB, 15–25 tok/s)</text>

  <rect x="36" y="276" width="194" height="56" rx="6" fill="#f0fdf4" stroke="#059669" stroke-width="0.8"/>
  <text x="133" y="294" text-anchor="middle" font-size="11" font-weight="600" fill="#065f46">Engineering focus</text>
  <text x="133" y="310" text-anchor="middle" font-size="10" fill="#047857">AgentCore ↔ vMLX API</text>
  <text x="133" y="326" text-anchor="middle" font-size="10" fill="#047857">cache warm-up strategy</text>

  <!-- Arrow 1a → 1b -->
  <path d="M246 192 L260 192 L260 192 L274 192" fill="none" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr5)"/>

  <!-- Phase 1b -->
  <rect x="247" y="32" width="186" height="320" rx="12" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5"/>
  <text x="340" y="58" text-anchor="middle" font-size="12" font-weight="600" fill="#1e3a8a">2× M4 Pro · TCP</text>
  <text x="340" y="76" text-anchor="middle" font-size="11" fill="#1d4ed8">shared API gateway</text>

  <rect x="263" y="90" width="154" height="44" rx="6" fill="#eff6ff" stroke="#2563eb" stroke-width="0.8"/>
  <text x="340" y="108" text-anchor="middle" font-size="11" font-weight="600" fill="#1e3a8a">Hardware</text>
  <text x="340" y="125" text-anchor="middle" font-size="10" fill="#1d4ed8">2× Mac mini M4 Pro</text>

  <rect x="263" y="144" width="154" height="56" rx="6" fill="#eff6ff" stroke="#2563eb" stroke-width="0.8"/>
  <text x="340" y="162" text-anchor="middle" font-size="11" font-weight="600" fill="#1e3a8a">vMLX引用</text>
  <text x="340" y="178" text-anchor="middle" font-size="10" fill="#1d4ed8">Dual API gateway</text>
  <text x="340" y="194" text-anchor="middle" font-size="10" fill="#1d4ed8">256 concurrent batching</text>

  <rect x="263" y="210" width="154" height="56" rx="6" fill="#eff6ff" stroke="#2563eb" stroke-width="0.8"/>
  <text x="340" y="228" text-anchor="middle" font-size="11" font-weight="600" fill="#1e3a8a">Model target</text>
  <text x="340" y="244" text-anchor="middle" font-size="10" fill="#1d4ed8">Qwen3.5-14B 4bit</text>
  <text x="340" y="260" text-anchor="middle" font-size="10" fill="#1d4ed8">(load balanced)</text>

  <rect x="263" y="276" width="154" height="56" rx="6" fill="#eff6ff" stroke="#2563eb" stroke-width="0.8"/>
  <text x="340" y="294" text-anchor="middle" font-size="11" font-weight="600" fill="#1e3a8a">Engineering focus</text>
  <text x="340" y="310" text-anchor="middle" font-size="10" fill="#1d4ed8">agent-role routing</text>
  <text x="340" y="326" text-anchor="middle" font-size="10" fill="#1d4ed8">TCP latency baseline</text>

  <!-- Arrow 1b → 1c -->
  <path d="M433 192 L447 192 L447 192 L461 192" fill="none" stroke="#64748b" stroke-width="1.5" marker-end="url(#arr5)"/>

  <!-- Phase 1c -->
  <rect x="434" y="32" width="226" height="320" rx="12" fill="#ede9fe" stroke="#7c3aed" stroke-width="1.5"/>
  <text x="547" y="58" text-anchor="middle" font-size="12" font-weight="600" fill="#3b0764">JACCL · RDMA · TB5</text>
  <text x="547" y="76" text-anchor="middle" font-size="11" fill="#5b21b6">tensor parallelism</text>

  <rect x="450" y="90" width="194" height="44" rx="6" fill="#faf5ff" stroke="#7c3aed" stroke-width="0.8"/>
  <text x="547" y="108" text-anchor="middle" font-size="11" font-weight="600" fill="#3b0764">Hardware</text>
  <text x="547" y="125" text-anchor="middle" font-size="10" fill="#5b21b6">TB5/RDMA ring, custom NodeDiscovery</text>

  <rect x="450" y="144" width="194" height="56" rx="6" fill="#faf5ff" stroke="#7c3aed" stroke-width="0.8"/>
  <text x="547" y="162" text-anchor="middle" font-size="11" font-weight="600" fill="#3b0764">vMLX引用</text>
  <text x="547" y="178" text-anchor="middle" font-size="10" fill="#5b21b6">JANG → larger model budget</text>
  <text x="547" y="194" text-anchor="middle" font-size="10" fill="#5b21b6">speculative decoding</text>

  <rect x="450" y="210" width="194" height="56" rx="6" fill="#faf5ff" stroke="#7c3aed" stroke-width="0.8"/>
  <text x="547" y="228" text-anchor="middle" font-size="11" font-weight="600" fill="#3b0764">Model target</text>
  <text x="547" y="244" text-anchor="middle" font-size="10" fill="#5b21b6">Qwen3.5-32B or MoE</text>
  <text x="547" y="260" text-anchor="middle" font-size="10" fill="#5b21b6">(tensor-split across nodes)</text>

  <rect x="450" y="276" width="194" height="56" rx="6" fill="#faf5ff" stroke="#7c3aed" stroke-width="0.8"/>
  <text x="547" y="294" text-anchor="middle" font-size="11" font-weight="600" fill="#3b0764">Engineering focus</text>
  <text x="547" y="310" text-anchor="middle" font-size="10" fill="#5b21b6">RDMA device name fix</text>
  <text x="547" y="326" text-anchor="middle" font-size="10" fill="#5b21b6">NodeDiscovery reboot-stable</text>
</svg>

</div>

### Critical Engineering Note for Phase 1c

JACCL has no auto-discovery. RDMA device names change on reboot, requiring a custom `NodeDiscovery`
module in the oMLX-Cluster project to maintain stable node identity. vMLX handles the single-node
inference layer in Phase 1c; cluster topology management remains oMLX's own engineering problem.

**Speculative decoding across nodes (Phase 1c opportunity):** With two M4 Pro units, one machine
can run a small 3B draft model at very high speed while the other runs the 32B target model.
JACCL passes the draft proposals over TB5/RDMA for verification. This is the most efficient use
of the hardware split and a direct JANG + vMLX speculative feature reference.

---

## 7. Model Selection for 16 GB Mac mini M4

Based on the 60–70% memory rule (model weights must not exceed 60–70% of total RAM):

| Priority | Model | Format | Weight size | Context headroom | Use case |
|---|---|---|---|---|---|
| 🥇 Primary | `mlx-community/Qwen3.5-9B-4bit` | MLX 4bit | ~6 GB | 100K+ with KV quant | General + reasoning |
| 🥈 Vision | `JANGQ-AI/Qwen3.5-VL-9B-4bit-MLX-CRACK` | JANG 4bit | ~6 GB | 64K+ | Multimodal |
| 🥉 Draft | `mlx-community/Qwen2.5-3B-4bit` | MLX 4bit | ~2 GB | N/A | Speculative draft model |
| ⚙️ Embed | `mlx-community/bge-small-en-v1.5` | MLX | ~100 MB | N/A | RAG embedding endpoint |

The draft model (Qwen2.5-3B) can be loaded alongside the primary model within the 16 GB budget,
enabling speculative decoding via vMLX's `--speculative-model` flag — yielding 15–30% throughput
increase on the primary model at no quality cost.

---

## 8. Technology Stack Coordinate Map

To place these technologies in context relative to each other:

```
Training-time intervention ←——————————————————→ Inference-time intervention

[BitNet b1.58]        [JANG PTQ]         [TurboQuant]      [vMLX 5-layer cache]
QAT, 1-bit weights    Adaptive weight     KV cache quant     KV state management
Needs retrain         compression         (PolarQuant+QJL)   serving optimization
No JANG needed        Any model →         Layer 3 of vMLX    Layers 1–5 of vMLX
                      smaller weights     stack              stack
```

**Orthogonal stackability:**
- JANG (weight compression) + vMLX KV cache quant (cache compression) → already combined in vMLX
- JANG + TurboQuant → theoretically orthogonal and stackable
- BitNet + JANG → not applicable (BitNet models have no float16 weights to compress)

---

## 9. Summary

vMLX delivers four independent but composable engineering wins on a single Apple Silicon node:

1. **5-layer KV cache** — converts a fixed memory budget into longer context and more concurrent
   users without changing the model or hardware
2. **Dual API** — Anthropic Messages + OpenAI-compatible endpoints on one server, enabling
   AgentCore endpoint-agnostic role assignment with zero code changes
3. **JANG quantization** — adaptive mixed-precision that preserves attention layer quality while
   aggressively compressing MoE expert layers, enabling model families that standard MLX
   cannot run at sub-4-bit
4. **256 concurrent sequences** — continuous batching that makes multi-agent orchestration
   (AgentCore's 5 roles) genuinely concurrent rather than serialized

For oMLX-Cluster, vMLX serves as the per-node inference runtime across all three planned phases,
with increasing feature dependency as the cluster scales: cache + API baseline in Phase 1a,
batching and load distribution in Phase 1b, and JANG + speculative decoding to maximize
the 32B+ model budget enabled by tensor parallelism in Phase 1c.

---

*References: [vmlx.net](https://vmlx.net) · [github.com/jjang-ai/vmlx](https://github.com/jjang-ai/vmlx) · [jangq.ai](https://jangq.ai) · [github.com/jjang-ai/jangq](https://github.com/jjang-ai/jangq) · [huggingface.co/JANGQ-AI](https://huggingface.co/JANGQ-AI)*