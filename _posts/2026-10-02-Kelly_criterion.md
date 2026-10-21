---
layout: post
title: 再看凱利公式
subtitle: 正期望值的遊戲,為什麼還是會讓你破產
cover-img: /assets/img/header/2026-04-18/QUANTUM.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-18/QUANTUM.png
published: true
pinned: true
mathjax: true
tags: [draft, KellyCrit]
---

# 凱利公式:正期望值的遊戲,為什麼還是會讓你破產

> **結論先講:** 賺錢的關鍵不是「賭對」,而是「每次壓多少」。壓太多,即使勝率 60% 也會長期走向歸零;凱利公式算出的是讓財富長期增長最快、又不會歸零的下注比例;現實中因為勝率估不準,通常只用一半(半凱利)。

---

## 一、先看一道題

手上有 100 萬,贏了再賺 100 萬,輸了 100 萬全沒。勝率 60%。每次要壓多少?

多數人的直覺是壓一半,甚至梭哈。理由很直白:60% 的勝率已經過半,期望值也漂亮:

**期望值 = 0.6 × 100 萬 + 0.4 × (−100 萬) = +20 萬**

每局平均賺 20 萬,看起來穩賺。問題出在「平均」這兩個字。

---

## 二、期望值的漏洞:平行宇宙 vs 同一條時間線

期望值的算法,暗中假設你在 100 個平行宇宙裡同時各玩一把,再取平均。但現實中你只有一條時間線,而且是**不可逆**的。

- **單次下注**:一組平行的機率,可以重來。
- **連續下注**:一條時間線,一旦歸零就出局,後面的局都與你無關。

全倉的下場很直接:100 萬 → 200 萬 → 400 萬 → 第三把輸,歸零。你不需要連輸,**只需要輸一次**。

![全倉連續下注的存活機率](/assets/img/charts/fig1-all-in-survival.svg)

連續全倉 10 局,存活機率只剩約 0.6%。局數愈多,出局愈接近必然。

### 加法思維 vs 乘法思維

期望值是加法公式,把所有結果加總再平均。但連續下注是**乘法**:每一局的財富,都是前一局乘上一個係數。

- 贏:乘 2
- 輸:乘 0

任何數乘以 0 都是 0。把加法思維套在乘法過程上,就是認知陷阱。

---

## 三、波動拖累:不虧錢,也會變窮

就算不全倉,只要在一個波動大的遊戲裡待著,財富也會被悄悄吃掉。

**例一:先漲後跌**

100 → 漲 50% → 150 → 跌 50% → 75,虧 25%。
反過來先跌後漲,結果一樣是 75。漲跌幅度相同,最後一定虧。

**例二:每年漲 20% 或跌 20%,機率各半**

算術平均報酬是 0,但長期實際報酬約為負:

**長期報酬 ≈ 算術平均 − 波動 ÷ 2**(這裡「波動」指變異數:0.2 × 0.2 = 0.04)

**長期報酬 ≈ 0 − 0.04 ÷ 2 = −2%**

什麼都沒做,光是待在漲漲跌跌的過程裡,財富每年縮水約 2%。這個 2% 就是**波動稅**。倉位愈重、交易愈頻繁,繳的稅愈多。

**例三:跌容易,漲難**

跌 50% 要漲 100% 才能回本。跌幅愈大,缺口呈指數級擴大:

![回本所需漲幅](/assets/img/charts/fig2-recovery.svg)

---

## 四、有沒有最優的下注比例?

既然全倉、重倉會破產,輕倉也被慢慢侵蝕,那有沒有一個數學上算得出來的最優比例,讓你在正期望值的遊戲裡持續賺錢,又永遠不歸零?

1956 年,約翰·凱利(John Kelly)給了答案。

### 凱利是誰

他在貝爾實驗室工作,當時研究的是**長途電話線的雜訊**:信號太弱會被雜訊淹沒,信號太強又浪費頻寬。他把這個問題數學化後,發現它與賭博中的下注比例在結構上完全一致:

| 通訊問題 | 賭博問題 |
| --- | --- |
| 訊噪比 | 勝率與賠率 |
| 最優信號強度 | 最優下注比例 |

論文發表在《貝爾系統技術期刊》,標題是〈對資訊傳輸速率的新解釋〉(A New Interpretation of Information Rate)。據說凱利的初稿直接用賽馬當例子,貝爾的管理層覺得不體面;後來由資訊論之父**香農(Claude Shannon)**協助改寫成抽象的數學模型。

### 從賭桌到華爾街

香農把這個公式告訴年輕數學家**愛德華·索普(Edward Thorp)**。索普當時正在研究如何用數學打敗二十一點,帶著凱利公式去了拉斯維加斯,贏到被賭場列入黑名單。之後他把同樣的思路帶到華爾街,成立對沖基金 **Princeton Newport Partners**,從 1969 年運作到 1988 年。依原文,費後年化報酬約 15.1%,同期標普 500 約 8.8%,近 20 年沒有出現過虧損的季度。

所以凱利公式一開始不是為了賺錢,是研究電話線雜訊時意外發現的,但它的數學核心剛好回答了一個問題:**正期望值的遊戲,每次到底該壓多少?**

---

## 五、公式本身

**f\* = (b × p − q) ÷ b**

- **f\***:最優下注比例(佔「目前總資金」的百分比)
- **p**:勝率
- **q**:敗率(= 1 − p)
- **b**:淨賠率(贏了淨賺幾倍本金)

代入開頭的題目:p = 0.6,q = 0.4,b = 1:

**f\* = (1 × 0.6 − 0.4) ÷ 1 = 0.2 = 20%**

注意是**當前總資金**的 20%,不是初始本金的 20%:贏了資金變多,下一把壓更多;輸了資金縮水,下一把壓更少。這是一套動態調整的機制,它不預測漲跌,只在勝率與賠率已知的前提下,算出長期成長最快的比例。

### 它到底在最大化什麼

不是某一局的收益,而是**長期複利的成長率**。連續下注的財富是一串乘法因子連乘,例如 1.2 × 0.8 × 1.2 × 0.8 ……。凱利做的事是把連乘用對數轉成加法,再對下注比例求導、令導數為 0,解出來就是上面的公式。

以 60% 勝率、1:1 賠率為例,每局的長期對數成長率是:

**g(f) = 0.6 × ln(1 + f) + 0.4 × ln(1 − f)**

畫出來是一條先升後降的山形曲線:

![成長率與下注比例](/assets/img/charts/fig3-growth-curve.svg)

- f = 20%:山頂,成長最快
- f 約 39%:成長率回到 0,再往上壓就是負成長
- f = 50%:負成長,長期走向歸零

> **補充說明:** 固定比例下注在嚴格意義上不會「剛好」歸零(每次只拿一部分),而是財富的長期成長率為負,於是資金不斷縮水、趨近於零。原始講稿把它說成 100% 破產,是簡化的講法,方向是對的。

壓得太多,一次大虧就打回原形;壓得太少,浪費優勢。看看同一場遊戲、不同比例,100 局後的典型結果:

![不同下注比例的典型路徑](/assets/img/charts/fig4-typical-paths.svg)

以對數成長率估算(典型路徑,不是保證):f = 20% 約成長 7.5 倍;f = 10% 約 4.5 倍;f = 30% 約 4.4 倍;f = 50% 只剩約 0.03 倍。壓 30% 的結果竟然比壓 10% 還差,這就是過度下注的代價。

---

## 六、公式的前提:系統平均 vs 時間平均

凱利公式的推導,關心的是**時間平均**:同一個人反覆玩很多次,長期的平均成長率。

與之相對的是**系統平均**:同一時刻有大量獨立個體(平行世界),各玩一次再取算術平均。

如果一個系統是**遍歷性**(ergodic)的,兩者會收斂到同一個值,個人的長期經歷等於群體平均。但金融市場有一種「吸收態」:一旦破產就清零、無法回來。有吸收態時,兩者會撕裂。

**舉例:** 一個遊戲,正面賺 50%,反面虧 40%,機率各半。

- 讓 10 萬人各玩一次:群體平均財富增加(每局算術平均 +5%)。
- 讓一個人連玩很多次:每兩局的乘數是 1.5 × 0.6 = 0.9,每局約 −5.1%,絕大多數人的財富會趨近於零。

同一個遊戲,群體在賺,個人在虧。原因是群體裡,贏家的大額收益可以抵消輸家的損失,但你自己一旦虧光,沒辦法拿別人的贏來補自己的虧。

> **補充說明:** 遍歷性在數學與物理中是嚴謹的概念,但把它當作經濟學的新分析框架(例如 Ole Peters 一派),在學界仍有爭議,尚未成為共識。它不影響我們理解破產風險的數學結構。

---

## 七、什麼時候該壓,什麼時候不該玩

凱利公式最重要的訊息不是怎麼贏,而是**什麼時候不該玩**。

**期望值為零或負:公式給的答案是「不玩」。**

例如:勝率 40%,贏了賺 60%、輸了賠 100% 本金。直覺上 60% 的賠率挺誘人,代入公式:

**f\* = (0.6 × 0.4 − 0.6) ÷ 0.6 = −0.6**

負數,就代表不要下注。高賠率能製造「值得一搏」的幻覺,但算期望值是負的,玩愈多虧愈多。人的大腦本來就傾向高估贏的可能、低估輸的可能,賠率愈高,這個效應愈強。

**正期望值也不代表安全。** 正期望值只保證長期平均會賺,不保證你不會在中途死掉,它只管平均,不管你死在第幾次。

### 呼應芒格的一句話

查理·芒格曾說過大意如下的話:世界給你機會時,聰明的投資者會出重手;機會極大時下大注;其餘時間,只是等待。

翻成數學語言就是凱利公式:**勝率高、賠率好的時候壓得多;沒有優勢的時候不壓。** 巴菲特管理波克夏時,前五大持股常佔七成以上,他不是在分散投資,而是集中壓在他認為賠率極度有利的機會上。

---

## 八、現實中最危險的地方:估計誤差

凱利公式假設你**精確知道**真實的勝率和賠率。現實中我們只能估計,而估計常有偏差。

例子:你估某投資勝率 60%、賠率 1:1,算出 20%,於是按 20% 下注。但真實勝率其實只有 50%。

- 真實勝率 50%、賠率 1:1,期望值為 0,正確答案是一分錢都不壓。
- 你卻把 20% 壓在零期望值的遊戲上,長期被波動拖累慢慢吃掉。

![高估勝率的代價](/assets/img/charts/fig5-estimation-error.svg)

這就是凱利公式在現實中最危險的地方:**它吃你的估計精度**。估得愈不準,公式給的答案愈危險。

所以結論是:能用,但要先知道邊界。它最擅長的是勝率與賠率已知且穩定的情況;不擅長告訴你在資訊模糊的真實世界裡該相信哪個數字。

---

## 九、半凱利:現實中的折扣策略

索普的做法是:永遠假設自己的估計偏樂觀,把凱利公式算出的比例打折,實際下注通常只有理論值的一半甚至更少,也就是**半凱利**。

| 公式算出 | 實際壓 |
| --- | --- |
| 20% | 10% |
| 30% | 15% |

為什麼這個交換很划算?因為成長率對下注比例的敏感度是**不對稱**的:

- 在最優比例附近,往左偏一點,成長率下降得慢;往右偏一點,下降得快。
- 波動對下注比例是線性的:壓一半,波動少一半。

索普的說法是:壓一半凱利,大約能拿到四分之三的報酬,波動只有一半。驗算一下:全凱利成長率 0.0201,半凱利 0.0150,比值約 75%。

![半凱利的交換](/assets/img/charts/fig6-half-kelly.svg)

**回撤風險也大幅降低:** 在一段時間內曾損失一半本金的機率,全凱利大約是 1/2,半凱利降到約 1/8。

### 心理上的執行空間

我們是活生生的人,會恐懼、會貪婪。假設 100 萬本金連輸五把:

| 策略 | 每次下注 | 連輸五把後剩下 |
| --- | --- | --- |
| 全凱利 | 20% | 約 33 萬 |
| 半凱利 | 10% | 約 59 萬 |

剩 33 萬時,多數人會慌、會改策略、甚至直接梭哈;剩 59 萬就舒服很多。半凱利給你的不只是數學上的安全邊際,還有**心理上能把策略執行下去的空間**。

---

## 十、延伸:香農的惡魔

香農晚年在麻省理工的課堂上提出一個策略,後人稱為**香農的惡魔**(Shannon's Demon)。

假設有一個資產長期不漲不跌,但波動很大。把一半的錢放在它身上,一半放現金,每隔一段時間重新調回 50:50。

- 起點 1000:股票 500,現金 500
- 第一年股價腰斬:股票 250,現金 500,總資產 750
- 再平衡:股票 375,現金 375
- 第二年股價翻倍:股票 750,現金 375,總資產 1125

![香農的惡魔](/assets/img/charts/fig7-shannon-demon.svg)

股價從 1000 → 500 → 1000,回到原點,但總資產從 1000 變成 1125,多了 12.5%。

原因與波動拖累是同一件事的另一面:再平衡降低了組合的有效波動,減少了波動稅,讓報酬能更好地複利。**波動不只能被承受,也能被利用。**

> **補充說明:** 「香農晚年投資績效堪比巴菲特」只是傳聞,沒有公開數據可驗證。但「在兩個零報酬的波動資產之間再平衡確實能產生正報酬」這個數學原理本身是確定的。

---

## 十一、重點整理

| 問題 | 結論 |
| --- | --- |
| 期望值為什麼會騙人? | 它是平行宇宙的加法平均;你只有一條不可逆的乘法時間線 |
| 全倉、重倉的下場? | 全倉必然出局;重倉使長期成長率轉負 |
| 波動為什麼傷財富? | 波動拖累:報酬約等於算術平均減去變異數的一半 |
| 凱利公式算什麼? | 讓長期複利成長率最大的下注比例:f\* = (b × p − q) ÷ b |
| 什麼時候不玩? | 期望值為零或負時,公式給的是 0 或負數,答案是不玩 |
| 最大的風險? | 勝率、賠率是估的;高估優勢就等於過度下注 |
| 現實怎麼用? | 半凱利或更低:約 75% 的成長,換一半的波動和更小的回撤 |

最後只有一句話:**跑得快不重要,跑得久才重要。** 一旦歸零,所有的增長速度都和你無關。不下牌桌,就還有機會。

而剩下的難題是模型風險:當你的前提假設本身就是錯的,一個知道自己不知道的人,該按什麼比例下注?這個問題比前面所有的數學都難。

---

## 十二、實作:用 sizing.py 把凱利公式接進回測

前面講的都是原理。真正放進交易系統時,會碰到兩個問題:p、b 從哪裡來?怎麼確保算出來的倉位沒有偷看未來?`sizing.py` 就是針對這兩個問題寫的小模組,只依賴 numpy。

### 用意

回測系統裡常見的做法是固定倉位,例如永遠半倉。這很穩,但它和凱利公式沒有關係,策略有沒有優勢、優勢多大,倉位都不會變。`sizing.py` 做的是讓倉位**隨著策略已經驗證過的優勢調整**:

- 優勢明顯、樣本夠多,倉位放大
- 優勢很薄,倉位自動縮小
- 沒有優勢(f\* ≤ 0),倉位為 0,不下單

對應前文的三個重點:

| 前文的問題 | sizing.py 的處理 |
| --- | --- |
| 估計誤差(第八節) | p 取信賴區間下界,b 取保守估計,再加半凱利 |
| 樣本太少估不準 | 暖機期內不用凱利,固定小倉位 |
| 時間線不可逆、不能偷看未來 | 只用已平倉的交易,並附遮罩測試 |

### 輸入與輸出

- **輸入**:每筆已平倉交易的「淨報酬率」(已扣手續費,以投入資金為分母)與「出場 bar 的索引」`exit_bar`。
- **輸出**:在第 t 根 bar 收盤時,下一根開盤要投入的資金比例 f,範圍在 0 到上限之間。

執行時間點:**t 收盤後決策,t+1 開盤成交**,與 next-open 的回測規則一致。

### 基本用法

```python
from sizing import kelly_fraction, SizingConfig

# exit_bars: 每筆已平倉交易的出場 bar;rets: 對應的扣費後報酬率
f = kelly_fraction(exit_bars, rets, t)

qty = equity * f / next_open      # 下一根開盤的下單數量
```

要一次算出整段回測的倉位序列:

```python
from sizing import sizing_series
sizes = sizing_series(exit_bars, rets, n_bars)
```

要調整參數,建立設定物件即可:

```python
cfg = SizingConfig(kelly_mult=0.5, cap=0.20, min_trades=40)
f = kelly_fraction(exit_bars, rets, t, cfg)
```

### 內部流程

1. **篩選**:只取 `exit_bar < t` 的交易。未平倉的交易,結果在 t 時還不知道,不能算。
2. **暖機判斷**:已平倉少於 30 筆,或虧損少於 10 筆,直接回傳固定的 10% 倉位。
3. **估計 p**:勝率取 Wilson 下界,比單純的勝場數除以總場數保守。
4. **估計 b**:獲利與虧損分開做縮尾處理(winsorize,5/95 百分位),算出平均獲利 ÷ 平均虧損;再向先驗值 1.0 收縮,並取 bootstrap 的 25 百分位;兩者取較小值。
5. **代入公式**:**f\* = (b × p − q) ÷ b**,乘上 0.5 成為半凱利。
6. **夾住範圍**:結果限制在 0 到 25%。f\* 為負或零時倉位為 0。

另外附一個連續版 `kelly_fraction_continuous`,不拆成勝率與賠率,直接用 **f\* ≈ μ ÷ σ²**(μ 為報酬平均、σ² 為變異數),同樣打折並加上限。適合報酬分布不是二元結果的策略。

### 主要參數

| 參數 | 預設值 | 意義 |
| --- | --- | --- |
| `min_trades` | 30 | 暖機期所需的最少已平倉筆數 |
| `min_losses` | 10 | 暖機期所需的最少虧損筆數 |
| `warmup_fraction` | 10% | 暖機期的固定倉位 |
| `p_z` | 1.0 | Wilson 下界的 z 值,越大越保守 |
| `win_lo` / `win_hi` | 5 / 95 | 縮尾處理的百分位 |
| `b_boot_pct` | 25 | b 的 bootstrap 保守百分位 |
| `kelly_mult` | 0.5 | 凱利折扣,0.5 即半凱利 |
| `cap` | 25% | 單次倉位的硬上限 |

所有門檻要在回測前就固定,不要根據績效好壞回頭調整,否則等於把未來資訊塞進參數。

### 驗證:遮罩測試

`check_no_lookahead()` 的做法是:任選一個時間點 T,把 T 之後的所有交易結果換成亂數,重新計算倉位序列。T 以前的倉位必須與原本完全相同,只要有一個不同,就代表程式在決定倉位時用到了未來資料。

```python
from sizing import check_no_lookahead
assert check_no_lookahead(exit_bars, rets, n_bars)
```

### 限制

- **只能擋住 sizing 本身的洩漏。** 如果策略的參數是看過全部資料後才選的(例如布林通道倍數、均線長度),每一筆「過去的交易」本身已經帶著未來資訊,p 會偏樂觀。這種情況要改用 walk-forward 的樣本外交易,或把 p 當成上限再額外打折。
- **p 與 b 只是歷史統計。** 市場環境改變時,過去的優勢可能消失,所以才要下界、半凱利和硬上限三層保護。
- **持有期差異大時,連續版要小心。** σ² 是單筆報酬的變異數,若各筆交易的持有期長短不一,需先換算到同一時間尺度。

### 怎麼知道值不值得用

把「固定半倉」與「凱利動態倉位」放進同一個回測環境,比較最大回撤、Calmar 比率與期末資金。如果動態倉位在樣本外沒有明顯優於固定半倉,代表 p、b 的估計雜訊大於它帶來的資訊,這時維持固定比例反而更穩。回到本文的主題:凱利公式要的不是算得漂亮,而是在你**真的知道自己有多少優勢**的範圍內下注。

### 全部的 python code

```python
"""
sizing.py — Kelly position sizing from closed trades only (no look-ahead).

Input : per-trade net returns (after fees, as fraction of capital invested)
        + the bar index where each trade was CLOSED (exit_bar).
Output: fraction of equity to deploy at bar t, in [0, cap].

Rule: at bar t only trades with exit_bar < t are visible.
      Decide at close of t, fill at open of t+1 (next-open execution).
"""
from dataclasses import dataclass
import numpy as np


@dataclass(frozen=True)
class SizingConfig:
    min_trades: int = 30          # warm-up: fewer closed trades -> fixed small size
    min_losses: int = 10          # warm-up: fewer losing trades -> fixed small size
    warmup_fraction: float = 0.10
    p_z: float = 1.0              # Wilson lower bound z (1.0 ~ 84% one-sided)
    win_lo: float = 5.0           # winsorize percentiles (fix in advance, don't tune)
    win_hi: float = 95.0
    b_prior: float = 1.0          # shrink b toward this
    b_shrink_k: float = 10.0      # prior weight in "number of loss trades"
    b_boot_n: int = 500
    b_boot_pct: float = 25.0      # conservative bootstrap percentile of b
    kelly_mult: float = 0.5       # half Kelly
    cap: float = 0.25             # hard cap on fraction of equity
    seed: int = 0                 # deterministic bootstrap


def winsorize(x, lo=5.0, hi=95.0):
    """Clip values outside [lo, hi] percentiles to the percentile value (count unchanged)."""
    x = np.asarray(x, dtype=float)
    if x.size == 0:
        return x
    a, b = np.percentile(x, [lo, hi])
    return np.clip(x, a, b)


def wilson_lower(wins: int, n: int, z: float) -> float:
    """Wilson score lower bound of win rate."""
    if n == 0:
        return 0.0
    ph = wins / n
    d = 1 + z * z / n
    c = ph + z * z / (2 * n)
    m = z * np.sqrt(ph * (1 - ph) / n + z * z / (4 * n * n))
    return float((c - m) / d)


def _b_from(wins, losses_abs):
    return float(np.mean(wins) / np.mean(losses_abs))


def estimate_p_b(rets, cfg: SizingConfig):
    """Return (p_low, b_conservative) or None if not enough data."""
    rets = np.asarray(rets, dtype=float)
    wins = rets[rets > 0]
    losses = -rets[rets <= 0]            # absolute losses (zero-return counted as loss)
    n, nl = rets.size, losses.size
    if n < cfg.min_trades or nl < cfg.min_losses or wins.size < 1:
        return None
    wins = winsorize(wins, cfg.win_lo, cfg.win_hi)
    losses = winsorize(losses, cfg.win_lo, cfg.win_hi)
    if losses.mean() <= 0:
        return None

    p_low = wilson_lower(int(wins.size), n, cfg.p_z)

    # shrink b toward prior (weight by number of loss trades)
    b_hat = _b_from(wins, losses)
    b_shr = (nl * b_hat + cfg.b_shrink_k * cfg.b_prior) / (nl + cfg.b_shrink_k)

    # bootstrap conservative percentile of b
    rng = np.random.default_rng(cfg.seed)
    bs = []
    for _ in range(cfg.b_boot_n):
        w = rng.choice(wins, wins.size, replace=True)
        l = rng.choice(losses, losses.size, replace=True)
        if l.mean() > 0:
            bs.append(_b_from(w, l))
    b_boot = float(np.percentile(bs, cfg.b_boot_pct)) if bs else b_shr

    return p_low, min(b_shr, b_boot)


def kelly_fraction(exit_bars, rets, t: int, cfg: SizingConfig = SizingConfig()) -> float:
    """Fraction of equity to deploy, deciding at close of bar t. Only trades with exit_bar < t."""
    exit_bars = np.asarray(exit_bars)
    rets = np.asarray(rets, dtype=float)
    visible = rets[exit_bars < t]
    est = estimate_p_b(visible, cfg)
    if est is None:
        return cfg.warmup_fraction
    p, b = est
    q = 1.0 - p
    f_star = (b * p - q) / b             # f* = (b p - q) / b
    f = f_star * cfg.kelly_mult
    return float(np.clip(f, 0.0, cfg.cap))   # f <= 0 -> no position


def kelly_fraction_continuous(exit_bars, rets, t: int, cfg: SizingConfig = SizingConfig(),
                              per_period_vol_floor: float = 1e-8) -> float:
    """Continuous variant: f* ~ mu / sigma^2 on winsorized visible returns (then fractional + cap)."""
    exit_bars = np.asarray(exit_bars)
    visible = np.asarray(rets, dtype=float)[exit_bars < t]
    if visible.size < cfg.min_trades:
        return cfg.warmup_fraction
    x = winsorize(visible, cfg.win_lo, cfg.win_hi)
    var = max(float(np.var(x, ddof=1)), per_period_vol_floor)
    f = float(np.mean(x)) / var * cfg.kelly_mult
    return float(np.clip(f, 0.0, cfg.cap))


def sizing_series(exit_bars, rets, n_bars: int, cfg: SizingConfig = SizingConfig(), mode="binary"):
    fn = kelly_fraction if mode == "binary" else kelly_fraction_continuous
    return np.array([fn(exit_bars, rets, t, cfg) for t in range(n_bars)])


def check_no_lookahead(exit_bars, rets, n_bars: int, cfg: SizingConfig = SizingConfig(),
                       mode="binary", n_cuts: int = 5, seed: int = 1) -> bool:
    """Mask test: replace every trade with exit_bar >= T by garbage; sizes for t <= T must not change."""
    exit_bars = np.asarray(exit_bars)
    rets = np.asarray(rets, dtype=float)
    base = sizing_series(exit_bars, rets, n_bars, cfg, mode)
    rng = np.random.default_rng(seed)
    for T in rng.integers(n_bars // 4, n_bars, size=n_cuts):
        bad = rets.copy()
        m = exit_bars >= T
        bad[m] = rng.normal(0.5, 1.0, m.sum())       # garbage future
        alt = sizing_series(exit_bars, bad, n_bars, cfg, mode)
        if not np.array_equal(base[: T + 1], alt[: T + 1]):
            return False
    return True


if __name__ == "__main__":
    rng = np.random.default_rng(42)
    N = 400
    exit_bars = np.sort(rng.integers(5, N, size=120))
    rets = np.where(rng.random(120) < 0.55, rng.normal(0.03, 0.02, 120).clip(0.001),
                    -rng.normal(0.025, 0.01, 120).clip(0.001))
    s = sizing_series(exit_bars, rets, N)
    print("warmup bars:", int((s == SizingConfig().warmup_fraction).sum()),
          "| final f:", round(float(s[-1]), 4), "| max f:", round(float(s.max()), 4))
    print("no look-ahead (binary):    ", check_no_lookahead(exit_bars, rets, N))
    print("no look-ahead (continuous):", check_no_lookahead(exit_bars, rets, N, mode="continuous"))
```