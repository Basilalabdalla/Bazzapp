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
  { key: 'PENDING',     label: 'Pending',     color: '#94A3B8' },
  { key: 'PROCESSING',  label: 'Processing',  color: '#1A3C6E' },
  { key: 'IN_DELIVERY', label: 'In Delivery', color: '#FFD700' },
  { key: 'DELIVERED',   label: 'Delivered',   color: '#2ECC71' },
  { key: 'CANCELLED',   label: 'Cancelled',   color: '#E53935' },
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
            background: 'rgba(255,215,0,0.08)',
            borderColor: 'rgba(255,215,0,0.35)',
          }}
        >
          <div className="pulse-glow rounded-full p-1">
            <AlertTriangle size={16} style={{ color: '#F59E0B' }} />
          </div>
          <span className="text-sm font-semibold" style={{ color: '#92700A' }}>
            {pendingCount} order{pendingCount !== 1 ? 's' : ''} need{pendingCount === 1 ? 's' : ''} attention
          </span>
          <button
            onClick={() => (window.location.href = '/orders?status=PENDING')}
            className="ml-auto text-xs font-semibold underline underline-offset-2"
            style={{ color: '#1A3C6E' }}
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
              style={{ height: 110, background: '#FFFFFF', borderColor: '#E2E8F0' }}
            />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-5 gap-4">
          <StatsCard label="Today's Orders" value={stats?.orders.today ?? 0}    icon={Truck}        color="#1A3C6E" />
          <StatsCard label="Pending"         value={stats?.orders.pending ?? 0}  icon={Clock}        color="#F59E0B" />
          <StatsCard label="In Delivery"     value={stats?.orders.inDelivery ?? 0} icon={Navigation} color="#3B82F6" />
          <StatsCard label="Delivered"       value={stats?.orders.delivered ?? 0} icon={CheckCircle} color="#2ECC71" />
          <StatsCard label="COD Collected"   value={`JD ${(stats?.cod.totalCollected ?? 0).toFixed(2)}`} icon={Banknote} color="#FFD700" />
        </div>
      )}

      {/* Two-column section */}
      <div className="grid grid-cols-5 gap-6">
        {/* Recent Orders (60%) */}
        <div className="col-span-3">
          <div
            className="rounded-xl border overflow-hidden"
            style={{ background: '#FFFFFF', borderColor: '#E2E8F0', boxShadow: '0 1px 3px rgba(0,0,0,0.05)' }}
          >
            <div
              className="flex items-center justify-between px-5 py-4 border-b"
              style={{ borderColor: '#E2E8F0', background: '#FAFBFC' }}
            >
              <h2
                className="text-sm font-bold"
                style={{ fontFamily: 'Inter, Syne, sans-serif', color: '#1A202C' }}
              >
                Recent Orders
              </h2>
              <button
                onClick={() => refetchStats()}
                className="rounded-lg p-1.5 transition-colors hover:bg-gray-100"
                style={{ color: '#94A3B8' }}
              >
                <RefreshCw size={14} />
              </button>
            </div>

            {ordersLoading ? (
              <div className="p-6 space-y-3">
                {Array.from({ length: 5 }).map((_, i) => (
                  <div key={i} className="h-10 rounded-lg animate-pulse" style={{ background: '#F5F7FA' }} />
                ))}
              </div>
            ) : recentOrders?.data.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-16">
                <Package size={40} style={{ color: '#E2E8F0' }} />
                <p className="text-sm mt-3" style={{ color: '#94A3B8' }}>No orders yet</p>
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
            style={{ background: '#FFFFFF', borderColor: '#E2E8F0', boxShadow: '0 1px 3px rgba(0,0,0,0.05)' }}
          >
            <h2
              className="text-sm font-bold mb-4"
              style={{ fontFamily: 'Inter, Syne, sans-serif', color: '#1A202C' }}
            >
              Order Breakdown
            </h2>
            {statsLoading ? (
              <div className="space-y-3">
                {Array.from({ length: 5 }).map((_, i) => (
                  <div key={i} className="h-8 rounded animate-pulse" style={{ background: '#F5F7FA' }} />
                ))}
              </div>
            ) : (
              <div className="space-y-3">
                {STATUS_LIST.map(({ key, label, color }) => {
                  const count =
                    key === 'PENDING'     ? stats?.orders.pending    ?? 0 :
                    key === 'PROCESSING'  ? stats?.orders.processing ?? 0 :
                    key === 'IN_DELIVERY' ? stats?.orders.inDelivery ?? 0 :
                    key === 'DELIVERED'   ? stats?.orders.delivered  ?? 0 :
                                           stats?.orders.cancelled  ?? 0;
                  const pct = getPercent(count);
                  return (
                    <div key={key}>
                      <div className="flex items-center justify-between mb-1.5">
                        <span className="text-xs font-medium" style={{ color: '#64748B' }}>{label}</span>
                        <span className="text-xs font-mono font-semibold" style={{ color }}>
                          {count} · {pct}%
                        </span>
                      </div>
                      <div className="h-1.5 rounded-full overflow-hidden" style={{ background: '#F1F5F9' }}>
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
            style={{ background: '#FFFFFF', borderColor: '#E2E8F0', boxShadow: '0 1px 3px rgba(0,0,0,0.05)' }}
          >
            <h2
              className="text-sm font-bold mb-4"
              style={{ fontFamily: 'Inter, Syne, sans-serif', color: '#1A202C' }}
            >
              Merchant Overview
            </h2>
            <div className="grid grid-cols-2 gap-3">
              <div className="rounded-xl p-4 text-center" style={{ background: '#F5F7FA', border: '1px solid #E2E8F0' }}>
                <Store size={18} className="mx-auto mb-1.5" style={{ color: '#1A3C6E' }} />
                <p className="text-2xl font-bold" style={{ fontFamily: 'Inter, Syne, sans-serif', color: '#1A202C' }}>
                  {stats?.merchants.total ?? 0}
                </p>
                <p className="text-xs mt-0.5" style={{ color: '#64748B' }}>Total</p>
              </div>
              <div className="rounded-xl p-4 text-center" style={{ background: '#F5F7FA', border: '1px solid #E2E8F0' }}>
                <Store size={18} className="mx-auto mb-1.5" style={{ color: '#2ECC71' }} />
                <p className="text-2xl font-bold" style={{ fontFamily: 'Inter, Syne, sans-serif', color: '#1A202C' }}>
                  {stats?.merchants.active ?? 0}
                </p>
                <p className="text-xs mt-0.5" style={{ color: '#64748B' }}>Active</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {selectedOrderId && (
        <OrderDetailModal orderId={selectedOrderId} onClose={() => setSelectedOrderId(null)} />
      )}
    </div>
  );
}

function RecentOrderRow({ order, onClick }: { order: Order; onClick: () => void }) {
  return (
    <tr
      onClick={onClick}
      className="cursor-pointer"
      style={{ borderLeft: order.status === 'PENDING' ? '3px solid #FFD700' : '3px solid transparent' }}
      onMouseEnter={(e) => { (e.currentTarget as HTMLTableRowElement).style.background = '#F8FAFC'; }}
      onMouseLeave={(e) => { (e.currentTarget as HTMLTableRowElement).style.background = 'transparent'; }}
    >
      <td>
        <span className="text-xs font-mono font-semibold" style={{ color: '#1A3C6E' }}>
          {order.orderId}
        </span>
      </td>
      <td><span className="text-xs font-medium" style={{ color: '#1A202C' }}>{order.merchant?.name || '—'}</span></td>
      <td><span className="text-xs" style={{ color: '#1A202C' }}>{order.recipientName}</span></td>
      <td><span className="text-xs" style={{ color: '#64748B' }}>{order.area}</span></td>
      <td><StatusBadge status={order.status} size="sm" /></td>
      <td><span className="text-xs" style={{ color: '#94A3B8' }}>{formatDistanceToNow(new Date(order.createdAt), { addSuffix: true })}</span></td>
    </tr>
  );
}
