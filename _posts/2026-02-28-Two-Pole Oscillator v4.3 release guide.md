# @CJH Two-Pole Oscillator v4.3
## First Release — Technical Reference & User Guide

**Author:** CJH  
**Platform:** TradingView Pine Script v6  
**Release Date:** 2026-02-25  
**License:** Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  

---

## Table of Contents

1. [Overview & Philosophy](#1-overview--philosophy)
2. [The Problem This Indicator Solves](#2-the-problem-this-indicator-solves)
3. [Mathematical Foundation](#3-mathematical-foundation)
4. [Buy / Sell Strategy Logic](#4-buy--sell-strategy-logic)
5. [Stop-Loss & Re-Entry State Machine](#5-stop-loss--re-entry-state-machine)
6. [Flattening (鈍化) Detection System](#6-flattening-鈍化-detection-system)
7. [Visual Reference Guide](#7-visual-reference-guide)
8. [Parameters Reference](#8-parameters-reference)
9. [Version History & Bug Fix Log](#9-version-history--bug-fix-log)
10. [Known Limitations & Future Roadmap](#10-known-limitations--future-roadmap)
11. [Full Source Code](#11-full-source-code)

---

## 1. Overview & Philosophy

The **@CJH Two-Pole Oscillator** is a momentum oscillator built on a second-order digital low-pass filter (Two-Pole EMA). It normalises price deviation into a bounded Z-score oscillator, then applies layers of intelligent signal filtering to generate high-quality buy and sell signals across equities, ETFs, and indices on any timeframe.

The indicator is not a simple crossover system. It embodies a complete **trade lifecycle management framework**:

```
Signal Generation  →  Entry Confirmation  →  Stop-Loss Monitoring
       ↓                                            ↓
  Re-Entry Watch  ←──────── Stop Triggered ─────────┘
       ↓
  New Stop-Loss Line rebuilt automatically
```

Every stage of a trade — from first entry, through stop-loss exit, to re-entry after price recovers — is handled automatically with visual clarity on both the price chart and the oscillator pane.

---

## 2. The Problem This Indicator Solves

### 2.1 Original Two-Pole OSC Defects

The starting point was a standard Two-Pole Oscillator using a hard-coded 4-bar delay as its signal line (`two_pp = two_p[4]`). Through live observation on stocks like **8358 金居 (TPEX)**, **OKLO (NYSE)**, and **IBM (NYSE)**, two fundamental flaws were identified:

**Defect ①: Signal Lag**

```
Price:    ↑↑↑  Reversal  ↓↓↓↓
two_p:          ↑↑↑↑↑↑    ↓     ← 2nd-order filter inertia
two_pp:           ↑↑↑↑↑↑↑  ↓   ← additional 4-bar hard delay
Sell signal:                ←── appears 4–8 bars too late
```

**Defect ②: Flatline Paralysis (鈍化)**

When price oscillates sideways at a high or low level, the Two-Pole filter averages out the oscillations, producing a near-horizontal OSC line. The crossover condition between `two_p` and `two_pp` never triggers. The indicator goes silent precisely when the market is most ambiguous — which is when a trader most needs guidance.

**Defect ③: No Trade Lifecycle Awareness**

The original indicator had no concept of what happens *after* a signal. A stop-loss trigger (price crossing the reference line) would mark an ✖, but the indicator then forgot about the position entirely. If price reversed and recovered above the stop level, no re-entry signal was generated. And critically, after a re-entry, no new stop-loss reference line was created — leaving the trader unprotected if price reversed again sharply (the **IBM Jan 2026** scenario).

---

## 3. Mathematical Foundation

### 3.1 Input: Z-Score Normalisation

Raw price is first transformed into a standardised deviation score:

```
sma25  = SMA(close, 25)
dev    = close - sma25
sma_n1 = (dev - SMA(dev, 25)) / StdDev(dev, 25)
```

This produces a dimensionless oscillator input centred around zero, with typical range ±2. The Z-score normalisation ensures the indicator behaves consistently across stocks with vastly different price levels — from a $5 stock to a $500 stock.

### 3.2 Two-Pole Low-Pass Filter (Main Line)

```
alpha  = 2 / (length + 1)
s1    := (1 - alpha) * s1 + alpha * source     ← First EMA pass
s2    := (1 - alpha) * s2 + alpha * s1          ← Second EMA pass (Two-Pole)
```

This is a **2nd-order Butterworth-style recursive filter**. It provides excellent noise rejection but introduces inherent phase lag proportional to `length`. The output `two_p` is the main oscillator line.

### 3.3 One-Pole Signal Line (Improved)

```
alpha_sig = 2 / (sig_len + 1)       where sig_len = length × sig_ratio
signal   := (1 - alpha_sig) * signal + alpha_sig * two_p
```

Unlike the original `two_p[4]` hard delay, this **dynamic One-Pole EMA signal line** adapts to the oscillator's own movement. Being a first-order filter, it is inherently faster than the Two-Pole main line, creating a meaningful and responsive crossover relationship. The `sig_ratio` parameter (default 0.6) allows users to tune the signal speed.

### 3.4 Velocity (Rate of Change)

```
vel   = two_p - two_p[2]            ← 2-bar slope
vel_s = OnePoleSmoother(vel, 3)     ← lightly smoothed
```

The velocity line measures the **rate of change** of the oscillator. Its sign transition (positive ↔ negative) provides an early warning of turning points — often 2–4 bars earlier than a crossover signal. This is the pre-emptive signal layer.

### 3.5 Area (Dynamic Volatility Buffer)

```
area = SMA(high - low, 100)
```

The 100-bar average true range is used to position stop-loss reference lines dynamically below buy signals (`low - area`) and above sell signals (`high + area`). This adapts the buffer distance to each stock's natural volatility.

---

## 4. Buy / Sell Strategy Logic

### 4.1 Signal Conditions

**Buy Signal** triggers when either condition is true AND flattening filters pass:

| Trigger | Condition | Description |
|---------|-----------|-------------|
| `buy_cross` | `crossover(two_p, signal)` AND `was_low` | Main line crosses above signal line, with confirmation that OSC was recently at a low level (within 14 bars) |
| `buy_vel` | `crossover(vel_s, vel_thresh)` AND `two_p < -0.15` | Velocity turns positive while OSC is still in negative territory — **early warning** |

**Sell Signal** (fully symmetric):

| Trigger | Condition | Description |
|---------|-----------|-------------|
| `sell_cross` | `crossunder(two_p, signal)` AND `was_high` | Main line crosses below signal line, with confirmation that OSC was recently at a high level |
| `sell_vel` | `crossunder(vel_s, -vel_thresh)` AND `two_p > 0.15` | Velocity turns negative while OSC is still in positive territory — **early warning** |

### 4.2 The `was_low` / `was_high` Memory Condition

This was a critical fix introduced to handle fast-moving markets. The original condition `two_p < 0` would fail when price rebounded sharply: the crossover might happen after `two_p` had already risen above zero.

```pine
was_low  = ta.lowest (two_p, 14) < -0.15   // Was OSC in low zone within 14 bars?
was_high = ta.highest(two_p, 14) >  0.15   // Was OSC in high zone within 14 bars?
```

By checking a **14-bar memory window** rather than the current bar's value, the indicator correctly captures fast rebounds where the crossover occurs above the zero line.

### 4.3 Signal Flow Diagram

```
                    ┌─────────────────────────┐
                    │   Z-Score Input (sma_n1) │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │   Two-Pole Filter       │ ← main line (two_p)
                    └────────────┬────────────┘
                         ┌───────┴────────┐
            ┌────────────▼──┐         ┌───▼──────────────┐
            │ One-Pole      │         │ Velocity          │
            │ Signal Line   │         │ vel_s = diff(2)   │
            └──────┬────────┘         └──────┬────────────┘
                   │                         │
            crossover?                  vel turns up/down?
                   │                         │
                   └──────────┬──────────────┘
                              │
                    ┌─────────▼──────────┐
                    │ Flatness Filter    │ ← blocks if no directional momentum
                    │ (velocity-aware)   │
                    └─────────┬──────────┘
                              │
                    ┌─────────▼──────────┐
                    │  BUY / SELL Signal │
                    └────────────────────┘
```

---

## 5. Stop-Loss & Re-Entry State Machine

This is the most sophisticated component of the indicator — a **4-state finite state machine** tracking trade lifecycle per direction.

### 5.1 Buy Side State Machine

```
State 0: IDLE
  → On BUY signal:
      Draw buy_line at (low - area)
      → Move to State 1

State 1: IN_POSITION (buy_line active)
  → On low < buy_line:
      Draw ✖ at stop price
      Store reentry_buy_price = stop_price
      wait_buy_reentry = true
      Clear buy_line
      → Move to State 2

State 2: WAITING_REENTRY
  → On new SELL signal:
      Reset all → State 0

  → On close > reentry_buy_price:
      Draw ▲ Re-Buy label
      Immediately rebuild buy_line at (low - area)  ← v4.3 fix
      wait_buy_reentry = false
      → Move to State 1  (protection reinstated!)
```

### 5.2 Sell Side State Machine (Symmetric)

```
State 0: IDLE
  → On SELL signal:
      Draw sell_line at (high + area)
      → Move to State 1

State 1: IN_POSITION (sell_line active)
  → On high > sell_line:
      Draw ✖ at stop price
      Store reentry_sell_price = stop_price
      wait_sell_reentry = true
      Clear sell_line
      → Move to State 2

State 2: WAITING_REENTRY
  → On new BUY signal:
      Reset all → State 0

  → On close < reentry_sell_price:
      Draw ▼ Re-Sell label
      Immediately rebuild sell_line at (high + area)  ← v4.3 fix
      wait_sell_reentry = false
      → Move to State 1  (protection reinstated!)
```

### 5.3 The IBM v4.3 Bug Fix

The v4.3 fix closes a critical gap in the state machine. In v4.2, after Re-Buy triggered:

```
v4.2 (BROKEN):
  ▲ Re-Buy fires → wait=false, reentry_price=na, buy_line=na
                                                   ↑
                              No stop-loss line exists!
                              IBM drops 25% → ✖ never fires
                              Trader has no exit signal

v4.3 (FIXED):
  ▲ Re-Buy fires → immediately creates new buy_line at (low - area)
                → IBM drops → low < new buy_line → ✖ fires correctly
                → Trader gets exit signal
```

---

## 6. Flattening (鈍化) Detection System

### 6.1 The Flattening Problem

Traditional oscillators become useless during sideways markets. The Two-Pole filter exacerbates this: its smoothing averages out lateral oscillations, producing a horizontal line that never crosses its signal line. The indicator goes silent — but it does so silently, with no warning to the user.

### 6.2 Three-Zone Detection

```pine
osc_range = highest(two_p, 10) - lowest(two_p, 10)   // recent amplitude
osc_mean  = SMA(two_p, 10)                            // recent centre level

is_flat      = osc_range < osc_flat_th     // amplitude too small?
is_high_flat = is_flat AND osc_mean >  0.2  // flat at HIGH level
is_low_flat  = is_flat AND osc_mean < -0.2  // flat at LOW level
is_mid_flat  = is_flat AND |osc_mean| ≤ 0.2 // flat in MIDDLE
```

### 6.3 Velocity-Aware Filtering

A naive implementation blocks all signals during flatness. This creates a new bug: a slow, gradual recovery from a low (flat by amplitude metrics, but with clear directional velocity) would be incorrectly suppressed.

The fix: **only block signals when there is genuinely no directional velocity**:

```pine
low_flat_block_buy   = is_low_flat  AND vel_s <= 0
// → If OSC is flat-low BUT velocity is turning UP → allow buy signal through

high_flat_block_sell = is_high_flat AND vel_s >= 0
// → If OSC is flat-high BUT velocity is turning DOWN → allow sell signal through

mid_flat_block_buy   = is_mid_flat  AND vel_s <= 0
mid_flat_block_sell  = is_mid_flat  AND vel_s >= 0
```

This was the root cause of the **OKLO Nov 26, 2025** missing buy signal — the OSC was technically in a low-flat zone, but velocity had turned positive. The v4.2 fix correctly let the signal through.

### 6.4 Background Colour Warnings

| Background Colour | Meaning | Action |
|-------------------|---------|--------|
| 🟥 Red (faint) | High-zone flatness | Sell signals suppressed (unless vel confirms) |
| 🟩 Green (faint) | Low-zone flatness | Buy signals suppressed (unless vel confirms) |
| 🟨 Yellow (faint) | Mid-zone flatness | Both directions suppressed (no trend) |
| No colour | Normal conditions | All signals active |

---

## 7. Visual Reference Guide

### 7.1 Main Price Chart Elements

| Visual Element | Colour | Meaning |
|----------------|--------|---------|
| Small upward triangle label | Cyan/Teal gradient | **Buy signal** — entry point |
| Dashed line extending right | Cyan/Teal | **Buy stop-loss reference line** — trail this |
| ✖ mark at reference line | Cyan/Teal | **Stop-loss triggered** — exit long |
| **▲ label** | Bright Green | **Re-Buy** — price recovered above stop, re-enter long |
| Dashed line (lighter green) | Light Green | **New stop-loss line** after Re-Buy |
| Small downward triangle label | Purple gradient | **Sell signal** — entry point |
| Dashed line extending right | Purple | **Sell stop-loss reference line** |
| ✖ mark at reference line | Purple | **Stop-loss triggered** — cover short |
| **▼ label** | Bright Red | **Re-Sell** — price fell back below stop, re-enter short |
| Dashed line (lighter red) | Light Red | **New stop-loss line** after Re-Sell |

### 7.2 Oscillator Pane Elements

| Visual Element | Colour | Meaning |
|----------------|--------|---------|
| Thick oscillating line | Cyan ↔ Purple gradient | Main Two-Pole OSC (`two_p`) |
| Thin line | Faint white/grey | One-Pole signal line |
| Fill between two lines | Colour-matched | Direction momentum fill |
| Small circle (double ring) | Cyan | Buy signal dot |
| Small circle (double ring) | Purple | Sell signal dot |
| Small solid circle | Green | Re-Buy dot |
| Small solid circle | Red | Re-Sell dot |
| Orange line | Orange | Velocity (`vel_s`) |
| Dashed horizontal line | Orange (faint) | Velocity zero line |

### 7.3 Reference Level Lines

```
 1.00  ──── (extreme overbought)
 0.50  ···· (overbought zone)
 0.00  ════ (centre, alternating)
-0.50  ···· (oversold zone)
-1.00  ──── (extreme oversold)
```

---

## 8. Parameters Reference

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| **Filter Length** | 15 | 1 – ∞ | Controls smoothing of the Two-Pole main line. Lower = faster but noisier. Higher = smoother but more lag. |
| **Signal Line Ratio** | 0.6 | 0.2 – 1.0 | Multiplied by Filter Length to derive signal line period. Lower = signal line faster, crossovers trigger sooner. Recommended: 0.4–0.7. |
| **Velocity Threshold** | 0.03 | 0.005 – 0.1 | Minimum velocity magnitude to trigger velocity-based signals. Higher = fewer early signals. |
| **Flatness Threshold** | 0.15 | 0.05 – 0.5 | Maximum OSC amplitude (10-bar range) below which zone is considered "flat". Higher = more conservative flattening detection. |
| **Show Price Lines** | true | bool | Show/hide the dashed stop-loss reference lines on price chart. |
| **Show Velocity** | true | bool | Show/hide the orange velocity line in OSC pane. |
| **Show Flat Warnings** | true | bool | Show/hide the coloured background flatness zone warnings. |
| **Show Re-Entry** | true | bool | Show/hide ▲ Re-Buy and ▼ Re-Sell signals. |

### 8.1 Tuning Recommendations by Market Type

| Market Type | Filter Length | Signal Ratio | Notes |
|-------------|--------------|--------------|-------|
| Large-cap stocks (daily) | 15 | 0.6 | Default, well balanced |
| Small/mid-cap (more volatile) | 12 | 0.5 | Faster response |
| Weekly chart | 10 | 0.6 | Reduce length for weekly |
| Crypto (high volatility) | 20 | 0.7 | More smoothing needed |
| Sideways market | any | any | Trust flatness warning colours |

---

## 9. Version History & Bug Fix Log

### v1.0 — Original (Baseline)
- Two-Pole OSC with `two_pp = two_p[4]` hard-delay signal line
- Basic crossover buy/sell signals with `two_p < 0` / `two_p > 0` position filter
- Stop-loss reference line (buy/sell) with ✖ on breach

**Known issues:** Signal lag 4–8 bars; flatness paralysis; no re-entry; no lifecycle state management.

---

### v3.0 — Core Improvements
- ① Signal line replaced with **One-Pole EMA** (configurable via `sig_ratio`)
- ② **Velocity line** added for early turning point detection
- ③ **Three-zone flattening detection** (high / low / mid) with background colour warnings
- Flattening zones hard-block corresponding signals

**Remaining issues:** Flatness zones too aggressive — block legitimate signals during slow recoveries.

---

### v4.0 — Re-Entry System
- ④ **Re-Buy ▲** signal when price closes back above stop-loss reference after ✖
- **Re-Sell ▼** signal when price closes back below stop-loss reference after ✖
- State variables (`wait_buy_reentry`, `wait_sell_reentry`) track re-entry waiting status
- Direction reversal cancels opposite re-entry wait

**Remaining issues:** `two_p < 0` position filter blocks signals when fast rebounds cause crossover above zero line. `was_*` memory window only 8 bars (too short).

---

### v4.1 — Signal Position Filter Fix
- ⑤ Replaced `two_p < 0` with `was_low = ta.lowest(two_p, 8) < -0.15`
- Sell side symmetric: `was_high = ta.highest(two_p, 8) > 0.15`
- Velocity position threshold relaxed from ±0.25 to ±0.15
- `is_mid_flat` converted to velocity-aware version

**Remaining issues:** 8-bar window still too short for some fast markets. `is_low_flat` / `is_high_flat` still hard-blocking.

---

### v4.2 — OKLO Nov 26 Root Cause Fix
- ⑥ `was_low` / `was_high` lookback extended from **8 → 14 bars**
- `is_low_flat` converted to velocity-aware: `is_low_flat AND vel_s <= 0`
- `is_high_flat` converted to velocity-aware: `is_high_flat AND vel_s >= 0`
- Label sizes refined (user-modified from v4.1)
- Price labels formatted to 2 decimal places: `str.tostring(value, "#.##")`

**Remaining issues:** Re-entry signals (▲▼) do not rebuild stop-loss reference lines.

---

### v4.3 — IBM Extreme Case Fix *(Current Release)*
- ⑦ **Re-Buy ▲** now immediately rebuilds `buy_line` at `(low - area)` after trigger
- **Re-Sell ▼** now immediately rebuilds `sell_line` at `(high + area)` after trigger
- Re-built lines use lighter colour (green/red 30% transparency) to distinguish from original signals
- Price label added below/above re-built reference lines
- Full stop-loss protection reinstated after every re-entry

---

## 10. Known Limitations & Future Roadmap

### Current Limitations

- The oscillator is **trend-neutral** by design. In a strong trending market, sell signals during an uptrend (or buy signals during a downtrend) will fire. Users should combine with a trend filter (e.g., a long-period SMA direction) for trend-following applications.
- The **14-bar `was_low` window** may still be insufficient for extremely slow-moving recoveries in monthly charts. Consider extending to 20 for very long timeframes.
- **Re-entry is one-time only**: after ▲ Re-Buy fires, if the new stop-loss is also triggered, no second re-entry is attempted. This is conservative by design but may miss multi-wave recovery patterns.
- No **multi-timeframe confirmation**: all signals are generated from the current chart timeframe only.

### Future Roadmap

| Feature | Description | Priority |
|---------|-------------|----------|
| ML probability filter | Integrate logistic regression buy/sell probability (trained per-stock via Python pipeline) | High |
| Trend filter input | Option to only take signals in direction of higher-timeframe trend | High |
| Alert conditions | `alertcondition()` for buy, sell, re-buy, re-sell, and stop triggers | Medium |
| Second re-entry | Allow a second re-entry attempt after the re-built stop-loss is also triggered | Medium |
| ATR-based flatness threshold | Replace fixed `osc_flat_th` with ATR-derived dynamic threshold | Low |
| Multi-timeframe OSC overlay | Show higher-timeframe OSC state in lower-timeframe chart | Low |

---

## 11. Full Source Code

```pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// @CJH - Two-Pole Oscillator v4.3
// 改善項目：
//   ① 信號線改用 One-Pole EMA（取代硬延遲 two_p[4]），減少滯後
//   ② 加入 Velocity 速度線，提前偵測頂底轉折
//   ③ 分區鈍化過濾（速度方向感知版）：高/低/中段各自只在「無速度方向」時才擋信號
//   ④ 停損 ✖ 後若價格反轉超越原參考線 → 顯示綠色 Re-Buy / 紅色 Re-Sell
//   ⑤ Bug Fix v4.1：crossover 發生在 0 線上方時不再誤擋（was_low/was_high 記憶條件）
//   ⑥ Bug Fix v4.2：
//      - was_low/was_high 回望從 8 根延長至 14 根，防止快速反彈超出記憶窗口
//      - is_low_flat / is_high_flat 改為速度感知版（OKLO Nov26 根因修復）
//   ⑦ Bug Fix v4.3（IBM 極端例子）：
//      - Re-Buy  ▲ 觸發後立刻重建 buy_line  停損參考線（以當根 low - area 為基準）
//      - Re-Sell ▼ 觸發後立刻重建 sell_line 停損參考線（以當根 high + area 為基準）
//      - 解決「買回/回補後急跌/急漲卻沒有 ✖ 停損」的問題
//@version=6
indicator("@CJH@TEST@ Two-Pole Oscillator v4.3", max_labels_count = 500, max_lines_count = 500)

// ── INPUTS ───────────────────────────────────────────────────────────────────
int    length       = input.int  (15,   minval=1,              title="Filter Length")
float  sig_ratio    = input.float(0.6,  minval=0.2, maxval=1.0, step=0.05,
                                  title="Signal Line Ratio（越小信號線越快）")
float  vel_thresh   = input.float(0.03, minval=0.005, step=0.005,
                                  title="Velocity 觸發門檻")
float  osc_flat_th  = input.float(0.15, minval=0.05, step=0.01,
                                  title="鈍化偵測門檻（OSC Range）")
bool   disp_lvl     = input.bool (true, "顯示價格支撐/壓力線")
bool   show_vel     = input.bool (true, "顯示 Velocity 線")
bool   show_flat    = input.bool (true, "顯示鈍化背景警示")
bool   show_reentry = input.bool (true, "顯示停損後 Re-Buy / Re-Sell 信號")

color up_color = input.color(#55ffda, "", inline="color")
color dn_color = input.color(#8c5bff, "", inline="color")

// ── PERSISTENT STATE ─────────────────────────────────────────────────────────
var buy_line  = line(na)
var sell_line = line(na)

// Re-entry 狀態
var float reentry_buy_price  = na
var float reentry_sell_price = na
var bool  wait_buy_reentry   = false
var bool  wait_sell_reentry  = false

// ── FILTER FUNCTIONS ─────────────────────────────────────────────────────────
f_two_pole(source, len) =>
    var float s1 = na
    var float s2 = na
    float a = 2.0 / (len + 1)
    s1 := na(s1) ? source : (1 - a) * s1 + a * source
    s2 := na(s2) ? s1     : (1 - a) * s2 + a * s1
    s2

f_one_pole(source, len) =>
    var float s = na
    float a = 2.0 / (len + 1)
    s := na(s) ? source : (1 - a) * s + a * source
    s

// ── CALCULATIONS ─────────────────────────────────────────────────────────────
float sma1   = ta.sma(close, 25)
float sma_n1 = ((close - sma1) - ta.sma(close - sma1, 25)) / ta.stdev(close - sma1, 25)
float area   = ta.sma(high - low, 100)

float two_p = f_two_pole(sma_n1, length)

int   sig_len = math.max(2, math.round(length * sig_ratio))
float signal  = f_one_pole(two_p, sig_len)

float vel   = two_p - two_p[2]
float vel_s = f_one_pole(vel, 3)

float osc_range   = ta.highest(two_p, 10) - ta.lowest(two_p, 10)
float osc_mean    = ta.sma(two_p, 10)

bool is_flat      = osc_range < osc_flat_th
bool is_high_flat = is_flat and osc_mean >  0.2
bool is_low_flat  = is_flat and osc_mean < -0.2
bool is_mid_flat  = is_flat and math.abs(osc_mean) <= 0.2

// ── SIGNALS ──────────────────────────────────────────────────────────────────

// Fix①：was_low/was_high 回望 14 根
bool was_low  = ta.lowest (two_p, 14) < -0.15
bool was_high = ta.highest(two_p, 14) >  0.15

bool buy_cross  = ta.crossover (two_p, signal) and was_low
bool sell_cross = ta.crossunder(two_p, signal) and was_high

bool buy_vel  = ta.crossover (vel_s,  vel_thresh) and two_p < -0.15
bool sell_vel = ta.crossunder(vel_s, -vel_thresh) and two_p >  0.15

// Fix②③：鈍化過濾改為速度方向感知版
bool low_flat_block_buy   = is_low_flat  and vel_s <= 0
bool high_flat_block_sell = is_high_flat and vel_s >= 0
bool mid_flat_block_buy   = is_mid_flat  and vel_s <= 0
bool mid_flat_block_sell  = is_mid_flat  and vel_s >= 0

bool buy  = (buy_cross  or buy_vel)  and barstate.isconfirmed and not low_flat_block_buy  and not mid_flat_block_buy

bool sell = (sell_cross or sell_vel) and barstate.isconfirmed and not high_flat_block_sell and not mid_flat_block_sell

// ── COLORS ───────────────────────────────────────────────────────────────────
color buy_col1  = color.from_gradient(two_p, -1,  0.5, up_color, na)
color buy_col2  = color.from_gradient(two_p, -1,  0.5, color.new(up_color, 50), na)
color sell_col1 = color.from_gradient(two_p, -0.5, 1,  na, dn_color)
color sell_col2 = color.from_gradient(two_p, -0.5, 1,  na, color.new(dn_color, 50))
color osc_color = two_p > signal
                  ? color.from_gradient(two_p, -1, 1, up_color, color.new(up_color, 0))
                  : color.from_gradient(two_p, -1, 1, color.new(dn_color, 0), dn_color)

// ════════════════════════════════════════════════════════════════
//  LABELS & LINES
// ════════════════════════════════════════════════════════════════

// ── 買入信號出現 ──────────────────────────────────────────────────
if buy
    sell_line          := line(na)
    wait_sell_reentry  := false
    reentry_sell_price := na

    if disp_lvl
        buy_line := line.new(
             bar_index, low[0] - area, bar_index, low[0] - area,
             force_overlay=true, color=buy_col1, style=line.style_dashed)

    label.new(bar_index, low[0] - area,
              color=buy_col1, style=label.style_label_up,
              force_overlay=true, size=size.tiny)
    label.new(bar_index, low[0] - area * 1.5,
              color=color.new(color.black, 100),
              text=str.tostring((low[0] - area), "#.##"),
              style=label.style_label_up, force_overlay=true, size=size.small,
              textcolor=color.new(chart.fg_color, 30))

// ── 買入停損 ✖（價格跌破參考線）────────────────────────────────────
if ta.crossunder(low, buy_line.get_y1()) and barstate.isconfirmed
    float sl_price = buy_line.get_y1()

    label.new(bar_index, sl_price,
              color=color.new(up_color, 100), style=label.style_label_center,
              force_overlay=true, size=size.normal, text="✖", textcolor=up_color)

    reentry_buy_price := sl_price
    wait_buy_reentry  := true
    buy_line          := line(na)

// ── Re-Buy 偵測：收盤突破回參考線上方 → ▲ 綠色買回 + 重建停損線 ──
if wait_buy_reentry and show_reentry and not na(reentry_buy_price)
    if ta.crossover(close, reentry_buy_price) and barstate.isconfirmed

        // 主圖：綠色向上標籤
        label.new(bar_index, reentry_buy_price,
                  color=color.new(color.green, 0), style=label.style_label_up,
                  force_overlay=true, size=size.tiny,
                  text="▲", textcolor=color.white)

        // OSC 副圖：綠色圓點
        label.new(bar_index, two_p,
                  color=color.new(color.green, 20),
                  style=label.style_circle, size=size.tiny)

        // ⑦ Bug Fix v4.3：Re-Buy 後立刻重建 buy_line 停損參考線
        //   以當根 low - area 為新的停損基準，之後若急跌仍可觸發 ✖
        if disp_lvl
            buy_line := line.new(
                 bar_index, low[0] - area, bar_index, low[0] - area,
                 force_overlay=true, color=color.new(color.green, 30),
                 style=line.style_dashed)

        label.new(bar_index, low[0] - area * 1.5,
                  color=color.new(color.black, 100),
                  text=str.tostring((low[0] - area), "#.##"),
                  style=label.style_label_up, force_overlay=true, size=size.small,
                  textcolor=color.new(color.green, 30))

        // 重置等待狀態
        wait_buy_reentry  := false
        reentry_buy_price := na

// ── 賣出信號出現 ──────────────────────────────────────────────────
if sell
    buy_line          := line(na)
    wait_buy_reentry  := false
    reentry_buy_price := na

    if disp_lvl
        sell_line := line.new(
             bar_index, high[0] + area, bar_index, high[0] + area,
             force_overlay=true, color=sell_col1, style=line.style_dashed)

    label.new(bar_index, high[0] + area,
              color=sell_col1, style=label.style_label_down,
              force_overlay=true, size=size.tiny)
    label.new(bar_index, high + area * 1.5,
              color=color.new(color.black, 100),
              text=str.tostring((high + area), "#.##"),
              style=label.style_label_down, force_overlay=true, size=size.small,
              textcolor=color.new(chart.fg_color, 30))

// ── 賣出停損 ✖（價格突破參考線上方）────────────────────────────────
if ta.crossover(high, sell_line.get_y1()) and barstate.isconfirmed
    float sl_price_s = sell_line.get_y1()

    label.new(bar_index, sl_price_s,
              color=color.new(dn_color, 100), style=label.style_label_center,
              force_overlay=true, size=size.normal, text="✖", textcolor=dn_color)

    reentry_sell_price := sl_price_s
    wait_sell_reentry  := true
    sell_line          := line(na)

// ── Re-Sell 偵測：收盤跌破參考線下方 → ▼ 紅色回補 + 重建停損線 ──
if wait_sell_reentry and show_reentry and not na(reentry_sell_price)
    if ta.crossunder(close, reentry_sell_price) and barstate.isconfirmed

        // 主圖：紅色向下標籤
        label.new(bar_index, reentry_sell_price,
                  color=color.new(color.red, 0), style=label.style_label_down,
                  force_overlay=true, size=size.tiny,
                  text="▼", textcolor=color.white)

        // OSC 副圖：紅色圓點
        label.new(bar_index, two_p,
                  color=color.new(color.red, 20),
                  style=label.style_circle, size=size.tiny)

        // ⑦ Bug Fix v4.3：Re-Sell 後立刻重建 sell_line 停損參考線
        //   以當根 high + area 為新的停損基準，之後若急漲仍可觸發 ✖
        if disp_lvl
            sell_line := line.new(
                 bar_index, high[0] + area, bar_index, high[0] + area,
                 force_overlay=true, color=color.new(color.red, 30),
                 style=line.style_dashed)

        label.new(bar_index, high[0] + area * 1.5,
                  color=color.new(color.black, 100),
                  text=str.tostring((high[0] + area), "#.##"),
                  style=label.style_label_down, force_overlay=true, size=size.small,
                  textcolor=color.new(color.red, 30))

        wait_sell_reentry  := false
        reentry_sell_price := na

// ── 延伸參考線 ───────────────────────────────────────────────────
switch
    not na(buy_line)  => buy_line. set_x2(bar_index)
    not na(sell_line) => sell_line.set_x2(bar_index)

// ── PLOTS ────────────────────────────────────────────────────────────────────

// 鈍化背景
bgcolor(show_flat and is_high_flat ? color.new(color.red,    88) : na, title="高檔鈍化警示")
bgcolor(show_flat and is_low_flat  ? color.new(color.green,  88) : na, title="低檔鈍化警示")
bgcolor(show_flat and is_mid_flat  ? color.new(color.yellow, 88) : na, title="中段鈍化警示")

// 買賣訊號點（OSC 副圖）
plotshape(buy  ? two_p : na, "Buy",  shape.circle, location.absolute, buy_col2,  0, size=size.small)
plotshape(buy  ? two_p : na, "Buy",  shape.circle, location.absolute, buy_col1,  0, size=size.tiny)
plotshape(sell ? two_p : na, "Sell", shape.circle, location.absolute, sell_col2, 0, size=size.small)
plotshape(sell ? two_p : na, "Sell", shape.circle, location.absolute, sell_col1, 0, size=size.tiny)

// 水平參考線
p11 = plot( 1,    color=color.new(chart.fg_color, 80))
plot        (0.5, color=color.new(chart.fg_color, 50))
p00 = plot( 0,    color=color.new(bar_index % 2 == 0 ? chart.fg_color : na, 0))
plot        (-0.5,color=color.new(chart.fg_color, 50))
p_1 = plot(-1,    color=color.new(chart.fg_color, 80))
fill(p11, p00, 2, -1, color.new(chart.fg_color, 80), na)
fill(p_1, p00, 1, -2, na, color.new(chart.fg_color, 80))

// 主振盪器線 + 信號線 + 填色
p1 = plot(two_p,  color=osc_color,                      linewidth=2, title="Two-Pole OSC")
p2 = plot(signal, color=color.new(chart.fg_color, 55),  linewidth=1, title="Signal Line (One-Pole)")
fill(p1, p2, two_p, signal, osc_color, na)

// 速度線（橘色，可關閉）
plot(show_vel ? vel_s : na,
     color=color.new(color.orange, 20), linewidth=1, title="Velocity")
hline(0, color=color.new(color.orange, 70), linestyle=hline.style_dotted)
```

---

*Document generated: 2026-02-25 | @CJH Two-Pole Oscillator v4.3 | First Release*  
*License: CC BY-NC-SA 4.0 — Free for personal and educational use. Commercial use prohibited without permission.*
