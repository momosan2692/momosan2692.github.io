---
layout: post
title: A Stock Reinforcement-Learning Sandbox with PPO and Stable-Baselines3
subtitle: SB3 early builds
cover-img: /assets/img/header/2026-04-18/QUANTUM.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-18/QUANTUM.png
published: true
pinned: true
mathjax: true
tags: [draft, 推論引擎]
---

# Building a Stock Reinforcement-Learning Sandbox with PPO and Stable-Baselines3

> **Scope and disclaimer.** This guide builds a *research sandbox*: a place to learn how RL behaves on market data, to test ideas, and to see how easily RL overfits. It is not a trading system and not financial advice. Daily-bar price data has a very low signal-to-noise ratio, so most RL agents trained on it will not beat buy-and-hold after costs. A good sandbox is one that tells you that honestly.

---

## Table of Contents

0. [What you will build](#0-what-you-will-build)
1. [Framing trading as an RL problem](#1-framing-trading-as-an-rl-problem)
2. [Setup](#2-setup)
3. [Project layout and config](#3-project-layout-and-config)
4. [Data and features (and how to avoid leakage)](#4-data-and-features)
5. [The Gymnasium trading environment](#5-the-gymnasium-trading-environment)
6. [Validating the environment before training](#6-validating-the-environment)
7. [Training PPO with Stable-Baselines3](#7-training-ppo)
8. [Evaluation, baselines and metrics](#8-evaluation-baselines-and-metrics)
9. [Hyperparameter tuning and multi-seed runs](#9-hyperparameter-tuning-and-multi-seed-runs)
10. [Failure modes and diagnostics](#10-failure-modes-and-diagnostics)
11. [Extensions roadmap](#11-extensions-roadmap)
12. [Checklist](#12-checklist)
13. [Further reading](#13-further-reading)

---

## 0. What you will build

A complete pipeline:

```
prices (OHLCV) -> features -> Gymnasium env -> PPO (SB3) -> validation -> held-out test
                                   ^                              |
                                   +---- transaction costs, ------+
                                         position state, baselines
```

Concretely:

| Piece | File |
|---|---|
| Config (ticker, dates, window, costs) | `config.py` |
| Data download, caching, feature engineering, time splits | `src/data.py` |
| Single-stock trading environment (Gymnasium API) | `src/env.py` |
| Performance metrics (Sharpe, drawdown, CAGR, ...) | `src/metrics.py` |
| Backtest runner, buy-and-hold and random baselines | `src/backtest.py` |
| PPO training with validation-based model selection | `train.py` |
| Evaluation + plots | `evaluate.py` |
| Optuna hyperparameter search | `tune.py` |
| Environment unit tests | `tests/test_env.py` |

---

## 1. Framing trading as an RL problem

| RL concept | Choice in this guide | Alternatives |
|---|---|---|
| **Agent** | PPO (`MlpPolicy`) | RecurrentPPO, SAC, A2C |
| **Observation** | Last `W` days of normalized features + current position weight | Raw OHLCV windows, order-book data, news embeddings |
| **Action** | One continuous number in `[-1, 1]`, mapped to a **target exposure** in `[0, 1]` (long-only) | Discrete {sell, hold, buy}; multi-asset weight vector; short selling |
| **Reward** | Per-step **log growth of equity, net of costs** (x100 for scale) | Differential Sharpe, drawdown-penalized return |
| **Episode** | Random 252-day window of the training period | Full history; walk-forward windows |
| **Transition** | Historical replay: the agent does not move the market | Simulators with market impact |

Three modeling decisions matter more than any hyperparameter:

1. **Timing.** The agent sees features computed from data up to and including the close of day *t*, picks a target exposure, and earns the return from close *t* to close *t+1*. Features never include day *t+1*.
2. **Costs.** Every change in exposure is charged `cost_bps` of the traded notional. Without costs, PPO will happily flip positions daily on noise.
3. **State includes the current position.** Without it the agent cannot know that changing exposure costs money.

---

## 2. Setup

```bash
python -m venv .venv && source .venv/bin/activate
pip install --upgrade pip
pip install "stable-baselines3[extra]" sb3-contrib gymnasium
pip install yfinance pandas numpy matplotlib optuna pytest tensorboard
```

Notes:

- **Stable-Baselines3 2.x uses Gymnasium**, not the old `gym`. Your environment must return `(obs, info)` from `reset()` and `(obs, reward, terminated, truncated, info)` from `step()`.
- **Use the CPU for `MlpPolicy`.** PPO with small MLPs is bottlenecked by environment stepping and tiny matrix multiplies, so a GPU (or Apple's MPS backend) is usually *slower*. Pass `device="cpu"` explicitly to silence the SB3 warning and get predictable speed.
- Pin your versions (`pip freeze > requirements.txt`) so results are reproducible.

Create the folders:

```bash
mkdir -p src tests data models runs reports
touch src/__init__.py
```

---

## 3. Project layout and config

```
rl-sandbox/
├── config.py
├── train.py
├── evaluate.py
├── tune.py
├── src/
│   ├── __init__.py
│   ├── data.py
│   ├── env.py
│   ├── metrics.py
│   └── backtest.py
├── tests/test_env.py
├── data/        # cached CSVs
├── models/      # checkpoints and best models
├── runs/        # TensorBoard logs
└── reports/     # plots
```

```python
# file: config.py
TICKER = "AAPL"

# Chronological splits. Never shuffle time-series data across splits.
TRAIN = ("2010-01-01", "2021-12-31")   # PPO learns here
VAL   = ("2022-01-01", "2023-12-31")   # model selection and tuning
TEST  = ("2024-01-01", "2026-09-30")   # touch ONCE at the very end

WINDOW = 20           # days of history in each observation
EPISODE_LEN = 252     # trading days per training episode
COST_BPS = 5.0        # 5 bps = 0.05% per unit of turnover (commission + slippage)
GAMMA = 0.99
```

Choose a split that contains more than one market regime in training (bull, bear, sideways). A training set that is one long bull run teaches the agent "always be long".

---

## 4. Data and features

### 4.1 Rules that prevent leakage

1. Every feature at row *t* may use data from rows `<= t` only.
2. The label (`fwd_ret`, the next-day return) is never part of the observation.
3. Normalize with **rolling (causal) statistics**, or fit scalers on the training split only. Do not z-score using the full-history mean and standard deviation.
4. Split by date, in order: train, then validation, then test.
5. Use adjusted prices (`auto_adjust=True`) so splits and dividends do not create fake jumps.

### 4.2 Code

```python
# file: src/data.py
from pathlib import Path

import numpy as np
import pandas as pd


def load_prices(ticker: str, start: str, end: str, cache_dir: str = "data") -> pd.DataFrame:
    """Download adjusted OHLCV with yfinance, cached as CSV. Delete the file to refresh."""
    path = Path(cache_dir) / f"{ticker}_{start}_{end}.csv"
    if path.exists():
        return pd.read_csv(path, index_col=0, parse_dates=True)

    import yfinance as yf

    df = yf.download(ticker, start=start, end=end, auto_adjust=True, progress=False)
    if isinstance(df.columns, pd.MultiIndex):          # newer yfinance returns MultiIndex columns
        df.columns = df.columns.get_level_values(0)
    df = df[["Open", "High", "Low", "Close", "Volume"]].dropna()
    path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(path)
    return df


def rolling_z(s: pd.Series, win: int = 252, clip: float = 5.0) -> pd.Series:
    """Causal z-score: uses only the trailing `win` rows (including the current one)."""
    z = (s - s.rolling(win).mean()) / (s.rolling(win).std() + 1e-8)
    return z.clip(-clip, clip)


def make_features(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.Series]:
    """Return (features X, next-day return y), aligned on the same dates."""
    c, v = df["Close"], df["Volume"]
    logc = np.log(c)
    ret1 = logc.diff()

    f = pd.DataFrame(index=df.index)
    f["ret_1"] = ret1
    f["ret_5"] = logc.diff(5)
    f["ret_20"] = logc.diff(20)
    f["vol_20"] = ret1.rolling(20).std()

    # RSI(14), Wilder smoothing, centered to [-0.5, 0.5]
    delta = c.diff()
    up = delta.clip(lower=0).ewm(alpha=1 / 14, adjust=False).mean()
    down = (-delta.clip(upper=0)).ewm(alpha=1 / 14, adjust=False).mean()
    f["rsi_14"] = (100 - 100 / (1 + up / (down + 1e-12))) / 100 - 0.5

    # MACD histogram, scaled by price
    macd = c.ewm(span=12, adjust=False).mean() - c.ewm(span=26, adjust=False).mean()
    f["macd_hist"] = (macd - macd.ewm(span=9, adjust=False).mean()) / c

    # Bollinger %B, centered and clipped
    ma20, sd20 = c.rolling(20).mean(), c.rolling(20).std()
    f["bb_pctb"] = ((c - (ma20 - 2 * sd20)) / (4 * sd20 + 1e-12) - 0.5).clip(-1.5, 1.5)

    f["sma_gap_50"] = c / c.rolling(50).mean() - 1
    f["vol_z"] = np.log1p(v)

    # Causal z-scoring for everything except already-bounded oscillators
    for col in ["ret_1", "ret_5", "ret_20", "vol_20", "macd_hist", "sma_gap_50", "vol_z"]:
        f[col] = rolling_z(f[col])

    out = f.copy()
    out["fwd_ret"] = c.pct_change().shift(-1)           # close[t+1] / close[t] - 1  (the label)
    out = out.dropna()
    return out.drop(columns="fwd_ret"), out["fwd_ret"]


def split_by_date(X: pd.DataFrame, y: pd.Series, start: str, end: str):
    m = (X.index >= start) & (X.index <= end)
    return X.loc[m], y.loc[m]
```

Feature ideas to add later: sector or index returns (SPY, QQQ), VIX level, day-of-week, fundamentals, earnings-date proximity. Add one group at a time and watch validation, not training reward.

---

## 5. The Gymnasium trading environment

### 5.1 Design decisions

- **Action to exposure.** The policy outputs `a in [-1, 1]` (SB3 clips Gaussian samples to the action bounds). For long-only, `target = (a + 1) / 2`, so `a = 0` means 50% invested and `a = -1` means all cash. With `allow_short=True`, `target = a` (range -1 to +1).
- **Equity accounting.** Equity is tracked as a growth multiple starting at 1.0.
  `growth = 1 + target * r - cost_rate * |target - w_prev|` where `w_prev` is the exposure *after drifting with the market*:
  `w_next = target * (1 + r) / (1 + target * r)`.
- **Reward.** `100 * log(growth)`. Log growth is additive over time, penalizes big losses more than it rewards equal-sized gains, and the x100 puts rewards near 1.0 for typical daily moves.
- **Termination.** `terminated=True` if equity drops below `ruin_equity` (default 0.3). `truncated=True` when the episode window ends.
- **Randomized starts** during training expose PPO to many regimes; evaluation uses `random_start=False` and runs the whole split once, deterministically.

### 5.2 Code

```python
# file: src/env.py
import gymnasium as gym
import numpy as np
from gymnasium import spaces


class SingleStockEnv(gym.Env):
    """Daily single-asset trading env with continuous target exposure and transaction costs.

    features:    (N, F) array, row t uses information up to the close of day t only.
    fwd_returns: (N,)   array, fwd_returns[t] = close[t+1] / close[t] - 1.
    """

    metadata = {"render_modes": []}

    def __init__(
        self,
        features,
        fwd_returns,
        window: int = 20,
        cost_bps: float = 5.0,
        allow_short: bool = False,
        episode_len: int | None = 252,
        random_start: bool = True,
        reward_scale: float = 100.0,
        ruin_equity: float = 0.3,
    ):
        super().__init__()
        assert len(features) == len(fwd_returns), "features and returns must align"
        self.features = np.asarray(features, dtype=np.float32)
        self.fwd = np.asarray(fwd_returns, dtype=np.float64)
        self.n, self.n_feat = self.features.shape

        self.window = window
        self.cost_rate = cost_bps / 1e4
        self.allow_short = allow_short
        self.episode_len = episode_len or (self.n - window)     # None -> run the whole split
        assert self.episode_len <= self.n - window, "not enough data for this window/episode length"
        self.random_start = random_start
        self.reward_scale = reward_scale
        self.ruin_equity = ruin_equity

        self.action_space = spaces.Box(low=-1.0, high=1.0, shape=(1,), dtype=np.float32)
        self.observation_space = spaces.Box(
            low=-np.inf, high=np.inf, shape=(window * self.n_feat + 1,), dtype=np.float32
        )

    # ------------------------------------------------------------------ helpers
    def _obs(self) -> np.ndarray:
        win = self.features[self.t - self.window + 1 : self.t + 1]          # rows <= t only
        return np.concatenate([win.ravel(), [self.w]]).astype(np.float32)

    # ---------------------------------------------------------------- Gym API
    def reset(self, *, seed=None, options=None):
        super().reset(seed=seed)
        lo, hi = self.window - 1, self.n - self.episode_len                  # hi is exclusive
        self.t = int(self.np_random.integers(lo, hi)) if self.random_start else lo
        self.end = self.t + self.episode_len
        self.equity = 1.0
        self.w = 0.0                                                         # start in cash
        return self._obs(), {"equity": self.equity, "weight": self.w}

    def step(self, action):
        a = float(np.clip(np.asarray(action).ravel()[0], -1.0, 1.0))
        target = a if self.allow_short else (a + 1.0) / 2.0

        turnover = abs(target - self.w)
        cost = self.cost_rate * turnover
        r = self.fwd[self.t]                                                 # return from close t to close t+1

        gross = 1.0 + target * r
        growth = max(gross - cost, 1e-8)
        reward = float(np.log(growth) * self.reward_scale)

        self.equity *= growth
        self.w = target * (1.0 + r) / gross if gross > 1e-8 else 0.0         # exposure drifts with the market
        self.t += 1

        terminated = bool(self.equity < self.ruin_equity)
        truncated = bool(self.t >= self.end)
        info = {
            "equity": self.equity,
            "weight": self.w,
            "target_weight": target,
            "turnover": turnover,
            "cost": cost,
        }
        return self._obs(), reward, terminated, truncated, info
```

---

## 6. Validating the environment

Most "RL isn't working" problems are environment bugs. Test the environment *before* training anything.

### 6.1 Unit tests with known answers

```python
# file: tests/test_env.py
import numpy as np

from src.env import SingleStockEnv


def _make(cost_bps=0.0, n=300):
    rng = np.random.default_rng(0)
    feats = rng.normal(size=(n, 3)).astype(np.float32)
    fwd = rng.normal(0.0005, 0.01, size=n)
    env = SingleStockEnv(feats, fwd, window=10, cost_bps=cost_bps, episode_len=100, random_start=False)
    return env, fwd


def _run_constant(env, a):
    env.reset(seed=0)
    done = False
    while not done:
        _, _, term, trunc, info = env.step(np.array([a], dtype=np.float32))
        done = term or trunc
    return info


def test_flat_agent_keeps_cash():
    env, _ = _make()
    info = _run_constant(env, -1.0)                      # target exposure 0
    assert abs(info["equity"] - 1.0) < 1e-9


def test_always_long_matches_buy_and_hold_when_free():
    env, fwd = _make(cost_bps=0.0)
    info = _run_constant(env, 1.0)                       # target exposure 1
    expected = np.prod(1.0 + fwd[9 : 9 + 100])
    assert abs(info["equity"] - expected) < 1e-9


def test_costs_reduce_equity():
    free, _ = _make(cost_bps=0.0)
    costly, _ = _make(cost_bps=50.0)
    assert _run_constant(costly, 1.0)["equity"] < _run_constant(free, 1.0)["equity"]


def test_observation_shape_and_dtype():
    env, _ = _make()
    obs, _ = env.reset(seed=0)
    assert obs.shape == env.observation_space.shape and obs.dtype == np.float32
```

Run: `python -m pytest -q`

### 6.2 SB3's environment checker

```python
from stable_baselines3.common.env_checker import check_env
import config as C
from src.data import load_prices, make_features
from src.env import SingleStockEnv

X, y = make_features(load_prices(C.TICKER, C.TRAIN[0], C.TEST[1]))
env = SingleStockEnv(X.values, y.values, window=C.WINDOW, cost_bps=C.COST_BPS)
check_env(env, warn=True)          # silent output = good
```

### 6.3 Random-agent sanity check

A random policy should *lose a little* to costs relative to a 50%-exposure benchmark, with high variance across seeds. If a random agent makes consistent money, you have leakage. `src/backtest.py` below includes a `random_baseline`.

---

## 7. Training PPO

### 7.1 Hyperparameters in a trading context

| Parameter | Starting value | What it does here |
|---|---|---|
| `n_envs` | 8 | Parallel copies of the env. More envs give more diverse, less correlated rollouts. `DummyVecEnv` is enough since the env is cheap. |
| `n_steps` | 2048 (per env) | Rollout length before each update. With 8 envs, 16,384 samples per update. |
| `batch_size` | 256 | Minibatch size. Keep `n_steps * n_envs` divisible by it to avoid an SB3 warning. |
| `n_epochs` | 10 | Passes over each rollout. **Lower (3-5) if the agent overfits.** |
| `learning_rate` | 3e-4, linearly decayed | Decay stabilizes late training. |
| `gamma` | 0.99 | Effective horizon of about 100 steps. Daily trading with costs rarely needs more. |
| `gae_lambda` | 0.95 | Bias/variance trade-off of advantages. Keep. |
| `clip_range` | 0.2 | Trust-region size. Smaller means more conservative updates. |
| `ent_coef` | 0.005 | Exploration bonus. If the policy collapses to always-flat or always-long, raise it (0.01-0.02). |
| `net_arch` | `pi=[128,128], vf=[128,128]` | Small networks are enough. Bigger ones overfit noise faster. |
| `VecNormalize` | `norm_reward=True`, `norm_obs=False` | Features are already z-scored, so only rewards are normalized. |

### 7.2 Code

```python
# file: train.py
import argparse
from pathlib import Path

import torch.nn as nn
from stable_baselines3 import PPO
from stable_baselines3.common.callbacks import CheckpointCallback, EvalCallback
from stable_baselines3.common.monitor import Monitor
from stable_baselines3.common.vec_env import DummyVecEnv, VecNormalize

import config as C
from src.data import load_prices, make_features, split_by_date
from src.env import SingleStockEnv


def linear_schedule(initial_lr: float):
    """SB3 passes `progress_remaining`, which goes from 1.0 to 0.0 during training."""
    return lambda progress_remaining: progress_remaining * initial_lr


def make_env_fn(X, y, **env_kwargs):
    def _init():
        env = SingleStockEnv(X.values, y.values, window=C.WINDOW, cost_bps=C.COST_BPS, **env_kwargs)
        return Monitor(env)          # logs raw episode reward/length for TensorBoard
    return _init


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--steps", type=int, default=1_000_000)
    p.add_argument("--n-envs", type=int, default=8)
    p.add_argument("--seed", type=int, default=0)
    p.add_argument("--run-name", default="ppo_v1")
    args = p.parse_args()

    df = load_prices(C.TICKER, C.TRAIN[0], C.TEST[1])
    X, y = make_features(df)
    Xtr, ytr = split_by_date(X, y, *C.TRAIN)
    Xva, yva = split_by_date(X, y, *C.VAL)
    print(f"train rows: {len(Xtr)}, val rows: {len(Xva)}, features: {X.shape[1]}")

    # Training env: random 252-day windows
    train_env = DummyVecEnv(
        [make_env_fn(Xtr, ytr, episode_len=C.EPISODE_LEN, random_start=True) for _ in range(args.n_envs)]
    )
    train_env = VecNormalize(train_env, norm_obs=False, norm_reward=True, gamma=C.GAMMA)

    # Validation env: the whole validation period, one deterministic pass
    eval_env = DummyVecEnv([make_env_fn(Xva, yva, episode_len=None, random_start=False)])
    eval_env = VecNormalize(eval_env, training=False, norm_obs=False, norm_reward=False)

    out = Path("models") / args.run_name
    out.mkdir(parents=True, exist_ok=True)

    eval_cb = EvalCallback(
        eval_env,
        best_model_save_path=str(out / "best"),
        log_path=str(out / "eval_logs"),
        eval_freq=max(20_000 // args.n_envs, 1),     # counted in calls per env
        n_eval_episodes=1,
        deterministic=True,
    )
    ckpt_cb = CheckpointCallback(
        save_freq=max(100_000 // args.n_envs, 1),
        save_path=str(out / "checkpoints"),
        name_prefix="ppo",
    )

    model = PPO(
        "MlpPolicy",
        train_env,
        learning_rate=linear_schedule(3e-4),
        n_steps=2048,
        batch_size=256,
        n_epochs=10,
        gamma=C.GAMMA,
        gae_lambda=0.95,
        clip_range=0.2,
        ent_coef=0.005,
        vf_coef=0.5,
        max_grad_norm=0.5,
        policy_kwargs=dict(net_arch=dict(pi=[128, 128], vf=[128, 128]), activation_fn=nn.Tanh),
        tensorboard_log="runs",
        seed=args.seed,
        device="cpu",
        verbose=1,
    )
    model.learn(total_timesteps=args.steps, callback=[eval_cb, ckpt_cb],
                tb_log_name=args.run_name, progress_bar=True)

    model.save(str(out / "final"))
    train_env.save(str(out / "vecnormalize.pkl"))   # only needed if you later enable norm_obs=True


if __name__ == "__main__":
    main()
```

Run it:

```bash
python train.py --steps 1000000 --n-envs 8 --seed 0 --run-name ppo_v1
tensorboard --logdir runs
```

### 7.3 What to watch in TensorBoard

| Metric | Healthy | Warning sign |
|---|---|---|
| `rollout/ep_rew_mean` | Rises, then plateaus | Rises forever (overfitting) or flat from the start |
| `eval/mean_reward` (validation) | Tracks training for a while, then flattens | Falls while training reward rises: **overfitting**, stop early |
| `train/entropy_loss` / `train/std` | Declines gradually | Collapses in the first few updates (raise `ent_coef`) |
| `train/approx_kl` | Around 0.005-0.02 | Spikes above 0.05 (lower learning rate or `clip_range`) |
| `train/clip_fraction` | 0.05-0.2 | Above 0.4 means updates are too aggressive |
| `train/explained_variance` | Slightly positive | Near 0 is normal in noisy markets. Negative and stuck means check the reward scale. |

`EvalCallback` keeps `models/<run>/best/best_model.zip` according to *validation* reward. That is model selection, so validation is now partly "used up". The test set remains untouched.

---

## 8. Evaluation, baselines and metrics

### 8.1 Metrics

```python
# file: src/metrics.py
import numpy as np
import pandas as pd


def perf_metrics(equity, periods_per_year: int = 252) -> dict:
    """equity: sequence of portfolio values (any starting level). Risk-free rate assumed 0."""
    eq = pd.Series(np.asarray(equity, dtype=float))
    rets = eq.pct_change().dropna()
    years = len(rets) / periods_per_year
    total = eq.iloc[-1] / eq.iloc[0] - 1
    cagr = (eq.iloc[-1] / eq.iloc[0]) ** (1 / years) - 1 if years > 0 else np.nan
    vol = rets.std() * np.sqrt(periods_per_year)
    sharpe = rets.mean() / rets.std() * np.sqrt(periods_per_year) if rets.std() > 0 else 0.0
    downside = rets[rets < 0].std()
    sortino = rets.mean() / downside * np.sqrt(periods_per_year) if downside and downside > 0 else 0.0
    max_dd = (eq / eq.cummax() - 1).min()
    calmar = cagr / abs(max_dd) if max_dd < 0 else np.nan
    return {
        "total_return": total,
        "cagr": cagr,
        "ann_vol": vol,
        "sharpe": sharpe,
        "sortino": sortino,
        "max_drawdown": max_dd,
        "calmar": calmar,
    }
```

### 8.2 Backtest runner and baselines

```python
# file: src/backtest.py
import numpy as np
import pandas as pd

import config as C
from src.env import SingleStockEnv


def make_raw_env(X, y, **kw):
    return SingleStockEnv(X.values, y.values, window=C.WINDOW, cost_bps=C.COST_BPS, **kw)


def run_episode(model, X, y, deterministic: bool = True) -> pd.DataFrame:
    """Run the policy once over the whole split. Returns equity, exposure and turnover by date."""
    env = make_raw_env(X, y, episode_len=None, random_start=False)
    obs, _ = env.reset(seed=0)
    equity, weight, turnover = [1.0], [0.0], [0.0]
    done = False
    while not done:
        action, _ = model.predict(obs, deterministic=deterministic)
        obs, _, term, trunc, info = env.step(action)
        equity.append(info["equity"])
        weight.append(info["target_weight"])
        turnover.append(info["turnover"])
        done = term or trunc
    idx = X.index[C.WINDOW - 1 : C.WINDOW - 1 + len(equity)]
    return pd.DataFrame({"equity": equity, "weight": weight, "turnover": turnover}, index=idx)


def buy_and_hold(X, y) -> pd.Series:
    """Fully invested from the first decision date, no costs (a standard benchmark)."""
    start = C.WINDOW - 1
    growth = np.concatenate([[1.0], np.cumprod(1.0 + y.values[start : len(y) - 1])])
    return pd.Series(growth, index=X.index[start : start + len(growth)], name="buy_and_hold")


def random_baseline(X, y, n: int = 20, seed: int = 0):
    """Mean and std of final equity for a uniformly random policy."""
    finals = []
    for i in range(n):
        env = make_raw_env(X, y, episode_len=None, random_start=False)
        env.reset(seed=seed + i)
        env.action_space.seed(seed + i)
        done = False
        while not done:
            _, _, term, trunc, info = env.step(env.action_space.sample())
            done = term or trunc
        finals.append(info["equity"])
    return float(np.mean(finals)), float(np.std(finals))
```

### 8.3 Evaluation script

```python
# file: evaluate.py
import argparse
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd
from stable_baselines3 import PPO

import config as C
from src.backtest import buy_and_hold, random_baseline, run_episode
from src.data import load_prices, make_features, split_by_date
from src.metrics import perf_metrics


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--model", required=True, help="path to a saved SB3 model .zip")
    p.add_argument("--split", choices=["train", "val", "test"], default="val")
    p.add_argument("--tag", default="ppo")
    args = p.parse_args()

    X, y = make_features(load_prices(C.TICKER, C.TRAIN[0], C.TEST[1]))
    span = {"train": C.TRAIN, "val": C.VAL, "test": C.TEST}[args.split]
    Xs, ys = split_by_date(X, y, *span)

    model = PPO.load(args.model, device="cpu")
    res = run_episode(model, Xs, ys, deterministic=True)
    bh = buy_and_hold(Xs, ys)

    table = pd.DataFrame(
        {"PPO": perf_metrics(res["equity"]), "Buy&Hold": perf_metrics(bh)}
    ).T
    table["avg_daily_turnover"] = [res["turnover"].mean(), 0.0]
    table["avg_exposure"] = [res["weight"].mean(), 1.0]
    print(f"\n=== {args.split.upper()} ({span[0]} to {span[1]}) ===")
    print(table.round(3).to_string())

    rm, rs = random_baseline(Xs, ys)
    print(f"\nRandom policy final equity: {rm:.3f} +/- {rs:.3f} (mean +/- std over 20 runs)")

    Path("reports").mkdir(exist_ok=True)
    fig, ax = plt.subplots(2, 1, figsize=(10, 7), sharex=True, gridspec_kw={"height_ratios": [3, 1]})
    ax[0].plot(res.index, res["equity"], label="PPO")
    ax[0].plot(bh.index, bh.values, label="Buy & Hold", alpha=0.7)
    ax[0].set_title(f"{C.TICKER} {args.split}: growth of 1.0")
    ax[0].legend()
    ax[1].fill_between(res.index, res["weight"], step="post", alpha=0.5)
    ax[1].set_ylabel("target exposure")
    ax[1].set_ylim(-0.05, 1.05)
    fig.tight_layout()
    out = f"reports/{args.tag}_{args.split}.png"
    fig.savefig(out, dpi=130)
    print(f"saved {out}")


if __name__ == "__main__":
    main()
```

```bash
python evaluate.py --model models/ppo_v1/best/best_model.zip --split val
python evaluate.py --model models/ppo_v1/best/best_model.zip --split test   # once, at the very end
```

### 8.4 How to read the results

- **Always compare with buy-and-hold** on the same period. Beating zero is meaningless in a rising market.
- Compare **risk-adjusted** numbers (Sharpe, max drawdown, Calmar), not only total return. An agent that holds 50% cash and returns half as much with a third of the drawdown may be genuinely better.
- Look at **turnover and exposure**. An agent whose average exposure is 0.98 is buy-and-hold in disguise. An agent with average daily turnover of 0.3 is likely trading noise, and a bigger cost assumption will break it.
- Check the **random baseline spread**. If PPO's edge is within the random policy's standard deviation, you have no evidence of skill.
- The test set is single-use. If you retrain after seeing test results, it becomes a second validation set.

---

## 9. Hyperparameter tuning and multi-seed runs

### 9.1 Why multiple seeds are non-negotiable

RL on noisy financial data has huge seed variance. One good run is an anecdote. Train **at least 5 seeds** per configuration and report the **median and interquartile range** of validation Sharpe.

```bash
for s in 0 1 2 3 4; do
  python train.py --steps 1000000 --seed $s --run-name ppo_v1_seed$s
done
```

### 9.2 Optuna search

```python
# file: tune.py
import argparse

import numpy as np
import optuna
import torch.nn as nn
from stable_baselines3 import PPO
from stable_baselines3.common.vec_env import DummyVecEnv

import config as C
from src.backtest import run_episode
from src.data import load_prices, make_features, split_by_date
from src.metrics import perf_metrics
from train import make_env_fn


def build_objective(Xtr, ytr, Xva, yva, steps: int, seeds: int):
    def objective(trial: optuna.Trial) -> float:
        params = dict(
            learning_rate=trial.suggest_float("learning_rate", 1e-5, 1e-3, log=True),
            n_steps=trial.suggest_categorical("n_steps", [256, 512, 1024, 2048]),
            gamma=trial.suggest_float("gamma", 0.9, 0.999),
            ent_coef=trial.suggest_float("ent_coef", 1e-6, 5e-2, log=True),
            clip_range=trial.suggest_categorical("clip_range", [0.1, 0.2, 0.3]),
            n_epochs=trial.suggest_categorical("n_epochs", [3, 5, 10]),
        )
        width = trial.suggest_categorical("width", [64, 128, 256])

        scores = []
        for seed in range(seeds):
            env = DummyVecEnv([make_env_fn(Xtr, ytr, episode_len=C.EPISODE_LEN, random_start=True)])
            model = PPO(
                "MlpPolicy", env, batch_size=64, seed=seed, device="cpu", verbose=0,
                policy_kwargs=dict(net_arch=dict(pi=[width, width], vf=[width, width]),
                                   activation_fn=nn.Tanh),
                **params,
            )
            model.learn(total_timesteps=steps)
            res = run_episode(model, Xva, yva)
            scores.append(perf_metrics(res["equity"])["sharpe"])
            trial.report(float(np.mean(scores)), step=seed)
            if trial.should_prune():
                raise optuna.TrialPruned()
        return float(np.mean(scores))

    return objective


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--trials", type=int, default=30)
    p.add_argument("--steps", type=int, default=200_000)
    p.add_argument("--seeds", type=int, default=3)
    args = p.parse_args()

    X, y = make_features(load_prices(C.TICKER, C.TRAIN[0], C.TEST[1]))
    Xtr, ytr = split_by_date(X, y, *C.TRAIN)
    Xva, yva = split_by_date(X, y, *C.VAL)

    study = optuna.create_study(
        direction="maximize",
        sampler=optuna.samplers.TPESampler(seed=0),
        pruner=optuna.pruners.MedianPruner(n_startup_trials=5),
    )
    study.optimize(build_objective(Xtr, ytr, Xva, yva, args.steps, args.seeds), n_trials=args.trials)
    print("Best validation Sharpe:", study.best_value)
    print("Best params:", study.best_params)


if __name__ == "__main__":
    main()
```

**Tuning cautions.** Optimizing on one validation window overfits that window. For anything you take seriously, use several validation folds (see walk-forward in section 11). Treat a tuned configuration as a hypothesis and confirm it on data the search never saw.

---

## 10. Failure modes and diagnostics

| Symptom | Likely cause | What to try |
|---|---|---|
| Agent is **always fully invested** | Bull-market training data, so buy-and-hold is the best policy it can find | Add bear periods, compare to buy-and-hold honestly, consider a risk-adjusted reward |
| Agent is **always in cash** | Costs dominate expected edge, or the entropy bonus is too low | Check `cost_bps`, raise `ent_coef`, verify the reward sign with the unit tests |
| Position **flips every day** | Costs too low or no turnover pressure | Raise `cost_bps`, add a turnover penalty, or let the action be a *change* in exposure |
| Great training reward, poor validation | Overfitting to noise | Smaller network, `n_epochs` 3-5, more tickers or more history, early stopping on validation, fewer features |
| Validation great, **test poor** | Validation was used for selection and tuning | Expected to some degree. Use walk-forward and multiple seeds. |
| Results change wildly between seeds | Normal for RL on noisy data | 5+ seeds, report median and IQR |
| Implausibly good results | **Leakage** | Re-check the `shift(-1)` label, rolling z-score windows, and that features at *t* use only data `<= t` |
| `explained_variance` stuck negative | Value function cannot fit | Check reward scale and `VecNormalize` reward normalization, lower the learning rate |
| `approx_kl` spikes, reward collapses | Updates too large | Lower `learning_rate`, `clip_range` 0.1, increase `batch_size` |

### Two cheap leakage tests

1. **Shuffled-label test.** Randomly permute `fwd_ret` within the training set (`y_train = y_train.sample(frac=1, random_state=0).values`), retrain, and evaluate on validation. Performance should look like the random baseline. If it does not, something other than the real signal is driving it.
2. **Future-poke test.** Multiply `fwd_ret` after row *t* by 10 and confirm that the observation at row *t* does not change. If it does, future information leaks into your features.

---

## 11. Extensions roadmap

Add these one at a time, and re-run the full validation protocol after each.

**1. Multi-asset portfolio.** Change the action to a vector of `N+1` values (stocks plus cash), apply a softmax to get weights that sum to 1, and compute turnover as `sum(|w_new - w_old|)`. Reward becomes the log of the weighted return minus costs.

```python
# inside step(), multi-asset sketch
z = np.asarray(action, dtype=np.float64)
w_target = np.exp(z - z.max()); w_target /= w_target.sum()      # softmax: stocks + cash
turnover = np.abs(w_target - self.w).sum()
port_ret = (w_target[:-1] * self.fwd[self.t]).sum()              # fwd[t] has shape (N,)
growth = 1.0 + port_ret - self.cost_rate * turnover
```

**2. Shorting and leverage.** Set `allow_short=True` for exposure in `[-1, 1]`. Model borrow costs and margin before trusting short results.

**3. Discrete actions with masking (`MaskablePPO`).** Use `Discrete(3)` or `Discrete(5)` exposure levels and mask invalid actions (for example, "buy" when already at maximum exposure) with `sb3-contrib`:

```python
from sb3_contrib import MaskablePPO
from sb3_contrib.common.wrappers import ActionMasker

env = ActionMasker(env, lambda e: e.valid_action_mask())   # you implement valid_action_mask()
model = MaskablePPO("MlpPolicy", env, verbose=1)
```

**4. Recurrent policy (`RecurrentPPO`).** An LSTM carries memory across steps, so you can feed a single day's features instead of a flattened window.

```python
from sb3_contrib import RecurrentPPO
model = RecurrentPPO("MlpLstmPolicy", train_env, n_steps=256, batch_size=128, device="cpu")
```

**5. Custom feature extractor.** Reshape the observation to `(window, features)` and use a 1D-CNN or small Transformer via `policy_kwargs=dict(features_extractor_class=..., features_extractor_kwargs=...)` (subclass `BaseFeaturesExtractor`).

**6. Alternative rewards.**
   - *Drawdown-penalized:* `reward = log_growth - lambda * max(0, drawdown_now - drawdown_prev)`.
   - *Differential Sharpe ratio:* an online, per-step Sharpe update used in the RL-trading literature.
   - *Turnover-penalized:* subtract `kappa * |target - w_prev|` on top of the cost to encourage smoother positions.

**7. Walk-forward training.** Train on years 1-5 and validate on year 6, then train on years 2-6 and validate on year 7, and so on. Report the distribution of out-of-sample results across folds instead of one number.

**8. Realistic execution.** Trade at the *next open* instead of the close, add spread and slippage proportional to volatility, and apply liquidity limits.

**9. From sandbox to paper trading.** Only after the agent is stable across seeds and folds: load the model, rebuild features from the latest bars using *the exact same* `make_features` code, call `model.predict(obs, deterministic=True)`, convert the target exposure into an order against a **paper-trading** account, and log everything. Compare live paper results with what the backtest would have done on the same days. Any gap is a pipeline bug until proven otherwise.

---

## 12. Checklist

**Data**
- [ ] Adjusted prices; no missing-day gaps you did not intend
- [ ] Features at row *t* use only data `<= t`
- [ ] Normalization is causal (rolling or train-only)
- [ ] Train, validation and test split chronologically

**Environment**
- [ ] Unit tests pass (flat equals 1.0, always-long equals buy-and-hold when free)
- [ ] `check_env` passes
- [ ] Costs included; position is part of the observation
- [ ] Random agent does not make money

**Training**
- [ ] `device="cpu"`, seeds set, versions pinned
- [ ] Validation environment tracked with `EvalCallback`
- [ ] TensorBoard checked: entropy, KL, clip fraction, validation reward

**Evaluation**
- [ ] Compared with buy-and-hold and the random baseline
- [ ] Sharpe, max drawdown, turnover and exposure reported
- [ ] 5+ seeds, median and IQR
- [ ] Shuffled-label test run
- [ ] Test set evaluated once

---

## 13. Further reading

- Stable-Baselines3 docs: https://stable-baselines3.readthedocs.io
- SB3-Contrib (MaskablePPO, RecurrentPPO): https://sb3-contrib.readthedocs.io
- Gymnasium docs (custom environments): https://gymnasium.farama.org
- PPO paper: Schulman et al., *Proximal Policy Optimization Algorithms* (2017)
- Optuna: https://optuna.org
