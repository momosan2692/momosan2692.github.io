---
layout: post
title: "推理晶片的下一場戰爭"
subtitle: "Jalapeño 最新進展、Broadcom $22B 解構、2027 前瞻掃描框架，與 GPU:CPU 比例反轉的結構性信號"
cover-img: /assets/img/header/2026-05-14/AI-NATIVE-WAN.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-14/AI-NATIVE-WAN.jpeg
published: true
pinned: false
tags: [draft, AI, 半導體, ASIC, 推理晶片, 垂直整合, OpenAI, Broadcom, Agentic]
---



> **本文是《OpenAI Jalapeño ASIC 深度分析》的延伸研究**，聚焦於四個在前篇發表後持續演化的維度：Project Nexus 的五月融資僵局、Broadcom $22B 季度財報的真實組成、面向 2027 年的頂層掃描框架，以及整個 AI 晶片產業最重要的新結構性信號——GPU:CPU 比例正在發生根本性反轉。

---

## 一、本文全部圖表索引

> 以下九張圖表完整覆蓋本系列研究。Fig 1–5 來自前篇，Fig 6–9 為本篇新製。所有 SVG 檔案請置於 `/assets/img/jalapeno/`。

| 圖號 | 檔案名稱 | 主題 |
|---|---|---|
| Fig 1 | `fig1-three-ip-models.svg` | 三種 ASIC IP 所有權模型比較 |
| Fig 2 | `fig2-google-tpu-timeline.svg` | Google TPU 十年垂直整合時間軸 |
| Fig 3 | `fig3-inference-landscape.svg` | 推理 ASIC 完整賽局版圖 2026 |
| Fig 4 | `fig4-self-vs-partner.svg` | 自研團隊 vs 戰略夥伴：六大論點 |
| Fig 5 | `fig5-convergence-law.svg` | 垂直整合收斂定律 |
| Fig 6 | `fig6-project-nexus-status-timeline.svg` | Project Nexus 五月 2026 狀態時間軸 |
| Fig 7 | `fig7-broadcom-22b-breakdown.svg` | Broadcom Q2 FY2026 $22B 收入解構 |
| Fig 8 | `fig8-ai-chip-2027-scanner.svg` | AI 晶片 2027 前瞻頂層掃描框架 |
| Fig 9 | `fig9-gpu-cpu-ratio-inversion.svg` | GPU:CPU 比例反轉——Agentic 時代信號 |

---

## 二、Project Nexus 五月實況：MSFT 路徑已關閉

![Project Nexus 五月 2026 狀態時間軸](/assets/img/header/2026-05-22/fig6-project-nexus-status-timeline.svg)

*Fig 6：從 MSFT–OpenAI 協議修訂（Apr 27）到 Nvidia Vera CPU 出貨（May 20）的三十天關鍵事件序列*

上篇分析中，我們指出 OpenAI–AVGO–MSFT 融資三角的核心障礙：Broadcom 要求 Microsoft 承諾購買約 40% 的 Jalapeño 晶片（約 $18B），作為 Project Nexus 第一期啟動前提。

五月的事件序列已將這條路徑正式關閉：

### Apr 27：MSFT–OpenAI 協議修訂，關係結構性鬆動

OpenAI 與 Microsoft 正式修訂合作協議：Microsoft 的授權由獨家轉為非獨家，OpenAI 可以在任何雲端平台服務其產品。Microsoft 停止向 OpenAI 支付收益分成；OpenAI 向 Microsoft 的支付總額上限為 $38B，期限至 2030 年，且不再與 AGI 技術里程碑掛鉤。

這個修訂是 Jalapeño 融資問題的根本性背景——它使 MSFT 對 OpenAI 的義務大幅收縮，要求 MSFT 承擔 $18B OpenAI 專屬硬體融資，與這個關係走向完全背道而馳。

### May 7：僵局公開，OpenAI 內部已表態反對

值得注意的不只是融資卡關本身，而是 OpenAI 自身的反應。據報導，OpenAI 計算基礎設施負責人 Sachin Katti 在內部表示，任何涉及 Microsoft 的結構都會讓這筆交易「在財務上缺乏吸引力」，並稱當前商業結構「可能無法實現」——OpenAI 在公開報導之前就已放棄 MSFT 路徑。Broadcom 股價當日下跌 4%。

### May 8：條件性路徑浮現

草案協議中加入新條款：若 Microsoft 拒絕承諾，OpenAI 可自行尋找替代買家。Broadcom 與 OpenAI 正朝「條件性協議」推進，使 Broadcom 能夠「有信心地分配」TSMC 製造產能。Broadcom 股價反彈 4%。

### May 13：收益分成上限釋放自籌可能性

OpenAI 向 Microsoft 的收益分成總額正式設定上限 $38B（至 2030 年），較原先預計的 ~$135B 節省約 **$97B**。這筆節省創造了一條窄的自籌資金路徑——儘管在 2026 年預計消耗 $14B 現金的背景下，仍然困難。

### May 20：Nvidia 反制動作

Nvidia 開始向包括 OpenAI 在內的早期客戶交付 Vera CPU 系統。**Jalapeño 每推遲一個月，Nvidia 在 OpenAI 基礎設施棧中的位置就加深一分。** 這是本輪事件序列最值得關注的結構性後果。

---

## 三、Broadcom $22B 解構：數字背後是什麼

![Broadcom Q2 FY2026 $22B 收入解構](/assets/img/header/2026-05-22/fig7-broadcom-22b-breakdown.svg)

*Fig 7：$22B 是 Broadcom 的全公司季度收入，不是晶片收入。Jalapeño 在其中貢獻 $0。*

前篇研究中，我們提到「Broadcom Q2 ~$22B 的業績假設 AI 晶片管線不變」——這個表述是不精確的，需要在此糾正。

### $22B 的真實組成

**引擎一：AI 半導體 $10.7B（49%）**

Q1 AI 收入為 $8.4B（YoY +106%），Q2 導引至 $10.7B，年化約 $43B。這由兩條產品線組成：

- **客製化 AI 加速器（XPU）**：為 Google TPU、Meta MTIA Artemis、ByteDance XPU 及三個未公開客戶提供 ASIC 設計服務。
- **AI 網路矽晶片**：Tomahawk 交換晶片、Jericho 路由晶片、StrataXGS——每一個 H100/H200 集群仍然需要 Broadcom 的乙太網路交換晶片。

**關鍵事實：Jalapeño 在 $10.7B 中貢獻 $0。** OpenAI 尚未成為 Broadcom 的付費晶片客戶。OpenAI 出現在 Broadcom 的前瞻展望中——Hock Tan 稱 Broadcom 對 2027 年 AI 半導體收入超過 **$100B** 有「明確的視線」——而不是當前的季度導引。

**引擎二：基礎設施軟體（VMware）$6.8B（31%）**

VMware 在 FY2025 全年貢獻 $27B 收入，毛利率超過 93%，ARR 年增 19%，Q1 FY2026 合約總價值簽約超過 $9.2B。這條線是 Broadcom 在 AI 晶片管線出現任何波動時的結構性緩衝。

**剩餘 ~$4.5B（20%）：非 AI 半導體**

傳統網路、儲存控制器、寬頻晶片（電纜數據機、DSL）、工業與企業半導體——隨著 AI 資本支出擠占預算而緩慢下滑。

### 正確的表述

> **$22B 的 Q2 導引不假設 OpenAI 管線成立。** Jalapeño 的進展只影響 Broadcom 的 2027 年 $100B AI 收入目標——這是前瞻性長期預測，而非當季財務數字。Broadcom 的 VMware 底座（~$27B/年，高毛利、高重複性）使其對任何單一晶片客戶的融資問題具有強大的結構性絕緣能力。

---

## 四、2027 前瞻掃描框架：從最大力量到最小信號

![AI 晶片 2027 前瞻頂層掃描框架](/assets/img/header/2026-05-22/fig8-ai-chip-2027-scanner.svg)

*Fig 8：六層頂層掃描框架——每層含「已確立（Ready）」與「即將改變（Change）」雙信號，以及 2027 年影響推論*

評估 2027 年推理與訓練晶片格局，需要一套有紀律的頂層掃描方法——從最大的結構性力量掃描到最小的晶片層面信號。以下是六層框架的核心摘要：

### 第①層：模型架構演化（最大力量）

**已確立**：密集型 Transformer 推理是已解決的工作負載。固定批次大小、可預測的 KV Cache、靜態記憶體存取模式——ASIC 的效率優勢清晰且可測量，Systolic Array 架構主導。

**即將改變**：Agentic / 推理型模型（o3 類、GPT-5+）使推理變得**迭代性**——動態批次大小、樹狀搜索解碼、長視野多步驟鏈路。推理在不可預測性上開始類似訓練。

**2027 影響**：針對靜態 Transformer 運算優化的固定功能推理 ASIC，在 Agentic 工作負載上將失去效率優勢。2027 年勝出的推理晶片需要的是**可程式化資料流**，而不只是吞吐量。

### 第②層：計算需求曲線

**已確立**：推理佔全部 AI 計算量的 70%（2026 年）。Token 量指數成長，數十億次每日查詢的需求曲線已鎖定 2–3 年超大規模資本支出。

**即將改變**：情境長度爆炸（1M+ Token 視窗）→ 記憶體頻寬牆，而非計算牆。Agentic 管線新增 CPU 密集型協調、工具呼叫、沙箱執行——異質計算組合，而非純 GPU。

**2027 影響**：記憶體頻寬（HBM4、HBM4E）成為制約因素，而非 FLOPS。情境記憶（CMX）平台作為基礎設施層浮現。

### 第③層：資本配置（已鎖定的 CapEx）

MSFT $190B、Meta $135B、Amazon $105B、Google $75B——全部列入 2026–2027 財報導引，不是預測。但混合比例正在轉移：Meta 的 $135B 主要投入 MTIA 而非 H100，Google 主要投入 TPU，AWS 以 Trainium 為主。Nvidia 在每家超大規模商業中的預算佔比正在下降。

Broadcom 的 2027 年 $100B AI 收入目標的可信度正是建立在這個轉移上——它是三家以上將預算從 Nvidia GPU 轉向自訂 ASIC 的超大規模商業的合作夥伴。

### 第④層：製程節點與記憶體路線圖

**已確立**：TSMC N3 是當前所有前沿 AI 晶片的生產節點（TPU v7、Maia 200、Trainium3、Blackwell）。HBM3E 為現行記憶體標準（1.2 TB/s、96GB/封裝）。

**即將改變**：TSMC N2（GAA 奈米片，2026 量產）和 A16（背面電源輸送，2027）即將到來。HBM4 進入量產（2TB/s）。CoWoS 封裝產能是制約 2027 年部署的關鍵瓶頸。

**2027 影響**：N2+HBM4 的先行者獲得 1.5–2× 記憶體頻寬優勢。TSMC CoWoS 封裝產能分配成為地緣政治與商業武器。

### 第⑤層：系統與互連架構

**即將改變**：推理集群與訓練集群在架構上正式分離——推理走向乙太網路原生、異質（CPU+GPU+LPU+記憶體），訓練維持 NVLink 同質化 Nvidia 架構。兩個截然不同的市場，兩個截然不同的贏家。

### 第⑥層：新進入者與晶片層級信號

**即將改變（最關鍵的結構性新進入者）**：**ARM 首次設計自有晶片**（AGI CPU）——從 ISA 授權商變成晶片競爭者。ARM AGI CPU 在發布時已有超過 **$20B 的承諾需求**，是原始預測的兩倍。ARM 正在從一個向每顆晶片收取授權金的公司，變成一個在授權金之上直接捕獲利潤的公司——ISA 層正在被重新貨幣化。

其他值得關注的新進入者：Etched（Transformer 固化 ASIC，聲稱 4× H100 效率）、Tenstorrent（Jim Keller 主導，RISC-V 架構）、d-Matrix（數字記憶體內計算）。

---

## 五、最重要的新信號：GPU:CPU 比例正在反轉

![GPU:CPU 比例反轉——Agentic 時代信號](/assets/img/header/2026-05-22/fig9-gpu-cpu-ratio-inversion.svg)

*Fig 9：從訓練時代的 8:1，到聊天機器人推理的 4:1，到 Agentic 推理的 1:1 乃至 CPU 佔多數的結構性反轉*

這是本篇研究中最重要的新信號，也是理解 2027 年 AI 晶片格局的核心視角。

### 三個時代的比例

**時代一：訓練集群——8 GPU : 1 CPU**

訓練是完全並行的工作負載：前向傳遞、反向傳播梯度計算、All-Reduce 通訊、權重更新。CPU 在訓練時代只是一個「資料搬運工」——負責壓縮資料並路由至 GPU。沒有任何順序決策工作，GPU 完全主導，CPU 幾乎是陪襯。

**時代二：聊天機器人推理——4 GPU : 1 CPU**

Prefill 是並行的（GPU 負責），Decode 是順序性的（一次生成一個 Token）。KV Cache 管理、分詞、對話路由讓 CPU 重新獲得一些存在感，但 GPU 仍然擁有全部推理計算。每個查詢是一次性的，計算模式相對穩定。

**時代三：Agentic 推理——1 GPU : 1 CPU，甚至 CPU 超越 GPU**

這是結構性的反轉。Agentic 工作負載的核心循環是：**計劃 → 工具呼叫 → 等待結果 → 重新計劃**。這個循環是順序性的、條件性的、上下文相關的——正是 CPU 最擅長的域。

具體來說，Agentic 推理的 CPU 工作包括：
- **協調與計劃**：決定下一步行動，管理多個子代理之間的工作流
- **工具呼叫**：調用外部 API、資料庫、搜尋引擎
- **程式碼執行**：在沙箱中編譯和執行代碼，並等待結果
- **政策檢查與驗證**：確認輸出是否安全、合規，是否需要回溯

GPU 在 Agentic 架構中只負責 LLM 前向傳遞本身——而這在整個 Agentic 循環中可能只佔 20–30% 的時間。

### 浮現中的三層 Agentic 推理棧

2026 年 4 月，SambaNova 與 Intel 聯合宣布的架構藍圖將這個概念具體化：

- **GPU 層**：負責 Prefill（並行注意力計算）
- **RDU / LPU 層**（SambaNova 可重配置資料流單元）：負責 Decode（順序性 Token 生成）
- **CPU 層**（Intel Xeon 6 / Nvidia Vera CPU）：負責協調、工具執行、沙箱、驗證——完整的行動層

這個三層分工意味著，未來的推理集群不是「更多 GPU」，而是**更多 CPU 搭配適量 GPU 和專用解碼硬體**。

### 市場規模的量化

ARM 的估算提供了最具體的量化：Agentic AI 資料中心每 GW 需要 **1.2 億顆 CPU 核心**——是傳統 AI 資料中心（每 GW 3,000 萬核心）的四倍。

UBS 分析：從 2025 年傳統 AI 訓練轉向 2026/2027 年 Agentic 推理場景，CPU 工作負載需求將增加至目前水準的 **3 到 8 倍**。

結果：伺服器 CPU 總目標市場（TAM）現在預計每年增長超過 **35%**，到 2030 年超過 **$1,200 億**（較原先 18% CAGR 預測大幅上修）。CPU 伺服器售價自 2026 年 3 月以來已上漲 20%。

### 為什麼這個信號對晶片投資有決定性意義

GPU:CPU 比例反轉是一個**架構性信號**，而非週期性信號。它意味著：

1. **Nvidia 並不是 Agentic 時代最大的受益者**——GPU 在 Agentic 循環中的比重下降，高度可程式化的 CPU 和異質計算架構才是核心。
2. **Intel、ARM、Qualcomm 的伺服器 CPU 業務進入結構性上升通道**——不是因為傳統工作負載，而是因為成為 AI 協調層。
3. **固定功能推理 ASIC（針對靜態批次 Transformer 優化）在 Agentic 時代的護城河變窄**——這直接影響對 Jalapeño 等純推理 ASIC 的長期評估。
4. **Agentic 推理是 2027 年唯一「無主導設計」的市場**——這是新進入者最後的窗口。

---

## 六、前後兩篇的整合視角

![三種 ASIC IP 所有權模型比較](/assets/img/header/2026-05-22/fig1-three-ip-models.svg)

*Fig 1（前篇）：IP 邊界分析——計算裸晶 vs PHY/SerDes vs 封裝層*

![自研團隊 vs 戰略夥伴：六大論點](/assets/img/header/2026-05-22/fig4-self-vs-partner.svg)

*Fig 4（前篇）：自研 vs 夥伴的決策框架，以及均衡解*

![Google TPU 垂直整合時間軸](/assets/img/header/2026-05-22/fig2-google-tpu-timeline.svg)

*Fig 2（前篇）：唯一完成的完整驗證——v1 到 v7 Ironwood 的十年弧線*

![推理 ASIC 完整賽局版圖 2026](/assets/img/header/2026-05-22/fig3-inference-landscape.svg)

*Fig 3（前篇）：超越三角關係的完整賽局版圖*

![垂直整合收斂定律](/assets/img/header/2026-05-22/fig5-convergence-law.svg)

*Fig 5（前篇）：凡擁有前沿模型的主體，最終都將擁有推理矽晶*

前篇確立的核心論點——**IP 邊界（Fig 1）、Google TPU 路徑（Fig 2）、完整賽局版圖（Fig 3）、均衡解（Fig 4）、收斂定律（Fig 5）**——在本篇的新信號下得到強化，但需要補充一個重要的修訂視角：

> **收斂定律的終點不只是「擁有推理矽晶」，而是「擁有能夠服務 Agentic 工作負載的推理矽晶」。** 靜態 Transformer 推理的最佳化 ASIC 是今天的正確答案，但 Agentic 計算的 GPU:CPU 比例反轉意味著，2027 年勝出的晶片架構需要重新定義「推理矽晶」的邊界——它不再是單一晶片，而是一個以 CPU 為協調中心的異質計算棧。

這個修訂不否定 Jalapeño 的戰略邏輯，但它意味著 Titan（訓練晶片）和 Jalapeño 的接班晶片，都需要在設計時將 Agentic 工作負載的 CPU-GPU 協調架構納入考量——而非繼續最佳化靜態批次前向傳遞吞吐量。

---

## 七、結語：三個月後再看這個框架

本篇研究是一個動態分析框架，而不是靜態結論。以下是三個月後最值得重新評估的關鍵節點：

**① Project Nexus 替代買家是否出現**（Oracle、主權基金，或 OpenAI 自籌）。每個月的延遲都在加深 Nvidia 在 OpenAI 基礎設施棧中的位置。

**② Broadcom 的 FY2026 Q3 AI 半導體收入**是否持續從 $10.7B 向 $100B 年化路徑推進，以及 OpenAI 是否正式確認為 XPU 客戶。

**③ ARM AGI CPU 的第一批出貨時間與性能數據**。ARM 從 ISA 授權商變成晶片競爭者，是整個推理晶片市場結構中最具爆炸性的新進入者——比任何新創公司都更危險，因為它的護城河已經存在於每顆晶片的設計中。

**④ Agentic 工作負載的 CPU:GPU 實際部署比例數據**。英特爾和 ARM 的預測（1:1 乃至 CPU 超越 GPU）目前仍是推斷，第一批 Agentic 生產集群的實際測量數據將是最重要的校準信號。

---

*研究資料截至 2026 年 5 月 21 日。所有財務數字引自公開報導，非投資建議。*

*本文 SVG 圖表為研究過程中製作，版權歸作者所有。圖表部署路徑：`/assets/img/jalapeno/fig[N]-[name].svg`。*
