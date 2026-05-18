import { useState } from 'react';
import { X, Store, Eye, EyeOff } from 'lucide-react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import toast from 'react-hot-toast';
import { createMerchant, updateMerchant } from '../lib/api';
import type { Merchant, UserRole } from '../types';

interface CreateMerchantModalProps {
  onClose: () => void;
  editMerchant?: Merchant;
}

export function CreateMerchantModal({ onClose, editMerchant }: CreateMerchantModalProps) {
  const queryClient = useQueryClient();
  const isEdit = !!editMerchant;

  const [form, setForm] = useState({
    phone: editMerchant?.phone || '',
    name: editMerchant?.name || '',
    nameAr: editMerchant?.nameAr || '',
    password: '',
    role: (editMerchant?.role || 'MERCHANT') as UserRole,
  });
  const [showPassword, setShowPassword] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const createMutation = useMutation({
    mutationFn: () =>
      createMerchant({
        phone: form.phone,
        name: form.name,
        nameAr: form.nameAr || undefined,
        password: form.password,
        role: form.role,
      }),
    onSuccess: () => {
      toast.success('Merchant created successfully');
      queryClient.invalidateQueries({ queryKey: ['merchants'] });
      onClose();
    },
    onError: (err: unknown) => {
      const msg =
        (err as { response?: { data?: { message?: string } } })?.response?.data?.message ||
        'Failed to create merchant';
      toast.error(msg);
    },
  });

  const editMutation = useMutation({
    mutationFn: () =>
      updateMerchant(editMerchant!.id, {
        name: form.name || undefined,
        nameAr: form.nameAr || undefined,
        phone: form.phone || undefined,
      }),
    onSuccess: () => {
      toast.success('Merchant updated successfully');
      queryClient.invalidateQueries({ queryKey: ['merchants'] });
      onClose();
    },
    onError: () => {
      toast.error('Failed to update merchant');
    },
  });

  const validate = () => {
    const errs: Record<string, string> = {};
    if (!form.phone.trim()) errs.phone = 'Phone is required';
    if (!form.name.trim()) errs.name = 'Name is required';
    if (!isEdit && !form.password.trim()) errs.password = 'Password is required';
    if (!isEdit && form.password.length < 6)
      errs.password = 'Password must be at least 6 characters';
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;
    if (isEdit) editMutation.mutate();
    else createMutation.mutate();
  };

  const isPending = createMutation.isPending || editMutation.isPending;

  const Field = ({
    label,
    name,
    required,
    children,
  }: {
    label: string;
    name: string;
    required?: boolean;
    children: React.ReactNode;
  }) => (
    <div>
      <label className="block text-xs font-medium mb-1.5" style={{ color: '#94A3B8' }}>
        {label}
        {required && <span style={{ color: '#EF4444' }}> *</span>}
        {!required && <span style={{ color: '#64748B' }}> (optional)</span>}
      </label>
      {children}
      {errors[name] && (
        <p className="text-xs mt-1" style={{ color: '#EF4444' }}>
          {errors[name]}
        </p>
      )}
    </div>
  );

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="rounded-xl border w-full max-w-md slide-in"
        style={{ background: '#0D1117', borderColor: '#252D3F' }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div
          className="flex items-center justify-between px-6 py-4 border-b"
          style={{ borderColor: '#252D3F' }}
        >
          <div className="flex items-center gap-2">
            <Store size={18} style={{ color: '#FFBE0B' }} />
            <h2
              className="text-base font-semibold"
              style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
            >
              {isEdit ? 'Edit Merchant' : 'Add Merchant'}
            </h2>
          </div>
          <button onClick={onClose} style={{ color: '#64748B' }}>
            <X size={18} />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <Field label="Phone Number" name="phone" required>
            <input
              type="tel"
              value={form.phone}
              onChange={(e) => setForm({ ...form, phone: e.target.value })}
              placeholder="+962 7X XXX XXXX"
              className="w-full px-3 py-2.5 text-sm font-mono"
              style={{ borderColor: errors.phone ? '#EF4444' : '#252D3F' }}
            />
          </Field>

          <Field label="Name (English)" name="name" required>
            <input
              type="text"
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
              placeholder="e.g. Ahmad's Store"
              className="w-full px-3 py-2.5 text-sm"
              style={{ borderColor: errors.name ? '#EF4444' : '#252D3F' }}
            />
          </Field>

          <Field label="Name (Arabic)" name="nameAr">
            <input
              type="text"
              value={form.nameAr}
              onChange={(e) => setForm({ ...form, nameAr: e.target.value })}
              placeholder="مثال: محل أحمد"
              dir="rtl"
              className="w-full px-3 py-2.5 text-sm"
            />
          </Field>

          {!isEdit && (
            <>
              <Field label="Password" name="password" required>
                <div className="relative">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={form.password}
                    onChange={(e) => setForm({ ...form, password: e.target.value })}
                    placeholder="Min. 6 characters"
                    className="w-full px-3 py-2.5 text-sm pr-10"
                    style={{ borderColor: errors.password ? '#EF4444' : '#252D3F' }}
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
              </Field>

              <Field label="Role" name="role" required>
                <select
                  value={form.role}
                  onChange={(e) => setForm({ ...form, role: e.target.value as UserRole })}
                  className="w-full px-3 py-2.5 text-sm"
                >
                  <option value="MERCHANT">Merchant</option>
                  <option value="ADMIN">Admin</option>
                </select>
              </Field>
            </>
          )}

          <div className="flex gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 py-2.5 rounded-lg text-sm font-medium border transition-colors"
              style={{ borderColor: '#252D3F', color: '#94A3B8', background: 'transparent' }}
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isPending}
              className="flex-1 py-2.5 rounded-lg text-sm font-semibold transition-opacity"
              style={{
                background: '#FFBE0B',
                color: '#000',
                opacity: isPending ? 0.7 : 1,
                fontFamily: 'Syne, sans-serif',
              }}
            >
              {isPending
                ? isEdit
                  ? 'Saving...'
                  : 'Creating...'
                : isEdit
                ? 'Save Changes'
                : 'Create Merchant'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
