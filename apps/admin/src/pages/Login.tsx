import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Zap, Eye, EyeOff, Phone, Lock } from 'lucide-react';
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
      className="min-h-screen flex items-center justify-center relative"
      style={{ background: '#07080F' }}
    >
      {/* Grid background */}
      <div className="absolute inset-0 grid-bg pointer-events-none" />

      {/* Card */}
      <div
        className="relative w-full rounded-xl border slide-in"
        style={{
          maxWidth: 400,
          background: '#0D1117',
          borderColor: '#252D3F',
          padding: 40,
          margin: '0 16px',
        }}
      >
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-2">
            <div
              className="rounded-xl p-2"
              style={{ background: 'rgba(255,190,11,0.12)' }}
            >
              <Zap size={24} fill="#FFBE0B" style={{ color: '#FFBE0B' }} />
            </div>
            <span
              className="text-4xl font-extrabold"
              style={{ fontFamily: 'Syne, sans-serif', color: '#FFBE0B' }}
            >
              BazZ
            </span>
          </div>
          <p
            className="text-sm"
            style={{ color: '#64748B', fontFamily: 'Outfit, sans-serif' }}
          >
            Admin Console
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Phone */}
          <div>
            <label
              className="block text-xs font-medium mb-1.5"
              style={{ color: '#94A3B8' }}
            >
              Phone Number
            </label>
            <div className="relative">
              <Phone
                size={15}
                className="absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none"
                style={{ color: '#64748B' }}
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
                  borderColor: error ? '#EF4444' : '#252D3F',
                }}
              />
            </div>
          </div>

          {/* Password */}
          <div>
            <label
              className="block text-xs font-medium mb-1.5"
              style={{ color: '#94A3B8' }}
            >
              Password
            </label>
            <div className="relative">
              <Lock
                size={15}
                className="absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none"
                style={{ color: '#64748B' }}
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
                  borderColor: error ? '#EF4444' : '#252D3F',
                }}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2"
                style={{ color: '#64748B' }}
              >
                {showPassword ? <EyeOff size={15} /> : <Eye size={15} />}
              </button>
            </div>
          </div>

          {/* Error */}
          {error && (
            <div
              className="rounded-lg px-3 py-2.5 text-sm"
              style={{ background: 'rgba(239,68,68,0.1)', color: '#EF4444', border: '1px solid rgba(239,68,68,0.2)' }}
            >
              {error}
            </div>
          )}

          {/* Submit */}
          <button
            type="submit"
            disabled={mutation.isPending}
            className="w-full rounded-lg text-sm font-semibold flex items-center justify-center gap-2 transition-opacity mt-6"
            style={{
              height: 48,
              background: '#FFBE0B',
              color: '#000',
              fontFamily: 'Syne, sans-serif',
              fontSize: 15,
              opacity: mutation.isPending ? 0.75 : 1,
            }}
          >
            {mutation.isPending ? (
              <>
                <div
                  className="w-4 h-4 rounded-full border-2 border-t-transparent animate-spin"
                  style={{ borderColor: '#000', borderTopColor: 'transparent' }}
                />
                Signing in...
              </>
            ) : (
              'Sign In'
            )}
          </button>
        </form>

        {/* Footer */}
        <p
          className="text-center text-xs mt-8"
          style={{ color: '#3a4557' }}
        >
          BazZ Platform © 2025
        </p>
      </div>
    </div>
  );
}
