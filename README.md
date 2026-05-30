## 如何在本機啟動專案

1. **資料庫初始化**：
   - 請在本地 MySQL 建立名為 `financial_db` 的 Schema。
   - 匯入 `database/financial_db.sql` 檔案以還原資料表結構與初始資料。

2. **後端設定**：
   - 修改 `financial-backend/src/main/resources/application.properties` 中的資料庫帳號與密碼。
   - 使用 IntelliJ IDEA 啟動 `FinancialBackendApplication`。