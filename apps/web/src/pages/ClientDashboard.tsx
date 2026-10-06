import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import axios from 'axios';
import { motion } from 'framer-motion';
import { ArrowLeft, Loader2, ShieldCheck, CheckCircle, Clock, MapPin, Download, AlertTriangle } from 'lucide-react';
import { API_BASE_URL } from '../lib/siteApi';

interface ChantierSuivi {
  nomClient: string;
  ville: string;
  statut: string;
  avancementPourcent: number;
  etapes?: { libelle: string; ordre: number; statut: 'A_FAIRE' | 'EN_COURS' | 'TERMINEE'; dateFin?: string }[];
  photos?: { url: string; libelle?: string; avantApres?: string }[];
  documents?: { url: string; libelle?: string }[];
}

const statutLabel: Record<string, string> = {
  'A_VENIR': 'À venir',
  'EN_COURS': 'En cours',
  'EN_PAUSE': 'En pause',
  'TERMINE': 'Terminé',
  'ARCHIVE': 'Archivé',
};

export default function ClientDashboard() {
  const { code } = useParams<{ code: string }>();
  const [data, setData] = useState<ChantierSuivi | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [commentaire, setCommentaire] = useState('');
  const [note, setNote] = useState(5);
  const [avisMessage, setAvisMessage] = useState('');
  const [lent, setLent] = useState(false);

  useEffect(() => {
    const controller = new AbortController();
    const lentTimer = window.setTimeout(() => setLent(true), 6000);
    const timeout = window.setTimeout(() => controller.abort(), 60000);
    axios.get(`${API_BASE_URL}/api/suivi/${code}`, { signal: controller.signal })
      .then(res => setData(res.data))
      .catch(err => {
        const timeoutMessage = err.code === 'ERR_CANCELED'
          ? 'Le serveur met trop de temps à répondre. Patientez une minute puis réessayez.'
          : "Code invalide ou chantier introuvable. Vérifiez votre code.";
        setError(err.response?.data?.message || timeoutMessage);
      })
      .finally(() => {
        window.clearTimeout(timeout);
        window.clearTimeout(lentTimer);
        setLoading(false);
      });
    return () => {
      window.clearTimeout(timeout);
      window.clearTimeout(lentTimer);
      controller.abort();
    };
  }, [code]);

  if (loading) return (
    <div className="min-h-screen bg-noir flex flex-col items-center justify-center gap-6">
      <Loader2 className="animate-spin text-or" size={48} />
      <p className="text-texte-muted text-xs tracking-[0.4em] uppercase animate-pulse">{lent ? 'Réveil du serveur, patientez jusqu’à une minute…' : 'Vérification du code...'}</p>
    </div>
  );

  if (error || !data) return (
    <div className="min-h-screen bg-noir flex items-center justify-center px-6">
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }}
        className="max-w-md w-full bg-noir-surface border border-erreur/30 p-12 text-center"
      >
        <AlertTriangle size={48} className="text-erreur mx-auto mb-6" />
        <h2 className="font-display text-3xl font-light text-texte mb-3">Accès refusé</h2>
        <p className="text-texte-muted text-sm mb-8 font-light">{error}</p>
        <Link
          to="/espace-client"
          className="inline-flex items-center gap-2 bg-or text-noir font-semibold text-xs tracking-widest uppercase px-6 py-3 hover:bg-or-clair transition-all"
        >
          <ArrowLeft size={16} /> Réessayer
        </Link>
      </motion.div>
    </div>
  );

  const isTermine = ['TERMINE', 'ARCHIVE'].includes(data.statut);

  async function envoyerAvis(event: React.FormEvent) {
    event.preventDefault();
    try {
      await axios.post(`${API_BASE_URL}/api/avis`, {
        codePublic: code,
        nomClient: data?.nomClient || 'Client',
        note,
        commentaire,
      });
      setCommentaire('');
      setAvisMessage('Merci. Votre commentaire sera publié après validation.');
    } catch (err: any) {
      setAvisMessage(err.response?.data?.message || 'Impossible d’envoyer le commentaire.');
    }
  }

  return (
    <div className="min-h-screen bg-noir text-texte pb-20">

      {/* Header */}
      <header className="sticky top-0 z-50 glass border-b border-or/10 px-6 py-4 flex justify-between items-center">
        <Link to="/espace-client" className="flex items-center gap-3 hover:text-or transition-colors">
          <ArrowLeft size={18} />
          <span className="text-sm font-semibold uppercase tracking-[0.22em] text-or">Espace client</span>
        </Link>
        <div className="flex items-center gap-2 border border-or/30 px-4 py-2">
          <ShieldCheck size={14} className="text-or" />
          <span className="text-xs tracking-[0.2em] uppercase text-or">Espace Sécurisé</span>
        </div>
      </header>

      <main className="max-w-6xl mx-auto px-6 py-16">

        {/* Title */}
        <motion.div
          initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
          className="mb-16 flex flex-col md:flex-row md:items-end justify-between gap-6"
        >
          <div>
            <p className="text-xs tracking-[0.4em] uppercase text-or mb-3">Dossier client</p>
            <h1 className="font-display text-4xl md:text-5xl font-light text-texte mb-4">
              Bonjour, {data.nomClient}
            </h1>
            <div className="flex flex-wrap items-center gap-3">
              <span className="inline-flex items-center gap-1.5 text-xs text-texte-muted border border-or/20 px-3 py-1.5">
                <MapPin size={12} className="text-or" /> {data.ville || 'Douala'}
              </span>
              <span className={`inline-flex items-center gap-1.5 text-xs px-3 py-1.5 border ${
                isTermine ? 'border-succes/30 text-succes' : 'border-or/30 text-or'
              }`}>
                {isTermine ? <CheckCircle size={12} /> : <Clock size={12} />}
                {statutLabel[data.statut] || data.statut}
              </span>
            </div>
          </div>
          <button onClick={() => window.print()} className="inline-flex items-center gap-2 border border-or/20 text-texte-muted hover:border-or hover:text-or text-xs tracking-widest uppercase px-5 py-3 transition-all">
            <Download size={16} /> Exporter le rapport
          </button>
        </motion.div>

        <div className="grid lg:grid-cols-3 gap-8">

          {/* Main content */}
          <div className="lg:col-span-2 space-y-8">

            {/* Avancement */}
            <motion.div
              initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
              className="bg-noir-surface border border-or/20 p-6 sm:p-10"
            >
              <div className="flex justify-between items-end mb-8">
                <div>
                  <p className="text-xs tracking-[0.3em] uppercase text-or mb-2">État d'avancement</p>
                  <h2 className="font-display text-3xl font-light text-texte">Avancement du chantier</h2>
                </div>
                <span className="font-display text-6xl font-light text-or">{data.avancementPourcent}%</span>
              </div>
              <div className="w-full h-1 bg-or/20">
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: `${data.avancementPourcent}%` }}
                  transition={{ duration: 1.5, ease: "easeOut", delay: 0.4 }}
                  className="h-full bg-or"
                />
              </div>
              <div className="flex justify-between mt-3 text-xs text-texte-muted tracking-widest uppercase">
                <span>Démarrage</span>
                <span>Réception</span>
              </div>
            </motion.div>

            {data.etapes && <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.18 }} className="bg-noir-surface border border-or/20 p-6 sm:p-10">
              <p className="text-xs tracking-[0.3em] uppercase text-or mb-2">Étapes du chantier</p>
              <h2 className="font-display text-3xl font-light text-texte mb-6">Le parcours de réalisation</h2>
              {data.etapes.length === 0 ? <p className="border border-dashed border-white/10 px-5 py-8 text-center text-sm text-texte-muted">Les étapes seront publiées par notre équipe prochainement.</p> : <div className="space-y-3">{data.etapes.map((etape) => <div key={`${etape.ordre}-${etape.libelle}`} className="flex items-center gap-4 border-b border-white/10 pb-3 last:border-0"><span className={`h-3 w-3 rounded-full ${etape.statut === 'TERMINEE' ? 'bg-succes' : etape.statut === 'EN_COURS' ? 'bg-or animate-pulse' : 'bg-texte-muted/40'}`} /><span className="flex-1 text-sm text-texte">{etape.libelle}</span><span className="text-[10px] uppercase tracking-[0.15em] text-texte-muted">{etape.statut === 'TERMINEE' ? 'Terminée' : etape.statut === 'EN_COURS' ? 'En cours' : 'À faire'}</span></div>)}</div>}
            </motion.div>}

            {data.photos && <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.22 }} className="bg-noir-surface border border-or/20 p-6 sm:p-10">
              <p className="text-xs tracking-[0.3em] uppercase text-or mb-2">Journal visuel</p>
              <h2 className="font-display text-3xl font-light text-texte mb-6">Dernières réalisations</h2>
              {data.photos.length === 0 ? <p className="border border-dashed border-white/10 px-5 py-8 text-center text-sm text-texte-muted">Aucune photo n’a encore été publiée pour ce chantier.</p> : <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">{data.photos.map((photo) => <figure key={photo.url} className="overflow-hidden border border-white/10 bg-noir"><img src={photo.url} alt={photo.libelle || 'Photo du chantier'} className="aspect-square w-full object-cover transition duration-500 hover:scale-105" /><figcaption className="p-2 text-[10px] uppercase tracking-[0.12em] text-texte-muted">{[photo.libelle, photo.avantApres].filter(Boolean).join(' · ') || 'Chantier'}</figcaption></figure>)}</div>}
            </motion.div>}

            {data.documents && <div className="bg-noir-surface border border-or/20 p-6 sm:p-10"><p className="text-xs tracking-[0.3em] uppercase text-or mb-2">Documents partagés</p>{data.documents.length === 0 ? <p className="border border-dashed border-white/10 px-5 py-8 text-center text-sm text-texte-muted">Aucun document n’est disponible pour le moment.</p> : <div className="space-y-2">{data.documents.map((document) => <a key={document.url} href={document.url} target="_blank" rel="noreferrer" className="block border border-white/10 p-3 text-sm text-texte hover:border-or hover:text-or">{document.libelle || 'Document du chantier'}</a>)}</div>}</div>}

            <motion.div
              initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}
              className="bg-noir-surface border border-or/20 p-6 sm:p-10"
            >
              <div className="mb-6">
                <p className="text-xs tracking-[0.3em] uppercase text-or mb-2">Informations publiques</p>
                <h2 className="font-display text-3xl font-light text-texte">Suivi de chantier</h2>
              </div>
              <div className="rounded-none border border-or/20 bg-noir px-5 py-6">
                <p className="text-sm leading-relaxed text-texte-muted font-light">
                  Les montants, encaissements et dépenses restent strictement réservés à l’équipe interne. Votre espace client affiche uniquement le statut, la ville et l’avancement du chantier.
                </p>
              </div>
            </motion.div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            <motion.div
              initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.3 }}
              className="bg-noir-surface border border-or/20 p-8"
            >
              <ShieldCheck size={24} className="text-or mb-4" />
              <h3 className="font-display text-xl font-light text-texte mb-3">Suivi en temps réel</h3>
              <p className="text-texte-muted text-sm leading-relaxed font-light mb-6">
                Cet espace est mis à jour directement par nos chefs d'équipe sur le terrain. Vous avez une visibilité totale sur votre investissement.
              </p>
              <div className="border-t border-or/20 pt-6">
                <p className="text-xs tracking-[0.2em] uppercase text-or mb-2">Responsable chantier</p>
                <p className="text-texte font-medium">M. Raoul Michel</p>
                <a href="tel:+237688921213" className="text-sm text-or hover:text-or-clair transition-colors mt-1 block">
                  +237 688 92 12 13
                </a>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.4 }}
              className="bg-noir-surface border border-or/20 p-8 text-center"
            >
              <CheckCircle size={24} className="text-or mx-auto mb-3" />
              <p className="text-xs text-texte-muted leading-relaxed font-light">
                Données chiffrées et synchronisées en temps réel avec l'application métier Elite Placo & Déco.
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.45 }}
              className="bg-noir-surface border border-or/20 p-8"
            >
              <p className="text-xs tracking-[0.2em] uppercase text-or mb-2">Votre expérience</p>
              <h3 className="font-display text-2xl font-light text-texte mb-4">Laisser un commentaire</h3>
              <form onSubmit={envoyerAvis} className="space-y-3">
                <div className="flex gap-1" aria-label="Note sur cinq">
                  {[1, 2, 3, 4, 5].map((value) => <button type="button" key={value} onClick={() => setNote(value)} className={value <= note ? 'text-or text-xl' : 'text-texte-muted text-xl'} aria-label={`${value} étoile${value > 1 ? 's' : ''}`}>★</button>)}
                </div>
                <textarea value={commentaire} onChange={(event) => setCommentaire(event.target.value)} required maxLength={1200} rows={4} placeholder="Votre commentaire" className="w-full border border-or/20 bg-noir px-3 py-3 text-sm text-texte outline-none focus:border-or" />
                {avisMessage && <p className="text-xs text-texte-muted">{avisMessage}</p>}
                <button className="w-full bg-or px-4 py-3 text-xs font-semibold uppercase tracking-[0.15em] text-noir">Envoyer</button>
              </form>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.5 }}
              className="bg-or p-8"
            >
              <p className="text-xs tracking-[0.2em] uppercase text-noir mb-3 font-semibold">Besoin d'aide ?</p>
              <p className="text-noir/80 text-sm mb-4 font-light">Une question sur votre chantier ? Notre équipe est disponible.</p>
              <Link
                to="/contact"
                className="inline-flex items-center gap-2 bg-noir text-or text-xs tracking-widest uppercase px-4 py-2.5 hover:bg-noir-surface transition-colors"
              >
                Nous contacter <ArrowLeft size={14} className="rotate-180" />
              </Link>
            </motion.div>
          </div>
        </div>
      </main>
    </div>
  );
}
