---
layout: post
title: 下一代推論引擎 Roadmap 附錄
subtitle: 長生命週期與 階層式cache與 多硬體並行
cover-img: /assets/img/header/2026-04-18/QUANTUM.png
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-04-18/QUANTUM.png
published: true
pinned: true
mathjax: true
tags: [draft, 推論引擎]
---


# 下一代推論引擎 Roadmap 附錄

更新日期：2026-10-11。本文補充[〈下一代推論引擎的重點與晶片對應〉](/2026/10/10/next-gen-inference-engine.html)，聚焦各專案公開的 roadmap、RFC、版本計畫與近期方向。

以下把「路線圖／計畫」和「已發布功能」分開描述。Roadmap issue 中的 target 通常不是供貨或 GA 承諾；版本說明則只能證明功能已發布，不能直接當成未來承諾。性能數字若來自專案或廠商自己的測試，也不等同獨立驗證。

## 1. vLLM：從通用引擎走向可組合的服務平台

### 核心引擎與開發流程

vLLM 的 [Q1 2026 roadmap](https://github.com/vllm-project/vllm/issues/32455) 和 [Q2 2026 roadmap](https://github.com/vllm-project/vllm/issues/39749) 將工作拆成 SIG 與明確的工程項目，而不只列模型支援。值得追蹤的方向包括：

- **Scheduler、KV Cache Manager 與分散式執行器**：持續把核心執行路徑模組化，改善大型服務的可維護性與可擴展性。
- **編譯與執行期**：整合 `torch.compile`、模組化 compiler 與自訂融合 pass；roadmap 也列出 vLLM IR 遷移、權重同步、KV cache reset 等工作。
- **可量測的效能回歸**：nightly 效能評估、儀表板與數值監控 harness，讓效能變更更容易被追蹤。
- **模型支援節奏**：roadmap 描述 day-0 驗證、week-1 基本效能、month-1 成熟化的支援目標；這是專案目標，不是每個模型的保證時程。

Roadmap 中出現的 compile-time 與 warm-compile 目標屬工程目標，不能解讀為已達到的產品 SLA。

### vLLM-Omni：長生命週期與即時多模態請求

[vLLM-Omni 的 world-model RFC／roadmap](https://github.com/vllm-project/vllm-omni/issues/7074) 把即時推論視為不同於一般 request/response 的執行模式：單一長生命週期請求、逐步執行與串流輸出、執行中互動，以及由 session 持有的狀態。文件也列出 realtime video API 與具體模型交付目標。

這代表 serving API 的演進可能不再只圍繞「送入 prompt、回傳 completion」，而要表示可中斷、可互動、帶狀態的多模態工作階段。該文件是 roadmap/RFC，列出的模型與 API 目標不應視為全部已 GA。

### Google TPU 成為 vLLM 的正式硬體方向

Google 與 Inferact 在 2026-09-14 公布工程合作，目標是讓 TPU 成為 vLLM 的一級目標，並把合作成果 upstream 到開源專案。合作公告把 prefill/decode disaggregation、speculative decoding、KV offload、structured output 與 tool calling 列為希望能在 TPU 上組合與驗證的生產功能。

這和舊的 JetStream 路線不同：[JetStream 專案首頁](https://github.com/AI-Hypercomputer/JetStream)表示核心功能已遷移至 [vLLM 的 tpu-inference 專案](https://github.com/vllm-project/tpu-inference)，並公告 JetStream 將於 2026-02-01 封存。因此，現在追蹤 Google TPU 開源推論進展時，應優先看 tpu-inference 與 vLLM，而不要把 JetStream 當成仍在活躍開發的獨立 roadmap。

Google Cloud 的 [vLLM on TPU 指南](https://docs.cloud.google.com/kubernetes-engine/docs/tutorials/serve-vllm-tpu)是部署與支援能力的證據；[合作公告](https://inferact.ai/news/google-tpu-partnership)則描述共同 roadmap。合作公告的目標不是已交付項目的清單，也沒有給出所有功能的完成日期。

## 2. SGLang：PD 分離、階層式 cache 與多硬體並行

[SGLang Q2 2026 roadmap](https://github.com/sgl-project/sglang/issues/22949)聚焦以下幾條主線：

- **可靠的 Prefill/Decode disaggregation**：擴大不同平行策略與部署方式的相容性。
- **Speculative decoding 與階層式 cache**：提高快取重用及負載平衡能力。
- **新硬體 kernel**：roadmap 涵蓋 NVIDIA、AMD、TPU 等平台，方向是讓引擎功能與效能不只依賴單一 GPU 世代。
- **RL 工作流整合與部署易用性**：把 serving engine 與強化學習工作負載、Kubernetes 等部署模式接起來。

專案的 [Rust server 遷移 RFC](https://github.com/sgl-project/sglang/issues/23206)則代表另一條 runtime 工程方向：把非 GPU 的 server 路徑逐步移至 Rust。Issue 中曾列出 2026-07-17 的里程碑日期；此日期是計畫紀錄，是否如期交付應以實際 release 為準。

SGLang roadmap 用「aim／plan」描述的項目應視為開發方向，而不是固定承諾。其 [官方文件](https://docs.sglang.ai/)與[版本紀錄](https://github.com/sgl-project/sglang/releases)可用來區分規劃項目和已釋出的功能。

## 3. AMD ROCm：把新 GPU 支援變成可重複驗證的引擎能力

AMD 相關工作分散在 vLLM、SGLang 與 ROCm kernel 專案，尚不宜簡化成一條單一的「AMD inference engine roadmap」。

- **vLLM ROCm roadmap**：[2026 Q3 roadmap issue](https://github.com/vllm-project/vllm/issues/44091)明確標示為 draft / work-in-progress，且列出的項目與日期可能改變。方向包括新模型 day-0 enablement、MI355X 上的 decode parity、ROCm backend 遷移至 vLLM V1、disaggregated serving 強化，以及公開的效能回歸 dashboard。
- **SGLang ROCm 工作**：[AMD Q3 roadmap issue](https://github.com/sgl-project/sglang/issues/35003)列出針對 NSA/DSA 模型的 FP8 attention kernel 優化與 MXFP4 KV cache 探索。這是 SGLang 中的 AMD 開發計畫，不代表所有項目已合併或支援所有模型。
- **共用 kernel 生態**：[ROCm AITER Q2 roadmap](https://github.com/ROCm/aiter/issues/3442)將 first-class vLLM、SGLang、ATOM backend，CDNA4（MI350/MI355X）支援，以及 CK、Triton、FlyDSL 等 kernel 路徑列為重點。

這些 roadmap 的共同訊號是：AMD 的推論競爭力不只取決於硬體峰值，而在於跨引擎 kernel、模型新架構支援、版本回歸測試與高並行 decode 的成熟度。具體 parity 目標屬專案內部追趕指標，不能直接解讀為已證明和其他平台同速。

## 4. NVIDIA：TensorRT-LLM 優化執行，Dynamo 管理叢集

### TensorRT-LLM

[Q3 2026 roadmap issue](https://github.com/NVIDIA/TensorRT-LLM/issues/15044)呈現出比單純 kernel tuning 更完整的 runtime 計畫：

- KV Cache Manager V2 與 KV Cache Transceiver V2。
- 更進階的 speculative decoding（包括 dflash 與動態 draft 長度）。
- MoE、MLA 與 FP4 attention 的 kernel 工作。
- ModelExpress 的 P2P 權重傳輸，以及較快重啟用途的 GPU Memory Service。
- 面向 prefill-only 工作負載的 `LLM.encode()`、embedding serving endpoint。
- Helix parallelism 相容性與可從線上流量擷取 trace 的 profiling endpoint。

這些項目若落地，TensorRT-LLM 的定位會涵蓋更完整的模型載入、快取生命週期、embedding 與線上診斷，而不僅是高效能 decode。以 [官方 release notes](https://nvidia.github.io/TensorRT-LLM/release-notes.html)確認實際交付狀態；roadmap issue 中的季度目標不是 GA 日期保證。

### NVIDIA Dynamo

Dynamo 的 [H1 2026 roadmap](https://github.com/ai-dynamo/dynamo/issues/5506)以五類問題組織開發：效能、生產級 serving 與擴展、router/KV caching、agents，以及 multimodality/diffusion。它補足單一引擎不負責的叢集層問題，例如跨 worker 路由、不同引擎協作與 KV 資源管理。

另外，[Dynamo 0.5.1／0.6.0 時程 issue](https://github.com/ai-dynamo/dynamo/issues/3323)列有 2026-10-08 與 2026-10-22 的目標日期，並提到可重現的 Kubernetes benchmark 與 observability 指標。前者在本文更新日之前、後者在之後；此處僅記錄 issue 上的計畫日期，不推定 0.5.1 已按期發布或 0.6.0 一定如期交付。實際功能應對照 [Dynamo releases](https://github.com/ai-dynamo/dynamo/releases)。

## 5. Google JetStream 與 Intel OpenVINO：注意「專案方向」不等於 roadmap

### Google JetStream 的轉向

JetStream 曾是面向 TPU/XLA 的推論服務引擎，但其 GitHub 首頁已公告核心功能遷移至 vLLM TPU inference 專案，並計畫封存 JetStream repo。加上 2026-09 的 Google–Inferact 合作，較可靠的追蹤方式是：

1. 看 [vllm-project/tpu-inference](https://github.com/vllm-project/tpu-inference)的程式碼、issue 與版本。
2. 看 Google Cloud 的部署文件，確認 TPU 上實際支援的模型與服務方式。
3. 把 Google–Inferact 公布的共同目標和已合併／發布的功能分開。

因此，本附錄不把 JetStream 描述成仍有獨立、活躍的季度 roadmap。

### Intel OpenVINO GenAI

本次找到的官方材料是 [OpenVINO release notes](https://docs.openvino.ai/releasenotes)，不是一份專門的 LLM serving roadmap。版本說明顯示 GenAI、多模態、模型支援與 runtime 部署仍在演進；但 release notes 反映的是已發布版本與相容性變動，不能據此推導未公布的 LLM 引擎功能或交付日期。若比較生產服務，還要分清 OpenVINO GenAI API、OpenVINO Model Server 與底層 runtime 的不同責任。

## 6. 跨專案路線圖的共通方向

| 方向 | 代表專案／公開訊號 | 對部署者的意義 |
|---|---|---|
| KV cache 生命週期成為一級功能 | vLLM、TensorRT-LLM、Dynamo、SGLang | 比較 cache 放置、傳輸、淘汰、遠端層級與故障行為，不能只看命中率。 |
| Prefill / decode 分離變成端到端系統問題 | vLLM、SGLang、Dynamo、TensorRT-LLM | 同時驗證 scheduler、KV 傳輸、router 與跨節點網路，而不是只量單一 kernel。 |
| 硬體支援朝共同 runtime 與 kernel 生態發展 | vLLM TPU、AMD ROCm/AITER、SGLang | 「支援某加速器」要拆成模型正確性、功能覆蓋、效能與維運成熟度。 |
| 即時多模態和 agent session 改變 API 形狀 | vLLM-Omni、Dynamo | 長生命週期、串流與中途互動需要獨立的排程、狀態管理與成本量測。 |
| 可觀測性與效能回歸逐漸產品化 | vLLM nightly dashboard、Dynamo Kubernetes benchmark | 要求相同 workload、SLO 與指標定義，並保留可重跑設定。 |

## 7. 看 roadmap 時的驗證清單

1. **辨認文件狀態**：是已合併 PR、release note、正式 RFC、roadmap issue，還是廠商公告？Draft 和 open issue 不等同承諾。
2. **把時程拆成事件**：預計開發、程式碼合併、release、GA、雲端區域可用是不同日期。
3. **追蹤整個 serving path**：除模型/kernel 外，也量 KV 搬移、router、scheduler、CPU/runtime、冷啟動與故障恢復。
4. **固定測試負載**：輸入與輸出長度、並行數、cache 命中率、硬體型號與軟體版本都需一致。
5. **分開報告廠商數字與獨立結果**：公開 benchmark 應保留可重現設定；沒有第三方驗證時，不要把宣傳數字寫成普遍效能。

## 來源

- [vLLM Q1 2026 Roadmap](https://github.com/vllm-project/vllm/issues/32455)
- [vLLM Q2 2026 Roadmap](https://github.com/vllm-project/vllm/issues/39749)
- [vLLM-Omni World Model Realtime Inference Roadmap / RFC](https://github.com/vllm-project/vllm-omni/issues/7074)
- [Google–Inferact TPU partnership announcement](https://inferact.ai/news/google-tpu-partnership)
- [Google Cloud: Serve an LLM using TPU Trillium on GKE with vLLM](https://docs.cloud.google.com/kubernetes-engine/docs/tutorials/serve-vllm-tpu)
- [vLLM TPU Inference repository](https://github.com/vllm-project/tpu-inference)
- [Google JetStream repository and archival notice](https://github.com/AI-Hypercomputer/JetStream)
- [SGLang Development Roadmap (2026 Q2)](https://github.com/sgl-project/sglang/issues/22949)
- [SGLang non-GPU process Rust migration RFC](https://github.com/sgl-project/sglang/issues/23206)
- [AMD vLLM Development Roadmap (2026 Q3, draft)](https://github.com/vllm-project/vllm/issues/44091)
- [AMD SGLang Development Roadmap (2026 Q3)](https://github.com/sgl-project/sglang/issues/35003)
- [ROCm AITER Development Roadmap (2026 Q2)](https://github.com/ROCm/aiter/issues/3442)
- [TensorRT-LLM Q3 2026 Roadmap](https://github.com/NVIDIA/TensorRT-LLM/issues/15044)
- [TensorRT-LLM Release Notes](https://nvidia.github.io/TensorRT-LLM/release-notes.html)
- [NVIDIA Dynamo H1 2026 Roadmap](https://github.com/ai-dynamo/dynamo/issues/5506)
- [Dynamo 0.5.1 and 0.6.0 roadmap dates](https://github.com/ai-dynamo/dynamo/issues/3323)
- [Dynamo Releases](https://github.com/ai-dynamo/dynamo/releases)
- [OpenVINO Release Notes](https://docs.openvino.ai/releasenotes)
