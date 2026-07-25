import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import axios from 'axios';
import { motion } from 'framer-motion';
import { ArrowLeft, Loader2, ShieldCheck, CheckCircle, Clock, MapPin, ReceiptText, Download, AlertTriangle } from 'lucide-react';

interface Depense {
  description: string;
  categorie: string;
  montant: number;
  date: string;
}

interface ChantierSuivi {
  nomClient: string;
  ville: string;
  statut: string;
  avancementPourcent: number;
  depenses: Depense[];
}

const statutLabel: Record<string, string> = {
  'A_VENIR': 'à€ venir',
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

  useEffect(() => {
    axios.get(`http://localhost:8080/api/suivi/${code}`)
      .then(res => { setData(res.data); setLoading(false); })
      .catch(err => {
        setError(err.response?.data?.message || "Code invalide ou chantier introuvable. Vérifiez votre code.");
        setLoading(false);
      });
  }, [code]);

  const formatCurrency = (val: number) =>
    new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XAF', maximumFractionDigits: 0 }).format(val);

  const formatDate = (d: string) =>
    d ? new Date(d).toLocaleDateString('fr-FR', { day: '2-digit', month: 'long', year: 'numeric' }) : '';

  if (loading) return (
    <div className="min-h-screen bg-noir flex flex-col items-center justify-center gap-6">
      <Loader2 className="animate-spin text-or" size={48} />
      <p className="text-texte-muted text-xs tracking-[0.4em] uppercase animate-pulse">Vérification du code...</p>
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
  const totalDepenses = data.depenses?.reduce((sum, d) => sum + d.montant, 0) || 0;

  return (
    <div className="min-h-screen bg-noir text-texte pb-20">

      {/* Header */}
      <header className="sticky top-0 z-50 glass border-b border-or/10 px-6 py-4 flex justify-between items-center">
        <Link to="/espace-client" className="flex items-center gap-3 hover:text-or transition-colors">
          <ArrowLeft size={18} />
          <div>
            <div className="font-display text-lg font-semibold tracking-widest text-texte">Élite Placo & Déco</div>
            <div className="text-[10px] tracking-[0.3em] text-or uppercase">PRIMA BTP</div>
          </div>
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
          <button className="inline-flex items-center gap-2 border border-or/20 text-texte-muted hover:border-or hover:text-or text-xs tracking-widest uppercase px-5 py-3 transition-all">
            <Download size={16} /> Exporter le rapport
          </button>
        </motion.div>

        <div className="grid lg:grid-cols-3 gap-8">

          {/* Main content */}
          <div className="lg:col-span-2 space-y-8">

            {/* Avancement */}
            <motion.div
              initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
              className="bg-noir-surface border border-or/20 p-10"
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

            {/* Dépenses */}
            <motion.div
              initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}
              className="bg-noir-surface border border-or/20 p-10"
            >
              <div className="flex items-center justify-between mb-8">
                <div>
                  <p className="text-xs tracking-[0.3em] uppercase text-or mb-2">Transparence totale</p>
                  <h2 className="font-display text-3xl font-light text-texte">Dépenses engagées</h2>
                </div>
                <ReceiptText size={24} className="text-or" />
              </div>

              {data.depenses && data.depenses.length > 0 ? (
                <>
                  <div className="space-y-3 mb-6">
                    {data.depenses.map((d, idx) => (
                      <motion.div
                        key={idx}
                        initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.3 + idx * 0.08 }}
                        className="flex justify-between items-center border-b border-or/20 pb-3 hover:border-or/30 transition-colors"
                      >
                        <div>
                          <p className="text-sm text-texte font-light">{d.description || d.categorie}</p>
                          <p className="text-xs text-texte-muted mt-0.5">{d.categorie} · {formatDate(d.date)}</p>
                        </div>
                        <span className="font-display text-or text-lg">{formatCurrency(d.montant)}</span>
                      </motion.div>
                    ))}
                  </div>
                  <div className="flex justify-between items-center pt-4 border-t border-or/20">
                    <span className="text-xs tracking-widest uppercase text-texte-muted">Total engagé</span>
                    <span className="font-display text-2xl text-or">{formatCurrency(totalDepenses)}</span>
                  </div>
                </>
              ) : (
                <div className="border border-or/20 border-dashed p-10 text-center">
                  <ReceiptText size={32} className="text-texte-muted mx-auto mb-3" />
                  <p className="text-texte font-light">Aucune dépense enregistrée</p>
                  <p className="text-xs text-texte-muted mt-1">Les dépenses apparaîtront ici au fur et à mesure.</p>
                </div>
              )}
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
              className="bg-nor-surface border border-or/20 p-8 text-center"
            >
              <CheckCircle size={24} className="text-or mx-auto mb-3" />
              <p className="text-xs text-texte-muted leading-relaxed font-light">
                Données chiffrées et synchronisées en temps réel avec l'application métier Elite Placo & Déco.
              </p>
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
