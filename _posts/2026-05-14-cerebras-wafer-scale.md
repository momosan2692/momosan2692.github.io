---
layout: post
title: Cerebras：把整片晶圓變成一顆晶片的工程師賭注
subtitle: 從 SRAM 機器的邊緣到 OpenAI 750MW 計算合約——快速 Token 時代讓十年孤注一擲的架構決策終於找到市場
cover-img: /assets/img/header/2026-05-14/CEREBRAS.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-14/CEREBRAS.jpeg
published: true
pinned: false
tags: [draft, Cerebras, WSE, SRAM, 快速推論, OpenAI, 晶圓級芯片, NeoCloud, 美國企業AI]
---

# Cerebras：把整片晶圓變成一顆晶片的工程師賭注

> 美國企業 AI 系列第三篇——Cerebras × WSE-3 × 快速 Token 經濟學 · May 2026
> 涵蓋主題：WSE-3 晶圓架構、SRAM vs HBM 競爭軸線、吞吐量 vs 互動性前沿、OpenAI 750MW 計算合約、冷卻與散熱挑戰、SRAM 機器的市場時機

---
```
核心訊息

Cerebras 做了一件任何正常工程師都會說不可能的事：
把整片晶圓做成一顆晶片，解決了 Moore's Law 放緩後最根本的互連瓶頸。

這個賭注沉默了五年——在總吞吐量主導市場偏好的時代，速度不是議題。
直到開發者用錢投票說出他們真正想要的：快速 Token，而不是更聰明的 Token。

Cerebras 沒有改變，是市場追上了它。
而 OpenAI 用 750MW 的計算合約，把這個判斷寫進了歷史。
```
---

## 引言：一個遲來五年的時機

2021 年，SemiAnalysis 寫了 Cerebras 的深度報告。那時候，晶圓級引擎（WSE）是一個令人著迷但找不到主流市場的工程壯舉——它快，但誰需要那麼快？

2025 年 12 月，NVIDIA 以超過 200 億美元收購了 Groq——同樣是 SRAM 機器，同樣是為快速 Token 而生的架構。Jensen Huang 看到的，是「Claude Code 引爆點」之後開發者行為的根本性轉變。

**開發者不再只要更聰明的模型，他們要更快的 Token。**

這句話改變了整個 AI 加速器市場的評估框架，也讓 Cerebras 的 WSE 從「有趣但邊緣」變成「OpenAI 願意簽署 750MW 計算合約」的核心基礎設施。

---

## 一、快速 Token 的經濟學：為什麼速度突然變得值錢

### 開發者的錢包說話了

Opus 4.6 快速模式，以 6 倍標準版的價格，提供 2.5 倍的互動速度。

在 SemiAnalysis 的實測中，2026 年 4 月有 80% 的 AI 支出（峰值年化 1,000 萬美元）集中在 Opus 4.6 快速模式——即使 Opus 4.7 已經發布，工程師們拒絕升級，理由只有一個：4.7 沒有快速模式。

這是 AI 工具歷史上第一次，**開發者選擇了速度而不是智能，而且還願意為此付顯著的溢價。**

背後的邏輯不難理解：

```
AI 輔助工作流程中的瓶頸演進：

階段一：AI 太慢，等待 = 打斷工作流
  → 用戶主要體驗：等待
  → 速度的邊際價值：極高

階段二：AI 夠快（40 tps 以上），速度不再是瓶頸
  → 用戶主要體驗：閱讀和決策
  → 速度的邊際價值：遞減

Claude Code 引爆點確認：
  開發者在「流狀態」中，Token 生成速度
  直接決定了每小時能完成的工作量
  → 速度的邊際價值重新飆升
```

這個邏輯有一個明確的市場含義：在 AI 深度嵌入開發者工作流程之後，**互動性（每用戶每秒 Token 數）成為比吞吐量（每 GPU 每秒 Token 數）更重要的競爭維度。**

### 吞吐量 vs 互動性前沿

推論的根本取捨可以用一條前沿曲線描述：

```
高互動性（Fast Mode）
  ↑
  │     Cerebras WSE-3（千級 tps，超出 HBM 機器的物理極限）
  │   ↗
  │ ↗  NVIDIA GB300 NVL72
  │↗   H100
  └────────────────────→ 高吞吐量（批次處理）

移動這條曲線的兩個方法：
  1. 調整批次大小（并發用戶數）
     → 增加並發 = 向右（更高吞吐量，更低互動性）
     → 減少並發 = 向上（更高互動性，更低吞吐量）

  2. 更換底層硬體
     → SRAM 機器（Cerebras/Groq）= 整條曲線向右上移動
     → 實現 HBM 機器物理上不可能達到的互動性水準
```

GB300 NVL72 在低互動性（40 tps）下比 H100 有 20 倍的吞吐量優勢，在高互動性（120 tps）下有 100 倍的優勢——這已經非常驚人。但 Cerebras 提供的是千級 tps，**這個互動性水準根本不在 HBM 機器的可達範圍內。**

---

## 二、WSE-3：晶圓即晶片的工程邏輯

### 為什麼要做整片晶圓？

半導體製造有一個物理上的硬性限制：單次曝光的最大面積（Reticle Limit）約為 858mm²。所有傳統的 GPU、TPU、LPU 都活在這個限制之內，要擴展計算能力，必須靠多晶片互連——NVLink、Infinity Fabric、NVSwitch，本質上都是在解決「多個 858mm² 的晶片如何高效溝通」的問題。

Cerebras 選擇了一條截然不同的路：**讓整片晶圓成為一顆晶片。**

WSE-3 是一個 12×7 的陣列，84 個相同的 die 排列在整片晶圓上，形成一個完整的計算單元。關鍵創新是：資料在晶圓上流動，而不是在晶片之間傳輸。消除了晶片間互連的開銷——功耗、延遲、成本全部隨之消失。

### WSE-3 的核心規格

```
記憶體：44 GB SRAM（全部在晶圓上）
帶寬：  21 PB/s（SRAM 的本質優勢）
計算：  125 PFLOPs FP16（稀疏數字）
        = 15.6 PFLOPs FP16（密集數字）← 注意：8:1 稀疏假設

對比：
  典型大型處理器 SRAM：數百 MB
  Groq LPU（單卡）：500 MB SRAM
  WSE-3：44,000 MB SRAM = 88× Groq 單卡

弱點：
  對外網路帶寬：只有 150 GB/s
  = GPU/XPU 競爭者的零頭
  → 多 WSE 擴展的根本性障礙
```

### SRAM 機器的核心邏輯

Cerebras 和 Groq 屬於同一個架構類別：**SRAM 機器**——把大量矽面積分配給超快 SRAM，而不是 HBM。

```
SRAM 機器 vs HBM 機器的取捨：

         SRAM 機器          HBM 機器
帶寬     極高（21 PB/s）    高（3-5 TB/s）
容量     低（44 GB）        高（288 GB/卡）
延遲     極低               低
互動性   最高（千級 tps）   高（百級 tps）
吞吐量   受容量限制         最高
成本/bit SRAM 遠貴於 DRAM   HBM 效益更佳

KV Cache 放在哪裡？
  SRAM 機器：KV cache 在晶圓上的 SRAM
  HBM 機器：KV cache 在 HBM，溢出才到 SSD（Everpure 的機會）
```

這個對比揭示了一個有趣的結構：**Cerebras 和 Everpure 在 KV cache 問題上是對立的解法**——Cerebras 把 KV cache 放進 SRAM 消滅延遲，Everpure 在 KV cache 溢出 HBM 之後接住它。SRAM 機器的普及，在某種程度上是對 Everpure pivot 論點的一個對沖力量。

---

## 三、三個工程難題

### 難題一：良率（Yield）

一片完整晶圓出現缺陷幾乎是必然的——問題是如何讓有缺陷的晶圓仍然可用。

Cerebras 的解法分三層：
1. **冗餘設計**：WSE-3 有 970,000 個核心，只啟用 900,000 個，10% 作為備援
2. **動態路由**：能繞過缺陷核心繼續運算——這要求每個核心刻意設計得比 GPU 核心小，犧牲了計算密度換取良率靈活性
3. **每批次客製遮罩**：上層金屬層的接線方式每批晶圓都不同，專門為那批晶圓的缺陷分佈量身訂做。這是額外的光罩成本，但確保了近 100% 的晶圓可用率

這個良率工程是 WSE 最難複製的護城河之一——它不只是製程知識，是軟硬體協同設計的系統能力。

### 難題二：散熱（Thermal）

25 kW 的功耗集中在一片 46,225 mm² 的晶圓上，熱流密度約 50 W/cm²。這個數字超出了傳統氣冷和標準液冷方案的處理能力。

Cerebras 的 Oklahoma 資料中心用 5°C 的冷水（而非業界標準的 45°C 入水溫度），通過專屬「引擎塊」散熱系統維持晶圓溫度。代價是需要大型冷水機組——冷卻基礎設施的複雜度和成本，是 WSE 部署的隱性成本。

GB200 NVL72 的設計可以在 45°C 入水溫度下運作，讓資料中心大部分時間用自然冷卻（free cooling）；CSe-3 需要 21°C，必須全程開冷水機。**這個差異在規模部署時，是每年數百萬美元的電費和基礎設施成本差距。**

### 難題三：網路帶寬（Networking）

150 GB/s 的對外帶寬，是 WSE-3 最明顯的弱點。

這個數字意味著：
- 多個 WSE 之間的資料交換極其受限
- 超大規模模型（如 671B 參數）無法有效在 WSE 間做 tensor 並行
- Cerebras 接受了這個限制，把整個推論架構設計成「單晶圓能跑什麼模型就跑什麼模型」

這是一個和 Everpure 的 DirectFlash 邏輯相似的選擇——**把問題的邊界重新定義，而不是試圖用傳統架構解決傳統架構的限制。**

---

## 四、OpenAI 合約：市場對架構賭注的定價

750MW 的計算合約，是 Cerebras 從「有趣的架構實驗」切換到「主流 AI 基礎設施」的分水嶺。

這個合約意味著：

```
OpenAI 的戰略判斷：
  快速 Token 的需求足夠大，值得專門採購 SRAM 機器
  Cerebras 是唯一能在工業規模提供千級 tps 的供應商
  750MW 到 2028 = 從零到數量級增長的製造與部署挑戰

TSMC 的訊號：
  Cerebras 的晶圓訂單每季度顯著增長，以滿足 OpenAI 部署需求
  這是比任何財報數字都更直接的業務健康指標

對市場的啟示：
  快速推論（Fast Inference）已從差異化功能
  → 成為 frontier lab 的核心商業模式之一
  Opus 4.6 快速模式是 Anthropic 最高利潤的 SKU
  Cerebras 讓 OpenAI 有能力大規模提供類似的差異化
```

---

## 五、連接回更大的框架

### SRAM 機器 vs HBM 機器：不是競爭，是分工

放在我們整個 AI 基礎設施分析框架中，Cerebras 的位置很清晰：

```
SRAM 機器（Cerebras/Groq）：
  最佳場景：短 context，高互動性，開發者 flow state
  KV cache 完全在晶圓 SRAM 內
  PR_cerebras = KV_cache / SRAM_capacity << 1（通常）

HBM 機器（NVIDIA GB200/H100）：
  最佳場景：長 context，高並發，批次處理
  KV cache 在 HBM，溢出到 SSD
  PR_everpure = S × C × κ / N × H × α（趨近 1 時）

兩者之間沒有零和關係：
  快速互動任務 → SRAM 機器
  持久 Agentic session（長 context）→ HBM 機器 + Everpure
```

這也解釋了為什麼 OpenAI 同時和 Cerebras（SRAM）和主流 GPU 雲端（HBM）合作——不同的 workload 特性需要不同的架構。

### 和 Jensen 五層框架的對應

```
Layer 0  Energy     → Cerebras 的冷水機組是能源限制的具體體現
                      CS-3 的 5°C 入水 vs GB200 的 45°C 入水
                      = 每 MW 的設施成本差距

Layer 1  Silicon    → WSE-3：突破 Reticle Limit 的架構創新
                      良率工程是真正的技術護城河

Layer 2  Infrastructure → 150 GB/s 網路帶寬是部署規模的天花板

Layer 3  Models     → SRAM 容量（44 GB）決定了可跑的模型上限
                      MLA 在這裡是友軍：減少 KV cache 需求
                      → 讓更長的 context 可以留在 SRAM 而不溢出

Layer 4  Applications → 快速 Token = 開發者 flow state
                         = Opus 4.6 fast mode 的商業模式驗證
```

---

## 六、工程師文化的相似性：「接受難的那座山」

Cerebras 和 Everpure 有一個驚人的相似之處：都在一個「更容易的路」存在的情況下，選擇了最困難的技術路線。

Everpure 可以做混合陣列，它選擇了 DirectFlash。
Cerebras 可以做標準 GPU 設計，它選擇了整片晶圓。

兩個公司都在說同一件事：**如果你接受前代架構的假設，你只能在那些假設的限制內競爭。唯一的辦法是把問題的邊界重新定義。**

良率工程、散熱客製化、每批次遮罩——這些不是任何教科書告訴你的路徑。但它們是讓 WSE 從「不可能」變成「TSMC 每季度顯著增加晶圓訂單」的技術基礎。

Cerebras 的 IPO，不只是一家公司上市，而是一個「在市場追上你之前堅持十年」的工程賭注，終於被公開市場定價。

---

## 結語：SRAM Is Not Just the Beginning

Jensen Huang 反覆強調：吞吐量 vs 互動性是推論的根本取捨。

Cerebras 在這條曲線的最右端——千級 tps 的互動性，是 HBM 機器在物理上無法到達的地方。

這個位置在 2021 年是孤獨的。在 2025 年 Claude Code 引爆點之後，在 2026 年 Opus 4.6 快速模式貢獻 Anthropic 最高利潤 SKU 之後，這個位置變成了 OpenAI 願意用 750MW 計算合約背書的戰略制高點。

市場沒有改變 Cerebras。Cerebras 等待市場改變。

在 AI 基礎設施的競爭中，這種等待通常以失敗告終。Cerebras 是極少數等到了的例子——因為它的賭注不是建立在市場趨勢上，而是建立在物理定律上：**SRAM 永遠比 HBM 快，快速 Token 永遠比慢速 Token 更適合互動式工作流。**

這兩個命題從 2016 年就是真的，從現在到 2030 年也仍然是真的。

---

> 📌 **美國企業 AI 系列索引**
> 1. [Everpure——為 Flash 重新設計一切的工程師公司](/2026-05-12-everpure-flash-chasm)
> 2. NeoCloud 與 WAN Cloud：GPU 雲端市場的分層與競爭 *(即將發布)*
> 3. **本篇：Cerebras——把整片晶圓變成一顆晶片的工程師賭注**
