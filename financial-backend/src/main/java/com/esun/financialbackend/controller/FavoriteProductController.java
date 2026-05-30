package com.esun.financialbackend.controller;

import com.esun.financialbackend.dto.LoginRequestDto;
import com.esun.financialbackend.dto.FavoriteProductDto;
import com.esun.financialbackend.service.FavoriteProductService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/favorites")
@CrossOrigin(origins = "*") // 允許前端跨網域
public class FavoriteProductController {

    private final FavoriteProductService favoriteProductService;

    public FavoriteProductController(FavoriteProductService favoriteProductService) {
        this.favoriteProductService = favoriteProductService;
    }


    /**
     * 查詢喜好商品清單
     * URL: GET http://localhost:8080/api/favorites?userId=A1236456789
     */
    @GetMapping
    public ResponseEntity<List<FavoriteProductDto>> getFavoriteProducts(@RequestParam String userId) {
        return ResponseEntity.ok(favoriteProductService.getFavoriteProducts(userId));
    }

    @GetMapping("/{userId}/user-info")
    public ResponseEntity<Map<String, Object>> getUserInfo(@PathVariable String userId) {
        Map<String, Object> userInfo = favoriteProductService.getUserInfo(userId);
        if (userInfo.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
        return ResponseEntity.ok(userInfo);
    }

    /**
     * 撈取供前端下拉選單選用的金融商品資訊
     * URL: GET http://localhost:8080/api/favorites/products
     */
    @GetMapping("/products")
    public ResponseEntity<List<Map<String, Object>>> getProductList() {
        return ResponseEntity.ok(favoriteProductService.getProductList());
    }


    /**
     * 使用者登入接口
     * URL: POST http://localhost:8080/api/favorites/login
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequestDto loginDto) {
        if (loginDto.getUserId() == null || loginDto.getUserId().trim().isEmpty() ||
                loginDto.getPassword() == null || loginDto.getPassword().trim().isEmpty()) {
            return ResponseEntity.badRequest().body("帳號與密碼不可為空！");
        }

        Map<String, Object> loginUser = favoriteProductService.loginCheck(
                loginDto.getUserId().trim(),
                loginDto.getPassword()
        );

        if (loginUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("帳號或密碼錯誤");
        }

        return ResponseEntity.ok(loginUser);
    }

    /**
     * 新增喜好金融商品
     * URL: POST http://localhost:8080/api/favorites
     */
    @PostMapping
    public ResponseEntity<String> addFavoriteProduct(@RequestBody Map<String, Object> payload) {
        String userId = (String) payload.get("userId");
        String Account = (String) payload.get("Account");
        Integer productNo = (Integer) payload.get("productNo");
        Integer purchaseQuantity = (Integer) payload.get("purchaseQuantity");

        favoriteProductService.addFavoriteProduct(userId, productNo, purchaseQuantity);
        return ResponseEntity.status(HttpStatus.CREATED).body("喜好商品新增成功！");
    }

    /**
     * 更改喜好商品資訊（更新購買數量）
     * URL: PUT http://localhost:8080/api/favorites/1
     */
    @PutMapping("/{sn}")
    public ResponseEntity<String> updateFavoriteProduct(
            @PathVariable Integer sn,
            @RequestBody Map<String, Object> payload) {

        Integer purchaseQuantity = (Integer) payload.get("purchaseQuantity");
        favoriteProductService.updateFavoriteProduct(sn, purchaseQuantity);
        return ResponseEntity.ok("喜好商品數量修改成功！");
    }

    /**
     * 刪除喜好金融商品
     * URL: DELETE http://localhost:8080/api/favorites/1
     */
    @DeleteMapping("/{sn}")
    public ResponseEntity<String> deleteFavoriteProduct(@PathVariable Integer sn) {
        favoriteProductService.deleteFavoriteProduct(sn);
        return ResponseEntity.ok("喜好商品刪除成功！");
    }
}