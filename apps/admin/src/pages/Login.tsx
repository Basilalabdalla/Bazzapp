import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Eye, EyeOff, Phone, Lock, Zap } from 'lucide-react';
import { useMutation } from '@tanstack/react-query';
import toast from 'react-hot-toast';
import { adminLogin } from '../lib/api';
import { useAuthStore } from '../store/auth';

export default function Login() {
  const navigate = useNavigate();
  const { setAuth, admin } = useAuthStore();

  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    document.title = 'Login — BazZ Admin';
    if (admin) navigate('/dashboard', { replace: true });
  }, [admin, navigate]);

  const mutation = useMutation({
    mutationFn: () => adminLogin(phone, password),
    onSuccess: ({ data }) => {
      setAuth(data.admin, data.accessToken, data.refreshToken);
      toast.success(`Welcome back, ${data.admin.name}`);
      navigate('/dashboard', { replace: true });
    },
    onError: (err: unknown) => {
      const msg =
        (err as { response?: { data?: { error?: string } } })?.response?.data?.error ||
        'Invalid credentials. Please try again.';
      setError(msg);
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    if (!phone.trim()) { setError('Phone number is required'); return; }
    if (!/^\d{10}$/.test(phone.trim())) { setError('Phone number must be exactly 10 digits'); return; }
    if (!password.trim()) { setError('Password is required'); return; }
    mutation.mutate();
  };

  return (
    <div
      className="min-h-screen flex"
      style={{ background: '#F5F7FA' }}
    >
      {/* Left panel — Navy brand side */}
      <div
        className="hidden lg:flex flex-col justify-between p-12 relative overflow-hidden"
        style={{ width: 420, background: '#1A3C6E', flexShrink: 0 }}
      >
        {/* Grid bg */}
        <div className="absolute inset-0 grid-bg pointer-events-none" />

        {/* Logo */}
        <div className="relative flex items-center gap-3">
          <div
            className="rounded-xl p-2.5"
            style={{ background: 'rgba(255,215,0,0.15)' }}
          >
            <Zap size={22} fill="#FFD700" style={{ color: '#FFD700' }} />
          </div>
          <span
            className="text-3xl font-extrabold tracking-tight"
            style={{ fontFamily: 'Syne, sans-serif', color: '#FFD700' }}
          >
            BazZ
          </span>
        </div>

        {/* Tagline */}
        <div className="relative">
          <h2
            className="text-3xl font-bold mb-3"
            style={{ color: '#FFFFFF', fontFamily: 'Syne, sans-serif', lineHeight: 1.3 }}
          >
            Jordan's Delivery Platform
          </h2>
          <p style={{ color: 'rgba(255,255,255,0.55)', fontSize: 15 }}>
            Manage merchants, track orders, and monitor your delivery operations in real time.
          </p>
        </div>

        {/* Footer */}
        <p className="relative text-xs" style={{ color: 'rgba(255,255,255,0.3)' }}>
          BazZ Platform © 2025
        </p>
      </div>

      {/* Right panel — Login form */}
      <div className="flex-1 flex items-center justify-center p-6">
        <div
          className="w-full rounded-2xl border slide-in"
          style={{
            maxWidth: 420,
            background: '#FFFFFF',
            borderColor: '#E2E8F0',
            padding: 40,
            boxShadow: '0 4px 24px rgba(26,60,110,0.08)',
          }}
        >
          {/* Mobile logo */}
          <div className="flex lg:hidden items-center gap-2 mb-8">
            <div
              className="rounded-lg p-1.5"
              style={{ background: 'rgba(26,60,110,0.08)' }}
            >
              <Zap size={18} fill="#1A3C6E" style={{ color: '#1A3C6E' }} />
            </div>
            <span
              className="text-2xl font-extrabold"
              style={{ fontFamily: 'Syne, sans-serif', color: '#1A3C6E' }}
            >
              BazZ
            </span>
          </div>

          <div className="mb-8">
            <h1
              className="text-2xl font-bold mb-1"
              style={{ color: '#1A202C', fontFamily: 'Syne, sans-serif' }}
            >
              Admin Console
            </h1>
            <p className="text-sm" style={{ color: '#64748B' }}>
              Sign in to manage your platform
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Phone */}
            <div>
              <label
                className="block text-xs font-semibold mb-1.5"
                style={{ color: '#1A3C6E' }}
              >
                Phone Number
              </label>
              <div className="relative">
                <Phone
                  size={15}
                  className="absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none"
                  style={{ color: '#94A3B8' }}
                />
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => { setPhone(e.target.value); setError(''); }}
                  placeholder="07XXXXXXXX"
                  autoComplete="username"
                  className="w-full pl-9 pr-3 font-mono"
                  style={{
                    height: 48,
                    fontSize: 14,
                    borderColor: error ? '#E53935' : '#E2E8F0',
                    color: '#1A202C',
                  }}
                />
              </div>
            </div>

            {/* Password */}
            <div>
              <label
                className="block text-xs font-semibold mb-1.5"
                style={{ color: '#1A3C6E' }}
              >
                Password
              </label>
              <div className="relative">
                <Lock
                  size={15}
                  className="absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none"
                  style={{ color: '#94A3B8' }}
                />
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => { setPassword(e.target.value); setError(''); }}
                  placeholder="Your password"
                  autoComplete="current-password"
                  className="w-full pl-9 pr-10"
                  style={{
                    height: 48,
                    fontSize: 14,
                    borderColor: error ? '#E53935' : '#E2E8F0',
                    color: '#1A202C',
                  }}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2"
                  style={{ color: '#94A3B8' }}
                >
                  {showPassword ? <EyeOff size={15} /> : <Eye size={15} />}
                </button>
              </div>
            </div>

            {/* Error */}
            {error && (
              <div
                className="rounded-lg px-3 py-2.5 text-sm"
                style={{
                  background: 'rgba(229,57,53,0.06)',
                  color: '#E53935',
                  border: '1px solid rgba(229,57,53,0.2)',
                }}
              >
                {error}
              </div>
            )}

            {/* Submit */}
            <button
              type="submit"
              disabled={mutation.isPending}
              className="w-full rounded-xl text-sm font-bold flex items-center justify-center gap-2 transition-all mt-2"
              style={{
                height: 48,
                background: mutation.isPending ? '#2D5A9E' : '#1A3C6E',
                color: '#FFFFFF',
                fontFamily: 'Inter, Syne, sans-serif',
                fontSize: 15,
                border: 'none',
                cursor: mutation.isPending ? 'not-allowed' : 'pointer',
              }}
              onMouseEnter={(e) => {
                if (!mutation.isPending)
                  (e.currentTarget as HTMLButtonElement).style.background = '#153064';
              }}
              onMouseLeave={(e) => {
                if (!mutation.isPending)
                  (e.currentTarget as HTMLButtonElement).style.background = '#1A3C6E';
              }}
            >
              {mutation.isPending ? (
                <>
                  <div
                    className="w-4 h-4 rounded-full border-2 animate-spin"
                    style={{ borderColor: 'rgba(255,255,255,0.3)', borderTopColor: '#FFFFFF' }}
                  />
                  Signing in...
                </>
              ) : (
                'Sign In'
              )}
            </button>
          </form>

          <p className="text-center text-xs mt-8" style={{ color: '#CBD5E0' }}>
            BazZ Platform © 2025
          </p>
        </div>
      </div>
    </div>
  );
}
