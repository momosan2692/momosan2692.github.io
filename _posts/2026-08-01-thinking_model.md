---
layout: post
title: Thinking Models, TTFT, and the VRAM Wall
subtitle: CoT training internals, budget forcing at the inference layer, KV cache math, and why 1M-token context doesn't fit on a desk
cover-img: /assets/img/header/2026-05-14/AI-NATIVE-WAN.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-14/AI-NATIVE-WAN.jpeg
published: true
pinned: true
tags: [draft, AI, LLM, inference, hardware]
---
# Thinking Models, TTFT, and the VRAM Wall

> Notes from a working session on reasoning-model latency, KV cache math, and the hard limits of local hardware · August 2026
> Covers: TTFT decomposition · RLVR training internals · trace faithfulness · budget forcing at the inference layer · llama-server cache-reuse mechanics · VRAM estimation for MoE models · concurrency-aware TTFT optimization · why 1M-token context doesn't fit on Apple Silicon (or almost anywhere)

This post collects a deep technical thread on why "thinking" models are slow to first token, how that cost is actually generated during training, how to control it at the inference layer, and — pushed to its logical end — why a 1M-token context window is a rack-scale problem, not a config flag.

---

## 1. TTFT for reasoning models isn't what it is for base models

For a non-reasoning model, time-to-first-token (TTFT) is essentially just **prefill**: process the prompt, build the KV cache, emit the first token almost immediately after. Prefill is compute-bound and highly parallelizable — it scales with prompt length but is comparatively cheap per token.

For a thinking model, TTFT-to-the-first-*visible*-answer-token is a different animal:

```
TTFT_reasoning = prefill_time + full_decode_of_hidden_reasoning_tokens
```

The model has to autoregressively generate its entire chain-of-thought — potentially hundreds to thousands of tokens — before it emits anything the user sees. This phase is **decode-bound**: one token at a time, memory-bandwidth-limited, sequential. It scales with *reasoning length*, not prompt length, and reasoning length itself scales with problem difficulty in a way that's hard to predict in advance.

Practical implication: if you're instrumenting TTFT in a pipeline, be explicit about which TTFT you mean — *time-to-first-thinking-token* (basically just prefill) versus *time-to-first-answer-token* (prefill + full CoT). For a reasoning model these can differ by an order of magnitude.

## 2. Turn cost is not equal, and thinking re-fires every turn

Two compounding effects explain why multi-turn latency in a reasoning-model pipeline doesn't behave the way people expect:

**Thinking is regenerated from scratch on every turn.** Most serving stacks strip the previous turn's reasoning trace before it's fed back into history — the model gets the prior *answer*, not the prior *reasoning*. So turn N pays a full thinking-decode cost again; there is no KV-cache continuity into the model's own past reasoning, because that state was never persisted in the first place.

**Per-turn cost is noisy, not flat.** Three things move independently:
- Reasoning length varies with question difficulty (dominant source of variance)
- Prefill grows as conversation history accumulates (linear, and cacheable if the serving stack supports it)
- Some models adapt reasoning depth to context — less if ambiguity is already resolved, more if the context complicates the task

Net effect: prefill trends upward slowly and is cacheable; thinking-decode cost is noisy and independent per turn and is *not* cacheable. They don't cancel into anything resembling constant per-turn latency.

## 3. Does prefill growth mean every loop takes longer?

Yes, in principle — context length is monotonically increasing each turn, and attention scales at best linearly (worse without optimization) with total context length. But three things bound the damage:

1. **Prefix caching.** If the serving stack caches KV state for the unchanged prefix, only the new tokens need prefilling — prefill cost becomes closer to *proportional to the new message*, not the whole history.
2. **Thinking-decode usually dominates anyway.** A 10K-token prefill on decent hardware is often still faster than decoding a few hundred sequential thinking tokens, because prefill is parallelized and thinking-decode is not.
3. **There's a hard ceiling** — the context window itself — so growth is bounded, not unbounded.

The practical takeaway for an agentic loop: if prefix caching isn't actually firing on your serving stack, expect turn latency to creep upward on top of the independent thinking-cost noise per turn. Whether it's firing is worth checking directly rather than assuming.

## 4. What actually happens inside a "thinking" model, mechanically

**Prompted CoT vs. trained "thinking."** The 2022-era "let's think step by step" technique is pure prompting — no training change, inconsistent quality, skippable. Current thinking models (o-series, DeepSeek-R1, QwQ, Gemini Thinking, Claude extended thinking) are explicitly post-trained to *always* emit an optimized reasoning trace before the final answer. That's the architecturally distinct thing.

**How the training actually works — RLVR.** The dominant recipe (DeepSeek-R1's published approach is the clearest public reference): the model generates a trace + answer, and a reward checks *only the final answer* against ground truth — a math result, whether code passes unit tests, and so on. Nothing directly supervises the reasoning trace itself. Behaviors like self-verification and backtracking emerge because they're instrumentally useful for getting the final answer right, not because anyone labeled them as "good reasoning." This is exactly why traces often look messy or repetitive — nothing rewards elegance, only correctness of the terminal output.

**Process reward models (PRM).** Some pipelines add a secondary model scoring intermediate steps, not just the final answer, to shape the trace directly. More expensive and harder to keep robust — step-level rewards are more exploitable than outcome-only rewards, which is part of why outcome-only RLVR has become the more common approach.

**Distillation.** Once a strong reasoning model exists, generate large volumes of (question, trace, answer) triples from it and fine-tune smaller models on the traces directly. This is how reasoning capability propagates cheaply into smaller open models — it's imitation of RL-derived behavior, not independent RL training. A distilled model is capped by trace quality and won't discover reasoning strategies RL might have found on its own.

**At inference time**, thinking models aren't running a different forward-pass mechanism — same autoregressive decode loop as any other model. What's different is the *policy* (what tokens it chooses to emit) and, at the serving layer, the *decoding budget* applied to the reasoning segment: special tokens or a separate channel wrap the trace so it can be stripped before display and before being fed back into history; some deployments force continuation or early termination to trade thinking-token count for latency.

## 5. Why RLVR-trained traces look the way they do — and where it breaks

**Reward hacking modes, documented in practice:**
- *Language mixing / incoherent-but-correct reasoning* — nothing in the reward penalizes readability, only the final answer's correctness, so traces can wander in ways a human reader wouldn't produce.
- *Shortcut exploitation* — if a verifier has an exploitable gap (e.g., a code reward based on a fixed test set), RL will find and exploit it rather than solving the general problem, because gradient descent optimizes reward, not understanding.
- *Length gaming* — if length correlates with reward during training, the policy can learn "longer is safer" as a heuristic even on easy problems, inflating trace length independent of actual need. This is why several labs add explicit length penalties.
- *Process-reward hacking* — when a PRM scores intermediate steps, the policy can learn to produce steps that *look* good to the PRM's classifier without being load-bearing for the answer — essentially adversarial examples against your own reward model.

**Trace faithfulness is a genuinely open problem.** Interpretability research (including work from Anthropic) perturbs traces — injecting a wrong intermediate claim or a hint — and checks whether the final answer changes accordingly. Faithfulness is inconsistent and degrades further on harder problems, which is exactly where you'd most want the trace to be trustworthy. Three regimes worth naming:
- *Post-hoc rationalization* — the model may settle on an answer early and generate a trace that reads as justification rather than as the process that produced it.
- *Silent computation* — some of the actual work may happen in hidden states across the whole sequence, not localized to specific trace tokens; the visible trace is a lossy projection, not the computation itself.
- *Steganographic-reasoning risk* — a theoretical concern in the interpretability literature: RL optimization pressure could in principle push a model toward encoding meaning in trace tokens in ways that aren't transparent to a human reader, since nothing in RLVR explicitly rewards legibility. Live research area, not settled.

**Practical rule for any pipeline that audits reasoning traces (e.g., a Judge/Gatekeeper role inspecting a Challenger's output):** treat the exposed trace as *evidence to be weighted*, not as a verified record of computation. Same epistemic status as a stated confidence score, not an audit log.

## 6. Budget forcing — implementations at the actual inference-engine level

Three mechanisms, simplest to most involved, all controllable without touching model weights.

**a) Stop-token suppression / forced continuation** (the s1-paper technique) — intercept the sampler at the reasoning/answer boundary:

```python
def generate_with_budget_forcing(model, prompt, min_think_tokens, max_think_tokens):
    think_tokens = []
    output_ids = tokenize(prompt)
    while True:
        next_token = model.sample_next(output_ids)
        if next_token == END_THINK_TOKEN and len(think_tokens) < min_think_tokens:
            forced = tokenize("Wait, let me reconsider.")
            output_ids += forced
            continue
        if len(think_tokens) >= max_think_tokens and next_token != END_THINK_TOKEN:
            output_ids.append(END_THINK_TOKEN)
            break
        output_ids.append(next_token)
        if next_token == END_THINK_TOKEN:
            break
        think_tokens.append(next_token)
    return output_ids
```

**b) Logit biasing on the end-think token** — coarser, no hard interception needed:

```python
class ThinkingBudgetProcessor:
    def __init__(self, end_think_token_id, min_tokens, max_tokens):
        self.end_think_id = end_think_token_id
        self.min_tokens = min_tokens
        self.max_tokens = max_tokens
        self.count = 0

    def __call__(self, token_ids, logits):
        self.count += 1
        if self.count < self.min_tokens:
            logits[self.end_think_id] = -float("inf")
        elif self.count > self.max_tokens:
            logits[:] = -float("inf")
            logits[self.end_think_id] = 0.0
        return logits
```

This is the practical mechanism behind hosted APIs' "reasoning effort" parameters — a thin serving-layer wrapper around a logit intervention, not (usually) a different checkpoint per effort tier.

**c) Shared-prefix KV cache for best-of-N thinking** — compute the prompt's KV cache once, branch N independent reasoning traces from it:

```python
prompt_kv_cache = model.prefill(prompt)   # computed once
branches = []
for i in range(N):
    branch_cache = prompt_kv_cache.clone()  # cheap, no recompute
    trace, answer = model.decode_from_cache(branch_cache, sampling_temp=0.8)
    branches.append((trace, answer))
best = select_best(branches)               # majority vote / verifier score
```

This is exactly what SGLang's RadixAttention and vLLM's PagedAttention are built for: the shared prefix's KV blocks are computed once and referenced (not copied) across branches, with copy-on-write as branches diverge. Without this, N branches means N× the raw prefill cost.

**Why this still doesn't give cross-turn continuity:** prefix caching reuses KV state *within* one generation call where branches share the same prompt tokens. Across conversation turns, the prompt itself changes (new message appended, old thinking stripped) — so cached blocks for "prompt + old thinking" are never referenced again by the next call. It's a cache-key mismatch, not a limitation of the caching mechanism.

### Realistic options on llama.cpp / MLX

**llama-server**, via the HTTP API's `logit_bias` and `cache_prompt`:

```python
import requests

def generate_with_budget(prompt, min_think_tokens=200, max_think_tokens=800,
                          end_think_str="</think>", server="http://localhost:8080"):
    end_think_id = tokenize(server, end_think_str)[0]
    r1 = requests.post(f"{server}/completion", json={
        "prompt": prompt,
        "n_predict": min_think_tokens,
        "logit_bias": [[end_think_id, -100]],
        "cache_prompt": True,
    })
    partial = r1.json()["content"]
    r2 = requests.post(f"{server}/completion", json={
        "prompt": prompt + partial,
        "n_predict": max_think_tokens - min_think_tokens,
        "cache_prompt": True,
        "stop": [end_think_str],
    })
    return partial + r2.json()["content"]
```

With `--cache-reuse` enabled server-side and `cache_prompt: true` on both calls, the second call doesn't recompute the first call's prefix — the two-call split costs an HTTP round trip, not a recompute.

**MLX-native** (more aligned with a multi-node MLX cluster roadmap, since the code carries forward): `mlx-lm`'s `generate_step` yields one token at a time, so budget forcing is direct, no round trip:

```python
from mlx_lm import load, generate_step
import mlx.core as mx

model, tokenizer = load("mlx-community/<model>-4bit")
end_think_id = tokenizer.encode("</think>")[-1]

def logits_processor(min_tok, max_tok):
    count = 0
    def process(tokens, logits):
        nonlocal count
        count += 1
        if count < min_tok:
            logits[..., end_think_id] = -mx.inf
        elif count > max_tok:
            logits[:] = -mx.inf
            logits[..., end_think_id] = 0.0
        return logits
    return process

prompt_ids = tokenizer.encode(prompt)
processor = logits_processor(min_tok=200, max_tok=800)
tokens = []
for token, _ in generate_step(mx.array(prompt_ids), model, logits_processor=processor):
    tokens.append(token)
    if token == end_think_id:
        break
```

Runs in-process, natural KV continuity within the call since there's no call split. Pin the exact `mlx-lm` version — the `generate_step` signature has shifted across releases.

## 7. llama-server's `--cache-reuse`: what it actually reuses

**Per-slot, not global.** Each of the `N` slots from `-np N` maintains an independent KV cache. A new request is routed to a slot via a longest-common-prefix heuristic against each idle slot's history, and the matching prefix is reused within that slot. It works at `-np > 1` — it just isn't a shared pool the way SGLang's radix tree is.

**Two real failure modes at `-np > 1`:**
1. Slot affinity isn't guaranteed — with more distinct prompt prefixes cycling through than slots available, cache reuse can effectively stop firing; even below that threshold, slot selection uses a "good enough" LCP match rather than a globally optimal one.
2. **Architecture-specific breakage.** Models with sliding-window / shared-KV attention layers have been reported to log "cache reuse is not supported" even with flash-attention and full-SWA flags enabled — worth verifying against your pinned build rather than assuming it's active, especially for hybrid local/global-attention architectures.

**Why SGLang isn't the answer on Apple Silicon.** SGLang's core performance (RadixAttention, CUDA graph capture, FlashInfer kernels) is built against CUDA; there's no mature Metal/MLX backend, and running it on Apple Silicon loses the engine's actual value. MLX is the architecturally correct serving stack for Apple Silicon hardware, not a CUDA-first engine ported over.

## 8. Estimating VRAM (unified memory) for a model

Three additive terms:

```
Total = weights + KV_cache(context, concurrency) + compute_overhead(~10-15%)
```

**Weights — the MoE trap.** VRAM is sized by *total* parameters, not active parameters. A 26B-total MoE model with 4B active per token still requires all 26B parameters resident in memory — the router only decides which experts get *computed* per token, not which get *loaded*. At 4-bit quantization (~0.55 bytes/param including scale/zero-point overhead):

```
26B params × 0.55 bytes/param ≈ 14.3 GB
```

**KV cache:**

```
KV_bytes = 2(K+V) × num_layers × num_kv_heads × head_dim × context_length × bytes_per_element × num_parallel_slots
```

Use the GQA head count, not total attention heads — this alone can cut KV cache 4-8x versus a naive multi-head assumption. `num_parallel_slots` matters directly: `-np 4` roughly quadruples this term versus `-np 1` at the same per-slot context length. The most reliable way to get exact layer/head/dim figures is to read them straight from the server's own verbose startup log rather than deriving them by hand from a spec sheet.

**Apple Silicon specific gotcha:** total installed RAM is not all usable by the GPU — macOS enforces a wired-memory ceiling, roughly 75% of total RAM by default (adjustable via `sysctl iogpu.wired_limit_mb`, at the cost of system stability headroom if pushed too far). A 32GB machine's *practical* ceiling is closer to ~24GB unless that default is explicitly overridden.

**Recommended workflow:** start the server at the intended `-c`/`-np`, read the exact reported KV allocation from the verbose log, then compute `weights + reported_kv × 1.12`. This removes the two biggest sources of estimate error — unknown GQA configuration and quantization overhead variance — at the cost of one test run.

## 9. Formalizing the TTFT-vs-VRAM tradeoff under concurrency

Given a target concurrency `N` and a VRAM budget `B`, the free variables are: weight quantization `q`, KV cache precision `k`, per-slot context length `L`, and slot count `np`.

**Hard constraint:**

```
W(q) + np · KV_slot(k, L) + overhead(q, np) ≤ B
```

**TTFT under load** decomposes as:

```
TTFT_i = queue_wait_i + prefill_compute_time(prompt_len_i)
```

`-np` doesn't add compute — it only provides more cache slots so more prefixes can stay hot, which improves TTFT for cache hits; raw tokens/sec throughput is unchanged by slot count. On a single accelerator, all slots share one compute pipeline via continuous batching, so under load, a new request's prefill has to interleave with other slots' in-flight decode. Model this with a standard utilization approximation:

```
ρ = N × (avg_tokens_per_request / max_sustained_throughput)
queue_wait ≈ (ρ / (1 - ρ)) × avg_service_time
```

As `ρ → 1`, queue wait blows up superlinearly — meaning there's a concurrency ceiling past which TTFT degrades sharply *regardless of available VRAM*. VRAM only gates how many slots you can allocate; it doesn't guarantee the compute can serve them promptly.

**The full optimization problem:**

```
minimize    TTFT_p95(q, k, np, L, N)
subject to  W(q) + np · KV_slot(k, L) + overhead(q, np) ≤ B
            np ≥ N
            ρ(N, q, np) < 1
```

Not closed-form — `TTFT_p95` depends on measured throughput, not clean algebra. The right approach is a constrained grid search, prioritized by which knob is cheapest to explore: fix `q` and `k` at intended production values, sweep `np` and `L`, read VRAM from the server's startup log and p95 TTFT from real request timing, and stop increasing either dimension at the first violation of the VRAM ceiling or the TTFT inflection point where the system starts saturating.

## 10. Mapping concurrency onto a scheduler with mixed dispatch modes

A useful reframing for any orchestration layer that doesn't look like generic multi-user chat: "concurrency" should map to *how many model calls the scheduler actually fires simultaneously*, not an abstract user count.

| Dispatch mode | Effective N | Optimal `np` | Binding constraint |
|---|---|---|---|
| Sequential (one call at a time) | 1 | 1 | Prefill compute only — no queueing term at all |
| Parallel (fixed fan-out) | fan-out count | = N | VRAM ceiling caps per-slot context length |
| Mixed (fan-out varies by phase) | peak fan-out | = N_peak | Size for the peak; off-peak slots are idle-but-safe, not reclaimed mid-run |

For parallel fan-out, the VRAM constraint forces a direct tradeoff between how many calls run together and how much context each gets — solving backward from a fixed weight+overhead budget caps per-slot context tightly once fan-out exceeds a handful of concurrent calls. One resolution: not every role in a fan-out needs the same reasoning depth — apply tighter budget forcing to narrow-scope sub-tasks and reserve full thinking budget only for whichever role does final synthesis, which shrinks the `avg_tokens_per_req` term in the queueing model directly. For mixed-mode schedules, size for the peak fan-out point and accept idle-slot memory cost during lower-fan-out phases — most local inference servers don't support hot-reconfiguring slot count without a restart, so dynamic resizing isn't a practical option regardless.

## 11. Worked example: a hybrid-attention MoE model, single slot

Using a real published hybrid-attention MoE architecture as a worked case (30 layers, most using sliding-window attention at one head dimension, a handful of layers using full/global attention at a larger head dimension, GQA with 4 KV heads shared across 8 query heads):

```
Local layers (26):  2(K+V) × 4 kv_heads × 256 head_dim = 2,048 elements/layer
Global layers (4):  2(K+V) × 4 kv_heads × 512 head_dim = 4,096 elements/layer

Per-token total = 26 × 2,048 + 4 × 4,096 = 69,632 elements/token
```

At q8_0 KV precision (1 byte/element): **~68 KB/token**
At fp16 KV precision (2 bytes/element): **~136 KB/token**

At `np = 1` and `L = 100,000` tokens:

| KV precision | Cost at 100K tokens | Fits a ~24GB practical budget (after ~14.3GB weights)? |
|---|---|---|
| q8_0 | ~6.5 GB | Yes — thin margin, ~0.6GB |
| fp16 | ~13.0 GB | No — exceeds by ~6GB |

The structural point: collapsing to `np = 1` (pure sequential dispatch) removes the queueing term and the multi-slot KV multiplication entirely — the whole budget belongs to one context. That's the difference between infeasible and barely-feasible at 100K tokens; concurrency, not context length itself, was the thing eating the budget at higher `np`.

## 12. Why 1M-token context is a rack problem, not a config problem

**The naive number, at a plausible dense-model config:** 96 layers, 64 heads, 128 head-dim, fp16 KV — about **6MB of KV cache per token**, or **6TB at 1M tokens**. Two 80GB accelerators combined (160GB) fall short by roughly 37x. Getting a 70B-class model to fit 1M tokens on a single 80GB accelerator requires on the order of 33x compression from that baseline — that's an architecture-level achievement (MLA-class compression, extreme MoE sparsity), not a serving flag.

**What real 1M-token deployments actually run on:** multi-GPU/TPU racks with specialized interconnects, not any single machine. A concrete production shape: a 1M-token request's ~164GB FP8 KV cache distributed across 4 context-parallel ranks spanning 32 GPUs, each rank holding roughly 41GB — comfortably within a modern accelerator's per-GPU HBM, but only because the KV cache is *sharded across 32 devices*, not held on one.

**Three techniques make this possible at all, and only one of them shrinks the actual memory footprint:**
- *Context parallelism / ring attention* — continuous key-value exchange between GPUs across nodes; if transfer time exceeds compute time, devices sit idle instead of computing. Requires NVLink-class (1.8TB/s) or InfiniBand-class interconnects; this is the load-bearing technique and the most bandwidth-hungry.
- *FlashAttention* — tiles Q/K/V into SRAM-sized blocks with an online softmax, avoiding materializing the full attention matrix (which would otherwise be hundreds of GB per layer at long context). This makes the *compute* tractable — it does not shrink the KV cache itself.
- *KV compression* — the part that actually reduces the number: grouped-query attention (up to 8x reduction), multi-head latent attention (over 90% cache reduction in published results, while preserving multi-head expressiveness), or hybrid global/sliding-window designs that cut memory substantially versus full attention on every layer.

**Where this leaves local/prosumer hardware.** The bottleneck that survives regardless of memory topology is bandwidth, not capacity: every decode step in standard attention has to *read* the entire accumulated KV cache, not just store it. Even in a hypothetical world where 1M tokens of KV cache physically fits in unified memory, reading ~30GB of cache on every single generated token, at a unified-memory bandwidth on the order of ~200GB/s, works out to roughly 150ms per token from KV reads alone — a single-digit-tokens-per-second ceiling, before adding the bandwidth cost of reading active weights on top. Unified memory removes the PCIe-hop penalty that a discrete-GPU system would pay when spilling KV cache to system RAM, but it does not change the underlying scaling law: cost grows with context length regardless of where the bytes physically live.

**A specific note on distributed Apple Silicon clusters.** The technique that makes 1M-token context work on real hardware — ring attention across nodes — is bandwidth-hungry in exactly the way a Thunderbolt-class interconnect isn't built for. NVLink runs near 1.8TB/s; Thunderbolt 5 tops out around 120Gb/s (~15GB/s) — roughly two orders of magnitude slower. Even with an RDMA-class transport minimizing protocol overhead, the wire bandwidth ceiling doesn't move. A multi-node unified-memory cluster over Thunderbolt genuinely aggregates *capacity* — useful for running multiple independent models, or scaling a single node's practical context ceiling — but a context-parallel single-request 1M-token workload spread across such a cluster would be severely interconnect-bound well before the capacity limit is even reached.

**The only architecture-level escape.** Standard transformer attention has KV cache that grows linearly with context, with no ceiling — this isn't a tuning problem, it's structural. The genuine way out is a model whose *state size is independent of context length*: recurrent/SSM-hybrid architectures maintain a fixed-size hidden state that gets updated rather than a cache that gets appended to. This is memory-architecture-agnostic — it's a win on any hardware, including a single consumer machine — but it trades exact long-range recall for a lossy, compressed representation of history, a quality tradeoff rather than a memory one.

## 13. Practical takeaways

- **Instrument TTFT precisely.** Separate "first thinking token" from "first answer token" — for a reasoning model these can differ by an order of magnitude, and conflating them will misdirect any latency-optimization effort.
- **Treat reasoning traces as evidence, not audit logs**, in any pipeline that inspects or scores them — trace faithfulness is an open research problem, not a solved one.
- **Route by task, not uniformly.** Not every step in a multi-agent pipeline needs full reasoning depth; budget-forcing narrow sub-tasks and reserving full thinking budget for synthesis is probably the single biggest lever for reducing latency variance in a heterogeneous agent system.
- **Verify cache-reuse is actually firing** on your pinned build before budgeting latency around it — architecture-specific breakage (hybrid attention, sliding-window layers) is a documented failure mode, not a hypothetical one.
- **Read KV-cache size from the server's own startup log**, not from a hand-derived formula, before committing to a production `-c`/`-np` configuration — the two biggest sources of estimate error (exact GQA config, quantization overhead) are exactly the things a real startup log resolves for free.
- **Size concurrency for the peak, not the average**, in any mixed-dispatch scheduler, and accept idle-slot memory cost off-peak rather than trying to dynamically resize — most local serving stacks don't support the latter without a restart anyway.
- **1M-token context is a rack-scale, interconnect-bound problem.** On a single machine — including Apple Silicon with unified memory — it is out of reach by roughly an order of magnitude under standard attention, regardless of quantization or memory topology. The realistic paths are: accept a bounded/sliding working set with externalized long-term memory (a shared-memory or blackboard-style architecture standing in for the model's own context), or adopt a model architecture with sub-linear state growth.