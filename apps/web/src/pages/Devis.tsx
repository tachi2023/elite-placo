import { useState } from 'react';
import { motion } from 'framer-motion';
import { Send, CheckCircle, AlertCircle } from 'lucide-react';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import { submitDemandeDevis } from '../lib/siteApi';

const typesTravaux = ['Plâtrerie', 'Faux Plafonds', 'Décoration Intérieure', 'Revêtements Muraux', 'Peinture Décorative', 'Isolation', 'Autre'];

export default function Devis() {
  const [form, setForm] = useState({
    nom: '', email: '', telephone: '', ville: '',
    typeTravaux: '', superficie: '', message: '', budget: '', honeypot: ''
  });
  const [sent, setSent] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setForm(prev => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    try {
      setIsSubmitting(true);
      await submitDemandeDevis({
        nom: form.nom.trim(),
        email: form.email.trim(),
        telephone: form.telephone.trim(),
        ville: form.ville.trim(),
        typeTravaux: form.typeTravaux,
        superficie: form.superficie.trim(),
        budgetEstime: form.budget.trim(),
        message: form.message.trim(),
        honeypot: form.honeypot,
      });
      setSent(true);
    } catch (submitError) {
      setError(submitError instanceof Error ? submitError.message : 'Une erreur est survenue.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-noir text-texte">
      <Navbar />

      <div className="pt-40 pb-20 w-full px-6 xl:px-[200px] border-b border-or/20">
        <motion.p
          initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
          className="text-xs tracking-[0.4em] uppercase text-or mb-4 font-light"
        >
          Demande de devis
        </motion.p>
        <motion.h1
          initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
          className="font-display text-5xl md:text-7xl font-light text-texte mb-4"
        >
          Parlons de votre projet
        </motion.h1>
        <motion.p
          initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.2 }}
          className="text-texte-muted font-light text-lg"
        >
          Remplissez ce formulaire et nous reviendrons vers vous sous 24 heures.
        </motion.p>
      </div>

      <div className="max-w-3xl mx-auto px-6 py-24">
        {sent ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="text-center py-20"
          >
            <CheckCircle size={64} className="text-or mx-auto mb-6" />
            <h2 className="font-display text-4xl font-light text-texte mb-4">Demande envoyée !</h2>
            <p className="text-texte-muted font-light">Nous reviendrons vers vous sous 24 heures pour discuter de votre projet.</p>
          </motion.div>
        ) : (
          <motion.form
            initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}
            onSubmit={handleSubmit}
            className="space-y-6"
          >
            <div className="grid md:grid-cols-2 gap-6">
              {[
                { name: 'nom', label: 'Nom complet', type: 'text', required: true },
                { name: 'email', label: 'Adresse email', type: 'email', required: false },
                { name: 'telephone', label: 'Téléphone', type: 'tel', required: true },
                { name: 'ville', label: 'Ville', type: 'text', required: false },
              ].map(field => (
                <div key={field.name}>
                  <label className="block text-xs tracking-[0.2em] uppercase text-texte-muted mb-2">{field.label}</label>
                  <input
                    type={field.type}
                    name={field.name}
                    required={field.required}
                    value={(form as any)[field.name]}
                    onChange={handleChange}
                    className="w-full bg-noir-surface border border-or/20 text-texte px-4 py-3 focus:outline-none focus:border-or transition-colors placeholder-texte-muted/40 text-sm"
                    placeholder={field.label}
                  />
                </div>
              ))}
            </div>

            <input name="honeypot" value={form.honeypot} onChange={handleChange} tabIndex={-1} autoComplete="off" aria-hidden="true" className="hidden" />

            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <label className="block text-xs tracking-[0.2em] uppercase text-texte-muted mb-2">Type de travaux</label>
                <select
                  name="typeTravaux"
                  value={form.typeTravaux}
                  onChange={handleChange}
                  className="w-full bg-noir-surface border border-or/20 text-texte px-4 py-3 focus:outline-none focus:border-or transition-colors text-sm"
                >
                  <option value="">Sélectionner...</option>
                  {typesTravaux.map(t => <option key={t} value={t}>{t}</option>)}
                </select>
              </div>
              <div>
                <label className="block text-xs tracking-[0.2em] uppercase text-texte-muted mb-2">Superficie estimée (m²)</label>
                <input
                  type="number"
                  name="superficie"
                  value={form.superficie}
                  onChange={handleChange}
                  className="w-full bg-noir-surface border border-or/20 text-texte px-4 py-3 focus:outline-none focus:border-or transition-colors text-sm"
                  placeholder="Ex: 150"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs tracking-[0.2em] uppercase text-texte-muted mb-2">Budget estimé (FCFA)</label>
              <input
                type="text"
                name="budget"
                value={form.budget}
                onChange={handleChange}
                className="w-full bg-noir-surface border border-or/20 text-texte px-4 py-3 focus:outline-none focus:border-or transition-colors text-sm"
                placeholder="Ex: 5 000 000 FCFA"
              />
            </div>

            <div>
              <label className="block text-xs tracking-[0.2em] uppercase text-texte-muted mb-2">Description du projet</label>
              <textarea
                name="message"
                value={form.message}
                onChange={handleChange}
                rows={5}
                className="w-full bg-noir-surface border border-or/20 text-texte px-4 py-3 focus:outline-none focus:border-or transition-colors text-sm resize-none"
                placeholder="Décrivez votre projet, vos attentes, vos contraintes..."
              />
            </div>

            {error && (
              <div className="flex items-center gap-3 rounded border border-red-500/40 bg-red-500/5 px-4 py-3 text-sm text-red-200">
                <AlertCircle size={18} className="shrink-0" />
                <span>{error}</span>
              </div>
            )}

            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full flex items-center justify-center gap-2 bg-or text-noir font-semibold tracking-widest uppercase text-sm px-8 py-4 hover:bg-or-clair transition-all duration-300 disabled:cursor-not-allowed disabled:opacity-60"
            >
              <Send size={18} />
              {isSubmitting ? 'Envoi en cours...' : 'Envoyer ma demande'}
            </button>
          </motion.form>
        )}
      </div>

      <Footer />
    </div>
  );
}


