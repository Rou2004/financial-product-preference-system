import request from './request';

export const favoriteApi = {
    // 查詢喜好清單 (GET /favorites?userId=...)
    getFavorites(userId) {
        return request.get('/favorites', { params: { userId } });
    },

     // 取得可選擇的金融商品清單
    getAvailableProducts() {
    return request.get('/favorites/products');
    },

    // 新增喜好商品 (POST /favorites)
    addFavorite(data) {
        // data 格式: { userId: '...', productNo: 1, purchaseQuantity: 10 }
        return request.post('/favorites', data);
    },

    // 改購買數量 (PUT /favorites/{sn})
    updateFavorite(sn, purchaseQuantity) {
        return request.put(`/favorites/${sn}`, { purchaseQuantity });
    },

    // 刪除喜好商品 (DELETE /favorites/{sn})
    deleteFavorite(sn) {
        return request.delete(`/favorites/${sn}`);
    },
};