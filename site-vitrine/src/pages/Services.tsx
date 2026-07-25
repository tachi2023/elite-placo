import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ArrowRight, CheckCircle } from 'lucide-react';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

const services = [
  {
    title: 'Plâtrerie',
    desc: 'Cloisons, doublages et finitions plâtre exécutés selon les standards les plus élevés.',
    items: ['Cloisons sèches', 'Doublages thermiques', 'Enduits de finition'],
  },
  {
    title: 'Faux Plafonds',
    desc: 'Plafonds suspendus, décoratifs, acoustiques ou lumineux pour sublimer chaque pièce.',
    items: ['Plafonds en BA13', 'Corniches lumineuses', 'Plafonds coffres'],
  },
  {
    title: 'Décoration Intérieure',
    desc: "Conception et réalisation d'aménagements intérieurs sur-mesure, élégants et fonctionnels.",
    items: ['Conseil en design', 'Moulures & corniches', 'Aménagement complet'],
  },
  {
    title: 'Revêtements Muraux',
    desc: 'Papier peint, lambris, panneaux décoratifs : une signature murale pour chaque ambiance.',
    items: ['Papier peint haut de gamme', 'Lambris décoratifs', 'Panneaux 3D'],
  },
  {
    title: 'Peinture Décorative',
    desc: 'Peintures, patines, effets matières et finitions luxueuses pour des murs uniques.',
    items: ['Patines et effets', 'Stuc vénitien', 'Peintures métallisées'],
  },
  {
    title: 'Isolation',
    desc: "Solutions d'isolation thermique et acoustique performantes, intégrées discrètement.",
    items: ['Isolation thermique', 'Isolation acoustique', 'Conformité énergétique'],
  },
];

export default function Services() {
  return (
    <div className="min-h-screen bg-noir text-texte">
      <Navbar />

      {/* Page Header */}
      <div className="pt-40 pb-20 w-full px-6 xl:px-[200px] border-b border-or/20">
        <motion.p
          initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
          className="text-xs tracking-[0.4em] uppercase text-or mb-4 font-light"
        >
          Nos prestations
        </motion.p>
        <motion.h1
          initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
          className="font-display text-5xl md:text-7xl font-light text-texte mb-6"
        >
          Des services d'exception
        </motion.h1>
        <motion.p
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.2 }}
          className="text-texte-muted max-w-2xl font-light text-lg"
        >
          Six expertises complémentaires, une seule exigence : la perfection du détail.
        </motion.p>
      </div>

      {/* Services List */}
      <div className="w-full px-6 xl:px-[200px] py-24">
        <div className="flex flex-col gap-10">
          {services.map((service, i) => (
            <motion.div
              key={service.title}
              initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.08 }} viewport={{ once: true }}
              className="relative bg-noir-surface p-10 md:p-14 grid md:grid-cols-2 gap-10 border border-or/10 hover:border-or/40 transition-all duration-500 group overflow-hidden"
            >
              {/* Luxury decorative accent */}
              <div className="absolute top-0 left-0 w-1 h-full bg-gradient-to-b from-or/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
              
              <div>
                <div className="text-xs text-texte-muted tracking-[0.3em] mb-4">0{i + 1}</div>
                <h2 className="font-display text-3xl md:text-4xl font-light text-texte mb-4 group-hover:text-or transition-colors duration-300">
                  {service.title}
                </h2>
                <p className="text-texte-muted font-light leading-relaxed mb-8">{service.desc}</p>
                <Link
                  to="/devis"
                  className="inline-flex items-center gap-2 bg-or text-noir text-xs font-semibold tracking-widest uppercase px-6 py-3 hover:bg-or-clair transition-all duration-300"
                >
                  Demander un devis <ArrowRight size={14} className="group-hover:translate-x-1 transition-transform" />
                </Link>
              </div>
              <ul className="space-y-4 self-center">
                {service.items.map((item) => (
                  <li key={item} className="flex items-center gap-4 text-texte-muted group/item">
                    <div className="w-6 h-6 rounded-full border border-or/30 flex items-center justify-center group-hover/item:border-or transition-colors shrink-0">
                      <CheckCircle size={12} className="text-or" />
                    </div>
                    <span className="font-light group-hover/item:text-texte transition-colors">{item}</span>
                  </li>
                ))}
              </ul>
            </motion.div>
          ))}
        </div>
      </div>

      <Footer />
    </div>
  );
}



