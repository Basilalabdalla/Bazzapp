import { useState } from 'react';
import { X, UserCheck, Phone } from 'lucide-react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import toast from 'react-hot-toast';
import { assignDriver } from '../lib/api';
import type { Order } from '../types';

interface AssignDriverModalProps {
  order: Order;
  onClose: () => void;
}

export function AssignDriverModal({ order, onClose }: AssignDriverModalProps) {
  const queryClient = useQueryClient();
  const [form, setForm] = useState({
    driverName: order.driverName || '',
    driverNameAr: order.driverNameAr || '',
    driverPhone: order.driverPhone || '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const mutation = useMutation({
    mutationFn: () => assignDriver(order.id, form),
    onSuccess: () => {
      toast.success('Driver assigned successfully');
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      queryClient.invalidateQueries({ queryKey: ['order', order.id] });
      onClose();
    },
    onError: () => {
      toast.error('Failed to assign driver');
    },
  });

  const validate = () => {
    const errs: Record<string, string> = {};
    if (!form.driverName.trim()) errs.driverName = 'Driver name is required';
    if (!form.driverPhone.trim()) errs.driverPhone = 'Driver phone is required';
    else if (!/^\+?[\d\s\-()]{7,}$/.test(form.driverPhone))
      errs.driverPhone = 'Enter a valid phone number';
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) mutation.mutate();
  };

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
            <UserCheck size={18} style={{ color: '#FFBE0B' }} />
            <h2
              className="text-base font-semibold"
              style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
            >
              Assign Driver
            </h2>
          </div>
          <div className="flex items-center gap-3">
            <span
              className="text-xs font-mono"
              style={{ color: '#FFBE0B' }}
            >
              #{order.orderId}
            </span>
            <button
              onClick={onClose}
              className="rounded-lg p-1 transition-colors"
              style={{ color: '#64748B' }}
            >
              <X size={18} />
            </button>
          </div>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="block text-xs font-medium mb-1.5" style={{ color: '#94A3B8' }}>
              Driver Name (English) <span style={{ color: '#EF4444' }}>*</span>
            </label>
            <input
              type="text"
              value={form.driverName}
              onChange={(e) => setForm({ ...form, driverName: e.target.value })}
              placeholder="e.g. Ahmad Al-Hassan"
              className="w-full px-3 py-2.5 text-sm"
              style={{
                borderColor: errors.driverName ? '#EF4444' : '#252D3F',
              }}
            />
            {errors.driverName && (
              <p className="text-xs mt-1" style={{ color: '#EF4444' }}>
                {errors.driverName}
              </p>
            )}
          </div>

          <div>
            <label className="block text-xs font-medium mb-1.5" style={{ color: '#94A3B8' }}>
              Driver Name (Arabic) <span style={{ color: '#64748B' }}>(optional)</span>
            </label>
            <input
              type="text"
              value={form.driverNameAr}
              onChange={(e) => setForm({ ...form, driverNameAr: e.target.value })}
              placeholder="مثال: أحمد الحسن"
              dir="rtl"
              className="w-full px-3 py-2.5 text-sm"
            />
          </div>

          <div>
            <label className="block text-xs font-medium mb-1.5" style={{ color: '#94A3B8' }}>
              Driver Phone <span style={{ color: '#EF4444' }}>*</span>
            </label>
            <div className="relative">
              <Phone
                size={15}
                className="absolute left-3 top-1/2 -translate-y-1/2"
                style={{ color: '#64748B' }}
              />
              <input
                type="tel"
                value={form.driverPhone}
                onChange={(e) => setForm({ ...form, driverPhone: e.target.value })}
                placeholder="+962 7X XXX XXXX"
                className="w-full pl-9 pr-3 py-2.5 text-sm font-mono"
                style={{
                  borderColor: errors.driverPhone ? '#EF4444' : '#252D3F',
                }}
              />
            </div>
            {errors.driverPhone && (
              <p className="text-xs mt-1" style={{ color: '#EF4444' }}>
                {errors.driverPhone}
              </p>
            )}
          </div>

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
              disabled={mutation.isPending}
              className="flex-1 py-2.5 rounded-lg text-sm font-semibold transition-opacity"
              style={{
                background: '#FFBE0B',
                color: '#000',
                opacity: mutation.isPending ? 0.7 : 1,
                fontFamily: 'Syne, sans-serif',
              }}
            >
              {mutation.isPending ? 'Assigning...' : 'Assign Driver'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
