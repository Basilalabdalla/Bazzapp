import type { OrderStatus } from '../types';

const STATUS_CONFIG: Record<
  OrderStatus,
  { bg: string; color: string; label: string }
> = {
  PENDING: { bg: '#1C2333', color: '#94A3B8', label: 'Pending' },
  PROCESSING: { bg: '#2D2000', color: '#F59E0B', label: 'Processing' },
  IN_DELIVERY: { bg: '#0F1F3D', color: '#3B82F6', label: 'In Delivery' },
  DELIVERED: { bg: '#0F2D1A', color: '#22C55E', label: 'Delivered' },
  CANCELLED: { bg: '#2D0F0F', color: '#EF4444', label: 'Cancelled' },
};

interface StatusBadgeProps {
  status: OrderStatus;
  size?: 'sm' | 'md';
}

export function StatusBadge({ status, size = 'md' }: StatusBadgeProps) {
  const config = STATUS_CONFIG[status];
  const padding = size === 'sm' ? '2px 8px' : '4px 10px';
  const fontSize = size === 'sm' ? '11px' : '12px';

  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: 5,
        background: config.bg,
        color: config.color,
        padding,
        fontSize,
        fontWeight: 500,
        borderRadius: 20,
        fontFamily: 'Outfit, sans-serif',
        whiteSpace: 'nowrap',
      }}
    >
      <span
        style={{
          width: 6,
          height: 6,
          borderRadius: '50%',
          background: config.color,
          flexShrink: 0,
        }}
      />
      {config.label}
    </span>
  );
}
