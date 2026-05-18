import { useEffect, useState } from 'react';
import {
  Truck,
  Clock,
  Navigation,
  CheckCircle,
  Banknote,
  RefreshCw,
  AlertTriangle,
  Package,
  Store,
} from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { formatDistanceToNow } from 'date-fns';
import { getPlatformStats, getAdminOrders } from '../lib/api';
import { StatsCard } from '../components/StatsCard';
import { StatusBadge } from '../components/StatusBadge';
import { OrderDetailModal } from '../components/OrderDetailModal';
import type { Order, OrderStatus } from '../types';

const STATUS_LIST: { key: OrderStatus; label: string; color: string }[] = [
  { key: 'PENDING', label: 'Pending', color: '#94A3B8' },
  { key: 'PROCESSING', label: 'Processing', color: '#F59E0B' },
  { key: 'IN_DELIVERY', label: 'In Delivery', color: '#3B82F6' },
  { key: 'DELIVERED', label: 'Delivered', color: '#22C55E' },
  { key: 'CANCELLED', label: 'Cancelled', color: '#EF4444' },
];

export default function Dashboard() {
  const [selectedOrderId, setSelectedOrderId] = useState<string | null>(null);

  useEffect(() => {
    document.title = 'Dashboard — BazZ Admin';
  }, []);

  const {
    data: stats,
    isLoading: statsLoading,
    refetch: refetchStats,
  } = useQuery({
    queryKey: ['stats'],
    queryFn: () => getPlatformStats().then((r) => r.data),
    refetchInterval: 60000,
  });

  const { data: recentOrders, isLoading: ordersLoading } = useQuery({
    queryKey: ['orders', { limit: 10, page: 1 }],
    queryFn: () => getAdminOrders({ limit: 10, page: 1 }).then((r) => r.data),
    refetchInterval: 30000,
  });

  const pendingCount = stats?.orders.pending ?? 0;
  const totalOrders = stats?.orders.total ?? 0;

  const getPercent = (count: number) =>
    totalOrders > 0 ? Math.round((count / totalOrders) * 100) : 0;

  return (
    <div className="p-6 space-y-6">
      {/* Pending attention banner */}
      {pendingCount > 0 && (
        <div
          className="flex items-center gap-3 rounded-xl px-4 py-3 border"
          style={{
            background: 'rgba(255,190,11,0.07)',
            borderColor: 'rgba(255,190,11,0.25)',
          }}
        >
          <div className="pulse-glow rounded-full p-1">
            <AlertTriangle size={16} style={{ color: '#FFBE0B' }} />
          </div>
          <span className="text-sm font-medium" style={{ color: '#FFBE0B' }}>
            {pendingCount} order{pendingCount !== 1 ? 's' : ''} need{pendingCount === 1 ? 's' : ''} attention
          </span>
          <button
            onClick={() => (window.location.href = '/orders?status=PENDING')}
            className="ml-auto text-xs font-medium underline underline-offset-2"
            style={{ color: '#FFBE0B' }}
          >
            View all →
          </button>
        </div>
      )}

      {/* Stats row */}
      {statsLoading ? (
        <div className="grid grid-cols-5 gap-4">
          {Array.from({ length: 5 }).map((_, i) => (
            <div
              key={i}
              className="rounded-xl border animate-pulse"
              style={{ height: 110, background: '#0D1117', borderColor: '#252D3F' }}
            />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-5 gap-4">
          <StatsCard
            label="Today's Orders"
            value={stats?.orders.today ?? 0}
            icon={Truck}
            color="#FFBE0B"
          />
          <StatsCard
            label="Pending"
            value={stats?.orders.pending ?? 0}
            icon={Clock}
            color="#64748B"
          />
          <StatsCard
            label="In Delivery"
            value={stats?.orders.inDelivery ?? 0}
            icon={Navigation}
            color="#3B82F6"
          />
          <StatsCard
            label="Delivered"
            value={stats?.orders.delivered ?? 0}
            icon={CheckCircle}
            color="#22C55E"
          />
          <StatsCard
            label="COD Collected"
            value={`JD ${(stats?.cod.totalCollected ?? 0).toFixed(2)}`}
            icon={Banknote}
            color="#FFBE0B"
          />
        </div>
      )}

      {/* Two-column section */}
      <div className="grid grid-cols-5 gap-6">
        {/* Recent Orders (60%) */}
        <div className="col-span-3">
          <div
            className="rounded-xl border overflow-hidden"
            style={{ background: '#0D1117', borderColor: '#252D3F' }}
          >
            <div
              className="flex items-center justify-between px-5 py-4 border-b"
              style={{ borderColor: '#252D3F' }}
            >
              <h2
                className="text-sm font-semibold"
                style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
              >
                Recent Orders
              </h2>
              <button
                onClick={() => refetchStats()}
                className="rounded-lg p-1.5 transition-colors"
                style={{ color: '#64748B' }}
              >
                <RefreshCw size={14} />
              </button>
            </div>

            {ordersLoading ? (
              <div className="p-6 space-y-3">
                {Array.from({ length: 5 }).map((_, i) => (
                  <div
                    key={i}
                    className="h-10 rounded-lg animate-pulse"
                    style={{ background: '#141920' }}
                  />
                ))}
              </div>
            ) : recentOrders?.data.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-16">
                <Package size={40} style={{ color: '#252D3F' }} />
                <p className="text-sm mt-3" style={{ color: '#64748B' }}>
                  No orders yet
                </p>
              </div>
            ) : (
              <table>
                <thead>
                  <tr>
                    <th>Order ID</th>
                    <th>Merchant</th>
                    <th>Recipient</th>
                    <th>Area</th>
                    <th>Status</th>
                    <th>Time</th>
                  </tr>
                </thead>
                <tbody>
                  {recentOrders?.data.map((order) => (
                    <RecentOrderRow
                      key={order.id}
                      order={order}
                      onClick={() => setSelectedOrderId(order.id)}
                    />
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>

        {/* Right panel (40%) */}
        <div className="col-span-2 space-y-4">
          {/* Order Breakdown */}
          <div
            className="rounded-xl border p-5"
            style={{ background: '#0D1117', borderColor: '#252D3F' }}
          >
            <h2
              className="text-sm font-semibold mb-4"
              style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
            >
              Order Breakdown
            </h2>
            {statsLoading ? (
              <div className="space-y-3">
                {Array.from({ length: 5 }).map((_, i) => (
                  <div key={i} className="h-8 rounded animate-pulse" style={{ background: '#141920' }} />
                ))}
              </div>
            ) : (
              <div className="space-y-3">
                {STATUS_LIST.map(({ key, label, color }) => {
                  const count =
                    key === 'PENDING'
                      ? stats?.orders.pending ?? 0
                      : key === 'PROCESSING'
                      ? stats?.orders.processing ?? 0
                      : key === 'IN_DELIVERY'
                      ? stats?.orders.inDelivery ?? 0
                      : key === 'DELIVERED'
                      ? stats?.orders.delivered ?? 0
                      : stats?.orders.cancelled ?? 0;
                  const pct = getPercent(count);

                  return (
                    <div key={key}>
                      <div className="flex items-center justify-between mb-1.5">
                        <span className="text-xs" style={{ color: '#94A3B8' }}>
                          {label}
                        </span>
                        <span className="text-xs font-mono" style={{ color }}>
                          {count} · {pct}%
                        </span>
                      </div>
                      <div
                        className="h-1.5 rounded-full overflow-hidden"
                        style={{ background: '#1C2333' }}
                      >
                        <div
                          className="h-full rounded-full transition-all duration-500"
                          style={{ width: `${pct}%`, background: color }}
                        />
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          {/* Merchant Stats */}
          <div
            className="rounded-xl border p-5"
            style={{ background: '#0D1117', borderColor: '#252D3F' }}
          >
            <h2
              className="text-sm font-semibold mb-4"
              style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
            >
              Merchant Overview
            </h2>
            <div className="grid grid-cols-2 gap-3">
              <div
                className="rounded-lg p-3 text-center"
                style={{ background: '#141920' }}
              >
                <Store size={18} className="mx-auto mb-1.5" style={{ color: '#FFBE0B' }} />
                <p
                  className="text-2xl font-bold"
                  style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
                >
                  {stats?.merchants.total ?? 0}
                </p>
                <p className="text-xs mt-0.5" style={{ color: '#64748B' }}>
                  Total
                </p>
              </div>
              <div
                className="rounded-lg p-3 text-center"
                style={{ background: '#141920' }}
              >
                <Store size={18} className="mx-auto mb-1.5" style={{ color: '#22C55E' }} />
                <p
                  className="text-2xl font-bold"
                  style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
                >
                  {stats?.merchants.active ?? 0}
                </p>
                <p className="text-xs mt-0.5" style={{ color: '#64748B' }}>
                  Active
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {selectedOrderId && (
        <OrderDetailModal
          orderId={selectedOrderId}
          onClose={() => setSelectedOrderId(null)}
        />
      )}
    </div>
  );
}

function RecentOrderRow({
  order,
  onClick,
}: {
  order: Order;
  onClick: () => void;
}) {
  return (
    <tr
      onClick={onClick}
      className="cursor-pointer"
      style={{ borderLeft: order.status === 'PENDING' ? '2px solid #FFBE0B' : '2px solid transparent' }}
      onMouseEnter={(e) => {
        (e.currentTarget as HTMLTableRowElement).style.background = '#141920';
      }}
      onMouseLeave={(e) => {
        (e.currentTarget as HTMLTableRowElement).style.background = 'transparent';
      }}
    >
      <td>
        <span className="text-xs font-mono" style={{ color: '#FFBE0B' }}>
          {order.orderId}
        </span>
      </td>
      <td>
        <span className="text-xs" style={{ color: '#EDF2FF' }}>
          {order.merchant?.name || '—'}
        </span>
      </td>
      <td>
        <span className="text-xs" style={{ color: '#EDF2FF' }}>
          {order.recipientName}
        </span>
      </td>
      <td>
        <span className="text-xs" style={{ color: '#94A3B8' }}>
          {order.area}
        </span>
      </td>
      <td>
        <StatusBadge status={order.status} size="sm" />
      </td>
      <td>
        <span className="text-xs" style={{ color: '#64748B' }}>
          {formatDistanceToNow(new Date(order.createdAt), { addSuffix: true })}
        </span>
      </td>
    </tr>
  );
}
