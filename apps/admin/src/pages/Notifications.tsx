import { useEffect, useState } from 'react';
import { Bell, Send, Users, User, CheckCircle, AlertCircle, Clock, Trash2 } from 'lucide-react';
import { useMutation, useQuery } from '@tanstack/react-query';
import toast from 'react-hot-toast';
import { getMerchants, sendNotification } from '../lib/api';
import type { Merchant } from '../types';
import { format } from 'date-fns';

interface SentNotification {
  id: string;
  recipient: string;
  title: string;
  body: string;
  sentAt: Date;
  result: { sent: number; skipped: number; total?: number };
}

export default function Notifications() {
  const [target, setTarget] = useState<'all' | 'single'>('all');
  const [merchantId, setMerchantId] = useState('');
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [history, setHistory] = useState<SentNotification[]>([]);

  useEffect(() => {
    document.title = 'Notifications — BazZ Admin';
  }, []);

  const { data: merchantsData } = useQuery({
    queryKey: ['merchants', { limit: 200 }],
    queryFn: () => getMerchants({ limit: 200 }).then((r) => r.data),
  });

  const merchants: Merchant[] = merchantsData?.data ?? [];
  const selectedMerchant = merchants.find((m) => m.id === merchantId);

  const mutation = useMutation({
    mutationFn: () =>
      sendNotification({
        merchantId: target === 'single' ? merchantId : undefined,
        title: title.trim(),
        body: body.trim(),
      }),
    onSuccess: ({ data }) => {
      const entry: SentNotification = {
        id: crypto.randomUUID(),
        recipient:
          target === 'all'
            ? 'All Merchants'
            : selectedMerchant?.name ?? 'Unknown',
        title: title.trim(),
        body: body.trim(),
        sentAt: new Date(),
        result: data,
      };
      setHistory((prev) => [entry, ...prev].slice(0, 20));
      toast.success(
        `Sent to ${data.sent} merchant${data.sent !== 1 ? 's' : ''}${
          data.skipped ? ` · ${data.skipped} skipped (no token)` : ''
        }`,
      );
      setTitle('');
      setBody('');
    },
    onError: (err: unknown) => {
      const msg =
        (err as { response?: { data?: { error?: string } } })?.response?.data
          ?.error ?? 'Failed to send notification';
      toast.error(msg);
    },
  });

  const canSend =
    title.trim().length > 0 &&
    body.trim().length > 0 &&
    (target === 'all' || merchantId !== '') &&
    !mutation.isPending;

  return (
    <div className="p-6 space-y-6 max-w-5xl">
      <div className="flex items-center gap-3">
        <div
          className="rounded-xl p-2.5"
          style={{ background: 'rgba(255,190,11,0.10)' }}
        >
          <Bell size={20} style={{ color: '#FFBE0B' }} />
        </div>
        <div>
          <h1
            className="text-lg font-bold"
            style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
          >
            Push Notifications
          </h1>
          <p className="text-xs" style={{ color: '#64748B' }}>
            Send notifications directly to merchant apps
          </p>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-6">
        {/* Composer */}
        <div className="col-span-2 space-y-4">
          <div
            className="rounded-xl border p-6 space-y-5"
            style={{ background: '#0D1117', borderColor: '#252D3F' }}
          >
            <h2
              className="text-sm font-semibold"
              style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
            >
              Compose Notification
            </h2>

            {/* Target selector */}
            <div>
              <label
                className="block text-xs font-medium mb-2"
                style={{ color: '#94A3B8' }}
              >
                Recipients
              </label>
              <div className="grid grid-cols-2 gap-2">
                <TargetCard
                  active={target === 'all'}
                  onClick={() => { setTarget('all'); setMerchantId(''); }}
                  icon={Users}
                  label="All Merchants"
                  description={`${merchants.filter((m) => m.isActive).length} active`}
                />
                <TargetCard
                  active={target === 'single'}
                  onClick={() => setTarget('single')}
                  icon={User}
                  label="Specific Merchant"
                  description="Choose one merchant"
                />
              </div>
            </div>

            {/* Merchant picker */}
            {target === 'single' && (
              <div>
                <label
                  className="block text-xs font-medium mb-1.5"
                  style={{ color: '#94A3B8' }}
                >
                  Select Merchant
                </label>
                <select
                  value={merchantId}
                  onChange={(e) => setMerchantId(e.target.value)}
                  className="w-full px-3 py-2.5 text-sm"
                  style={{ color: merchantId ? '#EDF2FF' : '#64748B' }}
                >
                  <option value="">— Choose a merchant —</option>
                  {merchants
                    .filter((m) => m.isActive)
                    .map((m) => (
                      <option key={m.id} value={m.id}>
                        {m.name} · {m.phone}
                      </option>
                    ))}
                </select>
                {merchantId && !selectedMerchant?.isActive && (
                  <p className="text-xs mt-1" style={{ color: '#EF4444' }}>
                    This merchant is inactive
                  </p>
                )}
              </div>
            )}

            {/* Title */}
            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label
                  className="text-xs font-medium"
                  style={{ color: '#94A3B8' }}
                >
                  Notification Title
                </label>
                <span
                  className="text-xs font-mono"
                  style={{ color: title.length > 90 ? '#EF4444' : '#64748B' }}
                >
                  {title.length}/100
                </span>
              </div>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value.slice(0, 100))}
                placeholder="e.g. New Feature Available!"
                className="w-full px-3 py-2.5 text-sm"
              />
            </div>

            {/* Body */}
            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label
                  className="text-xs font-medium"
                  style={{ color: '#94A3B8' }}
                >
                  Message Body
                </label>
                <span
                  className="text-xs font-mono"
                  style={{ color: body.length > 450 ? '#EF4444' : '#64748B' }}
                >
                  {body.length}/500
                </span>
              </div>
              <textarea
                value={body}
                onChange={(e) => setBody(e.target.value.slice(0, 500))}
                placeholder="Write your message here..."
                rows={4}
                className="w-full px-3 py-2.5 text-sm resize-none"
                style={{
                  background: '#141920',
                  border: '1px solid #252D3F',
                  borderRadius: 8,
                  color: '#EDF2FF',
                  fontFamily: 'Outfit, sans-serif',
                  outline: 'none',
                }}
                onFocus={(e) => (e.currentTarget.style.borderColor = '#FFBE0B')}
                onBlur={(e) => (e.currentTarget.style.borderColor = '#252D3F')}
              />
            </div>

            {/* Preview */}
            {(title || body) && (
              <div
                className="rounded-xl p-4 border"
                style={{ background: '#141920', borderColor: '#1C2333' }}
              >
                <p
                  className="text-xs font-medium mb-1"
                  style={{ color: '#64748B' }}
                >
                  Preview · Phone notification
                </p>
                <div
                  className="rounded-xl p-3 mt-2"
                  style={{ background: '#1C2333' }}
                >
                  <div className="flex items-center gap-2 mb-1.5">
                    <div
                      className="rounded-md p-1"
                      style={{ background: 'rgba(255,190,11,0.2)' }}
                    >
                      <Bell size={10} style={{ color: '#FFBE0B' }} />
                    </div>
                    <span
                      className="text-xs font-semibold"
                      style={{ color: '#EDF2FF', fontFamily: 'Syne, sans-serif' }}
                    >
                      BazZ
                    </span>
                    <span
                      className="text-xs ml-auto"
                      style={{ color: '#64748B' }}
                    >
                      now
                    </span>
                  </div>
                  <p
                    className="text-xs font-semibold"
                    style={{ color: '#EDF2FF' }}
                  >
                    {title || '(no title)'}
                  </p>
                  {body && (
                    <p
                      className="text-xs mt-0.5 line-clamp-2"
                      style={{ color: '#94A3B8' }}
                    >
                      {body}
                    </p>
                  )}
                </div>
              </div>
            )}

            {/* Send button */}
            <button
              onClick={() => mutation.mutate()}
              disabled={!canSend}
              className="w-full flex items-center justify-center gap-2 rounded-xl font-semibold transition-all"
              style={{
                height: 48,
                background: canSend ? '#FFBE0B' : '#1C2333',
                color: canSend ? '#000' : '#3a4557',
                fontFamily: 'Syne, sans-serif',
                fontSize: 14,
                cursor: canSend ? 'pointer' : 'not-allowed',
              }}
            >
              {mutation.isPending ? (
                <>
                  <div
                    className="w-4 h-4 rounded-full border-2 animate-spin"
                    style={{ borderColor: '#000', borderTopColor: 'transparent' }}
                  />
                  Sending...
                </>
              ) : (
                <>
                  <Send size={15} />
                  Send Notification
                  {target === 'all' && (
                    <span
                      className="text-xs px-2 py-0.5 rounded-full"
                      style={{ background: 'rgba(0,0,0,0.2)' }}
                    >
                      {merchants.filter((m) => m.isActive).length} merchants
                    </span>
                  )}
                </>
              )}
            </button>
          </div>
        </div>

        {/* Sent history */}
        <div>
          <div
            className="rounded-xl border overflow-hidden"
            style={{ background: '#0D1117', borderColor: '#252D3F' }}
          >
            <div
              className="flex items-center justify-between px-4 py-3.5 border-b"
              style={{ borderColor: '#252D3F' }}
            >
              <h2
                className="text-sm font-semibold"
                style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
              >
                Sent This Session
              </h2>
              {history.length > 0 && (
                <button
                  onClick={() => setHistory([])}
                  className="rounded-lg p-1"
                  title="Clear history"
                  style={{ color: '#64748B' }}
                >
                  <Trash2 size={13} />
                </button>
              )}
            </div>

            {history.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-12 px-4">
                <Clock size={28} style={{ color: '#1C2333' }} />
                <p
                  className="text-xs text-center mt-3"
                  style={{ color: '#64748B' }}
                >
                  No notifications sent yet this session
                </p>
              </div>
            ) : (
              <div className="divide-y" style={{ borderColor: '#141920' }}>
                {history.map((entry) => (
                  <HistoryEntry key={entry.id} entry={entry} />
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

function TargetCard({
  active,
  onClick,
  icon: Icon,
  label,
  description,
}: {
  active: boolean;
  onClick: () => void;
  icon: React.ElementType;
  label: string;
  description: string;
}) {
  return (
    <button
      onClick={onClick}
      className="flex items-start gap-3 rounded-xl p-3.5 text-left transition-all border"
      style={{
        background: active ? 'rgba(255,190,11,0.07)' : '#141920',
        borderColor: active ? '#FFBE0B' : '#252D3F',
      }}
    >
      <div
        className="rounded-lg p-1.5 mt-0.5 flex-shrink-0"
        style={{
          background: active ? 'rgba(255,190,11,0.15)' : '#1C2333',
        }}
      >
        <Icon size={14} style={{ color: active ? '#FFBE0B' : '#64748B' }} />
      </div>
      <div>
        <p
          className="text-xs font-semibold"
          style={{ color: active ? '#FFBE0B' : '#EDF2FF' }}
        >
          {label}
        </p>
        <p className="text-xs mt-0.5" style={{ color: '#64748B' }}>
          {description}
        </p>
      </div>
    </button>
  );
}

function HistoryEntry({ entry }: { entry: SentNotification }) {
  const success = entry.result.sent > 0;
  return (
    <div className="px-4 py-3">
      <div className="flex items-start gap-2">
        <div className="mt-0.5 flex-shrink-0">
          {success ? (
            <CheckCircle size={13} style={{ color: '#22C55E' }} />
          ) : (
            <AlertCircle size={13} style={{ color: '#F59E0B' }} />
          )}
        </div>
        <div className="min-w-0 flex-1">
          <p
            className="text-xs font-medium truncate"
            style={{ color: '#EDF2FF' }}
          >
            {entry.title}
          </p>
          <p
            className="text-xs truncate mt-0.5"
            style={{ color: '#64748B' }}
          >
            {entry.body}
          </p>
          <div className="flex items-center gap-2 mt-1.5">
            <span
              className="text-xs px-1.5 py-0.5 rounded"
              style={{ background: '#141920', color: '#94A3B8' }}
            >
              {entry.recipient}
            </span>
            <span className="text-xs" style={{ color: '#3a4557' }}>
              {format(entry.sentAt, 'HH:mm')}
            </span>
          </div>
          <p className="text-xs mt-1" style={{ color: success ? '#22C55E' : '#F59E0B' }}>
            {entry.result.sent} sent
            {entry.result.skipped > 0 && ` · ${entry.result.skipped} skipped`}
          </p>
        </div>
      </div>
    </div>
  );
}
