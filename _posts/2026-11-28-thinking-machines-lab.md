---
layout: post
title: Thinking Machines Lab：西方開放權重陣營的領頭羊，與它的 Tinker 生意
subtitle: 從 Inkling 到 Inkling 2 Mini，一家成立 21 個月的實驗室如何同時發模型 賣後訓練
cover-img: /assets/img/header/2026-04-18/QUANTUM.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-18/QUANTUM.png
published: true
nolist: false 
pinned: true
tags: [draft, Agentic]
---




2026 年 11 月的前三週，Thinking Machines Lab 做了三件事。11 月 5 日，它在自家 Tinker 平台上推出 594B 參數的 Inkling 2 Small，權重暫不公開；11 月 12 日，這份權重以 Apache 2.0 授權上架 Hugging Face；11 月 20 日，26.4B 的 Inkling 2 Mini 跟著釋出，20GB 左右的 checkpoint，一台 32GB 的 Mac 就能跑。同一時期，Business Insider 報導 Accel 將領投一輪 50 億美元，投前估值 400 億美元。這家公司 2025 年 2 月才成立。

這篇整理它的人、錢、模型，以及對企業最實際的一個問題：後訓練該自己做，還是付錢給 Tinker。資料截至 2026 年 11 月 28 日，多數財務數字來自媒體報導與匿名消息來源，文中會標明。

## 創辦團隊：留下來的與離開的

Mira Murati 擔任 CEO，2024 年 9 月離開 OpenAI CTO 一職後創辦這家公司。John Schulman 是首席科學家，OpenAI 共同創辦人，PPO 與 RLHF 的主要推手，加入前在 Anthropic 待過一小段時間。Bob McGrew 與 Alec Radford 是顧問；前 OpenAI 的 Jonathan Lachman 也在團隊中。

人事震盪是這家公司這一年的主旋律。2025 年 10 月，共同創辦人 Andrew Tulloch 轉往 Meta。2026 年 1 月 14 日，Murati 在 X 上宣布與共同創辦人兼 CTO Barret Zoph「分道揚鑣」，並任命 Soumith Chintala 接任 CTO；不到一小時，OpenAI 的 Fidji Simo 宣布 Zoph、Luke Metz 與研究員 Sam Schoenholz 回到 OpenAI。外界對 Zoph 離開的原因說法不一，TML 方面的說法與 OpenAI 的回應並不一致，這裡不下定論。2026 年 7 月 27 日，共同創辦人 Lilian Weng 以健康因素宣布離職，OpenAI 隨後證實她回任。據報導，創始團隊約有三分之一已經離開。

所以現在的技術核心是 Murati、Schulman 與 Chintala 三人：Chintala 是 PyTorch 的共同創造者，2025 年底離開 Meta 後加入，從 2026 年 1 月起是 CTO，而不只是「技術成員」。

## 錢：估值躍升，但營收基數還小

時間線很短。2025 年 7 月，種子輪 20 億美元、估值 120 億美元，由 a16z 領投，NVIDIA、AMD、Accel、Cisco、ServiceNow、Jane Street 等參與，是史上最大的種子輪之一，當時產品都還沒出。2025 年底，Bloomberg 報導公司曾想以約 500 億美元估值再融資，談判最後作罷，外界普遍把它和核心成員出走連在一起，不過公司沒有證實兩者的因果。

2026 年 9 月，消息先傳出約 10 億美元、估值 400 億美元的洽談，Nvidia 也被報導有意參與；11 月 6 日，Business Insider 的報導把規模改成 50 億美元，Accel 領投，投前 400 億美元，換算投後約 450 億美元，並說最快當週完成。這裡有三個要留意的地方：

1. 這是報導，不是公告。公司對 Business Insider 的詢問不予置評，截至我查證時沒有找到公司或 Accel 的正式確認。
2. 若這輪照報導條件完成，累計公開募資約 70 億美元，這個數字不含 NVIDIA 2026 年 3 月那筆未揭露金額的投資。
3. 估值對應的營收：TechCrunch 9 月引述匿名消息來源，年化營收（run-rate）超過 1 億美元，主要來自 Tinker 的用量計費。400 億除以 1 億是 400 倍，但這是用已報導的下限算出的倍數上限，不是公司實際的倍數。

算力端有另一條線。2026 年 3 月，NVIDIA 與 TML 宣布多年期合作，至少 1GW 的 Vera Rubin 系統，2027 年初開始部署，外加一筆未揭露金額的投資。Inkling 本身是在 NVIDIA GB300 NVL72 上訓練的。

## 模型：四個型號，兩種路線

TML 的路線是稀疏 MoE 加上一個少見的選擇：把中等尺寸的模型做成可以本地跑。四個型號放在一起看：

| 型號 | 發布 | 總參數 / 活躍參數 | 輸入 | 權重 |
|---|---|---|---|---|
| Inkling | 2026-07-15 | 975B / 41B | 文字、圖片、音訊 | Apache 2.0 |
| Inkling Small | 2026 年 7 月底 | 276B / 12B | 多模態 | Apache 2.0 |
| Inkling 2 Small | 2026-11-05 | 594B / 17B | 文字、圖片 | 先封閉，11-12 起 Apache 2.0 |
| Inkling 2 Mini | 2026-11-20 | 26.4B / 3.4B | 文字、圖片 | Apache 2.0 |

四個型號的輸出都只有文字。

**Inkling** 是第一個旗艦：66 層、1M token 上下文、約 45T token 的文字、圖片、音訊、影片混合預訓練。音訊以 16kHz WAV 輸入，模型卡建議單段在 20 分鐘內，所以語音理解不需要另接 Whisper；要讓它「開口說話」則仍得外接 TTS。**Inkling Small** 是 276B 的蒸餾版，效果接近旗艦，體積約四分之一。

**Inkling 2 Small** 是 48 層的 decoder-only 架構，384 個專家每個 token 選 8 個，支援 1M 上下文與可調的推理強度。官方強調它在多項金融基準上是開放權重模型中表現最好的；Artificial Analysis 的 Intelligence Index 給它 31 分，並表示權重釋出後，這會是該榜單上中國以外開發的最高分開放權重模型。Tinker 上的定價是每百萬 token 輸入 0.30 美元、輸出 1.00 美元。它先封閉一週，是因為 TML 7 月 31 日發表的〈A safe path to open weights〉主張先 API、再受監控的託管微調、最後才視外部安全測試結果決定是否開放權重，因為權重一旦公開就收不回來。

**Inkling 2 Mini** 是這波最有話題的一款。它儲存 24 層，其中中間 12 層共用權重、每個 token 走三遍，等於 48 次層運算，活躍參數 3.4B，計入迴圈後約 5.4B。checkpoint 約 20GB，能在 32GB 的 Mac 上跑。TML 公布的 SWE-bench Verified 是 79.2%（bash-only 設定），SWE-bench Pro v2 Hard 77.9%，DeepSWE v1.1 為 48.2%，都領先同級的 Qwen3.8-27B 與 Gemma 4 31B。

這些分數要讀得保守一點。它們是廠商自報，不是第三方複測；Qwen3.8-27B 在 Terminal Bench 2.1（73.0% 對 71.6%）與 HLE 上仍然領先，Artificial Analysis 指數上兩者並列 20.1。所以「所有 100B 以下開放權重模型中的最強」這個說法，比較準確的版本是「在多數 agentic coding 基準上領先同級」。

至於「西方開放權重陣營的領頭羊」，這個標籤有根據，但來源是 Artificial Analysis 的排名與 TML 自己的基準表，不是一個客觀的定論；NVIDIA、Meta 等也都有開放權重模型。

## 和 OpenAI 的差別

兩家公司的人才幾乎同源，路線卻分岔。OpenAI 的主力是閉源模型加消費端的 ChatGPT；它的開放權重最大是 2025 年 8 月的 gpt-oss-120b（約 117B 總參數、5.1B 活躍），我沒有查到之後更大的 OpenAI 開放權重。TML 開放的是 975B 與 594B 這個量級。

商業模式的差別更大。Tinker 在 2025 年 10 月發表、12 月全面開放，把後訓練拆成幾個底層原語（sample、forward_backward、optim_step、save_state），使用者自己寫訓練迴圈，分散式系統的麻煩交給平台；訓練完的權重或 LoRA adapter 可以帶走。OpenAI 的 RFT 則是在它自己的伺服器上、以較高階的 API 調整它自己的模型。一邊賣算力與工具、讓客戶擁有結果，一邊賣能力、客戶租用，這是兩家公司最根本的分野。

## 後訓練：付給 Tinker，還是自己來

模型權重都能下載，企業就面對一個老問題：買，還是自己做。以下是推論，不是實測數據。

在 594B 到 1T 的量級，自己做的難度很高：多節點 GPU 叢集、高速互連，加上 RL 階段在推論 rollout 與梯度更新之間來回切換，閒置時間很難壓低。agentic RL 還要同時跑大量沙盒執行單元測試。這種工作量不穩定、尖峰很高，付使用費通常比自建叢集划算，這是 Tinker 最站得住腳的位置。

到了 26B 這一級，帳就不同。Inkling 2 Mini 的 checkpoint 只有 20GB，推論單張高階 GPU 或一台 32GB 以上的 Mac 就夠；LoRA 微調的記憶體需求比 20GB 高，但仍落在單機到少數 GPU 的範圍，Unsloth、Axolotl、TRL 這類開源工具可以直接處理 SFT 與輕量 RL。Tinker 在這個尺寸剩下的價值，主要是需要大量平行沙盒的 RL，以及先在小模型上驗證 reward 設計，再原樣搬到 594B。

## 內部部署：Mac Studio 叢集能做到什麼

對有「資料不出門」要求的國防、金融、醫療單位，Mac Studio 叢集是另一個選項，這個選項在 2026 年才真正存在：Apple 在 8 月 25 日發表搭載 M5 Ultra 的 Mac Studio，最高 512GB 統一記憶體、1.2TB/s 頻寬；9 月 22 日開始出貨，512GB 的組態延到 10 月底。

幾個可以核對的事實：M5 Ultra 的起價是 5,499 美元（96GB），目前查到最高的公開價是 256GB 加 16TB SSD 的 18,299 美元，512GB 組態的價格我沒找到。以此推算，四台 512GB 的總價很可能超出 4 到 5 萬美元，原始估算偏低。

吞吐量方面，我沒有找到任何實測。只能做一個粗算：解碼速度受記憶體頻寬限制，Inkling 的 41B 活躍參數以 4-bit 約 20GB，1.2TB/s 的單節點頻寬天花板約 58 token/s；叢集透過 Thunderbolt 5 切分後，實際值會比這個上限低。975B 以 4-bit 約 490GB，單台 512GB 放不下，要兩台以上。594B 的 LoRA 微調與 RL 的時間估算，同樣缺少實測支撐，我認為最合理的分工是：

- 本地叢集：日常私有推論、合成資料生成、26B 級模型的快速原型，以及針對內部資料的夜間 LoRA。
- 雲端或 Tinker：500B 以上的 RL 這類尖峰運算，完成後把權重下載回內部硬體長期部署。

## 還沒定論的幾件事

那輪 50 億美元要等公司或 Accel 確認才算數。1 億美元的 run-rate 來自單一匿名來源，成長曲線沒有公開。Inkling 2 Mini 的基準需要等第三方複測。人事方面，創始團隊流失之後，Schulman 與 Chintala 能不能撐住研究節奏，是估值之外更值得追的變數。

## 參考來源

Business Insider（2026-11-06）、TechCrunch（2026-01-14、2026-07-29、2026-09 run-rate 報導）、Thinking Machines Lab 官方文章與模型卡（Inkling、Inkling 2 Small、Inkling 2 Mini）、Hugging Face 模型頁、Artificial Analysis、MarkTechPost（2026-11-21）、Apple Newsroom（2026-08-25）、PetaPixel 與 MacRumors 的 Mac Studio 報導、OpenAI gpt-oss 發表文（2025-08-05）、Wikipedia。
