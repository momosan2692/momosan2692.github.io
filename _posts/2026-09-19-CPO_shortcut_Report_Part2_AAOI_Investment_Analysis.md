---
layout: post
title: 1.6T Thesis Valuation Review and Risk Framework
subtitle: Company Review AAOI
cover-img: /assets/img/header/2026-04-18/QUANTUM.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-18/QUANTUM.png
published: true
pinned: true
mathjax: true
tags: [draft, CPO]
---

# Applied Optoelectronics (AAOI): 1.6T Thesis, Valuation Review and Risk Framework
## Report Part 2 of 2 — Company & Investment Analysis

*Compiled 19 September 2026 from the raw research notes in `2026-09-19-CPO_shortcut.md`, plus my own arithmetic checks of the DCF and price-level figures. Company data and forecasts come from secondary sources and AI-generated summaries in the notes and are unverified. This is information for your own decision-making, not investment advice; I am not a financial advisor.*

> **Update, 19 Sep 2026 — please read the Addendum.** After verifying against company filings and the Q2 call, several figures in this report (taken from the raw notes) are superseded: shares are about 92.8M (not 81.6M); the balance sheet is net cash before convertibles (not US$500m net debt); AAOI also manufactures in Taiwan and Ningbo, China; management ties the 1.6T ramp to DSP/TIA supply, so the order is probably **not** an LPO product; and management's capex guidance implies deeply negative free cash flow through 2027. A rebuilt valuation gives roughly US$29 (base) to US$72 (bull) on a perpetuity method, or US$52-117 on a 16x exit multiple, versus the notes' US$98-148. See `CPO_shortcut_Addendum_AAOI_Unit_Economics_and_Order_Check.md`.

---

## Executive Summary

1. **The thesis.** AAOI is a US-manufactured, vertically integrated (in-house InP lasers) 1.6T module maker with a first volume order above US$200m from a hyperscaler, aggressive Texas capacity expansion, and a demonstrated 1.6T OSFP DR8 LPO module. The bull case is that LPO simplifies manufacturing, avoids DSP supply constraints, and that US origin earns extra share as buyers tighten origin audits.
2. **What is solid.** The order, the capacity plan, the in-house laser capability and the management revenue path (Q4 2026 next-gen revenue about US$330m, of which 1.6T US$70–80m) are consistently reported across the notes.
3. **What is not yet proven.** (a) That the US$200m order is LPO rather than DSP-based; (b) that a US-based plant can match SE Asian unit cost at volume; (c) that free cash flow turns strongly positive in 2027 after very heavy capex; (d) that the customer concentration and dilution history do not bite again.
4. **Valuation.** The notes' DCF gives US$98.31 (base) and US$147.83 (bull). I re-ran the arithmetic and it is correct **for the inputs given**, but the base case lands almost exactly on the market price, about 76% of value sits in the terminal value, and the result swings from about US$70 to US$172 with modest changes in discount rate and cash flows. It is a scenario tool, not a price target.
5. **Risk levels.** The US$89.40 stop level and US$124.81 add level are built from formulas whose coefficients are unexplained, and the "asset-backed support" justification for US$94 contradicts the notes' own description of US$94 as a technical support level. They are usable as personal reference lines only after you decide your own rules.

---

## 1. Company Snapshot (from the notes)

| Item | Detail |
|---|---|
| Business | Optical transceivers and lasers for data centre, CATV and telecom; data centre now dominant |
| Vertical integration | Manufactures InP high-power lasers and light engines in-house |
| Manufacturing | Sugar Land and Pearland, Texas; two Pearland facilities adding nearly 400,000 sq ft of automated space; wider Houston-area footprint referenced at about 900,000 sq ft |
| Products | 800G and 1.6T transceivers; 1.6T OSFP DR8 LPO demonstrated at ECOC 2024; 3.2T and External Light Source (CPO) in development |
| Capacity plan (800G + 1.6T combined, monthly) | About 200,000 (mid-2026) → over 650,000 (end-2026) → 930,000+ (late 2027) |
| Laser capacity | Management targets a 350% increase in US laser output by end-2027 |
| Share count | About 81.6 million (notes' figure, after ATM issuance) |
| Price and market cap | About US$98 (98.06–98.15 in different places); market cap 81.6M × 98.06 ≈ **US$8.0bn**, versus US$8.3bn quoted in one line |
| Volatility | Beta cited between 2.64 and 2.95 |

---

## 2. Financial Timeline

| Period | 1.6T revenue | Context |
|---|---|---|
| H1 2026 | Zero | 800G ramp; Q2 800G revenue about US$12.8m (over 2× quarter on quarter) |
| Q3 2026 | Small, first shipments (Aug–Sep) | Guidance for total revenue US$255–290m, dominated by 800G volume |
| Q4 2026 | US$70–80m | 800G + 1.6T revenue about US$330m; 1.6T annualised run rate about US$300m |
| Full-year 2026 | About US$80–90m (1.6T) | Company target of US$1.0–1.1bn total revenue |
| Q1 2027 | Around US$150m+ (doubling) | Management-implied; implies about US$600m annualised |

**Order and constraint.** Management says orders are visible into mid-2027 and that output, not demand, limits 2026 revenue.

**Consistency checks I ran on the notes.**
- Q4 1.6T of US$70–80m minus full-year 1.6T of US$80–90m implies Q3 1.6T of only about US$10m: consistent with "first shipments".
- The base-case revenue for 2027 is described as "over US$1.8bn" in one place, while a code comment mentions "could top US$2.5bn if capacity is fully utilised". The DCF uses cash-flow figures, not revenue; the notes never show the bridge from revenue to FCF.
- Q2 capex is quoted at about US$565m for the single quarter, a figure large relative to the FY revenue target; it includes machinery prepayments. Any DCF that starts in 2027 depends on this spending stopping or falling sharply.

---

## 3. The Investment Thesis in Detail

### 3.1 Technology: the LPO "shortcut"
The argument in the notes: LPO removes the DSP, so (a) the module has fewer parts and an easier automated assembly and test flow, (b) AAOI is not dependent on Broadcom or Marvell DSP allocation, and (c) power is lower, which matters for power-constrained hyperscalers. Signal-recovery capability moves into the host SerDes.

**Strengths of the argument**
- Consistent with the industry direction described in Part 1.
- AAOI showed an early LPO demonstrator.
- Removing the DSP eliminates a supply chokepoint and a bill-of-materials line.

**Weaknesses and open questions**
- The order's module type is not documented in the notes. If it is DSP-based, the "LPO shortcut" is a longer-term option rather than the source of current revenue.
- LPO requires link-level tuning with a specific host. That favours a small number of large, closed deployments and creates dependence on one or two customers.
- CPO could overtake pluggable LPO in scale-up within a few years (Part 1, Section 5).
- Simplified assembly does not remove the laser bottleneck; it shifts the weight to laser yield.
- AAOI's own claim of lowering labour intensity has to be measured against Thai, Malaysian and Vietnamese labour costs at InnoLight-scale volumes.

### 3.2 Geopolitical positioning
US manufacturing and in-house lasers make AAOI's origin easy to certify. That is a genuine advantage in a market where hyperscalers audit SE Asian plants. The notes may overstate the effect: total demand is set by AI capex, while origin rules mostly shift marginal share. Hyperscalers also prize volume and dual sourcing, which favours very large suppliers.

### 3.3 Position against US peers (US-based 1.6T footprint)

| Company | US base | 1.6T end-module US capacity | In-house InP | Comment |
|---|---|---|---|---|
| AAOI | Texas | Large and growing, planned as core volume site | Yes | Purest US-made module story; small company |
| Coherent | Texas (Sherman), 20+ US sites | Wafer capacity very large; some module packaging via Thailand partners | Yes, industry-leading | Stronger and more diversified; could re-shore packaging if asked |
| Lumentum | California | Small; volume in Japan and Thailand | Yes | Laser and OCS specialist |

The notes correctly conclude that Coherent is technically deeper while AAOI has the "purer" US module capacity. Coherent has said it could move packaging back to the US if customers require it, which limits how long AAOI's edge lasts.

---

## 4. Valuation Review

### 4.1 Replication of the notes' DCF

Inputs used in the notes: WACC 11%, terminal growth 3%, net debt US$500m, 81.6m shares, five annual FCF values for 2027–2031.

| Case | FCF 2027–31 (US$m) | Enterprise value | Equity value per share |
|---|---|---|---|
| Base | 250, 450, 600, 750, 850 | US$8.52bn | **US$98.31** |
| Bull | 400, 650, 900, 1,100, 1,250 | US$12.56bn | **US$147.83** |

The arithmetic reproduces exactly. The problem is the inputs.

### 4.2 What the DCF tells you
- **The base case equals the market price.** A base case that lands within a few cents of the share price is a sign of calibration, not independent confirmation. It says "if you believe FCF ramps to about US$850m by 2031, today's price is about fair".
- **Terminal value carries about 76% of base-case enterprise value.** Only about US$2.0bn of the US$8.5bn comes from the explicit 2027–2031 cash flows.
- **Net debt and discounting:** the model uses a single mid-2026-style net debt of US$500m and ignores further equity dilution, additional capex and working-capital needs during the ramp.
- **Timing:** it discounts 2027 FCF a full year and does not model the 2026 cash burn.

### 4.3 Sensitivity (my calculation, 81.6m shares, US$500m net debt)

| WACC | Terminal g | Base value/share | Bull value/share |
|---|---|---|---|
| 10% | 3% | US$114.7 | US$171.9 |
| 10% | 2% | US$102.0 | US$153.2 |
| 11% | 3% | US$98.3 | US$147.8 |
| 11% | 2% | US$88.8 | US$133.8 |
| 13% | 3% | US$75.5 | US$114.3 |
| 13% | 2% | US$69.7 | US$105.8 |

A one-percentage-point change in discount rate moves the base value by roughly 15–20%.

Two operating sensitivities I added:
- **Delayed ramp:** if base-case FCF is 0, 200, 400, 600, 700 (a one-year slip), value falls to about **US$75**.
- **More dilution:** at 100m shares instead of 81.6m (another wave of ATM issuance), the base value falls to about **US$80**.

### 4.4 Assessment
Treat the two DCF values as a plausible range under stated assumptions, not as a target. The gap between "already priced in" and "50% upside" rests on whether FCF reaches US$400m in 2027 versus US$250m, a difference the notes do not derive from unit volumes, average selling price, gross margin or capex.

### 4.5 A better way to build the FCF bridge (suggested next step)
1. Units shipped per month × average selling price for 800G and 1.6T (the notes float US$600–800 for 1.6T without a source).
2. Gross margin path (the notes cite management aiming at 35–40%, and mention "expedite fees" depressing Q3 margin).
3. Operating expense and stock compensation.
4. Capex split into growth versus maintenance, and the timing of the Pearland completion.
5. Working capital growth (receivables and inventory rise rapidly in a ramp).
6. Share count path under ATM usage.

---

## 5. Peer Comparison: AAOI vs Corning (GLW)

| Dimension | AAOI | GLW |
|---|---|---|
| Price (Sep 2026) | About US$98 | About US$147.80 |
| Revenue scale | About US$1.0–1.1bn (2026) | About US$16.3–16.9bn |
| WACC used | 11% | 7.8% |
| Terminal growth used | 3.0% | 2.5% |
| Base DCF | US$98.31 | US$115.85 (about 22% below price) |
| Bull DCF | US$147.83 (about 50% above price) | US$201 (about 36% above price) |
| Valuation multiples | Growth-priced, FCF negative in 2026 | P/E about 67×, P/FCF about 52× |
| Character | High beta, high operating leverage, dilution history | Broad materials moat, lower volatility |

**Reading it.** The two models are not comparable in quality: they use different discount rates, different growth assumptions and hand-picked scenarios for each. GLW's exposure is mostly indirect (fibre, glass substrates, HAMR platters), while AAOI's is a direct bet on a single product ramp. The two cover different risks, and neither DCF should be used to rank them against each other.

**Largan (3008)** is a CPO component name whose material revenue is expected in 2027–2028, with a UBS Sell rating recorded in the notes on valuation. It has a different currency, market and time horizon from AAOI.

---

## 6. Risk Levels: Review of the Notes' Price Framework

### 6.1 The notes' levels

| Input | Value in notes |
|---|---|
| Last close | US$98.15 |
| 20-day MA | US$107.11 |
| "20-day volatility" | US$8.85 |
| 14-day resistance | US$116.90 |
| 14-day support | US$94.00 |
| Add-on trigger | US$124.81 (formula gives 124.60) |
| Stop / risk trigger | US$89.40 |

### 6.2 Verification
- **Add trigger:** 116.90 + 0.87 × 8.85 = **US$124.60**, not 124.81. The notes then move to 124.81 by "weighting the 20-day MA", with no calculation shown.
- **Stop trigger:** 94.00 − 0.52 × 8.85 = **US$89.40**. Arithmetic is right.

### 6.3 Weaknesses
1. **Unexplained coefficients.** The 0.87 and 0.52 are not derived from anything. The notes call 0.52 a Beta-based correction "for 2.95", but no formula connects them.
2. **Inconsistent justification for US$94.** In one place US$94 is a 14-day technical support. In another it is described as a liquidation or "asset-backed" floor derived from net debt and replacement cost of the Texas plant. Both cannot be true, and no asset-value calculation appears anywhere.
3. **"Volatility" is in dollars.** US$8.85 looks like a 20-day standard deviation of price, not an implied volatility. Calling it implied volatility is incorrect and matters if you compare it with options data.
4. **Claim of "exceeds 90% of normal noise"** for a 0.52-standard-deviation move below support is statistically wrong: a half-standard-deviation move is well inside ordinary daily noise for a stock with this volatility.
5. **Category error in the narrative.** The notes state that a break below US$89.40 "proves" the bull thesis failed (for example a yield problem or order cancellation). A price move does not identify its cause; it can equally reflect sector rotation, dilution announcements or index-level selling.
6. **The DCF fair value (US$98.31) and the "support" (US$94) are unrelated concepts.** The notes correctly say fair value is not a stop, but then blend them in the narrative.

### 6.4 A more defensible framework (for your own rules)

| Layer | Question to answer before setting a level |
|---|---|
| Position sizing | What percentage of the portfolio can AAOI represent given a beta near 3? A 30% drawdown in a week is within its history |
| Thesis stop | Which observable facts would falsify the thesis (e.g. Q4 1.6T revenue below the US$70m floor, capacity slip, customer order reduction), independent of price |
| Price stop | A level tied to your own loss tolerance, ideally using average true range (ATR) for the stock rather than a fixed dollar multiple |
| Adds | Only on facts (a second hyperscaler qualification, margin above target) not on a chart breakout alone |
| Trim | Consider partial profit-taking rules given how event-driven the stock is |

I have not re-derived a new set of numeric levels, because the right ones depend on your position size, holding period and risk tolerance, and I do not have those.

---

## 7. Risk Register

| Risk | Description | Severity | Evidence to watch |
|---|---|---|---|
| Execution / yield | New automated Texas lines fail to reach target yield; expedite fees persist | High | Gross margin path, commentary on Pearland equipment installation |
| Customer concentration | The 1.6T volume order comes from one hyperscaler | High | Second and third customer qualifications (Meta, Amazon cited as targets) |
| Dilution | ATM programmes have already lifted share count sharply | High | New ATM filings, share count in 10-Q, statement on ending ATM |
| Cash burn | About US$565m quarterly capex during the build-out | High | Operating cash flow versus capex, financing announcements |
| Technology path | CPO displacement, LPO limited to closed racks | Medium to high | NVIDIA Photonics timing, LPO interoperability news |
| Price competition | InnoLight/Eoptolink scale and SE Asia cost base | Medium | 1.6T ASP trend, gross margin |
| Geopolitics cuts both ways | Tariff or FCC relief for China-linked suppliers would erode AAOI's edge | Medium | Trade rulings, FCC rulemaking |
| Component supply | InP wafer, TIA/driver availability for LPO | Medium | Supplier commentary (MACOM, Semtech) |
| Valuation / volatility | Growth-priced stock with beta near 3 | High | Drawdowns after earnings; options-implied moves |
| Data quality | Analysis rests on unverified secondary sources | Medium | Verify against 10-Q, earnings call transcripts and press releases |

---

## 8. Monitoring Checklist Through Q4 2026 Results (expected early 2027)

1. **Q3 2026 results:** 1.6T revenue actually recognised; gross margin and expedite fee commentary; capex and cash balance; ATM usage.
2. **Order visibility:** any new 1.6T purchase orders or customer qualifications beyond the US$200m order; explicit statement on whether shipped modules are LPO or DSP-based.
3. **Capacity:** Pearland equipment move-in dates, monthly units against the 650k end-2026 target.
4. **Laser fab:** InP output and yield versus the 350% expansion goal.
5. **Industry:** InnoLight and Coherent 1.6T capacity announcements, NVIDIA CPO shipment timing, FCC and tariff developments, any Taiwan or SE Asia audit outcomes.
6. **Own-position discipline:** decide your thesis-based exits in writing before earnings.

---

## 9. Data-Quality Notes for This Part

- The notes contain price inputs that differ slightly (98.06, 98.15, "about 98"), a market cap that is inconsistent with the share count, and two revenue figures for 2027.
- Several passages assign specific mechanisms to unproven statements ("liquidation floor", "90% noise boundary", "major institutions defend at US$98"). Treat these as narrative, not analysis.
- The final sections of the notes increasingly echo your thesis and ask leading questions ("does this raise your confidence?"). That style is reassuring rather than critical, so I have tried to keep this report neutral and to test the claims.
- Original sources cited in the notes (company press releases, earnings transcripts, Seeking Alpha and Yahoo Finance pieces) should be checked directly before you rely on any single figure.

---

## 10. Bottom Line

AAOI has a credible, verifiable operating story: a real volume order, real capacity build-out and a differentiated origin position. The financial case, however, is a large bet on an execution ramp funded by heavy capex and share issuance, priced at a level where the notes' own base case says most good news is already reflected. The bull case needs three things at once: LPO adoption beyond one customer, cost-competitive US manufacturing, and FCF conversion that the notes assert but do not model. The most useful upgrades to the analysis are a unit-economics FCF bridge, verification of what product the US$200m order covers, and a risk framework based on your position size rather than on the borrowed coefficients in the notes.

---

*End of Part 2.*
