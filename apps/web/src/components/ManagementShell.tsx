import { Link, useLocation } from 'react-router-dom';
import { Home, Building2, BarChart3, Settings } from 'lucide-react';
import BrandLogo from './BrandLogo';

interface ManagementShellProps {
  title: string;
  subtitle?: string;
  children: React.ReactNode;
}

export default function ManagementShell({ title, subtitle, children }: ManagementShellProps) {
  const location = useLocation();

  const navItems = [
    { to: '/', icon: Home, label: 'ACCUEIL' },
    { to: '/chantiers', icon: Building2, label: 'CHANTIERS' },
    { to: '/dashboard', icon: BarChart3, label: 'BILAN' },
    { to: '/parametres', icon: Settings, label: 'RÉGLAGES' },
  ];

  return (
    <div className="min-h-screen bg-[#050505] text-white">
      <div className="mx-auto flex min-h-screen max-w-6xl flex-col px-4 py-4 sm:px-6 lg:px-8">
        <header className="mb-4 rounded-[28px] border border-white/10 bg-[#0E0E10]/90 px-5 py-4 shadow-[0_20px_60px_rgba(0,0,0,0.35)] backdrop-blur-xl">
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-4">
              <BrandLogo titleClassName="text-lg" />
              <div>
              <h1 className="text-xl font-semibold text-white">{title}</h1>
              {subtitle ? <p className="text-sm text-gray-400">{subtitle}</p> : null}
              </div>
            </div>
            <div className="rounded-full border border-[#C9A84C]/30 bg-[#C9A84C]/10 px-3 py-1.5 text-sm font-semibold text-[#C9A84C]">
              04.0511° N · 09.7679° E
            </div>
          </div>
        </header>

        <main className="flex-1 rounded-[32px] border border-white/10 bg-[#0A0A0B] p-4 shadow-[0_20px_70px_rgba(0,0,0,0.4)] sm:p-6">
          {children}
        </main>

        <nav className="mt-4 rounded-[28px] border border-white/10 bg-[#0E0E10]/90 px-2 py-3 shadow-[0_20px_60px_rgba(0,0,0,0.35)] backdrop-blur-xl">
          <div className="grid grid-cols-4 gap-2">
            {navItems.map(({ to, icon: Icon, label }) => {
              const active = location.pathname === to || (to === '/chantiers' && location.pathname.startsWith('/chantiers'));
              return (
                <Link
                  key={to}
                  to={to}
                  className={`flex flex-col items-center rounded-2xl px-2 py-3 text-center text-[11px] font-semibold tracking-[0.2em] transition ${
                    active ? 'bg-[#C9A84C] text-black' : 'text-gray-400 hover:bg-white/5 hover:text-white'
                  }`}
                >
                  <Icon size={18} />
                  <span className="mt-1">{label}</span>
                </Link>
              );
            })}
          </div>
        </nav>
      </div>
    </div>
  );
}
