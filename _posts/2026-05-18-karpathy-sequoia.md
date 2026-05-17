---
layout: post
title: 你可以外包你的思考，但你不能外包你的理解
subtitle: Andrej Karpathy 談 Software 3.0 與 Agentic Engineering
cover-img: /assets/img/header/2026-05-12/karpathy-sequoia.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-12/karpathy-sequoia.png
published: true
pinned: true
tags: [draft]
share-title: "Karpathy：Software 3.0 時代，AI 工作者該如何定位自己"
---

幾個月前，Andrej Karpathy 在社群媒體上說了一句話，讓整個 AI 圈子都停下來想了一下：

「我作為一個 programmer，從未覺得自己如此落後過。」
但他不是在抱怨。他是在描述一種加速。

Karpathy 是 OpenAI 的共同創辦人之一，曾任特斯拉 AI 與自動駕駛視覺總監，「Vibe Coding」一詞的發明者，也是 AI 原生教育平台 Eureka Labs 的創辦人。2026 年 4 月底，他接受紅杉資本的訪談，用整整三十分鐘，把「2026 年的 AI 工作者該怎麼定位自己」這件事，講得非常清楚。

他用了兩個核心詞：Software 3.0 與 Agentic Engineering。

以下是這場訪談的精華整理，以及你今天就能開始做的事。

一、Software 3.0：遊戲規則已經換了

Karpathy 把軟體的發展分成三個版本。

Software 1.0 是傳統時代。人寫程式碼，電腦按規則執行。每一條邏輯都必須由工程師明確寫出來。

Software 2.0 是神經網路時代。你不再逐條寫規則，而是設計資料集與目標函數，訓練出一個模型，讓模型去學習規則。

Software 3.0 是現在，LLM 的時代。你不是在寫 function，而是在寫 prompt、管理 context window、指揮一個 AI 助理。Karpathy 的原話是：

「Your programming now turns to prompting.」
他用自己做過的一個 app「MenuGen」來說明這個轉變有多根本。MenuGen 的概念很直觀：出國吃飯看不懂菜單，拍下來，讓 app 辨識菜名並生成圖片，重新排版呈現給你。他用傳統思維完成了這件事：寫程式、串 API、做 UI，上線了。

然後他意識到一件事——這個 app 根本不該存在。

在 Software 3.0 的思維裡，使用者直接把照片丟給一個前沿模型，三句話內就拿到一模一樣的結果。沒有 app 的必要。Karpathy 自己說：

「That app shouldn't exist.」
他補充的那句話更關鍵：Software 3.0 不只是把舊事情做得更快，而是讓以前根本不可能的東西現在可以做到。

對你的啟發是什麼？

在動手做任何 side project 之前，先做一個簡單的測試：如果使用者可以直接把原始輸入丟給一個前沿模型，三句話內就拿到你 app 的輸出，那你這個 app 大概就不該存在。但如果你的產品能做到模型做不到的事——特定領域的資料、特殊的工作流程、可驗證的輸出——那才是真正值得建造的東西。

二、Jagged Intelligence：AI 強得驚人，也笨得荒謬

Karpathy 並沒有只講 AI 很猛的一面。他花了很多時間談「Jagged Intelligence」——鋸齒狀的智力。

網路上有個流傳很廣的例子：你問最前沿的模型，「我要去離我 50 公尺遠的洗車場，該開車去還是走路去？」模型回答：「50 公尺很近，走路去就好。」——但它完全忘了，車子本身必須開去洗車場才能被洗。

這就是 Jagged Intelligence 的具體樣貌。AI 的能力分布不是平滑往上的曲線，而是有高峰、有斷崖、忽強忽弱。

Karpathy 說，背後的原因有兩個。

第一，只有「可驗證的領域」，才能丟進強化學習環境裡跑大量循環。數學可以對答案，程式碼可以跑測試，安全漏洞可以驗證有沒有被利用——這些任務讓模型能夠嘗試、失敗、獲得 reward，在大量循環裡優化行為，能力才會飆升。

第二，實驗室實際有沒有把這個領域放進訓練分布。從 GPT-3.5 到 GPT-4，視覺推理能力進步很多，不是因為模型整體變強，而是有人決定把大量視覺符號資料加進 pretraining——資料進了訓練分布，能力就跟著起飛。

他把這兩個條件稱為「Verifiable plus Labs Care」：可驗證，加上實驗室願意把它當作重點去訓練。數學和程式碼兩個條件都到位，能力就最強；常識推理雖然有對錯，但沒有人系統性地建立大量情境資料，所以模型在這裡才會表現失常。

這對你意味著什麼？

Karpathy 說，傳統電腦容易自動化「你能 specify 的東西」；這一代 LLM 容易自動化「你能 verify 的東西」。如果你想用 AI 把某件事做好，第一個該問的問題不是「AI 能不能做」，而是「我能不能驗證它做對了」。能驗證，你就能讓 AI 跑一百次，挑最好的那次。不能驗證，你只能祈禱它這次運氣好。

三、Vibe Coding vs. Agentic Engineering：你的天花板在哪裡

Karpathy 在訪談中明確區分了這兩件事。

Vibe Coding 提高了所有人的下限。不會寫程式的人，現在也可以用自然語言做出一個能跑的小工具；會寫程式的人能更快完成 side project。整個軟體創造的入口變寬了。

Agentic Engineering 則代表了你的上限。它關心的是：專業軟體該有的品質——安全性、可維護性——你不能因為用了 AI 就放棄。你不能因為模型寫得快，就讓系統開始引入漏洞。你不能因為程式碼是 agent 寫的，就沒有人為它負責。

Vibe Coding 是「我有個想法，AI 幫我做出來就好」——消費者心態。Agentic Engineering 是「我設計好邊界、驗證機制、回滾策略，讓一百個 agent 幫我跑」——工程師心態。

Karpathy 自己在 2026 年 3 月做了一個叫「auto research」的實驗來證明這件事——社群後來把這個模式稱為 Karpathy Loop。他把自己的 LLM training code 丟給一個 agent，給它一個 metric，叫它自己改程式碼、跑訓練、看 metric，變好就留下，變差就回滾，然後放著讓它自己跑。兩天內，agent 跑了大約 700 個實驗，找到 20 個有用的改動，整體訓練時間縮短了 11%，還順便抓到一個他自己都漏掉的 bug。

這個 loop 的設計只有三個 constraint：

One file：agent 只能改一個叫 train.py 的檔案
One metric：就一個可以打分的數字
One time budget：每個實驗有時間上限，跑不完就斷
關鍵不是 agent 多聰明，是這三個 constraint 設計得夠乾淨。agent 不能偷改別的檔案，不能 hack 評分機制，不能跑太久浪費算力。它只能在這個被定義好的小盒子裡，瘋狂試錯。

後來有個叫 SkyPilot 的工具把同樣的 loop 跑到 16 顆 GPU 的 cluster 上，8 小時跑了 910 個實驗，總成本不到 300 美金——一頓不算貴的晚餐，換來九百多次實驗。Shopify 的 CEO Toby Lütke 用同樣的模式跑在內部資料上，8 小時 37 個實驗，拿到 19% 的提升。

這就是 Karpathy 說的「遠不止 10 倍」是什麼意思。

如果你正要開始下一個專案，動手前先花 30 分鐘回答三件事：

你要 agent 做到什麼？
你怎麼知道它做對了？
它出包的時候回滾到哪裡？
如果第二題你寫不出來，那這個任務還不夠 verifiable。先停下來，自己想清楚。這才是 Agentic Engineering 的起點。

四、細節可以外包，概念不能

訪談最後，主持人問了一個根本的問題：當過往價值連城的知識也變便宜之後，什麼東西還值得我們深入學習？

Karpathy 引用了一句他最近一直在想的話：

「You can outsource your thinking, but you cannot outsource your understanding.」

你可以外包你的思考，但你不能外包你的理解。
他自己的例子是：他現在已經不記 PyTorch 或 Pandas 那些 API 細節了，因為 agent 記得比他好。但他強調，底層概念不能忘——Tensor 是什麼、View 跟 Storage 是什麼關係、什麼時候只是換個視角看同一塊記憶體、什麼時候會 copy memory。這些是概念，不是 API 的名字。

他也舉了一個讓人警醒的例子：他做的菜單 app，登入用 Google 帳號，購買 credits 用 Stripe 刷卡。他的 agent 說，「那我用 email 把這兩邊配對好了——Google email 跟 Stripe email 一樣的就是同一個人。」

這個邏輯錯得非常根本：一個人完全可以用不同的 email 分別註冊 Google 和 Stripe。如果用 email 綁定資金歸屬，整個系統的購買紀錄和資金就會對不上，在生產環境裡慢慢炸開。正確做法是後端要有一個 persistent user ID，所有資金與 user state 都綁在這個 ID 上，不是綁在外部的 email。

agent 寫出來的程式碼可以跑，test 也走得過，但系統設計本身是錯的。這種錯誤不會出現在語法層，只會在 system level 默默累積。

這對你的時間分配意味著什麼？

技術細節應該交給 agent。你的時間要花在：判斷這個東西值不值得做、寫好 spec、看 trace、檢查 agent 有沒有在 system level 犯根本性的錯誤。

你用 AI 不是要變成更會打字的人。你用 AI 是要變成更會做頂層決策的人。

結語：AI 放大的，是願不願意深度思考的 ROI

Karpathy 的整場訪談，其實可以用一條邏輯線串起來。

Software 3.0 告訴你，遊戲規則換了，光是能做出來已經不再是門檻。Jagged Intelligence 告訴你，AI 的能力是鋸齒狀的，你必須理解它強在哪、弱在哪，才能在對的地方信任它。Agentic Engineering 告訴你，真正的工程師是組織一群會犯錯但很強的 agent 的人。而貫穿這三件事的核心，就是那句話——

細節可以外包，概念不能。思考可以外包，理解不能。

在這個範式裡，AI 不會自動把你變強。AI 真正做的事，是把「願不願意深度思考」這件事的 ROI 放大。過去那些願意搞懂底層的人，和那些只想趕快交差的人，差距可能是兩倍、三倍。在 AI 時代，這個差距會被放大成幾十倍、上百倍——因為前者能指揮一百個 agent，後者只能等 agent 給他答案。

不要把 AI 當成讓你少想一點的工具。要把它當成讓你想得更深的槓桿。