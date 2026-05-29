package com.esun.financialbackend.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class FavoriteProductDto {
    private Integer sn;
    private String userId;
    private String productName;
    private String account;
    private Integer purchaseQuantity;
    private BigDecimal totalFee;
    private BigDecimal totalAmount;
    private String email;
}
