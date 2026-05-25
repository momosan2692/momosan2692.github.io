---
layout: post
title: All about Tokens
subtitle: Tokens inside, what are TTFT ITL KV-Cache Swap
cover-img: /assets/img/header/2026-05-14/CEREBRAS.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-14/CEREBRAS.jpeg
published: true
pinned: false
mathjax: true
tags: [draft, AI]
---

Q: 如果發生 KV 快取遷移到 SSD 的情況，哪個參數明顯變慢？
A: 
---
當 vLLM 或任何推論引擎將 KV Cache 置換（Offload / Swap）到 SSD 時，最明顯、最劇烈變慢的指標就是 TTFT（Time-to-First-Token，首字延遲），其次是 Inter-token Latency（字與字之間的生成延遲）。
在硬體底層，一旦記憶體不足觸發 KV Cache 寫入或讀取 SSD，整個推論架構會從「光速的物理電路傳輸」退化為「慢速的磁碟 I/O 排隊」。以下是具體變慢的參數與背後原因：
------------------------------
## 1. 斷崖式暴跌的參數：TTFT (Time-to-First-Token)

* 表現： 當你送出一個長 Prompt 或 Agent 進行多輪對話切換時，模型會完全凍結。過去可能只需 0.2 秒就能蹦出第一個字，現在需要 5 秒、10 秒甚至更久。
* 原因（Context Prefill 阻塞）：
當 Agent 進行下一輪對話時，引擎必須去 SSD 把先前快取的舊對話 KV 矩陣（歷史記憶）重新載入（Load）回 GPU/記憶體中。雖然 Mac 的 NVMe SSD 很快（約 5GB/s-7GB/s），但與 M1 統一記憶體（最高 68GB/s-400GB/s）相比，速度慢了 10 到 80 倍。在舊記憶完全讀完之前，模型無法開始計算新 Token。

## 2. 嚴重卡頓的參數：Inter-Token Latency (ITL / 每秒生成字數)

* 表現： 模型開始吐字後，速度變得極不均勻。可能順暢地蹦出 3 個字，然後突然卡住 1 秒，再蹦出 2 個字（Tokens Per Second 降到個位數）。
* 原因（Continuous Swapping 搶道）：
如果你的 max-model-len（上下文長度）開太大，記憶體完全塞不下。vLLM 內部會啟動 PagedAttention Swap 機制：它一邊生成新字，一邊把最舊的 KV Cache 區塊（Blocks）踢到 SSD，同時又從 SSD 把需要的區塊拉回來。這導致 GPU 計算單元經常在原地「空轉（Stall）」，等待 SSD 的 I/O 中斷，吞吐量瞬間崩潰。

## 3. 系統指標：System CPU Wait / Disk Read-Write

* 表現： 如果打開 macOS 的「活動監視器（Activity Monitor）」，你會看到 CPU 使用率降到極低，但磁碟（Disk）的讀取與寫入量飆到每秒數個 GB。
* 原因： 計算核心（GPU/Neural Engine）沒事做，所有的時間都浪費在等待 SSD 快閃記憶體顆粒的搬移。

------------------------------
## 🛠️ 遇到 SSD Swap 時，在 vLLM 該如何自救？
在 32GB Mac 上，如果發現只要對話變長就開始出現上述的「死寂般卡頓」，說明已經踩到 SSD 快取。請立即調整以下參數強制關閉 Offload：

   1. 強制禁用 Swap 空間：
   在啟動指令加上 --swap-space 0。這會強制 vLLM「寧可因為記憶體不足而報錯崩潰（OOM），也絕對不准動用 SSD 進行慢速快取」。
   2. 壓縮 KV Cache 體積：
   加上 --kv-cache-dtype fp8。這會把原本 16-bit 的快取資料壓縮成 8-bit，直接讓記憶體容量翻倍，從根本上避免需要把快取擠去 SSD。
   3. 縮減最大上下文：
   將 --max-model-len 砍半（例如從 8192 降到 4096）。這是最直接有效的方法，能確保所有的 KV 矩陣死死地鎖在 32GB 的物理記憶體內。

如果你的 Agent 需要處理超過 10K 以上的超長文本，且不想犧牲速度，你或許可以考慮將模型的 Quantization（量化）等級從 Q4 改為更輕量的 Q2_K，或者換成我們先前提到過的 MoE（混合專家模型），這能大幅縮減 KV Cache 所佔用的空間！
---
