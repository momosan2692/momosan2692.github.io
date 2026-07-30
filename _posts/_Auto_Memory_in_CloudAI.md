「Auto-Memory」通常指的是大型語言模型（如 AI 程式碼編寫工具 Claude Code）中自動記憶與濃縮對話脈絡的功能。它會自動記錄你的專案背景、偏好設定與除錯習慣等，讓你不必每次開啟新對話時重複說明。 [1] 
除此之外，AI 領域也有針對機器人與代理（Agent）如何自行優化記憶的學術研究（如 AutoMem）。 [2, 3] 
## Claude Code 自動記憶功能 (Auto-Memory)
在 AI 編程工具中，此功能會在背景自動分析你與 AI 的互動。它具備以下特性： [1] 

* 自動濃縮：它會在你結束多個對話階段後，自動將關鍵資訊匯總並存入特定的記憶檔案（如 MEMORY.md）。
* 更新內容：記錄的項目包含專案背景、常用語法、編程風格與除錯習慣。
* 自動調用：下次啟動專案時，AI 會自動讀取這些記憶，無須重新輸入上下文。 [1, 4] 

你可以至 [Claude Code 更新介紹](https://www.threads.com/@aiposthub/post/DVP8OkPkZDf/video-claude-code-%E6%9B%B4%E6%96%B0%E4%BA%86%E4%B8%80%E5%80%8B%E5%BE%88%E9%97%9C%E9%8D%B5%E7%9A%84%E5%8A%9F%E8%83%BDauto-memory%E7%B0%A1%E5%96%AE%E8%AC%9B%E5%AE%83%E9%96%8B%E5%A7%8B%E6%9C%83%E8%A8%98%E4%BD%8F%E4%BD%A0%E5%9C%A8%E5%81%9A%E4%BB%80%E9%BA%BC%E9%80%99%E6%AC%A1%E7%9A%84%E6%9B%B4%E6%96%B0%E6%9C%83%E8%87%AA%E5%8B%95%E6%8A%8A%E5%B0%88%E6%A1%88%E8%83%8C%E6%99%AF%E9%99%A4%E9%8C%AF%E7%BF%92%E6%85%A3%E5%B8%B8%E7%94%A8%E5%AF%AB%E6%B3%95%E5%81%8F%E5%A5%BD%E9%A2%A8%E6%A0%BC%E7%AD%89%E8%B3%87%E8%A8%8A%E6%95%B4%E7%90%86%E9%80%B2%E4%B8%80) 了解這項功能的具體操作方式。
## AutoMem 學術研究
在 AI 學術界，這也是一項探討如何讓模型將「記憶管理」視為獨立學習技能的研究。 [2, 3] 

* 核心概念：讓模型自動決定如何使用與更新檔案系統記憶，而不修改原本的任務執行方式。
* 研究表現：優化記憶管理後，能大幅提升 AI 模型處理複雜或長週期任務的表現。 [3, 5] 

更多關於此演算法的技術細節，請參考 [AutoMem 論文摘要](https://arxiv.org/abs/2607.01224)。
如果你對 AI 記憶技術感興趣，請問你想了解：

   1. 如何設定與使用 Claude Code 的自動記憶？
   2. 還是想深入了解 AI 記憶的學術理論與架構？


[1] [https://www.threads.com](https://www.threads.com/@aiposthub/post/DVP8OkPkZDf/video-claude-code-%E6%9B%B4%E6%96%B0%E4%BA%86%E4%B8%80%E5%80%8B%E5%BE%88%E9%97%9C%E9%8D%B5%E7%9A%84%E5%8A%9F%E8%83%BDauto-memory%E7%B0%A1%E5%96%AE%E8%AC%9B%E5%AE%83%E9%96%8B%E5%A7%8B%E6%9C%83%E8%A8%98%E4%BD%8F%E4%BD%A0%E5%9C%A8%E5%81%9A%E4%BB%80%E9%BA%BC%E9%80%99%E6%AC%A1%E7%9A%84%E6%9B%B4%E6%96%B0%E6%9C%83%E8%87%AA%E5%8B%95%E6%8A%8A%E5%B0%88%E6%A1%88%E8%83%8C%E6%99%AF%E9%99%A4%E9%8C%AF%E7%BF%92%E6%85%A3%E5%B8%B8%E7%94%A8%E5%AF%AB%E6%B3%95%E5%81%8F%E5%A5%BD%E9%A2%A8%E6%A0%BC%E7%AD%89%E8%B3%87%E8%A8%8A%E6%95%B4%E7%90%86%E9%80%B2%E4%B8%80)
[2] [https://arxiv.org](https://arxiv.org/abs/2607.01224)
[3] [https://arxiv.org](https://arxiv.org/html/2607.01224v1)
[4] [https://institute.sfeir.com](https://institute.sfeir.com/en/articles/claude-code-dream-auto-dream-memory-consolidation/)
[5] [https://huggingface.co](https://huggingface.co/papers/2607.01224)


# Stanford U/nversity Auto-mem paper
Stanford 大學於 2026 年 7 月發表的學術論文 [AutoMem](https://arxiv.org/abs/2607.01224)，其核心思想是將「記憶管理」視為一種可以訓練的 AI 技能（Metamemory），這正是 Anthropic 在 Claude Code（於 2026 年初推出） 中所採用的「Auto-Memory 方案」在學術界與系統設計上的延伸與理論化。 [1, 2, 3, 4] 
以下為您梳理兩者的關聯性與技術演進對比：
## 1. 相同的核心設計思想：自主做筆記與檔案化
無論是學術界的 AutoMem 還是 Anthropic 的工程實作，都打破了過去「將對話歷史全部塞進 Context Window」或「單純依賴向量資料庫（Vector DB/RAG）」的傳統做法。 [4] 

* 相同點：兩者都賦予 AI 代理（Agent）自主讀寫檔案系統（File System）的權限（例如建立和修改 Markdown 檔案）。
* 運作機制：AI 扮演一個會「自己做筆記的工程師」。它在對話中發現新規則（例如：某個 Bug 的解法、編譯指令）後，會主動觸發寫入動作，將知識提煉並儲存在本地磁碟中（如 Claude Code 的 MEMORY.md 檔案）。 [1, 5, 6, 7, 8] 

------------------------------
## 2. 進化版：AutoMem 如何將 Anthropic 的方案理論化？
Anthropic 在 Claude Code 中實作的 Auto-Memory 主要是啟發式（Heuristic）與 Prompt 驅動的工程設計；而 AutoMem 論文 則是用學術和機器學習的方法，去解決 Claude Code 目前遇到的一些瓶頸： [1, 3, 4] 

| 比較維度 | Anthropic - Claude Code Auto-Memory | 學術論文 - AutoMem (Stanford, 2026) |
|---|---|---|
| 記憶儲存與結構 | 主要是精簡的 MEMORY.md 檔案，且有 200 行的讀取上限限制，避免 token 膨脹。 | 引入複雜的「圖與向量混合架構」。AI 可以自主發明新指令（如 UPSERT_MAP）來優化空間。 |
| 記憶整理機制 | AutoDream / /compact 模式：在背景或下達指令時，由 AI 整理並精簡凌亂的對話記憶。 | 雙迴圈優化（Dual-Loop）： 1. 外迴圈：由強大的 Meta-LLM 審視整段軌跡，調整記憶的架構與 Prompt。 2. 內迴圈：篩選正確的記憶決定，拿來強化模型本身。 |
| 檢索精準度 | 早期版本多偏向基礎的關鍵字匹配。如果筆記寫 A、你問 B（即使同義），可能就找不到。 | 透過多達 11 種關係類型（如 LEADS_TO 遞移關係）進行語義與圖形關聯檢索，提升複雜場景的召回率。 |
| 最佳化目標 | 解決工程師「不想每次重新設定專案背景」的痛點。 | 證明**「記憶管理是獨立可訓練的技能」**。測試發現，優化記憶後，中階開源模型（如 32B）即可在長週期任務中與 Claude 4.5 等旗艦模型匹敵。 |

------------------------------
## 總結
可以把 Anthropic 的 Claude Code Auto-Memory 視為這項技術在商業工程上的先行實踐者（證明了 AI 幫自己寫 Markdown 備忘錄是切實可行的）。而 2026 年 7 月的 AutoMem 論文 則是對這種「Agent 自主管理記憶檔案」的行為進行了深度理論化，並提出了如何透過自主訓練與自動調整結構，讓這種記憶模式更聰明、效率更高的框架。 [1, 4, 7, 9] 
如果您有興趣，我們可以進一步探討：

* 想要了解 Claude Code 內部 MEMORY.md 與 CLAUDE.md 的四層權限與覆蓋邏輯？
* 還是您想看 AutoMem 論文中，AI 如何在背景自主運作 LOG 與 PLAN 流程的技術細節？ [4, 10, 11] 


[1] [https://arxiv.org](https://arxiv.org/abs/2607.01224)
[2] [https://arxiv.org](https://arxiv.org/abs/2607.01224)
[3] [https://www.reddit.com](https://www.reddit.com/r/ClaudeCode/comments/1qzmofn/how_claude_code_automemory_works_official_feature/)
[4] [https://www.linkedin.com](https://www.linkedin.com/pulse/automem-treating-memory-trainable-agentic-skill-frontwalkersl-j6exc)
[5] [https://israynotarray.com](https://israynotarray.com/en/ai/2026/03/30/claude-code-auto-memory-complete-guide/)
[6] [https://abhishek-iiit.medium.com](https://abhishek-iiit.medium.com/claude-code-just-got-smarter-understanding-auto-memory-and-the-return-of-ultrathink-5ad3ea66ab34)
[7] [https://www.mindstudio.ai](https://www.mindstudio.ai/blog/what-is-claude-code-auto-memory)
[8] [https://www.linkedin.com](https://www.linkedin.com/posts/youssef-hosni-b2960b135_anthropic-rolled-out-a-new-auto-memory-feature-activity-7433186691554758656-VZDF)
[9] [https://israynotarray.com](https://israynotarray.com/ai/20260330/2896397295/)
[10] [https://www.mindstudio.ai](https://www.mindstudio.ai/blog/what-is-claude-code-auto-memory)
[11] [https://www.youtube.com](https://www.youtube.com/watch?v=7yn5DGvvqbY)

在 Claude Code 的架構中，CLAUDE.md 家族與 MEMORY.md（Auto-Memory）共同組成了 AI 代理的上下文載入體系。 [1] 
當你啟動一個新 Session 或執行指令時，系統會依據 「作用域優先級（由高到低）」 與 「讀寫權限（人工 vs AI）」 來載入並覆蓋規則。這套分層機制確保了團隊規範、個人偏好與 AI 自主記憶不會互相打架。 [1, 2, 3] 
------------------------------
## 一、 核心四層權限與覆蓋邏輯（由內到外，優先級最高至最低）
當多個檔案有衝突的指令時，層級越高（越局部、越偏向個人）的設定，會直接覆蓋低層級的設定。 [2] 

[最高優先級]
  └── 第 1 層：CLAUDE.local.md (本機覆寫層) ──── 優先級最高，覆蓋下方所有規則
        └── 第 2 層：Project CLAUDE.md (團隊專案層) ── 覆蓋全域設定，全隊共享
              └── 第 3 層：MEMORY.md (AI 自動記憶層) ──── AI 的筆記，會自動演進
                    └── 第 4 層：Global CLAUDE.md (全域偏好層) ── 最底層底色

## 1. 第一層：CLAUDE.local.md（本地個人覆寫層）

* 優先級：⭐ 最高（Top Priority）
* 權限：唯讀（使用者手動維護）。
* 位置：專案根目錄下（通常會加入 .gitignore，避免推上 Repo）。
* 覆蓋邏輯：此檔案中的規則會無條件覆蓋下方所有層級的同名或衝突規則。適合放你個人的特殊路徑、本機測試環境密鑰、或者你個人偏好的特定編譯參數（不影響團隊）。 [2, 4] 

## 2. 第二層：Project/CLAUDE.md（團隊專案規範層）

* 優先級：⭐⭐ 高
* 權限：唯讀（使用者與團隊維護）。
* 位置：專案根目錄（會 Commit 進 Git 與團隊共享）。
* 覆蓋邏輯：高於 AI 的自動記憶與全域設定。它是 Claude 在該專案的最高行為準則（Session 啟動時強制全量載入）。如果這裡規定「必須使用 pnpm」，即使 Global 寫 npm，Claude 都會聽此層的命令。 [2, 3] 

## 3. 第三層：MEMORY.md（AI 自主記憶層 / Auto-Memory）

* 優先級：⭐⭐⭐ 中
* 權限：✍️ 可讀可寫（AI 主動管理，使用者可透過 /memory 審計）。 [3, 5] 
* 位置：不在專案內，而是本機 Home 目錄：~/.claude/projects/<專案雜湊>/memory/MEMORY.md。 [6, 7] 
* 覆蓋邏輯：它會覆蓋 Global 的設定，但會被 Project 層壓制。這是 AI 的「私密日記本」，用來記錄對話中累積的動態知識（如：某個 Bug 的臨時解法、特定的架構習慣）。 [6, 8] 
* 特殊限制：為防止 Token 暴增，每次對話 Claude 只會讀取 MEMORY.md 的前 200 行（或 25KB），細節會由 AI 自主拆分到主題小檔案中。 [9] 

## 4. 第四層：Global CLAUDE.md（使用者全域偏好層）

* 優先級：⭐⭐⭐⭐ 最低（底色層）
* 權限：唯讀（使用者手動維護）。
* 位置：本機全域目錄 ~/.claude/CLAUDE.md。
* 覆蓋邏輯：這是你的「個人大原則底色」。例如「寫程式一定要加 Type 註釋」或「禁止把 API 金鑰寫入對話」。只要專案層沒有覆蓋它，它在所有專案中都有效。 [1, 2, 10] 

------------------------------
## 二、 常見的覆蓋與衝突情境解析## 情境 A：你在對話中對 Claude 說：「記住以後這個專案都用 Bun 執行」

   1. Claude 收到指令後，會觸發後台寫入機制（ExtractMemories），把這條規則寫入第 3 層的 ~/.claude/projects/.../memory/MEMORY.md。
   2. 下一個 Session 啟動時，Claude 會讀取此記憶，並默認使用 Bun。 [1, 7] 

## 情境 B：團隊的 Project/CLAUDE.md（第 2 層）寫著：「本專案一律使用 npm」

   1. 此時即便你在情境 A 讓 AI 把 Bun 記進了 MEMORY.md（第 3 層）。
   2. 因為 第 2 層（Project）的優先級高於第 3 層（Memory），Claude 載入上下文時會以 Project/CLAUDE.md 為準，直接忽略並覆蓋它自己在 MEMORY.md 寫下的 Bun 記憶，乖乖使用 npm。 [2] 

## 情境 C：你想暫時脫離團隊規範，在本機用 pnpm 測試

   1. 你只需要在專案根目錄建立 CLAUDE.local.md（第 1 層），寫入「Use pnpm for local development」。
   2. 由於 第 1 層優先級最高，它會直接蓋掉第 2 層團隊的 npm 設定、第 3 層的記憶與第 4 層的全域設定。 [2, 4] 

------------------------------
## 三、 使用這套架構的核心技巧

* 人管政策，AI 記事實：靜態的工作流程、團隊禁止事項、程式風格放 CLAUDE.md；AI 自己踩坑、Debug 的經驗讓它放進 MEMORY.md。
* 保持精簡，善用 @import：如果你的 CLAUDE.md 超過 200 行，請使用 @import 語法，將部分長規則移至 .claude/rules/ 資料夾，避免干擾模型的 Context 窗口。
* 使用 /memory 進行清理：因為 MEMORY.md 是 AI 自己寫的，用久了可能會堆積過期或錯誤的記憶。你可以輸入 /memory 查看目前載入的狀態，或手動要求 Claude 刪除特定本機記憶。 [3, 5, 6, 10, 11, 12] 

如果需要，我們可以進一步探討：

* 想看看一個標準且高效率的 CLAUDE.md 範例模板？
* 還是想了解當 MEMORY.md 滿了之後，Claude Code 內部的 autoDream 自動壓縮機制是如何運作的？


[1] [https://zhuanlan.zhihu.com](https://zhuanlan.zhihu.com/p/2023071035180811714)
[2] [https://www.shareuhack.com](https://www.shareuhack.com/zh-TW/posts/claude-code-claudemd-skills-setup-guide-2026)
[3] [https://guoxudong.io](https://guoxudong.io/xiaohongshu/claude-md-deep-dive/index-part2/)
[4] [https://moksaweb.com](https://moksaweb.com/claude-md-project-memory/)
[5] [https://moksaweb.com](https://moksaweb.com/claude-code-features-overview/)
[6] [https://claude-world.com](https://claude-world.com/zh-tw/articles/memory-system-guide/)
[7] [https://israynotarray.com](https://israynotarray.com/en/ai/2026/03/30/claude-code-auto-memory-complete-guide/)
[8] [https://www.youtube.com](https://www.youtube.com/watch?v=FRwZg6VOjvQ)
[9] [https://ithelp.ithome.com.tw](https://ithelp.ithome.com.tw/m/articles/10400396)
[10] [https://www.linkedin.com](https://www.linkedin.com/posts/elishlomo_cybersecurity-ai-activity-7433582516403552256-pgzm)
[11] [https://leoaido.com](https://leoaido.com/claude-code-memory/)
[12] [https://www.youtube.com](https://www.youtube.com/watch?v=e1F7zUWRm3w)
