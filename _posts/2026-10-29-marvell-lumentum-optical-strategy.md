            ---
layout: post
title: Marvell 洽購 Lumentum 把光路從雷射到記憶體池一次收齊
subtitle: how it works從 Celestial AI XConn到LITE拆解Marvell的五條戰略線
cover-img: /assets/img/header/2026-04-18/QUANTUM.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-18/QUANTUM.png
published: true
pinned: true
mathjax: true
tags: [draft, spaceX]
---


10 月 28 日，Bloomberg 報導 Marvell 正與資料中心光學元件廠 Lumentum（LITE）進行深度談判，最快下週就可能宣布。消息出來後，LITE 盤後大漲約 11%，Marvell 單日下跌逾 8%。

先把前提講清楚。這筆交易還沒簽約，報導裡的 830 億美元是 Lumentum 目前的市值，不是成交價，溢價多少沒有人知道。Marvell 自己的市值約 2,210 億美元，帳上現金只有 39.2 億美元，所以對價幾乎只能靠換股，這也大致說得通它的股價為什麼挨了一刀。雙方都沒有公開說明收購動機，下文凡是我的推論，都會標明「推論」。

## 先看全貌：五條戰略線

把 Marvell 過去一年的動作攤開，會發現它在補的是同一件事：AI 叢集從銅線轉向光的時候，每一個需要光的節點，都要有一塊自己的矽或元件。Celestial AI 補了晶片上的光 I/O，XConn 補了記憶體交換，Lumentum 如果成交，補的是光源與光模組本身。

先看總圖。下圖把 Marvell 與兩家已併購公司、一家洽購中的公司，放回它們在 AI 機櫃裡的實際位置，由左到右是封裝內、機櫃內、跨機櫃三個尺度。圓圈裡的數字，對應後面五條戰略線。

![總圖：Marvell 與併購標的的位置](/assets/img/header/2026-10-29/marvell-lite-00-master-map.svg)

圖上橘色虛線的那幾格，就是目前 Marvell 手上沒有、Lumentum 能補上的部分：光源、收發模組與光交換。同一批方塊，換成分層的看法如下：

![Marvell AI 互連版圖](/assets/img/header/2026-10-29/marvell-lite-01-stack.svg)

| 戰略線 | Marvell 的動作 | 目前狀態 | Lumentum 補哪一格 |
|---|---|---|---|
| 一、光 I/O 上 die | 收購 Celestial AI | 已交割，營收 FY28 下半年起算 | 光源（推論） |
| 二、記憶體解耦與分層 | Structera CXL + XConn + 光學池化 | CXL 已出貨，光學池化待量產 | 間接 |
| 三、協定中立 | UALink／ESUN 交換 + NVLink Fusion | 同步布局 | 無直接關係 |
| 四、光層垂直整合 | 洽購 Lumentum | 深度談判，未簽約 | 雷射、收發、OCS |
| 五、客製 XPU 掛載 | 以客製晶片為入口，附掛各項內容 | 進行中 | 光收發與光源 |

## 一、光 I/O 上 die：Celestial AI

**做了什麼。** Marvell 在 2025 年 12 月宣布收購 Celestial AI，交易價 32.5 億美元，含 earnout 最高約 55 億美元，2026 年 2 月完成交割。Celestial 的 Photonic Fabric 把光 I/O 做成 chiplet，直接和 XPU、scale-up 交換器共同封裝。公司公布的規格是單顆 chiplet 單向 16 Tbps，單一封裝可到 64 Tbps 雙向。

![Photonic Fabric 光 I/O](/assets/img/header/2026-10-29/marvell-lite-02-photonic-fabric.svg)

**為什麼重要。** 電氣 I/O 的頻寬受限於晶片邊緣的長度，邊緣就那麼長，SerDes 再快也有上限。光 I/O 可以從封裝內部出光，繞開這個限制。Marvell 在分析師日釋出的訊息是，已有一家頂級雲端業者選定這套方案用於下一代 XPU 的 scale-up 網路。

**時間點很晚。** 公司給的營收目標是 FY28 下半年起貢獻，Q4 FY28 年化 5 億美元，Q4 FY29 年化 10 億美元。換句話說，這條戰略線的錢在一年多之後才進來，現階段是技術與客戶承諾，不是營收。

**與 Lumentum 的接點（推論）。** 法說會摘要提到 Celestial 的方案含 EAM 調變器。EAM 只負責調變，本身不發光，需要外部的連續波（CW）光源。Celestial 的光源從哪裡來，公開資料沒有說，但 CW 雷射正是 Lumentum 的核心產品之一，這是兩者最直接的技術接點。

**觀察指標：** Marvell 是否在 FY28 開始前點名 Photonic Fabric 的客戶；earnout 里程碑的達成進度。

## 二、記憶體解耦與分層：CXL 加上光學池化

**做了什麼。** 這是最接近你原本提到的「光纖記憶體池」的一條線，但它其實由兩層技術疊起來。機櫃層靠 CXL：Marvell 有 Structera 控制器與 260 通道的 CXL 交換器，又在 2026 年 1 月以約 5.4 億美元買下 XConn，後者的 PCIe 5／CXL 2.0 交換器已在量產，PCIe 6／CXL 3.1 在送樣，據稱已有超過 20 家客戶接洽。Pod 層靠光：Photonic Fabric 的記憶體模組可跨多個機櫃，距離最遠 50 公尺，最多提供 32TB 的 warm KV cache 卸載。

![HBM 之下的三層記憶體](/assets/img/header/2026-10-29/marvell-lite-03-memory-tiers.svg)

**為什麼這樣設計。** 一份產業評論的說法是，這整套設計的前提是推論成本的瓶頸在記憶體容量，不在算力。KV cache 隨上下文長度與並行請求數成長，HBM 放不下，就得往外分層。Counterpoint 估算，Structera 加上 Celestial 的光學互連，能撐起 100TB 以上的記憶體池，並把 HBM 與 DRAM 搬離 XPU 旁邊，改善 memory stranding（記憶體被綁在用不滿的機器上）。

**要說清楚的一點。** 這條線的「光」是 silicon photonics 的光 I/O，不是一般人想像的「光纖拉長記憶體匯流排」。光纖只負責那幾公尺到幾十公尺的距離。

**與 Lumentum 的接點。** 間接。記憶體池化本身不需要 Lumentum，只有當 pod 層走光、而光源需要大量 CW 雷射時才有關聯。以這條線單獨解釋收購 LITE，理由並不充分。

**觀察指標：** XConn 在 FY27 下半年的營收貢獻；Marvell 是否公布 CXL 記憶體附加的客戶與量產時程。

## 三、協定中立：UALink、ESUN 與 NVLink Fusion

**做了什麼。** Marvell 同時走兩條路。一條是開放標準：自家的 UALink 與 ESUN 交換器，XConn 的工程團隊併入 UALink 交換器團隊。另一條是 Nvidia 的 NVLink Fusion：讓 Marvell 的客製與網路矽可以接進 Nvidia 的機櫃架構。

![協定中立](/assets/img/header/2026-10-29/marvell-lite-04-protocol-hub.svg)

**為什麼。** 這是在對沖。客製 XPU 的客戶有的想脫離 Nvidia，有的想混搭，Marvell 兩邊都放一顆矽，客戶選哪邊它都在機櫃裡。據一份投資敘事整理，Nvidia 在 2026 年 3 月底也投資了 Marvell 20 億美元（這是單一來源，我沒有找到第二個確認）。若屬實，Nvidia 同時是 Marvell 與 Lumentum 的出資者，後面的客戶衝突問題會變得更複雜。

**與 Lumentum 的接點。** 沒有直接關係，但它決定了這筆交易的政治風險：Lumentum 的最大客戶之一是 Nvidia。

**觀察指標：** UALink 與 ESUN 交換器的出貨時程；Marvell 在 NVLink Fusion 生態中是否持續是唯一公開夥伴。

## 四、光層垂直整合：洽購 Lumentum

**Lumentum 是什麼。** 它的產品線橫跨 EML 雷射晶片（給雲端收發模組用）、CPO 用的高功率 CW 雷射、光放大器用的泵浦雷射，以及光電路交換器（OCS）。2023 年它以約 7.5 億美元買下 Cloud Light，把光收發模組也納入自家。

**Nvidia 在 2026 年 3 月 2 日各投 20 億美元給 Lumentum 與 Coherent**，內容包含數十億美元等級的採購承諾，以及特定雷射元件的未來取得權。Barclays 的判斷是，這筆錢大部分指向 400mW 等級的 CW 雷射。一份研究整理指出，這筆資金支援 Lumentum 興建第五座晶圓廠，用來保障長期供貨。

**Lumentum 的成長有分析師數字撐著，但那是預測。** GF Securities 預估 Nvidia 的 CPO 與近封裝光學（NPO）將把 Lumentum 的雷射營收推到 2027 年約 9.28 億美元、2028 年約 33 億美元。研究機構整理的資料顯示，OCS 訂單超過 4 億美元，目標在 2026 年底前達到每季 1 億美元。這幾個數字我都無法獨立驗證，引用時請當作市場共識，不是公司承諾。

![光鏈路四格](/assets/img/header/2026-10-29/marvell-lite-05-optical-chain.svg)

**戰略邏輯（推論）。** 一條光鏈路的價值，大致可以拆成：**光鏈路價值 = 光源 + 光引擎 + DSP + 光交換**。Marvell 目前握有 DSP 與（透過 Celestial）光引擎，缺光源與光交換。買下 Lumentum，等於把四格收成一條完整的產品線。更實際的一面是供應：雷射產能緊俏，Nvidia 已經用預付款與採購承諾鎖住一部分，Marvell 如果不自己握一個雷射廠，Photonic Fabric 在 FY28 放量時可能拿不到足夠的光源。有分析把這個動機描述為確保稀缺的雷射產能，同時擴大 Marvell 在整套光網路系統中所占的價值。

**對手的反應。** 24/7 Wall St 的看法是，交易成立後，Coherent 因為保持獨立，反而變得更有價值，因為 Nvidia 會在 Marvell 旗下的垂直整合供應商，與獨立的光學大廠之間，同時有財務與商業關係。Broadcom 則會面對一個對光學元件開發與製造有更多掌控的競爭者。

**觀察指標：** 對價結構（換股比例、溢價）；Nvidia 持有的 Lumentum 股份如何處理；既有客戶（尤其是 Marvell 的競爭者）是否得到持續供貨的保證。

## 五、客製 XPU 掛載：以 XPU 當入口

**做了什麼。** Marvell 的本業之一是替 hyperscaler 做客製 XPU。法說會摘要顯示，公司預期客製業務 FY27 營收成長超過 20%，由一個旗艦 XPU 專案帶動，同時有多個 XPU 附掛專案（CXL、NIC）在 FY27 開始放量，一個新的 Tier-1 XPU 專案則已確定來年需求。

![客製 XPU 掛載](/assets/img/header/2026-10-29/marvell-lite-06-xpu-attach.svg)

**為什麼。** 客製晶片本身毛利不一定好，但它是入口：只要晶片是 Marvell 設計的，旁邊的 NIC、CXL 控制器、光 I/O chiplet、光收發 DSP 都比較容易跟著賣。光源與收發模組是這張圖裡還沒補上的一格。

**與 Lumentum 的接點。** 直接。每顆 XPU 後面接的光收發與光源，在目前的架構下由第三方供應。買下 Lumentum 後，Marvell 能在同一個客戶專案裡報出更完整的 bill of materials。

**觀察指標：** 客製 XPU 的附掛率；單一客戶專案中 Marvell 內容物金額的變化。

## 這筆交易的代價

| 風險 | 說明 |
|---|---|
| 價格與稀釋 | 現金只有 39.2 億美元，必然大量換股；Marvell 單日跌逾 8%，反映市場對稀釋與價格的疑慮 |
| 客戶衝突 | Lumentum 賣雷射給 Nvidia，也可能賣給 Marvell 的競爭者；被 Marvell 收購後，這些客戶是否繼續採購（推論） |
| 製造模式落差 | Marvell 是無晶圓廠，Lumentum 有自己的化合物半導體製造；整合後的毛利結構與資本支出會改變（推論） |
| 時程錯配 | Photonic Fabric 的營收要到 FY28 下半年之後，而收購的資金成本現在就要付 |
| 監管 | 交易規模達數百億美元，審查時間與條件目前無法預測（推論） |

![時間軸](/assets/img/header/2026-10-29/marvell-lite-07-timeline.svg)

## 結語

回到一開始的問題：這筆收購是不是和「光學記憶體池」有關？我的判斷是有關，但不是主因。記憶體池化只是 Photonic Fabric 的一個應用，Marvell 真正要的，是讓 FY28 之後的光互連產品線不缺光源、不缺收發、不缺光交換。Celestial 和 XConn 補的是矽，Lumentum 補的是光本身。

下週如果 8-K 出來，值得先看三件事：對價是現金還是股票、Nvidia 的 Lumentum 持股怎麼處理、交易文件裡有沒有對既有客戶的供貨承諾。這三件事能回答的問題，比任何分析師的評論都多。

## 資料來源

- Bloomberg：<https://www.bloomberg.com/news/articles/2026-10-28/marvell-is-said-to-near-deal-for-lumentum-in-ai-related-megadeal>
- MarketScreener（Reuters）：<https://www.marketscreener.com/news/marvell-in-advanced-talks-to-buy-lumentum-bloomberg-news-reports-ce785cd3db8af523>
- AI Weekly：<https://aiweekly.co/alerts/marvell-in-advanced-talks-to-acquire-ai-optics-maker-lumentum>
- 24/7 Wall St：<https://247wallst.com/investing/2026/10/28/marvell-wants-lumentum-heres-why-coherent-could-win/>
- Converge Digest（Celestial AI 收購）：<https://convergedigest.com/marvell-bets-big-on-optical-scale-up-acquires-celestial-ai-for-photonic-fabric/>
- Converge Digest（分析師日）：<https://convergedigest.com/marvell-industry-analyst-day-celestial-ai-lands-a-hyperscaler-win/?amp=1>
- Marvell 完成 Celestial AI 收購（Business Wire）：<https://www.businesswire.com/news/home/20260201331090/en/marvell-completes-acquisition-of-celestial-ai>
- Counterpoint Research：<https://counterpointresearch.com/cn/insights/Celestial-AI-Acquisition-Perfectly-Positions-Marvell-For-Upcoming-Multi-Rack-Scale-Up-Boom>
- technologies.org（Photonic Fabric 產品與 earnout）：<https://technologies.org/marvell-mrvl-turns-celestial-ai-into-product-and-the-5-5-billion-earnout-clock-is-now-running/>
- Marvell 收購 XConn 公告：<https://www.marvell.com/company/newsroom/marvell-to-acquire-xconn-technologies-expanding-leadership-in-ai-data-center-connectivity.html>
- Dolphin Research（法說會摘要）：<https://longportapp.cn/topics/41197136>
- Simply Wall St（Nvidia 投資 Marvell，單一來源）：<https://simplywall.st/narratives/yc0sbctg-from-ai-infrastructure-plumber-to-full-stack-ai-factory-architect>
- SiliconANGLE（Nvidia 投資 Lumentum、Coherent）：<https://siliconangle.com/2026/03/02/nvidia-invests-4b-co-packaged-optics-suppliers-lumentum-coherent/>
- optics.org：<https://optics.org/news/nvidia-backs-lumentum-and-coherent-with-4bn-cash-investment>
- TradingKey（Barclays 對 400mW CW 的判斷）：<https://www.tradingkey.com/analysis/stocks/us-stocks/261638209-partnering-lumentum-coherent-nvidia-40-billion-cpo-future-ai-computing-power-tradingkey>
- SemiVision Research（第五座晶圓廠）：<https://tspasemiconductor.substack.com/p/who-owns-the-optical-layer-lumentums>
- GF Securities 預估（Yahoo Finance）：<https://finance.yahoo.com/markets/stocks/articles/lumentum-could-see-3-3-132602698.html>
- MLQ.ai（Lumentum 產品線與 OCS 訂單）：<https://mlq.ai/research/lumentum-ai-optical-laser-supercycle/>
- Lumentum 8-K（Cloud Light 收購）：<https://www.sec.gov/Archives/edgar/data/1633978/000119312523272452/d587006dex991.htm>
