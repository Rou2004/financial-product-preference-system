<template>
  <div class="app-container">
    <el-form @keyup.enter="handleLogin">
      <el-dialog
        v-model="loginDialogVisible"
        title="系統登入"
        width="450px"
        :show-close="false"
        :close-on-click-modal="false"
        :close-on-press-escape="false"
        class="custom-login-dialog"
        align-center
        center
      >

        <el-form :model="loginForm" label-width="110px">
          <el-form-item label="使用者帳號">
            <el-input
              v-model="loginForm.userId"
              placeholder="請輸入使用者帳號  (如: A1236456789) "
              clearable
            />
          </el-form-item>
          <el-form-item label="密碼">
            <el-input
              v-model="loginForm.password"
              type="password"
              placeholder="請輸入密碼"
              show-password
            />
          </el-form-item>
        </el-form>

        <template #footer>
          <span class="dialog-footer">
            <el-button
              type="primary"
              :loading="loginLoading"
              @click="handleLogin"
              style="width: 100%"
            >
              登入
            </el-button>
          </span>
        </template>
      </el-dialog>
    </el-form>

    <div>
      <div v-if="isLoggedIn" style="text-align: right; margin-bottom: 12px">
        <el-tag type="success" style="margin-right: 12px; font-size: 14px">
          當前登入：{{ currentUserName }}
        </el-tag>
        <el-button type="info" size="small" plain @click="handleLogout"
          >登出系統</el-button
        >
      </div>

      <el-card class="box-card">
        <template #header>
          <div class="card-header">
            <h2>金融商品喜好紀錄系統</h2>
            <div class="search-bar">
              <el-button type="primary" @click="fetchFavorites"
                >查詢喜好清單</el-button
              >
              <el-button type="success" @click="openAddDialog"
                >新增喜好商品</el-button
              >
            </div>
          </div>
        </template>

        <el-table
          :data="favoriteList"
          border
          style="width: 100%"
          v-loading="loading"
        >
          <el-table-column
            prop="productName"
            label="金融商品名稱"
            min-width="150"
          >
            <template #default="scope">
              <span v-html="sanitizeContent(scope.row.productName)"></span>
            </template>
          </el-table-column>
          <el-table-column
            prop="account"
            label="扣款帳號"
            width="140"
            align="center"
          />
          <el-table-column
            prop="purchaseQuantity"
            label="購買數量"
            width="100"
            align="right"
          />
          <el-table-column
            prop="totalFee"
            label="總手續費用 (元)"
            width="120"
            align="right"
          >
            <template #default="scope">
              $ {{ formatNumber(scope.row.totalFee) }}
            </template>
          </el-table-column>
          <el-table-column
            prop="totalAmount"
            label="預計扣款總金額 (元)"
            width="180"
            align="right"
          >
            <template #default="scope">
              <strong>$ {{ formatNumber(scope.row.totalAmount) }}</strong>
            </template>
          </el-table-column>
          <el-table-column prop="email" label="聯絡電子信箱" min-width="160">
            <template #default="scope">
              <span v-html="sanitizeContent(scope.row.email)"></span>
            </template>
          </el-table-column>

          <el-table-column label="其他功能" width="160" align="center">
            <template #default="scope">
              <el-button
                size="small"
                type="warning"
                @click="openEditDialog(scope.row)"
                >修改</el-button
              >
              <el-button
                size="small"
                type="danger"
                @click="handleDelete(scope.row.sn)"
                >刪除</el-button
              >
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>

    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '修改購買數量' : '新增喜好金融商品'"
      width="500px"
    >
      <el-form :model="form" label-width="110px">
        <el-form-item label="使用者 ID" v-if="!isEdit">
          <el-input v-model="form.userId" disabled />
        </el-form-item>
        <el-form-item label="使用者名稱" v-if="!isEdit">
          <el-input v-model="form.userName" disabled />
        </el-form-item>
        <el-form-item label="扣款帳號" v-if="!isEdit">
          <el-input v-model="form.account" disabled />
        </el-form-item>
        <el-form-item label="選擇金融商品" v-if="!isEdit">
          <el-select
            v-model="form.productNo"
            placeholder="請選擇金融商品"
            style="width: 100%"
          >
            <el-option
              v-for="item in dbProducts"
              :key="item.ProductNo"
              :label="`${item.ProductName} (單價: $${item.Price})`"
              :value="item.ProductNo"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="購買數量">
          <el-input-number
            v-model="form.purchaseQuantity"
            :min="1"
            style="width: 100%"
          />
        </el-form-item>

        <div v-if="!isEdit && selectedProductInfo" class="live-calc-box">
          <p>
            現取商品：<strong>{{ selectedProductInfo.ProductName }}</strong>
          </p>
          <p>
            商品單價：<span class="text-blue"
              >${{ formatNumber(selectedProductInfo.Price) }}</span
            >
          </p>
          <p>
            預估主金：<span class="text-orange"
              >${{ formatNumber(estimatedSubTotal) }}</span
            >
            (不含手續費)
          </p>
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
import { ref, onMounted, computed } from "vue";
import { favoriteApi } from "./api/favorite";
import DOMPurify from "dompurify";
import { ElMessage, ElMessageBox } from "element-plus";

const isLoggedIn = ref(false);
const loginDialogVisible = ref(true);
const loginLoading = ref(false);
const currentUserName = ref("");

const loginForm = ref({
  userId: "",
  password: "",
});

const userId = ref("");
const userName = ref("");
const account = ref("");
const favoriteList = ref([]);
const dbProducts = ref([]);
const loading = ref(false);
const dialogVisible = ref(false);
const isEdit = ref(false);
const currentSn = ref(null);

const form = ref({
  userId: "",
  userName: "",
  account: "",
  productNo: null,
  purchaseQuantity: 10,
});

// 登入
const handleLogin = async () => {
  if (!loginForm.value.userId.trim() || !loginForm.value.password.trim()) {
    ElMessage.warning("請輸入帳號與密碼");
    return;
  }

  loginLoading.value = true;
  try {
    const res = await favoriteApi.login(
      loginForm.value.userId.trim(),
      loginForm.value.password,
    );

    if (res && res.data) {
      ElMessage.success(`已登入！`);

      localStorage.setItem("token_user", JSON.stringify(res.data));

      userId.value = res.data.userId;
      currentUserName.value = res.data.userName;

      account.value = res.data.Account || res.data.account || "";

      isLoggedIn.value = true;
      loginDialogVisible.value = false;

      fetchProductOptions();
      fetchFavorites();
    }
  } catch (error) {
    console.error(error);
    ElMessage.error(error.response?.data || "登入失敗，請檢查帳號密碼");
  } finally {
    loginLoading.value = false;
  }
};

// 登出
const handleLogout = () => {
  localStorage.removeItem("token_user");
  isLoggedIn.value = false;
  loginDialogVisible.value = true;

  favoriteList.value = [];
  userId.value = "";
  userName.value = "";
  account.value = "";
  loginForm.value.userId = "";
  loginForm.value.password = "";
  ElMessage.info("已安全登出");
};

// 查詢可選商品選單
const fetchProductOptions = async () => {
  try {
    const res = await favoriteApi.getAvailableProducts();
    dbProducts.value = res.data;
  } catch (error) {
    console.error("無法取得商品清單", error);
  }
};

// 抓取商品詳細資訊
const selectedProductInfo = computed(() => {
  return dbProducts.value.find((p) => p.ProductNo === form.value.productNo);
});

// 試算金額 (單價 * 數量)
const estimatedSubTotal = computed(() => {
  if (!selectedProductInfo.value) return 0;
  return selectedProductInfo.value.Price * form.value.purchaseQuantity;
});

// 查詢喜好清單
const fetchFavorites = async () => {
  if (!userId.value) {
    console.warn("未獲取到登入的使用者 ID，跳過查詢");
    return;
  }

  loading.value = true;
  try {
    const res = await favoriteApi.getFavorites(userId.value);
    favoriteList.value = res.data;

    // 同步撈取使用者的基本資料（包含扣款帳號）
    const userRes = await favoriteApi.getUserInfo(userId.value);
    if (userRes && userRes.data) {
      userName.value = userRes.data.UserName || userRes.data.userName;
      account.value = userRes.data.Account || userRes.data.account;
    }
  } catch (error) {
    console.error("查詢失敗:", error);
    ElMessage.error("載入喜好清單或基本資料失敗");
  } finally {
    loading.value = false;
  }
};

// 開啟新增彈窗
const openAddDialog = async () => {
  if (!isLoggedIn.value || !userId.value) {
    ElMessage.warning("請先登入系統");
    return;
  }

  isEdit.value = false;

  if (!account.value) {
    try {
      const userRes = await favoriteApi.getUserInfo(userId.value);
      if (userRes && userRes.data) {
        account.value = userRes.data.Account || userRes.data.account || "";
        userName.value = userRes.data.UserName || userRes.data.userName || "";
      }
    } catch (e) {
      console.error("自動補撈扣款帳號失敗:", e);
    }
  }

  form.value = {
    userId: userId.value,
    userName: currentUserName.value || userName.value,
    account: account.value,
    productNo:
      dbProducts.value.length > 0 ? dbProducts.value[0].ProductNo : null,
    purchaseQuantity: 10,
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
      await favoriteApi.updateFavorite(
        currentSn.value,
        form.value.purchaseQuantity,
      );
      ElMessage.success("修改成功！");
    } else {
      await favoriteApi.addFavorite(form.value);
      ElMessage.success("新增成功！");
    }
    dialogVisible.value = false;

    fetchFavorites();
  } catch (error) {
    console.error("提交失敗:", error);
    ElMessage.error("操作失敗，請檢查後端日誌");
  }
};

// 刪除喜好商品
const handleDelete = (sn) => {
  ElMessageBox.confirm("確定要將此商品自喜好清單中移除嗎？", "提示", {
    confirmButtonText: "確定",
    cancelButtonText: "取消",
    type: "warning",
  })
    .then(async () => {
      await favoriteApi.deleteFavorite(sn);
      ElMessage.success("刪除成功！");
      fetchFavorites();
    })
    .catch(() => {});
};

const sanitizeContent = (content) => DOMPurify.sanitize(content);

const formatNumber = (num) => {
  if (num == null) return "0.00";
  return parseFloat(num)
    .toFixed(2)
    .replace(/\B(?=(\d{3})+(?!\d))/g, ",");
};

// 初始化檢查
onMounted(() => {
  const savedUser = localStorage.getItem("token_user");
  if (savedUser) {
    const user = JSON.parse(savedUser);
    userId.value = user.userId;
    currentUserName.value = user.userName;

    isLoggedIn.value = true;
    loginDialogVisible.value = false;

    fetchProductOptions();
    fetchFavorites();
  }
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
.login-welcome-text {
  margin-top: -10px;
  margin-bottom: 20px;
  text-align: center;
}
.login-welcome-text p {
  color: #909399;
  font-size: 14px;
  margin: 0;
}
:deep(.custom-login-dialog) {
  border-radius: 8px !important;
}
</style>