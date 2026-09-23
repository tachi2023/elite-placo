import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ArrowRight, Eye, EyeOff } from 'lucide-react';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import logoImg from '../assets/brand-logo.png';

export default function EspaceClient() {
  const [code, setCode] = useState('');
  const [showCode, setShowCode] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!code.trim()) {
      setError('Veuillez entrer votre code d\'accès.');
      return;
    }
    navigate(`/suivi/${code.trim().toUpperCase()}`);
  };

  return (
    <div className="min-h-screen bg-noir text-texte">
      <Navbar />

      <div className="min-h-screen flex items-center justify-center px-6 pt-20">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="w-full max-w-md"
        >
          {/* Identité de marque */}
          <div className="flex justify-center mb-8">
            <div className="relative">
              <div className="absolute inset-0 rounded-full bg-or/20 blur-2xl animate-pulse" />
              <img src={logoImg} alt="Élite Placo & Déco" className="relative w-full max-w-[290px] h-auto object-contain drop-shadow-[0_0_35px_rgba(201,168,76,0.2)]" />
            </div>
          </div>

          {/* Heading */}
          <div className="text-center mb-12">
            <p className="text-xs tracking-[0.4em] uppercase text-or mb-3 font-light">Accès sécurisé</p>
            <h1 className="font-display text-4xl font-light text-texte mb-3">Espace Client</h1>
            <p className="text-texte-muted text-sm font-light leading-relaxed">
              Entrez le code unique de votre chantier pour accéder à votre espace de suivi personnalisé.
            </p>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label className="block text-xs tracking-[0.3em] uppercase text-texte-muted mb-3">
                Code d'accès chantier
              </label>
              <div className="relative">
                <input
                  type={showCode ? 'text' : 'password'}
                  value={code}
                  onChange={(e) => { setCode(e.target.value); setError(''); }}
                  placeholder="Ex: EPC-8492"
                  className="w-full bg-noir-surface border border-or/20 focus:border-or text-texte text-center tracking-[0.4em] uppercase text-lg px-6 py-4 outline-none transition-colors placeholder:text-texte-muted/30 placeholder:normal-case placeholder:tracking-normal"
                />
                <button
                  type="button"
                  onClick={() => setShowCode(!showCode)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-texte-muted hover:text-texte transition-colors"
                >
                  {showCode ? <EyeOff size={18} /> : <Eye size={18} />}
                </button>
              </div>
              {error && <p className="mt-2 text-xs text-erreur">{error}</p>}
            </div>

            <button
              type="submit"
              className="w-full flex items-center justify-center gap-2 bg-or text-noir font-semibold tracking-widest uppercase text-sm py-4 hover:bg-or-clair transition-all duration-300 group"
            >
              Accéder au dossier
              <ArrowRight size={18} className="group-hover:translate-x-1 transition-transform" />
            </button>
          </form>

          <div className="mt-6 border border-or/20 bg-noir-surface/70 px-5 py-4 text-center">
            <p className="text-[10px] tracking-[0.2em] uppercase text-or mb-2">Accès démonstration</p>
            <button type="button" onClick={() => { setCode('VB-2026-014'); setError(''); }} className="text-sm text-texte hover:text-or transition-colors">
              Utiliser le chantier Villa Bonanjo · VB-2026-014
            </button>
          </div>

          {/* Info */}
          <p className="text-center text-xs text-texte-muted mt-8 leading-relaxed">
            Votre code d'accès vous a été remis par notre équipe lors du démarrage de votre chantier.{' '}
            <Link to="/contact" className="text-or hover:text-or-clair transition-colors">
              Contactez-nous
            </Link>{' '}
            si vous l'avez perdu.
          </p>
        </motion.div>
      </div>

      <Footer />
    </div>
  );
}
