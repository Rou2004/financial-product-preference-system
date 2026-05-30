package com.esun.financialbackend.repository;

import com.esun.financialbackend.dto.FavoriteProductDto;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class FavoriteProductRepository {

    private final JdbcTemplate jdbcTemplate;

    // 透過建構子注入 Spring 內建的 JdbcTemplate
    public FavoriteProductRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * 根據 UserID 查詢完整登入資訊
     */
    public Map<String, Object> getLoginInfoById(String userId) {
        String sql = "SELECT UserID AS userId, UserName AS userName, Password AS password FROM User WHERE UserID = ?";
        try {
            return jdbcTemplate.queryForMap(sql, userId);
        } catch (Exception e) {
            return new java.util.HashMap<>();
        }
    }

    /**
     * 根據 UserID 查詢使用者的真實姓名與扣款帳號
     */
    public Map<String, Object> getUserInfoById(String userId) {
        String sql = "SELECT UserName, Account FROM User WHERE UserID = ?";

        try {
            return jdbcTemplate.queryForMap(sql, userId);
        } catch (Exception e) {
            // 萬一查無此人，回傳空 Map 避免後端噴 500 錯誤
            return new java.util.HashMap<>();
        }
    }

    /**
     * 呼叫 sp_GetFavoriteProducts 預存程序
     * @param userId 使用者 ID
     * @return 喜好商品清單
     */
    public List<FavoriteProductDto> getFavoriteProducts(String userId) {
        // 初始化 SimpleJdbcCall，並指定要呼叫的 SP 名稱
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_GetFavoriteProducts")
                .returningResultSet("favoriteProducts", new FavoriteProductRowMapper());

        // 設定傳入 SP 的參數名稱與值 (對應 SP 裡的 IN p_UserID)
        Map<String, Object> inParams = new HashMap<>();
        inParams.put("p_UserID", userId);

        // 執行 SP
        Map<String, Object> result = jdbcCall.execute(inParams);

        // 從回傳結果中取出經由 RowMapper 轉換後的 List
        return (List<FavoriteProductDto>) result.get("favoriteProducts");
    }

    private static class FavoriteProductRowMapper implements RowMapper<FavoriteProductDto> {
        @Override
        public FavoriteProductDto mapRow(ResultSet rs, int rowNum) throws SQLException {
            FavoriteProductDto dto = new FavoriteProductDto();

            dto.setSn(rs.getInt("SN"));
            dto.setProductName(rs.getString("ProductName"));
            dto.setAccount(rs.getString("Account"));
            dto.setPurchaseQuantity(rs.getInt("PurchaseQuantity"));
            dto.setTotalFee(rs.getBigDecimal("TotalFee"));
            dto.setTotalAmount(rs.getBigDecimal("TotalAmount"));
            dto.setEmail(rs.getString("Email"));

            return dto;
        }
    }

    /**
     * 呼叫 sp_AddFavoriteProduct 新增喜好紀錄
     */
    public void addFavoriteProduct(String userId, Integer productNo, Integer purchaseQuantity) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_AddFavoriteProduct");

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("p_UserID", userId);
        inParams.put("p_ProductNo", productNo);
        inParams.put("p_PurchaseQuantity", purchaseQuantity);

        jdbcCall.execute(inParams);
    }

    /**
     * 呼叫 sp_UpdateFavoriteProduct 修改購買數量
     */
    public void updateFavoriteProduct(Integer sn, Integer purchaseQuantity) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_UpdateFavoriteProduct");

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("p_SN", sn);
        inParams.put("p_PurchaseQuantity", purchaseQuantity);

        jdbcCall.execute(inParams);
    }

    /**
     * 呼叫 sp_DeleteFavoriteProduct 刪除喜好紀錄
     */
    public void deleteFavoriteProduct(Integer sn) {
        SimpleJdbcCall jdbcCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("sp_DeleteFavoriteProduct");

        Map<String, Object> inParams = new HashMap<>();
        inParams.put("p_SN", sn);

        jdbcCall.execute(inParams);
    }

    public List<Map<String, Object>> getProductList() {
        String sql = "SELECT No, ProductName, Price FROM Product";

        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            Map<String, Object> map = new java.util.HashMap<>();

            map.put("ProductNo", rs.getInt("No"));
            map.put("ProductName", rs.getString("ProductName"));
            map.put("Price", rs.getBigDecimal("Price"));

            return map;
        });
    }
}