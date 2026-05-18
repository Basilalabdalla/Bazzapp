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
  color = '#64748B',
  subLabel,
}: StatsCardProps) {
  return (
    <div
      className="rounded-xl p-5 border transition-all duration-200 cursor-default"
      style={{
        background: '#0D1117',
        borderColor: '#252D3F',
      }}
      onMouseEnter={(e) => {
        (e.currentTarget as HTMLDivElement).style.borderColor = '#3a4557';
      }}
      onMouseLeave={(e) => {
        (e.currentTarget as HTMLDivElement).style.borderColor = '#252D3F';
      }}
    >
      <div className="flex items-start justify-between">
        <div>
          <p
            className="text-sm font-medium mb-1"
            style={{ color: '#64748B', fontFamily: 'Outfit, sans-serif' }}
          >
            {label}
          </p>
          <p
            className="text-3xl font-bold"
            style={{ color: '#EDF2FF', fontFamily: 'Syne, sans-serif', fontWeight: 700 }}
          >
            {value}
          </p>
          {subLabel && (
            <p className="text-xs mt-1" style={{ color: '#64748B' }}>
              {subLabel}
            </p>
          )}
        </div>
        <div
          className="rounded-lg p-2.5 flex-shrink-0"
          style={{ background: `${color}1A` }}
        >
          <Icon size={22} style={{ color }} />
        </div>
      </div>
    </div>
  );
}
