---
layout: post
title: Everpure：為 Flash 重新設計一切的工程師公司
subtitle: 從「Flash Chasm」到 KV Cache 時代——Pure Storage 十五年的技術積累，正在找到最大的用武之地
cover-img: /assets/img/header/2026-05-12/EVERPURE.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-12/EVERPURE.png
published: true
pinned: true
tags: [draft, Everpure, PureStorage, DataCenter, SSD, AI基礎設施, KVcache, DirectFlash, EMC, 企業儲存]
---


# Everpure：為 Flash 重新設計一切的工程師公司

> 美國企業 AI 系列第一篇——Everpure × SanDisk × DataCenter TCO · May 2026
> 涵蓋主題：Pure Storage 品牌重塑、創辦人工程文化、Flash Chasm、EMC 訴訟戰、DirectFlash 架構、KV Cache 臨界點、Agentic AI 儲存需求

---
```
核心訊息

Everpure 不是一家儲存公司碰巧趕上了 AI 浪潮。
它是一家十五年來始終在做同一件事的工程師公司：
為新的儲存媒體重新設計整個堆疊，而不是把新媒體貼在舊架構上。

Flash Chasm 是它的起點——磁碟時代的企業儲存架構根本不適合 flash。
KV Cache Chasm 是它的下一個戰場——傳統陣列架構根本不適合 Agentic AI 推論。
兩個機會的結構完全相同，而 Everpure 是唯一一家用同樣方法論打過第一場的公司。

這不是運氣，是工程師文化的複利。
```
---

## 引言：2026 年 2 月的一個品牌決定

2026 年 2 月，Pure Storage 宣布更名為 Everpure，NYSE 代碼維持 PSTG 不變。

多數財經媒體把這當成行銷事件報導，然後繼續追蹤 NVIDIA 的 GB300 和 OpenAI 的最新估值。但如果你願意花時間把 Everpure 這十五年的故事從頭讀一遍，你會發現這個品牌重塑不是終點，而是一個工程師公司終於被市場讀懂的節點。

故事要從 2009 年的一個問題開始：**如果你要為 flash 重新設計企業儲存，你會從哪裡開始？**

---

## 零、那個問題是怎麼被問出來的

### Sutter Hill 辦公室裡的一個下午

2009 年，在 Palo Alto 的 Sutter Hill Ventures 辦公室裡，兩個人決定用一個問題開始一家公司：

> **「如果你不受任何歷史包袱的約束，你會怎麼設計企業儲存？」**

這家公司最初以代號 Os76 Inc. 在 Sutter Hill Ventures 的辦公室內成立，由 John "Coz" Colgrove 和前 Yahoo! 技術長 John Hayes 共同創辦。

Colgrove 帶來的是二十年的儲存工程深度——他是 Veritas Storage Foundation 的創始工程師，450 項儲存相關專利的持有人，對企業儲存的每一個技術細節都了如指掌，包括它的每一個歷史包袱。Hayes 帶來的是完全不同的視角——Yahoo 的規模化工程思維，對大型分散式系統的直覺，以及對「儲存應該怎麼運作」這件事毫無先入為主的假設。

他們目標明確：把消費級 NAND 的成本經濟學和現代軟體思維，帶進企業儲存——解決 HDD 時代遺留的複雜性和延遲問題。

### 2009 年的技術現實

MLC flash 技術的進步，讓固態硬碟的成本降低到足以在消費性電子產品中取得競爭力。消費級 flash 的普及，意味著這個技術已準備好被推向下一個層次——企業全快閃儲存陣列。

但橫在這個願景前面的，是一個具體的工程障礙：

2009 年的 flash 硬碟只能支撐 10,000 次讀寫循環——對於企業資料中心處理的工作負載類型來說，這個記憶體耐用性根本不夠。

10,000 次看起來是個大數字，但在企業儲存的語境裡，這是災難性的不足——一個繁忙的企業資料庫工作負載，可以在數週內就把這個次數耗盡。這是整個 flash 企業化的最大瓶頸，也是 EMC、NetApp 等在位者選擇「混合陣列」路線而不敢全押 flash 的根本原因。

### 他們選擇的解法

面對耐用性問題，有兩條路：

**容易的路**：和其他廠商一樣，用 HDD 做主儲存、flash 做快取層，讓 flash 的讀寫次數分散、壓力降低。EMC 走了這條路，NetApp 走了這條路，HP 走了這條路。

**困難的路**：從零開始，為 flash 媒體的物理特性重新設計一整個軟體堆疊——把損耗管理、資料縮減、壽命延長的邏輯全部放進作業系統層，讓 flash 的每一次讀寫都被精確調度，而不是浪費在 FTL 的低效轉換上。

對 Pure Storage 來說，他們永遠選擇那座困難的山（take the hard hill），第一次就把技術做對。

他們從一個雙層軟體架構出發：下層專注於優化物理儲存媒體的效能、可靠性和壽命；上層處理儲存管理的系統層任務，包括虛擬化、與主機的通訊、資料縮減、內部 I/O 排程、RAID 保護和整體陣列管理。

### 兩年的隱身期

從 2009 年到 2011 年，公司在隱身模式中運作，專注於開拓全快閃儲存技術——這個開發強調的是一個為 flash 優化的架構，旨在克服傳統磁碟式企業儲存系統在效能、密度和耐用性上的固有限制。

這兩年，是 Colgrove 的工程信念與商業現實對賭的時間窗口。外部世界看不到他們在做什麼。EMC 和 NetApp 的銷售員繼續拜訪同樣的客戶，銷售同樣的混合陣列。

當 Pure Storage 在 2011 年底走出隱身模式時，企業儲存市場由在旋轉磁碟技術上建立起財富的公司主導。EMC、NetApp、IBM 和 HPE 都在推出混合陣列，在 flash 和傳統硬碟之間搭配，對全快閃系統的不確定經濟性進行對沖。Pure 的創辦人採取了完全不同的看法。Colgrove 看到了他所說的 flash 密度和成本曲線的「指數級改善」，確信 flash 很快就會「消滅企業資料中心的所有硬碟」。他們選擇不做過渡性產品，而是直接設計一個完全為 flash 優化的架構。

這個賭注，在 2011 年仍然是一個小數人相信的信念。但 Colgrove 有數學支持他——flash 的成本曲線正在以可預測的速度下降，而他的軟體堆疊正是為了在這條曲線到來時，成為最大的受益者而設計的。

---

## 一、2009 年的「Flash Chasm」

### 當時的世界

2009 年是一個特殊的時間點。VMware 的虛擬化已經成為企業標準，工作負載整合密度大幅提升，但儲存效能成了瓶頸。雲端運算開始獲得市場關注，資料放置和管理的複雜度急劇上升。SAN（Storage Area Network）在大型企業中已經無所不在，甚至開始滲透中小企業。

但企業儲存市場的主要玩家——EMC、NetApp、HDS、IBM——仍在銷售 25 到 35 年前設計的架構。他們把新功能貼在舊平台上，期待客戶接受這些妥協。

與此同時，MLC flash 技術的成本開始讓固態儲存在消費性電子產品中取得競爭力。但企業級儲存架構根本不是為 flash 設計的——它的每一層都假設了機械磁碟的物理特性：循序讀寫優先、隨機 I/O 代價高昂、延遲以毫秒計。

這個落差，就是 Colgrove 和 Hayes 後來稱之為「Flash Chasm」的裂縫：**flash 媒體已經存在，但企業儲存的架構世界還活在磁碟時代。**

### 兩個創辦人，兩種背景

John "Coz" Colgrove 在 Veritas Software 做了超過二十年的儲存技術，持有超過 450 項電腦系統和可靠數據儲存設計專利。他深刻理解企業儲存的每一個技術細節，包括它的每一個歷史包袱。

John Hayes 是 Yahoo 的 CTO，來自大規模網路服務的世界——那個世界的第一直覺是軟體、API、規模化，而不是硬體規格和銷售週期。

兩人在 Sutter Hill Ventures 的辦公室裡成立了 Os76 Inc.，帶著 500 萬美元的初始資金，開始做一件他們認為整個產業都做錯了的事。

### 最關鍵的招募決策

創業初期，Colgrove 做了一個反直覺的決定：**他們刻意不招聘有企業儲存背景的工程師。**

> 「如果你不知道一件事是怎麼被做的，你就拿著問題去解決它，而不是去想別人是怎麼解決的。」

他們從 Yahoo、Google、消費性科技公司招募工程師——這些人對 HDD 的物理特性沒有先入為主的假設，對磁碟時代的 RAID 設計也沒有路徑依賴。他們把 flash 的問題當成一個純粹的工程問題來解決。

這個決定的結果，就是 DirectFlash Module。

---

## 二、DirectFlash：繞過一整個產業的架構錯誤

### 傳統 SSD 的原罪：FTL

要理解 DirectFlash 的意義，必須先理解 FTL（Flash Translation Layer）是什麼，以及它為什麼是傳統 SSD 的原罪。

flash 媒體的物理特性和磁碟完全不同：它不能直接覆寫，必須先清除再寫入；清除操作是以「區塊」為單位，比讀寫操作大得多；每個 cell 有寫入次數限制，過度使用會縮短壽命。

傳統 SSD 在 flash 媒體上加了一層 FTL 控制器，讓作業系統以為自己在對磁碟說話——FTL 在中間做轉換、做損耗平衡（wear leveling）、管理 garbage collection。這讓 SSD 可以直接替換 HDD，不需要改變上層軟體。

但代價是：**FTL 引入了不可預測的延遲抖動（jitter）、write amplification（實際寫入量遠大於邏輯寫入量）、以及大量的計算開銷。**

在大多數工作負載下，這個代價是可接受的。但在 AI 推論的 KV Cache 工作負載下——高度隨機的小 I/O、對延遲一致性要求極高——FTL 的代價是結構性的缺陷。

### DirectFlash 的解法

Everpure 的 DirectFlash Module（DFM）選擇了一條更難走的路：**把 FTL 的邏輯從設備層移到系統層，讓 Purity 作業環境直接管理 NAND flash 的物理特性。**

這意味著：
- 去掉 SSD 控制器的 FTL，直接在原始 NAND 上操作
- 損耗平衡、garbage collection、壞塊管理全部由 Purity OS 在系統層統一調度
- 系統可以跨多個 DFM 做全局優化，而不是每個設備各自為政

結果是：
- 比同等容量的商品 SSD 高出 2 到 3 倍的儲存密度
- 功耗約為傳統 SSD 的一半
- 延遲一致性（低 jitter）遠優於 FTL 架構的 SSD
- 有效 IOPS 遠高於商品 NVMe SSD

這不是調參數的優化，是把問題的邊界重新定義——把設備層的問題拉到系統層解決，獲得跨設備的全局最優解。

---

## 三、EMC 的訴訟：一場代差戰爭的法律版本

### 44 名工程師

2013 年，EMC 起訴 Pure Storage 和其 44 名前 EMC 員工，指控竊取智慧財產。Pure Storage 反訴，指控 EMC 非法取得其儲存設備進行逆向工程。

這場官司在 2016 年以 Pure Storage 支付 3,000 萬美元達成和解告終。

表面上是 IP 糾紛，但更值得關注的是那個數字：**44 名前 EMC 工程師**。這不是偶然的人才流動，這是 EMC 內部最清楚技術走向的工程師，用雙腳投票告訴市場他們認為誰站在正確的一側。

EMC 選擇起訴，而不是加速自己的 all-flash 轉型——這個選擇本身就說明了它在這場技術代差戰爭中的戰略困境：它的商業模式（高利潤的維護合約、複雜的銷售週期、客戶的架構鎖定）和全面轉向 flash 的利益是衝突的。

### 逆向工程的故事

Pure Storage 的反訴指控 EMC 非法取得其儲存設備進行逆向工程——這個細節很耐人尋味。它說明 EMC 並不是不懂 Pure Storage 在做什麼，而是選擇了用法律手段拖延，而不是用技術手段超越。

這是科技產業競爭中的一個反覆出現的模式：當一個在位者看不到自己在正面競爭中贏的路徑，它會轉向法律、轉向銷售關係、轉向客戶鎖定——任何不需要根本性架構重寫的手段。

---

## 四、Purity OS：軟體優先的工程哲學

### 不是硬體公司

Everpure 的一個核心定位是常被誤解的：它不是一家銷售 flash 硬體的公司，它是一家把軟體智慧放進儲存系統的公司。

Purity 作業環境的設計哲學從第一天起就是 API-first：
- 所有功能對外暴露乾淨的 API，最大化與其他資料中心服務的整合可能性
- 磁碟選擇、LUN 遮蔽和分區、控制器卷分配等基本功能全部自動化
- 資料韌性採用獨特方案，避免傳統 RAID 奇偶條帶的剛性——消除了因媒體損壞重建時間引發的顧慮

這個 API-first 設計，在 AI 基礎設施時代成了結構性優勢。LangGraph、Temporal 這些 orchestration 框架要整合儲存層，需要的正是乾淨的程式接口，而不是需要儲存管理員手動配置的傳統介面。

### Evergreen：商業模式的工程化

2015 年推出的 Evergreen 訂閱模型，是把工程哲學延伸到商業模型的嘗試：客戶購買的不是一台會過時的硬體，而是一個永遠保持最新狀態的儲存平台。

硬體和軟體可以無中斷升級，不需要資料遷移、不需要停機視窗——這個承諾的背後，是 Purity OS 和 DirectFlash 從第一天起就被設計為支援非破壞性硬體替換的架構決定。

到 2026 年初，Everpure 的訂閱 ARR 達到 18 億美元，年增 17%——這是企業客戶對這個商業模型用錢投的票。

---

## 五、KV Cache Chasm：歷史再次重演

### 同一個問題，第二次

Agentic AI 正在創造一個新的技術落差，和 2009 年的 Flash Chasm 在結構上幾乎完全相同：

```
2009 年的 Flash Chasm：
  新媒體（NAND flash）已經存在
  但企業儲存架構是為磁碟設計的
  → 在位者：把 flash 貼在磁碟架構上（hybrid array）
  → Everpure：為 flash 重新設計整個堆疊

2025–2026 年的 KV Cache Chasm：
  新工作負載（Agentic AI 推論 KV cache）已經存在
  但現有儲存方案是為傳統資料庫/備份設計的
  → 在位者：把 NVMe SSD 貼在既有陣列架構上
  → Everpure：DirectFlash 繞過 FTL，為這個 workload 重新設計
```

### KV Cache 的物理現實

要理解為什麼這個問題非 Everpure 的架構不可，需要了解 KV Cache 作為儲存工作負載的物理特性：

當大型語言模型生成每一個 token，它需要讀取 context window 中所有先前 token 的 Key-Value 對。對於 Llama-70B 這樣的模型，每個 token 產生約 2.6 MB 的 KV cache：

```
KV cache / token (Llama-70B)
= 2 × d_head(128) × n_heads(64) × n_layers(80) × 2 bytes
= 2.6 MB / token

Context window 長度 vs 所需記憶體：
  128K tokens → 333 GB   （超過 4 張 H100 的 HBM 總量）
  200K tokens → 520 GB   （Agentic session 的典型大小）
  1M  tokens → 2.6 TB    （必然溢出至 SSD，無例外）
```

一旦 context window 超出 GPU 的 HBM 容量，KV cache 就必須存放在 SSD 上，而每次生成 token 都需要從 SSD 讀取——這個 I/O 直接在推論的 critical path 上。

這個工作負載的特性：
- **高度隨機的小 I/O**：每次 token 生成讀取特定位置的 KV 對
- **對延遲一致性要求極高**：jitter 直接影響推論速度的穩定性
- **高並發**：同時進行的多個 agent session，各自有獨立的 KV cache

FTL 架構的商品 SSD，在這個工作負載下有結構性缺陷：write amplification、garbage collection 引發的延遲抖動，在高並發推論場景下會直接降低 GPU 利用率。

DirectFlash 繞過 FTL、在系統層直接管理 NAND 的設計，是目前市場上唯一成熟的解法。

### 數字說話

Everpure 的 FlashBlade//S500 在 IO500 測試中達到 142.32 的複合分數，約是同類 DDN 方案的兩倍。在 AI 訓練場景中，這個效能差距使 GPU 利用率達到 85–98%，與傳統儲存相比將訓練時間縮短 50–70%。

這個兩倍的效能差距，不是來自更好的採購談判或更便宜的 NAND——它來自 Colgrove 的 450 個專利和十五年「為 flash 重新設計一切」的工程積累。

---

## 六、Everpure vs SanDisk：不是競爭，是不同的問題

### 兩個完全不同的商業模式

理解 Everpure 和 SanDisk 在 AI 基礎設施競爭中的角色，必須先認清它們根本不在同一個市場：

| | SanDisk | Everpure |
|---|---|---|
| **產品** | NAND flash 晶片、商品 SSD | 全快閃陣列 + Purity OS + 訂閱服務 |
| **競爭軸線** | 每 GB 成本、供應量 | 推論延遲、I/O 一致性、TCO |
| **採購決策者** | 採購部門、供應鏈 | ML infra 工程師、CTO |
| **收入模式** | 元件交易、週期性 | 多年訂閱、ARR 複利 |
| **AI 受益機制** | 總需求量增加 → 現貨價格上漲 | KV cache workload → 性能需求 → 平台採用 |

SanDisk 在 AI 推動的 NAND 需求爆發中獲益——過去一年股價上漲超過 1,500%，是供需失衡帶來的週期性紅利。

Everpure 的機會不是「需要更多 SSD」，而是「需要那種 SSD 能穩定在推論 critical path 上」——這個需求的採購決策由工程師做，評估標準是延遲、一致性、系統整合，而不是價格清單。

### NAND 成本下降是 Everpure 的順風，不是逆風

一個值得注意的非直覺邏輯：NAND flash 成本每年約下降 20%，這對 SanDisk 是利潤壓縮的壓力，對 Everpure 卻是原料成本降低的順風。

Everpure 的毛利來自 Purity OS 的軟體智慧和 DirectFlash 的系統架構，不來自 NAND 晶片本身。當 NAND 更便宜，Everpure 的系統可以在相同成本下提供更多容量——TCO 論述因此持續強化。

### 三變量視覺化：轉折點在哪裡

讀完上面的比較，下圖把電力、記憶體與 Token 產出三個變量的相關性結構，收攏成一張圖：

![三變量轉折點預測圖](/assets/img/charts/everpure-pivot-chart.svg)

三條曲線各自說一件事：

**電力（藍線）** 是通用基準——線性、無條件，對兩家公司都無差別。每一個 token 都要燒電，這是物理定律，不是競爭優勢的來源。

**商品 SSD（灰色虛線）** 是 SanDisk 的主場——整條曲線穩定成長，臨界點前後邏輯不變，因為無論 Agentic AI 的 context 長不長，模型權重、訓練數據、備份仍然持續產生商品 NAND 需求。

**企業級 SSD（綠線）** 是圖表的核心。臨界點左側幾乎是平的（r ≈ 0.30）——在這個區間，ML 工程師的儲存決策和 Everpure 幾乎沒有關係；越過臨界點之後，曲線開始指數加速（r ≈ 0.88）——每一個新增的 Agentic session 都在推論 critical path 上產生企業級 SSD 的 I/O 需求，而這個需求的延遲一致性要求，商品 SSD 架構無法穩定滿足。

**紅色實心圓點（Pivot Point）** 是整張圖的答案：KV cache 溢出 HBM 的那一刻，不是市場認知的轉變，是物理條件達到後的必然。Q4 2026 藍色區間位於轉折點右側——這個預測成立的前提，正在每一個月的 Agentic AI 企業採用報告中被悄悄驗證。

---

## 七、工程師文化的複利

### 「接受難的那座山」

Everpure 在回顧十五年歷史時，用了一個詞來描述自己的決策哲學：**take the hard hill**——接受最困難的那條路。

2009 年，最容易的選擇是做一個混合陣列：在磁碟架構上加 flash 快取層，相容現有的管理工具和銷售流程。EMC、NetApp、HP 都走了這條路。

Pure Storage 選擇了更難的路：從零開始設計一個為 flash 優化的作業系統，建立自己的 flash 管理硬體，拒絕向磁碟時代的設計假設妥協。

這個選擇在初期代價極高——它花了三年才有第一個商業產品，花了更長時間才讓市場相信全快閃陣列的 TCO 真的低於磁碟方案。但它換來的是一個其他公司無法用錢快速複製的技術堆疊。

### 軟體優先的組織設計

Everpure 一個不常被討論的特點是它的「startup within a startup」研發模式：有一個專門的內部團隊，做的工作是開發最終會交付給客戶的產品，而不是停留在研究階段的概念。

這個設計讓工程創新和產品交付的距離保持最短，避免了大公司常見的「實驗室和產品線脫節」問題。DirectFlash 從概念到交付、Purity OS 的持續演進、FlashBlade 的推出，都是這個模式的產物。

---

## 八、推論市場的 Flash 需求：完整結構框架

經過前七章的分析，可以把整個 flash 儲存在 AI 推論市場的需求結構，收攏成一個可追蹤、可量化的框架。

### 需求的三條獨立向量

Flash 在 AI 推論生態中，同時存在三條結構上互不依賴的需求向量：

```
向量一：雲端推論 KV Cache（Everpure 的戰場）
  驅動公式：PR(t) = [S × C × κ(arch)] / [N × H × α]
  性質：有閾值，越過才爆發
  主要受益者：企業級 NVMe 陣列（Everpure/WEKA）

向量二：本地推論 KV Cache Swap（SanDisk 的戰場）
  驅動公式：PR_local = [model_size + C_local × κ] / local_DRAM
  性質：穩定連續，不需要閾值
  主要受益者：消費級/專業級 NVMe SSD（SanDisk/Samsung）

向量三：本地模型庫儲存（MLA 無法壓縮）
  驅動公式：Users_local × avg_models × avg_model_size
  性質：MLA 不影響此項，純容量成長
  主要受益者：SanDisk——每個本地 LLM 用戶的持續底座需求
```

這三條向量的關鍵結構差異在於：**向量一需要越過閾值才爆發，向量二和三是連續成長的底座需求**。SanDisk 同時受益於向量二和三，而且不需要任何閾值條件；Everpure 的機會集中在向量一，但單次爆發規模最大。

### Everpure Pivot Ratio（PR）預測模型

```
核心公式：
  PR(t) = [S(t) × C(t) × κ(arch,t)] / [N(t) × H(t) × α(t)]

  PR > 1：Everpure 進入推論 critical path
  PR < 1：HBM 仍可覆蓋，SanDisk 商品邏輯主導

變量軌跡：
  S(t)  並發 sessions    → 指數成長（Agentic 採用）
  C(t)  平均 context     → 成長但趨緩（use case bound）
  κ(t)  KV/token        → 下降（MLA 普及）← 主要減速力
  N(t)  推論 GPU 數      → 指數成長（CapEx）
  H(t)  HBM per GPU     → 每代翻倍（~2 年週期）
  α(t)  可用 HBM 比例   → 緩慢改善

情境演算：
  2026 Q2（現在）  PR ≈ 0.09   SanDisk 主場
  2026 Q4         PR ≈ 0.40–0.59  臨近但未越過（κ 仍是 GQA）
  2027 H2         PR ≈ 0.30–0.50  MLA 驗證，分母擴大
  2028+           PR ≈ 1.1+   S 規模效應主導，越過閾值
```

### 三層減速因子的時序分析

MLA 是目前最常被提及的 Everpure 減速因子，但它不是「實體層」的力量：

```
減速因子分類          作用位置      PR 公式欄位   生效時間

實體層（供給側擴張）
  HBM 容量成長        分母 H(t) ↑   N×H×α       每代（~2年）
  NVLink 帶寬提升     分母 α(t) ↑   N×H×α       每代（~2年）

架構層（需求側壓縮）
  MLA（93.3% KV縮減） 分子 κ(t) ↓   S×C×κ       2027 H1 驗證完成
  GQA/MQA             分子 κ(t) ↓   S×C×κ       已生效（現在）
  KV 量化（INT4）     分子 κ(t) ↓   S×C×κ       2026–2027

系統層（效率提升）
  PagedAttention      分母 α(t) ↑   α 間接改善  已生效
  Prefix caching      分子 C(t) ↓   有效 C 縮減 已生效

規模層（驅動力）
  Agentic 用戶增長    分子 S(t) ↑   S×C×κ       無上限
  持續使用（長 session）分子 S×C 同升 S×C×κ    Agentic 主流化後
```

**MLA 的關鍵限制**：它是一次性的架構紅利，有信息論下界（~71 KB/token）。一旦產業完成向 MLA 的遷移，κ 穩定在新平台，S 的指數增長就重新主導 PR 方向。MLA 把 Everpure 的轉折點推遲，但不取消。

### 空窗期：MLA 驗證前的不確定區間

```
Everpure pivot 最早可能窗口：2026 Q4
MLA 作為減速器完整生效時間：2027 H1

空窗期：2026 Q4 — 2027 H1（約 6 個月）

在這個空窗期內：
  κ 仍接近 GQA 水準（~450 KB），MLA 滲透率僅 20-30%
  若 Agentic S 在此期間超預期增長
  → PR 有可能在 MLA 完整減速之前就越過 1
  → 這是 Everpure 最早、最快的 pivot 情境
```

### 可追蹤的先行指標

```
每季監測項目                    對應變量         來源

全球 Agentic AI 日活用戶        S(t) 代理指標    Andreessen/a16z 報告
平均 AI session 持續時間        S×C 乘數         產品分析工具
主流模型 MLA 採用率（%）        κ(arch,t) 估算   Hugging Face 模型統計
GB200/VR NVL72 出貨量           H(t) 更新        NVIDIA 法說會
NVIDIA Dynamo 生產案例數        α(t) 間接訊號    NVIDIA partner 公告
Everpure 超大規模客戶合約       市場驗證 PR>1    Everpure 法說會
WEKA Token Warehouse 部署數     競爭威脅追蹤     WEKA/NVIDIA 聯合公告
```

### 最終結構判斷

```
SanDisk 的 alpha 來源：
  位置優勢——坐在需求衝擊最前端
  不需要 PR > 1，三條向量都在成長
  週期性（供需失衡 → 量價齊升）
  風險：MLA 壓縮 κ，長期毛利空間收窄

Everpure 的 alpha 來源：
  臨界點優勢——PR > 1 後進入無可替代的位置
  NVIDIA NVCF 官方合作夥伴名單
  DirectFlash 的無 FTL 架構是 KV cache workload 的結構性適配
  風險：WEKA 在 NVIDIA 生態中的更深整合

兩者的關係：
  不是零和競爭，是不同閾值條件下的順序收益
  SanDisk 先行受益（現在到 2027）
  Everpure 後發爆發（PR > 1 的時刻，估計 2027–2028）
  本地推論成長是 SanDisk 的 MLA-proof 底座
  雲端 Agentic 規模化是 Everpure 的一次性重新定價事件
```
---

## 結語：Flash Was Only the Beginning

Everpure 的創辦人書名叫做《Flash Was Only the Beginning》。現在回頭看，這句話比他們當時想像的更精準。

Flash 是起點——它讓 Everpure 有機會證明「為新媒體重新設計架構」這個方法論是對的。十五年的工程積累，讓 DirectFlash、Purity OS、Evergreen 訂閱形成了一個完整的技術和商業護城河。

Agentic AI 的到來，讓這個積累第一次面對了一個真正和它等量級的需求：**數以億計的 agent session，每個都需要在 SSD 上維護數十萬 token 的 KV cache，對延遲一致性的要求比任何傳統企業儲存工作負載都高。**

EMC 在 2009 年面對 Flash Chasm 的時候，選擇了起訴對手、保護舊有利益。Dell EMC 的繼承者在 2025 年面對 KV Cache Chasm 的時候，大概也會有類似的選擇空間——和 Everpure 在系統架構上正面競爭，或是繼續靠銷售關係和維護合約維持市場份額。

Everpure 的答案已經在那 450 個專利、那個 API-first 的 Purity OS、那個被刻意設計為「不知道磁碟是什麼」的工程師團隊裡了。

Flash was only the beginning. KV cache is the next one.

---

> 📌 **美國企業 AI 系列索引**
> 1. **本篇：Everpure——為 Flash 重新設計一切的工程師公司**
> 2. [AI-Native WAN：NaaS、Cloud WAN 與 Cloud Exchange 的網路主權爭奪戰](/2026-05-14-ai-native-wan) *(即將發布)*
> 3. [Cerebras——把整片晶圓變成一顆晶片的工程師賭注](/2026-05-14-cerebras-wafer-scale)
> 4. [Token 計價革命——SRAM、HBM、Flash 決定了一切](/2026-05-14-token-pricing-revolution)
