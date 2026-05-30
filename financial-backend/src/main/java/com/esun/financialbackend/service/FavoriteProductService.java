package com.esun.financialbackend.service;

import com.esun.financialbackend.dto.FavoriteProductDto;
import com.esun.financialbackend.repository.FavoriteProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Map;
import java.util.List;

@Service
public class FavoriteProductService {

    private final FavoriteProductRepository favoriteProductRepository;

    // 透過建構子注入 Repository
    public FavoriteProductService(FavoriteProductRepository favoriteProductRepository) {
        this.favoriteProductRepository = favoriteProductRepository;
    }

    /**
     * 登入驗證邏輯
     */
    public Map<String, Object> loginCheck(String userId, String inputPassword) {
        Map<String, Object> userMap = favoriteProductRepository.getLoginInfoById(userId);

        if (userMap == null || userMap.isEmpty()) {
            System.out.println("找不到該帳號: " + userId);
            return null;
        }
        String dbPassword = (String) userMap.get("password");
        System.out.println("帳號: " + userId + " | 輸入密碼: " + inputPassword + " | 資料庫密碼: " + dbPassword);

        if (dbPassword != null && dbPassword.equals(inputPassword)) {
            userMap.remove("password");
            return userMap;
        }
        return null;
    }

    public Map<String, Object> getUserInfo(String userId) {
        return favoriteProductRepository.getUserInfoById(userId);
    }

    /**
     * 查詢喜好商品清單
     */
    @Transactional
    public List<FavoriteProductDto> getFavoriteProducts(String userId) {
        if (userId == null || userId.trim().isEmpty()) {
            throw new IllegalArgumentException("使用者 ID 不能為空");
        }
        return favoriteProductRepository.getFavoriteProducts(userId);
    }

    /**
     * 新增喜好金融商品
     */
    @Transactional
    public void addFavoriteProduct(String userId, Integer productNo, Integer purchaseQuantity) {
        if (purchaseQuantity == null || purchaseQuantity <= 0) {
            throw new IllegalArgumentException("購買數量必須大於 0");
        }
        favoriteProductRepository.addFavoriteProduct(userId, productNo, purchaseQuantity);
    }

    /**
     * 更改喜好商品資訊
     */
    @Transactional
    public void updateFavoriteProduct(Integer sn, Integer purchaseQuantity) {
        if (sn == null || purchaseQuantity == null || purchaseQuantity <= 0) {
            throw new IllegalArgumentException("無效的流水序號或購買數量");
        }

        favoriteProductRepository.updateFavoriteProduct(sn, purchaseQuantity);
    }

    /**
     * 刪除喜好金融商品
     */
    @Transactional
    public void deleteFavoriteProduct(Integer sn) {
        if (sn == null) {
            throw new IllegalArgumentException("流水序號不能為空");
        }

        favoriteProductRepository.deleteFavoriteProduct(sn);
    }

    public List<Map<String, Object>> getProductList() {
        return favoriteProductRepository.getProductList();
    }
}