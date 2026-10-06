import { useEffect, useState } from 'react';
import ManagementShell from '../components/ManagementShell';
import { adminRequest } from '../lib/siteApi';

type Statut = 'NOUVELLE' | 'CONTACTEE' | 'DEVIS_ENVOYE' | 'GAGNEE' | 'PERDUE';
type Demande = { id: number; nom: string; email?: string; telephone: string; ville?: string; typeTravaux: string; message?: string; dateCreation: string; statut: Statut };
const statuts: Statut[] = ['NOUVELLE', 'CONTACTEE', 'DEVIS_ENVOYE', 'GAGNEE', 'PERDUE'];

export default function DemandesDevisAdminPage() {
  const [demandes, setDemandes] = useState<Demande[]>([]);
  const [error, setError] = useState('');
  async function load() {
    try { setDemandes(await adminRequest('/api/devis')); } catch (caught) { setError(caught instanceof Error ? caught.message : 'Erreur de chargement'); }
  }
  useEffect(() => { void load(); }, []);
  async function changeStatus(id: number, statut: Statut) {
    await adminRequest(`/api/devis/${id}/statut?statut=${statut}`, { method: 'PATCH' });
    await load();
  }
  return <ManagementShell title="Demandes de devis" subtitle="Suivez les prospects et relances commerciales">
    {error && <p className="mb-4 border border-red-400/30 bg-red-400/10 p-3 text-sm text-red-200">{error}</p>}
    <div className="space-y-3">{demandes.length === 0 && <p className="rounded-2xl border border-dashed border-white/10 p-10 text-center text-gray-400">Aucune demande pour le moment.</p>}
      {demandes.map((demande) => <article key={demande.id} className="rounded-2xl border border-white/10 bg-[#121214] p-5"><div className="flex flex-wrap items-start justify-between gap-4"><div><h2 className="text-lg font-semibold text-white">{demande.nom}</h2><p className="mt-1 text-sm text-gray-400">{demande.telephone}{demande.email ? ` · ${demande.email}` : ''} · {demande.ville || 'Ville non précisée'}</p></div><select value={demande.statut} onChange={(event) => void changeStatus(demande.id, event.target.value as Statut)} className="border border-[#C9A84C]/30 bg-[#0A0A0B] px-3 py-2 text-xs uppercase tracking-[0.12em] text-[#C9A84C]">{statuts.map((statut) => <option key={statut}>{statut}</option>)}</select></div><p className="mt-4 text-sm text-[#C9A84C]">{demande.typeTravaux}</p>{demande.message && <p className="mt-2 text-sm leading-6 text-gray-300">{demande.message}</p>}<p className="mt-3 text-xs text-gray-500">{new Date(demande.dateCreation).toLocaleString('fr-FR')}</p></article>)}
    </div>
  </ManagementShell>;
}
