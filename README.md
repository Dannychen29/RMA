# RMA / Financial Institution CDD Solution

本 repository 是環服案移轉至銀行內網開發使用的程式碼版本。它同時包含「通用知識蒸餾 Skills」與「本案 CDD Solution」。正式文件範本、內規與實際查核資料不放在 Public repository。

## 根目錄資料夾

### `.agents/skills/`

Codex 使用的通用 BU 工作流程 Skills。這一層負責從訪談、證據整理、知識蒸餾到 Solution 建置，不是單一 CDD 案件的執行資料。

- `conduct-bu-interview/`：建立 engagement、訪談 BU、確認需求並收集證據。
- `record-bu-walkthrough/`：經使用者同意後錄製 Windows 操作流程與聲音。
- `prepare-audio-evidence/`：整理錄音、逐字稿、時間碼與說話者資訊。
- `extract-video-evidence/`：從長影片挑選高價值片段、畫面與時間碼。
- `analyze-video-evidence/`：分析畫面操作、欄位、決策、例外與痛點。
- `distill-bu-knowledge/`：將訪談及證據蒸餾成可追溯、可核准的 BRD。
- `build-bu-solution/`：把核准需求拆成可獨立測試的能力模組並組成 Solution。

每個 Skill 通常包含：`SKILL.md`（主流程）、`agents/`（代理設定）、`references/`（契約與品質門檻）、`scripts/`（驗證或轉換腳本）以及 `assets/`（空白結構或範本）。

### `solution/fi-cdd-composable-v1/`

本案實際 CDD Solution。它讀取銀行名單、取得 ACCUITY／CBDDQ 證據、建立標準化案件、檢查缺漏，最後輸出中英雙語 Excel。

- `capabilities/`：可以分開開發與測試的功能模組。
- `contracts/`：模組之間交換資料所使用的 JSON Schema 與欄位對照表。
- `orchestrator/`：依順序呼叫各能力、保存案件狀態；不應放入欄位判斷邏輯。
- `runtime-adapters/`：銀行環境特有的執行介面，目前包含 OpenCLI CDP adapter 規格。
- `capability-manifest.yaml`：能力清單、依賴關係、狀態、測試方式及負責人。
- `solution-brief.yaml`：Solution 的目標、輸入、輸出、限制及驗收條件。
- `validation.md`：目前完成的測試與尚待銀行環境驗證事項。

#### `capabilities/` 內部功能

- `roster-reader/`：讀取 XLSX／CSV 銀行名單，標準化 Legal Name、BIC、國家等欄位。
- `accuity-source-adapter/`：定義如何查詢 Bankers Almanac／ACCUITY、比對銀行及取得 CBDDQ 證據。
- `case-mapper/`：把名單、ACCUITY、CBDDQ 與人工資料合併成 `cdd-case.json`。
- `case-validator/`：檢查必要 metadata、缺漏狀態，防止把查不到資料誤判為「否」。
- `batch-review-exporter/`：把案件批次輸出成中英雙語、具有狀態顏色及來源說明的 Excel。
- `human-controls/`：定義制裁、PEP、風險評級、建議與核准等人工控制邊界。

### `input/`

目前只放模擬客戶名單，用來確認 Excel reader 與批次流程。在銀行內網可將正式名單放在這裡，但不得 commit 回 GitHub。

### `output/`

存放產出的 CDD Excel。內容已被 `.gitignore` 排除，避免正式審查結果提交到 repository。

### `runs/`

每次執行的工作目錄，建議使用 `runs/<run-id>/<BIC>/`，存放 `cdd-case.json`、來源證據、案件狀態與錯誤資訊。不得存放密碼、Cookie 或 Token，且內容不提交 GitHub。

### `logs/`

存放執行紀錄與除錯訊息。Log 必須遮罩帳號、個資、Cookie、Token、Session ID 等敏感值，且內容不提交 GitHub。

## 未包含的資料

- CDD／EDD Word 文件範本
- 銀行內部作業規範與風險評級文件
- 訪談或操作影片
- 核准 BRD 與內部知識基線
- BIDV／KBZ 或其他實際查核資料
- 帳號、密碼、Cookie、Token 或瀏覽器登入狀態

上述資料應使用銀行核准管道另外移轉。

## 建議執行流程

```text
input 銀行名單
    ↓
roster-reader
    ↓
accuity-source-adapter（OpenCLI／ACCUITY）
    ↓
case-mapper → runs/<run-id>/<BIC>/cdd-case.json
    ↓
case-validator
    ↓
batch-review-exporter → output/CDD_BATCH_REVIEW.xlsx
    ↓
人工篩檢、風險評級、覆核與核准
```

## 目前狀態

Excel batch renderer 已可產生中英雙語 CDD review workbook。OpenCLI CDP source adapter 仍需在銀行目標環境完成 POC；制裁、PEP、內部名單、風險評級與核准仍保留人工控制。
