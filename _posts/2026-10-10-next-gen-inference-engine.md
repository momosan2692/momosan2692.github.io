---
layout: post
title: 下一代推論引擎的重點與晶片對應
subtitle: 不要只看tokens
cover-img: /assets/img/header/2026-04-18/QUANTUM.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-18/QUANTUM.png
published: true
pinned: true
mathjax: true
tags: [draft, 推論引擎]
---

# 下一代推論引擎的重點與晶片對應

日期：2026-10-09。本文整理三部分：雲端推論評估指標、下一代推論引擎的新重點、軟體功能對應的晶片功能。多數數字來自廠商或引擎團隊自己的發布，請當作最佳情境。

## 總結論

1. 不要只看 tok/s。雲端推論應以 **在 SLO 下的 goodput** 評估：在指定並行數與 context 長度下，達到 TTFT 與 ITL 目標的前提上，每晶片、每美元、每瓦能服務多少請求。
2. 引擎的重點正從「更快的 kernel」轉到 **有狀態、理解 agent 的服務**：KV cache 成為可管理、可路由、可分層的資源。
3. 硬體正收斂到與軟體相同的形狀：**分層記憶體**（HBM → CPU DRAM → 共享 context 儲存）與 **階段專用運算**（prefill 晶片 vs decode 晶片）。Dynamo 與 vLLM 的 connector 是黏合層。

## 1. 為什麼 tok/s 不夠

單一使用者的 decode 速度是 SRAM / wafer-scale 設計的最佳情境。雲端服務還要看下列因素：

| 因素 | 衡量的內容 | 偏向誰 |
| --- | --- | --- |
| Decode 速度（ITL） | 每位使用者的記憶體頻寬 | SRAM / wafer（Cerebras、Groq） |
| Prefill / TTFT | 受限於算力，隨 prompt 長度增加 | 高 FP8/FP4 張量算力的 GPU、prefill 專用矽（Rubin CPX） |
| 並行數 | 權重讀取可由整個 batch 分攝，GPU 每晶片吞吐隨 batch 上升，直到算力或 KV 成為限制 | HBM GPU |
| KV 容量 | 使用者數 × context 長度 × 每 token KV 大小 | HBM + 分層（DRAM/CXL/NVMe），SRAM 是弱點 |
| Cache 命中率 | 是否可以跳過 prefill | 擁有更大、更便宜 cache 層的一方 |

- **Agent 工作負載由 prefill 主導**。每一輪都重送長 system prompt、tool schema 與歷史，輸入常達數萬 token，輸出卻很短。TTFT 取決於 prompt 長度與 cache 命中率，而不是 decode 速度。
- **SRAM 容量限制並行數**。現有的高速數字來自較短的 prompt 與較少的使用者。長 context 、多 session 需要的 KV 空間，晶片上 SRAM 無法提供，因此要分散到很多晶片（每 token 成本上升），或限制 context 與模型目錄。這可能是 Cerebras 與 Groq 只列少數模型的原因。
- **GPU 的單使用者延遲輸給 SRAM 設計，但利用率贏**。低 batch 時 decode 受頻寬限制、算力被浪費；高 batch 時同一顆 GPU 每 token 效率高很多，因此改用「在 SLO 下的每 token 成本」衡量時差距會縮小。
- **這就是 disaggregation 的理由**：高算力的 prefill 晶片、高頻寬的 decode 晶片、再加上分層 KV 儲存，目標正是這個缺口。純 SRAM 設計只解決 decode 那一半。

### 比較時要求的資料

1. 在固定輸入長度（例如 8k 與 32k 以上）、並行數 N 下的 TTFT p50/p95，不是 batch 1。
2. 同負載下的 ITL p95。
3. 特定延遲 SLO 下的最大並行 session 數，以及這個點的 $/M tokens。
4. 熱 prefix cache 與冷 prefix cache 的行為。
5. 獨立執行的結果：Cerebras 的速度主張是廠商數字，且 Cerebras 不參加 MLPerf Inference。

我沒有看到 Cerebras 或 Groq 在長 context、高並行下 TTFT 的已驗證公開資料，因此上面的容量論述是架構推理，不是量測。

## 2. 下一代推論引擎的新重點

### 2.1 Agent-aware 排程與 cache 策略

- vLLM 2026 Q3 roadmap 的優先項目是生產級 agentic 工作負載：引擎可由 session / correlation ID 辨識多輪 agent 與 subagent，並支援 prefix prefetch、eviction 與選擇性 offload。
- 將 Mooncake 作為共享 KV pool，在真實 Codex trace 上報告吞吐量 3.8 倍、P50 TTFT 降低 46 倍（廠商自跑的 benchmark）。
- vLLM router roadmap 計畫：依 KV events 做精確的 KV-aware routing、program-aware 排程，以及 KV TTL 原型。TTL 的概念來自 Continuum 等研究。

### 2.2 引擎之上的 orchestration

- Dynamo 位於 vLLM、SGLang、TensorRT-LLM 之上，提供 disaggregated serving、routing、多層 KV caching 與叢集範圍的 KV 可見性，包含 offload 到 S3 / Azure blob 等儲存層。NIXL 負責在 prefill 與 decode GPU 之間搬移 KV。
- Disaggregation 正延伸到多模態：encode / prefill / decode 分離加上 embedding cache，在影像工作負載上 TTFT 快約 30%。
- 標準化仍未定：vLLM 有一份 RFC 提議 KV cache 互通的公開契約。

### 2.3 Hybrid / sparse attention 破壞 prefix caching

- Qwen3.5 以約 3:1 交替 Gated DeltaNet 線性層與 full attention；DeepSeek V4 使用壓縮 sparse attention，依 DeepSeek 估計，V4-Pro 在 1M token 時所需 cache 約為前代的十分之一。
- Prefix caching 變得更難：線性層只能在存了 checkpoint 的位置重用狀態，hybrid 模型得讓兩種 cache 對齊到同一位置。Tail-Replay、SuffixReplay、sparse prefix caching 等新研究正針對這個問題。
- 引擎需要「依層不同的 cache 型別」。vLLM 描述了可程式化的 KV cache，讓不同工作負載有不同的放置、保留與逐出策略；LMCache 則把線性 attention 狀態當作不透明頁面儲存。

### 2.4 KV 壓縮與長 context 並行

- vLLM 目標把 quantized KV cache 從「有這個功能」推到「可用於生產」。INT8 per-token 為基礎，NVFP4 KV 進行中。
- Decode Context Parallelism 依 sequence 把 KV 分散到多顆 GPU，廠商報告在長 context agentic 工作負載上比 tensor parallelism 高 3 倍吞吐。

### 2.5 CPU 與 runtime 開銷

GPU 推論變快之後，tokenization、JSON 處理與 streaming 成為瓶頸，因此 router 與 frontend 正在重寫成 fast path。這和 Vera 面向 agent 的 CPU 定位相呼應。

### 2.6 本地 / Apple Silicon

- 本地引擎正在複製伺服器的做法：vllm-metal 把 vLLM 的 scheduler、paged KV cache 與 prefix caching 帶到 Apple Silicon，並有 SSD cache 選項與 MTP。Ollama 已在 2026 年 3 月改用 MLX。
- 硬體限制：M5 的 neural accelerators 幫助受算力限制的 prefill，但不改變受頻寬限制的 decode 上限；M1–M4 的差距較小。對 M1 Pro 而言，持久的 prefix cache 與 SSD cache 比 kernel 的提升更重要。

## 3. 軟體功能 → 晶片／系統功能對應

左欄是軟體功能，右欄是對應的硬體。對應關係是我依廠商規格整理的，標為「推論」的列不是廠商聲明。

| 軟體功能 | 晶片／系統對應 |
| --- | --- |
| 多層 KV offload、共享 KV pool、KV-aware routing | NVIDIA BlueField-4 CMX 在 HBM 與儲存之間新增共享 context 記憶體層，2026 H2 推出。Vera Rubin 的 CPU-GPU 頻寬 1.8 TB/s，讓 KV 溢出到 DRAM。AMD 用 Infinity Fabric 提供 cache-coherent 的 CPU 存取 GPU 記憶體。 |
| Disaggregated prefill/decode、attention-FFN 分離 | Rubin CPX（128GB GDDR7）針對百萬 token context，2026 年底。Groq 3 LPX 負責 decode 的 FFN/MoE，Rubin GPU 負責 prefill 與 attention，Dynamo 負責路由與協調。LPX 已全面量產。 |
| Agent-aware 排程、CPU fast path | Vera CPU：88 核心、1.5 TB 記憶體，用於 orchestration、記憶體 offload 與 agentic 推論周邊的 CPU 工作。 |
| KV 壓縮與量化 | BlueField-4 STX 的 Vera CPU 對 context 資料壓縮吞吐最高 3.29 倍；GPU 的 NVFP4 支援（對應為推論）。 |
| 長 context 高並行（KV 容量） | MI455X：432GB HBM4、23.3 TB/s，對比 Rubin 288GB。Hugging Face 初步測試顯示並行請求數超過 192GB MI300 的 3 倍。 |
| Decode context parallelism、expert parallelism | Scale-up 網路：NVLink 6（NVL72）；MI455X 的 UALink 3.6 TB/s。（推論） |
| Hybrid attention 的 state cache | 未找到專用硬體；推論偏好大容量加快速溢出層。（推論） |
| Apple：prefix cache、M5 prefill | vllm-metal 在 M5 上用 NAX tensor kernel 做 prefill，decode 仍受記憶體頻寬限制。 |

### 對先前回答的更新

- 我曾不確定 NVIDIA 的 KV 分層產品細節；現已確認 BlueField-4 CMX，Groq 3 LPX 也已全面量產。
- Groq 交易的說法不一：較早的來源稱為技術授權（2025 年 12 月），另一來源稱為 200 億美元資產收購。
- Google TPU 8i（偏推論）仍列為 coming soon，因此未納入對應。

## 4. 注意事項

- 多數數字來自引擎團隊(如vLLM等)自己的部落格，獨立的 agentic benchmark 還很新。這裡的 3.8 倍 / 46 倍請當作最佳情境的 trace。
- LPX 的 3,400 tok/s 是單一指定長 context 工作負載的廠商回報數字。
- 上線時程分散：CMX 2026 H2、Rubin CPX 2026 年底、MI455X 推出中。
- 5 倍 KV 儲存加速等數字為廠商聲稱，待獨立結果確認。

## 相關檔案

試算表 software\_to\_chip\_mapping.xlsx 包含第 3 節的完整對應、各晶片規格與比值、來源連結。
