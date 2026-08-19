# RMA / Financial Institution CDD Solution

本 repository 是環服案搬移至銀行內網開發用的程式碼版本。

## 內容

- `.agents/skills/`：BU 訪談、證據處理、知識蒸餾與 Solution 建置 Skills。
- `solution/fi-cdd-composable-v1/`：CDD roster reader、ACCUITY source adapter、case mapper、validator、batch Excel exporter、human controls、orchestrator 與資料契約。
- `input/`：模擬客戶名單；僅供結構與批次流程開發。
- `output/`、`runs/`、`logs/`：內網執行時使用的空目錄。

## 未包含

- CDD／EDD Word 範本及銀行內部作業規範
- 訪談或操作影片
- 核准 BRD 與內部知識基線
- BIDV／KBZ 或其他實際查核資料
- 帳號、密碼、Cookie、Token 或瀏覽器登入狀態

上述內部資料應透過銀行核准管道移轉，不應提交到此 repository。

## 目前狀態

Excel batch renderer 已可產生中英雙語 CDD review workbook。OpenCLI CDP source adapter 仍需在銀行目標環境完成 POC；制裁、PEP、內部名單、風險評級與核准仍保留人工控制。
