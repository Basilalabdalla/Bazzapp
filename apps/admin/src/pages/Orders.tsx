import { useEffect, useState, useCallback } from 'react';
import {
  Search,
  RefreshCw,
  UserCheck,
  Eye,
  Package,
  AlertCircle,
  ChevronLeft,
  ChevronRight,
  Gem,
} from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { formatDistanceToNow } from 'date-fns';
import { useSearchParams } from 'react-router-dom';
import { getAdminOrders, getMerchants } from '../lib/api';
import { StatusBadge } from '../components/StatusBadge';
import { AssignDriverModal } from '../components/AssignDriverModal';
import { OrderDetailModal } from '../components/OrderDetailModal';
import type { Order, OrderStatus } from '../types';

type TabStatus = OrderStatus | 'ALL';

const TABS: { key: TabStatus; label: string }[] = [
  { key: 'ALL', label: 'All' },
  { key: 'PENDING', label: 'Pending' },
  { key: 'PROCESSING', label: 'Processing' },
  { key: 'IN_DELIVERY', label: 'In Delivery' },
  { key: 'DELIVERED', label: 'Delivered' },
  { key: 'CANCELLED', label: 'Cancelled' },
];

const PACKAGE_COLORS: Record<string, string> = {
  SMALL: '#22C55E',
  MEDIUM: '#F59E0B',
  LARGE: '#3B82F6',
};

export default function Orders() {
  const [searchParams, setSearchParams] = useSearchParams();

  const [activeTab, setActiveTab] = useState<TabStatus>(
    (searchParams.get('status') as TabStatus) || 'ALL'
  );
  const [search, setSearch] = useState('');
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [merchantId, setMerchantId] = useState('');
  const [page, setPage] = useState(1);

  const [assignOrder, setAssignOrder] = useState<Order | null>(null);
  const [detailOrderId, setDetailOrderId] = useState<string | null>(null);

  useEffect(() => {
    document.title = 'Orders — BazZ Admin';
  }, []);

  const queryParams = {
    status: activeTab !== 'ALL' ? activeTab : undefined,
    search: search || undefined,
    from: from || undefined,
    to: to || undefined,
    merchantId: merchantId || undefined,
    page,
    limit: 20,
  };

  const {
    data,
    isLoading,
    isFetching,
    isError,
    refetch,
  } = useQuery({
    queryKey: ['orders', queryParams],
    queryFn: () => getAdminOrders(queryParams).then((r) => r.data),
    placeholderData: (prev) => prev,
  });

  const { data: merchantsData } = useQuery({
    queryKey: ['merchants', { limit: 100 }],
    queryFn: () => getMerchants({ limit: 100 }).then((r) => r.data),
  });

  const handleTabChange = useCallback(
    (tab: TabStatus) => {
      setActiveTab(tab);
      setPage(1);
      if (tab !== 'ALL') {
        setSearchParams({ status: tab });
      } else {
        setSearchParams({});
      }
    },
    [setSearchParams]
  );

  const orders = data?.data ?? [];
  const meta = data?.meta;

  return (
    <div className="p-6 space-y-4">
      {/* Filter bar */}
      <div
        className="rounded-xl border p-4 space-y-3"
        style={{ background: '#0D1117', borderColor: '#252D3F' }}
      >
        {/* Status tabs */}
        <div className="flex items-center gap-1 border-b pb-3" style={{ borderColor: '#252D3F' }}>
          {TABS.map((tab) => {
            const isActive = activeTab === tab.key;
            return (
              <button
                key={tab.key}
                onClick={() => handleTabChange(tab.key)}
                className="px-3 py-1.5 text-xs font-medium rounded-md transition-colors relative"
                style={{
                  color: isActive ? '#FFBE0B' : '#64748B',
                  background: isActive ? 'rgba(255,190,11,0.08)' : 'transparent',
                }}
              >
                {tab.label}
                {isActive && (
                  <span
                    className="absolute bottom-0 left-0 right-0 h-0.5 rounded-full"
                    style={{ background: '#FFBE0B' }}
                  />
                )}
              </button>
            );
          })}
          <div className="ml-auto flex items-center gap-2">
            <button
              onClick={() => refetch()}
              disabled={isFetching}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium border transition-colors"
              style={{ borderColor: '#252D3F', color: '#64748B', background: 'transparent' }}
            >
              <RefreshCw
                size={12}
                className={isFetching ? 'animate-spin' : ''}
              />
              Refresh
            </button>
          </div>
        </div>

        {/* Filter inputs */}
        <div className="flex items-center gap-3 flex-wrap">
          {/* Search */}
          <div className="relative flex-1 min-w-48">
            <Search
              size={14}
              className="absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none"
              style={{ color: '#64748B' }}
            />
            <input
              type="text"
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(1); }}
              placeholder="Search by order ID, recipient, area..."
              className="w-full pl-8 pr-3 py-2 text-sm"
            />
          </div>

          {/* Date from */}
          <input
            type="date"
            value={from}
            onChange={(e) => { setFrom(e.target.value); setPage(1); }}
            className="px-3 py-2 text-sm"
            style={{ color: from ? '#EDF2FF' : '#64748B' }}
          />
          <span className="text-xs" style={{ color: '#64748B' }}>to</span>
          <input
            type="date"
            value={to}
            onChange={(e) => { setTo(e.target.value); setPage(1); }}
            className="px-3 py-2 text-sm"
            style={{ color: to ? '#EDF2FF' : '#64748B' }}
          />

          {/* Merchant filter */}
          <select
            value={merchantId}
            onChange={(e) => { setMerchantId(e.target.value); setPage(1); }}
            className="px-3 py-2 text-sm min-w-36"
          >
            <option value="">All Merchants</option>
            {merchantsData?.data.map((m) => (
              <option key={m.id} value={m.id}>
                {m.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Table */}
      <div
        className="rounded-xl border overflow-hidden"
        style={{ background: '#0D1117', borderColor: '#252D3F' }}
      >
        {isLoading ? (
          <div className="p-8 space-y-3">
            {Array.from({ length: 8 }).map((_, i) => (
              <div
                key={i}
                className="h-12 rounded-lg animate-pulse"
                style={{ background: '#141920' }}
              />
            ))}
          </div>
        ) : isError ? (
          <div className="flex flex-col items-center justify-center py-20">
            <AlertCircle size={40} style={{ color: '#EF4444' }} />
            <p className="text-sm mt-3 mb-4" style={{ color: '#64748B' }}>
              Failed to load orders
            </p>
            <button
              onClick={() => refetch()}
              className="px-4 py-2 rounded-lg text-sm font-medium"
              style={{ background: '#141920', color: '#EDF2FF', border: '1px solid #252D3F' }}
            >
              Retry
            </button>
          </div>
        ) : orders.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20">
            <Package size={40} style={{ color: '#252D3F' }} />
            <p className="text-sm mt-3" style={{ color: '#64748B' }}>
              No orders found
            </p>
          </div>
        ) : (
          <table>
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Merchant</th>
                <th>Recipient</th>
                <th>Area / Gov</th>
                <th>Package</th>
                <th>COD</th>
                <th>Status</th>
                <th>Driver</th>
                <th>Created</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((order) => (
                <OrderRow
                  key={order.id}
                  order={order}
                  onAssign={() => setAssignOrder(order)}
                  onView={() => setDetailOrderId(order.id)}
                />
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Pagination */}
      {meta && meta.totalPages > 1 && (
        <div className="flex items-center justify-between px-1">
          <span className="text-xs" style={{ color: '#64748B' }}>
            Showing {(meta.page - 1) * meta.limit + 1}–
            {Math.min(meta.page * meta.limit, meta.total)} of {meta.total} orders
          </span>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={meta.page === 1}
              className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs border transition-colors disabled:opacity-40"
              style={{ borderColor: '#252D3F', color: '#94A3B8', background: 'transparent' }}
            >
              <ChevronLeft size={14} />
              Previous
            </button>
            <span className="text-xs font-mono" style={{ color: '#EDF2FF' }}>
              {meta.page} / {meta.totalPages}
            </span>
            <button
              onClick={() => setPage((p) => Math.min(meta.totalPages, p + 1))}
              disabled={meta.page === meta.totalPages}
              className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs border transition-colors disabled:opacity-40"
              style={{ borderColor: '#252D3F', color: '#94A3B8', background: 'transparent' }}
            >
              Next
              <ChevronRight size={14} />
            </button>
          </div>
        </div>
      )}

      {/* Modals */}
      {assignOrder && (
        <AssignDriverModal
          order={assignOrder}
          onClose={() => setAssignOrder(null)}
        />
      )}
      {detailOrderId && (
        <OrderDetailModal
          orderId={detailOrderId}
          onClose={() => setDetailOrderId(null)}
        />
      )}
    </div>
  );
}

function OrderRow({
  order,
  onAssign,
  onView,
}: {
  order: Order;
  onAssign: () => void;
  onView: () => void;
}) {
  const isPending = order.status === 'PENDING';
  const isCancelled = order.status === 'CANCELLED';
  const canAssign = !['DELIVERED', 'CANCELLED'].includes(order.status);

  return (
    <tr
      style={{
        borderLeft: isPending ? '2px solid #FFBE0B' : '2px solid transparent',
        opacity: isCancelled ? 0.6 : 1,
      }}
      onMouseEnter={(e) => {
        (e.currentTarget as HTMLTableRowElement).style.background = '#141920';
      }}
      onMouseLeave={(e) => {
        (e.currentTarget as HTMLTableRowElement).style.background = 'transparent';
      }}
    >
      {/* Order ID */}
      <td>
        <span className="text-xs font-mono font-medium" style={{ color: '#FFBE0B' }}>
          {order.orderId}
        </span>
      </td>

      {/* Merchant */}
      <td>
        <span className="text-xs" style={{ color: '#EDF2FF' }}>
          {order.merchant?.name || '—'}
        </span>
      </td>

      {/* Recipient */}
      <td>
        <p className="text-xs" style={{ color: '#EDF2FF' }}>
          {order.recipientName}
        </p>
        <p className="text-xs mt-0.5 font-mono" style={{ color: '#64748B' }}>
          {order.recipientPhone}
        </p>
      </td>

      {/* Area/Gov */}
      <td>
        <span className="text-xs" style={{ color: '#94A3B8' }}>
          {order.area}, {order.governorate}
        </span>
      </td>

      {/* Package */}
      <td>
        <div className="flex items-center gap-1.5">
          <span
            className="text-xs font-medium px-2 py-0.5 rounded"
            style={{
              background: `${PACKAGE_COLORS[order.packageSize]}18`,
              color: PACKAGE_COLORS[order.packageSize],
            }}
          >
            {order.packageSize}
          </span>
          {order.isFragile && (
            <Gem size={12} style={{ color: '#F59E0B' }} />
          )}
        </div>
      </td>

      {/* COD */}
      <td>
        {order.isCod ? (
          <span className="text-xs font-mono" style={{ color: '#FFBE0B' }}>
            JD {order.codAmount.toFixed(2)}
          </span>
        ) : (
          <span className="text-xs" style={{ color: '#3a4557' }}>
            —
          </span>
        )}
      </td>

      {/* Status */}
      <td>
        <StatusBadge status={order.status} size="sm" />
      </td>

      {/* Driver */}
      <td>
        {order.driverName ? (
          <div>
            <p className="text-xs" style={{ color: '#EDF2FF' }}>
              {order.driverName}
            </p>
            <p className="text-xs font-mono mt-0.5" style={{ color: '#64748B' }}>
              {order.driverPhone}
            </p>
          </div>
        ) : (
          <span className="text-xs" style={{ color: '#3a4557' }}>
            —
          </span>
        )}
      </td>

      {/* Created */}
      <td>
        <span className="text-xs" style={{ color: '#64748B' }}>
          {formatDistanceToNow(new Date(order.createdAt), { addSuffix: true })}
        </span>
      </td>

      {/* Actions */}
      <td>
        <div className="flex items-center gap-1">
          {canAssign && (
            <button
              onClick={onAssign}
              title="Assign Driver"
              className="rounded-lg p-1.5 transition-colors"
              style={{ color: '#64748B' }}
              onMouseEnter={(e) => {
                (e.currentTarget as HTMLButtonElement).style.color = '#FFBE0B';
                (e.currentTarget as HTMLButtonElement).style.background = 'rgba(255,190,11,0.1)';
              }}
              onMouseLeave={(e) => {
                (e.currentTarget as HTMLButtonElement).style.color = '#64748B';
                (e.currentTarget as HTMLButtonElement).style.background = 'transparent';
              }}
            >
              <UserCheck size={14} />
            </button>
          )}
          <button
            onClick={onView}
            title="View Detail"
            className="rounded-lg p-1.5 transition-colors"
            style={{ color: '#64748B' }}
            onMouseEnter={(e) => {
              (e.currentTarget as HTMLButtonElement).style.color = '#3B82F6';
              (e.currentTarget as HTMLButtonElement).style.background = 'rgba(59,130,246,0.1)';
            }}
            onMouseLeave={(e) => {
              (e.currentTarget as HTMLButtonElement).style.color = '#64748B';
              (e.currentTarget as HTMLButtonElement).style.background = 'transparent';
            }}
          >
            <Eye size={14} />
          </button>
        </div>
      </td>
    </tr>
  );
}
