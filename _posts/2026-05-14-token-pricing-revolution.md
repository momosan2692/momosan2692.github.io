---
layout: post
title: Token 計價革命：SRAM、HBM、Flash 決定了一切
subtitle: 每一個 Token 的誕生都有硬體成本——三層記憶體等級的成本結構，才是 AI 推論定價的物理基礎
cover-img: /assets/img/header/2026-05-14/TOKEN-PRICING.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-14/TOKEN-PRICING.jpeg
published: true
pinned: false
mathjax: true
tags: [draft, Token計價, SRAM, HBM, Flash, AI推論, 記憶體等級, Cerebras, Everpure, NvidiaGB200]
---

# Token 計價革命：SRAM、HBM、Flash 決定了一切

> 美國企業 AI 系列第四篇——記憶體等級 × Token 生成經濟學 · May 2026
> 涵蓋主題：SRAM/HBM/Flash 成本結構、記憶體等級與 Token 速度的對應、Token 定價的物理基礎、快速模式 vs 標準模式的硬體解釋、Memory Parkinson's Law

---
```
核心訊息

AI Token 的定價，不是模型公司任意決定的商業策略。
它是三層硬體記憶體等級的成本結構，被市場發現之後的必然結果。

SRAM、HBM、Flash——這三種元件在 Token 的生成過程中各司其職。
哪一層介入得越多，Token 的速度越快，成本越高。
哪一層被壓縮，Token 的速度下降，但成本降低。

Opus 4.6 快速模式以 6 倍定價提供 2.5 倍速度，
不是行銷溢價，是 SRAM 資源分配的硬體成本被定價進去了。
Token 計價革命，是記憶體等級的競爭，用市場語言說出來。
```
---

## 引言：為什麼 Token 不應該都是同一個價格

2026 年的 AI 推論市場，正在發生一件在軟體行業罕見的事：**同一個模型的輸出，開始以不同的價格出售。**

Anthropic 的 Opus 4.6 有快速模式（6× 定價）和標準模式。OpenAI 有 Priority、Standard 和 Batch 三種定價層。這不只是服務差異，是底層硬體成本的差異第一次被市場語言表達出來。

要理解這個定價結構的物理基礎，必須先理解一個 Token 是如何從記憶體中誕生的。

---

## 一、Token 生成的記憶體路徑

每一個 Token 的生成，都需要從記憶體中讀取 KV cache（Key-Value Cache）——這是 Transformer 模型在處理整個 context 時所累積的中間狀態。KV cache 存放在哪一層記憶體，直接決定了 Token 生成的速度和成本。

```
Token 生成的記憶體讀取路徑（由快到慢）：

┌─────────────────────────────────────────────┐
│  SRAM（晶片內部）                            │
│  速度：21 PB/s（Cerebras WSE-3）            │
│  延遲：< 1 ns                               │
│  容量：44 GB（整片 WSE-3）                  │
│  角色：Cerebras 架構的主工作區              │
│        KV cache 完全在 SRAM，千級 tps       │
├─────────────────────────────────────────────┤
│  HBM（封裝外掛）                            │
│  速度：3–5 TB/s（H200/GB200）              │
│  延遲：~100 ns                              │
│  容量：80–192 GB/GPU                        │
│  角色：主流 GPU 推論的工作記憶體            │
│        短中 context 的 KV cache 主戰場      │
├─────────────────────────────────────────────┤
│  Flash SSD（系統外掛）                      │
│  速度：~14 GB/s（Everpure FlashBlade）      │
│  延遲：~150 μs                              │
│  容量：PB 級（無上限）                      │
│  角色：KV cache 溢出後的接收層             │
│        長 context Agentic AI 的必經之路     │
└─────────────────────────────────────────────┘

Token 速度受制於最慢的介入層。
```

---

## 二、三層記憶體的成本結構

### 實際數字

HBM2e 的街頭價格約 110 美元/GB，DDR5 伺服器記憶體約 35–70 美元/GB。 2026 年，SK Hynix 向 NVIDIA 供應的 HBM3E 每疊（stack）約 350 美元；HBM4 將漲至約 500 美元中段，相比 HBM3E 前代幾乎翻倍。

```
記憶體等級成本對照（2026 Q2 估算）

元件        形式      成本/GB       帶寬         密度
──────────────────────────────────────────────────
SRAM        晶片內    ~$3,000+     21 PB/s      最低
            （推算：矽面積 × 5-6× 低於 DRAM）
HBM3E       封裝外掛  ~$110/GB     3.35 TB/s    中
HBM4        封裝外掛  ~$140/GB     3.3–6 TB/s   中高
DDR5 伺服器 DIMM      ~$50/GB      ~200 GB/s    高
NVMe SSD    外接      ~$0.1/GB     ~14 GB/s     最高
（Everpure DFM）      ~$1–2/GB

成本比：SRAM : HBM : DDR5 : NVMe ≈ 3000 : 110 : 50 : 0.1
容量比：SRAM : HBM : DDR5 : NVMe ≈  1  :  80 : 200 : ∞
```

SRAM 在每平方毫米可放置的容量是 DRAM 的 5-6 倍低——換言之，SRAM 需要 5-6 倍的矽面積來儲存同樣的資料量。HBM 透過垂直堆疊 12-16 個 DRAM 晶片進一步增加容量，結果 HBM 的有效容量是同等矽面積 SRAM 的 80 倍。

### Memory Parkinson's Law

就像 Parkinson's Law 觀察到「工作會擴展以填滿所分配的時間」，現代 AI 遵循著「記憶體 Parkinson 動態」——神經網路架構無情地增長，以佔用任何可用的 HBM。從 A100 的 80 GB HBM2E 到 Rubin Ultra 的 1,024 GB HBM4E，記憶體容量的爆炸性增長，每次都被更大的模型和更長的 context 立即吸收。

這是一個沒有終點的追逐：HBM 成長 → 模型填滿它 → 需要更大的 HBM。

![ParkinsonLaw](/assets/img/header/2026-05-14/ParkinsonLaw.png)


---

## 三、Token 的成本函數

把三層記憶體的成本結構和 Token 生成的路徑結合，可以寫出一個 Token 的硬體成本函數：

```
Cost_per_token(arch, C) =

  GPU_compute_cost (固定，與 context 弱相關)

  + SRAM_amortized × SRAM_utilization(arch)
    （Cerebras 架構：高；HBM 架構：接近零）

  + HBM_amortized × min(C × κ, H)
    （KV cache 在 HBM 容量內的部分）

  + Flash_IO_cost × max(0, C × κ - H)
    （KV cache 溢出 HBM 的部分，Everpure 的領域）

其中：
  C  = context window tokens
  κ  = KV bytes per token（架構決定：MLA/GQA/MHA）
  H  = 可用 HBM 容量（扣除模型權重後）
```

**三個場景的展開：**

```
場景一：Cerebras 快速模式（短 context，SRAM 機器）
  C = 8,000 tokens，κ = 任意，KV cache 在 SRAM
  Cost ≈ GPU_compute + SRAM_amortized（高）
  → 定價高，速度最快（千級 tps）
  → Opus 4.6 Fast Mode 的硬體基礎

場景二：標準 GPU 推論（中等 context，HBM 主導）
  C = 128K tokens，κ = 450 KB（GQA），KV = 57.6 GB
  Cost ≈ GPU_compute + HBM_amortized × 57.6 GB
  → 定價中等，速度中等（40–100 tps）
  → 多數當前 API 定價對應此場景

場景三：長 context Agentic 推論（Flash 介入）
  C = 300K tokens，κ = 450 KB，KV = 135 GB > HBM
  Cost ≈ GPU_compute + HBM_amortized × H
             + Flash_IO_cost × (135 - H) GB
  → 定價應最高，但目前市場尚未充分反映
  → 這是 Token 計價革命的核心尚未完成的部分
```

---

## 四、現有定價模式的硬體解釋

### 快速模式 vs 標準模式

SRAM 的超低延遲和低能耗，源於記憶體與處理器位於同一片矽上。任何其他現有記憶體技術都無法超越 SRAM 的存取速度——即使是 HBM 也不行。

Opus 4.6 快速模式以 6× 定價提供 2.5× 速度——這個比例不是市場策略的隨機選擇：

```
快速模式的硬體含義：
  分配更多 SRAM 資源給單一用戶 session
  或：在 SRAM 機器（Cerebras）上執行
  → SRAM 成本/GB 是 HBM 的 ~27 倍
  → 但分配方式不是線性的，有批次效應

6× 定價 ÷ 2.5× 速度 = 2.4× 的「速度溢價」
  這個溢價在 Anthropic 財務上的含義：
  Opus 4.6 快速模式是其最高利潤 SKU
  → SRAM 成本雖高，但市場願意付的溢價更高
```

### Batch 定價的硬體含義

批次定價（Batch Pricing）是反方向的操作：增加並發批次大小，讓多個用戶共享同一個 HBM 資源，降低每個 Token 的硬體成本分攤，換取延遲增加。

```
Batch Mode 的記憶體效率：
  並發用戶 N 共享 H GB HBM
  每用戶可用 HBM = H / N
  KV cache 被更高效地填充 → GPU 利用率上升
  每 Token 分攤成本下降 → 定價可以更低

這就是為什麼 Batch 定價通常比標準 API 便宜 50–80%
```

---

## 五、尚未被定價的部分：長 context 的 Flash 成本

目前 AI API 定價的最大結構性扭曲，是**長 context 的成本被嚴重低估**。

AI 推論逐漸從訓練轉向推論，越來越多地應用於終端用戶場景。記憶體延遲直接影響每個 Token 的生成速度。隨著 Agentic 用例的增加，工具呼叫引入文件和數據的高速率存取，KV cache 的需求從 NVMe 進一步推向更多的 DDR 和 HBM。

目前多數 API 的 context 定價是線性的：

```
目前常見定價：$X / million input tokens（與 context 長度線性）
實際硬體成本：在 HBM 溢出前線性，溢出後指數增加

這個定價扭曲的後果：
  短 context 用戶：補貼了長 context 用戶
  長 context Agentic：享受了低估的定價
  供應商：在 Agentic 採用規模化後，毛利將被壓縮

正確的定價應該是：
  Cost(C) = base_rate                    （C < HBM_threshold）
           = base_rate + flash_premium   （C > HBM_threshold）
  其中 flash_premium 在臨界點後非線性上升
```

這是 Token 計價革命尚未完成的部分——當 Agentic AI 把平均 context 推過 HBM 臨界點，現有的線性定價結構將面臨重新校準的壓力。

---

## 六、記憶體供應結構：定價的上游約束

Token 成本的另一個維度，是記憶體供應鏈的結構性約束：

AI 的記憶體消耗正在達到警戒水位。雲端核心推論工作負載——Google Gemini、AWS Bedrock、OpenAI ChatGPT——預計到 2026 年的即時記憶體需求約為 750 PB；加上冗餘和安全邊際，實際部署需求有效翻倍至約 1.5 EB。

1 GB 的 HBM 消耗 4 倍標準 DRAM 的晶圓產能，而 GDDR7 需要 1.7 倍。這個乘數效應意味著 AI 對製造產能的消耗，遠超過其實際出貨記憶體量的比例。SK Hynix 作為 NVIDIA 最大的 HBM 供應商，其先進封裝產線產能已被預訂至 2026 年底。

```
記憶體供應鏈的競爭效應：
  HBM 佔用晶圓產能的 4× 乘數
  → 每做一個 HBM GB，就少做 4 個普通 DRAM GB
  → DDR5 和消費級 NAND 供應因此被擠壓

  AI 記憶體超週期的受益者層級：
  第一層：SK Hynix（62% HBM 市占）
  第二層：Micron（HBM3E 快速追趕）
  第三層：Samsung（追趕 HBM 認證）

  Token 成本的上游：
  HBM4 單 stack 漲至 $500+
  → GPU 成本 BOM 上升
  → 推論成本上升
  → Token 定價不得不跟進
```

---

## 七、三個公司，三個記憶體賭注

把本系列前三篇放在同一個記憶體等級框架裡：

```
Cerebras（SRAM 賭注）
  把 KV cache 留在晶圓 SRAM 內
  → 消滅 HBM 和 Flash 的延遲
  → 代價：容量 44 GB，無法服務長 context
  → 適用：短 context，高互動性，開發者 flow state

Everpure（Flash 賭注）
  在 HBM 溢出後接住 KV cache
  → DirectFlash 繞過 FTL，最小化 Flash 延遲
  → 代價：延遲仍高於 HBM，需要低 jitter
  → 適用：長 context Agentic AI，PR > 1 後

NVIDIA GB200（HBM 賭注）
  最大化 HBM 容量和帶寬
  → 兼顧吞吐量和中等 context 容量
  → 代價：對極速互動和超長 context 都有上限
  → 適用：主流推論，覆蓋最廣的工作負載

三者的協同：
  SRAM 機器（Cerebras）處理快速互動層
  HBM 機器（GB200）處理主流推論層
  Flash 系統（Everpure）處理長 context 溢出層
  → 不是競爭，是同一個 Token 生成過程的三個物理位置
```

---

## 結語：記憶體等級即定價等級

Token 計價革命的本質，是一個物理現實被市場發現的過程。

SRAM、HBM、Flash 的成本比大約是 3,000 : 110 : 0.1——相差四個數量級。每一個 Token 的生成，都在這三層之間的某一個位置完成它的 KV cache 讀取。這個位置，由 context 長度、架構選擇（MLA/GQA）、和硬體配置共同決定。

現在的定價模式——快速模式 / 標準 / 批次——是市場開始把這個硬體現實翻譯成商業語言的第一批嘗試。但這個翻譯還不完整：長 context 的 Flash 成本尚未被充分定價，Agentic AI 的記憶體需求尚未在 API 收費中得到完整反映。

當 Agentic 工作流使平均 context 越過 HBM 臨界點，Token 定價將面臨結構性重寫。第一個正確定價這個轉變的模型提供商，將同時獲得最真實的毛利結構，和最難以被低價競爭者侵蝕的定價護城河。

> 記憶體等級即定價等級。
> 這個命題在 2026 年仍是觀察，到 2028 年將會是產業共識。

---

> 📌 **美國企業 AI 系列索引**
> 1. [Everpure——為 Flash 重新設計一切的工程師公司](/2026/05/12/everpure-flash-chasm.html)
> 2. NeoCloud 與 WAN Cloud：GPU 雲端市場的分層與競爭 *(即將發布)*
> 3. [Cerebras——把整片晶圓變成一顆晶片的工程師賭注](/2026/05/14/cerebras-wafer-scale.html)
> 4. **本篇：Token 計價革命——SRAM、HBM、Flash 決定了一切**
