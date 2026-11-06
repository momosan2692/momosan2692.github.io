---
layout: post
title: CPO(共封裝光學)技術解說
subtitle: 以訪談為骨幹再以論文與公開資料補強
cover-img: /assets/img/header/2026-04-18/QUANTUM.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-18/QUANTUM.png
published: true
pinned: true
mathjax: true
tags: [draft, CPO]
---

# CPO(共封裝光學)技術解說:以訪談為骨幹、以論文與公開資料補強
# 圖後補

> **本稿定位**:第一版「內文 + 圖標題」。SVG 尚未繪製,待你確認標題與圖意後再做。
>
> **體例(每章相同)**
> 1. **圖標題**:該章主圖,附一句圖意。
> 2. **訪談原話**:取自校正版譯文,保留主持人與受訪者的講法,未改寫。原稿沒有說話者標記,多位受訪者統稱「受訪者」。
> 3. **延伸說明**:用論文與公開資料補充背景。數字後面的方括號 [A1] 對應每章末的來源。
> 4. **查證註記**:標出廠商自述、尚未獨立驗證、或與訪談內容有出入的地方。
>
> **來源分級**:論文、標準文件(OIF、CW-WDM MSA、UCIe)、廠商發布與媒體報導。廠商數字(如「3.5 倍」「70%」)都是各家自己的宣稱,同一基準不一定可比,文中已標明。

---

## 第 1 章|I/O 牆:算得快,搬不動

**圖 1|算力隨面積長,I/O 隨邊長長:I/O 牆的幾何**
*圖意:左邊畫一顆晶粒,邊長 L,標出面積 ∝ L² 與周長 ∝ L;右邊兩條曲線(算力、邊緣 I/O 頻寬)隨世代拉開,縫隙標為「I/O 牆」。*

### 訪談原話

> **(主持人)** 晶片算得越來越快,資料卻快搬不動。當傳輸速度跟不上計算速度的時候,再快的 GPU 也只能原地等待,造成極大的算力浪費。
>
> **(主持人)** 銅線的頻寬、功耗和發熱都在逼近極限。這就好比急速擴張的高速公路,遇到了狹窄的收費站,形成了業界常說的「I/O 牆」。
>
> **(受訪者)** 算力相當於是隨面積(邊長的平方)增長,而晶片通訊是靠「邊」來做的。所以互聯的增長速率比算力要慢,這兩者極大地制約了晶片的通訊。

### 延伸說明

**「邊」為什麼是瓶頸。** 晶片能放多少高速 I/O,取決於晶粒周長(業界稱 shoreline 或 beachfront),而運算單元數量隨面積增加。晶粒變大時,周長增長比面積慢,I/O 追不上算力。訪談的「窄而快」(後面章節會再談)就是這個限制下的結果:邊緣能放的 SerDes 條數固定,只能把每條速率往上推。這個論點在文獻中的經典出處之一是 D. A. B. Miller 的 "Device requirements for optical interconnects to silicon chips"(Proc. IEEE, 2009)。*此文為憑記憶列出,本次未檢索驗證。*

**目標有多高。** Moazeni 的共封裝光學前瞻文章指出,下一代 AI 加速器與機架頂交換機需要 10 Tb/s 以上的頻寬與次 pJ/bit(每位元不到 1 皮焦耳)的能效,而當時的 CPO 示範還達不到 [A1]。

**光互聯的功耗已是系統問題。** NVIDIA 在 Hot Chips 2025 的說法是,AI 工廠的光學功耗約為傳統雲端資料中心的 17 倍,網路光學本身就約占 AI 工廠運算功耗的 10% [A2]。黃仁勳在 GTC 2025 舉例:每顆 GPU 若配 6 個可插拔收發器,約 180 W、成本約 6000 美元 [A3]。

### 查證註記
- 訪談說「過去十年算力增長將近一億倍、每年十倍」。這是受訪者口述,我沒找到可對照的來源,且「十年一億倍」與「每年十倍」在算術上不完全一致(十年每年十倍為 10¹⁰ 倍量級,八年才是一億倍),建議在正式文稿裡改用有出處的數字。
- NVIDIA 的 17 倍與 10% 是廠商簡報數字,不是獨立測量。

### 來源
- [A1] Moazeni, "Next-generation Co-Packaged Optics for Future Disaggregated AI Systems," arXiv:2303.01744 — https://arxiv.org/pdf/2303.01744
- [A2] NVIDIA Hot Chips 2025 報導(Wccftech)— https://wccftech.com/nvidia-spectrum-x-ethernet-photonics-debuts-as-the-world-first-200g-co-packaged-optics
- [A3] Optics.org, "Nvidia reveals plan to scale AI 'factories' with co-packaged optics" — https://www.optics.org/news/nvidia-reveals-plan-to-scale-ai-factories-with-co-packaged-optics

---

## 第 2 章|光進銅退:銅走不遠,DSP 太耗電

**圖 2|從面板到晶片:光的下沉階梯與電通道長度**
*圖意:水平階梯由左到右:可插拔(面板、長 PCB、含 DSP)→ LPO(無 DSP,主機 SerDes 補償)→ NPO(近封裝)→ CPO(同封裝)→ OIO(算力晶片旁)。每階標出「電通道長度」「是否需 DSP」「典型耦合位置」。*

### 訪談原話

> **(受訪者)** 光其實在近三十年不斷地下沉,越走越近,直到光模組……它還會進一步下沉,下沉到一公里以內、幾百米、幾十米、幾米、幾釐米,乃至幾微米這樣的距離。
>
> **(受訪者)** 隨著鏈路速率走到 1.6T、3.2T,銅在整個機櫃裡面大概只能傳輸一米左右,已經沒有辦法覆蓋機櫃從上到下了。所以這個領域是非常急迫的,要用光來取代電。
>
> **(受訪者)** 到單波 200G,其實已經用到了 3 奈米的 DSP,也受到摩爾定律放緩的限制……DSP 本來要做的就是解決插損的問題……DSP 貢獻了非常高的成本和功耗。

### 延伸說明

**銅的距離。** 被動銅纜(DAC)的實用距離隨單通道速率下降:Astera Labs 的說明是 50 Gbps/通道時被動 DAC 勉強到 3 公尺,100 Gbps/通道時實用上限約 2 公尺 [B1]。IEEE 802.3df 針對 212G/通道的討論,把被動 DAC 的鏈路預算聚焦在 1 公尺長的 26/27 AWG 雙絞線纜 [B2]。這與受訪者「約一米」的說法一致。要走更遠要靠主動電纜(含 retimer),一般 3–5 公尺,但要多耗電、多成本 [B2]。

**DSP 的負擔。** 可插拔光模組裡的 DSP 要在 PAM4 訊號上做均衡與前向糾錯,以補償「主機 PCB + 連接器 + 模組」這一整條電通道的損耗。廠商資料給出的量級:800G 含 DSP 模組約 12–16 W [B3],400G 模組裡 7nm DSP 約 4 W、約占模組功耗一半 [B4]。**LPO(線性驅動可插拔光學)** 的思路是把 DSP 拿掉,改由交換晶片的 SerDes 補償,模組功耗可降約四成到五成 [B3][B5]。

**CPO 如何省掉這些。** 把光引擎和交換 ASIC 放進同一封裝,電通道只剩幾毫米到幾公分,訊號調理需求大幅下降。Broadcom 的說法是,整合封裝「減少訊號調理需求、降低走線損耗與反射」,並宣稱光互聯功耗降低約 70%(約 3.5 倍)[B6]。NVIDIA 的 Spectrum-X Photonics 同樣強調沒有長 PCB 走線、雷射數量大幅減少 [A2]。

### 查證註記
- DSP 功耗占比、LPO 省多少,各家說法差異大。一篇業界文章也提醒,沒有具名基準模組、距離、速率與溫度的百分比,多半是行銷數字 [B5]。
- 「3 奈米 DSP」出自受訪者,我沒有找到公開資料驗證,先照原話保留。

### 來源
- [B1] Astera Labs — https://www.asteralabs.com/?p=21354
- [B2] ConnectorTips, 212G per-lane 銅纜與連接器 — https://www.connectortips.com/new-developments-in-212g-per-lane-data-center-connectors-and-cables/
- [B3] DSP vs LPO(China-TSCOM)— https://www.china-tscom.com/dsp-vs-lpo.html
- [B4] FS, "What is the LPO Transceiver?" — https://community.fs.com/article/what-is-the-lpo-transceiver.html
- [B5] "Linear Pluggable Optics: 40–50% Less Power at 800G"(Hengtong)— https://www.hengtongglobal.com/info/linear-pluggable-optics-power-savings-103606655.html
- [B6] Broadcom TH6-Davisson 新聞稿 — https://www.itiger.com/news/2573692637 、https://mfn.se/one/a/broadcom/broadcom-announces-tomahawk-r-6-davisson-the-industrys-first-102-4-tbps-ethernet-switch-with-co-packaged-optics-824cfbb5

---

## 第 3 章|CPO、NPO、OIO:三種「靠近」與兩個戰場

**圖 3|光離晶片多近:可插拔、NPO、CPO、OIO 的位置圖,與 scale-out / scale-up 分工**
*圖意:俯視剖面圖。上半是交換側(交換 ASIC + 光引擎 → 面板光纖,標 scale-out);下半是計算側(GPU + 光 I/O 小晶片 → 光纖,標 scale-up)。以顏色區分封裝層級:PCB 上、基板上、中介層上。*

### 訪談原話

> **(受訪者)** CPO 是一個概念的統稱,相當於光電共封裝。CPO 這個概念其實源自交換側,比如 Switch 這一塊,博通在做,英偉達在做的 Spectrum 這塊……算力這側(GPU、CPU 等)和光的互聯關係,叫做 OIO(Optical I/O)。
>
> **(受訪者)** 一個在 scale-out 交換側,一個在 scale-up 算力互聯側。
>
> **(受訪者)** 我覺得 NPO 在目前這種情況下其實是一個過渡。NPO 比較相容目前光模組整個的產業鏈……但不打破 GPU 現有的形態……而 OIO 是一個完全不一樣的範式,是一個完全重寫的創新。

### 延伸說明

**術語沒有統一定義。** 一篇解說指出,CPO 是一種整合方式,不是通訊協定或特定速率,光引擎不一定和處理器做在同一顆晶粒上;只寫「CPO」不能得知雷射位置、可否更換、冷卻方式 [C1]。業界也有「in-package optical I/O」與「near-package optics」的區分,OIF 與 CPO 協作聯盟(CPO Collaboration JDF)也定義過近封裝的外形規格 [C2]。所以讀產品資料時,要看「光引擎貼在哪一層」。

**交換側 CPO 已經出貨。**
- Broadcom 第三代 **Tomahawk 6–Davisson**:102.4 Tb/s,16 個 6.4 Tb/s 光引擎,每通道 200 Gbps,可現場更換的 ELSFP 雷射模組;第四代平台以每通道 400 Gbps 為目標 [C3][C4]。
- NVIDIA **Spectrum-X / Quantum-X Photonics**:採用微環調製器(MRM)的 1.6T 光引擎,每顆光引擎 8 條 200G PAM4 通道;NVIDIA 宣稱能效 3.5 倍、雷射數減少 4 倍、雷射可靠度 13 倍 [A2][C5]。
- 兩家都用台積電的 COUPE 平台製造光引擎(見第 9 章)[C3][C5]。

**計算側 OIO。** Intel 的 OCI 小晶片(光電子雙晶片,走 PCIe 介面,可與任意算力裝置共封裝)與 Ayar Labs 的 TeraPHY 是代表 [C6][C7]。Ayar 的第三代 TeraPHY 為 8 Tbps 光 I/O 小晶片,並首次在光路上承載 UCIe 流量(見第 8 章)[C7]。

### 查證註記
- 3.5 倍、4 倍、13 倍、70% 全為廠商宣稱;NVIDIA 與 Broadcom 的比較基準(可插拔方案的型號、速率、DSP 或 LPO)不同,不能互相比較。
- NPO 的產業現況與命名,我只找到零散說法,沒有正式規格可引用,這章 NPO 部分以訪談為主。

### 來源
- [C1] Why Use Co-Packaged Optics in AI Data Centers?(BestPCBs,2026-09)— https://www.bestpcbs.com/blog/2026/09/co-packaged-optics-ai-data-centers/
- [C2] Photonics.com, In-package optical I/O vs. CPO — https://www.photonics.com/Articles/Understanding_In-Package_Optical_I_O_Versus/a69701
- [C3] Converge Digest, Broadcom TH6-Davisson — https://convergedigest.com/broadcom-unveils-102-4-tbps-davisson-cpo-switch-for-ai-clusters/?amp=1
- [C4] Broadcom 新聞稿(同 [B6])
- [C5] NVIDIA Developer Blog, "How Industry Collaboration Fosters NVIDIA Co-Packaged Optics" — https://developer.nvidia.com/blog/how-industry-collaboration-fosters-nvidia-co-packaged-optics
- [C6] Tom's Hardware, CPO foundry roadmaps — https://www.tomshardware.com/tech-industry/artificial-intelligence/co-packaged-optics-cpo-foundry-roadmaps-breaking-down-tsmc-intel-samsung-and-globalfoundries-approach-to-next-generation-scale-up-connectivity
- [C7] Gazettabyte, Ayar Labs 專訪 — https://gazettabyte.com/?p=146250

---

## 第 4 章|把 0 和 1 寫進光裡:馬赫–曾德與微環

**圖 4|電壓如何變成光強:MZM 的干涉 vs 微環的共振**
*圖意:左右雙欄。左:光分兩臂、一臂加相位、再合波,下方畫 cos² 形傳輸曲線,標「3 mm 級」。右:光學匯流波導旁一個小環,下方畫洛倫茲共振谷,電壓讓谷左右平移,標「約 15 µm」。兩欄用同一比例尺標示尺寸差。*

### 訪談原話

> **(受訪者)** 電的 0101,指的是電的強度調製……它透過電光轉換效應,來改變光的一些基本特性。光裡面有幾個主要的特性:一個是強度,第二是相位,甚至還有偏振和模式。
>
> **(受訪者)** 矽光主要用的是馬赫–曾德調製器,這是現在整個矽光裡面用得最主流的調製器,也接近唯一了……把光分成兩束,其中一束被相位調製……兩束光再合併的時候,會透過相干相消和相長,轉換成強度的 1010 訊號。
>
> **(受訪者)** 但是這個器件也有比較大的弊端,就是尺寸非常大。因為要實現非常低的驅動電壓擺幅,必須要求驅動相位的長度足夠長。目前 MZM 的尺寸基本上都在毫米量級。

### 延伸說明

**MZM 的取捨。** 矽中常用的載子耗盡型相位調製很弱,要得到足夠的相位差只能靠加長電極,因此行波式 MZM 長達數毫米;行波電極還容易有 RF 串擾,限制相鄰元件的最小間距,使整體頻寬密度難以提高 [D1]。它的優點是低啁啾、頻寬高、線性好,對製程與溫度變化不敏感,這也是它能主宰光模組的原因 [D1]。

**微環的取捨。** 微環靠共振增強調製效率,所以小、耗能低,廣泛用在短距 IM-DD 互聯,也被視為高頻寬密度 WDM 鏈路的關鍵元件 [D1]。代價是共振波長對製程與溫度極敏感(下一章與第 6 章)。Li 與 Wang 的理論分析指出,共振式矽調製器存在能效與 RC 頻寬之間的本質取捨 [D2]。

**歷史脈絡。** 矽基微米級調製器的開端常追溯到 2005 年 Xu 等人的《Nature》論文;矽調製器的整體回顧可看 Reed 等人 2010 年 Nature Photonics 的 "Silicon optical modulators"。*這兩篇為憑記憶列出,本次未檢索驗證。*

### 來源
- [D1] "Compact ... microring modulator in an MZI ... >5 Tb/s/mm," arXiv:2412.17986 — https://pdf.arxiv.org/pdf/2412.17986
- [D2] E. Li and A. X. Wang, "Theoretical Analysis of Energy Efficiency and Bandwidth Limit of Silicon Photonic Modulators," JLT 37(23), 2019 — https://muri2.engr.utexas.edu/sites/default/files/publication/jlt-37-23-5801.pdf

---

## 第 5 章|微環的好處:邊密度、「寬而慢」與 WDM

**圖 5|窄而快 vs 寬而慢:邊密度到面密度,以及一根光纖上的多顆微環**
*圖意:上排兩個晶粒俯視。左:周邊少量 224G SerDes(窄而快);右:晶粒面上大量 32–64G 微環 I/O(寬而慢),標頻寬密度與 pJ/bit 對比。下排:一條匯流波導上串 8 顆不同半徑的微環,各挑一個波長,合併進一根光纖。*

### 訪談原話

> **(受訪者)** 微環最核心的優勢,就是尺寸極小。MZM 的尺寸大約在 3 毫米左右,而微環的直徑普遍大概是 15 微米,差了兩個多數量級……我可以像撒芝麻一樣,在整個晶片上佈滿微環。
>
> **(受訪者)** 原先是 112G,我現在只用 32G、64G,就可以透過晶片中間的 pad 把它連出來。這樣就是一個「面」的概念,也就是「寬」……慢帶來的好處,首先是功耗和面積都會很低。
>
> **(主持人)** 微環真正重要的地方,不只是把調製器從毫米縮到了微米,而是尺寸變小之後,它改變了整顆晶片組織 I/O 的方式:原來是少量極高速的通道,現在可以變成大量相對低速的並行通道。
>
> **(受訪者)** 微環天生就是一個波分複用的器件,它具有波長選擇性,我不需要引入任何額外的器件,就能夠實現非常高密度的密集波分複用(DWDM)。

### 延伸說明

**量級對照。** Ayar Labs 的說法是,微環約 10 微米,可做 25–100 Gbps,相對 MZI 約小 100 倍、頻寬密度高 25–50 倍、能效高約 50 倍;把多顆微環沿同一條波導串接,就成了 WDM [E1]。NVIDIA 的微環調製器做到單波長 200 Gbps PAM4,一個光引擎 8 發 8 收 [C5]。2024 年底 arXiv 上一個把 MRM 嵌入 MZI 的設計,報告了超過 5 Tb/s/mm 的晶片邊緣頻寬密度 [D1]。

**能效路線圖。** 台積電公開的光學路線圖顯示:每位元能耗從傳統銅封裝的 30 pJ/bit 以上,降到基板上 CPO 的 5 pJ/bit 以下,再降到中介層級光 I/O 的 2 pJ/bit 以下 [E2]。這是路線圖目標,不是量產實測。

**UCIe 的邊密度提醒。** Ayar 的 UCIe 光學小晶片受 UCIe 標準凸塊配置所限,頻寬密度為 896 Gbps/mm [E3]。也就是說,「面」式 I/O 的收益最終受封裝凸塊間距而非光元件限制,與訪談展示的 3D 微環 OIO 方向互補。

**WDM 的邏輯。** 每顆微環只與其共振波長互動,所以同一條匯流波導上可串多顆微環、各取一個波長;這是「用少量光纖承載大量通道」的原因。代價是每個波長都要有對應的光源線(第 7 章)。

### 查證註記
- Ayar 的「100 倍小、25–50 倍密度、50 倍能效」是公司自述 [E1],比較的是特定 MZI 設計。
- 受訪者說微環可做到 400G;已公開的量產實例為 200G(NVIDIA)[C5]。400G 屬於研發層級,本次沒找到對應的公開論文。

### 來源
- [E1] The Next Platform, Ayar Labs TeraPHY — https://www.nextplatform.com/2019/09/11/on-chip-optical-links-are-one-step-closer-to-reality
- [E2] 36Kr/半導體行業觀察,〈TSMC bets on optical chips〉— https://eu.36kr.com/en/p/3964202172079624 ;Creative Strategies, "TSMC COUPE: Why the CoWoS Pattern Is Repeating in Silicon Photonics" — https://creativestrategies.com/research/tsmc-coupe-why-the-cowos-pattern-is-repeating-in-silicon-photonics/
- [E3] Ayar Labs, Hot Chips 2025 簡報 — https://hc2025.hotchips.org/assets/program/conference/day2/83_Ayar_Labs_Stojanovic_final.pdf

---

## 第 6 章|微環的代價:波長飄移、熱鎖定與「修調」

**圖 6|對付波長飄移的兩條路:持續加熱鎖定 vs 一次性修調**
*圖意:同一張圖畫三條洛倫茲共振曲線與一條雷射線。上:出廠共振偏離雷射線(± 數百 pm 至 nm 級)。左下:用微加熱器把共振拖回(標「持續耗電、需回授電路」)。右下:用雷射脈衝一次性改變折射率,共振永久移到位(標「皮米級、一次性、需設備」)。*

### 訪談原話

> **(受訪者)** 良率到底是由什麼原因導致的?……傳統思維就是:我用更好的光刻機,光刻機的 CD 越小,它帶來的波動就越小。但是哪怕你用再好的光刻機,你的機械設備裡永遠有一個抖動。
>
> **(受訪者)** 光刻機是由於線寬引入了相位波動,我可以做另外一台設備,把 Graham Reed 教授發明的相位編輯技術,也就是矽的晶態和非晶態的轉換,用來改善光的相位。
>
> **(主持人)** 這就像造一把琴的時候,不需要讓每一根琴弦都有絕對音準,而是可以在造出來之後再進一步調節。
>
> **(受訪者)** 一般情況下,微環的工作波長與雷射器的波長耦合區域,大概在幾十皮米以內……我們能夠做到一皮米的精度來改善微環的波長精度。

### 延伸說明

**為什麼會飄。** 矽的熱光係數約 1.8×10⁻⁴/K,使微環共振在 1550 nm 附近約每 K 移動 10 GHz(約 80 pm)[F1]。製程方面,CEA-Leti 的簡報指出,僅僅 1 nm 的矽厚度變化就足以使共振波長在設計時不可預測 [F2]。所以微環不能「設計完就用」,必須在工作點上校準。

**路線一:主動熱調諧與回授鎖定。** 用微加熱器把共振拖到雷射波長,再靠光電二極體取得誤差訊號做閉環控制。Padmaraju 與 Bergman 等人的工作建立了這套方法:以平均功率監測鎖定微環調製器(Opt. Express 20(27), 2012),以及用抖動(dither)訊號做波長鎖定(JLT 32(3), 2014)[F1][F3]。CEA-Leti 的實作中,每個波長的加熱器控制約占 40×40 µm² 電子面積,並示範了 30 pm 峰峰值波長擾動下的穩定 [F2]。缺點是要一直耗電、一直跑控制迴路,波長數愈多愈麻煩。

**路線二:永久修調(trimming)。** 這正是訪談的核心。
- 訪談提到的 **Graham Reed 團隊(Southampton)** 的路線:對矽波導做鍺離子植入使其非晶化(折射率提高),再以局部雷射退火讓它部分重新結晶,折射率變化因此可被「寫入」並設定到目標值 [F4][F5]。他們發表過環形諧振器離子植入修調(IEEE JSTQE, 2018)、MZI 相位修調(Photonics Research 5, 578, 2017),以及以實時監測與梯度回授提高修調精度(Opt. Express 26, 2018)[F4][F5][F6]。
- 一篇 2022 年 arXiv 論文以鍺植入加加熱器退火,在 300 mm 矽晶圓上把環形諧振器修到目標波長 1310 nm 的 ±32 pm 內,並以此論證了大規模製造的可行性 [F7]。
- 其他機制:對氮化矽用紫外雷射修調(De Paoli 等,Photonics Research 8, 2020)[F8];對氧化層覆蓋做雷射緻密化,使有效折射率上升而紅移。2025 年 arXiv 有一個 64 顆微碟調製器的 1.28 Tb/s、29 fJ/bit 發射器採用此法,報告最小約 100 pm 紅移,並稱可省下約 33% 的熱調諧能量 [F9]。
- 兩種原理要區分:訪談所述是**矽的晶態/非晶態相變**,2025 年這篇是**氧化層緻密化**。

**與量產玩家的關係。** NVIDIA 的技術文章說,與台積電的合作已經在量產規模上解決了微環調製器的長期製造問題,並強調兼具小尺寸與穩健熱控 [C5]。文章沒有揭露使用的是修調還是主動熱控。所以「業界已經用哪種方式量產微環」這件事,公開資料給不出答案。

### 查證註記
- **99% 良率**:訪談明講這只是「微環波長」單一因素的良率,其他因素(晶圓廠工藝、貼片等)另計。我沒有找到對應的公開數據或論文,應視為受訪公司自述。
- 「幾十皮米」的工作窗與「1 皮米」精度,是設備層級的宣稱;量產中的控制穩定度、修調後的長期漂移與是否可逆,文獻中都是需要關注的問題(Reed 團隊的方法被描述為折射率變化可逆、可藉局部退火調整 [F10])。
- 訪談中的人名「張維威」與設備名「智威 1000」為語音辨識結果。我在文獻中看到 Southampton 2025 年論文作者列有 Weiwei Zhang,但**不能就此確定是同一人**,正式稿請向受訪者確認。

### 來源
- [F1] PhotonForge 文件, "Thermal Stabilization of Microring Resonators" — https://docs.flexcompute.com/projects/photonforge/en/latest/examples/Microring_Thermal_Stabilization.html
- [F2] CEA-Leti, Y. Thonnart, D43D 2018 — https://www.cea.fr/cea-tech/leti/english/Documents/pres-WS-LID-2018/D43D/Session2/D43D18-S24-Y.Thonnart.pdf
- [F3] K. Padmaraju 博士論文,哥倫比亞大學 — https://academiccommons.columbia.edu/doi/10.7916/D8P849F2
- [F4] Milošević 等,Ion implantation in silicon for trimming the operating wavelength of ring resonators,IEEE JSTQE — https://eprints.soton.ac.uk/417957/1/08276286.pdf
- [F5] Chen 等,Post-fabrication phase trimming of MZIs by laser annealing of Ge-implanted waveguides,Photonics Res. 5, 578 — https://eprints.soton.ac.uk/412216/2/prj_5_6_578.pdf
- [F6] B. Chen 等,Real-time monitoring and gradient feedback enable accurate trimming of ion-implanted silicon photonic devices,Opt. Express 26 — https://eprints.soton.ac.uk/423186/1/oe_26_19_24953.pdf
- [F7] arXiv:2203.03503(300 mm 晶圓 ±32 pm 修調)— https://arxiv.org/pdf/2203.03503
- [F8] De Paoli 等,Laser trimming of the operating wavelength of SiN racetrack resonators,Photonics Res. 8, 677 — https://www.researching.cn/articles/OJ53351a288de86bf
- [F9] arXiv:2508.11146(64 微碟、非易失雷射修調)— https://arxiv.org/html/2508.11146v2
- [F10] Southampton 論文集頁(Ge 植入使折射率變化可逆、可局部退火調整)— https://eprints.soton.ac.uk/440503/2/Ion_implantation_of_germanium.pdf

---

## 第 7 章|光從哪裡來:外部雷射源與多波長光源

**圖 7|光源怎麼供:外部雷射源(ELS)→ 光纖 → 光引擎,單波長陣列 vs 多波長光源**
*圖意:左側面板上的可抽換 ELSFP 模組(標「熱抽換、盲插、眼安全」);中間光纖到封裝內的光引擎;右側比較兩種光源:8 顆 DFB 並排(各發一個波長)vs 1 顆梳狀/多波長光源(一次發 8 或 16 個波長),後者標「共用封裝、散熱」。*

### 訪談原話

> **(受訪者)** 傳統的雷射器都是適配 MZI 的,它無法適配微環:傳統的製造工藝和設計裡面,是把波長精度這個指標砍掉了。如果在當前的 CW 高功率雷射器裡面把波長精度帶進去,它的良率可能會從原來的 50% 降低到 10%。
>
> **(受訪者)** 精準波長、八通道的 DFB 雷射器(磷化銦),價格大概是 3000 美金一顆。
>
> **(主持人)** 能不能換個思路,讓一顆雷射器一次發出 8 種、16 種甚至更多種波長的光呢?
>
> **(受訪者)** 我們能夠保證有兩款產品未來面世:一款是 8 波長雷射器,一款是 16 波長。

### 延伸說明

**為什麼雷射放在外面。** CPO 的光引擎貼近高溫的交換/算力晶片,而雷射對溫度與熱循環敏感;NVIDIA 的文章說,可插拔光學中反覆的熱循環會快速縮短雷射壽命,CPO 把雷射集中到外部模組可改善這件事 [C5]。業界的具體做法是 **ELS(外部雷射源)**:NVIDIA 的 ELS 每模組含八顆 200 mW 連續波 DFB 雷射,並有自動溫度追蹤 [G1],是可現場更換的模組 [C5]。OIF 在 2023 年發布了 **ELSFP 實作協議**,定義放在面板(系統最涼處)的外部雷射可插拔外形,支援熱抽換,並以盲插光連接器降低高功率下的眼安全風險;後續有 2025 年 1 月的 02.0 版 [G2][G3]。Broadcom 的 Davisson 同樣使用可現場更換的 ELSFP [C3]。

**波長網格的標準。** **CW-WDM MSA**(2020 年成立,2021 年 6 月發布首版規格)定義了 O 波段 8、16、32 波長的光源,含多種間距、固定與彈性網格、單波長輸出的模組化光源與全部波長同埠輸出的整合光源兩種形態,以及 RIN、SMSR、線寬等量測方法;發起成員包含 Ayar Labs、Intel、Lumentum、MACOM、Sivers 等 [G4][G5]。這回答了訪談提到的問題:微環系統要的是「波長精確且間距有規格」的光源,而不是任意挑出的 DFB。

**多波長光源的幾種路線。**
- **量子點梳狀雷射**:HP Labs 示範過梳狀雷射驅動微環 DWDM 發射機 [G6]。
- **Kerr 光梳(氮化矽)**:2023 年《Nature Photonics》的 Rizzo 等人示範了 Kerr 光梳驅動的矽光鏈路,單根光纖上 32 個波長通道、合計 512 Gb/s [G7]。
- **異質整合 III-V/矽 DFB 陣列**:SPIE 2024 報告 4 顆四波長 DFB 組成 16 個波長通道、200 GHz 間距 [G8]。
- **鏈路層面的最佳化**:London 等人分析了梳狀光源驅動的環式矽光鏈路,討論如何選擇光梳設定以最小化雷射功耗 [G9]。

Ayar 的 **SuperNova** 光源為 16 波長版本,與 TeraPHY 搭配 [C7][G10]。

### 查證註記
- 磷化銦雷射良率 50%→10%、成本「十倍」、3000 美金一顆,都是受訪者自述,我沒有公開資料可對照。
- 受訪公司的 8 與 16 波長雷射,本次沒找到公開規格;能否符合 CW-WDM MSA 的網格也不明。

### 來源
- [G1] NADDOD, "NVIDIA's Silicon Photonics CPO" — https://naddod.com/blog/nvidia-s-silicon-photonics-cpo-the-beginning-of-a-transformative-journey-in-ai
- [G2] Lightwave, OIF ELSFP — https://www.lightwaveonline.com/optical-tech/components/article/14297441/oif-serves-up-external-laser-small-formfactor-pluggable-elsfp-implementation-agreement
- [G3] OIF-ELSFP-02.0 — https://www.oiforum.com/wp-content/uploads/OIF-ELSFP-02.0.pdf
- [G4] CW-WDM MSA 發布,Business Wire — https://www.businesswire.com/news/home/20210608005513/en/CW-WDM-MSA-Consortium-Releases-New-Specification-for-Multi-Wavelength-Optical-Laser-Sources
- [G5] Lightwave, CW-WDM MSA — https://www.lightwaveonline.com/optical-tech/components/article/14204845/cwwdm-msa-consortium-releases-multiwavelength-oband-laser-specifications
- [G6] C.-H. Chen 等(HP Labs),comb laser-driven DWDM silicon photonic transmitter — https://www.researchgate.net/profile/Chin-Hui_Chen2/publication/280778036_A_comb_laser-driven_DWDM_silicon_photonic_transmitter_based_on_microring_modulators/links/55ccb6e208aed3bc0c70820d.pdf
- [G7] Rizzo 等,Massively scalable Kerr comb-driven silicon photonic link,Nature Photonics 17, 2023 — https://www.nature.com/articles/s41566-023-01244-7.pdf
- [G8] SPIE 12905, 16-channel integrated multi-wavelength DFB lasers with 200 GHz spacing — https://biomedicaloptics.spiedigitallibrary.org/conference-proceedings-of-spie/12905/129050J/16-channel-integrated-multi-wavelength-DFB-lasers-with-200-GHz/10.1117/12.3023430.full
- [G9] London 等,Energy Efficiency Analysis of Comb Source Carrier-Injection Ring-Based Silicon Photonic Link,JSTQE — https://cris.bgu.ac.il/en/publications/energy-efficiency-analysis-of-comb-source-carrier-injection-ring--2/
- [G10] Ayar Labs UCIe 光學小晶片報導(Compound Semiconductor)— https://compoundsemiconductor.net/article/121491/Ayar_Labs_unveils_first_UCIe_optical_chiplet

---

## 第 8 章|電晶片與 UCIe:GPU 與光之間的「翻譯官」

**圖 8|翻譯官:UCIe 電訊號 → 光 I/O 電晶片 → 微環 → 光纖**
*圖意:由左至右方塊鏈:GPU(UCIe 介面)→ 光 I/O 電晶片(標出 1.6–2 V 驅動、反偏、波長鎖定迴路、retimer)→ 光晶片(微環陣列)→ 光纖。上方對照傳統路徑:GPU SerDes → 長電通道(含 30–40 dB 損耗、均衡、CDR)→ 光模組 DSP。*

### 訪談原話

> **(受訪者)** GPU 本身有 SerDes 介面,但是那個 SerDes 介面是用來驅動銅線的,它驅動的是 50 歐姆特徵阻抗的負載……我們現在的微環是一個非線性的器件,同時它不是 50 歐姆匹配的,同時它還對溫度和偏置電壓極其敏感。
>
> **(受訪者)** 常規的 SerDes 大概只需要 400 毫伏到 800 毫伏的差分擺幅就差不多夠了,但是我們要驅動微環,就需要 1.6 伏到 2 伏,甚至更高一點的驅動電壓……我們需要實時鎖定它的波長,那就需要實時鎖定的電路。
>
> **(受訪者)** 我們更像是一個翻譯官,把它的電訊號翻譯成光能夠閱讀的一種訊號……GPU 甚至都沒有感知,它以為還是傳給 SerDes。
>
> **(受訪者)** 在 OIO 這個方向,我們目前是全面相容 UCIe 的。UCIe 其實是專門為 die-to-die 而生的一個協議……透過我們的光 I/O,我們可以把它連到十米、幾十米這種規模。

### 延伸說明

**UCIe 如何接上光。** UCIe 規格分為物理層、die-to-die 轉接層與協定層三層,物理層採轉發時脈與單端低電壓 DDR 訊號以提高能效 [H1]。為了跨封裝延伸距離,專利與規格文件描述了 **UCIe retimer**:一端以 UCIe 與本封裝的晶粒通訊,另一端的外部埠可接光、毫米波或電纜等長距離媒介;retimer 負責在兩個封裝間可靠傳送 flit,可搭配 FEC 與 CRC/重送,承載 PCIe、CXL 等協定 [H2]。UCIe 聯盟也說明,UCIe 合規使 PHY 可被最佳化為光學應用的 retimer [H3]。

**實例:Ayar Labs 的 8 Tbps TeraPHY。** Hot Chips 2025 簡報稱這是首個 UCIe 光學 retimer 的實作:每晶片 16 個模組、雙向共 8.192 Tbps,含 retimer 協定轉接邏輯,把 UCIe 流量送上光 I/O;並以 16 波長 SuperNova 光源完成了 UCIe 端到端鏈路測試 [E3]。TeraPHY 用 GlobalFoundries 的 45nm 矽光製程,CTO Stojanovic 提到也可把電晶片移到台積電更先進的 CMOS 節點 [C7]。

**微環為什麼需要專用電路。** 早在 2015 年,Sun 等人(含 Stojanovic、Wade)在《Nature》發表單晶片微處理器:在一顆晶片上集成超過 7000 萬電晶體與 850 個光子元件,證明了微處理器可直接用光與外界通訊,且採用「zero-change」做法,直接用既有 CMOS 製程設計光元件 [H4]。Stojanovic 在採訪中提到,由於資料未經編碼,微環調製器會因資料樣式(連續的 0)而自熱,是設計必須處理的問題 [H5]。這就是訪談所說「實時鎖定電路」的由來。

**能效的來源。** 受訪者的論點是:晶片離光很近,電通道損耗只剩幾個到十幾個 dB,不再需要為 30–40 dB 損耗設計的強均衡、預加重與 CDR,「寬而慢」又進一步降低每位元能耗(第 5 章)。這與第 2 章 DSP 的論述是同一件事的兩面。

### 查證註記
- 「十米、幾十米」:Ayar 在 UCIe 光學中,公開資料多提到機架內到跨機架尺度;UCIe 規格文件未見具體「幾十米」數字,應以產品規格為準。Avicena 等公司的資料提到小於 1 pJ/bit、10 公尺 [H6],但那是另一家公司的光互聯方案,不應和受訪公司混為一談。
- 受訪者說的「全面相容 UCIe」是產品宣稱;UCIe 光學 retimer 的規格本身仍在演進(我檢索到的有 UCIe 2.0 與相關專利)。

### 來源
- [H1] Semiconductor Engineering, "What Is UCIe?" — https://semiengineering.com/what-is-ucie/
- [H2] UCIe retimer 相關專利:US 12499019 — https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/12499019 ;US 12332826 — https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/12332826
- [H3] UCIe 聯盟,"UCIe in Optical Networking" — https://www.uciexpress.org/post/ucie-in-optical-networking
- [H4] C. Sun 等,Single-chip microprocessor that communicates directly using light,Nature 528, 534–538 (2015),DOI 10.1038/nature16454 — https://www.ovid.com/journals/natr/pdf/10.1038/nature16454~single-chip-microprocessor-that-communicates-directly-using
- [H5] Gazettabyte, Stojanovic 專訪 — https://gazettabyte.com/?p=97
- [H6] Design World, UCIe 與光互聯 — https://www.designworldonline.com/?p=597547

---

## 第 9 章|封裝與製造:台積電 COUPE、流片的坑與垂直整合

**圖 9|光電怎麼疊在一起:COUPE 三階段路線與封裝剖面**
*圖意:左側為堆疊剖面(EIC 以 SoIC-X 貼在 PIC 上、光纖陣列單元 FAU、基板/中介層);右側為三階段橫條:COUPE on PCB(1.6T)→ on substrate(6.4T)→ on interposer(12.8T),每階標頻寬與每位元能耗目標(>30 → <5 → <2 pJ/bit)。*

### 訪談原話

> **(主持人)** 台積電則是這輪光互聯爆發背後的另外一個巨頭,也正在透過自己的 COUPE 平台,嘗試把晶圓製造、先進封裝和光電融合這一整套技術鏈,打造成系統級、由台積電主導的最佳化。
>
> **(受訪者)** 因為我們一開始對先進封裝的理解不夠……當時只是為了在光晶片上植球,就發現遇到了非常大的阻力……它需要非常多的底填膠……但是我們的光晶片當時已經做好了,就導致我們的端面很容易被這種膠汙染。所以那次流片基本上是廢掉了。
>
> **(受訪者)** 光比電要年輕。電現在已經水平分工了……但光不一樣,光更多需要的是垂直整合。
>
> **(受訪者)** 我們做的不是一顆光的晶片,我們做的是一個光互聯的系統……我們一定要長在一起,而不只是坐在一起。

### 延伸說明

**COUPE 是什麼。** COUPE(Compact Universal Photonic Engine)是台積電以 SoIC 為基礎的光引擎平台:以無凸塊的銅對銅鍵合把電晶片(EIC)疊在光晶片(PIC)上 [I1]。台積電的路線有三階段:第一代在 PCB 上、以可插拔形態達 1.6 Tbps;第二代與 CoWoS 整合、與交換 ASIC 共封裝(6.4 Tbps),邁入 CPO;第三代放到中介層上(12.8 Tbps),直接進入處理器封裝 [I2][I3]。微環調製器本身的演進被台積電另列為一條獨立路線 [I2]。量產時程方面,媒體報導 COUPE 目標在 2026 年進入量產 [I4]。

**EIC 與 PIC 節點不同。** 一份分析稱 COUPE 結合了先進節點電晶片、成熟的矽光子製程與先進封裝,並以混合鍵合貼合 [I5]。我找到的說法對 EIC 節點不一致(65 nm 與 6 nm 兩種),因此不寫數字。

**NVIDIA 如何處理耦合與組裝。** 在 NVIDIA 的實作中,晶圓層級整合微透鏡以降低光纖對準的時間與敏感度;光引擎直接回流焊到模組基板上 [C5]。這些細節說明光纖耦合是 CPO 能否量產的關鍵,與受訪者提到的「端面汙染」是同一類問題。

**受訪者的坑,在技術上怎麼理解。** 訪談中的「端面」指光晶片邊緣的光耦合面。我對這段的解讀是:邊緣耦合對汙染與膠材非常敏感,植球、底填與清洗等先進封裝步驟若與光學面不相容,整輪流片就報廢。*這是我基於光學耦合常識的解讀,沒有找到公開文件逐項印證受訪者所述的具體製程。*

**為什麼需要整合團隊。** 台積電的路線把電、光、封裝放在同一平台上共同最佳化,而訪談的初創公司則是以「垂直整合」與「四位創辦人光電同時在場」來應對同一件事,兩者的共同點是:光電不能分開設計。

### 查證註記
- 受訪者說「光流片 8 輪、電 5 輪」是公司自述。
- COUPE 的量產時間與各代規格,媒體與分析文章來源不一,以台積電官方資料為準。

### 來源
- [I1] 台積電 COUPE 技術解析(Substack 轉載)— https://tspasemiconductor.substack.com/p/electro-optical-integration-tsmcs
- [I2] Tom's Hardware(同 [C6])
- [I3] TechSpot, TSMC 路線圖 — https://www.techspot.com/news/102779-tsmc-lays-out-roadmap-massive-kilowatt-class-chip.html
- [I4] TrendForce, "Silicon Photonics Race Intensifies as TSMC Targets 2026 COUPE Production" — https://www.trendforce.com/news/2026/04/01/news-silicon-photonics-race-intensifies-as-tsmc-targets-2026-coupe-production-samsung-eyes-2029-cpo-turnkey/
- [I5] Creative Strategies(同 [E2])

---

## 第 10 章|生態與未來:封閉整合、開放標準與池化資料中心

**圖 10|兩種生態與一個願景:蘋果式整合、安卓式開放,以及資源池化的資料中心**
*圖意:左半是兩個生態對比(封閉:GPU + NVLink + 自家光互聯,單一廠商;開放:UCIe、ELSFP、CW-WDM 等標準介面,多廠商並存)。右半是池化資料中心示意:CPU 池、DRAM 池、SSD 池、GPU 池以光互聯跨機櫃連接。*

### 訪談原話

> **(受訪者)** 我看到整個光互聯其實有兩種模式,或者說兩種生態。一種是老黃、英偉達這種模式,它是一個閉環生態,我願意把它稱之為「蘋果生態」:什麼都自己幹,收購了 Mellanox,自己做 NVLink,自己做光互聯……但是我們願意做「安卓生態」。我希望把我們 open 給所有這樣的 GPU 公司。
>
> **(受訪者)** 以後的這樣一個數據中心,一定是池化的……CPU 的 pool、DRAM 的 pool、SSD 的 pool、GPU 的 pool,各種品牌的 pool,都可以用光來做 interconnect……整個巨大的算力中心,可能數百萬卡,就如同一張 GPU 在工作一樣。
>
> **(受訪者)** 我們不是要做下一個中際旭創……OIO 並不是要做一個更好的光模組,而是 OIO 要定義一個計算光互聯的新範式。

### 延伸說明

**「開放」的現實基礎。** 光互聯確實有幾個跨廠商的標準在成形:UCIe(晶粒互聯)、OIF 的 ELSFP(外部雷射模組)與 CMIS 管理介面、CW-WDM MSA(多波長光源規格)[G2][G4][H1]。Ayar Labs 的合作也印證了這個方向:它與 Alchip、GUC 等台灣 ASIC 設計公司結盟 [C7]。另一方面,NVIDIA 的 CPO 是與供應鏈夥伴共同開發、並把數百件專利授權給夥伴 [A2],也不是完全封閉。所以「蘋果 vs 安卓」是有用的比喻,但實況比二分法更複雜。

**池化與分離式資料中心。** Moazeni 的文章討論了讓 HBM 經共封裝光學被存取、以及把共封裝光學當作封裝內的「協處理器」,以支援分離式 AI 系統 [A1]。UCIe 加上 CXL 的光互聯也被設想用於資源池化,例如刀鋒伺服器內以 PCIe/CXL I/O 晶片、機架間以整合 UCIe 的光晶片 [H6]。這與受訪者的願景方向一致,但仍處於架構探索階段。

**需要同時看到的另一面。**
- 可靠度與可維修性:CPO 的固定配置與可替換性之間仍有取捨;雷射是主要失效風險,但 ELSFP 設計支援現場更換 [G1]。
- 可插拔仍是主流:有分析指出可插拔光模組仍是市場主流 [G1];LPO 作為不改外形的低功耗路線,正與 CPO 並行競爭 [B5]。
- 路線尚未收斂:Broadcom 已在規劃每通道 400G 的第四代 CPO [C3],台積電也把微環演進列為獨立路線 [I2],表示製程與架構仍在快速變動。
- 中國大陸的標準化努力:Frontiers of Optoelectronics 的 CPO 綜述(Tan 等人,2023)涵蓋了中國 CPO 標準化的討論,可作為了解大陸學界與產業界觀點的起點 [J1]。

### 查證註記
- 「數百萬卡如同一張 GPU」是願景而非現況;沒有找到公開資料證明該目標在近期可達。
- 受訪者對 NVIDIA 生態的描述是他個人觀點的簡化。

### 來源
- [J1] Tan 等,Co-packaged optics (CPO): status, challenges, and solutions,Frontiers of Optoelectronics 16(1), 2023 — https://link.springer.com/content/pdf/10.1007/s12200-022-00055-y.pdf

---

## 附錄 A|圖標題總表(請你確認)

| 圖 | 章 | 標題 |
|---|---|---|
| 圖 1 | I/O 牆 | 算力隨面積長,I/O 隨邊長長:I/O 牆的幾何 |
| 圖 2 | 光進銅退 | 從面板到晶片:光的下沉階梯與電通道長度 |
| 圖 3 | CPO/NPO/OIO | 光離晶片多近:可插拔、NPO、CPO、OIO 的位置圖,與 scale-out / scale-up 分工 |
| 圖 4 | 調製器 | 電壓如何變成光強:MZM 的干涉 vs 微環的共振 |
| 圖 5 | 微環優勢 | 窄而快 vs 寬而慢:邊密度到面密度,以及一根光纖上的多顆微環 |
| 圖 6 | 修調 | 對付波長飄移的兩條路:持續加熱鎖定 vs 一次性修調 |
| 圖 7 | 光源 | 光源怎麼供:外部雷射源(ELS)→ 光纖 → 光引擎,單波長陣列 vs 多波長光源 |
| 圖 8 | 電晶片 | 翻譯官:UCIe 電訊號 → 光 I/O 電晶片 → 微環 → 光纖 |
| 圖 9 | 封裝 | 光電怎麼疊在一起:COUPE 三階段路線與封裝剖面 |
| 圖 10 | 生態 | 兩種生態與一個願景:蘋果式整合、安卓式開放,以及資源池化的資料中心 |

## 附錄 B|建議先讀的論文(按重要性)

1. **修調核心**:B. Chen 等,*Real-time monitoring and gradient feedback enable accurate trimming of ion-implanted silicon photonic devices*,Opt. Express 26 (2018)——[F6]
2. **修調的晶圓級證據**:arXiv:2203.03503(300 mm 晶圓 ±32 pm)——[F7]
3. **微環加 WDM 加 CMOS 的起點**:Sun 等,*Nature* 528 (2015)——[H4]
4. **CPO 全景**:Tan 等,*Frontiers of Optoelectronics* (2023)——[J1]
5. **未來方向**:Moazeni,arXiv:2303.01744——[A1]
6. **多波長光源**:Rizzo 等,*Nature Photonics* 17 (2023)——[G7]
7. **微環熱控**:Padmaraju 與 Bergman,Opt. Express 20 (2012) 與 JLT 32 (2014)——[F1][F3]
8. **標準文件**:OIF-ELSFP-02.0——[G3];CW-WDM MSA 規格(cw-wdm.org)

## 附錄 C|已知缺口與建議處理

- **受訪公司的技術細節**(修調設備型號、99% 良率的定義、8/16 波長雷射規格):沒有公開論文或規格可驗證,正式稿建議向公司索取白皮書或加註「公司自述」。
- **微環單波 400G**:受訪者提及;本次未找到公開實例。
- **「算力十年一億倍」**:建議替換為有出處的數字。
- **NPO 的標準化現況**:我只找到零散說法,沒有正式規格。
- **憑記憶列出、本次未驗證的參考**:Miller (Proc. IEEE 2009)、Xu 等 (Nature 2005)、Reed 等 (Nature Photonics 2010)。使用前請核對書目資訊。
