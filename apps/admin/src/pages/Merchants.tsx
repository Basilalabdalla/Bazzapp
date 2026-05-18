import { useEffect, useState } from 'react';
import {
  Search,
  Plus,
  Pencil,
  ToggleLeft,
  ToggleRight,
  Store,
  AlertCircle,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { format } from 'date-fns';
import toast from 'react-hot-toast';
import { getMerchants, toggleMerchantStatus } from '../lib/api';
import { CreateMerchantModal } from '../components/CreateMerchantModal';
import { ConfirmModal } from '../components/ConfirmModal';
import type { Merchant } from '../types';

export default function Merchants() {
  const queryClient = useQueryClient();

  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [showCreate, setShowCreate] = useState(false);
  const [editMerchant, setEditMerchant] = useState<Merchant | null>(null);
  const [toggleTarget, setToggleTarget] = useState<Merchant | null>(null);

  useEffect(() => {
    document.title = 'Merchants — BazZ Admin';
  }, []);

  const queryParams = {
    search: search || undefined,
    page,
    limit: 20,
  };

  const { data, isLoading, isError, refetch } = useQuery({
    queryKey: ['merchants', queryParams],
    queryFn: () => getMerchants(queryParams).then((r) => r.data),
    placeholderData: (prev) => prev,
  });

  const toggleMutation = useMutation({
    mutationFn: (id: string) => toggleMerchantStatus(id),
    onSuccess: (_, id) => {
      const merchant = data?.data.find((m) => m.id === id);
      toast.success(
        `${merchant?.name} ${merchant?.isActive ? 'deactivated' : 'activated'}`
      );
      queryClient.invalidateQueries({ queryKey: ['merchants'] });
      setToggleTarget(null);
    },
    onError: () => {
      toast.error('Failed to update merchant status');
    },
  });

  const merchants = data?.data ?? [];
  const meta = data?.meta;

  return (
    <div className="p-6 space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2
            className="text-xl font-bold"
            style={{ fontFamily: 'Syne, sans-serif', color: '#1A202C' }}
          >
            Merchants
          </h2>
          <p className="text-xs mt-0.5" style={{ color: '#64748B' }}>
            {meta?.total ?? 0} total merchants
          </p>
        </div>
        <button
          onClick={() => setShowCreate(true)}
          className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold transition-opacity"
          style={{ background: '#1A3C6E', color: '#FFFFFF', fontFamily: 'Inter, Syne, sans-serif' }}
        >
          <Plus size={15} />
          Add Merchant
        </button>
      </div>

      {/* Filter bar */}
      <div
        className="rounded-xl border p-4"
        style={{ background: '#FFFFFF', borderColor: '#E2E8F0', boxShadow: '0 1px 3px rgba(0,0,0,0.05)' }}
      >
        <div className="relative max-w-sm">
          <Search
            size={14}
            className="absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none"
            style={{ color: '#64748B' }}
          />
          <input
            type="text"
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            placeholder="Search by name or phone..."
            className="w-full pl-8 pr-3 py-2 text-sm"
          />
        </div>
      </div>

      {/* Table */}
      <div
        className="rounded-xl border overflow-hidden"
        style={{ background: '#FFFFFF', borderColor: '#E2E8F0', boxShadow: '0 1px 3px rgba(0,0,0,0.05)' }}
      >
        {isLoading ? (
          <div className="p-8 space-y-3">
            {Array.from({ length: 6 }).map((_, i) => (
              <div
                key={i}
                className="h-14 rounded-lg animate-pulse"
                style={{ background: '#F8FAFC' }}
              />
            ))}
          </div>
        ) : isError ? (
          <div className="flex flex-col items-center justify-center py-20">
            <AlertCircle size={40} style={{ color: '#EF4444' }} />
            <p className="text-sm mt-3 mb-4" style={{ color: '#64748B' }}>
              Failed to load merchants
            </p>
            <button
              onClick={() => refetch()}
              className="px-4 py-2 rounded-lg text-sm font-medium"
              style={{ background: '#141920', color: '#1A202C', border: '1px solid #252D3F' }}
            >
              Retry
            </button>
          </div>
        ) : merchants.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20">
            <Store size={40} style={{ color: '#252D3F' }} />
            <p className="text-sm mt-3" style={{ color: '#64748B' }}>
              No merchants found
            </p>
          </div>
        ) : (
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Phone</th>
                <th>Role</th>
                <th>Status</th>
                <th>Orders</th>
                <th>Joined</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {merchants.map((merchant) => (
                <MerchantRow
                  key={merchant.id}
                  merchant={merchant}
                  onEdit={() => setEditMerchant(merchant)}
                  onToggle={() => setToggleTarget(merchant)}
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
            {Math.min(meta.page * meta.limit, meta.total)} of {meta.total}
          </span>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={meta.page === 1}
              className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs border disabled:opacity-40"
              style={{ borderColor: '#252D3F', color: '#94A3B8', background: 'transparent' }}
            >
              <ChevronLeft size={14} />
              Previous
            </button>
            <span className="text-xs font-mono" style={{ color: '#1A202C' }}>
              {meta.page} / {meta.totalPages}
            </span>
            <button
              onClick={() => setPage((p) => Math.min(meta.totalPages, p + 1))}
              disabled={meta.page === meta.totalPages}
              className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs border disabled:opacity-40"
              style={{ borderColor: '#252D3F', color: '#94A3B8', background: 'transparent' }}
            >
              Next
              <ChevronRight size={14} />
            </button>
          </div>
        </div>
      )}

      {/* Modals */}
      {showCreate && (
        <CreateMerchantModal onClose={() => setShowCreate(false)} />
      )}
      {editMerchant && (
        <CreateMerchantModal
          onClose={() => setEditMerchant(null)}
          editMerchant={editMerchant}
        />
      )}
      {toggleTarget && (
        <ConfirmModal
          title={toggleTarget.isActive ? 'Deactivate Merchant' : 'Activate Merchant'}
          message={
            toggleTarget.isActive
              ? `Are you sure you want to deactivate "${toggleTarget.name}"? They will no longer be able to create orders.`
              : `Are you sure you want to activate "${toggleTarget.name}"?`
          }
          confirmLabel={toggleTarget.isActive ? 'Deactivate' : 'Activate'}
          variant={toggleTarget.isActive ? 'danger' : 'default'}
          isLoading={toggleMutation.isPending}
          onConfirm={() => toggleMutation.mutate(toggleTarget.id)}
          onCancel={() => setToggleTarget(null)}
        />
      )}
    </div>
  );
}

function MerchantRow({
  merchant,
  onEdit,
  onToggle,
}: {
  merchant: Merchant;
  onEdit: () => void;
  onToggle: () => void;
}) {
  return (
    <tr
      onMouseEnter={(e) => {
        (e.currentTarget as HTMLTableRowElement).style.background = '#F8FAFC';
      }}
      onMouseLeave={(e) => {
        (e.currentTarget as HTMLTableRowElement).style.background = 'transparent';
      }}
    >
      {/* Name */}
      <td>
        <p className="text-sm font-medium" style={{ color: '#1A202C' }}>
          {merchant.name}
        </p>
        {merchant.nameAr && (
          <p
            className="text-xs mt-0.5"
            dir="rtl"
            lang="ar"
            style={{ color: '#64748B', fontFamily: "'Cairo', sans-serif" }}
          >
            {merchant.nameAr}
          </p>
        )}
      </td>

      {/* Phone */}
      <td>
        <span className="text-sm font-mono" style={{ color: '#94A3B8' }}>
          {merchant.phone}
        </span>
      </td>

      {/* Role */}
      <td>
        <span
          className="text-xs font-medium px-2 py-0.5 rounded-full"
          style={{
            background: merchant.role === 'ADMIN' ? 'rgba(26,60,110,0.1)' : 'rgba(59,130,246,0.12)',
            color: merchant.role === 'ADMIN' ? '#FFBE0B' : '#3B82F6',
          }}
        >
          {merchant.role}
        </span>
      </td>

      {/* Status */}
      <td>
        <span
          className="text-xs font-medium px-2.5 py-1 rounded-full"
          style={{
            background: merchant.isActive ? 'rgba(34,197,94,0.12)' : 'rgba(239,68,68,0.12)',
            color: merchant.isActive ? '#22C55E' : '#EF4444',
          }}
        >
          {merchant.isActive ? 'Active' : 'Inactive'}
        </span>
      </td>

      {/* Orders */}
      <td>
        <span className="text-sm font-mono" style={{ color: '#1A202C' }}>
          {merchant._count?.orders ?? 0}
        </span>
      </td>

      {/* Joined */}
      <td>
        <span className="text-xs" style={{ color: '#64748B' }}>
          {format(new Date(merchant.createdAt), 'MMM d, yyyy')}
        </span>
      </td>

      {/* Actions */}
      <td>
        <div className="flex items-center gap-1">
          <button
            onClick={onEdit}
            title="Edit"
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
            <Pencil size={14} />
          </button>
          <button
            onClick={onToggle}
            title={merchant.isActive ? 'Deactivate' : 'Activate'}
            className="rounded-lg p-1.5 transition-colors"
            style={{ color: merchant.isActive ? '#22C55E' : '#64748B' }}
            onMouseEnter={(e) => {
              (e.currentTarget as HTMLButtonElement).style.background = merchant.isActive
                ? 'rgba(239,68,68,0.1)'
                : 'rgba(34,197,94,0.1)';
              (e.currentTarget as HTMLButtonElement).style.color = merchant.isActive
                ? '#EF4444'
                : '#22C55E';
            }}
            onMouseLeave={(e) => {
              (e.currentTarget as HTMLButtonElement).style.background = 'transparent';
              (e.currentTarget as HTMLButtonElement).style.color = merchant.isActive
                ? '#22C55E'
                : '#64748B';
            }}
          >
            {merchant.isActive ? <ToggleRight size={16} /> : <ToggleLeft size={16} />}
          </button>
        </div>
      </td>
    </tr>
  );
}
