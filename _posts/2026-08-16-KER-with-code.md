---
layout: post
title: Kaufman's Efficiency Ratio (ER) in the BB%B and Two-Pole System
subtitle: Tradingview PINE or Python Flask server  
cover-img: /assets/img/header/2026-04-18/QUANTUM.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-18/QUANTUM.png
published: true
pinned: true
tags: [draft, Kaufman, ER]
---


# Kaufman's Efficiency Ratio (ER) in the BB%B + Two-Pole System

## 1. What ER measures

Perry Kaufman introduced the Efficiency Ratio in *Smarter Trading* (1995) as a
way to answer one question: **for the net distance price moved, how much
back-and-forth did it take to get there?**

```
ER = |Close[t] − Close[t−n]| / Σ|Close[i] − Close[i−1]|   for i = t−n+1 … t
```

- **Numerator** — net displacement over the last `n` bars (a straight-line
  distance: start price vs. end price).
- **Denominator** — the total path length: the sum of every single-bar move,
  regardless of direction.

ER is bounded `[0, 1]`:

- **ER → 1**: price moved almost entirely in one direction — a clean, low-noise
  trend. The path length is close to the net displacement.
- **ER → 0**: price covered a lot of ground but ended up near where it
  started — chop, a sideways grind, or a mean-reverting range. The path
  length is much longer than the net displacement.

It's a *regime* indicator, not a directional one — the sign of the price
move doesn't appear anywhere in the formula, only magnitude. ER can't tell
you up from down; it only tells you whether the recent move was efficient
(trending) or wasteful (choppy).

## 2. Why this matters for BB%B specifically

BB%B (`bb_osc` in this codebase) is a **mean-reversion** oscillator: it
normalizes price's position relative to its Bollinger Bands to a
`-100..+100` scale, and the trade signals (`bb_upFromLower`,
`bb_downFromUpper`, and the extreme-threshold crosses) all fire on the
assumption that a stretched move reverts — price wanders to an extreme,
then snaps back toward the mean.

That assumption breaks exactly in the regime ER is built to detect: a
strongly trending market. In a real trend, price doesn't revert after
tagging the upper or lower band — it rides along it, prints a fresh extreme,
gets briefly "overbought" or "oversold" again, and keeps going. A
mean-reversion signal fired in that regime is fighting the trend, not
riding a reversal. This is the exact failure mode you flagged earlier:
continuous trends where price keeps running past the upper/lower zones
instead of snapping back — a bare BB%B has no way to distinguish "stretched
and about to revert" from "stretched because it's genuinely trending."

ER is the regime filter that sits in front of BB%B to make that
distinction, so the reversal signals only fire when reversal is actually
the more likely behavior.

## 3. Implementation in this codebase

### Pine indicator (`@CJH@ BB%B + Two-Pole Combo Indicator`)

```pine
er_change        = math.abs(close - close[er_len])
er_volatility    = math.sum(math.abs(close - close[1]), er_len)
efficiency_ratio = er_volatility != 0 ? er_change / er_volatility : 0.0
er_pct           = (efficiency_ratio - 0.5) * 200   // 0.0-1.0 -> -100..+100
is_trending_live = er_pct > er_trending_th
```

### Python engine (`bb_pctb_two_pole_combo.py`, `_add_efficiency_ratio`)

```python
er_change = (close - close.shift(cfg.er_len)).abs()
er_volatility = close.diff().abs().rolling(cfg.er_len).sum()
efficiency_ratio = np.where(er_volatility != 0, er_change / er_volatility, 0.0)
er_pct = (efficiency_ratio - 0.5) * 200
out["is_trending_live"] = out["er_pct"] > cfg.er_trending_th
```

Both are a 1:1 port of the same formula — a rolling-window version of
Kaufman's ratio, re-scaled from its native `0.0–1.0` range to `-100..+100`
so it plots on the same axis as BB%B and the Two-Pole oscillator (`0.5`
native → `0%` displayed).

### Parameters

| Name | Default | Meaning |
|---|---|---|
| `er_len` | 10 | Lookback window `n` for the ratio |
| `er_trending_th` | -20 | Threshold on the *rescaled* `er_pct` axis. `-20` corresponds to a native efficiency ratio of `0.4` — i.e. "trending" is declared once ≥40% of the total path length was net progress |
| `use_er_filter` | off (Pine) / off (Python `ComboConfig`) | Master on/off switch for actually gating signals on `is_trending_live`, as opposed to just displaying the line |

### Where it gates trades

```python
er_block_buy  = cfg.use_er_filter & out["is_trending_live"]
er_block_sell = cfg.use_er_filter & out["is_trending_live"]

out["buy"]  = entry_buy_raw  & ~low_flat_block_buy  & ~mid_flat_block_buy  & ~er_block_buy
out["sell"] = entry_sell_raw & ~high_flat_block_sell & ~mid_flat_block_sell & ~er_block_sell
```

When `use_er_filter` is on and the market is currently trending
(`is_trending_live = True`), the raw BB%B triangle/threshold signal is
**suppressed** — not deleted, just prevented from becoming a `buy`/`sell`
entry for that bar. In the Pine indicator this is also shown visually: the
BB%B line dims to 60% transparency exactly when a signal in that direction
would currently be blocked, so you can see the filter's effect live on the
chart before it ever touches the backtest.

This is the polarity that was worth double-checking earlier in this
project — it's "block *while* trending", not "block during chop". The
inverse reading is intuitive (why would you silence a signal during the
one regime where a real move is most likely?) but backwards for what this
filter is protecting against: it isn't guarding against noise, it's
guarding a *mean-reversion* signal against firing into a trend that won't
revert.

## 4. How ER relates to the other two filters in this system

The engine now has three independent gates on entries/exits, and it's easy
to conflate them since they all sit in the same pipeline:

| Gate | Detects | Blocks |
|---|---|---|
| **ER regime filter** (`use_er_filter`) | Trending vs. choppy, via path-efficiency | Mean-reversion `buy`/`sell` signals while trending |
| **Flat filter** (`use_flat_filter`) | A dead/flat Two-Pole oscillator with no velocity | Entries during a stalled, directionless oscillator |
| **Forced-buy / forced-sell debounce** | A BB%B zero-axis crossing that might be a whipsaw | Delays (buy side, 3 bars) or doesn't delay (sell side, 1 bar) the forced full-position trades on a zero-cross |

ER and the flat filter both suppress the *raw triangle/threshold* signals
(`buy`/`sell` columns). The forced-buy/sell debounce is a completely
separate mechanism gating the *zero-axis crossing* rule, and doesn't
consult ER or the flat filter at all — a forced trade can fire even while
`use_er_filter` would have blocked a triangle-based entry the same bar,
since the zero-cross rule is meant to be an unconditional "you're either
fully in or fully out" override, not another reversion signal.

## 5. Worked example: RKLB, 2026-04-21

This is a real case pulled from a live backtest run (`bb_length=14`,
default config), not a hypothetical.

![RKLB chart, 2026-04-21 premature sell / buy-back](/assets/img/header/2026-08-16/rklb-2026-04-21-chart.png){: width="85%" height="50%" .mx-auto.d-block}


Source OHLCV for the window this example uses (`RKLB`, 1D, TradingView
tvdatafeed):

| date | open | high | low | close | volume |
|---|---|---|---|---|---|
| 2026-04-08 | 72.100 | 73.590 | 67.850 | 69.065 | 509,133 |
| 2026-04-09 | 69.285 | 69.520 | 66.590 | 66.755 | 293,522 |
| 2026-04-10 | 67.590 | 70.040 | 66.380 | 68.040 | 252,499 |
| 2026-04-13 | 67.000 | 71.510 | 66.660 | 70.620 | 255,478 |
| 2026-04-14 | 73.530 | 74.730 | 70.480 | 72.200 | 372,883 |
| 2026-04-15 | 73.725 | 74.590 | 69.630 | 73.625 | 457,265 |
| 2026-04-16 | 76.940 | 83.450 | 76.940 | 82.915 | 722,259 |
| 2026-04-17 | 84.375 | 86.915 | 83.610 | 84.810 | 466,745 |
| 2026-04-20 | 84.830 | 90.290 | 84.680 | 89.435 | 411,818 |
| **2026-04-21** | 89.940 | 91.930 | 85.785 | **86.620** | 426,384 |
| **2026-04-22** | 90.980 | 92.770 | 87.900 | **90.010** | 308,521 |
| 2026-04-23 | 89.850 | 90.175 | 81.570 | 84.610 | 311,312 |

A sell triangle fired on 2026-04-21, right in the middle of a strong
rally. One bar later price closed back above that sell's trigger price
without BB%B ever completing a genuine washout through zero in between —
so the weak-signal reversal tracker (§ not covered here, see the
`buyback_fired`/`sellout_fired` logic in `_add_weak_signal_tracker`)
flagged it as premature and fired a correcting buy-back on 4/22. Net
effect: one round-trip trade that shouldn't have happened.

ER for that same window, computed with `use_er_filter=True`:

| date | close | efficiency_ratio | `is_trending_live` (th=0.4) | `sell` fires |
|---|---|---|---|---|
| 04-14 | 72.20 | 0.668 | True | — |
| 04-15 | 73.63 | 0.561 | True | — |
| 04-16 | 82.92 | 0.702 | True | — |
| 04-17 | 84.81 | 0.698 | True | — |
| 04-20 | 89.44 | 0.749 | True | — |
| **04-21** | 86.62 | **0.664** | **True** | **sell fires (with filter off)** |
| 04-22 | 90.01 | 0.671 | True | buyback corrects it |

ER sat at **0.66–0.75** for the entire week leading into and through the
4/21 sell — nowhere close to choppy, comfortably above the 0.4 trending
threshold the whole time. With `use_er_filter=True`, `er_block_sell` would
have been `True` on 4/21 and the sell would never have fired at all.

The comparison this makes concrete: ER and the weak-signal tracker are
catching the *same* mistake from opposite ends of the timeline.

- **ER filter** — proactive. Knows *before* the trade that the regime is
  trending, so a mean-reversion sell shouldn't be trusted, and blocks it
  outright. Net result: no trade at all.
- **Weak-signal tracker** — reactive. Doesn't know anything about regime;
  lets the sell fire, then watches the outcome and corrects it after the
  fact if price proves it wrong. Net result: two trades (the wrong sell,
  then the buy-back that undoes it) instead of zero.

With the ER filter off (as in this specific run), the tracker is doing
ER's job for it — one bar late, and with an extra round-trip trade's worth
of slippage/commission along the way. Turning the ER filter on removes
the round trip entirely for cases like this one; whether that holds up
across a full backtest (rather than just this single case) is worth
checking directly rather than assumed, since ER blocking sells during a
trend has helped some cycles and hurt others elsewhere in this project.

## 6. A natural extension: KAMA

The reference material you shared also flags ER's role as the smoothing
input for Kaufman's Adaptive Moving Average (KAMA) — an EMA whose smoothing
constant is driven by ER itself, so the average tracks tightly in a
trend (`ER → 1`) and flattens out in chop (`ER → 0`). Nothing in this
codebase currently builds a KAMA line; `er_pct` is only consumed as a
boolean gate (`is_trending_live`) today. If a smoother, regime-adaptive
version of the Two-Pole basis is ever wanted, ER is already computed and
sitting right there to drive it — that would be a separate, additive
feature rather than a change to the existing filter logic.