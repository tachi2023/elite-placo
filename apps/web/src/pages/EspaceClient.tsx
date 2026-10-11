import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ArrowLeft, ArrowRight, Eye, EyeOff, ShieldCheck } from 'lucide-react';
import BrandLogo from '../components/BrandLogo';

export default function EspaceClient() {
  const [code, setCode] = useState('');
  const [showCode, setShowCode] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const goBackToSite = () => {
    if (document.referrer.startsWith(window.location.origin)) navigate(-1);
    else navigate('/');
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!code.trim()) {
      setError('Veuillez entrer votre code d\'accès.');
      return;
    }
    navigate(`/suivi/${code.trim().toUpperCase()}`);
  };

  const openDemo = () => navigate('/suivi/VB-2026-014');

  return (
    <div className="min-h-screen bg-noir text-texte">
      <div className="mx-auto flex min-h-screen w-full max-w-6xl flex-col px-5 py-6 sm:px-8">
        <button
          type="button"
          onClick={goBackToSite}
          className="inline-flex w-fit items-center gap-2 text-[10px] uppercase tracking-[0.28em] text-texte-muted transition-colors hover:text-or"
        >
          <ArrowLeft size={15} /> Retour au site
        </button>

        <div className="flex flex-1 items-center justify-center py-10 sm:py-16">
          <motion.div
            initial={{ opacity: 0, y: 26 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.75 }}
            className="w-full max-w-xl rounded-[32px] border border-or/20 bg-noir-surface/80 p-6 shadow-[0_20px_80px_rgba(0,0,0,0.45)] backdrop-blur-sm sm:p-10"
          >
            <div className="mb-8 flex items-center justify-between gap-3 border-b border-or/15 pb-5">
              <div className="flex min-w-0 items-center gap-4">
                <BrandLogo titleClassName="text-xl" />
                <span className="hidden h-8 w-px bg-or/20 sm:block" />
                <p className="font-display text-xl font-light text-texte sm:text-2xl">Espace Client</p>
              </div>
              <div className="inline-flex items-center gap-2 rounded-full border border-or/20 bg-or/5 px-2.5 py-1.5 text-[9px] uppercase tracking-[0.2em] text-or">
                <ShieldCheck size={12} /> Sécurisé
              </div>
            </div>

            <div className="mb-8 text-center">
              <p className="mb-3 text-[10px] tracking-[0.38em] uppercase text-or">Accès sécurisé</p>
              <h1 className="font-display text-4xl font-light text-texte sm:text-5xl">Suivi de chantier</h1>
              <p className="mt-4 text-sm leading-relaxed text-texte-muted">
                Entrez le code unique de votre chantier pour accéder à votre espace de suivi personnalisé.
              </p>
            </div>

            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <label htmlFor="client-access-code" className="mb-3 block text-[10px] tracking-[0.34em] uppercase text-texte-muted">
                  Code d'accès chantier
                </label>
                <div className="relative">
                  <input
                    id="client-access-code"
                    type={showCode ? 'text' : 'password'}
                    value={code}
                    onChange={(e) => { setCode(e.target.value); setError(''); }}
                    placeholder="Ex: VB-2026-014"
                    className="w-full rounded-2xl border border-or/20 bg-noir px-6 py-4 text-center text-lg uppercase tracking-[0.35em] text-texte outline-none transition-all placeholder:text-texte-muted/30 placeholder:normal-case placeholder:tracking-normal focus:border-or focus:shadow-[0_0_0_3px_rgba(201,168,76,0.12)]"
                  />
                  <button
                    type="button"
                    onClick={() => setShowCode(!showCode)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-texte-muted transition-colors hover:text-texte"
                    aria-label={showCode ? 'Masquer le code' : 'Afficher le code'}
                  >
                    {showCode ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
                {error && <p className="mt-2 text-xs text-erreur">{error}</p>}
              </div>

              <button
                type="submit"
                className="group flex w-full items-center justify-center gap-2 rounded-full bg-or px-5 py-4 text-[11px] font-semibold uppercase tracking-[0.22em] text-noir transition-all duration-300 hover:bg-or-clair"
              >
                Accéder au dossier
                <ArrowRight size={18} className="transition-transform group-hover:translate-x-1" />
              </button>
            </form>

            <div className="mt-6 rounded-2xl border border-or/20 bg-noir/40 px-4 py-4 text-center">
              <p className="mb-2 text-[9px] tracking-[0.28em] uppercase text-or">Accès démonstration</p>
              <button
                type="button"
                onClick={openDemo}
                className="text-sm text-texte transition-colors hover:text-or"
              >
                Ouvrir le chantier de démonstration · VB-2026-014
              </button>
            </div>

            <p className="mt-8 text-center text-xs leading-relaxed text-texte-muted">
              Votre code d'accès vous a été remis par notre équipe lors du démarrage de votre chantier.{' '}
              <Link to="/contact" className="text-or transition-colors hover:text-or-clair">
                Contactez-nous
              </Link>{' '}
              si vous l'avez perdu.
            </p>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
