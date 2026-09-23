import { useState } from 'react';
import { motion } from 'framer-motion';
import { useEffect } from 'react';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import { fetchPublicRealisations, usableImageUrl } from '../lib/siteApi';

const categories = ['Tous', 'Résidentiel', 'Hôtellerie', 'Commercial'];

const fallbackRealisations = [
  { title: 'Villa Bonanjo', location: 'Douala', cat: 'Résidentiel', img: '/assets/realisations/villa.jpg' },
  { title: 'Hôtel Le Méridien', location: 'Douala', cat: 'Hôtellerie', img: '/assets/realisations/hotel.jpg' },
  { title: 'Siège Corporate', location: 'Akwa', cat: 'Commercial', img: '/assets/realisations/corporate.jpg' },
  { title: 'Résidence Bonapriso', location: 'Douala', cat: 'Résidentiel', img: '/assets/realisations/residence.jpg' },
  { title: 'Suite Présidentielle', location: 'Kribi', cat: 'Hôtellerie', img: '/assets/realisations/suite.jpg' },
  { title: 'Restaurant Étoile', location: 'Bonanjo', cat: 'Commercial', img: '/assets/realisations/restaurant.jpg' },
];

export default function Realisations() {
  const [realisations, setRealisations] = useState(fallbackRealisations);
  const [active, setActive] = useState('Tous');
  useEffect(() => {
    fetchPublicRealisations().then((items) => {
      if (items.length > 0) setRealisations(items.map((item) => ({
        title: item.titre || 'Réalisation Élite Placo',
        location: item.cle?.split('-').slice(-1)[0] || 'Cameroun',
        cat: 'Résidentiel',
        img: usableImageUrl(item.imageUrl, '/assets/hero_bg.jpg'),
      })));
    }).catch(() => undefined);
  }, []);
  const filtered = active === 'Tous' ? realisations : realisations.filter(r => r.cat === active);

  return (
    <div className="min-h-screen bg-noir text-texte">
      <Navbar />

      {/* Header */}
      <div className="pt-40 pb-16 w-full px-6 xl:px-[200px] border-b border-or/20">
        <motion.p
          initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
          className="text-xs tracking-[0.4em] uppercase text-or mb-4 font-light"
        >
          Portfolio
        </motion.p>
        <motion.h1
          initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
          className="font-display text-5xl md:text-7xl font-light text-texte mb-4"
        >
          Nos réalisations
        </motion.h1>
        <motion.p
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.2 }}
          className="text-texte-muted font-light text-lg"
        >
          Une sélection de projets qui témoignent de notre engagement envers l'excellence.
        </motion.p>
      </div>

      {/* Filters */}
      <div className="w-full px-6 xl:px-[200px] py-10 flex gap-4 flex-wrap">
        {categories.map(cat => (
          <button
            key={cat}
            onClick={() => setActive(cat)}
            className={`text-xs tracking-[0.25em] uppercase px-5 py-2.5 border transition-all duration-200 ${
              active === cat
                ? 'bg-or text-noir border-or font-semibold'
                : 'border-or/20 text-texte-muted hover:border-or/40 hover:text-texte'
            }`}
          >
            {cat}
          </button>
        ))}
      </div>

      {/* Grid */}
      <div className="w-full px-6 xl:px-[200px] pb-32">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filtered.map((r, i) => (
            <motion.div
              key={r.title}
              layout
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: i * 0.08 }}
              className="group relative overflow-hidden bg-noir-surface aspect-[4/3] cursor-pointer"
            >
              <img
                src={r.img}
                alt={r.title}
                className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110 opacity-70 group-hover:opacity-90"
              />
              {/* Overlay */}
              <div className="absolute inset-0 bg-gradient-to-t from-noir via-noir/40 to-transparent" />
              {/* Tag */}
              <div className="absolute top-4 left-4 text-[10px] tracking-[0.3em] uppercase text-or bg-noir/60 px-3 py-1.5 border border-or/30">
                {r.cat}
              </div>
              {/* Info */}
              <div className="absolute bottom-0 left-0 right-0 p-6">
                <h3 className="font-display text-2xl font-light text-texte">{r.title}</h3>
                <p className="text-texte-muted text-sm mt-1">{r.location}</p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>

      <Footer />
    </div>
  );
}



