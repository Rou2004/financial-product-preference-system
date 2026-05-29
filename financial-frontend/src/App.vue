<template>
  <div class="app-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <h2>金融商品喜好紀錄系統</h2>
          <div class="search-bar">
            <el-input 
              v-model="userId" 
              placeholder="請輸入使用者 ID (如: A1236456789)" 
              style="width: 250px; margin-right: 12px;"
            />
            <el-button type="primary" @click="fetchFavorites">查詢喜好清單</el-button>
            <el-button type="success" @click="openAddDialog">新增喜好商品</el-button>
          </div>
        </div>
      </template>

      <el-table :data="favoriteList" border style="width: 100%" v-loading="loading">
        <el-table-column prop="sn" label="序號" width="70" align="center" />
        <el-table-column prop="productName" label="金融商品名稱" min-width="150">
          <template #default="scope">
            <span v-html="sanitizeContent(scope.row.productName)"></span>
          </template>
        </el-table-column>
        <el-table-column prop="account" label="扣款帳號" width="140" align="center" />
        <el-table-column prop="purchaseQuantity" label="購買數量" width="100" align="right" />
        <el-table-column prop="totalFee" label="手續費 (元)" width="120" align="right">
          <template #default="scope">
            $ {{ formatNumber(scope.row.totalFee) }}
          </template>
        </el-table-column>
        <el-table-column prop="totalAmount" label="預計扣款總金額 (元)" width="180" align="right">
          <template #default="scope">
            <strong>$ {{ formatNumber(scope.row.totalAmount) }}</strong>
          </template>
        </el-table-column>
        <el-table-column prop="email" label="聯絡通知信箱" min-width="160">
          <template #default="scope">
            <span v-html="sanitizeContent(scope.row.email)"></span>
          </template>
        </el-table-column>

        <el-table-column label="功能操作" width="160" align="center">
          <template #default="scope">
            <el-button size="small" type="warning" @click="openEditDialog(scope.row)">修改</el-button>
            <el-button size="small" type="danger" @click="handleDelete(scope.row.sn)">刪除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '修改購買數量' : '新增喜好金融商品'" width="500px">
      <el-form :model="form" label-width="110px">
        <el-form-item label="使用者 ID" v-if="!isEdit">
          <el-input v-model="form.userId" disabled />
        </el-form-item>
        
        <el-form-item label="選擇金融商品" v-if="!isEdit">
          <el-select v-model="form.productNo" placeholder="請選擇金融商品" style="width: 100%">
            <el-option
              v-for="item in dbProducts"
              :key="item.ProductNo"
              :label="`${item.ProductName} (單價: $${item.Price})`"
              :value="item.ProductNo"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="購買數量">
          <el-input-number v-model="form.purchaseQuantity" :min="1" style="width: 100%" />
        </el-form-item>

        <div v-if="!isEdit && selectedProductInfo" class="live-calc-box">
          <p>現取商品：<strong>{{ selectedProductInfo.ProductName }}</strong></p>
          <p>商品單價：<span class="text-blue">${{ formatNumber(selectedProductInfo.Price) }}</span></p>
          <p>預估主金：<span class="text-orange">${{ formatNumber(estimatedSubTotal) }}</span> (不含手續費)</p>
        </div>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitForm">確認提交</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { favoriteApi } from './api/favorite';
import DOMPurify from 'dompurify';
import { ElMessage, ElMessageBox } from 'element-plus';

// 響應式變數設定
const userId = ref('A1236456789');
const favoriteList = ref([]);
const dbProducts = ref([]);
const loading = ref(false);
const dialogVisible = ref(false);
const isEdit = ref(false);
const currentSn = ref(null);

const form = ref({
  userId: '',
  productNo: null,
  purchaseQuantity: 10
});

// 查詢可選商品選單
const fetchProductOptions = async () => {
  try {
    const res = await favoriteApi.getAvailableProducts();
    dbProducts.value = res.data;
  } catch (error) {
    console.error('無法取得商品清單', error);
  }
};

// 抓取商品詳細資訊
const selectedProductInfo = computed(() => {
  return dbProducts.value.find(p => p.ProductNo === form.value.productNo);
});

// 試算金額 (單價 * 數量)
const estimatedSubTotal = computed(() => {
  if (!selectedProductInfo.value) return 0;
  return selectedProductInfo.value.Price * form.value.purchaseQuantity;
});

// 查詢喜好清單
const fetchFavorites = async () => {
  if (!userId.value.trim()) {
    ElMessage.warning('請先輸入使用者 ID');
    return;
  }
  loading.value = true;
  try {
    const res = await favoriteApi.getFavorites(userId.value);
    favoriteList.value = res.data;
  } catch (error) {
    console.error(error);
  } finally {
    loading.value = false;
  }
};

// 開啟新增彈窗
const openAddDialog = () => {
  isEdit.value = false;
  form.value = {
    userId: userId.value,
    productNo: dbProducts.value.length > 0 ? dbProducts.value[0].ProductNo : null, // 預選第一個商品
    purchaseQuantity: 10
  };
  dialogVisible.value = true;
};

// 開啟修改彈窗
const openEditDialog = (row) => {
  isEdit.value = true;
  currentSn.value = row.sn;
  form.value.purchaseQuantity = row.purchaseQuantity;
  dialogVisible.value = true;
};

// 提交表單
const submitForm = async () => {
  try {
    if (isEdit.value) {
      await favoriteApi.updateFavorite(currentSn.value, form.value.purchaseQuantity);
      ElMessage.success('修改成功！');
    } else {
      await favoriteApi.addFavorite(form.value);
      ElMessage.success('新增成功！');
    }
    dialogVisible.value = false;
    fetchFavorites();
  } catch (error) {
    console.error(error);
  }
};

// 刪除喜好商品
const handleDelete = (sn) => {
  ElMessageBox.confirm('確定要將此商品自喜好清單中移除嗎？', '提示', {
    confirmButtonText: '確定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    await favoriteApi.deleteFavorite(sn);
    ElMessage.success('刪除成功！');
    fetchFavorites();
  }).catch(() => {});
};

const sanitizeContent = (content) => DOMPurify.sanitize(content);

const formatNumber = (num) => {
  if (num == null) return '0.00';
  return parseFloat(num).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
};

onMounted(() => {
  fetchFavorites();
  fetchProductOptions();
});
</script>

<style scoped>
.app-container {
  padding: 24px;
  background-color: #f5f7fa;
  min-height: 100vh;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}
.card-header h2 {
  margin: 0;
  font-size: 20px;
  color: #303133;
}
.search-bar {
  display: flex;
  align-items: center;
}
/* 新增的試算區塊精美樣式 */
.live-calc-box {
  margin-top: 18px;
  padding: 12px 16px;
  background-color: #fafafa;
  border-left: 4px solid #409eff;
  border-radius: 4px;
}
.live-calc-box p {
  margin: 6px 0;
  font-size: 14px;
  color: #606266;
}
.text-blue {
  color: #409eff;
  font-weight: bold;
}
.text-orange {
  color: #e6a23c;
  font-weight: bold;
}
</style>