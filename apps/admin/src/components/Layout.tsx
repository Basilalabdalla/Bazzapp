import { useState, useEffect } from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import {
  LayoutDashboard,
  Package,
  Store,
  Bell,
  LogOut,
  ChevronRight,
  Zap,
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
        color: isActive ? '#FFD700' : 'rgba(255,255,255,0.7)',
        background: isActive ? 'rgba(255,215,0,0.12)' : 'transparent',
        borderLeft: isActive ? '3px solid #FFD700' : '3px solid transparent',
        marginLeft: -1,
      })}
    >
      {({ isActive }) => (
        <>
          <Icon
            size={17}
            style={{ color: isActive ? '#FFD700' : 'rgba(255,255,255,0.6)', flexShrink: 0 }}
          />
          <span style={{ fontFamily: 'Inter, Outfit, sans-serif' }}>{label}</span>
          {badge !== undefined && badge > 0 && (
            <span
              className="ml-auto text-xs font-bold rounded-full px-1.5 py-0.5 min-w-[20px] text-center"
              style={{ background: '#FFD700', color: '#1A3C6E' }}
            >
              {badge > 99 ? '99+' : badge}
            </span>
          )}
          {!badge && !isActive && (
            <ChevronRight
              size={12}
              className="ml-auto opacity-0 group-hover:opacity-40 transition-opacity"
              style={{ color: 'rgba(255,255,255,0.5)' }}
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
    toast.success('Logged out successfully');
    navigate('/login');
  };

  return (
    <div className="flex h-screen overflow-hidden" style={{ background: '#F5F7FA' }}>
      {/* Sidebar — Navy */}
      <aside
        className="flex flex-col flex-shrink-0"
        style={{
          width: 256,
          background: '#1A3C6E',
          boxShadow: '2px 0 8px rgba(26,60,110,0.15)',
        }}
      >
        {/* Logo */}
        <div
          className="px-5 pt-6 pb-5 border-b"
          style={{ borderColor: 'rgba(255,255,255,0.1)' }}
        >
          <div className="flex items-center gap-2 mb-1">
            <div
              className="rounded-lg p-1.5"
              style={{ background: 'rgba(255,215,0,0.15)' }}
            >
              <Zap size={16} fill="#FFD700" style={{ color: '#FFD700' }} />
            </div>
            <span
              className="text-2xl font-extrabold tracking-tight"
              style={{ fontFamily: 'Syne, sans-serif', color: '#FFD700' }}
            >
              BazZ
            </span>
            {/* Live indicator */}
            <div className="ml-auto flex items-center gap-1.5">
              <div
                className="live-dot w-2 h-2 rounded-full"
                style={{ background: '#2ECC71' }}
              />
              <span className="text-xs font-medium" style={{ color: 'rgba(255,255,255,0.5)' }}>
                LIVE
              </span>
            </div>
          </div>
          <p
            className="text-xs"
            style={{ color: 'rgba(255,255,255,0.45)', marginLeft: 36, fontFamily: 'Inter, Outfit, sans-serif' }}
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
        <div
          className="px-4 pb-4 border-t pt-4"
          style={{ borderColor: 'rgba(255,255,255,0.1)' }}
        >
          <div
            className="rounded-lg p-3 mb-3"
            style={{ background: 'rgba(255,255,255,0.08)' }}
          >
            <div className="flex items-center gap-2">
              <div
                className="w-8 h-8 rounded-full flex items-center justify-center text-sm font-bold flex-shrink-0"
                style={{ background: '#FFD700', color: '#1A3C6E' }}
              >
                {(admin?.name || 'A')[0].toUpperCase()}
              </div>
              <div className="min-w-0">
                <p
                  className="text-sm font-semibold truncate"
                  style={{ color: '#FFFFFF' }}
                >
                  {admin?.name || 'Admin'}
                </p>
                <p
                  className="text-xs truncate font-mono"
                  style={{ color: 'rgba(255,255,255,0.45)' }}
                >
                  {admin?.phone}
                </p>
              </div>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-2 px-3 py-2 rounded-lg text-sm transition-all duration-150"
            style={{ color: 'rgba(255,255,255,0.55)' }}
            onMouseEnter={(e) => {
              (e.currentTarget as HTMLButtonElement).style.color = '#E53935';
              (e.currentTarget as HTMLButtonElement).style.background = 'rgba(229,57,53,0.12)';
            }}
            onMouseLeave={(e) => {
              (e.currentTarget as HTMLButtonElement).style.color = 'rgba(255,255,255,0.55)';
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
        {/* Top bar — White */}
        <header
          className="flex items-center justify-between px-6 flex-shrink-0 border-b"
          style={{
            height: 56,
            background: '#FFFFFF',
            borderColor: '#E2E8F0',
            boxShadow: '0 1px 3px rgba(0,0,0,0.04)',
          }}
        >
          <PageTitle />
          <div className="flex items-center gap-4">
            <span
              className="text-sm font-mono"
              style={{ color: '#94A3B8' }}
            >
              {format(now, 'EEE, MMM d · HH:mm:ss')}
            </span>
          </div>
        </header>

        {/* Page content */}
        <main className="flex-1 overflow-y-auto" style={{ background: '#F5F7FA' }}>
          <Outlet />
        </main>
      </div>
    </div>
  );
}

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
      style={{ fontFamily: 'Inter, Syne, sans-serif', color: '#1A202C' }}
    >
      {title}
    </h1>
  );
}
