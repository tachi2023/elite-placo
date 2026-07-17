import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import axios from 'axios';
import { ArrowLeft, Loader2, CheckCircle, Clock, MapPin, ReceiptText } from 'lucide-react';
import { motion } from 'framer-motion';

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

export default function ClientDashboard() {
  const { code } = useParams<{ code: string }>();
  const [data, setData] = useState<ChantierSuivi | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Dans un cas réel, l'URL de l'API serait dans une variable d'environnement
    axios.get(`http://localhost:8080/api/suivi/${code}`)
      .then(res => {
        setData(res.data);
        setLoading(false);
      })
      .catch(err => {
        setError(err.response?.data?.message || "Impossible de charger les informations de ce chantier. Vérifiez votre code.");
        setLoading(false);
      });
  }, [code]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="animate-spin text-or" size={48} />
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center p-6 text-center">
        <div className="bg-anthracite-clair p-8 rounded-2xl border border-erreur/50 max-w-md w-full">
          <h2 className="text-2xl font-display font-bold text-erreur mb-4">Accès refusé</h2>
          <p className="text-gray-400 mb-8">{error}</p>
          <Link to="/" className="text-or hover:underline flex items-center justify-center gap-2">
            <ArrowLeft size={16} /> Retour à l'accueil
          </Link>
        </div>
      </div>
    );
  }

  // Formatage monétaire
  const formatCurrency = (val: number) => {
    return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'XAF', maximumFractionDigits: 0 }).format(val);
  };

  // Formatage date
  const formatDate = (dateStr: string) => {
    if (!dateStr) return '';
    return new Date(dateStr).toLocaleDateString('fr-FR', { day: '2-digit', month: 'long', year: 'numeric' });
  };

  const isTermine = data.statut === 'TERMINE' || data.statut === 'ARCHIVE';

  return (
    <div className="min-h-screen pb-20">
      {/* Header compact */}
      <header className="px-6 py-6 md:px-12 flex items-center border-b border-anthracite-clair bg-anthracite sticky top-0 z-50">
        <Link to="/" className="text-gray-400 hover:text-white transition-colors mr-6">
          <ArrowLeft size={24} />
        </Link>
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-full bg-anthracite-clair border border-or flex items-center justify-center">
            <span className="text-or font-bold text-sm">É</span>
          </div>
          <h1 className="text-lg font-display font-bold tracking-widest text-white">ÉLITE <span className="text-or">PLACO</span></h1>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-6 py-10">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-10"
        >
          <h2 className="text-3xl md:text-4xl font-display font-bold mb-2">Suivi de votre chantier</h2>
          <div className="flex items-center gap-2 text-gray-400">
            <MapPin size={16} className="text-or" />
            <span>{data.ville || 'Lieu non spécifié'}</span>
            <span className="mx-2">•</span>
            <span className="font-semibold text-white">{data.nomClient}</span>
          </div>
        </motion.div>

        <div className="grid md:grid-cols-3 gap-8">
          
          {/* Colonne Principale: Statut & Dépenses */}
          <div className="md:col-span-2 space-y-8">
            
            {/* Carte Avancement */}
            <motion.div 
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.1 }}
              className="bg-anthracite-clair rounded-2xl p-6 border border-gray-800"
            >
              <div className="flex justify-between items-end mb-6">
                <div>
                  <h3 className="text-xl font-display font-semibold mb-1">État d'avancement</h3>
                  <div className="flex items-center gap-2">
                    {isTermine ? (
                      <span className="bg-succes/20 text-succes px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider flex items-center gap-1">
                        <CheckCircle size={14} /> Terminé
                      </span>
                    ) : (
                      <span className="bg-or/20 text-or px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider flex items-center gap-1">
                        <Clock size={14} /> {data.statut.replace('_', ' ')}
                      </span>
                    )}
                  </div>
                </div>
                <span className="text-4xl font-display font-bold text-white">{data.avancementPourcent}%</span>
              </div>
              
              <div className="w-full h-4 bg-anthracite rounded-full overflow-hidden">
                <motion.div 
                  initial={{ width: 0 }}
                  animate={{ width: `${data.avancementPourcent}%` }}
                  transition={{ duration: 1.5, ease: "easeOut" }}
                  className="h-full bg-gradient-to-r from-or to-or-sombre rounded-full"
                ></motion.div>
              </div>
            </motion.div>

            {/* Section Dépenses (Pour rassurer le client) */}
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
            >
              <div className="flex items-center gap-3 mb-6">
                <div className="p-2 bg-anthracite-clair rounded-lg border border-gray-800 text-or">
                  <ReceiptText size={20} />
                </div>
                <h3 className="text-2xl font-display font-semibold">Dépenses effectuées</h3>
              </div>
              <p className="text-gray-400 text-sm mb-6">
                En toute transparence, voici le détail des dépenses en matériaux et logistique engagées sur votre chantier pour assurer une qualité premium.
              </p>

              {data.depenses && data.depenses.length > 0 ? (
                <div className="space-y-4">
                  {data.depenses.map((depense, idx) => (
                    <div key={idx} className="bg-anthracite-clair p-4 rounded-xl border border-gray-800 flex justify-between items-center hover:border-or/30 transition-colors">
                      <div>
                        <h4 className="font-semibold text-white">{depense.description || depense.categorie}</h4>
                        <div className="text-xs text-gray-500 mt-1 flex gap-3">
                          <span>{depense.categorie}</span>
                          <span>•</span>
                          <span>{formatDate(depense.date)}</span>
                        </div>
                      </div>
                      <div className="font-bold text-or">
                        {formatCurrency(depense.montant)}
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="bg-anthracite-clair p-8 rounded-xl border border-gray-800 border-dashed text-center">
                  <p className="text-gray-500">Aucune dépense majeure n'a encore été enregistrée pour ce chantier.</p>
                </div>
              )}
            </motion.div>

          </div>

          {/* Colonne Latérale: Infos */}
          <motion.div 
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.3 }}
            className="space-y-6"
          >
            <div className="bg-anthracite-clair rounded-2xl p-6 border border-gray-800">
              <h4 className="font-display font-bold mb-4 text-or">Notre engagement</h4>
              <p className="text-sm text-gray-400 leading-relaxed mb-4">
                Chez Élite Placo & Déco, nous faisons de la transparence et du respect des délais une priorité absolue. 
                Cet espace vous permet de suivre l'évolution de vos travaux en temps réel.
              </p>
              <div className="pt-4 border-t border-gray-800">
                <p className="text-xs text-gray-500 mb-1">Une question ?</p>
                <p className="text-sm font-semibold text-white">Contactez M. Raoul Michel</p>
                <p className="text-sm text-or">+237 688 92 12 13</p>
              </div>
            </div>
          </motion.div>

        </div>
      </main>
    </div>
  );
}
