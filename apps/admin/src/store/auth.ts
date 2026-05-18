import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { Admin } from '../types';

interface AuthState {
  admin: Admin | null;
  accessToken: string | null;
  refreshToken: string | null;
  setAuth: (admin: Admin, accessToken: string, refreshToken: string) => void;
  updateTokens: (accessToken: string, refreshToken: string) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      admin: null,
      accessToken: null,
      refreshToken: null,
      setAuth: (admin, accessToken, refreshToken) =>
        set({ admin, accessToken, refreshToken }),
      updateTokens: (accessToken, refreshToken) =>
        set({ accessToken, refreshToken }),
      logout: () => set({ admin: null, accessToken: null, refreshToken: null }),
    }),
    {
      name: 'bazz-admin-auth',
    }
  )
);
