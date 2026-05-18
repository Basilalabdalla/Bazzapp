import axios from 'axios';
import { useAuthStore } from '../store/auth';
import type {
  Admin,
  Order,
  OrderStatus,
  Merchant,
  PaginatedResponse,
  PlatformStats,
  UserRole,
} from '../types';

const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000';

export const api = axios.create({
  baseURL: `${BASE_URL}/api`,
  headers: { 'Content-Type': 'application/json' },
});

// Request interceptor — attach access token
api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Track whether we are currently refreshing to avoid loops
let isRefreshing = false;
let failedQueue: Array<{
  resolve: (value: string) => void;
  reject: (reason: unknown) => void;
}> = [];

function processQueue(error: unknown, token: string | null) {
  failedQueue.forEach((p) => {
    if (error) {
      p.reject(error);
    } else {
      p.resolve(token as string);
    }
  });
  failedQueue = [];
}

// Response interceptor — handle 401 with token refresh
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        }).then((token) => {
          originalRequest.headers.Authorization = `Bearer ${token}`;
          return api(originalRequest);
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      const { refreshToken, updateTokens, logout } = useAuthStore.getState();

      if (!refreshToken) {
        logout();
        window.location.href = '/login';
        return Promise.reject(error);
      }

      try {
        const { data } = await axios.post<{
          accessToken: string;
          refreshToken: string;
        }>(`${BASE_URL}/api/admin/auth/refresh`, { refreshToken });

        updateTokens(data.accessToken, data.refreshToken);
        processQueue(null, data.accessToken);
        originalRequest.headers.Authorization = `Bearer ${data.accessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError, null);
        logout();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  }
);

// ── Auth ──────────────────────────────────────────────────────────────────────

export const adminLogin = (phone: string, password: string) =>
  api.post<{ accessToken: string; refreshToken: string; admin: Admin }>(
    '/admin/auth/login',
    { phone, password }
  );

export const adminLogout = (refreshToken: string) =>
  api.post('/admin/auth/logout', { refreshToken });

// ── Stats ─────────────────────────────────────────────────────────────────────

export const getPlatformStats = () =>
  api.get<PlatformStats>('/admin/stats');

// ── Orders ────────────────────────────────────────────────────────────────────

export const getAdminOrders = (params: {
  status?: OrderStatus;
  search?: string;
  page?: number;
  limit?: number;
  from?: string;
  to?: string;
  merchantId?: string;
}) => api.get<PaginatedResponse<Order>>('/admin/orders', { params });

export const getAdminOrder = (id: string) =>
  api.get<Order>(`/admin/orders/${id}`);

export const updateOrderStatus = (id: string, status: OrderStatus, note?: string) =>
  api.patch<Order>(`/admin/orders/${id}/status`, { status, note });

export const assignDriver = (
  id: string,
  data: { driverName: string; driverNameAr?: string; driverPhone: string }
) => api.patch<Order>(`/admin/orders/${id}/driver`, data);

// ── Merchants ─────────────────────────────────────────────────────────────────

export const getMerchants = (params?: {
  search?: string;
  page?: number;
  limit?: number;
  isActive?: boolean;
}) => api.get<PaginatedResponse<Merchant>>('/admin/merchants', { params });

export const createMerchant = (data: {
  phone: string;
  name: string;
  nameAr?: string;
  password: string;
  role?: UserRole;
}) => api.post<Merchant>('/admin/merchants', data);

export const updateMerchant = (
  id: string,
  data: { name?: string; nameAr?: string; phone?: string }
) => api.patch<Merchant>(`/admin/merchants/${id}`, data);

export const toggleMerchantStatus = (id: string) =>
  api.patch<Merchant>(`/admin/merchants/${id}/status`);

// ── Notifications ─────────────────────────────────────────────────────────

export const sendNotification = (data: {
  merchantId?: string;
  title: string;
  body: string;
}) =>
  api.post<{ sent: number; skipped: number; total?: number; failed?: string[] }>(
    '/admin/notifications/send',
    data,
  );
