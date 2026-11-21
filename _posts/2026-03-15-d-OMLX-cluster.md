---
layout: post
title: oMLX-Cluster
subtitle: Clustering Methods — Decision Log and Phases
cover-img: /assets/img/header/2026-03-04/DATACENTER.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-03-04/DATACENTER.jpeg
published: false    # ← add this, post won't show on blog
pinned: false # true — pin a post to the top
tags: [draft]
---


# oMLX-Cluster
## Clustering Methods — Decision Log

**Version 1.0 | March 2026 | Hardware: 3x Mac mini M4 Pro 48GB**

| | METHOD 1 | METHOD 2 | METHOD 3 |
|---|---|---|---|
| | llama.cpp RPC | MLX JACCL RDMA | Exo |
| | REFERENCE ONLY | **SELECTED** | REFERENCE ONLY |

---

## 1. Overview

This document logs the evaluation of three distributed inference clustering methods for the **oMLX-Cluster** project. The target hardware is **3x Mac mini M4 Pro 48GB** connected via Thunderbolt 5, running macOS 26.2+. All three methods are documented for record — Methods 1 and 3 are highlighted as reference alternatives, Method 2 is the selected implementation path. 3 nodes is the architecturally correct choice for full-mesh RDMA: each Mac mini M4 Pro has exactly 3 TB5 ports, so a 3-node full mesh uses all ports with no waste and no exhaustion. A 4th node would consume the last port on each machine with no redundancy; 5+ nodes would require a TB5 switch, breaking the full-mesh RDMA guarantee entirely.

### Hardware Context

| Spec | Per Node | 3-Node Cluster |
|------|----------|----------------|
| Model | Mac mini M4 Pro 48GB | 3 nodes |
| Total RAM | 48 GB unified | ~144 GB |
| RAM after macOS | ~40 GB for oMLX | ~120 GB pooled |
| Interconnect | Thunderbolt 5 | Full mesh (3 cables) |
| RDMA | Yes (TB5) | Yes — macOS 26.2+ |
| Cost | ~$1,800/node | ~$5,400 total |

---

## 2. Method 1 — llama.cpp RPC  [REFERENCE]

> **REFERENCE ONLY — NOT SELECTED.** Documented for record. See Section 6 for exclusion rationale.

### Architecture

llama.cpp exposes an `rpc-server` binary that runs on each worker node, accepting incoming tensor operations from the primary node over TCP. The primary node runs `llama-cli` or `llama-server` and offloads model layers to remote workers via TCP sockets.

**Network topology:**

```
Node 1 (primary)        Node 2 (worker)       Node 3 (worker)
─────────────────       ───────────────        ───────────────
llama-server            rpc-server             rpc-server
  |                       |                      |
  +──── TCP :50052 ───────+                      |
  +──── TCP :50052 ────────────────────────────--+
```

### Configuration Steps

#### Step 1: Build with RPC on each node

```bash
# Clone and build with RPC + Metal support
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
cmake -B build -DGGML_METAL=ON -DGGML_RPC=ON
cmake --build build --parallel
```

#### Step 2: Start RPC server on each worker

```bash
# Node 2 — worker
./build/bin/rpc-server \
  --host 0.0.0.0 \
  --port 50052 \
  --mem 32000        # MB of memory to expose

# Node 3 — worker (same command)
./build/bin/rpc-server --host 0.0.0.0 --port 50052 --mem 32000
```

#### Step 3: Run inference on primary

```bash
# Node 1 — primary (with llama-server for OpenAI API)
./build/bin/llama-server \
  -m ~/models/DeepSeek-R1-671B-Q4_K_M.gguf \
  --rpc 192.168.1.2:50052,192.168.1.3:50052 \
  -ngl 99 \          # offload all layers to Metal + RPC
  -c 8192 \          # context window
  --host 0.0.0.0 \
  --port 8080
```

### Key Characteristics

- Transport: TCP over Ethernet — no RDMA, no special hardware required
- Model format: GGUF only — incompatible with MLX safetensors
- Memory distribution: weights + KV cache split proportionally across nodes
- OpenAI API: available via llama-server
- ❌ Performance: degrades as nodes are added (TCP overhead > compute gain)
- ❌ Proven: 20.4 tok/s (1 node) → 15.2 tok/s (4 nodes) on Qwen3 235B

---

## 3. Method 2 — MLX JACCL RDMA  [SELECTED]

> **SELECTED — Primary Implementation Path.** This is the method being built in oMLX-Cluster Phase 1 and 2.

### Architecture

MLX's JACCL (Jack and Angelos' Collective Communication Library, pronounced "Jackal") backend provides distributed collective operations natively over RDMA-capable Thunderbolt 5 connections. The `mx.distributed` Python API handles all RDMA transport transparently — no Swift wrapper, no ctypes, no custom bindings required.

### Configuration Steps

#### Step 1: Enable RDMA (one-time, per node)

```bash
# Boot each Mac into recovery mode (hold power button on M4)

# PREREQUISITE: Disable Thunderbolt Bridge to prevent CPU spikes and traffic storms
# System Preferences → Network → Thunderbolt Bridge → Remove

# Open Terminal in recovery environment
rdma_ctl enable

# Reboot normally, then verify
rdma_ctl status
# Expected output: RDMA enabled, Thunderbolt 5 interface active
```

#### Step 2: Python distributed init

```python
import mlx.core as mx

# JACCL auto-detects TB5 RDMA connections — no manual config
mx.distributed.init()

# All collective ops route over RDMA automatically
result = mx.distributed.all_sum(tensor)    # AllReduce per layer
world_size = mx.distributed.world_size()   # 3 for 3-node cluster
rank = mx.distributed.rank()               # 0, 1, or 2
```

#### Step 3: oMLX-Cluster serve command

```bash
# Node 1 — primary
omlx serve \
  --model-dir ~/models \
  --max-model-memory 40GB \
  --cluster-mode tensor_parallel \
  --cluster-nodes 3 \
  --rdma-memory-pool 32GB \
  --node-role primary \
  --paged-ssd-cache-dir ~/.omlx/cache \
  --host 0.0.0.0

# Node 2, Node 3 — workers
omlx serve \
  --model-dir ~/models \
  --node-role worker \
  --primary-addr 192.168.1.1
```

### Key Characteristics

- ✅ Transport: RDMA over Thunderbolt 5 — 80 Gb/s, 5-9 µs latency
- ✅ Model format: MLX safetensors — native, no conversion needed
- ✅ KV cache: full 5-tier SSD-persistent cache across all nodes (oMLX application layer — compatible with Method 2, not intrinsic to JACCL)
- ✅ API surface: OpenAI + Anthropic — unchanged from single-node oMLX
- ✅ Performance: scales correctly — more nodes = more throughput
- Requires: TB5 hardware (M4 Pro / M4 Max / M3 Ultra) + macOS 26.2+
- Status: Phase 1 implementation in progress (oMLX-Cluster fork)

---

## 4. Method 3 — Exo  [REFERENCE]

> **REFERENCE ONLY — NOT SELECTED.** Documented for record. See Section 6 for exclusion rationale.

### Architecture

Exo uses automatic peer discovery (mDNS) and shard assignment. Each node runs a single `exo` process that self-organizes into a cluster without manual configuration. Shard assignment is computed automatically based on available memory per node.

### Configuration Steps

#### Step 1: Install on each node

```bash
pip install exo
```

#### Step 2: Run on each node — that is literally it

```bash
# Node 1, Node 2, Node 3 — same command on all
exo

# Exo auto-discovers peers via mDNS
# Auto-assigns model shards based on available RAM
# Auto-routes requests to primary node
# OpenAI-compatible API at http://localhost:52415/v1
```

#### Optional: specify model explicitly

```bash
exo run llama-3.3-70b
# or
exo run deepseek-r1-671b
```

### Key Characteristics

- ✅ Configuration: zero-config — simplest setup of all three methods
- ✅ Discovery: mDNS automatic peer discovery over local network
- ✅ RDMA: supported via TB5 when available — scales correctly with RDMA
- ✅ Format: MLX and GGUF models supported
- ❌ KV cache: NONE — no SSD cache, no prefix sharing, no CoW
- ❌ Continuous batching: NOT supported — one request at a time per shard
- ❌ Anthropic API: NOT supported — OpenAI only
- ❌ mem0 / LlamaIndex integration: requires workaround shim

---

## 5. Full Comparison

| Dimension | Method 1: llama.cpp RPC | Method 2: MLX JACCL RDMA | Method 3: Exo |
|-----------|------------------------|--------------------------|---------------|
| Transport | TCP | RDMA TB5 | TCP / RDMA |
| Model format | GGUF only | MLX native | MLX + GGUF |
| KV cache | Basic | 5-tier SSD | None |
| Continuous batching | No | Yes (4.14x†) | No |
| OpenAI API | Yes | Yes | Yes |
| Anthropic API | No | Yes | No |
| Scaling (more nodes) | **WORSE** | Better | Better (RDMA) |
| TB5 RDMA | No | Required | Optional |
| Config complexity | Medium | Medium | Trivial |
| oMLX stack compat | No (GGUF) | Native | Partial |
| LlamaIndex + mem0 | Workaround | Native | Workaround |
| Production ready | Mature | Building | Early |
| **Status** | Reference only | **SELECTED** | Reference only |

† Internal oMLX benchmark — not externally sourced.

---

## 6. Exclusion Rationale

### Why Method 1 (llama.cpp RPC) was excluded

- Model format mismatch: all models are MLX safetensors — GGUF re-download required
- TCP transport degrades with nodes: proven 20.4 → 15.2 tok/s on 4-node cluster (note: different config from 3-node target, but degradation is intrinsic to TCP fan-out regardless of count)
- No RDMA support: cannot use TB5 bandwidth advantage of M4 Pro hardware
- Stack incompatibility: sits outside LlamaIndex + mem0 + oMLX pipeline
- No Anthropic API: Claude Code and Anthropic SDK integration requires workaround

### Why Method 3 (Exo) was excluded

- No KV cache: SSD-tiered persistent cache is the core value proposition of oMLX
- No continuous batching: loses 4.14x throughput advantage (internal oMLX benchmark — not sourced from JACCL)
- No Anthropic API: Claude Code integration not supported
- No LlamaIndex / mem0 native integration: RAG pipeline requires workaround
- Project maturity: early-stage, production stability unverified

### Why Method 2 (MLX JACCL RDMA) was selected

- Native MLX: no format conversion, no model re-download
- RDMA scales correctly: throughput improves with nodes added
- Full oMLX stack continuity: LlamaIndex, mem0, SSD cache all preserved
- Both OpenAI + Anthropic API: Claude Code works natively
- Python API clean: `mx.distributed.init()` — no Swift or ctypes needed
- Hardware match: M4 Pro TB5 is RDMA-capable, macOS 26.2 confirmed

---

## 7. Next Steps

| Phase | Duration | Deliverable | Gate |
|-------|----------|-------------|------|
| P0 | 1-2 days | RDMA spike — prove `mx.distributed` works over TB5. Known failure mode: `RuntimeError [jaccl] socket bind error 47` — test explicitly. | Must pass before P1 |
| P1 | 8-10 weeks | RDMATransport + Tier 3 + Tier 5 KV cache (coupled) | P0 success |
| P2 | 6-8 weeks | Tensor parallel via JACCL AllReduce — 200B models | P1 complete |
| P3 | 3-4 weeks | Cluster UI + fault tolerance + node dropout replan | P2 complete |

---

*Document prepared: March 2026 | Status: Decision finalized | Method 2 selected, Methods 1 & 3 archived for reference*

---
# Session II Design Phase Track
---

# oMLX-Cluster — Phase 1 Architecture Design

**P1 Design Doc | March 2026 | Status: Pre-implementation (P0 pending)**

---

## 1. Scope

P1 builds two tightly coupled components: **RDMATransport** (replacing the existing TCPTransport class) and **KV Cache Tiers 3 and 5**. These are coupled because the cache eviction policy must route through the transport layer — Tier 3 (local SSD) uses local I/O while Tier 5 (remote SSD) uses RDMA. The transport interface contract must be defined before either component is built.

> ⚠ P0 gate must pass before P1 implementation begins. This document is design-only.

| Phase | Component | Deliverable | Dependency |
|-------|-----------|-------------|------------|
| P1-A | RDMATransport | Drop-in replacement for TCPTransport via mx.distributed | P0 success |
| P1-B | KV Cache Tier 3 | Local SSD eviction from Tier 2 RAM | P1-A interface |
| P1-C | KV Cache Tier 5 | Cross-node remote SSD eviction via RDMATransport (stubbed) | P1-A + P1-B |

---

## 2. Transport Interface Contract

The core design decision: both `TCPTransport` and `RDMATransport` must implement the same interface so the KV cache manager is transport-agnostic. This enables fallback to TCP if RDMA is unavailable at runtime, and allows unit testing the cache layer against a mock transport.

### 2.1 BaseTransport ABC

```python
# transport/base.py
from abc import ABC, abstractmethod
import mlx.core as mx
from dataclasses import dataclass

@dataclass
class TransportStats:
    bytes_sent: int = 0
    bytes_recv: int = 0
    latency_us: float = 0.0    # last observed round-trip
    errors: int = 0

class BaseTransport(ABC):
    """Transport interface — all implementations must satisfy this contract."""

    @abstractmethod
    def send(self, tensor: mx.array, dst_rank: int, tag: int) -> None:
        """Non-blocking send. Caller must call sync() before reusing buffer."""

    @abstractmethod
    def recv(self, shape: tuple, dtype: mx.Dtype,
             src_rank: int, tag: int) -> mx.array:
        """Blocking recv. Returns tensor on completion."""

    @abstractmethod
    def all_reduce(self, tensor: mx.array) -> mx.array:
        """In-place AllReduce across all ranks."""

    @abstractmethod
    def sync(self) -> None:
        """Block until all pending sends are complete."""

    @abstractmethod
    def stats(self) -> TransportStats:
        """Return transport diagnostics for monitoring."""

    @property
    @abstractmethod
    def is_rdma(self) -> bool:
        """True if this transport uses RDMA (used by cache routing logic)."""
```

### 2.2 RDMATransport Implementation

```python
# transport/rdma.py
import mlx.core as mx
from .base import BaseTransport, TransportStats
import time

class RDMATransport(BaseTransport):
    """
    RDMA transport via mx.distributed (JACCL backend).
    Requires: rdma_ctl enabled, Thunderbolt Bridge disabled, macOS 26.2+.
    Known failure mode: RuntimeError [jaccl] socket bind error 47
    — ensure no stale mx.distributed state from prior init.
    """

    def __init__(self):
        mx.distributed.init()   # JACCL auto-detects TB5 RDMA
        self._rank = mx.distributed.rank()
        self._world = mx.distributed.world_size()
        self._stats = TransportStats()

    def send(self, tensor: mx.array, dst_rank: int, tag: int) -> None:
        # JACCL point-to-point — placeholder until mx.distributed exposes p2p
        # For P1: use all_sum with masked tensor as workaround
        raise NotImplementedError("P2P send: pending JACCL p2p API")

    def recv(self, shape, dtype, src_rank, tag) -> mx.array:
        raise NotImplementedError("P2P recv: pending JACCL p2p API")

    def all_reduce(self, tensor: mx.array) -> mx.array:
        t0 = time.monotonic()
        result = mx.distributed.all_sum(tensor)
        mx.eval(result)
        self._stats.latency_us = (time.monotonic() - t0) * 1e6
        return result

    def sync(self) -> None:
        mx.eval()   # flush MLX lazy eval graph

    def stats(self) -> TransportStats:
        return self._stats

    @property
    def is_rdma(self) -> bool:
        return True
```

### 2.3 TCPTransport (fallback — existing class, add `is_rdma` only)

```python
# transport/tcp.py  — existing implementation, add is_rdma property only
class TCPTransport(BaseTransport):
    # ... existing code ...

    @property
    def is_rdma(self) -> bool:
        return False
```

---

## 3. KV Cache Architecture

The existing cache handles Tiers 1–2 (GPU memory → unified RAM). P1 adds Tiers 3 and 5. Tier 4 (remote RAM) is deferred to P2. The eviction pipeline is extended downward — each eviction decision checks tier availability and transport cost before committing.

### 3.1 Tier Map

| Tier | Storage | Location | Transport | P1 Status |
|------|---------|----------|-----------|-----------|
| 1 | GPU/Metal unified | Local | Direct | ✅ Exists |
| 2 | Unified RAM | Local | Direct | ✅ Exists |
| 3 | Local SSD | Local | Local I/O | 🔨 P1-B Build |
| 4 | Remote RAM | RDMA | RDMATransport | ⏳ P2 Deferred |
| 5 | Remote SSD | RDMA | RDMATransport | 🔨 P1-C Stub |

### 3.2 CacheManager Eviction Policy

Eviction is triggered when a tier exceeds its capacity threshold. The manager walks down the tier chain and places the evicted block at the first available tier. The critical rule: remote tiers (Tier 5) are only attempted if `RDMATransport.is_rdma` is `True` and the transport is healthy.

```python
# cache/manager.py
from dataclasses import dataclass, field
from typing import Optional
import mlx.core as mx
from transport.base import BaseTransport

@dataclass
class KVBlock:
    block_id: str
    layer_idx: int
    data: mx.array
    tier: int = 1              # current tier
    owning_rank: int = 0       # which node generated this block

class KVCacheManager:
    def __init__(
        self,
        transport: BaseTransport,
        tier3_path: str,           # local SSD path e.g. ~/.omlx/cache
        tier3_capacity_gb: float = 200.0,
        tier5_capacity_gb: float = 200.0,   # per node, remote
        rank: int = 0,
    ):
        self.transport = transport
        self.tier3_path = tier3_path
        self.rank = rank
        self._tier3_store = LocalSSDStore(tier3_path, tier3_capacity_gb)
        self._tier5_store = RemoteSSDStore(transport, tier5_capacity_gb) \
                            if transport.is_rdma else None

    def evict(self, block: KVBlock) -> int:
        """
        Evict block from current tier. Returns destination tier.
        Eviction chain: Tier 2 → Tier 3 → Tier 5 → OOM error
        """
        if block.tier == 2:
            if self._tier3_store.has_capacity():
                self._tier3_store.write(block)
                block.tier = 3
                return 3
            elif self._tier5_store and self._tier5_store.has_capacity():
                self._tier5_store.write(block)   # RDMA write to remote node
                block.tier = 5
                return 5
            else:
                raise MemoryError(f"KV cache exhausted: block {block.block_id}")
        raise ValueError(f"Cannot evict from tier {block.tier} in P1")

    def fetch(self, block_id: str, tier: int) -> KVBlock:
        """Fetch block back to Tier 2 RAM for inference."""
        if tier == 3:
            return self._tier3_store.read(block_id)
        elif tier == 5:
            if not self._tier5_store:
                raise RuntimeError("RDMA not available — cannot fetch Tier 5")
            return self._tier5_store.read(block_id)
        raise ValueError(f"fetch() only handles Tier 3/5 in P1")
```

### 3.3 LocalSSDStore (Tier 3)

```python
# cache/tier3_local.py
import os, mmap
import mlx.core as mx
from .manager import KVBlock

class LocalSSDStore:
    """
    Tier 3: memory-mapped SSD store for KV blocks.
    Uses mmap for zero-copy reads back to Tier 2.
    Target: ~/.omlx/cache/<rank>/
    """

    def __init__(self, path: str, capacity_gb: float):
        self.path = path
        self.capacity_bytes = int(capacity_gb * 1e9)
        self._used_bytes = 0
        os.makedirs(path, exist_ok=True)

    def has_capacity(self) -> bool:
        return self._used_bytes < self.capacity_bytes

    def write(self, block: KVBlock) -> None:
        path = os.path.join(self.path, block.block_id)
        arr = block.data
        mx.eval(arr)
        # serialize MLX array to numpy → write to file
        import numpy as np
        np.save(path, np.array(arr))
        self._used_bytes += arr.nbytes
        block.data = None   # free RAM

    def read(self, block_id: str) -> KVBlock:
        import numpy as np
        path = os.path.join(self.path, block_id + ".npy")
        arr = mx.array(np.load(path, mmap_mode="r"))
        return KVBlock(block_id=block_id, layer_idx=-1, data=arr, tier=2)
```

### 3.4 RemoteSSDStore (Tier 5 — stubbed in P1)

```python
# cache/tier5_remote.py
import mlx.core as mx
from transport.base import BaseTransport
from .manager import KVBlock

class RemoteSSDStore:
    """
    Tier 5: remote SSD on peer node via RDMATransport.
    Block is serialized locally, sent over RDMA, written to peer SSD.
    Ownership: block stays on owning_rank's SSD, fetched on demand.

    DECISION: Stubbed in P1. Requires JACCL P2P send/recv API (not yet available).
    Full implementation deferred to P2.
    """

    def __init__(self, transport: BaseTransport, capacity_gb: float):
        self.transport = transport
        self.capacity_gb = capacity_gb
        self._registry: dict[str, int] = {}  # block_id → peer rank

    def has_capacity(self) -> bool:
        # TODO: query remote node capacity via all_reduce
        return True   # optimistic until capacity tracking implemented

    def write(self, block: KVBlock) -> None:
        raise NotImplementedError("Tier 5 write: JACCL P2P pending — deferred to P2")

    def read(self, block_id: str) -> KVBlock:
        raise NotImplementedError("Tier 5 read: JACCL P2P pending — deferred to P2")

    def _select_peer(self, block: KVBlock) -> int:
        """Round-robin across non-owning ranks."""
        return (block.owning_rank + 1) % 3
```

---

## 4. Integration with oMLX Serve

RDMATransport and KVCacheManager are wired together at server init time. The transport is passed into the cache manager as a dependency — not imported directly. This keeps Tier 3 (local SSD) operational even when RDMA is unavailable (e.g. during P0 failure fallback).

```python
# serve/init.py — startup wiring
from transport.rdma import RDMATransport
from transport.tcp import TCPTransport
from cache.manager import KVCacheManager

def init_cluster(args) -> KVCacheManager:
    # Attempt RDMA; fall back to TCP if JACCL init fails
    try:
        transport = RDMATransport()
        print(f"[oMLX] RDMA transport initialized — rank {transport._rank}")
    except RuntimeError as e:
        print(f"[oMLX] RDMA init failed ({e}), falling back to TCP")
        transport = TCPTransport()

    cache = KVCacheManager(
        transport=transport,
        tier3_path=args.paged_ssd_cache_dir,
        tier3_capacity_gb=args.tier3_capacity_gb,
        rank=transport._rank,
    )
    return cache
```

---

## 5. Known Constraints & P1 Blockers

### 5.1 JACCL P2P API Gap

`mx.distributed` exposes collective operations (`all_sum`, `all_gather`) but not point-to-point `send`/`recv` as of March 2026. Tier 5 write/read requires P2P.

> ⚠ **DECISION: Option A selected.** Tier 3 (local SSD) ships in P1. Tier 5 stubbed with `NotImplementedError`. Full Tier 5 implementation deferred to P2 pending JACCL P2P API.

### 5.2 mx.array Serialization

MLX arrays must be evaluated (`mx.eval`) before serialization to NumPy for SSD writes. Lazy evaluation means a Tier 3 write can trigger unexpected compute. `LocalSSDStore.write()` calls `mx.eval()` explicitly — confirm this does not block the inference loop under load.

### 5.3 3-Node Port Constraint

Mac mini M4 Pro has 3 TB5 ports. Full mesh across 3 nodes uses all 3 ports. No port is available for external TB5 peripherals (storage, display) while the cluster is running. Plan for this in deployment.

---

## 6. P1 File Structure

```
omlx/
├── transport/
│   ├── base.py          ← BaseTransport ABC + TransportStats  [NEW]
│   ├── rdma.py          ← RDMATransport via mx.distributed    [NEW]
│   └── tcp.py           ← TCPTransport + is_rdma property     [MODIFIED]
│
├── cache/
│   ├── manager.py       ← KVCacheManager + KVBlock + evict()  [MODIFIED]
│   ├── tier3_local.py   ← LocalSSDStore (mmap SSD)            [NEW]
│   └── tier5_remote.py  ← RemoteSSDStore (stub)               [NEW]
│
├── serve/
│   └── init.py          ← transport + cache wiring at startup  [MODIFIED]
│
└── tests/
    ├── test_transport.py        ← mock transport unit tests
    ├── test_tier3.py            ← local SSD write/read/evict
    └── test_cache_manager.py   ← eviction routing logic
```

---

## 7. Open Questions for P0 Spike

- Does `mx.distributed.init()` bind cleanly on TB5 RDMA without socket error 47?
- What is measured AllReduce latency across 3 nodes on TB5 vs TCP baseline?
- Does disabling Thunderbolt Bridge affect any existing oMLX single-node functionality?
- Is `mx.distributed` P2P (`send`/`recv`) on the JACCL roadmap — or is masked all_reduce the permanent path?
- What is Tier 3 SSD write throughput vs inference token latency — is SSD eviction on the critical path?

---

*Document prepared: March 2026 | Status: Design only — P0 gate pending | oMLX-Cluster P1*
