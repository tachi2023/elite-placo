import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { Loader2, Plus, Search } from 'lucide-react';
import ManagementShell from '../components/ManagementShell';
import { adminRequest } from '../lib/siteApi';

interface Chantier { id: number; nomClient: string; ville: string; typeTravaux: string; statut: string; montantDevis: number; totalEncaisse: number; totalDepenses: number; margeBrutePourcent: number; }
const formatMoney = (value: number) => `${new Intl.NumberFormat('fr-FR').format(value || 0)} FCFA`;
const statusLabel: Record<string, string> = { A_VENIR: 'À venir', EN_COURS: 'En cours', EN_PAUSE: 'En pause', TERMINE: 'Terminé', ARCHIVE: 'Archivé' };

export default function ChantiersPage() {
  const [activeTab, setActiveTab] = useState<'actifs' | 'archives'>('actifs');
  const [query, setQuery] = useState('');
  const [chantiers, setChantiers] = useState<Chantier[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  useEffect(() => {
    let actif = true;
    adminRequest('/api/chantiers').then((data) => { if (actif) setChantiers(data as Chantier[]); }).catch((reason: Error) => { if (actif) setError(reason.message || 'Impossible de charger les chantiers.'); }).finally(() => { if (actif) setLoading(false); });
    return () => { actif = false; };
  }, []);
  const visibles = useMemo(() => chantiers.filter((chantier) => { const matchesTab = activeTab === 'archives' ? chantier.statut === 'ARCHIVE' : chantier.statut !== 'ARCHIVE'; const haystack = `${chantier.nomClient} ${chantier.ville} ${chantier.typeTravaux}`.toLowerCase(); return matchesTab && haystack.includes(query.toLowerCase()); }), [activeTab, chantiers, query]);

  return <ManagementShell title="Chantiers" subtitle="Suivi des chantiers actifs et archivés">
    <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between"><div className="flex w-fit rounded-full border border-white/10 bg-[#121214] p-1">{(['actifs', 'archives'] as const).map((tab) => <button key={tab} type="button" onClick={() => setActiveTab(tab)} className={`rounded-full px-4 py-2 text-sm font-medium ${activeTab === tab ? 'bg-[#C9A84C] text-black' : 'text-gray-400'}`}>{tab === 'actifs' ? 'Actifs' : 'Archives'}</button>)}</div><div className="flex flex-col gap-3 sm:flex-row"><label className="flex items-center gap-2 rounded-full border border-white/10 bg-[#121214] px-4 py-2 text-sm text-gray-400"><Search size={16} /><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Rechercher" className="w-full bg-transparent text-white outline-none placeholder:text-gray-600 sm:w-40" /></label><Link to="/chantiers/new" className="inline-flex items-center justify-center gap-2 rounded-full bg-[#C9A84C] px-4 py-2 text-sm font-semibold text-black"><Plus size={16} /> Nouveau chantier</Link></div></div>
    {loading ? <div className="flex min-h-64 items-center justify-center text-gray-400"><Loader2 className="mr-2 animate-spin" size={20} /> Chargement des chantiers...</div> : error ? <div className="mt-6 rounded-2xl border border-rose-400/30 bg-rose-400/10 p-5 text-rose-200">{error}</div> : <div className="mt-6 grid gap-4 lg:grid-cols-2">{visibles.map((chantier) => <article key={chantier.id} className="rounded-[26px] border border-white/10 bg-[#121214] p-5 transition hover:border-[#C9A84C]/40"><div className="flex items-start justify-between gap-3"><div><h2 className="text-lg font-semibold text-white">{chantier.nomClient}</h2><p className="mt-1 text-sm text-gray-400">{chantier.ville} · {chantier.typeTravaux}</p></div><span className="rounded-full border border-[#C9A84C]/30 bg-[#C9A84C]/10 px-3 py-1 text-xs text-[#C9A84C]">{statusLabel[chantier.statut] || chantier.statut}</span></div><div className="mt-5 grid grid-cols-2 gap-3 text-sm"><div className="rounded-2xl bg-[#0A0A0B] p-3"><p className="text-gray-500">Devis</p><p className="mt-1 font-semibold text-white">{formatMoney(Number(chantier.montantDevis))}</p></div><div className="rounded-2xl bg-[#0A0A0B] p-3"><p className="text-gray-500">Encaissé</p><p className="mt-1 font-semibold text-emerald-300">{formatMoney(Number(chantier.totalEncaisse))}</p></div><div className="rounded-2xl bg-[#0A0A0B] p-3"><p className="text-gray-500">Dépenses</p><p className="mt-1 font-semibold text-rose-300">{formatMoney(Number(chantier.totalDepenses))}</p></div><div className="rounded-2xl bg-[#0A0A0B] p-3"><p className="text-gray-500">Marge</p><p className="mt-1 font-semibold text-[#C9A84C]">{Number(chantier.margeBrutePourcent || 0).toFixed(1)} %</p></div></div></article>)}{!visibles.length ? <div className="lg:col-span-2 rounded-[26px] border border-dashed border-white/10 px-6 py-12 text-center text-gray-400">Aucun chantier {activeTab === 'actifs' ? 'actif' : 'archivé'} ne correspond à votre recherche.</div> : null}</div>}
  </ManagementShell>;
}
