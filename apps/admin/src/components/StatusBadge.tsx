import type { OrderStatus } from '../types';

// Matches the Flutter app's BazzColors status palette exactly
const STATUS_CONFIG: Record<
  OrderStatus,
  { bg: string; color: string; label: string }
> = {
  PENDING:     { bg: '#F3F4F6', color: '#6B7280',  label: 'Pending' },
  PROCESSING:  { bg: '#1A3C6E', color: '#FFFFFF',  label: 'Processing' },
  IN_DELIVERY: { bg: '#FFD700', color: '#1A3C6E',  label: 'In Delivery' },
  DELIVERED:   { bg: '#2ECC71', color: '#FFFFFF',  label: 'Delivered' },
  CANCELLED:   { bg: '#E53935', color: '#FFFFFF',  label: 'Cancelled' },
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
        fontWeight: 600,
        borderRadius: 20,
        fontFamily: 'Inter, Outfit, sans-serif',
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
