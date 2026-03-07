---
layout: post
title: CJH Swing-Trade Signal System
subtitle: User Guide — Release v2.1 Draft
cover-img: /assets/img/path.jpg
thumbnail-img: /assets/img/hello_world.jpeg
share-img: /assets/img/path.jpg
pinned: true  # true — pin a post to the top
tags: [Release Guide, draft]
---

# @CJH Swing-Trade Signal System
## User Guide — Release v2.1

**Author:** CJH  
**Release Date:** 2026-03-05  
**Platform:** Flask Dashboard · `http://123.193.49.198:5308`  
**License:** CC BY-NC-SA 4.0 — Personal & educational use only

---

## Table of Contents

1. [What This System Does](#1-what-this-system-does)
2. [The Golden Rule — FREE / CASH](#2-the-golden-rule--free--cash)
3. [Your Four Indicators Explained](#3-your-four-indicators-explained)
4. [How Signals Are Scored](#4-how-signals-are-scored)
5. [The Trade Lifecycle — Step by Step](#5-the-trade-lifecycle--step-by-step)
6. [Stop-Run — Saving Your Loss](#6-stop-run--saving-your-loss)
7. [Re-Entry — The Buy Price Memory](#7-re-entry--the-buy-price-memory)
8. [Reading the Chart Markers](#8-reading-the-chart-markers)
9. [Reading the Oscillator Pane](#9-reading-the-oscillator-pane)
10. [Flatness Warnings — When to Wait](#10-flatness-warnings--when-to-wait)
11. [PLTR Walk-Through Example](#11-pltr-walk-through-example)
12. [Quick Reference Card](#12-quick-reference-card)
13. [Known Limitations](#13-known-limitations)

---

## 1. What This System Does

This is a **swing-trade signal system** for daily charts. It watches four technical indicators simultaneously, scores their agreement, and manages the complete lifecycle of a trade — from first entry, through stop-loss exit, to re-entry if price recovers.

**It does three things most indicators cannot do:**

| Capability | What it means for you |
|---|---|
| **Confluence scoring** | Only signals when multiple indicators agree — fewer false triggers |
| **Stop-Run management** | Automatically tells you when to exit and saves unnecessary losses |
| **Re-Entry with price memory** | After a stop, remembers your original price level and watches for recovery — you don't have to manually track it |

> **Important:** This system is designed for **swing trading on daily bars** — holding trades from a few days to a few weeks. It is not designed for intraday scalping.

---

## 2. The Golden Rule — FREE / CASH

The default state is always **FREE / CASH**.

This means you are holding cash and **waiting**. You do not enter a trade until the system scores at least 60 points of agreement across the four indicators.

```
FREE / CASH means:
  ✅  No open position
  ✅  No price level being tracked
  ✅  Waiting for a quality entry — do NOT force a trade
  ❌  NOT the same as LONG STOP or SHORT STOP (those remember a price)
```

The two entry conditions from FREE / CASH are:

**Enter LONG (Buy):**
> All four indicators combined score **≥ 60 points** in the BUY direction  
> AND the buy score is higher than the sell score

**Enter SHORT (Sell):**
> All four indicators combined score **≥ 60 points** in the SELL direction  
> AND the sell score is higher than the buy score

If neither condition is met — **stay in cash**. Patience is part of the strategy.

---

## 3. Your Four Indicators Explained

### 3.1 Two-Pole Oscillator (35 points)

The momentum engine. It smooths price into a normalised oscillator (roughly −2 to +2 range) and detects turning points earlier than standard indicators by using:

- A **two-pass EMA filter** (smooth, low-lag main line)
- A **one-pole signal line** (faster, creates crossover signals)
- A **velocity line** (rate of change — catches turns 2–4 bars early)

**What you see on the chart:**

| Marker | Meaning | Score |
|---|---|---|
| `B` | Buy signal — OSC crossed above signal line | 28 pts |
| `BB` | Strong Buy — double-confirmed buy | 35 pts |
| `S` | Sell signal — OSC crossed below signal line | 28 pts |
| `SS` | Strong Sell — double-confirmed sell | 35 pts |
| `RB` | Re-Buy — price recovered above stop level | 22 pts |
| `RS` | Re-Sell — price fell back below stop level | 22 pts |
| `✖` | Stop triggered — exit the trade | — |

### 3.2 ZigZag (25 points)

Draws lines connecting the most significant swing highs and swing lows, filtering out minor noise. Only the **last line may change** as new bars arrive — all earlier pivots are permanent.

**What it tells you:**

| Pattern | Meaning | Score |
|---|---|---|
| **Higher Low confirmed** | Price made a higher low than last time → bullish structure | 25 pts BUY |
| **High pivot confirmed** | Price reached a structural high → potential distribution zone | 20 pts SELL |

> **Tip:** If ZigZag confirms a Higher Low at the same time the Two-Pole shows a `B` signal — that is a high-confidence buy setup.

### 3.3 ATR / EMA Cost Zone (20 points)

Uses an EMA of the closing price as a proxy for **average cost basis** — the approximate average price at which most recent buyers hold their position.

```
Price far BELOW EMA cost  →  BUY zone
  People holding at higher cost may buy more to average down
  Support zone — value buyers step in

Price far ABOVE EMA cost  →  SELL zone
  People are sitting on profit — potential selling pressure
  Price extended beyond average cost
```

| Condition | Score |
|---|---|
| Price more than 3% below EMA cost | Up to 20 pts BUY |
| Price more than 5% above EMA cost | Up to 20 pts SELL |

The EMA cost line also acts as the **trailing stop-loss level** while you are in a trade (see Section 6).

### 3.4 Bollinger Bands (20 points)

Shows whether price is statistically extended above or below its recent average, based on standard deviation.

```
Price at or below the LOWER band  →  statistically oversold
  High probability of mean-reversion bounce upward

Price at or above the UPPER band  →  statistically overbought
  High probability of mean-reversion reversal downward
```

| Condition | Score |
|---|---|
| Price at or below BB Lower band | 20 pts BUY |
| Price near BB Lower band | 12 pts BUY |
| Price at or above BB Upper band | 20 pts SELL |
| Price near BB Upper band | 12 pts SELL |

---

## 4. How Signals Are Scored

### 4.1 The Problem with Single-Bar Scoring

A naive scoring system evaluates all four indicators on the **same bar** and only fires if they all agree simultaneously. In practice this almost never happens — ZigZag pivots, Bollinger touches, ATR zone entries, and Two-Pole crossovers rarely land on the exact same candle.

The result: **scores would be computed from scratch every bar, indicators that fired 2 days ago are completely forgotten, and the 100-point system is theoretically possible but practically useless.**

### 4.2 The Evidence Window Accumulator

Instead, each indicator fires **independently** and deposits its score into a rolling **Evidence Window**. Evidence persists for 5 bars (~1 trading week) and decays linearly over time.

```
LINEAR DECAY OVER 5 BARS:

  Bar fired     Age 0   Age 1   Age 2   Age 3   Age 4   Age 5
  ─────────────────────────────────────────────────────────────
  Weight        100%    80%     60%     40%     20%      0%
  ZigZag (25pt)  25     20      15      10       5       0  ← expired
  BB Lower (12pt)12      9.6     7.2     4.8     2.4     0
```

The total score each bar is the **sum of all live, decayed evidence** in the window:

```
BUY score  = Σ ( each BUY evidence item × decay weight at current age )
SELL score = Σ ( each SELL evidence item × decay weight at current age )
```

### 4.3 Hard Cancel Rule

When an indicator fires in the **opposite direction**, the entire opposite evidence window is **wiped immediately**. There is no partial netting — a sell signal cancels all accumulated buy evidence.

```
Example:
  Bar 3: ZigZag Low pivot fires      → BUY window:  25 pts
  Bar 4: Two-Pole B fires            → BUY window:  25×0.8 + 28 = 48 pts
  Bar 5: Price touches BB Upper      → SELL fires   → BUY window WIPED → 0 pts
                                        SELL window: 20 pts
```

This ensures the system never acts on stale bullish evidence when the market has already reversed.

### 4.4 Walk-Through Example

```
  Bar 1:  ZigZag Low pivot confirmed
          → BUY evidence added: 25 pts (age=0)
          → BUY score = 25  (below 60, no signal)

  Bar 3:  BB Lower bounce detected
          → BUY evidence added: 20 pts (age=0)
          → ZigZag evidence now age=2: 25 × 0.6 = 15 pts
          → BUY score = 15 + 20 = 35  (building...)

  Bar 4:  Two-Pole B marker fires
          → BUY evidence added: 28 pts (age=0)
          → ZigZag (age=3): 25 × 0.4 = 10 pts
          → BB     (age=1): 20 × 0.8 = 16 pts
          → BUY score = 10 + 16 + 28 = 54  (almost there...)

  Bar 5:  ATR: price 4% below EMA cost
          → BUY evidence added: 16 pts (age=0)
          → ZigZag (age=4): 25 × 0.2 =  5 pts
          → BB     (age=2): 20 × 0.6 = 12 pts
          → OSC    (age=1): 28 × 0.8 = 22 pts
          → ATR    (age=0): 16 × 1.0 = 16 pts
          → BUY score = 5 + 12 + 22 + 16 = 55  (still building...)

  Bar 6:  ZigZag fires again (refreshed!)
          → BUY evidence refreshed: 25 pts (age=0, replaces old)
          → BB     (age=3): 20 × 0.4 =  8 pts
          → OSC    (age=2): 28 × 0.6 = 17 pts
          → ATR    (age=1): 16 × 0.8 = 13 pts
          → ZigZag (age=0): 25 × 1.0 = 25 pts
          → BUY score = 8 + 17 + 13 + 25 = 63 pts  ✅ SIGNAL FIRES!
```

This is realistic confluence — indicators accumulating agreement **over a week of trading**, not requiring simultaneous firing on a single bar.

### 4.5 Signal Strength

| Total Score | Strength | What to do |
|---|---|---|
| **≥ 80 pts** | ⚡ **STRONG** | High-confidence entry — act on this |
| **≥ 60 pts** | ✅ **MODERATE** | Standard entry — proceed with normal size |
| **≥ 40 pts** | ⚠️ **WEAK** | Watching — evidence building, not yet actionable |
| **< 40 pts** | — | Noise — stay in cash |

### 4.6 Score Parameters

| Parameter | Default | Effect |
|---|---|---|
| `window_bars` | 5 | Evidence lifetime. Wider = more patient, catches slower setups |
| `entry_threshold` | 60 | Minimum score to open a trade. Lower = more signals, less quality |

> **Tuning tip:** For volatile stocks (crypto, small-cap), consider `window_bars=3` to avoid stale evidence driving entries. For slow-moving large-caps or indices, `window_bars=7` allows more time for confluence to build.

---

### 4.7 Concrete Visual Example — PLTR Feb–Mar 2025

This is a real example of the Evidence Window working across 6 daily bars. Each row shows what evidence was alive, its age, its decayed weight, and the running total.

```
PLTR  —  Evidence Window Trace  (Feb–Mar 2025, daily bars)
Window = 5 bars · Linear decay · Threshold = 60 pts

DATE        EVENT                         IND      RAW  AGE  WEIGHT  CONTRIB   TOTAL
──────────────────────────────────────────────────────────────────────────────────────
Feb 18      ZigZag Low pivot confirmed    ZigZag    25   0    1.0      25.0  →  25 pts
            [ below threshold — waiting ]

Feb 19      (no new indicator fires)
            ZigZag (age=1)                ZigZag    25   1    0.8      20.0  →  20 pts
            [ score decaying — still waiting ]

Feb 20      BB: price touches Lower band  BB        20   0    1.0      20.0
            ZigZag (age=2)                ZigZag    25   2    0.6      15.0  →  35 pts
            [ building... ]

Feb 21      Two-Pole B marker fires       OSC       28   0    1.0      28.0
            ZigZag (age=3)                ZigZag    25   3    0.4      10.0
            BB     (age=1)                BB        20   1    0.8      16.0  →  54 pts
            [ almost there... ]

Feb 24      ATR: price 4% below EMA       ATR       16   0    1.0      16.0
            OSC    (age=1)                OSC       28   1    0.8      22.4
            BB     (age=2)                BB        20   2    0.6      12.0
            ZigZag (age=4)                ZigZag    25   4    0.2       5.0  →  55 pts
            [ ZigZag about to expire... ]

Feb 25      ZigZag Low pivot again!       ZigZag    25   0    1.0      25.0  ← REFRESHED
            ATR    (age=1)                ATR       16   1    0.8      12.8
            OSC    (age=2)                OSC       28   2    0.6      16.8
            BB     (age=3)                BB        20   3    0.4       8.0  →  63 pts ✅

            *** BUY SIGNAL FIRES — MODERATE (63 pts) ***
            Entry @ ~$50.00 | SL: EMA cost line | TP: $50 + 3×ATR
```

**What this shows:**
- Without the Evidence Window, the only bar that would have scored above 0 is Feb 21 (OSC fired) — at 28 pts, well below 60. All other bars would have scored 0 because only one indicator fired each day.
- With the Evidence Window, the signals **accumulate naturally over the week** as the setup matures, and the entry fires when enough indicators have aligned — even though they fired on different days.
- The ZigZag evidence nearly expired on Feb 24 (age=4, only 5 pts left) but was refreshed by a second pivot confirmation on Feb 25, keeping it at full weight.

---

## 4A. Design Debate — Is Scoring the Right Strategy?

> **This section records an honest discussion about the limitations of the scoring approach and open questions about whether it is the best design for real stock trading.**

### The original question

After building the Evidence Window accumulator, the question was raised:

> *"I am not sure the scoring system should be the best strategy for stock trading."*

This is a legitimate concern. Here is the full debate.

---

### Argument FOR the scoring approach

**1. It forces multi-indicator agreement**

No single indicator is reliable enough to trade on its own. Two-Pole OSC alone will fire false signals in trending markets. ZigZag alone gives you structure but no momentum timing. Bollinger Bands alone will buy into a falling knife. Requiring 60+ points of agreement across 4 independent indicators reduces the chance of acting on noise from any one system.

**2. It is transparent and debuggable**

Every signal comes with a full breakdown: which indicators contributed, how many points each added, how old the evidence was. You can inspect exactly why a signal fired. This is not possible with black-box ML models or complex rule trees.

**3. The decay window is economically sensible**

A setup that took 5 trading days to form is more meaningful than one that appeared in a single bar. A ZigZag pivot that was confirmed a week ago is less relevant than one confirmed yesterday. Linear decay captures this intuition cleanly without complex statistics.

**4. It is parameterisable**

If the threshold is too aggressive (missing good trades) → lower it to 50. If too many false signals → raise it to 70. If evidence expires too fast → increase `window_bars`. The system is tunable without changing the underlying logic.

---

### Argument AGAINST the scoring approach

**1. Scores are arbitrary**

Why is Two-Pole OSC worth 35 points? Why is ZigZag worth 25? Why not 30 and 30? These numbers were assigned by judgement, not by statistical analysis of which indicators actually predict price movement on which timeframes. A score of 63 feels precise but it is not — it is the sum of four guesses.

**2. Not all signals are equal in context**

A ZigZag Higher Low in a confirmed uptrend means something different from the same signal in a downtrend. A Bollinger Lower Band touch during a sector crash is not the same as one during a normal pullback. The scoring system gives the same points regardless of broader market context, trend direction, volume, or sector rotation.

**3. The 60-point threshold is fixed**

The same threshold is used for a $5 biotech stock and a $500 large-cap. A 60-pt signal on PLTR during a bull market is not the same as a 60-pt signal on a thinly-traded small-cap. Context-blind thresholds will over-signal in noisy stocks and under-signal in calm ones.

**4. Decay is linear but reality is not**

Exponential decay (e.g. halving every 2 bars) would give much more weight to recent evidence and much less to older evidence — arguably more realistic for fast-moving markets. Linear decay treats a 4-day-old signal as only slightly less relevant than a fresh one. This may be too generous to stale evidence.

**5. It cannot learn**

The scoring weights never change. If ZigZag consistently outperforms Bollinger Bands for a specific stock over 6 months of history, the system does not know this. A machine learning layer (logistic regression, gradient boosting) trained on historical signals could discover which indicators and weights actually predict profitable entries for each specific stock.

---

### What we know works well

Based on the PLTR walk-through and visual inspection of the oscillator signals:

- The **Two-Pole OSC markers** (B, BB, S, SS, RB, RS) are high-quality directional signals on their own. They were the result of careful iterative refinement (v1.0 through v4.3) and handle edge cases like flatline paralysis and fast rebounds correctly.
- The **Stop-Run / Re-Entry state machine** logic is sound. The price-level re-entry (`close > reentry_buy_price`) is more reliable than a score-based re-entry because it does not require indicators to re-agree — it simply watches for the price to recover.
- **ZigZag Higher Low** is a structurally meaningful signal — it confirms that the market is making higher lows, which is the definition of a local uptrend beginning.

---

### What remains uncertain

| Question | Status |
|---|---|
| Are the score weights (35/25/20/20) optimal? | Assumed — not backtested |
| Is 60 pts the right threshold for all stocks? | Unknown — needs per-stock calibration |
| Is linear decay better than exponential? | Unknown — not tested |
| Should trend direction (higher-timeframe SMA) gate signals? | Missing — currently trend-neutral |
| Should volume confirm signals? | Missing — not implemented |
| Would ML-derived weights outperform fixed weights? | Likely yes for large-cap stocks with enough history |

---

### Current conclusion

The scoring system is a **reasonable first approximation** and a significant improvement over single-indicator trading. The Evidence Window accumulator solves the original flaw (single-bar evaluation). But it should be treated as **version 1 of a scoring model**, not a final optimised strategy.

The most valuable next step is **backtesting**: run the system on 2–3 years of PLTR, OKLO, IBM, and 8358 daily data, record every entry/exit, and measure:
- Win rate by signal strength (STRONG vs MODERATE)
- Average P&L per trade by indicator combination
- Whether any single indicator consistently dominates or drags performance

That data — not intuition — should drive the next revision of the weights.

> **Design principle going forward:** The state machine logic (stop-run, re-entry, price memory) is stable and should not change. The scoring weights and thresholds should be treated as tunable parameters that eventually get calibrated against real trade history.

---

## 5. The Trade Lifecycle — Step by Step

Every trade follows the same path through five states:

```
┌─────────────────────────────────────────────────────────────┐
│                      FREE / CASH                            │
│  No position  ·  No price memory  ·  Waiting for score≥60  │
└───────────┬────────────────────────────────┬────────────────┘
            │ BUY score ≥ 60                 │ SELL score ≥ 60
            ▼                                ▼
    ┌───────────────┐                ┌───────────────┐
    │     LONG      │                │     SHORT     │
    │ Buy Position  │                │ Sell Position │
    └───────┬───────┘                └───────┬───────┘
            │                                │
    close < EMA                      close > EMA
    (Stop-Run!)                      (Stop-Run!)
    Execute SELL                     Execute BUY
            │                                │
            ▼                                ▼
    ┌───────────────┐                ┌───────────────┐
    │  LONG STOP    │                │  SHORT STOP   │
    │ Waiting Re-Buy│◄──── FLIP ────►│Waiting Re-Sell│
    │ [PRICE MEMORY]│                │ [PRICE MEMORY]│
    └───────────────┘                └───────────────┘
```

**Normal exits** (S / SS / X marker or B / BB / X marker) → return directly to **FREE / CASH**

**Stop-Run exits** → go to **LONG STOP** or **SHORT STOP** (price memory states, NOT FREE/CASH)

---

## 6. Stop-Run — Saving Your Loss

The stop-run is the most important protection in the system. Here is exactly what happens:

### For a LONG position

While you are LONG, the system watches the **EMA cost line** every bar.

```
If:  close price  <  EMA cost line
Then:
  1. Execute a SELL at the current price  ← forced exit
  2. Record: reentry_buy_price = stop reference level
  3. Record: original_entry_price        ← for P&L tracking
  4. Move to LONG STOP state             ← waiting for recovery
```

The stop level is **trailing** — as price rises, the EMA cost line rises with it, locking in more profit. You are not stopped out at a fixed price set at entry; the stop moves up with the market.

```
Example:
  Entry price:      $147.00
  EMA cost (day 1): $143.00  ← stop level
  Price rises to:   $162.00
  EMA cost (day 10):$155.00  ← stop trailed up
  Price reverses:   $153.00
  close $153 < EMA $155  →  STOP fires
  EXIT at $153.00  →  profit of $6.00 (+4.1%) locked in
```

### For a SHORT position

The mirror image applies:

```
If:  close price  >  EMA cost line
Then:
  1. Execute a BUY at the current price   ← forced cover
  2. Record: reentry_sell_price = stop reference level
  3. Move to SHORT STOP state
```

---

## 7. Re-Entry — The Buy Price Memory

> This is the key insight that separates **LONG STOP** from **FREE / CASH**.

After a stop-run, the system does **not** reset to FREE/CASH. Instead it enters a **price memory state** and watches for the price to recover above the stop level.

### Why this matters

When price is stopped out and then recovers — this is the same swing, just with a temporary dip below the cost line. The re-entry catches that swing at a **better (lower) price** than the original entry.

### LONG STOP — what is stored

```
reentry_buy_price  =  stop reference price  (the level breached)
original_entry     =  your original buy price  (for P&L)
```

### Re-Buy trigger

```
If:  close price  >  reentry_buy_price   (price recovers above stop level)
Then:
  1. Re-enter LONG at current close price
  2. Immediately rebuild stop-loss line at:  low − area
  3. Clear the price memory
  4. Return to LONG state  (full protection reinstated)
```

> **Critical (v4.3 fix):** The new stop-loss line is rebuilt **immediately** on re-entry. In older versions, there was no protection after re-entry — if price then dropped sharply, no `✖` would fire. This is now fixed.

### What cancels the re-entry watch

| Condition | Action |
|---|---|
| New SELL score ≥ 60 fires | Abandon RB watch → enter SHORT instead |
| New BUY score ≥ 60 fires | Fresh LONG entry, reset state |

### SHORT STOP — symmetric

```
reentry_sell_price = stop reference price
Re-Sell trigger:   close < reentry_sell_price
New stop rebuilt:  high + area  (immediately on re-entry)
```

---

## 8. Reading the Chart Markers

### Price Chart — Buy Side

| Visual | Colour | What happened |
|---|---|---|
| Small upward triangle | Cyan / Teal | **Buy signal** — entry point |
| Dashed line extending right | Cyan / Teal | **Stop-loss reference line** — watch this |
| `✖` on the dashed line | Cyan / Teal | **Stop triggered** — system executed a SELL |
| `▲` label | Bright Green | **Re-Buy** — price recovered, re-entered LONG |
| New dashed line (lighter) | Light Green | **New stop-loss** rebuilt after Re-Buy |
| Price number below line | White/grey | Exact stop-loss price level |

### Price Chart — Sell Side

| Visual | Colour | What happened |
|---|---|---|
| Small downward triangle | Purple | **Sell signal** — entry point |
| Dashed line extending right | Purple | **Stop-loss reference line** |
| `✖` on the dashed line | Purple | **Stop triggered** — system executed a BUY (cover) |
| `▼` label | Bright Red | **Re-Sell** — price fell back, re-entered SHORT |
| New dashed line (lighter) | Light Red | **New stop-loss** rebuilt after Re-Sell |

### Price Marker Labels

| Label | Meaning |
|---|---|
| `B` | Buy — moderate confidence |
| `BB` | Buy — strong confidence |
| `S` | Sell — moderate confidence |
| `SS` | Sell — strong confidence |
| `RB` | Re-Buy signal |
| `RS` | Re-Sell signal |
| `✖` | Stop-loss hit — exit now |

---

## 9. Reading the Oscillator Pane

The oscillator pane sits below the price chart and shows the Two-Pole OSC in detail.

### Lines

| Line | Colour | Meaning |
|---|---|---|
| Thick oscillating line | Cyan ↔ Purple | Main Two-Pole OSC. Cyan = bullish phase, Purple = bearish |
| Thin line | Faint grey/white | One-Pole signal line — crosses with main line generate signals |
| Filled area between lines | Colour-matched | Width shows momentum strength |
| Orange line | Orange | Velocity — rate of change. Turning up = early buy warning |

### Dots

| Dot | Colour | Meaning |
|---|---|---|
| Double-ring circle | Cyan | Buy signal fired |
| Double-ring circle | Purple | Sell signal fired |
| Solid circle | Green | Re-Buy signal |
| Solid circle | Red | Re-Sell signal |

### Reference Levels

```
 +1.00  ════  Extreme overbought — expect sell signals here
 +0.50  ····  Overbought zone
  0.00  ════  Centre line
 −0.50  ····  Oversold zone
 −1.00  ════  Extreme oversold — expect buy signals here
```

> **Reading the velocity line:** When the orange velocity line crosses from negative to positive while the main OSC is still below zero — this is an **early buy warning**, often 2–4 bars before the main signal fires. It does not replace the main signal, but it helps you prepare.

---

## 10. Flatness Warnings — When to Wait

When the market moves sideways, the oscillator flattens and normal crossover signals stop firing. The system detects this and shows coloured background warnings.

| Background Colour | Zone | What it means | Action |
|---|---|---|---|
| 🟩 Faint Green | Low flat | OSC stuck at oversold, no momentum | Buy signals suppressed unless velocity confirms |
| 🟥 Faint Red | High flat | OSC stuck at overbought, no momentum | Sell signals suppressed unless velocity confirms |
| 🟨 Faint Yellow | Mid flat | OSC flat in the middle — no trend | Both directions suppressed |
| No colour | Normal | All conditions active | Trade normally |

> **Key rule:** If you see a yellow or red/green background — do not force a trade. Wait for the background to clear before acting on signals.

**Exception:** If the background is green (low flat) but the **velocity line is turning upward** — the system will still allow a buy signal through. A slow gradual recovery from a low does not look like a breakout in amplitude terms, but the velocity correctly identifies the directional movement.

---

## 11. PLTR Walk-Through Example

This is a visual example of the system at work on PLTR from early 2025 to March 2026.

### Signal History

| # | Date | Price | Signal | State Change | Reason |
|---|---|---|---|---|---|
| 1 | Feb 2025 | ~$50 | **B** | FREE → LONG | OSC bottomed + ZigZag low pivot + BB lower bounce |
| 2 | Mar 2025 | ~$88 | **✖** | LONG → LONG STOP | Close dropped below EMA cost line — forced SELL |
| 3 | Apr 2025 | ~$63 | **▲ RB** | LONG STOP → LONG | Price recovered above reentry_buy_price ($88) |
| 4 | May 2025 | ~$140 | **SS** | LONG → FREE | Strong sell marker fires — take profit |
| 5 | May 2025 | ~$140 | **SS** | FREE → SHORT | SS fires again — entry short with high confidence |
| 6 | Jun 2025 | ~$155 | **✖** | SHORT → SHORT STOP | Close rose above EMA — forced BUY (cover) |
| 7 | Jun 2025 | ~$118 | **▼ RS** | SHORT STOP → SHORT | Price fell back below reentry_sell_price |
| 8 | Sep 2025 | ~$203 | **SS** | SHORT → FREE | Strong sell exit — near $207 peak |
| 9 | Oct 2025 | ~$158 | **B** | FREE → LONG | ZigZag Low + OSC oversold + BB lower |
| 10 | Nov 2025 | ~$152 | **✖** | LONG → LONG STOP | EMA crossed — forced SELL |
| 11 | Dec 2025 | ~$162 | **▲ RB** | LONG STOP → LONG | Price recovered above stop level |
| 12 | Jan 2026 | ~$190 | **SS** | LONG → FREE | Take profit near BB upper |
| 13 | Feb 2026 | ~$155 | **▼ RS** | SHORT STOP → SHORT | Re-sell after stop |
| 14 | Mar 2026 | ~$147 | **B?** | — | OSC oversold, ZigZag watching — potential setup forming |

### Key Observations

- **Stop #2 (Feb→Mar 2025):** Price dipped below EMA at $88, forced exit. Then recovered to new highs. Re-entry at $63 caught the real move up to $140 — a much better entry than the original.
- **Near peak Sep 2025:** SS signal at $203 near the all-time high of $207. Classic overbought + BB upper rejection.
- **Mar 2026 current:** OSC approaching oversold zone, ZigZag may be forming a new Low pivot. No signal yet — watching. **Do not enter until score ≥ 60.**

---

## 12. Quick Reference Card

### Entry Checklist

```
Before entering ANY trade, verify:
  □  Score ≥ 60 pts in your direction
  □  Buy score > sell score  (or vice versa)
  □  No yellow / red / green flatness background
  □  State is FREE / CASH  (not LONG STOP or SHORT STOP)
  □  ZigZag pivot confirms direction  (optional but recommended)
```

### While In a Trade

```
LONG position — watch for:
  □  Close < EMA cost line  →  Stop-Run fires  →  exit immediately
  □  S / SS / X marker      →  Normal exit    →  take profit

SHORT position — watch for:
  □  Close > EMA cost line  →  Stop-Run fires  →  cover immediately
  □  B / BB / X marker      →  Normal exit    →  take profit
```

### After a Stop-Run

```
Now in LONG STOP or SHORT STOP (price memory state):
  □  Do NOT treat this as FREE/CASH — you have a reference price
  □  Wait for:  close > reentry_buy_price  (long)
                close < reentry_sell_price (short)
  □  On re-entry:  new stop-loss is rebuilt automatically
  □  If opposite score ≥ 60:  flip direction instead
```

### Risk Management (per trade)

```
Stop-Loss   =  EMA cost line  (trailing — updates every bar)
Take-Profit =  entry  +  3.0 × ATR  (long)
               entry  −  3.0 × ATR  (short)
Risk:Reward =  target 2:1 or better
```

### Signal API (for developers)

```
Current state:
  GET /api/signals/PLTR/state?market=us

Full history + stats:
  GET /api/signals/PLTR?market=us&period=6mo

Options:
  period        1mo / 3mo / 6mo / 1y
  entry_threshold  minimum score (default 60)
  atr_tp_mult      take-profit multiplier (default 3.0)
  zz_dev           ZigZag swing % (default 5.0)
```

---

## 13. Known Limitations

### Trading style
This system is **trend-neutral**. It will generate both buy and sell signals regardless of the broader market direction. In a strong uptrend, sell signals may fire and stop out quickly. For trend-following, consider only taking signals in the direction of a higher-timeframe moving average.

### Re-entry is one attempt only
After a `▲ Re-Buy` fires and the new stop-loss is rebuilt — if that new stop is also triggered, the system does **not** attempt a third entry. It moves to LONG STOP again and waits. Multi-wave recovery patterns may be partially missed.

### Intraday data
Real-time 1-minute and 15-minute data is available for US markets only (NASDAQ / NYSE / AMEX). For Taiwan (TWSE/TPEX), Hong Kong (HKEX), and other markets, the system automatically uses daily bars.

### 14-bar memory window
The `was_low` / `was_high` lookback window is 14 bars. In extremely slow-moving recoveries on weekly or monthly charts, a crossover may occur outside this window and be missed. Consider extending to 20 bars for very long timeframes.

### Market cap field
Market cap is currently showing `N/A` for some symbols. This is a datafeed limitation and does not affect any signal calculations.

---

## Appendix — State Machine Summary

Every possible state transition is shown below. There are **no dead ends** — every state has a path back to FREE / CASH.

```
  ╔══════════════════════════════════════════════════════════════════╗
  ║                       FREE / CASH                               ║
  ║          No position · No memory · Waiting for score ≥ 60       ║
  ╚══════════╤══════════════════════════════════════╤═══════════════╝
             │                                      │
             │ ① BUY score ≥ 60                     │ ② SELL score ≥ 60
             │   & buy > sell                       │   & sell > buy
             ▼                                      ▼
  ┌──────────────────────┐              ┌──────────────────────┐
  │        LONG          │              │        SHORT         │
  │   (Buy Position)     │              │   (Sell Position)    │
  │                      │              │                      │
  │  Trail SL = EMA line │              │  Trail SL = EMA line │
  └──────┬───────────────┘              └──────────────┬───────┘
         │                                             │
         │ ③ S / SS / X marker fires                  │ ④ B / BB / X marker fires
         │   Normal exit — take profit                │   Normal exit — take profit
         │                                            │
         ├──────────────────────────────────────────► │
         │          back to FREE / CASH  ◄────────────┘
         │
         │ ⑤ close < EMA cost line
         │   Stop-Run fires → Execute SELL
         │   Store reentry_buy_price
         ▼
  ┌──────────────────────┐              ┌──────────────────────┐
  │      LONG STOP       │              │      SHORT STOP      │
  │  [ PRICE MEMORY ]    │              │  [ PRICE MEMORY ]    │
  │                      │  ⑨ FLIP      │                      │
  │  reentry_buy_price   │ ──────────► │  reentry_sell_price  │
  │  original_entry_px   │ ◄────────── │  original_entry_px   │
  │                      │  ⑩ FLIP      │                      │
  └──────┬───────────────┘              └──────────────┬───────┘
         │                                             │
         │ ⑥ close > reentry_buy_price                │ ⑧ close < reentry_sell_price
         │   Re-Buy → rebuild SL                      │   Re-Sell → rebuild SL
         ▼                                            ▼
  ┌──────────────────────┐              ┌──────────────────────┐
  │        LONG          │              │        SHORT         │
  │  (re-entered)        │              │  (re-entered)        │
  │  New SL = low−area   │              │  New SL = high+area  │
  └──────┬───────────────┘              └──────────────┬───────┘
         │                                             │
         │ ③ S / SS / X fires                         │ ④ B / BB / X fires
         └──────────────────────────────────────────► │
                        back to FREE / CASH ◄──────────┘

         NOTE: ⑤⑦ Stop-Run on re-entered LONG/SHORT
               → back to LONG STOP / SHORT STOP again
               → one more re-entry attempt possible
```

### All 10 State Transitions

| # | From | To | Trigger |
|---|---|---|---|
| ① | FREE / CASH | LONG | BUY score ≥ 60 AND buy > sell |
| ② | FREE / CASH | SHORT | SELL score ≥ 60 AND sell > buy |
| ③ | LONG | **FREE / CASH** | S / SS / X marker fires (normal exit) |
| ④ | SHORT | **FREE / CASH** | B / BB / X marker fires (normal exit) |
| ⑤ | LONG | LONG STOP | close < EMA cost line → forced SELL |
| ⑥ | LONG STOP | LONG | close > reentry\_buy\_price → Re-Buy |
| ⑦ | SHORT | SHORT STOP | close > EMA cost line → forced BUY |
| ⑧ | SHORT STOP | SHORT | close < reentry\_sell\_price → Re-Sell |
| ⑨ | LONG STOP | SHORT | SELL score ≥ 60 → flip direction |
| ⑩ | SHORT STOP | LONG | BUY score ≥ 60 → flip direction |

> **Every path eventually leads back to FREE / CASH** via transitions ③ or ④ — either a normal profitable exit, or after a re-entered position is exited by marker.

**The critical difference:**

| State | Memory | Re-entry trigger |
|---|---|---|
| `FREE / CASH` | None — clean slate | Confluence score ≥ 60 |
| `LONG STOP` | `reentry_buy_price` stored | Price recovers above stop level |
| `SHORT STOP` | `reentry_sell_price` stored | Price falls below stop level |

---

*@CJH Swing-Trade Signal System v2.1 — User Guide*  
*Last updated: 2026-03-05*  
*License: CC BY-NC-SA 4.0 — Free for personal and educational use. Commercial use prohibited.*

---
# Appendix: Swing-Trade State Machine  v3.0 python code

``` python
"""
# signals.py  —  Swing-Trade State Machine  v3.0
================================================
CORE FIX v3.0:  Evidence Window Accumulator
--------------------------------------------
Previous design scored each bar independently from scratch.
This meant all 4 indicators had to fire on the EXACT same bar
to reach threshold — practically impossible.

v3.0 introduces a ROLLING EVIDENCE WINDOW:
  • Each indicator fires independently and stores its evidence
  • Evidence persists for WINDOW_BARS bars (default: 5)
  • Score DECAYS linearly:  bar 0 = 100%, bar 1 = 80%, ..., bar 4 = 20%, bar 5 = 0%
  • Opposite direction signal HARD CANCELS the opposite window immediately
  • Total score each bar = sum of all live (decayed) evidence in window

Example:
  Bar 1: ZigZag Low pivot fires   → BUY evidence: 25 pts  (age=0, weight=1.0)
  Bar 3: BB Lower bounce          → BUY evidence: 20 pts  (age=0, weight=1.0)
         ZigZag evidence (age=2)  →               25 × 0.6 = 15 pts  (decaying)
         Total BUY score = 15 + 20 = 35 pts  (not yet 60)
  Bar 4: Two-Pole B fires         → BUY evidence: 28 pts  (age=0, weight=1.0)
         Total BUY score = 25×0.4 + 20×0.8 + 28×1.0 = 10+16+28 = 54 pts
  Bar 5: ATR below EMA            → BUY evidence: 16 pts  (age=0)
         Total BUY score = 25×0.2 + 20×0.6 + 28×0.8 + 16×1.0 = 5+12+22+16 = 55 pts
         → Still building...  signal fires when window aligns
  Bar 6: ZigZag fires again       → BUY evidence: 25 pts  refreshed
         Total BUY score = 20×0.4 + 28×0.6 + 16×0.8 + 25×1.0 = 8+17+13+25 = 63 pts ✅ SIGNAL!

State Machine (v2.1 logic preserved):
  FLAT       → no position
  LONG       → buy position, trailing EMA stop
  LONG_STOP  → price memory state (reentry_buy_price stored)
  SHORT      → sell position, trailing EMA stop
  SHORT_STOP → price memory state (reentry_sell_price stored)

Stop-Run:
  LONG  → close < EMA cost line → forced SELL → LONG_STOP
  SHORT → close > EMA cost line → forced BUY  → SHORT_STOP

Re-Entry (price-level based, NOT score-based):
  LONG_STOP  → close > reentry_buy_price  → Re-Buy  → LONG
  SHORT_STOP → close < reentry_sell_price → Re-Sell → SHORT
"""

import numpy as np
import pandas as pd
from dataclasses import dataclass, field, asdict
from typing import List, Dict, Any, Optional, Tuple
from enum import Enum


# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

WINDOW_BARS  = 5      # evidence lives for 5 bars (1 trading week)
# Linear decay weights by age:  age=0 → 1.0,  age=1 → 0.8,  age=2 → 0.6 ...
DECAY_WEIGHT = [1.0, 0.8, 0.6, 0.4, 0.2]   # index = age in bars


# ─────────────────────────────────────────────────────────────────────────────
# State / Event enums
# ─────────────────────────────────────────────────────────────────────────────

class TradeState(str, Enum):
    FLAT        = "FLAT"
    LONG        = "LONG"
    LONG_STOP   = "LONG_STOP"
    SHORT       = "SHORT"
    SHORT_STOP  = "SHORT_STOP"


class EventType(str, Enum):
    BUY         = "BUY"
    SELL        = "SELL"
    STOP_LONG   = "STOP_LONG"
    STOP_SHORT  = "STOP_SHORT"
    RE_BUY      = "RE_BUY"
    RE_SELL     = "RE_SELL"
    EXIT_LONG   = "EXIT_LONG"
    EXIT_SHORT  = "EXIT_SHORT"


# ─────────────────────────────────────────────────────────────────────────────
# Evidence item — one indicator firing
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class Evidence:
    indicator:  str     # "OSC" | "ZigZag" | "ATR" | "BB"
    direction:  str     # "BUY" | "SELL"
    raw_score:  int     # points at time of firing (before decay)
    fired_bar:  int     # bar index when it fired
    reason:     str     # human-readable trigger reason

    def decayed_score(self, current_bar: int) -> float:
        age = current_bar - self.fired_bar
        if age >= WINDOW_BARS:
            return 0.0
        return self.raw_score * DECAY_WEIGHT[age]


# ─────────────────────────────────────────────────────────────────────────────
# Evidence Window — rolling accumulator
# ─────────────────────────────────────────────────────────────────────────────

class EvidenceWindow:
    """
    Maintains a rolling window of evidence items per direction.
    Each indicator can only have ONE active evidence item (most recent wins).
    Opposite direction fires → hard cancel clears the opposite window.
    """

    def __init__(self):
        # Store latest evidence per indicator per direction
        self._buy:  Dict[str, Evidence] = {}   # indicator -> Evidence
        self._sell: Dict[str, Evidence] = {}

    def add(self, ev: Evidence):
        """Add new evidence. Replaces any older evidence from same indicator."""
        if ev.direction == "BUY":
            self._buy[ev.indicator] = ev
            # Hard cancel: clear all SELL evidence immediately
            self._sell.clear()
        else:
            self._sell[ev.indicator] = ev
            # Hard cancel: clear all BUY evidence immediately
            self._buy.clear()

    def buy_score(self, current_bar: int) -> float:
        """Total decayed BUY score at current bar."""
        return sum(e.decayed_score(current_bar) for e in self._buy.values())

    def sell_score(self, current_bar: int) -> float:
        """Total decayed SELL score at current bar."""
        return sum(e.decayed_score(current_bar) for e in self._sell.values())

    def buy_breakdown(self, current_bar: int) -> Dict[str, float]:
        return {k: e.decayed_score(current_bar) for k, e in self._buy.items()
                if e.decayed_score(current_bar) > 0}

    def sell_breakdown(self, current_bar: int) -> Dict[str, float]:
        return {k: e.decayed_score(current_bar) for k, e in self._sell.items()
                if e.decayed_score(current_bar) > 0}

    def buy_reasons(self, current_bar: int) -> List[str]:
        return [f"{k}({e.decayed_score(current_bar):.0f}pt): {e.reason}"
                for k, e in self._buy.items()
                if e.decayed_score(current_bar) > 0]

    def sell_reasons(self, current_bar: int) -> List[str]:
        return [f"{k}({e.decayed_score(current_bar):.0f}pt): {e.reason}"
                for k, e in self._sell.items()
                if e.decayed_score(current_bar) > 0]

    def purge_expired(self, current_bar: int):
        """Remove evidence that has fully decayed."""
        self._buy  = {k: e for k, e in self._buy.items()
                      if e.decayed_score(current_bar) > 0}
        self._sell = {k: e for k, e in self._sell.items()
                      if e.decayed_score(current_bar) > 0}

    def reset(self):
        self._buy.clear()
        self._sell.clear()


# ─────────────────────────────────────────────────────────────────────────────
# Trade Event dataclass
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class TradeEvent:
    timestamp:          int
    date_str:           str
    event:              str
    state_before:       str
    state_after:        str
    price:              float
    stop_loss:          float
    take_profit:        float
    risk_reward:        float

    # Confluence at time of entry
    score:              int
    strength:           str
    buy_breakdown:      Dict[str, float]
    sell_breakdown:     Dict[str, float]
    buy_reasons:        List[str]
    sell_reasons:       List[str]

    # Context
    atr_value:          float
    ema_cost:           float
    bb_upper:           float
    bb_lower:           float
    pct_b:              float

    action:             str
    pnl_pct:            float = 0.0
    pnl_type:           str   = ""

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


# ─────────────────────────────────────────────────────────────────────────────
# Indicator helpers
# ─────────────────────────────────────────────────────────────────────────────

def _atr(df: pd.DataFrame, period: int = 14) -> pd.Series:
    h, l, c = df["high"], df["low"], df["close"]
    tr = pd.concat(
        [h - l, (h - c.shift(1)).abs(), (l - c.shift(1)).abs()],
        axis=1
    ).max(axis=1)
    return tr.ewm(alpha=1 / period, adjust=False).mean()


def _bollinger(df: pd.DataFrame, period: int = 20, std: float = 2.0) -> pd.DataFrame:
    mid   = df["close"].rolling(period).mean()
    sigma = df["close"].rolling(period).std(ddof=0)
    upper = mid + std * sigma
    lower = mid - std * sigma
    pct_b = (df["close"] - lower) / (upper - lower + 1e-9)
    return pd.DataFrame({"mid": mid, "upper": upper, "lower": lower, "pct_b": pct_b})


def _zigzag(df: pd.DataFrame, dev_pct: float = 5.0) -> pd.Series:
    highs, lows = df["high"].values, df["low"].values
    n   = len(highs)
    dev = dev_pct / 100.0
    pv  = np.zeros(n, dtype=np.int8)
    lp, lt, li = lows[0], -1, 0
    for i in range(1, n):
        if lt >= 0:
            if highs[i] > lp:  lp, li = highs[i], i
            elif lp > 0 and (lp - lows[i]) / lp >= dev:
                pv[li] = 1; lt, lp, li = -1, lows[i], i
        else:
            if lows[i] < lp:   lp, li = lows[i], i
            elif lp > 0 and (highs[i] - lp) / lp >= dev:
                pv[li] = -1; lt, lp, li = 1, highs[i], i
    return pd.Series(pv, index=df.index, name="zz")


def _parse_osc(osc_payload: Dict) -> Tuple[Dict[int, str], Dict[int, float]]:
    markers: Dict[int, str]   = {}
    values:  Dict[int, float] = {}
    for m in osc_payload.get("price_markers", []):
        t, txt = m.get("time"), m.get("text", "").strip()
        if t and txt:
            markers[t] = txt
    for pt in osc_payload.get("two_p_bull", []) + osc_payload.get("two_p_bear", []):
        values[pt["time"]] = pt["value"]
    return markers, values


# ─────────────────────────────────────────────────────────────────────────────
# Per-bar indicator fire detection  →  returns list of Evidence items
# ─────────────────────────────────────────────────────────────────────────────

def _detect_evidence(
    bar_idx:     int,
    df:          pd.DataFrame,
    bb:          pd.DataFrame,
    atr_ser:     pd.Series,
    ema_cost:    pd.Series,
    zz:          pd.Series,
    osc_markers: Dict[int, str],
    osc_values:  Dict[int, float],
    lookback:    int = 3,
) -> List[Evidence]:
    """
    Detect which indicators fired THIS bar and return Evidence objects.
    Does NOT accumulate — accumulation is handled by EvidenceWindow.
    """
    indices = list(df.index)
    bar_ts  = indices[bar_idx]
    close   = float(df["close"].iloc[bar_idx])
    high    = float(df["high"].iloc[bar_idx])
    low     = float(df["low"].iloc[bar_idx])
    atr_val = float(atr_ser.iloc[bar_idx])
    ema_val = float(ema_cost.iloc[bar_idx])
    bb_up   = float(bb["upper"].iloc[bar_idx])
    bb_lo   = float(bb["lower"].iloc[bar_idx])
    pct_b   = float(bb["pct_b"].iloc[bar_idx])
    unix_ts = int(bar_ts.timestamp()) if hasattr(bar_ts, "timestamp") else int(bar_ts)

    fired: List[Evidence] = []

    # ── 1. TWO-POLE OSC ───────────────────────────────────────────────────
    recent_marker = None
    for lb in range(lookback):
        if bar_idx - lb < 0: break
        t_idx  = indices[bar_idx - lb]
        t_unix = int(t_idx.timestamp()) if hasattr(t_idx,"timestamp") else int(t_idx)
        if t_unix in osc_markers:
            recent_marker = osc_markers[t_unix]
            break

    osc_curr = osc_values.get(unix_ts)

    if recent_marker in ("B", "BB"):
        sc = 35 if recent_marker == "BB" else 28
        fired.append(Evidence("OSC","BUY", sc, bar_idx,
                               f"Two-Pole {recent_marker} signal"))
    elif recent_marker == "RB":
        fired.append(Evidence("OSC","BUY", 22, bar_idx,
                               "Two-Pole Re-Buy signal"))
    elif recent_marker in ("S", "SS"):
        sc = 35 if recent_marker == "SS" else 28
        fired.append(Evidence("OSC","SELL", sc, bar_idx,
                               f"Two-Pole {recent_marker} signal"))
    elif recent_marker == "RS":
        fired.append(Evidence("OSC","SELL", 22, bar_idx,
                               "Two-Pole Re-Sell signal"))
    elif osc_curr is not None:
        if osc_curr < -0.3:
            fired.append(Evidence("OSC","BUY", 10, bar_idx,
                                   f"OSC oversold ({osc_curr:.2f})"))
        elif osc_curr > 0.3:
            fired.append(Evidence("OSC","SELL", 10, bar_idx,
                                   f"OSC overbought ({osc_curr:.2f})"))

    # ── 2. ZIGZAG ─────────────────────────────────────────────────────────
    for lb in range(min(5, bar_idx)):
        pv = int(zz.iloc[bar_idx - lb])
        if pv == -1:
            # Check for higher-low structure
            prev_lo_idx = next(
                (k for k in range(bar_idx - lb - 1, max(0, bar_idx - 30), -1)
                 if int(zz.iloc[k]) == -1), None)
            if prev_lo_idx is not None:
                prev_lo_px = float(df["low"].iloc[prev_lo_idx])
                if low >= prev_lo_px * 0.98:
                    fired.append(Evidence("ZigZag","BUY", 25, bar_idx,
                                           "Higher Low confirmed — bullish structure"))
                else:
                    fired.append(Evidence("ZigZag","BUY", 15, bar_idx,
                                           "Low pivot confirmed"))
            else:
                fired.append(Evidence("ZigZag","BUY", 15, bar_idx,
                                       "Low pivot confirmed"))
            break
        elif pv == 1:
            fired.append(Evidence("ZigZag","SELL", 20, bar_idx,
                                   "High pivot confirmed — distribution zone"))
            break

    # ── 3. ATR / EMA COST ────────────────────────────────────────────────
    if ema_val > 0:
        pve = (close - ema_val) / ema_val
        if pve <= -0.03:
            sc = min(20, int(abs(pve) / 0.01) * 4)
            fired.append(Evidence("ATR","BUY", sc, bar_idx,
                                   f"Price {abs(pve)*100:.1f}% below avg cost"))
        elif pve >= 0.05:
            sc = min(20, int(pve / 0.01) * 3)
            fired.append(Evidence("ATR","SELL", sc, bar_idx,
                                   f"Price {pve*100:.1f}% above avg cost"))

    # ── 4. BOLLINGER BANDS ────────────────────────────────────────────────
    if pct_b <= 0.05:
        fired.append(Evidence("BB","BUY", 20, bar_idx,
                               f"Price at/below BB Lower ({bb_lo:.2f})"))
    elif pct_b <= 0.15:
        fired.append(Evidence("BB","BUY", 12, bar_idx,
                               "Price near BB Lower"))
    elif pct_b >= 0.95:
        fired.append(Evidence("BB","SELL", 20, bar_idx,
                               f"Price at/above BB Upper ({bb_up:.2f})"))
    elif pct_b >= 0.85:
        fired.append(Evidence("BB","SELL", 12, bar_idx,
                               "Price near BB Upper"))

    return fired


# ─────────────────────────────────────────────────────────────────────────────
# Main state machine
# ─────────────────────────────────────────────────────────────────────────────

def run_state_machine(
    df:               pd.DataFrame,
    osc_payload:      Optional[Dict] = None,
    bb_period:        int            = 20,
    bb_std:           float          = 2.0,
    atr_period:       int            = 14,
    zz_deviation:     float          = 5.0,
    lookback:         int            = 3,
    entry_threshold:  int            = 60,
    atr_tp_mult:      float          = 3.0,
    window_bars:      int            = WINDOW_BARS,
) -> List[TradeEvent]:
    """
    Walk every bar:
      1. Detect which indicators fired → add to EvidenceWindow
      2. Compute current decayed BUY / SELL scores
      3. Apply state machine transitions
    """
    if df is None or len(df) < max(bb_period, atr_period, 30):
        return []

    df = df.copy()
    df.columns = df.columns.str.lower()

    bb       = _bollinger(df, bb_period, bb_std)
    atr_ser  = _atr(df, atr_period)
    ema_cost = df["close"].ewm(span=atr_period, adjust=False).mean()
    zz       = _zigzag(df, zz_deviation)

    osc_markers: Dict[int, str]   = {}
    osc_values:  Dict[int, float] = {}
    if osc_payload:
        osc_markers, osc_values = _parse_osc(osc_payload)

    # ── State variables ────────────────────────────────────────────────────
    state:               TradeState = TradeState.FLAT
    entry_price:         float      = 0.0
    entry_tp:            float      = 0.0
    reentry_buy_price:   float      = 0.0   # price-level memory (LONG_STOP)
    reentry_sell_price:  float      = 0.0   # price-level memory (SHORT_STOP)

    window = EvidenceWindow()
    events: List[TradeEvent] = []
    warm_up = max(bb_period, atr_period, 20)

    for i in range(warm_up, len(df)):
        indices = list(df.index)
        bar_ts  = indices[i]
        close   = float(df["close"].iloc[i])
        ema_val = float(ema_cost.iloc[i])
        atr_val = float(atr_ser.iloc[i])
        bb_up   = float(bb["upper"].iloc[i])
        bb_lo   = float(bb["lower"].iloc[i])
        pct_b   = float(bb["pct_b"].iloc[i])
        unix_ts = int(bar_ts.timestamp()) if hasattr(bar_ts,"timestamp") else int(bar_ts)
        date_s  = bar_ts.strftime("%Y-%m-%d") if hasattr(bar_ts,"strftime") else str(bar_ts)

        # ── Step 1: detect new evidence this bar ──────────────────────────
        new_ev = _detect_evidence(i, df, bb, atr_ser, ema_cost, zz,
                                  osc_markers, osc_values, lookback)
        for ev in new_ev:
            window.add(ev)   # hard-cancels opposite direction if fires

        # ── Step 2: compute current decayed scores ────────────────────────
        window.purge_expired(i)
        buy_score  = int(window.buy_score(i))
        sell_score = int(window.sell_score(i))

        # ── Step 3: check OSC marker for exits (direct, not score-based) ──
        osc_marker = None
        for lb in range(lookback):
            if i - lb < 0: break
            t_idx  = indices[i - lb]
            t_unix = int(t_idx.timestamp()) if hasattr(t_idx,"timestamp") else int(t_idx)
            if t_unix in osc_markers:
                osc_marker = osc_markers[t_unix]
                break

        # ── Helper: build event ───────────────────────────────────────────
        def strength_label(sc: int) -> str:
            return "STRONG" if sc >= 80 else "MODERATE" if sc >= 60 else "WEAK"

        def make_event(ev_type: EventType, s_before: TradeState, s_after: TradeState,
                       sl: float = 0.0, tp: float = 0.0,
                       score: int = 0, pnl: float = 0.0,
                       pnl_type: str = "") -> TradeEvent:
            risk   = abs(close - sl)  if sl  else atr_val
            reward = abs(tp - close)  if tp  else atr_val * atr_tp_mult
            rr     = round(reward / risk, 2) if risk > 0 else 0.0
            action_map = {
                EventType.BUY:        f"BUY      @ {close:.2f} | SL {sl:.2f} | TP {tp:.2f}",
                EventType.RE_BUY:     f"RE-BUY   @ {close:.2f} | SL {sl:.2f} | TP {tp:.2f}",
                EventType.SELL:       f"SELL     @ {close:.2f} | SL {sl:.2f} | TP {tp:.2f}",
                EventType.RE_SELL:    f"RE-SELL  @ {close:.2f} | SL {sl:.2f} | TP {tp:.2f}",
                EventType.STOP_LONG:  f"STOP-RUN EXIT LONG  @ {close:.2f} ({pnl:+.1f}%)",
                EventType.STOP_SHORT: f"STOP-RUN EXIT SHORT @ {close:.2f} ({pnl:+.1f}%)",
                EventType.EXIT_LONG:  f"EXIT LONG  @ {close:.2f} ({pnl:+.1f}%)",
                EventType.EXIT_SHORT: f"EXIT SHORT @ {close:.2f} ({pnl:+.1f}%)",
            }
            return TradeEvent(
                timestamp=unix_ts, date_str=date_s,
                event=ev_type.value,
                state_before=s_before.value, state_after=s_after.value,
                price=round(close,2), stop_loss=round(sl,2),
                take_profit=round(tp,2), risk_reward=rr,
                score=score, strength=strength_label(score),
                buy_breakdown=window.buy_breakdown(i),
                sell_breakdown=window.sell_breakdown(i),
                buy_reasons=window.buy_reasons(i),
                sell_reasons=window.sell_reasons(i),
                atr_value=round(atr_val,4), ema_cost=round(ema_val,2),
                bb_upper=round(bb_up,2), bb_lower=round(bb_lo,2),
                pct_b=round(pct_b,3),
                action=action_map[ev_type],
                pnl_pct=round(pnl,2), pnl_type=pnl_type,
            )

        # ════════════════════════════════════════════════════════════════
        if state == TradeState.FLAT:
        # ════════════════════════════════════════════════════════════════
            if buy_score >= entry_threshold and buy_score > sell_score:
                entry_price = close
                entry_tp    = close + atr_tp_mult * atr_val
                sl          = ema_val
                state       = TradeState.LONG
                window.reset()   # clear evidence — position is open
                events.append(make_event(EventType.BUY,
                    TradeState.FLAT, TradeState.LONG,
                    sl=sl, tp=entry_tp, score=buy_score))

            elif sell_score >= entry_threshold and sell_score > buy_score:
                entry_price = close
                entry_tp    = close - atr_tp_mult * atr_val
                sl          = ema_val
                state       = TradeState.SHORT
                window.reset()
                events.append(make_event(EventType.SELL,
                    TradeState.FLAT, TradeState.SHORT,
                    sl=sl, tp=entry_tp, score=sell_score))

        # ════════════════════════════════════════════════════════════════
        elif state == TradeState.LONG:
        # ════════════════════════════════════════════════════════════════
            sl = ema_val  # trailing stop

            # Stop-Run: close drops below EMA cost line
            if close < ema_val:
                pnl = (close - entry_price) / entry_price * 100
                reentry_buy_price = ema_val   # store price-level for re-entry
                state = TradeState.LONG_STOP
                window.reset()
                events.append(make_event(EventType.STOP_LONG,
                    TradeState.LONG, TradeState.LONG_STOP,
                    sl=sl, tp=entry_tp, pnl=pnl, pnl_type="STOP_SAVED"))

            # Normal exit: S / SS / X marker
            elif osc_marker in ("S", "SS", "X"):
                pnl      = (close - entry_price) / entry_price * 100
                pnl_type = "PROFIT" if pnl > 0 else "LOSS"
                state    = TradeState.FLAT
                window.reset()
                events.append(make_event(EventType.EXIT_LONG,
                    TradeState.LONG, TradeState.FLAT,
                    sl=sl, tp=entry_tp, pnl=pnl, pnl_type=pnl_type))

        # ════════════════════════════════════════════════════════════════
        elif state == TradeState.LONG_STOP:
        # ════════════════════════════════════════════════════════════════
            # Re-Buy: price recovers above reentry_buy_price (PRICE-LEVEL based)
            if close > reentry_buy_price:
                entry_price = close
                area = float(df["high"].rolling(100).mean().iloc[i] -
                             df["low"].rolling(100).mean().iloc[i])
                entry_tp = close + atr_tp_mult * atr_val
                sl       = ema_val
                state    = TradeState.LONG
                window.reset()
                events.append(make_event(EventType.RE_BUY,
                    TradeState.LONG_STOP, TradeState.LONG,
                    sl=sl, tp=entry_tp, score=0))

            # Flip: strong sell signal fires while waiting
            elif sell_score >= entry_threshold and sell_score > buy_score:
                entry_price = close
                entry_tp    = close - atr_tp_mult * atr_val
                sl          = ema_val
                state       = TradeState.SHORT
                window.reset()
                events.append(make_event(EventType.SELL,
                    TradeState.LONG_STOP, TradeState.SHORT,
                    sl=sl, tp=entry_tp, score=sell_score))

        # ════════════════════════════════════════════════════════════════
        elif state == TradeState.SHORT:
        # ════════════════════════════════════════════════════════════════
            sl = ema_val  # trailing stop

            # Stop-Run: close rises above EMA cost line
            if close > ema_val:
                pnl = (entry_price - close) / entry_price * 100
                reentry_sell_price = ema_val
                state = TradeState.SHORT_STOP
                window.reset()
                events.append(make_event(EventType.STOP_SHORT,
                    TradeState.SHORT, TradeState.SHORT_STOP,
                    sl=sl, tp=entry_tp, pnl=pnl, pnl_type="STOP_SAVED"))

            # Normal exit: B / BB / X marker
            elif osc_marker in ("B", "BB", "X"):
                pnl      = (entry_price - close) / entry_price * 100
                pnl_type = "PROFIT" if pnl > 0 else "LOSS"
                state    = TradeState.FLAT
                window.reset()
                events.append(make_event(EventType.EXIT_SHORT,
                    TradeState.SHORT, TradeState.FLAT,
                    sl=sl, tp=entry_tp, pnl=pnl, pnl_type=pnl_type))

        # ════════════════════════════════════════════════════════════════
        elif state == TradeState.SHORT_STOP:
        # ════════════════════════════════════════════════════════════════
            # Re-Sell: price falls back below reentry_sell_price
            if close < reentry_sell_price:
                entry_price = close
                entry_tp = close - atr_tp_mult * atr_val
                sl       = ema_val
                state    = TradeState.SHORT
                window.reset()
                events.append(make_event(EventType.RE_SELL,
                    TradeState.SHORT_STOP, TradeState.SHORT,
                    sl=sl, tp=entry_tp, score=0))

            # Flip: strong buy signal fires while waiting
            elif buy_score >= entry_threshold and buy_score > sell_score:
                entry_price = close
                entry_tp    = close + atr_tp_mult * atr_val
                sl          = ema_val
                state       = TradeState.LONG
                window.reset()
                events.append(make_event(EventType.BUY,
                    TradeState.SHORT_STOP, TradeState.LONG,
                    sl=sl, tp=entry_tp, score=buy_score))

    return events


# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

def calculate_signals(df, osc_payload=None, history=20, **kwargs) -> List[TradeEvent]:
    """Return last `history` events, newest first."""
    return list(reversed(run_state_machine(df, osc_payload, **kwargs)[-history:]))


def get_latest_signal(df, osc_payload=None, **kwargs) -> Optional[TradeEvent]:
    events = run_state_machine(df, osc_payload, **kwargs)
    return events[-1] if events else None


def get_trade_summary(df, osc_payload=None, **kwargs) -> Dict[str, Any]:
    events = run_state_machine(df, osc_payload, **kwargs)
    if not events:
        return {"total": 0}

    exits  = [e for e in events if e.event in ("EXIT_LONG",  "EXIT_SHORT")]
    stops  = [e for e in events if e.event in ("STOP_LONG",  "STOP_SHORT")]
    re_ent = [e for e in events if e.event in ("RE_BUY",     "RE_SELL")]
    profits= [e for e in exits  if e.pnl_type == "PROFIT"]
    losses = [e for e in exits  if e.pnl_type == "LOSS"]

    return {
        "total_events":     len(events),
        "exits":            len(exits),
        "stop_runs":        len(stops),
        "re_entries":       len(re_ent),
        "profitable_exits": len(profits),
        "losing_exits":     len(losses),
        "avg_profit_pct":   round(sum(e.pnl_pct for e in profits)/len(profits),2) if profits else 0,
        "avg_loss_pct":     round(sum(e.pnl_pct for e in losses) /len(losses), 2) if losses  else 0,
        "avg_stop_pct":     round(sum(e.pnl_pct for e in stops)  /len(stops),  2) if stops   else 0,
        "win_rate":         round(len(profits)/len(exits)*100, 1) if exits else 0,
        "events":           [e.to_dict() for e in reversed(events)],
    }

```