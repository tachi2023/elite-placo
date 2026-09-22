import { motion } from 'framer-motion';
import { MapPin, Phone, Mail, MessageCircle, Clock, ArrowRight } from 'lucide-react';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

const infos = [
  { icon: MapPin, label: 'Adresse', value: 'Douala, Cameroun', href: null },
  { icon: Phone, label: 'Téléphone', value: '+237 688 92 12 13', href: 'tel:+237688921213', cta: 'Appeler →' },
  { icon: Mail, label: 'Email', value: 'raoulmichel20@gmail.com', href: 'mailto:raoulmichel20@gmail.com', cta: 'Écrire →' },
  { icon: MessageCircle, label: 'WhatsApp', value: 'Réponse rapide 7j/7', href: 'https://wa.me/237688921213', cta: 'Démarrer une conversation →' },
  { icon: Clock, label: 'Horaires', value: 'Lun – Sam : 8h – 18h\nDimanche : sur rendez-vous', href: null },
];

export default function Contact() {
  return (
    <div className="min-h-screen bg-noir text-texte">
      <Navbar />

      <div className="pt-40 pb-20 w-full px-6 xl:px-[200px] border-b border-or/20">
        <motion.p
          initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
          className="text-xs tracking-[0.4em] uppercase text-or mb-4 font-light"
        >
          Nous contacter
        </motion.p>
        <motion.h1
          initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
          className="font-display text-5xl md:text-7xl font-light text-texte mb-4"
        >
          Restons en contact
        </motion.h1>
        <motion.p
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.2 }}
          className="text-texte-muted font-light text-lg"
        >
          Notre équipe est à votre écoute pour toute question ou demande de renseignement.
        </motion.p>
      </div>

      <div className="w-full px-6 xl:px-[200px] py-24">
        <div className="flex flex-col lg:flex-row gap-12">
          
          {/* Formulaire de Contact */}
          <div className="w-full lg:w-1/2">
            <h2 className="font-display text-3xl font-light text-texte mb-8">Envoyez-nous un message</h2>
            <form className="space-y-6" onSubmit={(e) => e.preventDefault()}>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-xs tracking-widest uppercase text-texte-muted">Nom complet</label>
                  <input type="text" className="w-full bg-noir-surface border border-or/20 px-4 py-3 text-texte focus:border-or outline-none transition-colors" placeholder="Jean Dupont" />
                </div>
                <div className="space-y-2">
                  <label className="text-xs tracking-widest uppercase text-texte-muted">Email</label>
                  <input type="email" className="w-full bg-noir-surface border border-or/20 px-4 py-3 text-texte focus:border-or outline-none transition-colors" placeholder="jean@exemple.com" />
                </div>
              </div>
              <div className="space-y-2">
                <label className="text-xs tracking-widest uppercase text-texte-muted">Sujet</label>
                <input type="text" className="w-full bg-noir-surface border border-or/20 px-4 py-3 text-texte focus:border-or outline-none transition-colors" placeholder="Demande de renseignement" />
              </div>
              <div className="space-y-2">
                <label className="text-xs tracking-widest uppercase text-texte-muted">Message</label>
                <textarea rows={5} className="w-full bg-noir-surface border border-or/20 px-4 py-3 text-texte focus:border-or outline-none transition-colors resize-none" placeholder="Votre message..."></textarea>
              </div>
              <button type="submit" className="inline-flex items-center gap-2 bg-or text-noir text-xs font-semibold tracking-widest uppercase px-8 py-4 hover:bg-or-clair transition-all duration-300">
                Envoyer le message <ArrowRight size={16} />
              </button>
            </form>
          </div>

          {/* Map and Options List */}
          <div className="w-full lg:w-1/2 flex flex-col gap-8">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {infos.slice(0, 4).map((info, i) => (
                <motion.div
                  key={info.label}
                  initial={{ opacity: 0, y: 10 }} whileInView={{ opacity: 1, y: 0 }}
                  transition={{ delay: i * 0.1 }} viewport={{ once: true }}
                  className="bg-noir-surface border border-or/10 p-6 hover:border-or/40 transition-colors group flex items-start gap-4"
                >
                  <info.icon size={20} className="text-or shrink-0 mt-1" />
                  <div>
                    <p className="text-[10px] tracking-[0.2em] uppercase text-texte-muted mb-1">{info.label}</p>
                    <p className="text-sm text-texte font-light whitespace-pre-line leading-relaxed">{info.value}</p>
                  </div>
                </motion.div>
              ))}
            </div>

            {/* Functional Google Map Iframe for Douala */}
            <motion.div
              initial={{ opacity: 0, x: 20 }} whileInView={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.4 }} viewport={{ once: true }}
              className="w-full h-[300px] bg-noir-surface border border-or/20 p-2 relative group overflow-hidden"
            >
              <div className="absolute top-4 left-6 z-10 bg-noir/80 backdrop-blur px-3 py-1.5 border border-or/20">
                <p className="text-[10px] tracking-[0.2em] uppercase text-or">Agence Douala</p>
              </div>
              <iframe 
                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d127402.13854580525!2d9.658252204733353!3d4.048268875569428!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x1061128be2e1f6c1%3A0x92011c10fa511b82!2sDouala%2C%20Cameroon!5e0!3m2!1sen!2sfr!4v1700000000000!5m2!1sen!2sfr" 
                width="100%" 
                height="100%" 
                style={{ border: 0 }} 
                allowFullScreen={true} 
                loading="lazy" 
                referrerPolicy="no-referrer-when-downgrade"
                className="w-full h-full object-cover transition-all duration-700"
              />
            </motion.div>
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
}



