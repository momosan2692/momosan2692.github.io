---
layout: post
title: NOT GPU, NOT TPU, but for MAC ROCE infra
subtitle: how to enlarge your VRAM in a AI local inference system 
cover-img: /assets/img/header/2026-03-04/DATACENTER.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-03-04/DATACENTER.jpeg
published: true    # ← add this, post won't show on blog
pinned: false # true — pin a post to the top
tags: []
mathjax: true
---

NOT GPU, NOT TPU, but for MAC ROCE infra. 

這是一份為你量身打造的 「AI 叢集部署架構白皮書」。這份文件總結了我們討論的硬體精算、平行運算策略，以及你從目前的 M1/M4 邁向未來 M5 RDMA 叢集的演進路線。
------------------------------
## 🚀 AI 分散式運算部署架構：從 Mac Mini 走向 M5 RDMA 叢集## 1. 現有硬體資源精算 (M1 + M4 Mini)
在開始部署前，必須了解 Unified Memory 的分配限制。macOS 系統通常會保留約 20% 的記憶體供系統使用。

| 設備 | 標配 RAM | 預估可用 VRAM (AI) | 記憶體頻寬 | 角色定位 |
|---|---|---|---|---|
| Mac Mini M4 | 16 GB | ~12.8 GB | 120 GB/s | Master (主控節點) |
| Mac Mini M1 | 8 GB | ~6.4 GB | 68 GB/s | Worker (運算節點) |
| 總計 (Cluster) | 24 GB | ~19.2 GB | 1GbE/Thunderbolt | 實驗性叢集 |

------------------------------
## 2. 平行運算方法論 (Parallelism Strategies)
針對不同硬體階段，建議採用不同的平行化方法：
## A. 流水線平行 (Pipeline Parallelism) — 當前最佳解

* 適用場景： M4 + M1 (網路頻寬受限，如 1GbE/10GbE)。
* 原理： 將模型的 Layers 按比例拆分。例如：M4 負責第 1-20 層，M1 負責第 21-32 層。
* 優點： 網路通訊頻率低，僅在層級交接時傳輸 Tensor。
* 工具： llama.cpp (RPC 模式)。

## B. 專家平行 (Expert Parallelism) — MoE 與 M5 的核心

* 適用場景： DeepSeek-V4-Flash 等 MoE 模型、未來 M5 RDMA 環境。
* 原理： 將不同的專家 (Experts) 分散在不同機器的記憶體中。
* 關鍵需求： RDMA (Remote Direct Memory Access)。
* 優點： 充分利用多機 VRAM 總量，同時保持 MoE 的極速推理特性。

------------------------------
## 3. DeepSeek 模型選擇建議 (基於 19.2GB VRAM)

| 模型名稱 | 參數結構 | 量化等級 | 預估空間 | 部署建議 |
|---|---|---|---|---|
| DeepSeek-V3-Distill-8B | Dense | Q8_0 | ~8.5 GB | 單機 M4 即可極速運行 |
| DeepSeek-V3-Distill-14B | Dense | Q4_K_M | ~10 GB | 推薦使用，邏輯與速度平衡 |
| Llama-3.1-70B | Dense | IQ2_XS | ~18 GB | M4+M1 串聯挑戰極限 |
| DeepSeek-V4-Flash | MoE | Q4_K_M | ~160 GB | 需等待 M5 叢集 (192GB+) |

------------------------------
## 4. 實戰部署指令 (llama.cpp RPC)## 第一步：在 M1 (Worker) 端啟動伺服器

# 進入 llama.cpp 目錄
./rpc-server -p 50052

## 第二步：在 M4 (Master) 端啟動推論

# 假設使用 Thunderbolt 直連，M1 IP 為 192.168.x.x
./main -m ./models/deepseek-v3-distill-14b-q4_k_m.gguf \
  --rpc 192.168.x.x:50052 \
  --n-gpu-layers 40 \
  --split-mode layer \
  -p "你好，請介紹一下分散式運算。"

------------------------------
## 5. 未來演進路線圖 (M5 RDMA Roadmap)

   1. Phase 1 (現在): 利用 M4 與 M1 熟練 llama.cpp 的 RPC 設定與層數分配。
   2. Phase 2 (M5 上市前夕): 關注 Thunderbolt 5 (120Gbps) 設備，這將是模擬 RDMA 的重要基礎設施。
   3. Phase 3 (M5 時代):
   * 部署 M5 Ultra/Max 叢集。
      * 切換至支援 RDMA 的後端（預計為升級後的 MLX 或專用驅動）。
      * 實現 DeepSeek-V4-Flash (Q4/Q8) 的完整地端部署。
   
------------------------------
## ⚠️ 注意事項

* 冷卻： 分散式推論時，M4 作為 Master 負載較高，請確保通風。
* 網路： 務必使用 Thunderbolt 線 直連兩台 Mac，Wi-Fi 會導致嚴重的推理卡頓。
* 量化損失： 記憶體不足時建議降低量化等級（如 Q2/IQ2），雖有損精度但能確保模型「跑得起來」。

------------------------------
這份文件可以作為你的 AI 實驗室建置手冊。如果有任何具體的錯誤訊息或編譯問題，隨時回來找我！
下一步： 你想先從 M4 上的 llama.cpp 環境編譯 開始動手嗎？

