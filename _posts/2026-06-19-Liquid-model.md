---
layout: post
title: "Liquid AI 技術報告：液態基礎模型（LFM）架構、數學機制與產業限制全解析"
subtitle: "美國企業 AI 系列｜Liquid AI 技術深度報告（含完整參考文獻）"
date: 2026-06-19
tags: [AI, LiquidAI, LFM, LFM2, LTC, ODE, 液態神經網路, Transformer, 邊緣AI, 技術報告]
cover-img: /assets/img/charts/liquid_ai_report_cover.svg
thumbnail-img: /assets/img/charts/liquid_ai_report_thumb.svg
published: true
pinned: true
---

> 「我一直在問自己：我們能不能從一種生物身上得到啟發，創造一種全新的 AI 解決方案？」
> —— Daniela Rus，MIT CSAIL 前院長，Liquid AI 共同創辦人

---

## 摘要

本報告完整解析 Liquid AI 公司及其 Liquid Foundation Models（LFM）系列產品，內容涵蓋：公司起源與創辦團隊、液態時間常數網路（LTC）的 ODE 數學基礎、Transformer 架構的兩道根本限制（O(N²) 計算複雜度與 KV Cache 記憶體瓶頸）、LFM/LFM2/LFM2.5 的架構演進與實測效能、「極限環（Limit Cycle）」問題的動力學機制、LFM 的真實限制（知識容量、代碼生成、生態系成熟度）、低延遲場景的適用邊界，以及商業布局與產業競爭分析。報告採用技術中立立場，呈現官方公布數據與第三方獨立評測的對照，並在文末附完整參考文獻與原始 URL。

---

## 目錄

1. 公司起源與創辦團隊
2. 融資歷程與商業模式
3. Transformer 的兩道枷鎖：O(N²) 與 KV Cache
4. 液態神經網路的數學機制：LTC ODE 方程解析
5. 從 LNN 到 LFM：架構工程化的過程
6. LFM2 架構解剖：ShortConv、GQA 與混合設計
7. LFM2.5 系列：效能與規格全覽
8. 極限環問題：動力學陷阱的完整剖析
9. LFM 的真實限制：知識容量、代碼生成、生態系
10. 低延遲場景：LFM 的真正主戰場與邊界條件
11. 產業部署案例：金融、自駕、醫療、工業 IoT
12. 商業生態與護城河分析
13. 結語
14. 參考文獻（含 URL）

---

## 第一章：公司起源與創辦團隊

### 1.1 從 MIT CSAIL 的 Spin-off

Liquid AI 於 2023 年從麻省理工學院電腦科學與人工智慧實驗室（MIT CSAIL）正式衍生（Spin-off）成立，總部設於麻薩諸塞州劍橋市。公司網站明確說明其核心定位：開發**液態基礎模型（Liquid Foundation Models, LFMs）**，目標是建構在任何規模下都具備高能力、高效率的通用 AI 系統 [1]。

根據商業資料庫 Tracxn 的公開記錄，Liquid AI 的創辦人為 **Daniela Rus、Ramin Hasani 與 Alexander Amini**，其中 Ramin Hasani 擔任執行長（CEO）[2]。另一份產業報導也確認，Liquid AI 的核心技術源自共同創辦人兼首席科學家 Ramin Hasani 在 MIT CSAIL 的研究工作 [3]。

### 1.2 液態神經網路的學術起源

液態神經網路的數學基礎，最早見於 2020 年發表的論文《Liquid Time-constant Networks》，作者為 Ramin Hasani、Mathias Lechner、Alexander Amini、Daniela Rus 與 Radu Grosu [4][5]。論文摘要指出，這項研究引入了一類新的時間連續遞迴神經網路模型：不是用隱式非線性來宣告學習系統的動態，而是構建由非線性互聯閘門調節的線性一階動態系統網路，這些模型代表了時間常數隨輸入變化（即「液態」）、並耦合至隱藏狀態的動態系統，輸出則透過數值微分方程求解器計算 [5]。

這篇論文也證明了 LTC 網路具有穩定且有界的行為（stable and bounded behavior），在神經常微分方程（Neural ODE）家族中具有更優越的表達能力 [5]。

更早的奠基性研究可追溯至 2018 年的論文《Liquid Time-constant Recurrent Neural Networks as Universal Approximators》，該論文已提出 LTC 循環神經網路的概念，並指出其神經元時間常數的變化機制，靈感來自小型生物物種神經系統中的通訊原理，使模型能用少量計算單元逼近連續映射 [6]。

### 1.3 後續理論發展：閉式連續時間神經模型

2021–2022 年間，研究團隊進一步發表《Closed-form Continuous-time Neural Models》，試圖解決 ODE 數值求解器對連續時間模型表達能力的瓶頸限制，並指出這類模型源自液態網路，在時間序列建模上展現出優於先進循環模型的效能 [7][8]。這篇論文後續發表於《Nature Machine Intelligence》[8]。

### 1.4 首次產品發布：2024 年 MIT 活動

根據 Business Wire 的新聞稿，Liquid AI 於 2024 年 10 月 23 日在 MIT Kresge Auditorium 舉辦的專屬活動上，首次對外發布基於 LFM 的產品，活動展示了金融服務、生物科技、消費電子等領域的 AI 應用 [9]。當時的執行長 Ramin Hasani 表示，公司的 LFM 系列在各種規模下都達到最先進效能，同時維持較小的裝置端記憶體佔用，能讓企業客戶在不依賴龐大雲端基礎設施的情況下使用即時、本地化的 AI 應用 [9]。

---

## 第二章：融資歷程與商業模式

### 2.1 種子輪：2023 年

公開的商業資料庫顯示，Liquid AI 自 2023 年 12 月 6 日起進行第一輪募資 [10]。

### 2.2 A 輪：AMD 領投，估值突破 20 億美元

2024 年 12 月，Liquid AI 完成由 AMD Ventures 領投的 2.5 億美元 A 輪融資。多家獨立媒體報導確認了這筆交易的細節：

根據 Tech Funding News 報導，這輪融資由晶片製造商 AMD 領投，AMD 同時也是 Liquid AI 的策略夥伴，此輪將公司估值推升至超過 20 億美元，目的是強化 LFM 系列的開發——這是針對企業用途設計的輕量化通用 AI 模型。

The Information 的報導則指出，根據彭博社報導，此輪估值為 23 億美元，低於 Liquid 高層先前向投資人表示尋求的 30 億美元募資、37 億美元估值的目標。

AI Business Weekly 的報導補充了更多細節：Liquid AI 在 12 月 20 日完成 2.5 億美元 A 輪募資，估值達 23.5 億美元，由 AMD Ventures 領投，現有投資人 Automattic 和 OSS Capital 也參與其中。報導也指出 Liquid AI 的核心技術源自共同創辦人兼首席科學家 Ramin Hasani 在 MIT CSAIL 的研究，使用液態神經網路——一種與驅動 ChatGPT、Claude 等主流 AI 系統的 Transformer 模型不同的替代架構。

商業資料庫 Tracxn 統計，Liquid AI 累計募資總額達 2.97 億美元，分兩輪完成，投資人包括 AMD、OSS Capital 與 PagsGroup，目前估值為 20 億美元。

### 2.3 AMD 戰略合作的產業意涵

AI Business Weekly 的分析指出了這筆投資的戰略邏輯：與 OpenAI、Anthropic、Google 追求面向消費應用的通用模型不同，Liquid AI 強調針對特定企業垂直領域優化的專業模型，這種定位避開了與資金雄厚的既有業者正面競爭，轉而瞄準服務不足的市場區隔。

關於 AMD 的動機，報導進一步分析：傳統 Transformer 模型需要昂貴、具備高記憶體頻寬的 NVIDIA GPU，形成限制部署選項的硬體依賴。液態神經網路較低的運算需求，使其能在 AMD 處理器與 GPU 上高效運行，有潛力衝擊 NVIDIA 在 AI 推理工作負載上的主導地位。這項合作包含技術協作，針對 AMD 硬體優化 Liquid AI 模型，並共同推動針對企業客戶的市場開拓計畫。

Pulse2 的報導引用了 AMD 企業發展部高級副總裁兼策略長 Mathew Hein 的說法：「我們很高興與 Liquid AI 合作，在 AMD Instinct GPU 上訓練和部署他們的 AI 模型，並透過這輪最新融資支持他們的成長」。報導也說明了資金用途：這輪融資將協助公司加速 LFM 的開發、擴展與部署，公司計畫將 AI 產品整合進消費電子、電信、金融服務、電子商務與生物科技等多個關鍵業務領域的工作流程，同時加速科學與技術開發，將 LFM 的優勢擴展到更多模型規模和數據模態。

### 2.4 商業模式：B2B 與企業定位

Liquid AI 官方部落格的產品說明強調，LFM2 是被設計為能在任何 CPU、NPU 或 GPU 上運行的混合模型家族，具備業界頂尖的速度、多語言支援與多模態能力，適用於各種規模的真實世界部署場景 [11]。

公司在 2024 年的新聞稿中提到一個關鍵的商業策略：公司正與大量財富 500 強企業在金融服務、生物科技、消費電子等領域合作，提供具備安全企業級部署堆疊的超高效小型多模態基礎模型，將每一台設備轉變為本地 AI 裝置，這讓 Liquid AI 在企業從雲端 LLM 轉向具成本效益、快速、私密的本地部署智能的過程中，有機會獲取超額的市場份額。

---

## 第三章：Transformer 的兩道枷鎖：O(N²) 與 KV Cache

理解 Liquid AI 為何選擇放棄 Transformer 架構，必須先理解這個架構在計算複雜度與記憶體頻寬上的兩個根本限制。

### 3.1 自注意力機制的 O(N²) 複雜度

Transformer 的核心創新是自注意力機制（Self-Attention），讓模型在處理每個 token 時，計算它與序列中所有其他 token 之間的相關性分數。這個「兩兩配對」的計算，使得計算量隨序列長度 N 呈現 **O(N²)** 的二次方成長——序列長度加倍，計算量變為四倍；序列長度從 4K 增至 128K，計算量暴增超過 1,000 倍。

這個複雜度問題不是理論上的擔憂，而是直接決定了大型語言模型推理的能源成本與速度上限，也是促使 Liquid AI 等公司探索替代架構的核心動機之一。

### 3.2 KV Cache 與記憶體頻寬瓶頸

Transformer 推理時，需要將序列中所有過去 token 的 Key 與 Value 向量快取在 GPU 高頻寬記憶體（HBM）中，稱為 KV Cache。這個快取的大小隨序列長度線性增長，且每生成一個新 token，都需要把整個 KV Cache 從 HBM 讀進計算核心進行運算。

這帶來一個經常被低估的事實：LLM 推理的真正瓶頸，往往不是算力（FLOPS），而是記憶體頻寬。GPU 的計算核心大量時間花在等待資料從 HBM 傳輸過來，而非真正進行運算——這也是為什麼 GPU 在推理時的利用率通常遠低於訓練時。

### 3.3 LFM2 對 KV Cache 問題的具體回應

Spheron 的技術部署指南針對 LFM2-8B-A1B 的架構提供了具體數據：LFM2-8B-A1B 使用 18 層 LIV（線性輸入變體）卷積層與 6 層 GQA（分組查詢注意力）層。LIV 層維持固定大小的循環狀態，不會隨序列增長而擴大 KV Cache；6 層 GQA 確實會維持 KV Cache，但因為只有 25% 的層使用注意力機制（相比純 Transformer 的全部層都使用），且 GQA 本身已比標準多頭注意力（MHA）使用更少的 KV 頭數，整體 KV Cache 在長上下文情境下明顯更小。

這段技術說明清楚指出了一個重要的事實：LFM2 確實會產生 KV Cache，只是規模遠小於同等的純 Transformer 模型——這糾正了一個常見的簡化說法（「LFM 完全沒有 KV Cache」），LFM2 採取的是混合架構，而非徹底消除注意力機制。

---

## 第四章：液態神經網路的數學機制：LTC ODE 方程解析

### 4.1 核心方程

液態時間常數網路（LTC）的核心，由一條常微分方程描述。根據原始論文的數學形式 [4][5][6]，LTC 神經元的動態可表示為：

```
τ(x, I) · dx/dt = −x(t) + f(x(t), I(t))
```

其中：
- `x(t)`：神經元在時刻 t 的連續狀態
- `dx/dt`：狀態的時間導數，即變化速率
- `τ(x, I)`：液態時間常數——關鍵在於它是狀態 `x` 和輸入 `I` 的函數，而非固定常數
- `f(x(t), I(t))`：非線性驱動函數
- `−x(t)`：耗散項，確保系統穩定收斂

原始論文摘要明確指出這個設計的核心思路：不是用隱式非線性宣告系統動態，而是構建由非線性互聯閘門調節的線性一階動態系統網路，所得到的模型代表具有隨輸入變化（即液態）時間常數、並耦合至隱藏狀態的動態系統，輸出則透過數值微分方程求解器計算。

### 4.2 穩定性與表達力的數學證明

論文進一步證明：這些神經網路展現穩定且有界的行為，在神經常微分方程家族中具有更優越的表達能力，並在時間序列預測任務上取得效能提升。AAAI 會議論文集收錄的版本也說明了具體的研究方法：研究團隊首先採用理論方法，找出系統動態的邊界，並透過潛在軌跡空間中的軌跡長度量度，計算其表達能力，然後進行一系列時間序列預測實驗，以證明 LTC 相較於經典和現代 RNN 的逼近能力。

### 4.3 長期依賴的已知限制

值得注意的是，研究團隊自己也在論文中坦承了 LTC 的一項限制：與許多時間連續模型的變體類似，LTC 同樣會出現梯度消失現象。這代表 LTC 雖然在數學上具有穩定性優勢，但在長期依賴關係的學習上，並非完全免於傳統 RNN 面臨的經典挑戰。

### 4.4 生物學靈感的來源

關於 LTC 設計靈感的生物學基礎，2018 年的奠基論文說明：神經元時間常數的變化機制，透過其非線性突觸傳輸模型實現，這項特徵的靈感來自小型物種神經系統中的通訊原理，使模型能夠用少量計算單元逼近連續映射。

Hugging Face 上 LFM2-1.2B 模型卡的範例對話，也直接呼應了這個生物學起源——模型在回答「什麼是 C. elegans」這個問題時的內建範例回應是：「這是一種生活在溫帶土壤環境中的微小線蟲」，顯示這個生物學典故已被深度整合進公司的產品敘事與訓練資料中。

---

## 第五章：從 LNN 到 LFM：架構工程化的過程

### 5.1 從純理論 ODE 到可規模化的產品

原始的 LTC 網路雖然在學術論文中展現了優越的數學性質，但要規模化到數十億參數、並在真實硬體上高效推理，需要大量的工程轉化。Liquid AI 把這個過程描述為從「液態神經網路」（LNN，學術研究階段的架構）演進到「液態基礎模型」（LFM，產品化的工程架構）。

### 5.2 結構化、自適應算子的設計哲學

西班牙文版的 Business Wire 新聞稿對這個工程轉化提供了清晰的描述：與傳統的 Transformer 模型不同，LFM2 由結構化、自適應的算子組成，這讓訓練更有效率、推理更快速，並在長上下文或資源受限的情境下有更好的泛化能力。

同一份新聞稿也引用了 Ramin Hasani 對這個設計哲學的說明：「在 Liquid，我們以品質、延遲與記憶體效率為核心理念，設計同類最佳的基礎模型。LFM2 系列模型的設計、開發與優化目標，是在任何處理器上的裝置端部署，為邊緣的生成式與代理式 AI 應用提供真正的存取能力」。

---

## 第六章：LFM2 架構解剖：ShortConv、GQA 與混合設計

### 6.1 官方對 LFM2 的架構定位

Liquid AI 官方部落格對 LFM2 的發布說明，提供了具體的效能對比數據：今天我們發布 LFM2，這是一類新的液態基礎模型，在品質、速度與記憶體效率部署上樹立了新標準。LFM2 專門設計為提供業界最快的裝置端生成式 AI 體驗，從而為大量裝置解鎖生成式 AI 工作負載。基於全新的混合架構，LFM2 在 CPU 上的解碼與預填充效能比 Qwen3 快 2 倍。

官方部落格也強調了架構創新對訓練效率的影響：除了部署效益，我們全新的架構與訓練基礎設施，相較於前一代 LFM，帶來 3 倍的訓練效率提升，使 LFM2 成為建構有能力、通用 AI 系統最具成本效益的路徑。

### 6.2 注意力佔比與計算分工

AMD 官方部落格針對 LFM2 架構提供了更精確的量化描述：Liquid AI 最新的架構 LFM2，是一個混合模型，僅約 20% 依賴注意力機制，大部分運算由快速、對記憶體友善的一維短卷積處理——這大幅降低了記憶體佔用並提升速度，同時不犧牲能力。

關於 LFM2 在個人化與規模上的設計目標，AMD 部落格進一步說明：除了高效運行外，裝置端 AI 還需要行為類似大型模型、針對特定任務的小型模型。因此 LFM2 也被設計為極其高效的個人化模型，透過應用特定的專業化，解鎖高品質的裝置端生成式 AI。文字模型的規格範圍為：3.5 億到 26 億參數的文字模型，外加一個僅啟動 10 億參數的 80 億參數 MoE（混合專家）模型。

報告總結了這個架構方法的核心價值：這種架構方法使 LFM 非常適合裝置端 AI 這個新興範式，能在人們已經擁有的硬體上，提供雲端品質的智能。

### 6.3 開源策略

西班牙文 Business Wire 新聞稿確認了 LFM2 的開源發布細節：Liquid AI 今天宣布發布最新一代的液態基礎模型（LFM2），在邊緣模型類別中創下速度、能源效率與品質的紀錄。LFM2 的權重已可在 Hugging Face 下載，並可透過 Liquid Playground 進行測試。新聞稿也透露了後續產品規劃：LFM2 是 Liquid AI 接下來幾個月將發布的一系列強大模型中的第一個。

### 6.4 微調建議

Hugging Face 上的官方模型卡，對 LFM2 的實際應用提供了明確建議：由於體積較小，我們建議在狹窄的應用場景上對 LFM2 模型進行微調，以最大化效能，並補充說明部署彈性：靈活部署——LFM2 在 CPU、GPU 與 NPU 硬體上皆能高效運行，適合在智慧型手機、筆記型電腦或車輛上進行靈活部署。

這項建議直接呼應了本報告後續章節討論的「知識容量限制」——由於小模型的參數容量有限，官方本身也承認通用能力有上限，更適合針對垂直場景進行客製化微調，而非作為開放域百科知識庫使用。

---

## 第七章：LFM2.5 系列：效能與規格全覽

### 7.1 官方對 LFM2.5 的定位

Liquid AI 官方產品頁面對 LFM2.5 的技術升級提供了明確說明：LFM2.5 在 LFM2 的基礎上，擴展至 28 兆 token 的預訓練量，並採用規模化的強化學習流程，推動小模型能力邊界的極限——涵蓋文字、視覺與音訊模型，為任何裝置上（無論連接雲端與否）的可靠、生產就緒代理系統打造。

官方頁面也概括了 LFM2 家族的整體定位：LFM2 是一個混合模型家族，設計目標是能在任何地方運行——任何 CPU、NPU 或 GPU——並具備同類最佳的速度、多語言支援，以及為真實世界各種規模部署設計的多模態能力，以及：LFM 在輕量化、可客製化、計算高效的足跡下，提供強大效能，適用於任何環境的部署。

### 7.2 多模態模型的低延遲設計取向

官方產品頁面對多模態模型的設計目標提供了具體描述：使用視覺與文字輸入輸出的多模態模型，其能力專為低延遲與裝置感知部署設計，以及針對細粒度應用場景的小型模型：針對特定任務與知識訂製的微型模型。

### 7.3 LFM2.5-Audio：語音代理的低延遲實證

關於 LFM2.5 在語音應用上的部署現實，COEY 的分析報導提供了重要的脈絡說明：開放權重的發布本身，並不意味著存在像 OpenAI 或 Anthropic 那種單一的官方託管 Liquid AI 音訊 API。但自動化的應用前景依然強勁，因為開發者可以建立自己的內部 API（本地伺服器、容器、邊緣執行環境），並從任何地方呼叫它——簡而言之：只要你的技術堆疊能呼叫一個 HTTP 端點，就能自動化這個流程，只需要在模型前面加一層推理包裝器。

報導對該模型的實際適用場景給出了務實的評估：LFM2.5-Audio-1.5B 的最佳應用場景不是「明天就取代你的客服中心」，而是：邊走邊構思、通勤中或編輯時的語音優先構思——「說出大綱，得到語音化的結構回饋」，這是一個相對謹慎、聚焦於明確場景而非誇大宣傳的定位描述。

### 7.4 部署架構與成本分析

Spheron 的部署指南針對 LFM2 系列在雲端 GPU 上的部署提供了具體的技術建議：LFM2-8B-A1B 的官方文件記載上下文窗口為 32,768 token（32K），根據 docs.liquid.ai 上的官方文件，應在 vLLM 啟動指令中明確設定 --max-model-len 32768。指南也對兩個主力模型的架構差異做了區分：LFM2-8B-A1B 是一個稀疏 MoE 模型，總參數 83 億，每個 token 啟動 15 億參數；LFM2-2.6B 則是一個較小的密集模型，參數量為 26 億。LFM2-8B-A1B 在複雜推理和指令遵循上提供更好的品質。

---

## 第八章：極限環問題：動力學陷阱的完整剖析

### 8.1 兩種「復讀機」的本質差異

小型語言模型（包括 Transformer 架構與液態神經網路架構）在處理複雜推理或長對話任務時，都容易陷入重複輸出的「死循環」現象。但兩者的底層數學機制截然不同：

**Transformer 的復讀機**：本質是機率分佈的正回饋塌陷。Softmax 函數把 logit 分數轉換為機率分佈時，一旦某個 token 被選中過一次，會在後續生成中被進一步放大機率，形成不可逆的螺旋收縮——在相空間中表現為軌跡收斂到一個穩定的「不動點」（fixed point），對應「只生成同一個 token 或同一段文字」的靜止狀態。

**液態模型的極限環**：本質是動力系統的幾何陷阱。LTC 神經元的隱藏狀態，在某些輸入條件和參數配置下，可能被拉進一條閉合的週期軌道（Limit Cycle）——這是非線性動力學中描述振盪系統的經典概念，最早由荷兰工程師 Van der Pol 在研究真空管電路時系統化描述。在這個軌道上，隱藏狀態週期性地循環，產生的輸出也因此呈現週期性重複，而非完全相同的靜止狀態。

### 8.2 LFM2.5-Thinking 的已知問題

這個問題不只是理論推測——它在 Liquid AI 自己的產品文件中也被坦承提及。根據官方部落格對 LFM2.5-1.2B-Thinking 模型的說明，這個嘗試在小型液態模型上整合思維鏈（Chain-of-Thought）推理能力的版本，在某些情況下確實會出現偏離正常收斂的重複文本循環現象，這與該模型首次嘗試在 1.2B 這種極小規模上實現複雜推理能力直接相關——CoT 推理通常被認為需要遠大於此的參數規模才能穩定運作。

### 8.3 兩種失敗模式的應對手段差異

| 失敗模式 | 數學本質 | 有效應對手段 |
|---|---|---|
| Transformer 逐字重複 | 機率分佈塌陷至不動點 | `repeat_penalty`、`temperature` 提升 |
| Thinking 模式不收斂 | Stop token 訓練覆蓋不足 | 限制生成長度、強制收尾指令 |
| 液態模型極限環 | 隱藏狀態困在閉合軌道 | 改變輸入訊號性質、調整 ODE 耗散強度 |

這個對照表的核心訊息：**沒有一個放諸四海皆準的解法**。不同架構、不同失敗模式，需要對應不同的偵測邏輯與不同的干預層級——從採樣參數調整（治標），到系統提示重新引導（部分治本），到重新訓練修改 ODE 能量函數（徹底治本）。

---

## 第九章：LFM 的真實限制：知識容量、代碼生成、生態系

### 9.1 固定隱藏狀態容量的物理上限

LFM 架構最核心的取捨在於：用固定大小的隱藏狀態取代隨序列線性增長的 KV Cache，換取 O(1) 的記憶體需求與邊緣部署能力。但這個取捨的代價，是任何有限容量的資訊儲存，面對無限增長的輸入，都必然在某個時刻開始遺忘早期資訊。

這在以下場景造成結構性的劣勢：需要精確記住對話開頭設定的多輪深度對話、需要精確計數或位置記憶的狀態追蹤任務，以及需要逐字精確的超長文件問答。

### 9.2 零樣本代碼生成的相對弱勢

公開的官方建議已間接承認了這個限制——Hugging Face 模型卡建議使用者「在狹窄的應用場景上微調」而非直接用於開放式代碼生成任務 [15]。這個建議背後的技術原因，與 ShortConv 算子的短感受野（難以追蹤跨越數百行的長距離語法依賴）、以及訓練資料中代碼比例相對通用語言理解較低有關。

### 9.3 知識容量的天花板

Liquid AI 的 Edge-first 定位，帶來了一個不可避免的知識容量上限：3.5 億到 26 億參數的模型，在百科知識廣度上，無法與千億甚至兆級參數的雲端模型競爭。官方的策略性回應，是把 LFM 定位為「推理引擎」而非「知識庫」，建議搭配檢索增強生成（RAG）架構使用，讓 LFM 專注於推理與生成，知識則從外部資料庫即時檢索。

### 9.4 生態系成熟度的差距

目前最流行的開源推理框架（如 llama.cpp、vLLM）大多針對標準 Transformer 的 KV Cache 機制做了深度優化。LFM 的混合架構需要額外的工程適配才能完全發揮優勢。Liquid AI 自行開發了針對 LFM 架構優化的推理方案，並透過 GGUF 格式支援與 Hugging Face transformers 庫的整合，降低社群採用門檻 [15]，但相較於已發展數年的 Transformer 工具鏈生態，仍處於追趕階段。

---

## 第十章：低延遲場景：LFM 的真正主戰場與邊界條件

### 10.1 為什麼低延遲是 LFM 的核心價值主張

LFM 沒有隨序列增長的 KV Cache（或僅有遠小於同等 Transformer 的 KV Cache），這意味著每個 token 生成的計算量相對固定，不會因為對話歷史增長而持續下降速度。這個特性，搭配官方公布的 CPU 推理速度數據——解碼與預填充效能比 Qwen3 快 2 倍——構成了 LFM 在低延遲、邊緣推理場景的核心競爭力。

### 10.2 真實世界的延遲邊界條件

然而，低延遲優勢有明確的邊界：

**長推理鏈的延遲惡化**：當啟用 Thinking 模式進行複雜推理時，模型可能生成數百到數千個中間 token，這會讓總延遲遠超過「即時回應」的心理預期門檻（通常在 200–300 毫秒）。這也是 LFM2.5-Thinking 容易在這類長鏈推理中遭遇極限環問題的場景。

**量化對精度的影響**：int8 等量化技術能大幅縮小模型尺寸與記憶體佔用（這是邊緣部署可行性的關鍵），但會犧牲部分計算精度，對某些任務（尤其是精確數學運算）的效能有明顯影響。

**硬體碎片化**：不同處理器平台（ARM CPU、Apple Silicon、Qualcomm NPU、AMD GPU）對算子的支援程度不同，即使 LFM2 被設計為跨平台友善，實際的加速效果在不同硬體上仍有差異，需要平台特定的調優工作。

---

## 第十一章：產業部署案例：金融、自駕、醫療、工業 IoT

### 11.1 金融服務

官方新聞稿明確將金融服務列為 Liquid AI 重點布局的產業領域之一 [9][24]，其技術契合點在於：詐欺偵測任務需要對時序交易資料進行即時分析，且延遲容忍度極低（通常要求數百毫秒內完成判定）——這正是 LFM 連續時間感知架構的設計強項。

### 11.2 自駕車與機器人

Liquid AI 創辦團隊在 MIT 時期的研究，已展示了液態神經網路在自駕車控制任務上極致精簡的潛力（用遠少於傳統網路的神經元數量完成車道保持等任務），這項研究背景也說明了為何自駕車控制成為公司商業布局的早期重點領域之一 [9]。

### 11.3 生物科技與醫療

官方活動明確將生物科技列為首批產品展示的應用領域 [9]，這與醫療場景對本地化推理（保護病患隱私資訊不出院內網路）的剛性法規需求高度契合。

### 11.4 消費電子與裝置端部署

AMD 部落格的案例描述，展示了 LFM2 在裝置端會議摘要應用上的具體落地：展示了在裝置端進行私密會議摘要的應用，這正是 LFM2 混合架構設計理念的體現，呼應了 AMD Ryzen 處理器生態與 Liquid AI 模型優化合作的商業實踐。

---

## 第十二章：商業生態與護城河分析

### 12.1 不直接挑戰 OpenAI 的市場定位策略

AI Business Weekly 的分析精準概括了 Liquid AI 的差異化定位：與 OpenAI、Anthropic、Google 追求面向消費應用的通用模型不同，Liquid AI 強調針對特定企業垂直領域優化的專業模型，這種定位避開了與資金雄厚的既有業者正面競爭，轉而瞄準服務不足的市場區隔。

### 12.2 硬體生態聯盟：AMD 的策略性意義

這個聯盟的核心邏輯，在於 Liquid AI 的架構天然契合非 NVIDIA 硬體的特性。傳統 Transformer 模型需要昂貴、具備高記憶體頻寬的 NVIDIA GPU，形成限制部署選項的硬體依賴；液態神經網路較低的運算需求，使其能在 AMD 處理器與 GPU 上高效運行，有潛力衝擊 NVIDIA 在 AI 推理工作負載上的主導地位。

### 12.3 開源策略作為生態建設手段

LFM2 系列以 Apache 2.0 授權在 Hugging Face 開源發布 [19][15]，這個策略讓開發者社群可以直接實驗、微調、進行基礎研究，加速發現架構的潛力與限制，同時也降低開發者嘗試非 Transformer 架構的門檻——這是 Liquid AI 對抗整個產業對 Transformer 路徑依賴的長期生態策略。

### 12.4 風險與脆弱性

儘管架構差異化明顯，Liquid AI 仍面臨幾個結構性風險：大型科技公司（Google Gemma、Meta Llama 系列）持續投資邊緣 AI，技術資源充沛；同屬非 Transformer 路線的 Mamba 系列研究團隊形成直接競爭；以及 LFM 在知識廣度、代碼生成等任務上仍落後於同等規模的優化 Transformer 模型（如 Phi-4 Mini），這些差距若未能持續縮小，可能限制企業客戶採用通用型解決方案時的選擇傾向。

---

## 第十三章：結語

Liquid AI 的技術路線，代表著 AI 產業在「擴大規模」這個主流敘事之外，一條罕見但邏輯嚴謹的替代路徑：透過重新設計神經網路的數學基礎（從靜態矩陣映射轉向連續時間動力系統），在計算複雜度與記憶體需求上取得結構性優勢，並將這個優勢明確導向企業邊緣部署這個 Transformer 架構相對弱勢的市場區隔。

這條路線的技術可信度，建立在紮實的學術根基之上——從 2018 年的奠基論文，到 2020 年正式提出 LTC 網路，到 2024–2026 年間連續發布的 LFM、LFM2、LFM2.5 產品迭代，呈現出一條清晰、可驗證的技術演進軌跡。同時，本報告也呈現了這條路線的真實限制：固定隱藏狀態帶來的長程記憶取捨、極限環這種架構特有的失敗模式、知識容量的物理上限，以及生態系成熟度的現實差距。

這些限制不構成對 Liquid AI 技術路線的否定，而是劃定了它目前最適用的邊界——低延遲、邊緣部署、垂直場景優化的企業 AI 應用，而非取代雲端通用大模型在知識廣度與複雜推理上的角色。這種務實的場景定位，或許正是 Liquid AI 在資本市場與企業客戶之間，持續取得信任的關鍵原因。

---

## 第十四章：參考文獻

[1] Liquid AI 官方產品頁面，"Liquid Foundation Models"
https://www.liquid.ai/models

[2] Tracxn，"Liquid AI - 2026 Company Profile, Team, Funding & Competitors"
https://tracxn.com/d/companies/liquid-ai/__WcgGMTavFS-PIXLKpe46XDv3j7Q4kwlkc7Hd-zvaYko

[3] AI Business Weekly，"Liquid AI Raises $250 Million in Round Led by AMD"
https://aibusinessweekly.net/p/liquid-ai-250-million-series-a-foundation-models

[4] arXiv，Hasani et al.，"Liquid Time-constant Networks" (abstract page)
https://arxiv.org/abs/2006.04439

[5] arXiv，Hasani et al.，"Liquid Time-constant Networks" v2
https://arxiv.org/abs/2006.04439v2

[6] arXiv，Hasani, Lechner, Amini, Rus, Grosu，"Liquid Time-constant Recurrent Neural Networks as Universal Approximators"
https://arxiv.org/pdf/1811.00321

[7] arXiv，"Closed-form Continuous-time Neural Models"
https://arxiv.org/abs/2106.13898

[8] Nature Machine Intelligence，"Closed-form continuous-time neural networks"
https://www.nature.com/articles/s42256-022-00556-7

[9] Business Wire，"Liquid AI to Unveil First Products Built on Liquid Foundation Models (LFMs) at Exclusive MIT Event"
https://www.businesswire.com/news/home/20241015656145/en

[10] Tracxn，Liquid AI 募資歷程記錄
https://tracxn.com/d/companies/liquid-ai/__WcgGMTavFS-PIXLKpe46XDv3j7Q4kwlkc7Hd-zvaYko

[11] Spheron Network Blog，"Deploy Liquid AI LFM2 Models (LFM2-8B-A1B, LFM2-2.6B) on GPU Cloud: Hybrid Architecture Guide (2026)"
https://www.spheron.network/blog/liquid-foundation-models-lfm-deployment-gpu-cloud-2026/

[12] AMD 官方部落格，"Liquid AI & AMD Show the Future of On-Device AI With Local Private Meeting Summarization"
https://www.amd.com/en/blogs/2026/liquid-ai-amd-ryzen-on-device-meeting-summaries.html

[13] Liquid AI 官方產品頁面（LFM2.5 章節）
https://www.liquid.ai/models

[14] Liquid AI 官方部落格，"Introducing LFM2: The Fastest On-Device Foundation Models on the Market"
https://www.liquid.ai/blog/liquid-foundation-models-v2-our-second-series-of-generative-ai-models

[15] Hugging Face，"LiquidAI/LFM2-1.2B" 模型卡
https://huggingface.co/LiquidAI/LFM2-1.2B

[16] COEY，"Liquid AI LFM2.5 Makes On Device Speech Agents Real"
https://coey.com/resources/blog/2026/01/06/liquid-ai-lfm2-5-makes-on-device-speech-agents-real/

[17] CB Insights，"Liquid AI" 公司檔案
https://www.cbinsights.com/company/liquid-ai

[18] CB Insights，"Liquid AI" 公司檔案（同上，募資與估值數據）
https://www.cbinsights.com/company/liquid-ai

[19] Business Wire（西班牙文版），"Liquid AI publica los modelos fundacionales pequeños de código abierto más rápidos y de mejor rendimiento del mundo"
https://www.businesswire.com/news/home/20250710879926/es

[20] Tech Funding News，"Liquid AI closes $250M, hits $2B valuation with AMD-led funding"
https://techfundingnews.com/liquid-ai-closes-250m-hits-2b-valuation-with-amd-led-funding/

[21] SalesTools.io，"Liquid AI Raises $250M Series A"
https://salestools.io/en/report/liquid-ai-raises-250m-series-a-december-2024

[22] OpenTools.ai，"Liquid AI Closes $250M Round, Surges to $2B Valuation!"
https://opentools.ai/news/liquid-ai-closes-dollar250m-round-surges-to-dollar2b-valuation

[23] The Information，"Liquid AI Raises $250 Million in Round Led by AMD"
https://www.theinformation.com/briefings/liquid-ai-raises-250-million-in-round-led-by-amd

[24] Pulse2，"Liquid AI: $250 Million (Series A) Raised For Scaling Capable General-Purpose AI"
https://pulse2.com/liquid-ai-250-million-series-a-raised-for-scaling-capable-general-purpose-ai/

[25] TexAu，"How Much Did Liquid AI Raise? Funding & Key Investors"
https://www.texau.com/profiles/liquid-ai

[26] Tracxn，"Liquid AI" 公司檔案與募資總覽
https://tracxn.com/d/companies/liquid-ai/__WcgGMTavFS-PIXLKpe46XDv3j7Q4kwlkc7Hd-zvaYko

[27] Digital Media Wire，"Liquid AI Closes $250M, Hits $2B Valuation With AMD-Led Funding"
https://digitalmediawire.com/2024/12/16/liquid-ai-closes-250m-hits-2b-valuation-with-amd-led-funding/

[28] AI Business Weekly，"Liquid AI Raises $250M Series A at $2.35B Valuation"
https://aibusinessweekly.net/p/liquid-ai-250-million-series-a-foundation-models

[29] arXiv AAAI Proceedings，"Liquid Time-constant Networks"（理論證明完整版）
https://ojs.aaai.org/index.php/AAAI/article/view/16936/16743

[30] arXiv，"LTC-SE: Expanding the Potential of Liquid Time-Constant Neural Networks for Scalable AI and Embedded Systems"
https://arxiv.org/pdf/2304.08691

[31] ar5iv (arXiv HTML 版)，"Liquid Time-constant Networks" 全文
https://ar5iv.labs.arxiv.org/html/2006.04439

[32] NASA ADS，"Liquid Time-constant Networks" 摘要記錄
https://ui.adsabs.harvard.edu/abs/2020arXiv200604439H/abstract

[33] AAAI Proceedings，"Liquid Time-constant Networks" 會議論文集條目
https://ojs.aaai.org/index.php/AAAI/article/view/16936

---

## 附註：方法論與資料可信度說明

本報告所引用的官方資料（Liquid AI 官方部落格、產品頁面、Hugging Face 模型卡）與第三方獨立報導（Business Wire、Tech Funding News、The Information、AI Business Weekly 等）在性質上有所不同：官方資料代表公司自身的技術主張與產品定位陳述，第三方報導則提供了估值、募資細節的交叉驗證,以及部分產業分析視角。讀者在解讀效能數據（如「比 Qwen3 快 2 倍」等比較性宣稱）時，應留意這些數字多數來自官方公布的基準測試，獨立第三方的同條件複現驗證在本報告完成時尚不全面，建議在實際技術選型決策前，自行進行針對性的基準測試。

文中部分公司估值數字在不同報導間存在細微差異（例如 23 億美元 vs 23.5 億美元 vs 20 億美元），這反映了不同報導時間點、不同計算口徑（投後估值 vs 投前估值）的差異，本報告保留原始報導的數字呈現，不做强行統一。

---

*本文為《美國企業 AI 系列》Liquid AI 技術報告，整合公司起源、數學機制、架構演進、產業限制與完整參考文獻。*

*作者：Jeffrey／momosan2692*
*日期：2026 年 6 月*
