import { useEffect, useState } from 'react';
import type { FormEvent } from 'react';
import { Check, ImagePlus, LogOut, Save, X } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import ManagementShell from '../components/ManagementShell';
import { adminRequest } from '../lib/siteApi';
import type { ClientReview, SiteContent } from '../lib/siteApi';

const emptyContent: SiteContent = { type: 'REALISATIONS', cle: '', titre: '', description: '', imageUrl: '', ordre: 1 };

export default function SiteContentAdminPage() {
  const navigate = useNavigate();
  const [contents, setContents] = useState<SiteContent[]>([]);
  const [reviews, setReviews] = useState<ClientReview[]>([]);
  const [draft, setDraft] = useState<SiteContent>(emptyContent);
  const [message, setMessage] = useState('');

  async function load() {
    try {
      const [contentData, reviewData] = await Promise.all([
        adminRequest('/api/contenu-site/type/REALISATIONS'),
        adminRequest('/api/avis'),
      ]);
      setContents(contentData);
      setReviews(reviewData);
    } catch {
      navigate('/admin/login');
    }
  }

  useEffect(() => { void load(); }, []);

  async function saveContent(event: FormEvent) {
    event.preventDefault();
    const isEdit = Boolean(draft.id);
    await adminRequest(isEdit ? `/api/contenu-site/${draft.id}` : '/api/contenu-site', {
      method: isEdit ? 'PUT' : 'POST', body: JSON.stringify(draft),
    });
    setDraft(emptyContent);
    setMessage('Réalisation mise à jour.');
    await load();
  }

  async function moderate(review: ClientReview, statut: 'APPROUVE' | 'REJETE') {
    await adminRequest(`/api/avis/${review.id}/statut`, { method: 'PATCH', body: JSON.stringify({ statut }) });
    await load();
  }

  function logout() {
    localStorage.removeItem('elite_access_token');
    localStorage.removeItem('elite_refresh_token');
    navigate('/admin/login');
  }

  return (
    <ManagementShell title="Contenu du site" subtitle="Images des chantiers et avis clients">
      <div className="mb-6 flex justify-end"><button onClick={logout} className="inline-flex items-center gap-2 text-xs uppercase tracking-[0.15em] text-gray-400 hover:text-or"><LogOut size={15} /> Déconnexion</button></div>
      {message && <div className="mb-5 border border-[#4CAF7D]/30 bg-[#4CAF7D]/10 px-4 py-3 text-sm text-[#8de0ae]">{message}</div>}
      <section className="grid gap-6 xl:grid-cols-[1.2fr_0.8fr]">
        <div className="space-y-4">
          <div className="flex items-center gap-2"><ImagePlus className="text-[#C9A84C]" size={19} /><h2 className="text-xl font-semibold text-white">Réalisations publiées</h2></div>
          {contents.map((content) => <article key={content.id} className="flex gap-4 rounded-[22px] border border-white/10 bg-[#121214] p-4">
            <img src={content.imageUrl || '/assets/hero_bg.jpg'} alt="" className="h-24 w-32 object-cover" />
            <div className="min-w-0 flex-1"><h3 className="font-semibold text-white">{content.titre}</h3><p className="mt-1 line-clamp-2 text-sm text-gray-400">{content.description}</p><p className="mt-2 truncate text-xs text-[#C9A84C]">{content.imageUrl}</p></div>
            <button onClick={() => setDraft(content)} className="self-start text-xs uppercase tracking-[0.15em] text-[#C9A84C]">Modifier</button>
          </article>)}
        </div>
        <form onSubmit={saveContent} className="h-fit rounded-[24px] border border-[#C9A84C]/25 bg-[#121214] p-6">
          <h2 className="text-xl font-semibold text-white">{draft.id ? 'Modifier une image' : 'Ajouter une réalisation'}</h2>
          <p className="mt-2 text-sm leading-6 text-gray-400">Utilisez l’URL permanente de l’image. Cela évite de perdre les fichiers lors d’un redéploiement.</p>
          <div className="mt-5 space-y-3"><input required value={draft.titre || ''} onChange={(event) => setDraft({ ...draft, titre: event.target.value })} placeholder="Titre du chantier" className="w-full border border-white/10 bg-[#0A0A0B] px-4 py-3 text-sm text-white outline-none focus:border-[#C9A84C]" /><input value={draft.cle || ''} onChange={(event) => setDraft({ ...draft, cle: event.target.value })} placeholder="Clé unique, ex. villa-bonanjo" className="w-full border border-white/10 bg-[#0A0A0B] px-4 py-3 text-sm text-white outline-none focus:border-[#C9A84C]" /><input required type="url" value={draft.imageUrl || ''} onChange={(event) => setDraft({ ...draft, imageUrl: event.target.value })} placeholder="https://.../photo.jpg" className="w-full border border-white/10 bg-[#0A0A0B] px-4 py-3 text-sm text-white outline-none focus:border-[#C9A84C]" /><textarea value={draft.description || ''} onChange={(event) => setDraft({ ...draft, description: event.target.value })} placeholder="Description" rows={4} className="w-full border border-white/10 bg-[#0A0A0B] px-4 py-3 text-sm text-white outline-none focus:border-[#C9A84C]" /></div>
          <div className="mt-5 flex gap-3"><button type="submit" className="inline-flex flex-1 items-center justify-center gap-2 bg-[#C9A84C] px-4 py-3 text-xs font-semibold uppercase tracking-[0.15em] text-black"><Save size={15} /> Enregistrer</button><button type="button" onClick={() => setDraft(emptyContent)} className="border border-white/10 px-4 py-3 text-xs uppercase tracking-[0.15em] text-gray-400">Annuler</button></div>
        </form>
      </section>
      <section className="mt-10"><h2 className="mb-4 text-xl font-semibold text-white">Avis clients à modérer</h2><div className="space-y-3">{reviews.length === 0 && <p className="rounded-[20px] border border-dashed border-white/10 p-8 text-center text-gray-400">Aucun avis reçu.</p>}{reviews.map((review) => <article key={review.id} className="rounded-[20px] border border-white/10 bg-[#121214] p-5"><div className="flex flex-wrap items-center justify-between gap-3"><div><strong className="text-white">{review.nomClient}</strong><span className="ml-3 text-[#C9A84C]">{'★'.repeat(review.note)}{'☆'.repeat(5 - review.note)}</span></div><span className="text-xs uppercase tracking-[0.15em] text-gray-500">{review.statut}</span></div><p className="mt-3 text-sm leading-6 text-gray-300">{review.commentaire}</p>{review.statut === 'EN_ATTENTE' && <div className="mt-4 flex gap-2"><button onClick={() => void moderate(review, 'APPROUVE')} className="inline-flex items-center gap-2 bg-[#4CAF7D] px-3 py-2 text-xs font-semibold uppercase tracking-[0.12em] text-black"><Check size={14} /> Publier</button><button onClick={() => void moderate(review, 'REJETE')} className="inline-flex items-center gap-2 border border-[#E05555]/40 px-3 py-2 text-xs uppercase tracking-[0.12em] text-[#E05555]"><X size={14} /> Rejeter</button></div>}</article>)}</div></section>
    </ManagementShell>
  );
}
