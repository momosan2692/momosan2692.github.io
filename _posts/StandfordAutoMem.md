---
layout: post
title: Standford Auto Mem
subtitle: 
cover-img: /assets/img/header/2026-05-12/EVERPURE.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-12/EVERPURE.png
published: false
pinned: false
tags: []
---



# Standford Auto Mem

AutoMem（全称 AutoMem: Automated Learning of Memory as a Cognitive Skill）是史丹佛大學團隊於 2026 年 7 月 發表的一項突破性 AI 框架研究。其核心理念是將「記憶管理」視為 AI 模型自身需要練就的一種“認知技能”（元記憶 Metamemory），而非一個外掛的靜態資料庫。 [1, 2, 3, 4] 
透過這種方式，團隊成功讓一個開源的 Qwen2.5-32B-Instruct 模型在複雜長任務中，展現出媲美 Claude 4.5 Opus 與 Gemini 3.1 Pro Thinking 等頂尖閉源巨型模型的性能，而無需進行傳統的參數擴展。 [2, 5] 
------------------------------
## 💡 核心創新：把記憶操作變成「動作」
傳統 AI Agent 的記憶通常是硬編碼的靜態架構（例如標準的向量資料庫或 RAG 管道）。AutoMem 徹底打破了這個邏輯，把檔案系統的讀取（Read）、寫入（Write）、搜尋（Search）、附加（Append）直接提昇為模型行動空間裡的「一等公民動作」，與一般的任務動作（如遊戲中“向北走”、“攻擊”）並列。 [4, 6, 7] 
模型在執行任務時，內部會自主運行兩個常規流程： [4] 

* LOG 流程（記什麼）：模型自我提問「剛才發生的事有什麼值得記錄？」，並自主決定是要開新檔案、覆寫索引，還是附加原始紀錄。
* PLAN 流程（何時讀）：模型自我提問「我現在需要回想什麼才能行動？」，隨後主動搜尋或調閱歷史日誌來輔助當下的決策。 [4] 

------------------------------
## 🔄 雙層自動化優化循環（Dual-Loop Framework）
由於人類不可能手動去優化成千上萬步的記憶決策，AutoMem 設計了一套雙外循環機制來自動訓練 AI 的記憶技能： [3, 4] 

[ 頂尖 Meta-LLM ] (如 Claude Opus) 
       │
       ▼ (循環 1: 架構修訂)
優化記憶基建 (提示詞、檔案格式、Schema)
       │
       ▼ (循環 2: 熟練度訓練)
篩選優質記憶決策 ──> 微調/蒸餾 ──> [ 輕量化記憶專家模型 ]


   1. 第一層循環：架構修訂（Scaffold Revision）
   由一個強大的頂尖模型（如 Claude）充當「導師」，審查普通 Agent 完整的執行軌跡，診斷它在哪裡迷路或失敗，進而自動修改和重寫 Agent 的記憶基礎建設（例如優化提示詞、修改檔案 Schema 或發明新指令）。 [4, 8] 
   2. 第二層循環：熟練度訓練（Proficiency Training）
   從大量的任務嘗試中，自動篩選出「正確且成功」的記憶操作範例，並將這些行為作為信號，去微調、訓練出一個專門管理記憶的輕量化專家模型，讓它學會高效率的存取紀律。 [4, 8] 

------------------------------
## 📊 驚人的實測表現
在 Crafter、MiniHack 和 NetHack 等需要上萬步操作、極度依賴長期記憶的複雜游戏與長任務基準測試中： [4, 9] 

* 性能倍增：在不觸動任何任務核心動作邏輯的前提下，單靠優化記憶管理，就讓基礎 Agent 的表現提升了 2 到 4 倍。
* 以小博大：讓一個 32B（320億參數）的開源模型，在 NetHack 等測試中成功逆襲、並肩甚至超越了千億/萬億級別的頂尖商業閉源模型。 [9, 10, 11, 12] 

## 🛠️ 開發者核心啟示
這項研究向科技界證明，AI Agent 的上下文崩潰、幻覺循環和 Token 膨脹，並不完全是硬體或檢索技術的瓶頸，更取決於模型是否擁有良好的組織紀律。透過將記憶模組化、動作化並進行針對性微調，開發者未來能以極低的 API 帳單成本，用中小型本地開源模型達到企業級的超長任務處理能力。 [4] 
------------------------------
您是否想深入了解 AutoMem 論文中關於[記憶架構（如 Zettelkasten 筆記法或圖向量結合）的技術細節](https://automem.ai/docs/research/)，或是想知道如何在您現有的 AI Agent 項目中實作這套雙循環邏輯？ [13] 

[1] [https://arxiv.org](https://arxiv.org/html/2607.01224v1)
[2] [https://www.alphamatch.ai](https://www.alphamatch.ai/blog/automem-qwen-memory-management-2026)
[3] [https://cloud.tencent.com](https://cloud.tencent.com/developer/article/2704518?policyId=1004)
[4] [https://www.linkedin.com](https://www.linkedin.com/pulse/automem-treating-memory-trainable-agentic-skill-frontwalkersl-j6exc)
[5] [https://www.youtube.com](https://www.youtube.com/watch?v=Jd2_IkBXOGM)
[6] [https://www.facebook.com](https://www.facebook.com/largitdata/posts/%E8%83%BD%E6%8A%8A%E8%A8%98%E6%86%B6%E8%AE%8A%E6%88%90%E4%B8%80%E9%A0%85%E5%8F%AF%E4%BB%A5%E7%B7%B4%E5%87%BA%E4%BE%86%E7%9A%84%E6%8A%80%E8%83%BDllm-%E7%9A%84%E7%93%B6%E9%A0%B8%E5%9C%A8%E4%B8%8A%E4%B8%8B%E6%96%87%E8%A6%96%E7%AA%97%E4%B9%9F%E5%B0%B1%E6%98%AF%E5%B7%A5%E4%BD%9C%E8%A8%98%E6%86%B6%E5%B0%B1%E9%82%A3%E9%BA%BC%E5%A4%A7%E5%A6%82%E6%9E%9C%E9%95%B7%E6%99%82%E9%96%93%E4%BB%BB%E5%8B%99%E5%8B%95%E8%BC%92%E4%B8%8A%E8%90%AC%E6%AD%A5%E5%A1%9E%E4%B8%8D%E9%80%B2%E5%8E%BB%E7%9A%84%E8%B3%87%E8%A8%8A%E6%80%8E%E9%BA%BC%E8%BE%A6%E5%8F%B2%E4%B8%B9%E4%BD%9B%E9%80%99%E7%AF%87-automem-%E6%8F%90%E5%87%BA%E8%88%87%E5%85%B6/1548223397317051/)
[7] [https://www.163.com](https://www.163.com/dy/article/L0U1S7BR051193U6.html)
[8] [https://www.sina.cn](https://www.sina.cn/news/detail/5318125672469780.html)
[9] [https://digg.com](https://digg.com/tech/9un69wvk)
[10] [https://www.alphamatch.ai](https://www.alphamatch.ai/zh/blog/automem-qwen-memory-management-2026)
[11] [https://www.youtube.com](https://www.youtube.com/watch?v=ulGkgvUaT6Q)
[12] [https://www.zhichai.top](https://www.zhichai.top/archives/12990)
[13] [https://automem.ai](https://automem.ai/docs/research/)


### From Claud desktop 
確認過了 — 這是真實存在的論文,史丹佛大學團隊(Shengguang Wu, Hao Zhu, Yuhui Zhang, Xiaohan Wang, Serena Yeung-Levy)於 2026 年 7 月 1 日發表於 arXiv(2607.01224v1),與您先前問的 automem.ai(一套商用記憶資料庫產品)完全是兩回事,只是剛好同名。以下是論文摘要:

## 核心概念:記憶管理即「可訓練的認知技能」

論文從認知科學的 **metamemory(元記憶)** 概念出發(Flavell 1979、Nelson 1990):知道「該記什麼、何時取用、如何組織」本身是一種可透過練習精進的技能,而非固定的系統架構。作者將這個視角搬到 LLM agent 上——把記憶操作(read/write/search/append)提升為與任務動作平起平坐的「一等公民動作」,讓模型自己決定怎麼管理記憶。

## 雙外循環架構(Dual Outer-Loop)

Agent 內部每步執行兩個例程:
- **LOG 流程**:剛剛發生的事有什麼值得記?
- **PLAN 流程**:現在要行動,需要回想什麼?

外層則有兩個自動化循環,由 meta-LLM(Claude Opus)驅動:

1. **Outer-loop #1(架構修訂)**:Claude Opus 4.6 審閱完整的執行軌跡(長達 10⁵ 步),診斷記憶管理哪裡出錯,重寫 agent 的 prompt、檔案 schema、動作詞彙。每次修訂只有在固定種子上平均進度嚴格優於前一版才會被採納。

2. **Outer-loop #2(熟練度訓練)**:Claude Opus 4.7 從大量 episode 中篩選出「好的記憶決策」作為 LoRA 微調的訓練資料,只訓練一個獨立的「記憶專家」子模型,任務動作模型的權重完全不動——確保記憶能力提升不會犧牲既有任務能力。

## 實驗結果(Qwen2.5-32B-Instruct,BALROG 基準)

在 Crafter、MiniHack、NetHack 三個長時程遊戲上:

| 環境 | v0(基礎) | 架構優化後 | +記憶訓練 |
|---|---|---|---|
| Crafter | 25.0% | 47.27%(×1.89) | 51.36% |
| MiniHack | 7.5% | 27.5%(×3.67) | 30.0% |
| NetHack | 0.42% | 1.57%(×3.74) | 1.85% |

**關鍵發現**:單靠優化記憶架構(完全不動模型權重),32B 開源模型的表現就超越了同系列的 Qwen2.5-72B-Instruct,並追上 Claude Opus 4.5、逼近 Gemini 3.1 Pro Thinking 等頂尖閉源模型——顯示在長時程任務中,**良好的記憶管理比模型規模更具槓桿效益**。

行為面的量化指標也支持這點:無效動作率(卡住/來回震盪)下降 32–65%;冗餘寫入下降 68–83%;搜尋落空率下降 13–50%;每步輸入 context 縮減最多 30%。訓練後的記憶專家還內化出「先搜尋再寫入」的紀律(LOG 階段寫入/搜尋比在三個環境分別下降 54%、72%、72%)。

## 與您研究方向的關聯

這篇論文的架構跟您在 AgentCore 裡做的東西高度相關——尤其是 Blackboard 共享記憶 + EpistemicRole 系統,以及您規劃中的「Real World Case Simulator vs RL」延伸討論。論文裡的「meta-LLM 審閱完整軌跡 → 自動改寫 scaffold」模式,本質上是用強模型當 code reviewer 對 agent 記憶基建做自動化 diagnose-and-revise,這跟您 Loop Engineering 技能裡「Debate Loop 需要滿足四個條件才有存在意義」的判準思路是同構的。

也想指出一點:您原本收到的中文摘要文件把這篇論文誤植為「AutoMem: Automated Learning of Memory as a Cognitive Skill」的簡中/民間轉述版,內容大致準確但引用來源相當雜(YouTube、Facebook、digg 等二手轉載),我這次直接抓了 arXiv 原文核對過,上面數字都是原始論文的。

核對後,這份文件大致抓住了論文精神,但有幾個具體錯誤或不夠精確的地方:

## ❌ 具體錯誤

**1. NetHack 舉例用錯了**
文件說「在 NetHack **等**測試中成功逆襲、並肩甚至超越了...頂尖商業閉源模型」——這個舉例剛好選反了。實際數字:

| 環境 | AutoMem (32B) | Claude Opus 4.5 | 是否超越 |
|---|---|---|---|
| Crafter | 51.36% | 49.5% | ✅ 超越 |
| MiniHack | 30.0% | 27.5% | ✅ 超越 |
| NetHack | 1.85% | 2.0% | ❌ 未超越(還落後,且遠低於 Gemini-3-Pro 的 6.8%)|

真正「超越閉源旗艦模型」的是 **Crafter 和 MiniHack**,NetHack 反而是三者中差距縮得最少、但仍未追平的一個。

**2. 「微調/蒸餾」這個詞不準確**
文件把 Outer-loop #2 描述成「篩選優質記憶決策 → 微調/**蒸餾** → 輕量化記憶專家模型」。但論文明確寫道:

> "the meta-LLM's role is to select which responses to reinforce—it thus acts as a filter on the model's own behavior **rather than as a teacher generating new responses**"

也就是說,訓練資料是 **Qwen2.5-32B 自己在遊戲中產生的原始輸出**(verbatim),Claude 只是負責「篩選」哪些片段值得拿來 LoRA 微調,不是由 Claude 生成新答案再蒸餾給小模型。這對您做 AgentCore 的訓練管線設計來說是個重要區別——是 self-distillation-by-selection,不是 teacher-student distillation。

**3. 「需要上萬步操作」誇大了三個環境的規模**
文件說 Crafter、MiniHack、NetHack「等需要上萬步操作」,但實際上只有 **NetHack** 達到 10⁴–10⁵ 步等級;Crafter 約 10³ 步,MiniHack 每個子任務僅約 10² 步。三者的「長時程」程度差異很大,不是統一等級。

**4. 「千億/萬億級別」是無根據的推測**
Gemini-3-Pro、Gemini-3.1-Pro-Thinking、Claude-Opus-4.5 都是閉源模型,論文並未揭露(也無從得知)它們的參數量。這個「千億/萬億」的說法是原文件自行猜測補上去的,不是論文內容。

## ✅ 大致正確的部分
- 史丹佛團隊、2026/7 發表、metamemory 概念、LOG/PLAN 雙例程、雙外循環架構(架構修訂 vs 熟練度訓練)、2–4 倍性能提升的整體結論,都與原文相符。
- 一個小補充:兩個外循環的 meta-LLM 其實不是同一版本——Loop 1(架構修訂)用 **Claude Opus 4.6**,Loop 2(訓練引擎)用 **Claude Opus 4.7**,文件只籠統寫「如 Claude」沒有點出版本差異。


逐項核對:

## 1. 資源增加性、資源重複性 —— ✅ **有討論**,但用詞不同

論文確實討論了這個主題,但是放在「**記憶檔案的冗餘/去重**」框架下,而非泛泛的「資源」:

- **NetHack 案例最具體**:v0 版本用 append-only 的 `dungeon_map.txt`,同一個座標被重複走訪就會反覆寫入重複紀錄,導致地圖檔案無限膨脹。Outer-loop #1 診斷出這個問題後,引入 `<|UPSERT_MAP|>` 操作,改成「座標索引式」的去重格式——同一格子的新觀測會**覆寫**舊紀錄而非疊加。
- **量化效果**:每步記憶增長量從 138 字元降到 6 字元,**減少 95%**。
- **跨三個環境的整體數據**:冗餘寫入(redundant memory-file writes)下降 **68–83%**;空搜尋率(SEARCH 找不到東西)下降 13–50%;每步輸入 context 因此縮減 3–30% tokens。
- 訓練後的「記憶專家」模型還進一步內化了「先搜尋再寫入」(consult-before-write)的習慣,LOG 階段的寫入/搜尋比在三環境分別再降 54%、72%、72%。

所以「資源重複性」對應的正是這套 append-only → 去重(UPSERT/dedup)的機制討論,只是論文原文沒有用「資源」這個詞,而是用 memory writes、duplicate coordinate entries、context growth 這些說法。

## 2. 回覆時間的討論 —— ❌ **沒有討論**

我重新檢視了整篇論文,**沒有找到任何關於推論延遲、wall-clock 回覆時間、或 API 呼叫耗時的討論或量化數據**。論文的評估指標集中在:

- 遊戲 progression rate(%)
- Token/context 長度(字元數、per-step context size)
- 記憶操作的行為指標(寫入次數、搜尋次數、空搜尋率)
- 訓練用的 LoRA 超參數(learning rate、batch size 等)

完全沒有涉及「跑一個 episode 要多久」「meta-LLM 審閱軌跡要多久」「推論速度/吞吐量」這類 latency/throughput 的討論。如果您是想比對這點對 AlpacaTradingAgent 的 `LatencyTracker` 或 `AnalystScheduler` 的參考價值,這篇論文在這個維度上幫不上忙——它是純粹的「記憶架構品質」研究,不涉及系統效能/延遲面向。

## My Ask： 但是明顯的是 ： 記憶架構品質 優化 和 系統效能/延遲面向 有可能是相反的面向
您說得對,這是一個非常敏銳的觀察,而且論文確實**完全沒有處理這個張力**,包括在它自己的 Limitations 章節裡也沒提到(該章節只講了 episodic memory 無法跨 episode 保留、遊戲環境到真實世界的遷移、scaffold 無法跨環境共用三點,唯獨迴避了成本/延遲面向)。

## 架構上確實存在潛在的反向關係

從論文揭露的機制去反推,至少有三個地方會產生「品質 vs. 延遲」的張力:

**1. 兩階段例程 = 每步至少兩次 LLM 呼叫**
LOG 和 PLAN 是分開的例程,而且訓練後的「記憶專家」還被證實會**更頻繁地搜尋**(consult-before-write discipline)。文件裡強調的是「寫入/搜尋比下降」,但這是比值下降,不代表搜尋的絕對次數下降——事實上論文的敘述暗示的是「多搜尋、少寫入」,也就是**搜尋次數可能不減反增**,只是被更精準地導向「先查再寫」。每一次額外的 SEARCH 都是一次額外的檢索(甚至可能是額外的 LLM 判斷),這在真實部署裡就是延遲。

**2. 雙模型推論架構(memory specialist + gameplay model)**
論文的 inference-time 設計是兩個模型實例共享同一個對話歷史、依序接手(specialist 先處理 LOG/PLAN 的記憶部分,再交棒給 gameplay model 承諾任務動作)。這代表**每一步理論上要跑兩次模型前向傳播**,而不是一次。論文完全沒有報告這個架構對 wall-clock 每步耗時的影響——在遊戲基準測試裡「進度率」是唯一目標,沒有時間預算的概念,所以這個成本被完全忽略了。

**3. Context 縮短的效益是有代價的**
確實,per-step context 縮小了 3–30%,這在推論端會加快(更短的 prompt)。但這個縮減是靠**scaffold 端額外的邏輯**換來的——例如自動同步 inventory/status 檔案、UPSERT 去重判斷、before-craft 材料檢查等。這些「自動化 hint 計算」本身是 scaffold 程式碼在每一步做的**額外運算**,只是不計入 LLM 呼叫次數,所以在論文的評估框架裡「隱形」。

## 這對您的系統設計有直接意義

這正好呼應您在 AlpacaTradingAgent 裡已經在處理的問題:`AnalystScheduler` 用 `asyncio.Semaphore` 綁定 llama-server 的 `-np` slot 數、`LatencyTracker` 動態調整 TTL——本質上就是在管理「多 agent/多次呼叫的記憶與判斷品質」跟「並發吞吐量上限」之間的權衡。AutoMem 論文示範的是「記憶架構品質上限可以怎麼被 meta-LLM 自動優化」,但它是在**無限計算預算、無延遲 SLA**的遊戲評測環境下做的——這在您實際要接 Alpaca 下單、有市場時效性要求的場景裡是不成立的假設。

換句話說:這篇論文證明了「記憶管理是一個獨立可優化的高槓桿維度」,但它刻意(或者說是實驗設計上被迫)把這個維度從「延遲/吞吐量」這個維度中解耦出來單獨最佳化。如果您要把類似的 LOG/PLAN 雙例程、consult-before-write 訓練這套邏輯搬進 `AnalystScheduler` 的 pipeline,勢必要重新引入延遲這個被論文丟棄的約束條件,兩者很可能真的是要做 trade-off,而不是同向優化。

## MyAsk ：",兩者很可能真的是要做 trade-off,而不是同向優化" 對啊！ 我相對對 "單向優化有很大的不確定性。。。
這個懷疑是對的,而且不只是直覺——這類論文的評估設計**結構性地**只能產生「單向優化」的結論,不是因為現實中真的沒有 trade-off,而是因為他們的 benchmark 根本沒有測量會顯現 trade-off 的那個維度。

## 為什麼論文「看起來」是單向優化

這其實是實驗設計的選擇性盲區,不是偶然:

1. **BALROG 的評分函數裡沒有時間項。** Progression rate 只計算「有沒有達成」,不計算「花了多少 wall-clock 時間/多少次 LLM 呼叫達成」。任何會增加呼叫次數但提升準確率的改動,在這個目標函數下永遠是正向的——因為分母(成本)根本不存在於損失函數裡。

2. **Meta-LLM 的優化目標本身就是單目標。** Outer-loop #1 的 gate 條件是「average progression 嚴格優於前一版」,沒有任何懲罰項限制 context 長度、呼叫次數、或延遲。如果 Claude Opus 4.6 發現「多加一次 SEARCH 可以讓進度提升 0.5%」,它沒有理由不加——因為多這一次呼叫在論文的效用函數裡是免費的。

3. **兩個指標朝同一方向移動的案例(context 縮短 3-30%)被拿來當作證據,但這是倖存者偏差。** 論文展示的是「剛好又快又準」的成功案例(UPSERT 去重),但這不代表所有記憶優化都會同時降低 context 又提升準確率。去重之所以雙贏,是因為它砍掉的是**冗餘**資訊——這是少數「品質與效率同向」的特例,不是通則。一旦優化方向變成「多次交叉驗證」「多輪 debate」「更完整的歷史回溯」,就會立刻進入品質與延遲互斥的區域,而論文的三個案例研究剛好都沒踩進這個區域。

## 更根本的問題:評估框架本身排除了會暴露 trade-off 的那類改動

如果 meta-LLM 提出的修訂是「每步先做三次交叉檢查再寫入」,這在遊戲環境裡**完全不會被扣分**,因為沒有 step budget 之外的時間懲罰(NetHack 的 100,000 步上限是動作步數,不是牆鐘時間)。所以你觀察到的「consult-before-write」搜尋次數增加,如果拉長到您的即時交易場景,很可能就是實質的延遲成本——但在論文的框架裡,這個成本完全不可見,自然也就不會出現在任何一張圖表或結論句裡。

## 對您系統的具體含義

這代表如果您想借鏡 AutoMem 的 LOG/PLAN 雙循環或 meta-LLM 審閱軌跡的方法論,**不能直接沿用它的 gate 條件**(只看 progression 是否提升)。您需要在 `AnalystScheduler` 或未來的記憶優化迴路裡,把類似的 gate 改成**多目標**——比如「progression 提升 且 P99 latency 不超過某個閾值」,或用一個聯合分數(accuracy 提升 − λ × 延遲增量)去約束 meta-LLM 的修訂空間。否則就會複製這篇論文的盲點:優化出一個在無限時間預算下很聰明、但在真實下單場景會拖垮 signal-to-execution 延遲的記憶架構。

這也解釋了您先前在 `LatencyTracker` + `SignalDedupTracker` 上做的動態 TTL 設計為什麼是必要的——本質上就是在替 AutoMem 論文完全沒做的那個維度(延遲約束)補上一個顯式的懲罰項。

# MCP Auto MEM
是的，完全可以使用 MCP（Model Context Protocol，模型上下文協定） 的方式來完美落地 AutoMem 的記憶框架。
這是目前在工程上最優雅、解耦最徹底的實作方式。使用 MCP，您可以將「記憶管理」做成一個獨立的 MCP Server，而您的 Agent 或 IDE 插件（如 Cline、Cursor）作為 MCP Client。這樣可以完美地將記憶操作「工具化」，並與任務邏輯分離。
以下是使用 MCP 實作 AutoMem 雙循環邏輯的架構與具體步驟：
------------------------------
## 🧱 1. 設計 AutoMem MCP Server (定義工具與資源)
您需要用 Python 或 TypeScript 撰寫一個 MCP Server，向 LLM 暴露以下三個核心功能（Tools, Resources, Prompts）：
## 🛠️ Tools：記憶的「主動動作」
在 MCP Server 中註冊以下工具，供 Agent 在需要時自主呼叫：

* 
* mem_write(topic, key, value)：寫入或更新結構化記憶檔案（例如：mem_write(topic="env_config", key="database_port", value="5432")）。
* mem_append_log(topic, message)：在特定主題的日誌末尾追加時間戳記與新事件。
* mem_search(query)：對所有記憶進行關鍵字或向量（RAG）檢索。
* 

## 📄 Resources：記憶的「上下文快照」
MCP 的 Resources 允許 Client 將靜態或動態數據直接掛載到 LLM 的上下文中。

* 
* 您可以將當前任務的核心記憶文件（如 memory://current_goals.json）註冊為 Resource。
* 當 Agent 呼叫工具修改記憶時，MCP Server 會動態更新此 Resource，確保 Agent 隨時能看到最新的「記憶全景圖」。
* 

## 📝 Prompts：動態注入 LOG 與 PLAN 範本
MCP 允許 Server 提供標準的提示詞範本。您可以設計一個名為 automem_reflection 的 Prompt：

* 
* 內容：「請檢視上一步的結果。調用 mem_write 或 mem_append_log 更新你的記憶庫。然後檢視 memory://current_goals.json 資源，決定下一步。」
* 

------------------------------
## 🔄 2. 透過 MCP 實作雙循環優化
有了 MCP 協定，AutoMem 的雙循環（Dual-Loop）在工程上會變得非常清晰：
## 🔄 循環一：架構修訂（Scaffold Revision）

   1. 日誌收集：MCP 協定自帶標準的 logging 機制。Client 端可以輕鬆導出 Agent 與 MCP Server 互動的完整 Trace（包含 Agent 呼叫了哪些 mem_ 工具、寫了什麼、結果發生什麼錯誤）。
   2. 架構更新：將失敗的 MCP 互動日誌丟給 Meta-LLM（如 Claude 3.5 Sonnet）。如果它發現 Agent 常常因為 mem_write 的欄位太雜亂而失敗，Meta-LLM 會直接重寫 MCP Server 的工具定義（Tools Schema）或優化 Prompts 範本，實現記憶基建的自動修訂。

## 🔄 循環二：熟練度訓練（Proficiency Training）

   1. 數據過濾：從 MCP 日誌中篩選出成功完成任務的 Trace。
   2. 行為蒸餾：萃取「User Prompt -> LLM 決定呼叫 mem_search -> 獲得 Memory Resource -> 做正確決策」的這段 MCP Tool Call 對話對。
   3. 微調小模型：用這組 MCP 格式的工具調用數據，微調您的開源小模型（如 Qwen2.5 或 Llama3），讓小模型生來就精通這套 MCP 記憶協定。

------------------------------
## 💻 3. 實戰程式碼範例 (Python MCP Server)
以下是使用 Python MCP SDK 實作 AutoMem 記憶工具的偽代碼：

from mcp.server.fastmcp import FastMCPimport jsonimport os
# 初始化 AutoMem MCP 服務app = FastMCP("AutoMem-Storage")MEMORY_DIR = "./agent_memories"

@app.tool()def mem_write(topic: str, key: str, value: str) -> str:
    """當前步驟結束後（LOG流程），若發現重要規則、變數、或階段性成果，
    請主動呼叫此工具，將資訊結構化寫入記憶中。"""
    os.makedirs(MEMORY_DIR, exist_ok=True)
    filepath = os.path.join(MEMORY_DIR, f"{topic}.json")
    
    # 讀取現有記憶
    data = {}
    if os.path.exists(filepath):
        with open(filepath, "r") as f:
            data = json.load(f)
            
    # 更新記憶
    data[key] = value
    with open(filepath, "w") as f:
        json.dump(data, f, indent=2)
        
    return f"成功更新主題【{topic}】的記憶：{key} = {value}"

@app.resource("memory://{topic}.json")def get_memory_snapshot(topic: str) -> str:
    """提供 Agent 當前特定主題的完整記憶結構。
    在 PLAN 流程開始前，請先檢視此資源以獲取歷史上下文。"""
    filepath = os.path.join(MEMORY_DIR, f"{topic}.json")
    if os.path.exists(filepath):
        with open(filepath, "r") as f:
            return f.read()
    return "{}"
if __name__ == "__main__":
    app.run()

------------------------------
## 🎯 總結：為什麼 MCP 是最佳解？

   1. 零摩擦接入主流工具：一旦您寫好這個 MCP Server，您可以直接把它掛載到 Cline (VS Code 插件) 或 Cursor 中。這些現成的 Agent 就會立刻學會「自己寫筆記、自己查歷史」的 AutoMem 能力。
   2. 標準化數據流：MCP 的 Tool Call 與 Resource 格式是標準化的，這讓您在收集「雙循環優化」所需的微調數據（Fine-tuning Dataset）時，格式完全統一，不需要撰寫複雜的日誌解析器。

您目前是打算將這個記憶機制整合到日常開發的 IDE Agent（如 Cline/Cursor）中，還是您正在從零使用 Python/TypeScript 自建一個獨立的 Agent 系統呢？我們可以根據您的場景來決定 MCP Server 的部署方式。

