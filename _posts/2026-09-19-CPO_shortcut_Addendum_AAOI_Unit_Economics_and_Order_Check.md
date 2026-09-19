---
layout: post
title: AAOI Addendum
subtitle: Valuations
cover-img: /assets/img/header/2026-04-18/QUANTUM.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-18/QUANTUM.png
published: true
pinned: true
mathjax: true
tags: [draft, CPO]
---


# AAOI Addendum: Order Verification, Unit-Economics Bridge and Rebuilt Valuation
## Follow-up to Reports Part 1 and Part 2

*Prepared 19 September 2026. This addendum replaces the unverified figures in the raw notes with company filings, the Q2 2026 press release and call transcript (6 August 2026), the March 2026 order press release, and September 2026 SEC 8-K filings. Everything in the "My assumptions" sections is my own modelling, not company guidance. Nothing here is investment advice; I am not a financial advisor.*

---

## 0. What Changed

I set out to (a) verify what the US$200m order covers, and (b) replace the notes' assumed FCF numbers with a bridge built from units, prices, margins and capex. Both exercises contradicted parts of the raw notes and of my earlier reports.

| # | Finding | Effect on the thesis |
|---|---|---|
| 1 | **Nothing I found says the 1.6T order is LPO.** The 9 March 2026 press release says only "1.6T data center transceivers". On the Q2 call, management repeatedly ties the 1.6T ramp to **DSP and TIA supply**. LPO modules have no DSP. | The "LPO shortcut" narrative is **not supported** for the current order. It looks like a DSP-based module ramp with the usual DSP bottleneck. |
| 2 | The notes' share count (81.6M) and net debt (US$500M) are wrong. Company guidance uses **about 92.8M diluted shares** (Q3), cash is **US$508.8M** against **US$92.8M** of non-convertible debt. | Per-share values in the notes' DCF were overstated by roughly 12% on shares alone. Net debt is a net cash position before convertibles. |
| 3 | AAOI is **not a pure US-made story**. It has manufacturing in Taipei and Ningbo, China, and signed a **10-year lease for a 38,312 m² factory in Ningbo on 10 September 2026**. Management says over half (not all) of end-2027 capacity will be in Texas. | The origin-compliance premium is real but smaller than the notes suggest. |
| 4 | **Free cash flow will be deeply negative through 2027**, not positive. Q2 capex alone was US$565.5m; management says capex stays elevated through 2027 and that second-half capex exceeds first-half. | The notes' "FCF +US$250m in 2027" is inconsistent with management's own capex statements. Financing needs are large. |
| 5 | Q2 "non-GAAP profitability" was **not operating profit**: non-GAAP operating loss was US$10.3M; the profit came from foreign tax benefits and subsidy income. | Profitability is thinner than the notes imply. |
| 6 | The notes' base case (US$98.31) landing on the market price was calibration. My rebuilt base case is far lower; the market price sits **between my base and bull cases** and depends on a high exit multiple. | Valuation is a bet on the bull path and on how the market prices AI hardware. |

---

## 1. Order Verification

### 1.1 What the primary sources confirm
- **Order:** "first volume order for 1.6T data center transceivers from a major hyperscale customer", "totaling more than US$200 million" (press release, 9 March 2026).
- **Customer:** a long-time customer whose revenue share the order is expected to lift back above 10%. The customer is **not named**. The raw notes' "Microsoft or Oracle" is speculation.
- **Timing:** shipments start late Q3 2026, bulk in Q4 2026, with a possible tail into Q1 2027 (CFO on the Q2 call).
- **Qualification status:** at the 6 August call, full qualification of the first 1.6T product was expected "within the next couple of weeks". **I found no confirmation of completion** in my searches. This is the most important pending fact.
- **Competitive position:** the CEO said AOI would be the **fourth supplier** qualified by this hyperscaler for 1.6T, so it is a follower here, not a first mover.
- **Order size context:** the CFO described the US$200m as "just the beginning", but also said the company is careful about taking more orders until capacity exists.

### 1.2 Is it LPO? The evidence
| Evidence | Points to |
|---|---|
| Press release and call describe "1.6T transceivers" without the word LPO | Not stated |
| CEO on Q4 delivery risk: material supply, and "working very closely with all the DSP and TIA suppliers" | DSP-based |
| CEO: the big challenge "is the DSP and TIA for 800G or 1.6T transceiver" | DSP-based |
| Investing.com summary of the call: lasers, DSPs and TIAs remain bottlenecks, "especially for 1.6 terabit products" | DSP-based |
| AAOI showed a 1.6T OSFP DR8 **LPO** demonstrator at ECOC 2024 | Capability exists, no volume evidence |
| Zero mentions of LPO in the Q2 prepared remarks or Q&A that I could read | Not a revenue driver yet |

**Conclusion.** The evidence strongly suggests the order is for conventional DSP-based modules. That is not conclusive: the transcript I read is AI-generated (Investing.com, editor-reviewed), and the modules could be a mix. The direct check is one question to investor relations, or the 10-Q: *"What share of 2026-2027 1.6T volume is LPO versus DSP-based?"*

### 1.3 Why it matters
- The notes' argument that AAOI "bypasses the DSP shortage" describes the LPO variant, not the product being shipped. Management itself lists DSP supply as a constraint on Q4 1.6T revenue ("we can commit maybe US$70-80m in Q4, because of material constraint").
- Management says its in-house lasers shield it from the laser shortage that affects rivals. That claim is supported; the DSP claim is not.
- Conversely, the CEO's argument that the industry has a **laser** bottleneck (300 mW CPO lasers, 21-24 month equipment lead times) is a better description of AAOI's real edge than the LPO story.

---

## 2. Corrected Data Sheet

| Item | Raw notes | Verified (source) |
|---|---|---|
| Q2 2026 revenue | (not stated clearly) | US$191.9m, +86% y/y, +27% q/q |
| Q2 mix | n/a | Data center 56% (US$107.7m), CATV 42% (US$80.6m), other 2% |
| Q2 800G revenue | US$12.8m | **US$12.8m confirmed**, 11.9% of data center revenue |
| Non-GAAP gross margin | 35-40% path | 29.8% in Q2; guide 29-30.5% in Q3; CEO expects **32-33%** exiting 2026; 40% is a long-term goal |
| Non-GAAP operating result Q2 | "returned to profitability" | Operating **loss** US$10.3m; net income US$5.5m from foreign tax benefits and subsidies |
| GAAP net loss Q2 | not mentioned | US$22.8m |
| Q3 guide | US$255-290m | Confirmed, but includes a US$20-25m hit from a 100G customer's switch shortage |
| FY2026 revenue | US$1.0-1.1bn | About US$1.1bn (reaffirmed) |
| Implied Q4 revenue | US$330m (800G+1.6T) | Consistent: ~US$330m for 800G+1.6T; total Q4 over US$500m per CEO; implied ~US$485m by my arithmetic |
| 1.6T revenue Q4 | US$70-80m | Confirmed; "more than US$70m" (CEO), constrained by materials |
| Q1 2027 1.6T | ~US$150m | CEO: "if it doubles I will not be surprised", a target, not guidance |
| Capacity (800G+1.6T, units/month) | 200k → 650k → 930k | Confirmed (about 200k now, over 650k end-2026, over 930k end-2027, over half from Texas) |
| Shares | 81.6M | **88.1M** weighted diluted in Q2; **~92.8M** Q3 guide |
| Cash | not given | **US$508.8m** (30 June) |
| Debt | "net debt US$500m" | **US$92.8m** ex-convertibles; convertible principal not verified (see 2.1) |
| Capex Q2 | US$565m | **US$565.5m**, including US$280m equipment prepayments |
| ATM | "two large ATMs" | New program; **US$538.8m net raised** to date; a US$600m program is referenced by a third-party summary |
| Customer concentration | "single hyperscaler" | Top 10 customers = **99%** of revenue; three >10% customers: one CATV (42%), two data center (26% and 24%) |
| Stock price | US$98.15 | US$98.61 on 17 Sep; roughly US$105 intraday on 18 Sep; 52-week range US$18.50-233.67 |
| Manufacturing | "pure US" | Texas plus Taipei and **Ningbo, China**; new 10-year Ningbo lease signed 10 Sep 2026 |

### 2.1 Items I could not verify
- **Convertible notes outstanding.** Older filings show 5.25% notes due 2026 that were largely exchanged into 2030 notes in December 2024. I do not have the current principal. My model uses **US$250m as a placeholder**. This is a reasonable range guess, not a fact. Check the Q2 10-Q balance sheet.
- **Q1 2026 capex.** I assume US$250m so that first-half capex is about US$816m.
- **Customer warrants.** Management says about 2.5% of revenue is contra-revenue tied to warrants issued to customers. That is another dilution source not in the notes.

---

## 3. Unit-Economics Bridge

### 3.1 The 2026 revenue walk (US$m)

| | Q1A | Q2A | Q3 (guide mid) | Q4 (implied) |
|---|---|---|---|---|
| Total revenue | 151.1 | 191.9 | 272.5 | ~485 |
| CATV | n/a | 80.6 | 100-110 (guide) | ~105-110 (my estimate) |
| 800G | n/a | 12.8 | ~64 (nearly 5x Q2) | ~255 (my derivation) |
| 1.6T | 0 | 0 | small | 70-80 |
| Other data center (100G/400G etc.) | n/a | ~89 | lower (100G -20-25) | balance |

FY2026 check: 151.1 + 191.9 + 272.5 + 484.5 = US$1,100m, matching management's "around US$1.1 billion". The Q4 figure is a residual, so the guidance is internally consistent only if Q4 is roughly US$485m, a **78% jump on Q3**. That single quarter carries the year.

### 3.2 Price and unit cross-checks
| Metric | Value | How derived |
|---|---|---|
| 1.6T implied ASP | **~US$650** (range US$600-700) | CEO: over 500,000 units/month = US$300-350m/month by end-2027 |
| 1.6T Q4 units | ~115,000 for the quarter (~38k/month) | US$75m / US$650 |
| 800G Q4 units | ~570,000 for the quarter (~190k/month) | US$255m / US$450 (**my assumed 800G ASP**, not disclosed) |
| Q4 average output vs year-end capacity | ~230k/month vs 650k/month | Output is well below the year-end capacity target, consistent with "material constraint" comments |

### 3.3 Management's mid-2027 monthly targets (a ceiling, not a forecast)
On the call, the CEO said that by mid-2027 monthly revenue would be about US$90m for 100G/400G, US$217m for 800G and US$164m for 1.6T, in total **about US$471m per month, or about US$5.6bn annualised**.

- 1.6T: US$164m/month at US$650 = ~250,000 units/month.
- Cross-check against capacity: 800G+1.6T at ~730,000 units/month is consistent with 650k rising to 930k.
- 800G+1.6T alone at US$381m/month is **about 3.5x Q4 2026's ~US$330m per quarter, reached within two quarters**.

**How to read it.** This is what full utilisation of announced capacity would produce if every unit is sold at current prices. It is roughly five times the 2026 total. It requires (a) equipment installed and yielding, (b) DSP, TIA and laser supply, (c) customers qualified and buying, and (d) no price erosion. I treat it as an upper bound. I also flag that I am relying on an AI-generated transcript for these monthly numbers; the 100G/400G figure (US$90m/month versus roughly US$30m/month currently) looks especially high and could be a transcription or phrasing error.

### 3.4 My 2027 scenarios (US$m)

| | Bear | Base | Bull |
|---|---|---|---|
| 2027 total revenue | 1,750 | 2,600 | 3,700 |
| Implied share of management's capacity-based path (800G+1.6T) | ~25% | ~45% | ~70% |
| Gross margin | 30% | 33% | 36% |
| Operating expenses | ~315 | ~340 | ~370 |
| Non-GAAP EBIT | 210 (12%) | 520 (20%) | 962 (26%) |

Check: Base 2,600 × 33% = 858 gross profit, less 340 opex = 518. Opex reflects management's US$70-80m per quarter today, rising with R&D.

**Why these margins.** Q2 was 29.8%. The CEO expects 32-33% at year-end, partly held back by expedite fees, and says 1.6T is the highest-margin product, lasers 55-65% and ELSFP over 50% from late 2027. Management's long-term target is about 40%. My bull case is roughly management's own targets; my base assumes only partial delivery. All figures are non-GAAP-style and exclude stock compensation; GAAP results are lower (Q2 GAAP gross margin 27.7%).

---

## 4. Capex and Funding Bridge

| Item | Value | Source |
|---|---|---|
| Q2 capex | US$565.5m (US$280m prepayments) | Company |
| H2 versus H1 | "Higher in the second half" | CFO |
| 2027 | "Continued elevated capital expenditures ... through 2027" | Company summary |
| Pearland expansion | ~US$300m, ~400,000 sq ft | Third-party summary; company 8-Ks show further leases and a US$26.8m Houston building purchase, plus purchase options of US$102m |
| Cash (30 June) | US$508.8m | Company |
| ATM headroom | About US$60m (US$600m program less US$538.8m net raised; gross versus net not reconciled) | Derived |
| Financing plan | "cash on hand, cash generated from operations, and some equity sales, along with additional debt" | CFO |

**My assumptions:** FY2026 capex US$1.7bn (Q1 assumed US$250m, Q2 US$565.5m, H2 about US$884m); 2027 capex US$1.1bn / 1.5bn / 1.9bn in bear / base / bull.

**Result (base case):**
- Free cash flow, H2 2026: about **-US$1.0bn** (capex plus a large working-capital build; inventory is already US$279m).
- Free cash flow, 2027: about **-US$1.1bn**.
- Cumulative through 2027: about **-US$2.1bn** versus US$509m of cash: an **external funding need of roughly US$1.6bn** (before any minimum cash buffer).
- If 2027 capex were only US$800m, the need would still be about US$0.9bn.
- At US$100 per share, US$1.6bn of equity is 16 million shares (about 17% dilution). New debt or convertibles would change the mix, not the burden.

This is the most decision-relevant gap between the notes and the filings. The notes' DCF starts cash flow in 2027 at +US$250m and never counts the funding of the build.

---

## 5. Valuation Rebuilt

### 5.1 Method
Unlevered free cash flow = non-GAAP EBIT less 18% tax, plus depreciation (from cumulative capex), less working capital (22% of revenue change) less capex. Valued at 30 June 2026 with 11% WACC. Terminal value uses 3% growth with reinvestment of g/ROIC (ROIC 15%), so free cash flow in perpetuity cannot exceed after-tax operating profit. Equity value = enterprise value minus net debt (US$92.8m debt plus US$250m placeholder convertibles less US$508.8m cash) divided by 92.8M shares.

### 5.2 Scenario paths (US$m)

| | 2026 | 2027 | 2028 | 2029 | 2030 | 2031 |
|---|---|---|---|---|---|---|
| **Bear** revenue | 1,100 | 1,750 | 2,100 | 2,300 | 2,400 | 2,500 |
| **Base** revenue | 1,100 | 2,600 | 3,400 | 3,900 | 4,300 | 4,600 |
| **Bull** revenue | 1,100 | 3,700 | 5,000 | 5,700 | 6,200 | 6,600 |
| Bear EBIT margin | | 12% | 11% | 10% | 10% | 10% |
| Base EBIT margin | | 20% | 19% | 18% | 17% | 16% |
| Bull EBIT margin | | 26% | 25% | 24% | 23% | 22% |
| Base capex | 1,700 | 1,500 | 800 | 600 | 550 | 550 |
| Base FCF | about -1,020 (H2) | -1,084 | 0 | 389 | 548 | 634 |

Margins decline over time in all cases to reflect ASP erosion and competition. That is my judgement; optical module prices normally fall each generation.

### 5.3 Results, US$ per share

| Method | Bear | Base | Bull |
|---|---|---|---|
| Perpetuity growth (11% WACC, 3% g) | 3 | **29** | 72 |
| Same at 10% WACC | 6 | 37 | 88 |
| Same at 13% WACC | -1 | 18 | 51 |
| Exit at 12x 2030 after-tax operating profit | 4 | 36 | 86 |
| Exit at 16x | 9 | 52 | 117 |
| Exit at 20x | 14 | 68 | 149 |
| Exit at 25x | 21 | 89 | 188 |

Weights of 25/50/25 give about **US$34** (perpetuity) or **US$58** (16x exit). Current price is about US$99-105.

### 5.4 Sensitivities (base case)
- 2027 capex US$0.8bn / 1.1bn / 1.5bn / 1.9bn / 2.2bn: US$33 / 32 / 29 / 27 / 25 per share. Capex matters less than margins.
- Terminal EBIT margin scaled to 60% / 70% / 80% / 90% / 100% of base: US$6 / 12 / 18 / 23 / 29. **Margin is the dominant variable.**
- Convertible principal US$0 / 250m / 500m: US$32 / 29 / 27.
- Extra 15M shares from new equity: about US$4 lower in the base case.

### 5.5 What you must believe at about US$99
- **Perpetuity method:** 2031 after-tax operating profit of about US$1.7bn (EBIT about US$2.1bn). That means roughly **US$9.5bn revenue at a 22% margin, or US$13bn at 16%**, versus US$1.1bn in 2026.
- **Exit method at 20x:** 2030 EBIT of about US$1.0bn, between my base (US$731m) and bull (US$1.43bn).

So the market price is consistent with either a high-growth path near the bull case, or a base-like path capitalised at a rich multiple. Both are plausible for an AI hardware name in this cycle; neither is a conservative assumption.

### 5.6 Reconciliation to the notes' DCF
Re-running the notes' own FCF paths (base 250/450/600/750/850; bull 400/650/900/1,100/1,250) with only the corrected inputs:

| Correction | Base | Bull |
|---|---|---|
| Notes as written (81.6M shares, US$500m net debt) | 98.3 | 147.8 |
| Correct share count (92.8M) | 86.4 | 130.0 |
| Also net cash of US$166m instead of US$500m net debt | 93.6 | 137.2 |
| Instead: US$1.0bn of unmodelled H2 2026 burn charged to the notes' case | 75.7 | 119.2 |

Structurally the notes' FCF paths are optimistic: their 2031 base FCF of US$850m exceeds my base 2031 after-tax operating profit of US$604m, and a growing company cannot sustain FCF above NOPAT in perpetuity unless capex stays below depreciation. It is also worth remembering that my scenarios carry their own assumptions; they are not more "correct" than the notes, only better tied to disclosed capex and share count.

### 5.7 Limits of this model
- Scenarios are illustrative, not forecasts. The revenue step from US$1.1bn to US$2.6bn (base) rests on a Q4 2026 exit rate that is itself unproven.
- The 11% WACC, 18% tax rate, 22% working capital intensity and 15% ROIC are judgement calls.
- Q1 2026 capex, FY2026 capex, convertible principal and the 800G ASP are my assumptions.
- The transcript is AI-generated; verify key numbers against the official transcript or filings.

---

## 6. Implications for the Original Thesis

| Thesis element | Status after verification |
|---|---|
| "1.6T LPO is the shortcut that bypasses the DSP" | **Unsupported for the current order.** Management describes DSP and TIA supply as a constraint. LPO remains a possible future product line, not a current revenue driver. |
| "Vertical integration in lasers gives a supply edge" | **Supported.** Management, the substrate-supply comments and the CPO laser plans (ELSFP ramp to about 400k/month in 2028, 300 mW class lasers) support it. It may prove more valuable than LPO. |
| "Pure US-made premium" | **Partly supported.** Texas will be over half of 2027 capacity, and management says a US ban on Chinese transceivers would help. But AAOI also manufactures in Taiwan and China and just leased a large Ningbo factory. |
| "FCF turns strongly positive in 2027" | **Contradicted** by management's capex commentary. Positive FCF looks more like 2028-2029 in my base case, and depends on capex normalising. |
| "Order visibility and demand" | **Supported.** Management says demand exceeds capacity through mid-2027 and capacity is booked into Q2 2027. |
| "Dilution is behind them" | **Not supported.** A new ATM program raised US$538.8m in about two months; further funding is expected. |
| "First-tier position" | **Mixed.** Fourth qualified supplier at one hyperscaler; two data center customers are 50% of revenue together; top-10 customers are 99%. |

None of this says the stock is a poor choice. It says the case rests on **execution and financing**, and on how much of a capacity ramp the market will pay for, rather than on a technology shortcut.

---

## 7. Updated Monitoring List

**Before the Q3 call (scheduled 5 November 2026):**
1. Confirmation that the first 1.6T product completed qualification, and shipments began in September.
2. 10-Q (Q2) balance sheet: convertible principal, warrant terms, and remaining ATM capacity.
3. Any new ATM, convertible or debt announcement.
4. Ask investor relations whether shipped 1.6T units are LPO or DSP-based.
5. Insider selling: a third-party summary reports roughly US$100m of net insider sales over 12 months; verify against Form 4 filings.

**On the Q3 call:**
6. Actual 1.6T revenue in Q3 (small) and the Q4 guide against US$70-80m.
7. Gross margin versus the 32-33% exit target, and expedite fee trends.
8. Capex for Q3 and the 2027 capex plan.
9. Capacity delivered versus the 650k/month year-end target; Sugar Land 210,000 sq ft site start, Pearland and Houston timing (early 2027).
10. Update on DSP, TIA and laser supply commitments.
11. Status of the Ningbo site: what will be made there.

**Trigger for re-rating the thesis:** a second 1.6T hyperscaler qualification, gross margin above 33%, and a financing plan that does not depend on new equity at lower prices.

---

## 8. Sources

- AOI press release, 9 March 2026, first volume order of 1.6T transceivers (company IR site, GlobeNewswire, Yahoo Finance).
- AOI Q2 2026 results press release, 6 August 2026 (company IR site, GlobeNewswire, Nasdaq).
- Q2 2026 earnings call transcript (Investing.com, AI-generated, editor-reviewed).
- Quartr Q2 2026 summary; Simply Wall St and Yahoo Finance summaries (secondary; used only for context and flagged where used).
- AOI SEC 8-K filings: Ningbo lease (10 September 2026), Houston property purchase (4 September 2026), Texas leases (May 2026).
- Price quotes from Benzinga and Robinhood pages (17-18 September 2026).

*The Python model behind Section 5 is provided as `aaoi_model.py` so every number can be re-run with different assumptions.*
