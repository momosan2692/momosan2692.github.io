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

日期：2026-10-09。第二版（2026-10-10）新增第 5–7 節：token 計費缺口、token 之後的服務、不確定性總表。第一版三部分為：雲端推論評估指標、下一代推論引擎的新重點、軟體功能對應的晶片功能。多數數字來自廠商或引擎團隊自己的發布，請當作最佳情境。

## 總結論

1. 不要只看 tok/s。雲端推論應以 **在 SLO 下的 goodput** 評估：在指定並行數與 context 長度下，達到 TTFT 與 ITL 目標的前提上，每晶片、每美元、每瓦能服務多少請求。
2. 引擎的重點正從「更快的 kernel」轉到 **有狀態、理解 agent 的服務**：KV cache 成為可管理、可路由、可分層的資源。
3. 硬體正收斂到與軟體相同的形狀：**分層記憶體**（HBM → CPU DRAM → 共享 context 儲存）與 **階段專用運算**（prefill 晶片 vs decode 晶片）。Dynamo 與 vLLM 的 connector 是黏合層。

## 1. 為什麼 tok/s 不夠

單一使用者的 decode 速度是 SRAM / wafer-scale 設計的最佳情境。雲端服務還要看下列因素：

| 因素 | 衡量的內容 | 偏向誰 |
|---|---|---|
| Decode 速度（ITL） | 每位使用者的記憶體頻寬 | SRAM / wafer（Cerebras、Groq） |
| Prefill / TTFT | 受限於算力，隨 prompt 長度增加 | 高 FP8/FP4 張量算力的 GPU、prefill 專用矽（Rubin CPX） |
| 並行數 | 權重讀取可由整個 batch 分攤，GPU 每晶片吞吐隨 batch 上升，直到算力或 KV 成為限制 | HBM GPU |
| KV 容量 | 使用者數 × context 長度 × 每 token KV 大小 | HBM + 分層（DRAM/CXL/NVMe），SRAM 是弱點 |
| Cache 命中率 | 是否可以跳過 prefill | 擁有更大、更便宜 cache 層的一方 |

- **Agent 工作負載由 prefill 主導**。每一輪都重送長 system prompt、tool schema 與歷史，輸入常達數萬 token，輸出卻很短。TTFT 取決於 prompt 長度與 cache 命中率，而不是 decode 速度。
- **SRAM 容量限制並行數**。現有的高速數字來自較短的 prompt 與較少的使用者。長 context、多 session 需要的 KV 空間，晶片上 SRAM 無法提供，因此要分散到很多晶片（每 token 成本上升），或限制 context 與模型目錄。這可能是 Cerebras 與 Groq 只列少數模型的原因。
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
|---|---|
| 多層 KV offload、共享 KV pool、KV-aware routing | NVIDIA BlueField-4 CMX 在 HBM 與儲存之間新增共享 context 記憶體層，2026 H2 推出。Vera Rubin 的 CPU-GPU 頻寬 1.8 TB/s，讓 KV 溢出到 DRAM。AMD 用 Infinity Fabric 提供 cache-coherent 的 CPU 存取 GPU 記憶體。 |
| Disaggregated prefill/decode、attention-FFN 分離 | Rubin CPX（128GB GDDR7）針對百萬 token context，2026 年底。Groq 3 LPX 負責 decode 的 FFN/MoE，Rubin GPU 負責 prefill 與 attention，Dynamo 負責路由與協調。LPX 已全面量產。 |
| Agent-aware 排程、CPU fast path | Vera CPU：88 核心、1.5 TB 記憶體，用於 orchestration、記憶體 offload 與 agentic 推論周邊的 CPU 工作。 |
| KV 壓縮與量化 | BlueField-4 STX 的 Vera CPU 對 context 資料壓縮吞吐最高 3.29 倍；GPU 的 NVFP4 支援（對應為推論）。 |
| 長 context 高並行（KV 容量） | MI455X：432GB HBM4、23.3 TB/s，對比 Rubin 288GB。Hugging Face 初步測試顯示並行請求數超過 192GB MI300 的 3 倍（原稿未附測試來源）。 |
| Decode context parallelism、expert parallelism | Scale-up 網路：NVLink 6（NVL72）；MI455X 的 UALoE scale-up 雙向頻寬為 3.6 TB/s，UALink scale-out 雙向頻寬為 600 GB/s。（推論；[AMD 規格](https://www.amd.com/en/products/accelerators/instinct/mi400/mi455x.html)） |
| Hybrid attention 的 state cache | 未找到專用硬體；推論偏好大容量加快速溢出層。（推論） |
| Apple：prefix cache、M5 prefill | vllm-metal 在 M5 上用 NAX tensor kernel 做 prefill，decode 仍受記憶體頻寬限制。 |

### 對先前回答的更新

- 我曾不確定 NVIDIA 的 KV 分層產品細節；現已確認 BlueField-4 CMX，Groq 3 LPX 也已全面量產。
- Groq 交易的說法不一：較早的來源稱為技術授權（2025 年 12 月），另一來源稱為 200 億美元資產收購。
- Google TPU 8i（偏推論）仍列為 coming soon，因此未納入對應。

## 4. 注意事項

- 多數數字來自引擎團隊自己的部落格，獨立的 agentic benchmark 還很新。這裡的 3.8 倍 / 46 倍請當作最佳情境的 trace。
- LPX 的 3,400 tok/s 是單一指定長 context 工作負載的廠商回報數字。
- 上線時程分散：CMX 2026 H2、Rubin CPX 2026 年底、MI455X 推出中。
- 5 倍 KV 儲存加速等數字為廠商聲稱，待獨立結果確認。

## 相關檔案

原稿提及的試算表 software_to_chip_mapping.xlsx 不在目前 repository 中；第 3 節的部分數字與對應因此尚無法由該試算表追溯，請勿把它視為隨文提供的來源。

## 5. Token 計費與會計規則的缺口

在計費計數、引擎指標、goodput 三層，都沒有共同的「工作單位」，所以跨供應商與跨引擎的比較容易失真。

- **計費計數**：OpenTelemetry 曾在 v1.40 加入 cache token 屬性、v1.41 加入 reasoning token 屬性；2026-06 的 v1.42 將 GenAI conventions 移至[獨立 repository](https://github.com/open-telemetry/semantic-conventions-genai)，並在原 repository 將舊定義標為 deprecated。新 repository 中 cache 與 reasoning 欄位仍標示為 Development；這些是遙測語意，不是計費規則或穩定的計費標準。供應商定義仍不同：Anthropic 的 `input_tokens` 不含快取與 cache creation，OpenAI 的 `prompt_tokens` 為總數、快取是其子集。閘道工具曾因此發生重複計費。OpenAI GPT-5.6 以後另列 cache write 計數。依 OTel，reasoning tokens 應計入 output。([v1.42 變更](https://github.com/open-telemetry/semantic-conventions/releases/tag/v1.42.0)、[GenAI 欄位定義](https://github.com/open-telemetry/semantic-conventions-genai/blob/main/docs/gen-ai/gen-ai-events.md))
- **引擎指標**：TTFT 大致一致，但 TPOT 與 ITL 的公式不同。vLLM 的 TPOT 是每請求記錄，公式為 `(E2E latency - TTFT) / (output tokens - 1)`；ITL 則是一筆一筆記錄串流輸出事件之間的時間差，若一次輸出包含多個 token（例如 speculative decoding），就不等同嚴格的逐 token 加權平均。GenAI-Perf、LLMPerf 與 guidellm 的計算方式也需逐一核對工具文件，不能只比較同名指標。([vLLM 指標定義](https://docs.vllm.ai/en/stable/design/metrics))
- **Goodput**：一種定義是達標請求的比例，另一種是單位時間內的達標請求數（被拒絕的請求計為未達標）。同一次測試會得到不同數字。
- **關鍵缺口**：token 價格把 TTFT、排隊、cache 命中率與引擎效率全壓進同一個價格。把 GPU 時間換算成計費 token 的方式沒有公開標準，我也沒有找到任何供應商公開其內部換算。

### 正規化做法

1. 把每家供應商的用量拆成四桶：未快取 input、cache read、cache write（含 TTL）、output（含 reasoning），再逐桶比較。
2. 基準測試時寫明公式：TPOT 是否每請求等權、TTFT 與 ITL 用哪個百分位、SLO 門檻、goodput 是比例還是速率。
3. 固定 workload、cache 命中率與並行數。

## 6. Token 之後的下一代服務

Token 在請求無狀態時是合理的代理單位。Agent session 有狀態且長時間存活，成本不再與 token 成正比，供應商因此在 token 之外加新的計價軸。

| token 未涵蓋的資源 | 目前已在販售的形式 |
|---|---|
| 延遲 / SLO | Fast mode（2026-07-30 由 Priority 改名）為標準價 2 倍，Batch 與 Flex 為 50%。GPT-5.6 Sol 的 output 價格為 Fast $40、Standard $20、Flex/Batch $10（每百萬 token），同一模型價差 4 倍；此處為短 context 價格，長 context 價格不同。([OpenAI API 定價](https://developers.openai.com/api/docs/pricing)) |
| Cache 駐留（記憶體 × 時間） | Cache write 為 input 的 1.25 倍（5 分鐘）或 2 倍（1 小時）。Google 對 Gemini 3.7 Flash 的快取收每百萬 token 每小時 $0.50 儲存費（截至 2026-12-31；2027-01-01 起為 $1.00）。([Gemini API 定價](https://ai.google.dev/gemini-api/docs/pricing)) |
| 長 context（KV 大小） | GPT-6 Astra 超過 272K input 時，整個請求的 input 與 cache 費率為 2 倍、output 為 1.5 倍。([OpenAI API 定價](https://developers.openai.com/api/docs/pricing)) |
| Agent 執行時間（等待、工具呼叫） | 有第三方詞條指出 Anthropic 在 token 之外加收每 session 小時 $0.08；我沒有在 Anthropic 官方頁面查證這個數字。 |
| 商業結果 | 應用層：Intercom Fin 每筆解決的對話 $0.99，Zendesk 每筆自動解決 $1.50–$2.00。 |

### 預期走向（我的推論）

- **基礎設施層**：token 價格 × 延遲層級，加上駐留項（GB-小時或 cache TTL），再加上 session 時間。目前的 cache 儲存費與 session 小時費已朝這個方向。
- **應用層**：按任務或按結果計價，由廠商承擔 token 變動。這不是通則：Salesforce Agentforce 結合 Flex Credits、按對話計價與按使用者授權，屬混合型。
- **標準化**：每家供應商各自定義新單位，除非 OTel 這類標準延伸到駐留與執行時間，否則第 5 節的正規化問題會重演。我沒有找到這方面的提案。

## 7. 不確定性總表

以下彙整本次整理中所有未驗證、僅為推論或來源性質有限的項目。

| 類別 | 項目 | 不確定之處 | 建議驗證方式 |
|---|---|---|---|
| 速度數字 | Cerebras、Groq 的 tok/s | 廠商自述；Cerebras 不參加 MLPerf Inference | 等獨立基準或自行在固定 workload 測試 |
| 速度數字 | LPX 的 3,400 tok/s | 單一指定長 context 工作負載（Gemma 4 31B、100K context）的廠商回報 | 以自己的模型與 context 長度重測 |
| 容量論述 | SRAM 設計在長 context、高並行下的限制 | 屬架構推論；我沒有看到 Cerebras 或 Groq 在此條件下 TTFT 的已驗證公開資料 | 要求廠商提供固定輸入長度、並行 N 下的 TTFT p95 |
| 引擎效益 | Mooncake 的 3.8 倍吞吐、46 倍 TTFT；DCP 的 3 倍 | 來自引擎團隊自己的 trace 與部落格 | 獨立 agentic benchmark（目前仍新） |
| 硬體效益 | DOCA Memos 的 5 倍 KV 儲存加速 | 廠商聲稱 | 等獨立結果 |
| 時程 | CMX（2026 H2）、Rubin CPX（2026 年底）、MI455X（推出中）、TPU 8i（coming soon） | 上線時程分散，實際供貨可能變動 | 查廠商最新公告 |
| 交易事實 | NVIDIA 與 Groq 的交易 | 來源說法不一：技術授權（2025-12）與 200 億美元資產收購 | 查 NVIDIA 官方文件或 SEC 文件 |
| 對應關係 | 軟體功能 → 晶片功能中標為「推論」的列 | NVFP4 對應 KV 量化、decode context parallelism 對應 scale-up 頻寬、hybrid attention state cache 無專用硬體，皆為我的判斷，非廠商聲明 | 看是否有廠商明確針對這些需求的規格 |
| 涵蓋範圍 | AMD、Google TPU、Trainium 的推論速度與成本 | 未查證；TPU 8i 頻寬來源未列出 | 另行搜尋 |
| 計算方法 | 全記憶體掃描時間（容量 ÷ 頻寬） | 只是量級比較，不含 KV、並行、排程影響 | 以實測 decode 速度取代 |
| 來源性質 | Rubin CPX、LPX、Vera Rubin 的規格 | 多數來自第三方整理頁，不是 NVIDIA 官方文件 | 對照 NVIDIA 官方產品頁 |
| 計費 | 每 session 小時 $0.08 | 來自第三方詞條，未在 Anthropic 官方頁查證 | 查 Anthropic 官方價格頁 |
| 計費 | 各家價格與倍率 | 價格頁常更動，部分為促銷價 | 使用前重新確認 |
| 計費 | GPU 時間與計費 token 的換算 | 沒有公開標準，也沒找到供應商公開內部換算 | 無；需供應商揭露 |
| 標準 | OTel 與各供應商的 input token 語意 | OTel 建議 input 含快取，但 Anthropic 原生欄位不含，各工具實作不一 | 逐桶正規化後再比較 |
| 標準 | Goodput 定義 | 比例與速率兩種並存；文中 SLO 門檻只是舉例 | 比較前先寫明定義與門檻 |
| 走向預期 | 第 6 節的「預期走向」 | 屬我的推論，沒有供應商公開的路線圖 | 追蹤價格頁與 OTel 提案 |
| 時間 | 我的知識截止約 2026-06 | 之後的事件靠搜尋，結果可能不完整 | 重大決策前再查最新資料 |