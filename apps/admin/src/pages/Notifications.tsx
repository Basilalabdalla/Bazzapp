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
        recipient: target === 'all' ? 'All Merchants' : selectedMerchant?.name ?? 'Unknown',
        title: title.trim(),
        body: body.trim(),
        sentAt: new Date(),
        result: data,
      };
      setHistory((prev) => [entry, ...prev].slice(0, 20));
      toast.success(`Sent to ${data.sent} merchant${data.sent !== 1 ? 's' : ''}${data.skipped ? ` · ${data.skipped} skipped (no token)` : ''}`);
      setTitle('');
      setBody('');
    },
    onError: (err: unknown) => {
      const msg = (err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed to send notification';
      toast.error(msg);
    },
  });

  const canSend = title.trim().length > 0 && body.trim().length > 0 && (target === 'all' || merchantId !== '') && !mutation.isPending;

  return (
    <div className="p-6 space-y-6 max-w-5xl">
      <div className="flex items-center gap-3">
        <div className="rounded-xl p-2.5" style={{ background: 'rgba(26,60,110,0.08)' }}>
          <Bell size={20} style={{ color: '#1A3C6E' }} />
        </div>
        <div>
          <h1 className="text-lg font-bold" style={{ fontFamily: 'Inter, Syne, sans-serif', color: '#1A202C' }}>
            Push Notifications
          </h1>
          <p className="text-xs" style={{ color: '#64748B' }}>Send notifications directly to merchant apps</p>
        </div>
      </div>

      <div className="grid grid-cols-3 gap-6">
        {/* Composer */}
        <div className="col-span-2 space-y-4">
          <div
            className="rounded-xl border p-6 space-y-5"
            style={{ background: '#FFFFFF', borderColor: '#E2E8F0', boxShadow: '0 1px 3px rgba(0,0,0,0.05)' }}
          >
            <h2 className="text-sm font-bold" style={{ fontFamily: 'Inter, Syne, sans-serif', color: '#1A202C' }}>
              Compose Notification
            </h2>

            {/* Target selector */}
            <div>
              <label className="block text-xs font-semibold mb-2" style={{ color: '#1A3C6E' }}>
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
                <label className="block text-xs font-semibold mb-1.5" style={{ color: '#1A3C6E' }}>
                  Select Merchant
                </label>
                <select
                  value={merchantId}
                  onChange={(e) => setMerchantId(e.target.value)}
                  className="w-full px-3 py-2.5 text-sm"
                  style={{ color: merchantId ? '#1A202C' : '#94A3B8' }}
                >
                  <option value="">— Choose a merchant —</option>
                  {merchants.filter((m) => m.isActive).map((m) => (
                    <option key={m.id} value={m.id}>{m.name} · {m.phone}</option>
                  ))}
                </select>
                {merchantId && !selectedMerchant?.isActive && (
                  <p className="text-xs mt-1" style={{ color: '#E53935' }}>This merchant is inactive</p>
                )}
              </div>
            )}

            {/* Title */}
            <div>
              <div className="flex items-center justify-between mb-1.5">
                <label className="text-xs font-semibold" style={{ color: '#1A3C6E' }}>Notification Title</label>
                <span className="text-xs font-mono" style={{ color: title.length > 90 ? '#E53935' : '#94A3B8' }}>
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
                <label className="text-xs font-semibold" style={{ color: '#1A3C6E' }}>Message Body</label>
                <span className="text-xs font-mono" style={{ color: body.length > 450 ? '#E53935' : '#94A3B8' }}>
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
                  background: '#FFFFFF',
                  border: '1px solid #E2E8F0',
                  borderRadius: 8,
                  color: '#1A202C',
                  fontFamily: 'Inter, Outfit, sans-serif',
                  outline: 'none',
                }}
                onFocus={(e) => (e.currentTarget.style.borderColor = '#1A3C6E')}
                onBlur={(e) => (e.currentTarget.style.borderColor = '#E2E8F0')}
              />
            </div>

            {/* Phone preview */}
            {(title || body) && (
              <div className="rounded-xl p-4 border" style={{ background: '#F5F7FA', borderColor: '#E2E8F0' }}>
                <p className="text-xs font-medium mb-2" style={{ color: '#64748B' }}>
                  Preview · Phone notification
                </p>
                <div className="rounded-xl p-3" style={{ background: '#1A3C6E' }}>
                  <div className="flex items-center gap-2 mb-1.5">
                    <div className="rounded-md p-1" style={{ background: 'rgba(255,215,0,0.2)' }}>
                      <Bell size={10} style={{ color: '#FFD700' }} />
                    </div>
                    <span className="text-xs font-semibold" style={{ color: '#FFFFFF', fontFamily: 'Inter, Syne, sans-serif' }}>
                      BazZ
                    </span>
                    <span className="text-xs ml-auto" style={{ color: 'rgba(255,255,255,0.45)' }}>now</span>
                  </div>
                  <p className="text-xs font-semibold" style={{ color: '#FFFFFF' }}>
                    {title || '(no title)'}
                  </p>
                  {body && <p className="text-xs mt-0.5 line-clamp-2" style={{ color: 'rgba(255,255,255,0.65)' }}>{body}</p>}
                </div>
              </div>
            )}

            {/* Send button */}
            <button
              onClick={() => mutation.mutate()}
              disabled={!canSend}
              className="w-full flex items-center justify-center gap-2 rounded-xl font-bold transition-all"
              style={{
                height: 48,
                background: canSend ? '#1A3C6E' : '#E2E8F0',
                color: canSend ? '#FFFFFF' : '#94A3B8',
                fontFamily: 'Inter, Syne, sans-serif',
                fontSize: 14,
                cursor: canSend ? 'pointer' : 'not-allowed',
                border: 'none',
              }}
            >
              {mutation.isPending ? (
                <>
                  <div className="w-4 h-4 rounded-full border-2 animate-spin"
                    style={{ borderColor: 'rgba(255,255,255,0.3)', borderTopColor: '#FFFFFF' }} />
                  Sending...
                </>
              ) : (
                <>
                  <Send size={15} />
                  Send Notification
                  {target === 'all' && (
                    <span className="text-xs px-2 py-0.5 rounded-full" style={{ background: 'rgba(255,255,255,0.15)' }}>
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
          <div className="rounded-xl border overflow-hidden" style={{ background: '#FFFFFF', borderColor: '#E2E8F0', boxShadow: '0 1px 3px rgba(0,0,0,0.05)' }}>
            <div className="flex items-center justify-between px-4 py-3.5 border-b" style={{ borderColor: '#E2E8F0', background: '#FAFBFC' }}>
              <h2 className="text-sm font-bold" style={{ fontFamily: 'Inter, Syne, sans-serif', color: '#1A202C' }}>
                Sent This Session
              </h2>
              {history.length > 0 && (
                <button onClick={() => setHistory([])} className="rounded-lg p-1" title="Clear history" style={{ color: '#94A3B8' }}>
                  <Trash2 size={13} />
                </button>
              )}
            </div>

            {history.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-12 px-4">
                <Clock size={28} style={{ color: '#E2E8F0' }} />
                <p className="text-xs text-center mt-3" style={{ color: '#94A3B8' }}>
                  No notifications sent yet this session
                </p>
              </div>
            ) : (
              <div className="divide-y" style={{ borderColor: '#F1F5F9' }}>
                {history.map((entry) => <HistoryEntry key={entry.id} entry={entry} />)}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

function TargetCard({ active, onClick, icon: Icon, label, description }: {
  active: boolean; onClick: () => void; icon: React.ElementType; label: string; description: string;
}) {
  return (
    <button
      onClick={onClick}
      className="flex items-start gap-3 rounded-xl p-3.5 text-left transition-all border"
      style={{
        background: active ? 'rgba(26,60,110,0.06)' : '#F8FAFC',
        borderColor: active ? '#1A3C6E' : '#E2E8F0',
      }}
    >
      <div className="rounded-lg p-1.5 mt-0.5 flex-shrink-0" style={{ background: active ? 'rgba(26,60,110,0.12)' : '#EDF2FF' }}>
        <Icon size={14} style={{ color: active ? '#1A3C6E' : '#64748B' }} />
      </div>
      <div>
        <p className="text-xs font-semibold" style={{ color: active ? '#1A3C6E' : '#1A202C' }}>{label}</p>
        <p className="text-xs mt-0.5" style={{ color: '#64748B' }}>{description}</p>
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
          {success ? <CheckCircle size={13} style={{ color: '#2ECC71' }} /> : <AlertCircle size={13} style={{ color: '#F59E0B' }} />}
        </div>
        <div className="min-w-0 flex-1">
          <p className="text-xs font-semibold truncate" style={{ color: '#1A202C' }}>{entry.title}</p>
          <p className="text-xs truncate mt-0.5" style={{ color: '#64748B' }}>{entry.body}</p>
          <div className="flex items-center gap-2 mt-1.5">
            <span className="text-xs px-1.5 py-0.5 rounded" style={{ background: '#F5F7FA', color: '#64748B' }}>
              {entry.recipient}
            </span>
            <span className="text-xs" style={{ color: '#94A3B8' }}>{format(entry.sentAt, 'HH:mm')}</span>
          </div>
          <p className="text-xs mt-1" style={{ color: success ? '#2ECC71' : '#F59E0B' }}>
            {entry.result.sent} sent{entry.result.skipped > 0 && ` · ${entry.result.skipped} skipped`}
          </p>
        </div>
      </div>
    </div>
  );
}
