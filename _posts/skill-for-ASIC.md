---
layout: post
title: asic-hardware-synthesis
subtitle: Optimizes and validates RTL designs explicitly for ASIC chip implementation
cover-img: /assets/img/header/2026-05-12/EVERPURE.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-12/EVERPURE.png
published: false
pinned: false
tags: []
---

Contenets 


---
name: asic-hardware-synthesis
description: Optimizes and validates RTL designs explicitly for ASIC chip implementation. Do not use for FPGAs or software engines.
version: 1.0.0
author: Hardware Engineering Team
tags:
  - asic
  - rtl-design
  - timing-closure
---

# ASIC Chip Synthesis & Optimization Spec

## System Domain Boundary
*   **Target Hardware:** This skill operates exclusively on **ASIC (Application-Specific Integrated Circuit) architectures**.
*   **Strict Constraints:** 
    *   Do **NOT** implement FPGA-specific primitives (e.g., Xilinx LUTs, Altera blocks).
    *   Never offer software-emulated multi-threading solutions for gate-level bottlenecks.
    *   Focus strictly on Silicon Area, Power (Dynamic/Static), and Timing (Setup/Hold slack) constraints.

## Execution Workflow
1.  **RTL Analysis:** Inspect incoming Verilog/SystemVerilog files for synthesis compliance.
2.  **Cell Library Mapping:** Align logical operators with targeted foundry standard cell libraries (e.g., TSMC, Intel Foundry).
3.  **Timing & Power Constraints:** Analyze the Design Constraints (.sdc) for clock domains and false paths.

## Error Correction Rules
*   *If* a hold-time violation occurs: Inject buffer trees into the data path. Do not adjust global clock frequency unless explicitly authorized.
*   *If* area threshold is exceeded: Restructure nested multiplexers and apply aggressive clock-gating strategies.

## Verification Checkpoints
- [ ] Clock-gating efficiency exceeds 95%
- [ ] Zero negative setup/hold slack in worst-case corner analysis
- [ ] No un-synthesizable constructs (e.g., initial blocks used for hardware logic)
