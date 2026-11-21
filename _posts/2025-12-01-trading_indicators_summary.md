---
layout: post
title: Top 3 Free Buy & Sell Indicators on TradingView
subtitle: A complete breakdown of three battle-tested from #3 to #1
cover-img: /assets/img/path.jpg
thumbnail-img: /assets/img/hello_world.jpeg
share-img: /assets/img/path.jpg
published: false    # ← add this, post won't show on blog
pinned: false
tags: [report, test]
---

# Top 3 Free Buy & Sell Indicators on TradingView

> *A complete breakdown of three battle-tested, free TradingView indicators ranked from #3 to #1 — with exact entry rules, settings, and trade management strategies.*

---

## Overview

With thousands of indicators on TradingView, most are ineffective. This guide ranks the top three **free** buy/sell indicators that have been tested and proven to deliver results — covering setup, signal interpretation, entry conditions, and risk management for each.

---

## #3 — Two Pole Oscillator (by Big Beluga)

### What It Is
A momentum oscillator that uses advanced **two-pole filtering** — a dual-layer smoothing technique — to reduce noise while preserving true trend signals. It identifies momentum shifts, trend strength, and trade signals with exceptional clarity.

### Setup
- Search "Two Pole Oscillator" on TradingView indicators, select the version by **Big Beluga**
- Double-click the indicator → Style tab → **Enable the last plot** to reveal the signal line (thin blue line)

### How to Read It
- The oscillator switches between **purple** (bearish) and **blue** (bullish)
- **Buy signal:** Oscillator crosses *above* the signal line → blue upward arrow prints
- **Sell signal:** Oscillator drops *below* the signal line → downward arrow prints
- **Invalidation levels** (dotted lines): Natural stop-loss zones. If price touches them, an "X" label appears — the trade is invalidated

### Key Levels
| Level | Meaning |
|-------|---------|
| Above +0.5 | Overbought |
| Above +1.0 | Strongly overbought |
| Below -0.5 | Oversold |
| Below -1.0 | Extremely oversold |

### Combine With: VIDya Indicator (Volumetric Variable Index Dynamic Average)
- Add the **VIDya indicator**, set length to **34**, disable the "Length" plot
- Green ribbon = bullish trend | Red ribbon = bearish trend
- Requires **Delta Volume ≥ 20%** to confirm a strong trend

### Entry Rules

**Long Trade:**
1. Buy signal printed **below the 0.5 level** (gray line) — signals above are invalid
2. VIDya ribbon is **green** (bullish trend)
3. Delta Volume is **≥ 20%**
4. ⚠️ Signal is **delayed by 2 candles** — enter after the close of the 2nd candle
5. Stop loss: just below the invalidation level (dotted line)
6. Take profit: **1.5× the risk**

**Short Trade:**
1. Sell signal printed **above the -0.5 level**
2. VIDya ribbon is **red** (bearish trend)
3. Delta Volume is **≤ -20%**
4. Enter after 2-candle delay
5. Stop loss: just above the invalidation level
6. Take profit: **1.5× the risk**

---

## #2 — Zero Lag Trend Signals (by ALGO Alpha)

### What It Is
Combines **ATR (Average True Range)** with **zero-lag technology** to eliminate false signals. Works across all markets (stocks, forex, crypto) and all timeframes. Designed to solve the #1 problem in technical analysis: lag.

### Setup
- Search "Zero Lag Trend Signals" → select the version by **ALGO Alpha**
- Default settings recommended

### Components
- **Trend Ribbon:** Green (bullish) / Red (bearish) — ATR-powered, filters false signals
- **Main Reversal Arrows:** Large green/red arrows mark full trend reversals (no lag)
- **Mini Arrows:** Small arrows appear during pullbacks when price closes back above/below the ribbon — pullback entry signals
- **Multi-Timeframe Dashboard:** Displays trend direction across 5 timeframes (5m, 15m, 1h, 4h, Daily) simultaneously

### Strategy 1: Trend Reversals
**Bullish Setup:**
1. Wait for large green upward arrow
2. All 5 timeframes on dashboard must show **bullish** — if even one is bearish, skip the trade
3. Stop loss: below the trend ribbon
4. Take profit: **1.5× the risk**

**Bearish Setup:** Mirror image — red arrow, all 5 timeframes bearish, stop above ribbon.

### Strategy 2: Pullback Mastery
**Bullish Pullback:**
1. Ribbon is green (trend is up)
2. Wait for green **mini arrow** (price touched ribbon and closed back above)
3. Dashboard: 15m, 1h, 4h, and Daily must be **bullish** — 5m can be bearish (normal during pullback)
4. Stop loss: below the most recent swing low
5. Take profit: **1.0–1.5× the risk**

**Bearish Pullback:** Same logic reversed.

### Strategy 3: Combined with Momentum Bias Index (by ALGO Alpha)
Add the **Momentum Bias Index** indicator (default settings).

**Long Entry Requirements:**
1. Bullish reversal signal from Zero Lag Trend Signals
2. Histogram bar on Momentum Bias Index must be **bright green** (not dark green — invalid)
3. Green histogram must close **beyond the dotted threshold line**
4. Stop loss: at the base of the trend ribbon
5. Take profit: **2× the risk** (backtesting shows this frequently exceeds 2:1)

**Short Entry Requirements:** Mirror — bearish reversal signal + bright red histogram extending beyond the bearish threshold.

---

## #1 — DIY Custom Strategy Builder (by ZPIEM)

### What It Is
The ultimate all-in-one tool that combines **40+ world-class indicators** into a single, customizable strategy engine. Instead of juggling multiple indicator windows, this tool lets you define your own strategy rules and get clean, consolidated buy/sell signals.

### Setup
- Search "DIY Custom Strategy Builder" → select the version by **ZPIEM**
- Works on all markets and timeframes (5m scalping to 4h swing trading)

### Key Features
- **Buy/sell signals:** Print when ALL your chosen indicator conditions are simultaneously met
- **Automatic candle coloring:** Green (bullish momentum), Red (bearish pressure), Gray (consolidation/chop)
- **Dashboard table:** Shows checkmarks/crosses for each indicator condition in real-time
- **Switchboard:** Toggle visual overlays on/off — supply & demand zones, 200 EMA line, support/resistance, Parabolic SAR, liquidity zones, market session times, and more (up to 14 tools)

### Example Strategy: SuperTrend + 200 EMA + MACD

**Configuration:**
1. **Leading indicator:** SuperTrend (primary signal generator)
2. **Confirmation 1:** EMA → set length to **200**
3. **Confirmation 2:** MACD → enable crossover/histogram condition of your choice
4. **Signal Expire:** Set to 3 candles (system waits up to 3 candles for confirmations to align; set to 1 for precision entries)

**A Buy Signal fires when ALL of these occur simultaneously:**
- SuperTrend flips bullish
- Price closes above the 200 EMA
- MACD meets the bullish condition

### Trade Execution

**Long Entry:**
1. Buy signal prints on the chart
2. Check candle color — ideally **green** (confirms bullish momentum)
3. Check if signal is near a **demand zone** (institutional buyers likely present)
4. Stop loss: below the most recent swing low
5. Take profit: **1.5× the risk** minimum
6. Move stop to **break even** once price moves 1:1 in your favor

**Short Entry:**
1. Sell signal prints
2. Check candle color — ideally **red**
3. Check if signal is near a **supply zone**
4. Stop loss: above the most recent swing high
5. Take profit: **1.5× the risk**
6. Move stop to break even at 1:1

### Available Indicator Library (40+)
Ichimoku, SuperTrend, BX-Trender, WADA ATR Explosion, Range Filters, ADX, RSI, Stochastics, MACD, EMA, and many more — mix and match for any trading style.

---

## Summary Comparison

| Rank | Indicator | Best For | Key Edge | TP Target |
|------|-----------|----------|----------|-----------|
| #3 | Two Pole Oscillator | Momentum trading with trend filter | Two-pole noise filtering + VIDya Delta Volume | 1.5× Risk |
| #2 | Zero Lag Trend Signals | Reversals & pullbacks, multi-TF confirmation | Zero-lag ATR + 5-TF dashboard | 1.5–2× Risk |
| #1 | DIY Custom Strategy Builder | Any style — fully customizable | 40+ indicators in one, candle coloring, switchboard | 1.5× Risk |

---

## Universal Risk Management Rules
- Always use the invalidation level or swing structure for **stop placement**
- Default take profit: **1.5× risk** (use 2× with Momentum Bias Index strategy)
- Move stop to **break even at 1:1** to protect capital
- Never enter on a signal alone — always wait for **context confirmation** (candle color, zones, dashboard)

---

*Not financial advice — educational content only. All indicators mentioned are free on TradingView.*
