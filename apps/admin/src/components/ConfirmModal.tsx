import { AlertTriangle } from 'lucide-react';

interface ConfirmModalProps {
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  variant?: 'danger' | 'warning' | 'default';
  isLoading?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}

export function ConfirmModal({
  title,
  message,
  confirmLabel = 'Confirm',
  cancelLabel = 'Cancel',
  variant = 'danger',
  isLoading = false,
  onConfirm,
  onCancel,
}: ConfirmModalProps) {
  const confirmColor =
    variant === 'danger'
      ? '#EF4444'
      : variant === 'warning'
      ? '#F59E0B'
      : '#FFBE0B';

  return (
    <div className="modal-overlay" onClick={onCancel}>
      <div
        className="rounded-xl border p-6 w-full max-w-sm slide-in"
        style={{ background: '#0D1117', borderColor: '#252D3F' }}
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center gap-3 mb-4">
          <div
            className="rounded-lg p-2"
            style={{ background: `${confirmColor}1A` }}
          >
            <AlertTriangle size={20} style={{ color: confirmColor }} />
          </div>
          <h3
            className="text-base font-semibold"
            style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
          >
            {title}
          </h3>
        </div>

        <p className="text-sm mb-6" style={{ color: '#94A3B8' }}>
          {message}
        </p>

        <div className="flex gap-3 justify-end">
          <button
            onClick={onCancel}
            disabled={isLoading}
            className="px-4 py-2 rounded-lg text-sm font-medium border transition-colors"
            style={{
              borderColor: '#252D3F',
              color: '#94A3B8',
              background: 'transparent',
            }}
          >
            {cancelLabel}
          </button>
          <button
            onClick={onConfirm}
            disabled={isLoading}
            className="px-4 py-2 rounded-lg text-sm font-semibold transition-opacity"
            style={{
              background: confirmColor,
              color: variant === 'warning' ? '#000' : '#fff',
              opacity: isLoading ? 0.6 : 1,
            }}
          >
            {isLoading ? 'Processing...' : confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}
