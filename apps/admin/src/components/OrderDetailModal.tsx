import { useState } from 'react';
import { X, MapPin, Package, Phone, User, Clock, ChevronDown } from 'lucide-react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { formatDistanceToNow, format } from 'date-fns';
import toast from 'react-hot-toast';
import { getAdminOrder, updateOrderStatus } from '../lib/api';
import { StatusBadge } from './StatusBadge';
import type { Order, OrderStatus } from '../types';

const ALL_STATUSES: OrderStatus[] = [
  'PENDING',
  'PROCESSING',
  'IN_DELIVERY',
  'DELIVERED',
  'CANCELLED',
];

interface OrderDetailModalProps {
  orderId: string;
  onClose: () => void;
}

export function OrderDetailModal({ orderId, onClose }: OrderDetailModalProps) {
  const queryClient = useQueryClient();
  const [selectedStatus, setSelectedStatus] = useState<OrderStatus | ''>('');
  const [statusNote, setStatusNote] = useState('');

  const { data: order, isLoading } = useQuery({
    queryKey: ['order', orderId],
    queryFn: () => getAdminOrder(orderId).then((r) => r.data),
  });

  const statusMutation = useMutation({
    mutationFn: () =>
      updateOrderStatus(orderId, selectedStatus as OrderStatus, statusNote || undefined),
    onSuccess: () => {
      toast.success('Status updated');
      queryClient.invalidateQueries({ queryKey: ['order', orderId] });
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      queryClient.invalidateQueries({ queryKey: ['stats'] });
      setSelectedStatus('');
      setStatusNote('');
    },
    onError: () => {
      toast.error('Failed to update status');
    },
  });

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="rounded-xl border w-full max-w-4xl max-h-[90vh] overflow-hidden flex flex-col slide-in"
        style={{ background: '#0D1117', borderColor: '#252D3F' }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div
          className="flex items-center justify-between px-6 py-4 border-b flex-shrink-0"
          style={{ borderColor: '#252D3F' }}
        >
          <div className="flex items-center gap-3">
            <Package size={18} style={{ color: '#FFBE0B' }} />
            <h2
              className="text-base font-semibold"
              style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
            >
              Order Details
            </h2>
            {order && (
              <span
                className="text-sm font-mono"
                style={{ color: '#FFBE0B' }}
              >
                #{order.orderId}
              </span>
            )}
          </div>
          <button onClick={onClose} style={{ color: '#64748B' }}>
            <X size={18} />
          </button>
        </div>

        {isLoading ? (
          <div className="flex items-center justify-center p-20">
            <div
              className="w-8 h-8 rounded-full border-2 border-t-transparent animate-spin"
              style={{ borderColor: '#FFBE0B', borderTopColor: 'transparent' }}
            />
          </div>
        ) : order ? (
          <div className="flex overflow-hidden flex-1 min-h-0">
            {/* Left: Order Info */}
            <div
              className="w-1/2 p-6 overflow-y-auto border-r space-y-5"
              style={{ borderColor: '#252D3F' }}
            >
              <OrderInfoSection order={order} />
            </div>

            {/* Right: Status + History */}
            <div className="w-1/2 p-6 overflow-y-auto space-y-5">
              {/* Status Update */}
              <div>
                <h3
                  className="text-xs uppercase tracking-widest mb-3"
                  style={{ color: '#64748B' }}
                >
                  Update Status
                </h3>
                <div className="space-y-3">
                  <div className="relative">
                    <select
                      value={selectedStatus}
                      onChange={(e) => setSelectedStatus(e.target.value as OrderStatus)}
                      className="w-full px-3 py-2.5 text-sm appearance-none pr-8"
                    >
                      <option value="">— Select new status —</option>
                      {ALL_STATUSES.filter((s) => s !== order.status).map((s) => (
                        <option key={s} value={s}>
                          {s.replace('_', ' ')}
                        </option>
                      ))}
                    </select>
                    <ChevronDown
                      size={14}
                      className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none"
                      style={{ color: '#64748B' }}
                    />
                  </div>
                  {selectedStatus && (
                    <>
                      <input
                        type="text"
                        value={statusNote}
                        onChange={(e) => setStatusNote(e.target.value)}
                        placeholder="Note (optional)"
                        className="w-full px-3 py-2.5 text-sm"
                      />
                      <button
                        onClick={() => statusMutation.mutate()}
                        disabled={statusMutation.isPending}
                        className="w-full py-2.5 rounded-lg text-sm font-semibold transition-opacity"
                        style={{
                          background: '#FFBE0B',
                          color: '#000',
                          opacity: statusMutation.isPending ? 0.7 : 1,
                          fontFamily: 'Syne, sans-serif',
                        }}
                      >
                        {statusMutation.isPending ? 'Updating...' : 'Update Status'}
                      </button>
                    </>
                  )}
                </div>
              </div>

              {/* Current Status */}
              <div
                className="rounded-lg p-3 border"
                style={{ borderColor: '#252D3F', background: '#141920' }}
              >
                <p className="text-xs mb-2" style={{ color: '#64748B' }}>
                  Current Status
                </p>
                <StatusBadge status={order.status} />
              </div>

              {/* Status History */}
              <div>
                <h3
                  className="text-xs uppercase tracking-widest mb-4"
                  style={{ color: '#64748B' }}
                >
                  Status History
                </h3>
                <div className="space-y-0">
                  {[...order.statusHistory].reverse().map((hist, idx) => (
                    <div key={hist.id} className="relative pl-5">
                      {/* Timeline line */}
                      {idx < order.statusHistory.length - 1 && (
                        <div
                          className="absolute left-[7px] top-5 bottom-0 w-px"
                          style={{ background: '#252D3F' }}
                        />
                      )}
                      {/* Dot */}
                      <div
                        className="absolute left-0 top-1.5 w-3.5 h-3.5 rounded-full border-2 flex items-center justify-center"
                        style={{ borderColor: '#252D3F', background: '#0D1117' }}
                      >
                        <div
                          className="w-1.5 h-1.5 rounded-full"
                          style={{ background: idx === 0 ? '#FFBE0B' : '#252D3F' }}
                        />
                      </div>
                      <div className="pb-5">
                        <StatusBadge status={hist.status} size="sm" />
                        {hist.note && (
                          <p className="text-xs mt-1" style={{ color: '#94A3B8' }}>
                            {hist.note}
                          </p>
                        )}
                        <p className="text-xs mt-1 flex items-center gap-1" style={{ color: '#64748B' }}>
                          <Clock size={10} />
                          {format(new Date(hist.createdAt), 'MMM d, yyyy HH:mm')}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        ) : (
          <div className="flex items-center justify-center p-20">
            <p style={{ color: '#64748B' }}>Order not found</p>
          </div>
        )}
      </div>
    </div>
  );
}

function InfoRow({ icon: Icon, label, value }: { icon: React.ElementType; label: string; value?: string | null }) {
  if (!value) return null;
  return (
    <div className="flex items-start gap-3">
      <div className="mt-0.5">
        <Icon size={14} style={{ color: '#64748B' }} />
      </div>
      <div>
        <p className="text-xs" style={{ color: '#64748B' }}>{label}</p>
        <p className="text-sm mt-0.5" style={{ color: '#EDF2FF' }}>{value}</p>
      </div>
    </div>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div>
      <h3 className="text-xs uppercase tracking-widest mb-3" style={{ color: '#64748B' }}>
        {title}
      </h3>
      <div
        className="rounded-lg border p-4 space-y-3"
        style={{ borderColor: '#252D3F', background: '#141920' }}
      >
        {children}
      </div>
    </div>
  );
}

function OrderInfoSection({ order }: { order: Order }) {
  return (
    <>
      <Section title="Merchant">
        <InfoRow icon={User} label="Name" value={order.merchant?.name} />
        <InfoRow icon={Phone} label="Phone" value={order.merchant?.phone} />
      </Section>

      <Section title="Recipient">
        <InfoRow icon={User} label="Name" value={order.recipientName} />
        <InfoRow icon={Phone} label="Phone" value={order.recipientPhone} />
        <InfoRow icon={MapPin} label="Address" value={order.address} />
        <InfoRow
          icon={MapPin}
          label="Area / Governorate"
          value={`${order.area}, ${order.governorate}`}
        />
      </Section>

      <Section title="Package">
        <InfoRow icon={Package} label="Size" value={order.packageSize} />
        <InfoRow icon={Package} label="Fragile" value={order.isFragile ? 'Yes' : 'No'} />
        <InfoRow
          icon={Package}
          label="Cash on Delivery"
          value={order.isCod ? `JD ${order.codAmount.toFixed(2)}` : 'No'}
        />
        {order.notes && <InfoRow icon={Package} label="Notes" value={order.notes} />}
      </Section>

      {order.driverName && (
        <Section title="Driver">
          <InfoRow icon={User} label="Name" value={order.driverName} />
          {order.driverNameAr && (
            <InfoRow icon={User} label="Name (Arabic)" value={order.driverNameAr} />
          )}
          <InfoRow icon={Phone} label="Phone" value={order.driverPhone} />
        </Section>
      )}

      <div className="text-xs space-y-1" style={{ color: '#64748B' }}>
        <p>
          Created{' '}
          <span style={{ color: '#94A3B8' }}>
            {format(new Date(order.createdAt), 'MMM d, yyyy HH:mm')}
          </span>
          {' · '}
          {formatDistanceToNow(new Date(order.createdAt), { addSuffix: true })}
        </p>
        <p>
          Updated{' '}
          <span style={{ color: '#94A3B8' }}>
            {format(new Date(order.updatedAt), 'MMM d, yyyy HH:mm')}
          </span>
        </p>
      </div>
    </>
  );
}
