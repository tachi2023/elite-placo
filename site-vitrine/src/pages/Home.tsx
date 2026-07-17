import React from 'react';
import { useNavigate } from 'react-router-dom';
import { HardHat, Ruler, Paintbrush, ArrowRight, ShieldCheck } from 'lucide-react';
import { motion } from 'framer-motion';

export default function Home() {
  const [code, setCode] = React.useState('');
  const navigate = useNavigate();

  const handleSuiviSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (code.trim()) {
      navigate(`/suivi/${code.trim()}`);
    }
  };

  return (
    <div className="flex flex-col min-h-screen">
      {/* Header */}
      <header className="px-6 py-8 md:px-12 flex justify-between items-center border-b border-anthracite-clair">
        <div className="flex items-center gap-2">
          <div className="w-10 h-10 rounded-full bg-anthracite-clair border border-or flex items-center justify-center glow-effect">
            <span className="text-or font-bold text-xl">É</span>
          </div>
          <h1 className="text-2xl font-display font-bold tracking-widest text-white">ÉLITE <span className="text-or">PLACO</span></h1>
        </div>
        <nav className="hidden md:flex gap-8 text-sm uppercase tracking-wider font-semibold">
          <a href="#services" className="hover:text-or transition-colors">Services</a>
          <a href="#realisations" className="hover:text-or transition-colors">Réalisations</a>
          <a href="#suivi" className="hover:text-or transition-colors">Espace Client</a>
        </nav>
      </header>

      {/* Hero Section */}
      <main className="flex-1 flex flex-col justify-center px-6 md:px-12 py-20 relative overflow-hidden">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-or opacity-5 blur-[150px] rounded-full pointer-events-none"></div>
        
        <div className="max-w-4xl mx-auto text-center z-10">
          <motion.h2 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="text-5xl md:text-7xl font-display font-bold mb-6 leading-tight"
          >
            L'Excellence du <span className="text-transparent bg-clip-text bg-gradient-to-r from-or to-or-sombre">Plafond</span> & de la <span className="text-transparent bg-clip-text bg-gradient-to-r from-or to-or-sombre">Décoration</span>
          </motion.h2>
          <motion.p 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="text-lg md:text-xl text-gray-400 mb-12 max-w-2xl mx-auto"
          >
            Transformez vos espaces avec nos solutions d'aménagement intérieur haut de gamme. Un savoir-faire artisanal couplé à une précision d'orfèvre.
          </motion.p>
        </div>

        {/* Espace Suivi Client Direct */}
        <motion.div 
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8, delay: 0.4 }}
          id="suivi" 
          className="max-w-md mx-auto w-full bg-anthracite-clair p-8 rounded-2xl border border-or/20 shadow-2xl relative z-10"
        >
          <div className="flex items-center gap-3 mb-6">
            <ShieldCheck className="text-or" size={24} />
            <h3 className="text-xl font-display font-semibold">Suivre votre chantier</h3>
          </div>
          <form onSubmit={handleSuiviSubmit} className="flex flex-col gap-4">
            <input 
              type="text" 
              placeholder="Code d'accès (ex: ABC1234)"
              value={code}
              onChange={(e) => setCode(e.target.value)}
              className="bg-anthracite border border-gray-800 text-white px-4 py-3 rounded-xl focus:outline-none focus:border-or transition-colors uppercase"
              required
            />
            <button 
              type="submit"
              className="bg-or text-anthracite font-bold py-3 rounded-xl hover:bg-or-sombre transition-colors flex items-center justify-center gap-2"
            >
              Accéder au suivi <ArrowRight size={18} />
            </button>
          </form>
        </motion.div>
      </main>

      {/* Services Mini-Section */}
      <section id="services" className="bg-anthracite-clair py-20 px-6 md:px-12">
        <div className="max-w-6xl mx-auto grid md:grid-cols-3 gap-8">
          <div className="bg-anthracite p-8 rounded-2xl border border-gray-800 hover:border-or/50 transition-colors">
            <HardHat className="text-or mb-4" size={40} />
            <h4 className="text-xl font-display font-bold mb-2">Plafonds Placoplâtre</h4>
            <p className="text-gray-400 text-sm">Réalisation de plafonds suspendus, BA13, isolations phoniques et thermiques avec une finition parfaite.</p>
          </div>
          <div className="bg-anthracite p-8 rounded-2xl border border-gray-800 hover:border-or/50 transition-colors">
            <Paintbrush className="text-or mb-4" size={40} />
            <h4 className="text-xl font-display font-bold mb-2">Décoration Intérieure</h4>
            <p className="text-gray-400 text-sm">Conception d'éléments décoratifs, niches éclairées, corniches et habillages muraux sur-mesure.</p>
          </div>
          <div className="bg-anthracite p-8 rounded-2xl border border-gray-800 hover:border-or/50 transition-colors">
            <Ruler className="text-or mb-4" size={40} />
            <h4 className="text-xl font-display font-bold mb-2">Métrage Précis</h4>
            <p className="text-gray-400 text-sm">Devis transparents et calculs exacts des matériaux pour une gestion de projet sans mauvaises surprises.</p>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-8 text-center text-gray-500 text-sm border-t border-anthracite-clair">
        <p>&copy; {new Date().getFullYear()} Élite Placo & Déco. Tous droits réservés.</p>
      </footer>
    </div>
  );
}
