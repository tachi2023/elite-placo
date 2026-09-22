import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ArrowLeft, ArrowRight, MoveUpRight } from 'lucide-react';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

const services = [
  { id: '01', title: 'Plâtrerie' },
  { id: '02', title: 'Faux Plafonds' },
  { id: '03', title: 'Décoration Intérieure' },
  { id: '04', title: 'Revêtements Muraux' },
  { id: '05', title: 'Peinture Décorative' },
  { id: '06', title: 'Isolation' },
];

const realisations = [
  { title: 'Villa Bonanjo', location: 'Douala', image: '/assets/realisations/villa.jpg' },
  { title: 'Hôtel Le Méridien', location: 'Douala', image: '/assets/realisations/hotel.jpg' },
  { title: 'Résidence Bonapriso', location: 'Douala', image: '/assets/realisations/residence.jpg' },
  { title: 'Suite Présidentielle', location: 'Kribi', image: '/assets/realisations/suite.jpg' },
];

const temoignages = [
  { quote: "Un travail d'une finesse remarquable. Notre plafond est devenu la pièce maîtresse de la maison.", name: 'Marie Ndoumbé', role: 'Propriétaire, Bonanjo' },
  { quote: 'Professionnalisme, ponctualité et finitions irréprochables. Nous renouvelons systématiquement notre confiance.', name: 'Hôtel Le Méridien', role: 'Direction technique' },
  { quote: 'Le partenaire idéal pour mes projets résidentiels haut de gamme à Douala.', name: 'Jean-Claude Mbarga', role: 'Architecte' },
];

const fadeUp = {
  hidden: { opacity: 0, y: 35 },
  visible: (i = 0) => ({
    opacity: 1,
    y: 0,
    transition: { duration: 0.75, delay: i * 0.14, ease: 'easeOut' as const },
  }),
};

export default function Home() {
  const [activeRealisation, setActiveRealisation] = useState(0);

  useEffect(() => {
    const timer = window.setInterval(() => {
      setActiveRealisation((current) => (current + 1) % realisations.length);
    }, 5500);
    return () => window.clearInterval(timer);
  }, []);

  const navigateRealisation = (direction: number) => {
    setActiveRealisation((current) => (current + direction + realisations.length) % realisations.length);
  };

  return (
    <div className="min-h-screen bg-noir text-texte">
      <Navbar />

      <section className="relative min-h-screen flex items-end pb-28 overflow-hidden">
        <div className="absolute inset-0 bg-cover bg-center bg-no-repeat" style={{ backgroundImage: "url('/assets/hero_bg.jpg')" }} />
        <div className="absolute inset-0 bg-gradient-to-t from-noir via-noir/70 to-noir/30" />
        <div className="absolute inset-0 bg-gradient-to-r from-noir/60 via-transparent to-transparent" />
        <div className="relative z-10 w-full px-6 xl:px-[200px] flex flex-col items-center text-center mt-32">
          <motion.p variants={fadeUp} initial="hidden" animate="visible" custom={0} className="text-xs tracking-[0.4em] uppercase text-or mb-8 font-light">Douala · Cameroun</motion.p>
          <motion.h1 variants={fadeUp} initial="hidden" animate="visible" custom={1} className="font-display font-light text-5xl md:text-7xl lg:text-8xl text-texte mb-8 leading-[1.0] max-w-4xl mx-auto">
            L'excellence du plâtre,<br /><em className="not-italic text-or">l'art de la décoration.</em>
          </motion.h1>
          <motion.p variants={fadeUp} initial="hidden" animate="visible" custom={2} className="text-texte-muted text-lg max-w-2xl mx-auto mb-12 font-light leading-relaxed">
            Élite Placo & Déco transforme vos espaces résidentiels, commerciaux et hôteliers en lieux d'exception, où chaque détail révèle la maîtrise du geste.
          </motion.p>
          <motion.div variants={fadeUp} initial="hidden" animate="visible" custom={3} className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link to="/devis" className="inline-flex items-center justify-center gap-2 bg-or text-noir text-sm font-semibold tracking-widest uppercase px-8 py-4 hover:bg-or-clair transition-all duration-300">Demander un devis gratuit</Link>
            <Link to="/realisations" className="inline-flex items-center justify-center gap-2 border border-or/30 text-texte text-sm tracking-widest uppercase px-8 py-4 hover:border-or hover:text-or transition-all duration-300">Voir nos réalisations <ArrowRight size={16} /></Link>
          </motion.div>
        </div>
      </section>

      <section className="home-realisations-showcase border-y border-or/20 bg-noir-surface">
        <div className="w-full px-6 xl:px-[200px] pt-16">
          <div className="flex items-end justify-between gap-6">
            <div><p className="text-xs tracking-[0.4em] uppercase text-or mb-3 font-light">Réalisations choisies</p><h2 className="font-display text-4xl md:text-5xl font-light text-texte">Le geste, <em className="text-or not-italic">en images.</em></h2></div>
            <Link to="/realisations" className="hidden md:inline-flex items-center gap-2 text-xs tracking-[0.2em] uppercase text-or hover:text-or-clair">Tout voir <ArrowRight size={15} /></Link>
          </div>
        </div>
        <div className="home-carousel-window" aria-label="Carrousel des réalisations">
          {realisations.map((project, index) => {
            const offset = (index - activeRealisation + realisations.length) % realisations.length;
            const position = offset === 0 ? 'is-active' : offset === 1 ? 'is-next' : offset === realisations.length - 1 ? 'is-prev' : 'is-hidden';
            return (
              <button type="button" key={project.title} onClick={() => setActiveRealisation(index)} className={'home-carousel-card ' + position} aria-label={'Afficher ' + project.title}>
                <img src={project.image} alt={project.title} />
                <span className="home-carousel-shade" />
                <span className="home-carousel-info"><small>{project.location}</small><strong>{project.title}</strong></span>
                <MoveUpRight className="home-carousel-arrow" size={19} />
              </button>
            );
          })}
        </div>
        <div className="home-carousel-controls">
          <button type="button" onClick={() => navigateRealisation(-1)} aria-label="Réalisation précédente"><ArrowLeft size={17} /></button>
          <div className="home-carousel-progress">
            {realisations.map((project, index) => <button type="button" key={project.title} onClick={() => setActiveRealisation(index)} className={activeRealisation === index ? 'is-current' : ''} aria-label={'Aller à ' + project.title} />)}
          </div>
          <button type="button" onClick={() => navigateRealisation(1)} aria-label="Réalisation suivante"><ArrowRight size={17} /></button>
          <Link to="/realisations" className="md:hidden ml-4 text-[10px] tracking-[0.2em] uppercase text-or">Tout voir</Link>
        </div>
      </section>

      <section className="py-32 w-full px-6 xl:px-[200px]">
        <div className="mb-16">
          <p className="text-xs tracking-[0.4em] uppercase text-or mb-4 font-light">Nos savoir-faire</p>
          <h2 className="font-display text-5xl md:text-6xl font-light text-texte">Un univers d'élégance</h2>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {services.map((service, index) => (
            <motion.div key={service.id} initial={{ opacity: 0, y: 25 }} whileInView={{ opacity: 1, y: 0 }} transition={{ delay: index * 0.08 }} viewport={{ once: true }} className="relative group bg-noir-surface border border-or/10 p-12 hover:border-or/40 hover:shadow-[0_0_40px_rgba(201,168,76,0.05)] transition-all duration-500 overflow-hidden">
              <div className="absolute top-0 right-0 w-24 h-24 bg-gradient-to-bl from-or/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700 pointer-events-none" />
              <div className="text-xs text-texte-muted tracking-[0.3em] mb-12">{service.id}</div>
              <h3 className="font-display text-2xl font-light text-texte mb-6 group-hover:text-or transition-colors duration-300 relative z-10">{service.title}</h3>
              <Link to="/services" className="inline-flex items-center gap-2 text-xs tracking-[0.2em] uppercase text-or opacity-0 group-hover:opacity-100 transition-all duration-300 translate-y-2 group-hover:translate-y-0 relative z-10">Découvrir <ArrowRight size={14} /></Link>
            </motion.div>
          ))}
        </div>
      </section>

      <section className="py-32 bg-noir-surface border-y border-or/20">
        <div className="w-full px-6 xl:px-[200px]">
          <div className="mb-20"><p className="text-xs tracking-[0.4em] uppercase text-or mb-4 font-light">Pourquoi nous choisir</p><h2 className="font-display text-5xl md:text-6xl font-light text-texte">Le souci du détail</h2></div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12">
            {[
              { title: 'Excellence Reconnue', desc: "Plus de 15 ans d'expérience au service du raffinement architectural." },
              { title: 'Finitions Sur-Mesure', desc: "Chaque détail est pensé et exécuté avec une précision d'artisan." },
              { title: 'Garantie Qualité', desc: "Matériaux premium et garantie sur l'ensemble de nos prestations." },
              { title: 'Équipe Experte', desc: "Plâtriers, décorateurs et designers passionnés par leur métier." },
            ].map((item, index) => (
              <motion.div key={item.title} initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} transition={{ delay: index * 0.1 }} viewport={{ once: true }} className="border-t border-or/30 pt-6">
                <h3 className="font-display text-xl text-texte mb-4">{item.title}</h3><p className="text-texte-muted text-sm leading-relaxed font-light">{item.desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      <section className="py-32 w-full px-6 xl:px-[200px]">
        <div className="mb-16"><p className="text-xs tracking-[0.4em] uppercase text-or mb-4 font-light">Témoignages</p><h2 className="font-display text-5xl md:text-6xl font-light text-texte">Ils nous font confiance</h2></div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {temoignages.map((testimonial, index) => (
            <motion.div key={testimonial.name} initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} transition={{ delay: index * 0.12 }} viewport={{ once: true }} className="bg-noir-surface border border-or/20 p-10 hover:border-or/40 transition-all duration-300">
              <p className="font-display text-lg italic text-texte mb-10 leading-relaxed">“{testimonial.quote}”</p><p className="font-medium text-texte text-sm">{testimonial.name}</p><p className="text-texte-muted text-xs mt-1 tracking-widest">{testimonial.role}</p>
            </motion.div>
          ))}
        </div>
      </section>

      <section className="py-32 px-6 bg-noir-surface border-t border-or/20">
        <div className="max-w-3xl mx-auto text-center">
          <h2 className="font-display text-5xl md:text-6xl font-light text-texte mb-6">Donnons vie à votre vision.</h2>
          <p className="text-texte-muted mb-12 font-light">Une consultation, un devis sur-mesure, sans engagement.</p>
          <Link to="/devis" className="inline-flex items-center gap-2 bg-or text-noir text-sm font-semibold tracking-widest uppercase px-10 py-4 hover:bg-or-clair transition-all duration-300">Demander un devis gratuit</Link>
        </div>
      </section>

      <Footer />
    </div>
  );
}
