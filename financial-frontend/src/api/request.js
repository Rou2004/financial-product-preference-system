import axios from 'axios';

// 建立 Axios 實例，統一管理後端 Base URL
const request = axios.create({
    baseURL: 'http://localhost:8080/api', // 對齊 Spring Boot 的 RequestMapping
    timeout: 5000 // 超時時間 5 秒
});

request.interceptors.response.use(
    response => response,
    error => {
        let message = '系統發生異常，請稍後再試';
        if (error.response && error.response.data) {
            // 如果後端有傳回錯誤訊息，就抓取後端的訊息
            message = typeof error.response.data === 'string' ? error.response.data : message;
        }
        alert(message); // 簡單用 alert 提示，之後可以用 Element Plus 的 ElMessage 優化
        return Promise.reject(error);
    }
);

export default request;