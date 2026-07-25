import { useState } from 'react';
import { Link } from 'react-router-dom';
import { Plus } from 'lucide-react';
import ManagementShell from '../components/ManagementShell';

export default function ChantiersPage() {
  const [activeTab, setActiveTab] = useState<'actifs' | 'archives'>('actifs');

  return (
    <ManagementShell title="Chantiers" subtitle="Suivi des chantiers actifs et archivés">
      <div className="flex items-center justify-between gap-3">
        <div className="flex rounded-full border border-white/10 bg-[#121214] p-1">
          <button
            type="button"
            onClick={() => setActiveTab('actifs')}
            className={`rounded-full px-4 py-2 text-sm font-medium ${activeTab === 'actifs' ? 'bg-[#C9A84C] text-black' : 'text-gray-400'}`}
          >
            Actifs
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('archives')}
            className={`rounded-full px-4 py-2 text-sm font-medium ${activeTab === 'archives' ? 'bg-[#C9A84C] text-black' : 'text-gray-400'}`}
          >
            Archives
          </button>
        </div>

        <Link to="/chantiers/new" className="inline-flex items-center gap-2 rounded-full bg-[#C9A84C] px-4 py-2 text-sm font-semibold text-black">
          <Plus size={16} /> Nouveau chantier
        </Link>
      </div>

      <div className="mt-6 rounded-[28px] border border-white/10 bg-[#121214] p-8 text-center text-gray-400">
        {activeTab === 'actifs' ? 'Aucun chantier actif.' : 'Aucun chantier archivé.'}
      </div>
    </ManagementShell>
  );
}
