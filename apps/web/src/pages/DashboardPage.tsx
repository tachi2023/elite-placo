import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowUpRight, Building2, Loader2, TrendingDown, TrendingUp, Wallet } from 'lucide-react';
import ManagementShell from '../components/ManagementShell';
import { adminRequest } from '../lib/siteApi';

interface Chantier { id: number; nomClient: string; ville: string; typeTravaux: string; statut: string; montantDevis: number; totalEncaisse: number; totalDepenses: number; resultatNet: number; margeBrutePourcent: number; }
const formatMoney = (value: number) => `${new Intl.NumberFormat('fr-FR').format(value || 0)} FCFA`;
const statusLabel: Record<string, string> = { A_VENIR: 'À venir', EN_COURS: 'En cours', EN_PAUSE: 'En pause', TERMINE: 'Terminé', ARCHIVE: 'Archivé' };

export default function DashboardPage() {
  const [chantiers, setChantiers] = useState<Chantier[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  useEffect(() => {
    let actif = true;
    adminRequest('/api/chantiers').then((data) => { if (actif) setChantiers(data as Chantier[]); }).catch((reason: Error) => { if (actif) setError(reason.message || 'Impossible de charger le bilan.'); }).finally(() => { if (actif) setLoading(false); });
    return () => { actif = false; };
  }, []);
  const totals = useMemo(() => chantiers.reduce((acc, chantier) => ({ ca: acc.ca + Number(chantier.montantDevis || 0), encaisse: acc.encaisse + Number(chantier.totalEncaisse || 0), depenses: acc.depenses + Number(chantier.totalDepenses || 0), resultat: acc.resultat + Number(chantier.resultatNet || 0) }), { ca: 0, encaisse: 0, depenses: 0, resultat: 0 }), [chantiers]);
  const marge = totals.ca > 0 ? (totals.resultat / totals.ca) * 100 : 0;
  const cards = [{ title: 'CA signé', value: formatMoney(totals.ca), icon: Building2, accent: 'text-[#C9A84C]' }, { title: 'Encaissé', value: formatMoney(totals.encaisse), icon: Wallet, accent: 'text-emerald-300' }, { title: 'Dépenses', value: formatMoney(totals.depenses), icon: TrendingDown, accent: 'text-rose-300' }, { title: 'Résultat net', value: formatMoney(totals.resultat), icon: TrendingUp, accent: 'text-sky-300' }];

  return <ManagementShell title="Bilan global" subtitle="Vue d’ensemble de la santé financière">
    {loading ? <div className="flex min-h-64 items-center justify-center text-gray-400"><Loader2 className="mr-2 animate-spin" size={20} /> Chargement du bilan...</div> : error ? <div className="rounded-2xl border border-rose-400/30 bg-rose-400/10 p-5 text-rose-200">{error}</div> : <>
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">{cards.map(({ title, value, icon: Icon, accent }) => <div key={title} className="rounded-[24px] border border-white/10 bg-[#121214] p-5"><div className="flex items-center justify-between text-sm text-gray-400"><span>{title}</span><Icon className={accent} size={18} /></div><div className="mt-3 text-2xl font-semibold text-white">{value}</div></div>)}</div>
      <div className="mt-6 rounded-[28px] border border-white/10 bg-[#121214] p-6"><div className="flex flex-wrap items-center justify-between gap-3"><div><h2 className="text-xl font-semibold text-white">Recettes vs dépenses</h2><p className="mt-1 text-sm text-gray-400">Synthèse calculée à partir des chantiers actifs</p></div><div className="rounded-full border border-[#C9A84C]/20 bg-[#C9A84C]/10 px-3 py-1 text-sm text-[#C9A84C]">Marge {marge.toFixed(1)} %</div></div><div className="mt-6 grid gap-3 sm:grid-cols-3"><div className="rounded-2xl bg-[#0A0A0B] p-4"><p className="text-xs uppercase tracking-[0.18em] text-gray-500">Encaissé</p><p className="mt-2 text-lg font-semibold text-emerald-300">{formatMoney(totals.encaisse)}</p></div><div className="rounded-2xl bg-[#0A0A0B] p-4"><p className="text-xs uppercase tracking-[0.18em] text-gray-500">Dépensé</p><p className="mt-2 text-lg font-semibold text-rose-300">{formatMoney(totals.depenses)}</p></div><div className="rounded-2xl bg-[#0A0A0B] p-4"><p className="text-xs uppercase tracking-[0.18em] text-gray-500">Chantiers</p><p className="mt-2 text-lg font-semibold text-white">{chantiers.length}</p></div></div></div>
      <div className="mt-6 rounded-[28px] border border-white/10 bg-[#121214] p-6"><div className="flex items-center justify-between gap-3"><h2 className="text-xl font-semibold text-white">Chantiers récents</h2><Link to="/chantiers" className="inline-flex items-center gap-1 text-sm text-[#C9A84C]">Voir la liste <ArrowUpRight size={15} /></Link></div><div className="mt-4 space-y-3">{chantiers.slice(0, 5).map((chantier) => <div key={chantier.id} className="flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-white/10 bg-[#0A0A0B] px-4 py-4"><div><p className="font-medium text-white">{chantier.nomClient}</p><p className="mt-1 text-sm text-gray-500">{chantier.ville} · {chantier.typeTravaux}</p></div><div className="text-right"><p className="font-medium text-[#C9A84C]">{formatMoney(Number(chantier.montantDevis))}</p><p className="mt-1 text-xs text-gray-500">{statusLabel[chantier.statut] || chantier.statut}</p></div></div>)}{!chantiers.length ? <p className="rounded-2xl border border-dashed border-white/10 px-4 py-8 text-center text-gray-400">Aucun chantier renseigné.</p> : null}</div></div>
    </>}
  </ManagementShell>;
}
