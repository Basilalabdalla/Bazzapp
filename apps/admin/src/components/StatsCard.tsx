import type { LucideIcon } from 'lucide-react';

interface StatsCardProps {
  label: string;
  value: string | number;
  icon: LucideIcon;
  color?: string;
  subLabel?: string;
}

export function StatsCard({
  label,
  value,
  icon: Icon,
  color = '#1A3C6E',
  subLabel,
}: StatsCardProps) {
  return (
    <div
      className="rounded-xl p-5 border transition-all duration-200 cursor-default"
      style={{
        background: '#FFFFFF',
        borderColor: '#E2E8F0',
        boxShadow: '0 1px 3px rgba(0,0,0,0.06)',
      }}
      onMouseEnter={(e) => {
        (e.currentTarget as HTMLDivElement).style.boxShadow = '0 4px 12px rgba(26,60,110,0.1)';
        (e.currentTarget as HTMLDivElement).style.borderColor = '#CBD5E0';
      }}
      onMouseLeave={(e) => {
        (e.currentTarget as HTMLDivElement).style.boxShadow = '0 1px 3px rgba(0,0,0,0.06)';
        (e.currentTarget as HTMLDivElement).style.borderColor = '#E2E8F0';
      }}
    >
      <div className="flex items-start justify-between">
        <div>
          <p
            className="text-sm font-medium mb-1"
            style={{ color: '#64748B', fontFamily: 'Inter, sans-serif' }}
          >
            {label}
          </p>
          <p
            className="text-3xl font-bold"
            style={{ color: '#1A202C', fontFamily: 'Inter, Syne, sans-serif', fontWeight: 700 }}
          >
            {value}
          </p>
          {subLabel && (
            <p className="text-xs mt-1" style={{ color: '#94A3B8' }}>
              {subLabel}
            </p>
          )}
        </div>
        <div
          className="rounded-xl p-2.5 flex-shrink-0"
          style={{ background: `${color}18` }}
        >
          <Icon size={22} style={{ color }} />
        </div>
      </div>
    </div>
  );
}
