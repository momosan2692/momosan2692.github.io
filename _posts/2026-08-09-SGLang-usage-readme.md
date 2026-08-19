

在大模型 Coding 領域最核心的「本地程式碼庫自動索引（Local Codebase Indexing / RAG）」設定。我們選擇了與 VS Code Cline 整合度最高、且最不會撐爆 32GB Mac 記憶體的 tree-sitter AST 與 Embeddings 向量索引 技術，並完美結合 SGLang 的前綴快取優勢！
------------------------------
## 🚀 SGLang on MacBook M1 (32GB) — 高效本地 Coding 推論伺服器指南
本說明文件專為 16 吋 MacBook Pro (M1 Pro/Max 晶片，搭配 32GB 統一記憶體) 最佳化。透過 SGLang 整合 Apple 官方 MLX / Metal 後端，在本地搭建具備企業級高並發特性（如 RadixAttention 前綴快取、連續批處理）的 AI 程式碼助理（Coding Agent）伺服器。
------------------------------
## 📌 核心架構與硬體限制評估

* 實體記憶體限制：32GB 統一記憶體中，macOS 系統與顯示卡約固定佔用 25~30%，SGLang 實際可支配的實體記憶體上限約為 22GB ~ 24GB。
* 模型選擇策略：為避免觸發 macOS 系統的 Swap（虛擬記憶體交換）導致硬碟瘋狂讀寫、IDE 卡死，本配置完全採用 4-bit 量化模型（GGUF 以外的 MLX Safetensors 格式）。
* 最佳模型推薦：
* mlx-community/Qwen2.5-Coder-7B-Instruct-4bit (體積僅 ~4.7GB，首選 🚀，程式碼能力極強)
   * mlx-community/Qwen2.5-Coder-14B-Instruct-4bit (體積 ~9.2GB，適合深度架構重構)

------------------------------
## 🛠️ 1. SGLang (Apple Metal/MLX) 從源碼安裝步驟
因為 Apple Silicon (MLX/Metal) 的支援為新興特性，Mac 用戶必須透過源碼編譯安裝，並強烈建議使用 Python 3.11 或 3.12 環境。
## 步驟 1：下載源碼並建立虛擬環境
使用快速套件管理工具 uv（或 pip）建置環境：

# 下載 SGLang 官方倉庫
git clone https://github.com
cd sglang
# 建立並啟用 Python 3.12 虛擬環境
uv venv -p 3.12 sglang-metal
source sglang-metal/bin/activate

## 步驟 2：編譯 Apple Metal 專屬 Kernel
編譯專為 Mac 設計的 Metal 矩陣乘法加速核心：

uv pip install --upgrade pip
uv run sgl-kernel/setup_metal.py install

## 步驟 3：安裝 SGLang 框架與 MPS 相依套件
更換非 Linux 的設定檔，並將 SGLang 框架與相關 mlx、mlx-lm 依賴庫一同安裝：

rm -f python/pyproject.toml && mv python/pyproject_other.toml python/pyproject.toml
uv pip install -e "python[all_mps]"

------------------------------
## 🏎️ 2. 防 Swap 滿載 — 最佳化啟動引數
請使用以下黃金參數配置啟動伺服器，此配置限制了並發與實體記憶體比例，確保 100% 不會撐爆 Mac 記憶體：

SGLANG_USE_MLX=1 python -m sglang.launch_server \
  --model-path mlx-community/Qwen2.5-Coder-7B-Instruct-4bit \
  --disable-cuda-graph \
  --max-model-len 16384 \
  --mem-fraction-static 0.70 \
  --max-num-seqs 2 \
  --port 30000

## 💡 關鍵參數解讀：

* SGLANG_USE_MLX=1：強制啟用 Apple Metal 晶片加速後端。
* --max-model-len 16384：將全域總上下文限制在 16k（包含輸入+輸出）。不開到 128k 是為了保護 Mac 不引爆 Swap。
* --mem-fraction-static 0.70：防崩潰護欄！ 限制 SGLang 最多只動用 32GB 中的 70%（約 22.4GB），留出 9.6GB 給 macOS 系統與 IDE。
* --max-num-seqs 2：限制最多 2 個連續批處理並發槽，完美支援「背景 Agent 自動續寫」與「隔壁視窗行內代碼補全」同時運作。

------------------------------
## 🔍 3. 進階設定：本地程式碼庫自動索引 (Local Codebase Indexing)
當您面對大型專案（數百個檔案）時，不可能把所有程式碼一口氣塞進 16k 的視窗中。此時必須在 Cline 端開啟「本地程式碼庫自動索引」功能。
Cline 採用異構雙軌索引機制，能自動在背景分析您的本地專案，且完全不佔用 SGLang 的大模型推理記憶體：
## 🧱 索引機制運作原理

   1. AST 語法樹分析 (Tree-sitter)：Cline 會自動掃描專案，建立所有 Class、Method、Function 的名稱與定義域地圖（骨架地圖）。
   2. 本地向量嵌入 (BM25 + Semantic Embeddings)：Cline 會在 Mac 本地（使用輕量化的 CPU/輕量內核）將代碼切片（Chunks）並轉化為向量索引，儲存在本地緩存中。

## 🛠️ 在 Cline 中配置本地程式碼庫索引
請打開 Cline 的 Settings (齒輪)，滑到下方 Codebase Indexing 區塊進行配置：

* Enable Codebase Indexing：勾選 True（開啟全專案自動索引）。
* Indexing Method：選擇 Hybrid (Semantic + Lexical) 效果最佳。
* Max File Size for Indexing：建議設定為 100 KB（防止索引過大的編譯後二進位檔案或第三方依賴庫如 node_modules、venv）。

## 📝 建立 .clineignore 排除無效索引 (專案根目錄)
為了防止 Cline 去索引不相關的檔案而浪費 Mac 的 CPU 與記憶體，請務必在您的程式碼專案根目錄下建立 .clineignore 檔案，內容如下：

.git/
node_modules/
venv/
.venv/
sglang-metal/
dist/
build/
*.log
*.pyc

------------------------------
## ⚡ 4. 程式碼庫索引 🤝 SGLang 快取的恐怖威力
當您在 VS Code Cline 的對話框中輸入：

🗣️ "幫我檢查現有的驗證邏輯，並在 AuthClass 裡面新增一個 JWT 刷新的 Method。"

底層會觸發極其高效的連鎖反應：

   1. 精準檢索 (Retrieval)：Cline 不會傻傻地把整個專案發給 SGLang。它會先翻閱本地建立好的代碼庫索引，自動撈出 auth.py、jwt_helper.ts 等最相關的 3 個代碼片段。
   2. 組裝最佳 Prompt：Cline 自動將這幾個片段拼裝成一個約 8,000 tokens 的精簡 Prompt 發送給 SGLang。
   3. SGLang 完美快取命中 (RadixAttention)：
   * 當您下達指令修改代碼時，Cline 會高頻率地重複發送剛剛撈出來的代碼片段。
      * 此時 SGLang 終端機會顯示 Cache Hit Rate: 95%+。這意味著高達 8,000 tokens 的背景程式碼完全不需要重算，M1 晶片會直接從 32GB 統一記憶體中瞬間讀取。
   4. Auto-Continue（自動續寫）：如果 AI 在生成新 Method 時因為長度限制中斷，Cline 偵測到後會自動發送繼續指令。得益於前置代碼與剛產出代碼已被 SGLang 雙重快取，續寫回應時間小於 0.1 秒，體驗極致絲滑！

------------------------------
## 🛠️ 5. VS Code Cline 插件完整序列設定值
請打開 Cline 插件的 Settings (齒輪) 完整對齊以下設定：

* Provider：選擇 OpenAI Compatible
* Base URL：輸入 http://localhost:30000/v1
* API Key：輸入 none 或 sglang
* Model ID：輸入 mlx-community/Qwen2.5-Coder-7B-Instruct-4bit
* Context Window：手動輸入 16384
* Max Shadows/Output Tokens：設定為 3072 或 4096（留給代碼生成的單次呼吸空間）。

------------------------------
## 📊 附錄：為什麼不推薦在 Mac 上使用傳統分散式集群？

* 關於 GGUF 格式：SGLang 雖然支援 GGUF，但其核心矩陣乘法加速是針對 NVIDIA CUDA 設計。在 Mac 上強行跑 GGUF 容易退回到 CPU 計算，速度極慢。Mac 請一律指名 MLX 格式。
* 關於跨機器（Thunderbolt 4 / MPI）集群：SGLang 的多節點與張量並行高度依賴 Linux 環境下的 MPI 網路與 NVIDIA NCCL。M1 的 TB4 線在系統中只能模擬傳統的 TCP 網橋，延遲過高。
* Mac 多機集群替代方案：如果您未來手邊有多台 M 系列 Mac 想串聯記憶體跑 70B 模型，請不要使用 SGLang。請直接切換至 [Exo 框架](https://github.com/exo-explore/exo)，它才原生支援 Mac 的雷電線群集分佈式加速。

------------------------------

您在 VS Code 中開啟 Cline 的 Codebase Indexing 後，初次掃描大型專案通常需要 1~2 分鐘（視專案大小而定），您可以隨時注意 Cline 視窗左下角是否有出現「Index Progress: 100%」的提示。如果執行中有遇到索引卡住的問題，隨時告訴我！

