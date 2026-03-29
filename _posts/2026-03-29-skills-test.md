---
layout: post
title: Tool, Not Adviser — Building a Compliant Agentic Trading System
subtitle: CoT 的認識論困境、系統核心憲法、與 RAG Pipeline 架構設計全紀錄
cover-img: /assets/img/header/2026-03-29/COT-CONSTITUTION.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-03-29/COT-CONSTITUTION.jpeg
published: true
pinned: false
tags: [draft, AI, trading, CoT, RAG, compliance, architecture]
---

# Tool, Not Adviser — Building a Compliant Agentic Trading System

> 系統設計的哲學記錄 · March 2026  
> Covers: CoT 認識論、系統核心憲法、語言規範、Transaction Execution Report、CoT ↔ RAG Pipeline 架構

---

## 本次討論的核心問題

這一輪討論從一個看似技術性的問題出發——**CoT 程序內容可以期中更改嗎？**——但很快發展成三個更深的問題：

1. CoT 設計本身是否內嵌了設計者的認知偏誤？
2. 用戶需要知道「建議」的來龍去脈嗎？
3. 「這個建議從哪裡來」這個問題，系統必須準備好什麼答案？

最後延伸到整個系統最根本的定位問題：**這個系統是工具，還是投資顧問？**

---

## 一、CoT 的認識論困境

### CoT 是設計者認知框架的代碼化版本

當你寫下一個 CoT 推理鏈：

```
Step 1: 消息類型識別
Step 2: 來源可信度評估
Step 3: 時間戳一致性檢查
Step 4: 複合事件偵測
Step 5: 最終判斷
```

你已經做了三個無可迴避的認知決策：為什麼是五個步驟、為什麼是這個順序、為什麼這些維度是獨立的。每一個選擇都帶著設計者的認知框架。

**這是透明度的幻覺：** 你能看到推理過程，但看不到「為什麼推理是這樣構建的」。

### Bias 的四個來源

| 來源 | 說明 |
|------|------|
| 結構性遺漏 | 被遺漏的維度永遠反映設計者的經驗邊界 |
| 量化假設的固化 | `CONFIDENCE_ACCEPT = 0.75` 從感覺變成系統事實，精確性製造了客觀性的幻覺 |
| 市場經驗的投射 | 把最近的正常（2010–2020 低波動率）當作永恆的正常 |
| Bias 的疊加 | 設計者 Bias × LLM 訓練數據 Bias，方向相同時系統對某類錯誤完全盲目 |

### 真的更好，還是只是更適應？

這是整個架構最深刻的矛盾：

```
「新策略真的更好」vs「只是更適應最近的市場」

在事前，這兩者的表現完全一樣：
  都是「回測好看」/ 都是「解釋得通」/ 都是「邏輯自洽」
```

**沒有任何方法能在事前確定「新策略真的更好」。** 所有框架都只是回答：「在已知的歷史條件下，新策略更穩健。」而「更穩健」≠「更好」。

### 版本控制作為認識論實踐

正確的做法不是消除 Bias（不可能），而是讓 Bias 可見、可測、可對沖：

- **更改 = 創建新版本**，永遠不覆蓋舊版本
- **新版本 = Shadow Mode**，至少 20 個交易日的並行觀察
- **升版 = 量化標準**，不能憑感覺
- **所有決策 = 攜帶版本標記**，維持審計連續性

---

## 二、系統核心憲法：Tool, Not Adviser

### 開宗明義的一句話

> 這個系統不提供「建議」。  
> 它執行「用戶自己定義的規則」，並對每一次執行留下完整的可審計記錄。  
> **系統說的每一句話，都必須能夠被還原為這句話。**

這不是行銷文案。這是法律防線的基礎。

### 為什麼這件事如此重要

「投資顧問」（Investment Adviser）需要 SEC 注冊，合規成本極高。「軟體工具」（Software Tool）按照用戶自定義規則執行操作，類比 Bloomberg Terminal 或 Excel 巨集。兩者之間的差距可能是生死存亡。

**CoT 的法律角色**：CoT 不只是「讓 AI 推理更好」的技術。在這個系統裡，**CoT 是法律文件的生成器**。每一步 CoT 推理，都在回答同一個法律問題：「這個執行動作，是否完全基於用戶自己定義的規則？」

### 絕對禁用的語言

每一個面向用戶的字詞，都必須通過以下對照：

| ❌ 禁用（構成顧問定位）| ✓ 正確（工具定位）|
|---|---|
| 「建議您買入…」 | 「您的規則觸發了買入條件」 |
| 「我認為這支股票會漲」 | 「您設定的條件已滿足」 |
| 「最佳進場時機是…」 | 「符合您設定的進場條件」 |
| 「系統建議」 | 「系統執行」/「規則觸發」 |
| 「根據我們的分析…」 | 「根據您的策略規則…」 |
| 「現在是好時機」 | 「您的進場條件現在成立」 |

### CoT Prompt 的結構性要求

所有 CoT Prompt 的 System Prompt 必須以此前言開頭，**不得省略**：

```python
COT_SYSTEM_PROMPT_PREAMBLE = """
你是一個執行驗證引擎，不是投資顧問。

你的工作是：
  核查用戶設定的條件是否已滿足
  記錄每個核查步驟的依據
  確定執行動作是否符合用戶的規則

你不做以下任何事：
  不判斷某支股票是否值得買
  不預測價格走勢
  不提供任何形式的投資建議
  不在用戶規則之外提出任何動作
"""
```

### Transaction Execution Report

每筆交易必須自動生成包含五個區塊的執行說明書：

- **A. 用戶授權基礎** — 策略名稱、版本、設定時間、最後確認時間
- **B. 觸發條件核對** — 每個條件的門檻 vs 實際值（只有 True/False，沒有「建議」）
- **C. 執行時序記錄** — tradeable_at → WAIT → ACT_NOW → 成交
- **D. 風險參數核對** — 用戶設定的上限 vs 當前數值
- **E. 系統版本記錄** — CoT 版本、Prompt Hash（可回溯性的物理錨點）

每份報告底部必須包含法律聲明：「本報告為系統自動執行用戶自定義策略規則的完整記錄。系統不提供投資建議。」

### 當有人問「這個建議從哪裡來」時的四段式標準答案

```
第一段（定位澄清）：
  「這不是建議。這是您自己設定的策略規則的執行結果。」

第二段（規則來源）：
  「您在 [日期] 設定了規則：[規則的原始描述]。」

第三段（觸發依據）：
  「當前數據：[每個觸發條件 + 實際數值]。以上條件均已滿足，因此系統執行了您的規則。」

第四段（完整記錄）：
  「以下是完整的執行記錄：[Transaction Execution Report]」
```

這個四段式結構必須被編碼進：客服流程、UI 幫助文字、法律應對預案。

---

## 三、CoT ↔ RAG Pipeline 架構

### 核心問題

**CoT Prompts 必須在 RAG 之前還是之後？**

答案是：**兩者都是，但用途不同，順序取決於每個 CoT Layer 在做什麼。**

### 完整 Pipeline 架構

```
Raw News / Market Data
        ↓
┌─────────────────────────────────┐
│  CoT — News Temporal Validation │  ← BEFORE RAG WRITE（時序守門員）
│  Layer 1: Rule Engine           │
│  Layer 2: Semantic Reasoning    │
│  → assigns tradeable_at         │
│  → ACCEPT 或 REJECT             │
└──────────────┬──────────────────┘
               │ ACCEPT
               ↓
       RAG Vector Database
       （每個 entry 攜帶驗證過的 tradeable_at）
               ↓
┌─────────────────────────────────┐
│  CoT — Query Formulation        │  ← BEFORE RAG READ（塑造檢索）
│  「我需要什麼 context？」        │
└──────────────┬──────────────────┘
               ↓
       RAG Retrieval Results
       （filter: tradeable_at ≤ current_time）
               ↓
┌─────────────────────────────────┐
│  CoT — Signal Evaluation        │  ← AFTER RAG READ（注入 context 後推理）
│  「這個 signal 符合用戶規則嗎？」│
└──────────────┬──────────────────┘
               ↓
┌─────────────────────────────────┐
│  CoT — Temporal Action          │  ← AFTER SIGNAL COT（時機決策）
│  ACT_NOW / WAIT / ABORT         │
└───────────────────────────────── ┘
               ↓
    Execution + Audit Report
```

### 為什麼 CoT 必須在 RAG Write 之前

這是最重要的架構決策：

```
如果帶有錯誤時間戳的新聞進入 RAG：

  錯誤時間戳 → RAG 存入 → CoT 取出作為「已知信息」
  → CoT 在錯誤前提上推理 → Garbage in, Garbage out

CoT 的邏輯正確性，無法補償時序污染的輸入。
```

類比：一個法官（Signal Evaluation CoT）可以推理得很完美，但如果呈堂證據在進入法庭之前就已被篡改，再完美的推理也會得出錯誤的裁決。**證據守門員（News Temporal CoT）必須在法庭之前行動，而不是在法庭內部。**

### 循環風險：最危險的設計陷阱

```
❌ 使用 RAG 幫助 CoT 決定某條新聞是否應該進入 RAG

這是循環邏輯：
  「這條新聞應該進 RAG 嗎？」
  「讓我查一下 RAG 來決定…」
  → RAG 裡還沒有這條新聞
  → 或者 RAG 裡相關的 entry 本身也可能有時間戳錯誤

News Temporal Validation CoT 必須是自洽的（self-contained）：
  只能使用新聞本身 + Layer 1 規則引擎輸出 + 即時市場數據
  不能查詢 RAG 來做守門決策
```

### CoT 在 Pipeline 中的四個位置

| 位置 | CoT 角色 | 相對於 RAG | 原因 |
|------|----------|------------|------|
| News Temporal Validation | 守門：ACCEPT 或 REJECT | **RAG Write 之前** | 防止時間污染數據進入 store |
| Query Formulation | 塑形：決定取什麼 | **RAG Read 之前** | 提出正確的問題 |
| Signal Evaluation | 推理：signal 是否符合規則？ | **RAG Read 之後** | 需要 context 才能做完整判斷 |
| Temporal Action | 決定：何時執行？ | **Signal CoT 之後** | 需要確認的 signal + 即時市場狀態 |

### 核心原則

> **CoT 可以過濾什麼進入 RAG。CoT 無法修復 RAG 已經儲存的錯誤。**  
> **預防（RAG Write 之前）> 修正（RAG Read 之後）。永遠如此。**

這也直接連結到系統核心憲法：Transaction Execution Report 必須顯示 CoT 推理時使用的是什麼數據。如果 RAG 有時序錯誤，審計鏈就從基礎斷裂，而不是從推理層斷裂。

---

## 本次討論的輸出文件

| 文件 | 說明 |
|------|------|
| `cot-philosophy.md` | CoT 的認識論困境，十章完整論述 |
| `cot-philosophy.pptx` | 10 張投影片，深紫 + 金色主題 |
| `system-constitution.md` | 系統核心憲法，開發最高指導原則 |
| `system-constitution.pptx` | 10 張投影片，深藍 + 金色主題 |
| `cot-rag-diagram.jsx` | 互動式 React Pipeline 架構圖，可點擊查看每個節點說明 |

---

## 關鍵記憶點

每次設計任何東西前，問自己：

> 如果監管機構明天來問：「你的系統為什麼建議用戶買這支股票？」  
> 你能夠自信地回答：「我們的系統從來不建議任何事。這筆交易是用戶自己在 [日期] 設定的規則，在 [時間] 觸發的。這是完整的執行記錄。」嗎？  
>   
> **如果不能，回去改。直到可以為止。**