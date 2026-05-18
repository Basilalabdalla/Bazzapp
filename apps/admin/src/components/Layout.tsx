import { useState, useEffect } from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import {
  LayoutDashboard,
  Package,
  Store,
  Bell,
  Zap,
  LogOut,
  ChevronRight,
} from 'lucide-react';
import { useQuery } from '@tanstack/react-query';
import { format } from 'date-fns';
import toast from 'react-hot-toast';
import { useAuthStore } from '../store/auth';
import { adminLogout, getPlatformStats } from '../lib/api';
import { useWebSocket } from '../hooks/useWebSocket';

interface NavItemProps {
  to: string;
  icon: React.ElementType;
  label: string;
  badge?: number;
}

function NavItem({ to, icon: Icon, label, badge }: NavItemProps) {
  return (
    <NavLink
      to={to}
      className={({ isActive }) =>
        `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-all duration-150 relative group ${
          isActive ? 'nav-active' : ''
        }`
      }
      style={({ isActive }) => ({
        color: isActive ? '#FFBE0B' : '#64748B',
        background: isActive ? 'rgba(255,190,11,0.08)' : 'transparent',
        borderLeft: isActive ? '2px solid #FFBE0B' : '2px solid transparent',
        marginLeft: -1,
      })}
    >
      {({ isActive }) => (
        <>
          <Icon
            size={17}
            style={{ color: isActive ? '#FFBE0B' : '#64748B', flexShrink: 0 }}
          />
          <span style={{ fontFamily: 'Outfit, sans-serif' }}>{label}</span>
          {badge !== undefined && badge > 0 && (
            <span
              className="ml-auto text-xs font-semibold rounded-full px-1.5 py-0.5 min-w-[20px] text-center"
              style={{ background: '#FFBE0B', color: '#000' }}
            >
              {badge > 99 ? '99+' : badge}
            </span>
          )}
          {!isActive && (
            <ChevronRight
              size={12}
              className="ml-auto opacity-0 group-hover:opacity-40 transition-opacity"
              style={{ color: '#64748B' }}
            />
          )}
        </>
      )}
    </NavLink>
  );
}

export function Layout() {
  const navigate = useNavigate();
  const { admin, refreshToken, logout } = useAuthStore();
  const [now, setNow] = useState(new Date());

  // Live clock
  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  // Stats for pending badge
  const { data: stats } = useQuery({
    queryKey: ['stats'],
    queryFn: () => getPlatformStats().then((r) => r.data),
    refetchInterval: 30000,
  });

  // WebSocket
  useWebSocket({});

  const handleLogout = async () => {
    try {
      if (refreshToken) await adminLogout(refreshToken);
    } catch {
      // ignore
    }
    logout();
    toast.success('Logged out');
    navigate('/login');
  };

  return (
    <div className="flex h-screen overflow-hidden" style={{ background: '#07080F' }}>
      {/* Sidebar */}
      <aside
        className="flex flex-col flex-shrink-0 border-r"
        style={{
          width: 256,
          background: '#0D1117',
          borderColor: '#252D3F',
        }}
      >
        {/* Logo */}
        <div
          className="px-5 pt-6 pb-5 border-b"
          style={{ borderColor: '#252D3F' }}
        >
          <div className="flex items-center gap-2 mb-1">
            <div
              className="rounded-lg p-1.5"
              style={{ background: 'rgba(255,190,11,0.12)' }}
            >
              <Zap size={16} fill="#FFBE0B" style={{ color: '#FFBE0B' }} />
            </div>
            <span
              className="text-2xl font-extrabold tracking-tight"
              style={{ fontFamily: 'Syne, sans-serif', color: '#FFBE0B' }}
            >
              BazZ
            </span>
            {/* Live indicator */}
            <div className="ml-auto flex items-center gap-1.5">
              <div
                className="live-dot w-2 h-2 rounded-full"
                style={{ background: '#22C55E' }}
              />
              <span className="text-xs" style={{ color: '#64748B' }}>
                LIVE
              </span>
            </div>
          </div>
          <p
            className="text-xs"
            style={{ color: '#64748B', marginLeft: 36, fontFamily: 'Outfit, sans-serif' }}
          >
            Admin Console
          </p>
        </div>

        {/* Nav */}
        <nav className="flex-1 px-4 py-4 space-y-1 overflow-y-auto">
          <NavItem to="/dashboard" icon={LayoutDashboard} label="Dashboard" />
          <NavItem
            to="/orders"
            icon={Package}
            label="Orders"
            badge={stats?.orders.pending}
          />
          <NavItem to="/merchants" icon={Store} label="Merchants" />
          <NavItem to="/notifications" icon={Bell} label="Notifications" />
        </nav>

        {/* Admin info + logout */}
        <div className="px-4 pb-4 border-t pt-4" style={{ borderColor: '#252D3F' }}>
          <div
            className="rounded-lg p-3 mb-2"
            style={{ background: '#141920' }}
          >
            <p
              className="text-sm font-medium truncate"
              style={{ color: '#EDF2FF' }}
            >
              {admin?.name || 'Admin'}
            </p>
            <p
              className="text-xs truncate font-mono mt-0.5"
              style={{ color: '#64748B' }}
            >
              {admin?.phone}
            </p>
          </div>
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-sm transition-colors"
            style={{ color: '#64748B' }}
            onMouseEnter={(e) => {
              (e.currentTarget as HTMLButtonElement).style.color = '#EF4444';
              (e.currentTarget as HTMLButtonElement).style.background = 'rgba(239,68,68,0.08)';
            }}
            onMouseLeave={(e) => {
              (e.currentTarget as HTMLButtonElement).style.color = '#64748B';
              (e.currentTarget as HTMLButtonElement).style.background = 'transparent';
            }}
          >
            <LogOut size={15} />
            <span>Logout</span>
          </button>
        </div>
      </aside>

      {/* Main */}
      <div className="flex flex-col flex-1 overflow-hidden">
        {/* Top bar */}
        <header
          className="flex items-center justify-between px-6 flex-shrink-0 border-b"
          style={{
            height: 56,
            background: '#0D1117',
            borderColor: '#252D3F',
          }}
        >
          {/* Page title injected by pages via document.title or context */}
          <PageTitle />
          <div className="flex items-center gap-4">
            <span
              className="text-sm font-mono"
              style={{ color: '#64748B' }}
            >
              {format(now, 'EEE, MMM d · HH:mm:ss')}
            </span>
          </div>
        </header>

        {/* Page content */}
        <main className="flex-1 overflow-y-auto">
          <Outlet />
        </main>
      </div>
    </div>
  );
}

// Simple page title that reads the document title
function PageTitle() {
  const [title, setTitle] = useState('');

  useEffect(() => {
    const update = () => {
      const t = document.title.replace(' — BazZ Admin', '').replace('BazZ Admin', 'Dashboard');
      setTitle(t);
    };
    update();
    const observer = new MutationObserver(update);
    observer.observe(document.querySelector('title') || document.head, {
      subtree: true,
      characterData: true,
      childList: true,
    });
    return () => observer.disconnect();
  }, []);

  return (
    <h1
      className="text-base font-semibold"
      style={{ fontFamily: 'Syne, sans-serif', color: '#EDF2FF' }}
    >
      {title}
    </h1>
  );
}
