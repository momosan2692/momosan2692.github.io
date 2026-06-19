---
layout: post
title: "Liquid Model vs Transformer：爬樹頂還是造火箭？"
subtitle: "從 Shopify 電商搜尋到藥物發現，Liquid AI 的真實邊界在哪裡"
cover-img: /assets/img/header/2026-06-19/liquid_ai.png
share-img: /assets/img/header/2026-06-19/liquid_ai.png
published: true
pinned: false
tags: [draft]
---
Liquid Model vs Transformer：爬樹頂還是造火箭？

從 Shopify 電商搜尋到藥物發現，Liquid AI 的真實邊界在哪裡 · June 2026
Covers: Liquid Neural Networks, LFM2 架構解析, 醫療 AI 應用評估, Transformer 比較, 月球笑話的深層意義
一個老笑話的新版本

有個老笑話是這樣的：一個 AI 機器人爬到樹頂，仰望月亮，心裡想著——「這樣我是不是離月亮近多了？」

把這個笑話稍微更新一下，2026 年的版本是：

機器人爬到樹頂，想著「這樣離月亮近多了」。
OpenAI 也在旁邊爬——只是那棵樹要 500 億美元才能爬上去。
這個笑話的核心，不是在嘲笑 Liquid AI 或 OpenAI 的技術能力。它指向的是一個更根本的問題：Transformer + scale 這條路，究竟是通往月亮的火箭，還是一棵越來越高的樹？

Liquid Neural Networks 是什麼？（不是行銷說的那樣）

學術源頭：真正的 LNN

Liquid Neural Networks 由 MIT CSAIL 的 Ramin Hasani、Mathias Lechner、Alexander Amini 和 Daniela Rus 開發。2021 年發表的 Liquid Time-Constant (LTC) Networks 論文 核心概念借鑒自神經科學：秀麗隱桿線蟲（C. elegans）只有 302 個神經元，卻能產生複雜行為，原因在於神經元之間的連接是動態的，而非固定的。

核心方程式：

dx/dt = -x/τ(x,I,t,θ) + f(x,I,t,θ) ⊙ A
其中 τ（時間常數）本身隨輸入動態變化——這就是「液態」的字面含義。2022 年 Nature Machine Intelligence 的後續論文 引入了 CfC（closed-form continuous-time）網路，用閉合解替代每步數值積分，解決了計算開銷問題。

一個只有 19 個神經元的 Liquid Network，能夠控制自動駕駛車輛。這不是誇大——是論文的實驗結果。

現實中的 LFM2：換了多少？

但 Liquid AI 賣給 Shopify、Insilico Medicine 的產品，是 LFM2——一個混合架構：

約 80% 的層：gated short convolution（門控短卷積）
約 20% 的層：Grouped Query Attention（GQA）
LFM2 Technical Report (arXiv:2511.23404) 明確描述其為「compact hybrid backbone」
這個架構在效率上是真實的進步，但它與原始 LNN 論文的 ODE 動態機制相差甚遠。LFM2 是一個 efficient hybrid architecture，不是嚴格意義上的 Liquid Neural Network。 品牌繼承大於技術繼承。

這是第一個需要清醒認識的地方：你看到的「Liquid」，大部分是行銷敘事，不是學術嚴格定義。
案例一：Shopify 電商搜尋 — Sub-20ms 的真實性

聲稱

Liquid AI 與 Shopify 的首個生產部署：一個在搜尋任務中完成推理、延遲低於 20ms 的文字模型。Shopify CTO Mikhail Parakhin 公開表示：

"No one else is delivering sub-20ms inference on real workloads like this. In some use cases, a model with ~50% fewer parameters beats Alibaba Qwen, Google Gemma, and still runs 2–10× faster."
來源：Liquid AI × Shopify 合作公告

月球背面：Transformer 的結構性瓶頸

Transformer 的自注意力在序列長度上的計算複雜度為 O(N²)。這對電商搜尋場景造成根本性瓶頸：每次 query 需要對所有 token 做 pairwise comparison。

現實是：大型電商（Meta、Pinterest、TikTok）的推薦系統從來不跑完整 LLM——他們跑的是 DLRM 或輕量 embedding 架構，因為 100ms+ 的 transformer 延遲在前端是死亡線。

Liquid 的 sub-20ms 填補了一個 Transformer 架構性無法佔領的空白，而非正面挑戰 GPT/Gemini 的主場。

可信度評估

維度	評估
技術聲明基礎	✅ Shopify CTO 外部確認，非僅自我宣傳
生產部署狀態	✅ 2025 年 11 月已上線，非 roadmap 承諾
「2–10×」量化聲明	⚠️ 範圍太寬，說明場景依賴性高
獨立第三方 benchmark	❌ 尚無公開獨立驗證
結論：核心主張可信，量化聲明需保留空間。

案例二：藥物發現 — LFM2-2.6B-MMAI

背景：Insilico Medicine 的 Rentosertib 里程碑

Insilico Medicine 是 AI 藥物發現的重要案例。Rentosertib（ISM001-055）成為第一個生物靶標和治療化合物均由 AI 設計的藥物：

TNIK 由 AI 辨識為纖維化新靶標
分子生成在 18 個月內完成
GENESIS-IPF Phase IIa 試驗於中國 22 個中心進行
2025 年 6 月發表於 Nature Medicine（IF=58.7）
患者在最高劑量下顯示肺功能改善（FVC 提升），而安慰劑組下降——在 IPF 這個幾乎沒有有效療法的疾病中，這是重要臨床信號。

來源：AIMonk — Generative AI in Life Sciences

Liquid AI × Insilico：LFM2-2.6B-MMAI

2026 年 3 月，Liquid AI 與 Insilico Medicine 合作發布 LFM2-2.6B-MMAI：

訓練資料：約 1,200 億 token 製藥數據，超過 200 種任務
涵蓋：ADMET 性質預測、多參數分子優化、蛋白口袋靶標評分、逆合成規劃
訓練框架：Insilico 的 Science MMAI Gym（含 SFT、RFT、RL）
benchmark 結果：

在 TDC（Therapeutics Data Commons）基準上，多個安全性與藥代動力學任務超越 TxGemma-27B（參數量為其 10 倍）
多參數分子優化任務成功率高達 98.8%
來源：Liquid AI × Insilico 合作公告 · Drug Target Review

月球背面：為什麼傳統 Transformer 在這裡真的有困難

1. 數據主權障礙（最根本）

製藥公司不能把專有分子結構傳到 OpenAI 的雲端。HIPAA、GDPR、各國個資法都是硬性限制。這使得 GPT-4、Claude、Gemini 在真實製藥場景幾乎無法合規使用。LFM 的 on-premise 部署在這個維度是真實突破，不是行銷話術。

2. 多任務 vs 多模型的工程地獄

傳統方案需要為 ADMET、分子生成、逆合成、蛋白質對接分別部署 ChemBERTa、MolBERT、ProtTrans 等不同專業模型，版本維護複雜。LFM2-2.6B-MMAI 以單一 checkpoint 替代這個拼接架構。

3. 「聰明小模型」現象的學術佐證

IntuitionLabs 的獨立分析指出：LFM2-2.6B-MMAI 在特定製藥任務上的表現可匹配 25–40 倍更大的模型。這與領域特化訓練（120B pharma tokens）的效果直接相關，而非純粹架構優勢。

來源：IntuitionLabs — Insilico Pharma AI 分析

可信度評估

維度	評估
TDC benchmark	✅ 公開第三方基準，可獨立驗證
On-premise 合規優勢	✅ 結構性真實，非行銷話術
「超越 10 倍大模型」	⚠️ benchmark 構成可能偏向 LFM 優勢任務
獨立性	⚠️ 雙方互利聯合公告，非獨立第三方
Liquid Model 適合醫療應用嗎？

醫療 AI 是一個堆疊，不是一個問題

臨床決策支援   ← LLM 層（推理、語言）
生理訊號監測   ← 時序層（連續感測器串流）
影像診斷       ← Vision 層（CNN/ViT）
藥物發現       ← 分子層（化學推理）
Liquid 的架構優勢集中在時序層。原始 LNN 的 ODE 動態機制天然對應連續時間的生理訊號——心電圖、血壓波形、腦電波、ICU 監測數據。這類數據的特徵恰好是 Transformer 最弱的地方：

連續抵達，不能等 batch
分佈會漂移（病人狀況動態變化）
需要低延遲即時反應
但 LFM2 產品線已偏離這個方向，走向通用小模型。理論上的 Liquid 適合醫療；現實中的 LFM2 適合的是醫療裡的 NLP 子任務（病歷摘要、藥物文獻問答），與 Transformer 的差異沒有想像中大。

現在是醫療應用的「最接近完美」選擇嗎？

直接答案：不是。 但它解決了一個真實的結構性障礙。

醫療需求	最佳現有選擇	LFM 的位置
On-premise 合規部署	LFM2 ✅ 領先	真實優勢
生理時序訊號即時分析	專用小模型（非 LLM）	理論優勢未兌現
臨床文件 NLP	Fine-tuned Transformer（BioGPT、Med-PaLM）	競爭力相當
可解釋性	傳統 ML（XGBoost、規則系統）	兩者都輸
幻覺控制與可靠性	無人解決	平手皆輸
LFM 現在最接近「完美適配」的醫療子場景只有一個：

需要在院內私有硬體上跑、對延遲敏感、任務相對明確的推理工作——例如藥物發現的分子優化，或 ICU 即時生理警報分類。
這是真實的利基，但距離「醫療 AI 的完美解」還差得很遠。

回到那個笑話

Transformer + RLHF + 更多 GPU + 更多參數，每一代都更接近「月亮」的感覺。GPT-3 → GPT-4 → GPT-5，hallucination 還在，reasoning 的天花板還在，真正的 world model 沒有，abstract concept 仍然無解。

Liquid AI 換了一根更細的樹枝爬，省了電費，但方向一樣。

真正的火箭問題是：

AGI = World Model + LLM + Memory + Agency + Abstraction

LLM 只是其中一項。OpenAI 把整棵樹當成火箭在賣。Liquid AI 至少誠實地說「我只是讓爬樹更省力」——這反而是它可信的地方。

月亮還在那裡。樹上的人越來越多。造火箭的，目前還沒有。

參考資料

來源	連結
Liquid Time-Constant Networks (Hasani et al., 2021)	arxiv.org/abs/2006.04439
CfC Networks — Nature Machine Intelligence (2022)	nature.com/articles/s42256-022-00556-7
LFM2 Technical Report (arXiv:2511.23404)	arxiv.org/abs/2511.23404
Liquid AI × Shopify 合作公告	liquid.ai/blog/shopify-partnership
Liquid AI × Insilico MMAI 合作公告	liquid.ai/press/insilico
LFM2-2.6B-MMAI — GeneOnline News	geneonline.com
Drug Target Review — LFM2-2.6B-MMAI	drugtargetreview.com
IntuitionLabs — Insilico Pharma AI 獨立分析	intuitionlabs.ai
Insilico × Liquid AI 技術深度介紹	insilico.com/blog/mmai-liquid-ai
Generative AI in Life Sciences — AIMonk	aimonk.com
Liquid Neural Networks 概覽 — AI News Digest	theainewsdigest.com
AMD × Liquid AI On-Device Meeting Summary	amd.com/blogs
LFM2.5 Fine-tuning 實測 — distil labs	distillabs.ai
Transformers in Drug Discovery — ScienceDirect	sciencedirect.com