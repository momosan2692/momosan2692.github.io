---
layout: post
title: 1.6T Optical Networking
subtitle: Industry and Technology
cover-img: /assets/img/header/2026-04-18/QUANTUM.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-18/QUANTUM.png
published: true
pinned: true
mathjax: true
tags: [draft, CPO]
---


# 1.6T Optical Networking: Industry Structure, Architecture and Geopolitics
## Report Part 1 of 2 — Industry & Technology

*Compiled 19 September 2026 from the raw research notes in `2026-09-19-CPO_shortcut.md`. Company figures and forecasts come from that raw material (largely secondary sources and AI-generated summaries) and have not been independently verified. Where a claim looks weak or internally inconsistent, it is flagged in Section 9. Nothing here is investment advice.*

---

## Executive Summary

1. **Demand driver.** AI clusters have pushed network bandwidth from 400G/800G to **1.6T per port**. NVIDIA's Blackwell Ultra (B300) and Vera Rubin generations make 1.6T the baseline for high-end "AI factories" (ConnectX-9 SuperNIC at 1.6 Tbps; Quantum-X / Spectrum-X Photonics switches at 1.6 Tbps per port).
2. **Two networks, two optical philosophies.** *Scale-out* (InfiniBand/Ethernet, 30–500+ m) needs **DSP-based** pluggable modules that clean up and re-time the signal. *Scale-up* (NVLink, short reach, latency-critical) is moving towards **DSP-less** designs: **LPO** (linear pluggable optics), **NPO** and **CPO** (co-packaged optics).
3. **The "capability migration" thesis.** In DSP-less optics the signal-recovery work moves from the *cable/module* into the *host chip's SerDes*. The module becomes a near-pure electro-optical converter. Profit and complexity shift towards whoever owns the big chips (NVIDIA, Broadcom, Marvell, custom ASIC houses), while module makers compete on lasers, power, yield and manufacturing footprint.
4. **Supply is ranked, not flat.** InnoLight (Zhongji) and Coherent lead 1.6T volume; Eoptolink, Lumentum, Cisco/Acacia, AAOI and Foxconn follow. Fabrinet is the contract manufacturer behind several Western names. Upstream, the binding constraint is **InP laser capacity** (EMLs and CW sources), not just DSPs.
5. **Geopolitics is now a design input.** The raw notes describe a Taiwan "origin-washing" enforcement wave (PCB and optical-module cases), FCC scrutiny of China-linked modules, and look-through audits by US hyperscalers. "Where and by whom it was made" is becoming a pricing and qualification factor alongside speed and power.
6. **Adjacent chokepoints.** Beyond modules, **Largan (3008)** is positioned in CPO fibre-array/micro-prism components and **Corning (GLW)** in fibre and glass materials. Both sit on longer time horizons than pluggable 1.6T.

---

## 1. What 1.6T Is and Why It Matters

A 1.6T optical port is typically built from **8 lanes of 200G** (for example OSFP DR8, or 2×FR4 variants). Reaching 200G per lane requires a step-up in modulation, laser linearity, driver/TIA performance and SerDes design. Every layer of that stack has become a bottleneck at some point:

| Layer | Role in a 1.6T link | Typical bottleneck |
|---|---|---|
| Host ASIC / switch SerDes | Drives and receives the electrical lanes | Power, equalisation strength |
| Optical DSP (if present) | Re-times, equalises, applies FEC | Cost, power, supply concentration (Broadcom, Marvell) |
| Driver / TIA | Analog front end | Linearity at 200G/lane (MACOM, Semtech and others) |
| Laser (EML / CW) | Light source | InP capacity and yield (Lumentum, Coherent, AAOI in-house) |
| Silicon photonics / PIC | Modulation and routing on chip | Packaging and coupling loss |
| Module assembly and test | Final product | Automation, yield, test equipment (Keysight), labour cost |

The economic logic is simple. AI training and reasoning workloads (long chain-of-thought, agents, large KV-cache transfers, model-parallel communication) generate east-west traffic that grows faster than GPU count. Halving the number of links and switch tiers needed to connect a given GPU population lowers cabling, congestion and total power. That is why NVIDIA doubles per-port speed generation over generation.

---

## 2. Value-Chain Map

The raw notes group the ecosystem into four layers. The table adds the role each company plays.

| Layer | Companies named | What they do at 1.6T |
|---|---|---|
| **Module / transceiver** | InnoLight (Zhongji), Coherent, Eoptolink, AAOI | Design and ship the final OSFP/QSFP-DD modules. InnoLight is the volume leader; Coherent is vertically integrated (own lasers) |
| **Networking / subsystem** | Cisco (Silicon One G300/P200, Acacia), Lumentum | Cisco supplies 102.4T switch silicon natively speaking 1.6T OSFP; Lumentum supplies EML/CW lasers other module makers need |
| **Chipset / DSP / CPO** | Broadcom, Marvell, NVIDIA (plus MACOM for TIA/driver) | Broadcom and Marvell dominate optical DSPs and 100G/200G SerDes; NVIDIA sets the roadmap by integrating 1.6T ports into its platforms |
| **Manufacturing and test** | Fabrinet, Keysight | Fabrinet ("the TSMC of optical communications") builds for Lumentum, Cisco and others; Keysight dominates high-speed validation |

Additional names from NVIDIA's ecosystem in the notes: **TSMC** (COUPE 3D photonic packaging), **Foxconn** (module manufacturing), **Coherent and Lumentum** (InP lasers), **MACOM** (TIA/drivers).

**Market-share claim (unverified).** One source quoted in the notes says NVIDIA-driven demand could account for over 60% of global 1.6T module shipments. Treat this as a demand-side estimate from a single research house, not a settled number. Another passage puts InnoLight's share of 1.6T at roughly 50–70% and of the overall optical-module market at roughly 27–35%.

---

## 3. NVIDIA's 1.6T Plan

### 3.1 Hardware anchors
- **Quantum-X Photonics / Spectrum-X Photonics**: CPO-based switch platforms, 1.6 Tbps per port; NVIDIA claims about 3.5× lower energy for the network.
- **ConnectX-9 SuperNIC**: 1.6 Tbps per NIC, aimed at million-GPU clusters.
- **HGX B300 (Blackwell Ultra)** clusters use 1.6T networking as standard; **Vera Rubin** and later platforms extend it, with **CPO in scale-up** already on the public roadmap (Feynman is mentioned in the notes).

### 3.2 Why NVIDIA pushes so hard
Inference and reasoning models move far more data between GPUs than earlier training patterns did. Where 400G/800G sufficed for H100-class clusters, KV-cache movement and model-parallel operations make 1.6T the practical entry point for B300-class deployments.

---

## 4. Scale-up vs Scale-out: The Central Distinction

### 4.1 Definitions
- **Scale-up (NVLink domain):** GPUs behave like one giant accelerator with a shared memory pool. Inside a rack this is done over **copper backplane**. Once the domain spans multiple racks, copper runs out of reach and optics is required.
- **Scale-out (InfiniBand / RoCE Ethernet):** Connects independent nodes and racks across the data hall (tens to hundreds of metres) for data-parallel synchronisation, checkpointing and storage.

### 4.2 Comparison table

| Dimension | Scale-up (NVLink) | Scale-out (InfiniBand / Ethernet) |
|---|---|---|
| Role | "Chip extender": fuses memory pools | "Data mover": connects nodes at scale |
| Latency sensitivity | Extreme (sub-100 ns targets cited) | Throughput and reliability first (µs tolerated) |
| Reach | Under roughly 10–20 m | 30–500+ m |
| Optical architecture | LPO / NPO / CPO (no or minimal DSP) | DSP-based pluggable modules |
| Signal recovery done by | Host/switch SerDes | Module's DSP (retiming, FEC) |
| Where 1.6T appears | Between NVLink switches (GPU-to-switch inside the rack stays on copper) | NIC-to-switch and switch-to-switch |
| Key NVIDIA parts | NVLink Switch with 1.6T ports | ConnectX-9, Quantum-X, Spectrum-X |

### 4.3 Why DSP-less works in scale-up
Short reach means the channel is benign. If the host SerDes pre-emphasises well and the receiving SerDes equalises strongly, the module needs only linear amplification: a driver on transmit and a TIA on receive. Removing the DSP cuts power (figures of up to about 50% are claimed for LPO modules) and latency.

### 4.4 The price of DSP-less
1. **Interoperability loss.** A DSP module works in any compliant host. An LPO module must be tuned link-by-link to a specific host SerDes.
2. **Closed-ecosystem fit.** LPO suits uniform, tightly controlled environments (a single hyperscaler's own rack design) and is a poor fit for heterogeneous multi-vendor networks.
3. **Ecosystem burden moves to the chip vendor.** Host SerDes must be strong enough, which is why the notes treat SerDes strength as the crux.

---

## 5. Technology Options Compared

| Option | What it is | DSP in module? | Strengths | Weaknesses | Best fit |
|---|---|---|---|---|---|
| **DSP pluggable** | Conventional OSFP/QSFP-DD with re-timing DSP | Yes | Interoperable, long reach, mature | Power, cost, DSP supply concentrated in two vendors | Scale-out |
| **LPO** | Pluggable, linear direct-drive | No | Lower power and latency, simpler module | Host-dependent tuning, reach limits | Scale-up, closed racks |
| **NPO** | Optics placed near the ASIC on the board | Minimal | Shorter electrical path than LPO | New ecosystem | Transitional |
| **CPO** | Optical engine packaged with the switch ASIC | Minimal/none | Electrical path of millimetres, lowest power | Serviceability, thermal, supply-chain immaturity | NVIDIA Photonics switches, future scale-up |
| **External Laser Source (ELS)** | Laser kept in a pluggable, light fed to CPO | n/a | Laser serviceability | Extra coupling loss | CPO systems |

The raw notes mention that AAOI is developing 3.2T architectures and ELS for CPO in addition to its 1.6T LPO module. That is a hedge across the whole DSP-less spectrum.

---

## 6. Where Each Company Sits

| Company | Position at 1.6T | Notable points in the notes |
|---|---|---|
| **InnoLight (Zhongji)** | Volume leader | Thailand 1.6T capacity reportedly scaling 300k → 600k/month; Malaysia phase 1 adding about 330k/month; Vietnam site (US$700m) planned; Mexico line late 2026; annual capacity plan of 40M → 90M units in three years |
| **Coherent** | Vertically integrated leader | In-house InP lasers; 6-inch InP capacity being expanded; US footprint of 20+ facilities (Sherman, Texas cited); some packaging via Fabrinet Thailand |
| **Eoptolink** | High-volume challenger | Scaling 1.6T lines |
| **Lumentum** | Laser specialist | EML/CW supplier; 1.6T volume and wafer capacity mainly Japan and Thailand; smaller US module footprint; OCS switch expertise |
| **AAOI** | US-based challenger | 1.6T OSFP DR8 LPO demonstrator; over US$200m volume order; Texas capacity expansion; in-house InP lasers (covered in Part 2) |
| **Cisco / Acacia** | Systems and coherent | Silicon One G300/P200 at 102.4T |
| **Broadcom / Marvell** | DSP and SerDes suppliers | Broadcom also a CPO pioneer and, per the notes, Apple's custom-ASIC partner |
| **Fabrinet** | Contract manufacturer | Concentrated exposure to Thailand |
| **Keysight** | Test and validation | Near-monopoly claim in the notes |
| **MACOM / Semtech** | Analog front end | Drivers and TIAs that make LPO viable |

---

## 7. Geopolitics and Compliance

### 7.1 What the raw notes describe
- Taiwanese enforcement actions involving (a) a PCB maker accused of relabelling China-made boards as Taiwan-origin, and (b) an investigation, with customs, into China-based optical-module firms routing product through Taiwan.
- US scrutiny of high-end optical modules for security and supply-chain trustworthiness, including FCC measures on China-linked components.
- US hyperscalers moving to **look-through audits** of Southeast Asian factories, asking where chips, firmware and sub-assemblies originate.

### 7.2 Substantial transformation
The notes summarise the US test as either a **change of tariff heading** or roughly **35% value added** in the country of claimed origin. Merely labelling, packing or lightly assembling does not qualify. For Southeast Asian plants that import lasers, chips and sub-assemblies from China-linked parents, this test becomes the crux of tariff and audit exposure.

### 7.3 Impact by group

| Group | Effect | Reasoning |
|---|---|---|
| China-parented producers with SE Asia plants (InnoLight, Eoptolink) | Medium to high compliance cost | Upstream components still partly China-sourced; customers can escalate audits; one failed audit can remove a supplier from a US programme |
| Taiwanese module and packaging houses | Near-term friction, medium-term benefit | Longer paperwork and origin declarations; possible shift of orders to cleaner supply chains |
| US-manufacturing suppliers (AAOI, Coherent) | Relative beneficiaries | US-made product with in-house lasers is easier to certify |
| Southeast Asia contract manufacturers | Higher audit intensity | Fabrinet-type sites face more scrutiny of sub-assembly origin |

**Important nuance.** The compliance premium is real but not unlimited. Total 1.6T demand is set by AI capex; origin rules mainly reallocate share at the margin and lengthen qualification cycles. US suppliers still need to match price, yield and delivery, and hyperscalers also value dual-sourcing and volume, which favours the largest producers.

---

## 8. Adjacent Chokepoints: Largan and Corning

### 8.1 Largan (3008): CPO optical components
- **Products:** FA/FAU (fibre arrays and units) and PMLA (prism-integrated micro-lens arrays) that bend light 90° and couple it into silicon-photonics chips. Subsidiary reports cited in the notes claim coupling loss below 0.3 dB versus 0.5–1.0 dB for conventional approaches.
- **Ecosystem position:** Tied to the TSMC COUPE platform, with reported NVIDIA planning for 1.6T today and 3.2T/6.4T later.
- **Timeline:** FA mass-production spec sampled to a first US customer in July 2026; pilot line by end of Q3 2026; trial production and certification in Q4; volume expected 2027–2028.
- **Valuation caution:** The notes record a UBS downgrade to Sell in early September 2026 on the view that price already discounts 2028 earnings.

### 8.2 Corning (GLW): fibre and glass
- **Demand:** Multi-billion-dollar AI fibre supply agreements (Meta and Verizon cited).
- **Longer-dated themes:** glass substrates (TGV) for advanced packaging, glass carriers for CoWoS/FOPLP, and thin glass platters for HAMR hard drives.
- **Valuation snapshot in the notes:** about US$147.80 with a P/E cited near 67× and P/FCF near 52×; details in Part 2.

### 8.3 Timeline summary

| Horizon | Dominant story | Names |
|---|---|---|
| 2026–2027 | 800G to 1.6T pluggable ramp | InnoLight, Coherent, Eoptolink, AAOI, Lumentum |
| 2027–2028 | CPO components scale | Largan, TSMC COUPE, Broadcom, NVIDIA Photonics |
| 2027+ | Glass and packaging materials | Corning |

---

## 9. Data-Quality Review of the Raw Notes

The raw notes read as a chain of AI-assisted conversations with source lists. Several claims need caution before they are used in decisions.

1. **NVLink optics is asserted more firmly than the evidence shows.** The notes say 1.6T LPO/CPO in NVLink scale-up "is written into NVIDIA's roadmap" and that no DSP is needed. CPO on NVIDIA switches is publicly announced; large-scale LPO in NVLink is less clearly documented. The notes themselves qualify this: the system-level tuning cost and the closed-ecosystem restriction are significant.
2. **"AAOI's LPO won the $200M order."** The order is for 1.6T transceivers from a hyperscaler. The notes do not establish that those units are the LPO variant rather than DSP-based modules; the LPO link comes from AAOI's ECOC 2024 demonstration. **Update:** on the Q2 2026 call, management tied 1.6T delivery risk to DSP and TIA supply, which strongly suggests DSP-based modules (see the Addendum). This matters for the thesis in Part 2.
3. **The customer identity is speculation.** "Microsoft or Oracle" is a market guess, not a disclosure.
4. **"50% power reduction" and "sub-100 ns"** are vendor-level or research-house figures that depend on the comparison baseline.
5. **Consulting-style sentences with no primary source.** Statements such as "Broadcom cannot squeeze the supply chain at this layer" or "Keysight's near-monopoly" are interpretive.
6. **Inconsistent tone.** Later sections of the notes drift into confirmatory language ("your view is highly accurate") that mirrors the user's thesis. Treat those passages as reinforcement, not evidence.
7. **Numbers repeated across sections do not always agree** (for example, several price-level inputs; see Part 2).

---

## 10. Key Uncertainties and What to Watch

| Question | Why it matters | Indicator |
|---|---|---|
| Does LPO reach volume outside a single customer's closed rack? | Determines whether DSP-less becomes a market or a niche | Multi-vendor interoperability announcements, second and third hyperscaler qualifications |
| How fast does CPO displace pluggables in scale-up? | Erodes pluggable LPO's window | NVIDIA Photonics shipment timing, TSMC COUPE ramp |
| Do look-through audits hurt China-parented SE Asia plants? | Reallocates share to US and Taiwan suppliers | Customer audit disclosures, FCC rulemaking, tariff rulings |
| Is InP laser capacity still the bottleneck? | Sets who can actually ship | Coherent and Lumentum wafer expansion, AAOI laser-fab ramp |
| Do hyperscaler custom ASICs (Apple Baltra, others) favour DSP-less optics? | Broadens the addressable market | ASIC SerDes specs, network-vendor selection |

---

## 11. Glossary

- **CPO:** Co-packaged optics; optical engines placed in the same package as the switch ASIC.
- **DSP:** Digital signal processor in a module that re-times and equalises the signal.
- **ELS:** External laser source that feeds CPO engines.
- **EML / CW:** Electro-absorption modulated laser / continuous-wave laser.
- **FEC:** Forward error correction.
- **InP:** Indium phosphide, the semiconductor for long-wavelength lasers.
- **LPO:** Linear pluggable optics; DSP-less pluggable module.
- **NPO:** Near-packaged optics.
- **OSFP / QSFP-DD:** High-speed pluggable form factors.
- **SerDes:** Serialiser/deserialiser, the high-speed I/O block of a chip.
- **TIA:** Trans-impedance amplifier on the receive side.

---

*End of Part 1. Part 2 covers Applied Optoelectronics (AAOI): thesis, financial timeline, valuation review, peer comparison and risk framework.*
