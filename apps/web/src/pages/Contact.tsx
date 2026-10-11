import { useState } from 'react';
import type { FormEvent } from 'react';
import { motion } from 'framer-motion';
import { MapPin, Phone, Mail, MessageCircle, Clock, ArrowRight, CheckCircle, AlertCircle } from 'lucide-react';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import { submitDemandeDevis } from '../lib/siteApi';

const infos = [
  { icon: MapPin, label: 'Adresse', value: 'Douala, Cameroun', href: null },
  { icon: Phone, label: 'Téléphone', value: '+237 688 92 12 13', href: 'tel:+237688921213', cta: 'Appeler →' },
  { icon: Mail, label: 'Email', value: 'raoulmichel20@gmail.com', href: 'mailto:raoulmichel20@gmail.com', cta: 'Écrire →' },
  { icon: MessageCircle, label: 'WhatsApp', value: 'Réponse rapide 7j/7', href: 'https://wa.me/237688921213', cta: 'Démarrer une conversation →' },
  { icon: Clock, label: 'Horaires', value: 'Lun – Sam : 8h – 18h\nDimanche : sur rendez-vous', href: null },
];

export default function Contact() {
  const [form, setForm] = useState({ nom: '', email: '', telephone: '', message: '', honeypot: '' });
  const [status, setStatus] = useState<'idle' | 'sending' | 'sent' | 'error'>('idle');
  const [error, setError] = useState('');
  const update = (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
    setForm((current) => ({ ...current, [event.target.name]: event.target.value }));

  async function submit(event: FormEvent) {
    event.preventDefault();
    setStatus('sending');
    setError('');
    try {
      await submitDemandeDevis({
        nom: form.nom.trim(), email: form.email.trim(), telephone: form.telephone.trim(),
        typeTravaux: 'Demande de contact', message: form.message.trim(), honeypot: form.honeypot,
      });
      setStatus('sent');
      setForm({ nom: '', email: '', telephone: '', message: '', honeypot: '' });
    } catch (caught) {
      setStatus('error');
      setError(caught instanceof Error ? caught.message : 'Impossible d’envoyer le message.');
    }
  }

  return (
    <div className="min-h-screen bg-noir text-texte">
      <Navbar />
      <div className="relative overflow-hidden border-b border-or/20 bg-gradient-to-br from-[#1b160f] via-noir to-[#0c0d0f] px-6 pb-20 pt-40 xl:px-[200px]">
        <div className="pointer-events-none absolute -right-16 top-12 h-64 w-64 rounded-full bg-or/10 blur-3xl" />
        <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="text-xs tracking-[0.4em] uppercase text-or mb-4 font-light">Nous contacter</motion.p>
        <motion.h1 initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }} className="font-display text-5xl md:text-7xl font-light text-texte mb-4">Restons en contact</motion.h1>
        <motion.p initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.2 }} className="text-texte-muted font-light text-lg">Notre équipe est à votre écoute pour toute question ou demande de renseignement.</motion.p>
      </div>
      <div className="w-full px-6 xl:px-[200px] py-24">
        <div className="flex flex-col lg:flex-row gap-12">
          <div className="w-full rounded-[28px] border border-or/15 bg-gradient-to-br from-[#17130e]/90 to-noir-surface/80 p-6 shadow-[0_24px_80px_rgba(0,0,0,.24)] lg:w-1/2 sm:p-8">
            <h2 className="font-display text-3xl font-light text-texte mb-8">Envoyez-nous un message</h2>
            {status === 'sent' ? <div className="border border-or/30 bg-or/5 p-8"><CheckCircle className="text-or mb-4" /><h3 className="font-display text-2xl">Message envoyé</h3><p className="mt-2 text-sm text-texte-muted">Nous reviendrons vers vous sous 24 heures.</p></div> : <form className="space-y-6" onSubmit={submit}>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <input name="nom" required value={form.nom} onChange={update} placeholder="Nom complet" className="w-full bg-noir-surface border border-or/20 px-4 py-3 text-texte outline-none focus:border-or" />
                <input name="email" type="email" value={form.email} onChange={update} placeholder="Email (facultatif)" className="w-full bg-noir-surface border border-or/20 px-4 py-3 text-texte outline-none focus:border-or" />
              </div>
              <input name="telephone" required value={form.telephone} onChange={update} placeholder="Téléphone" className="w-full bg-noir-surface border border-or/20 px-4 py-3 text-texte outline-none focus:border-or" />
              <textarea name="message" required value={form.message} onChange={update} rows={5} placeholder="Votre message..." className="w-full bg-noir-surface border border-or/20 px-4 py-3 text-texte outline-none focus:border-or resize-none" />
              <input name="honeypot" value={form.honeypot} onChange={update} tabIndex={-1} autoComplete="off" aria-hidden="true" className="hidden" />
              {status === 'error' && <div className="flex gap-2 text-sm text-red-200"><AlertCircle size={18} />{error}</div>}
              <button disabled={status === 'sending'} type="submit" className="inline-flex items-center gap-2 bg-or text-noir text-xs font-semibold tracking-widest uppercase px-8 py-4 hover:bg-or-clair transition-all disabled:opacity-50">{status === 'sending' ? 'Envoi...' : 'Envoyer le message'} <ArrowRight size={16} /></button>
            </form>}
          </div>
          <div className="w-full lg:w-1/2 flex flex-col gap-8">
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">{infos.slice(0, 4).map((info, i) => <motion.div key={info.label} initial={{ opacity: 0, y: 10 }} whileInView={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.1 }} viewport={{ once: true }} className="group flex items-start gap-4 rounded-2xl border border-or/10 bg-gradient-to-br from-[#17130e] to-noir-surface p-6 transition-colors hover:border-or/40"><info.icon size={20} className="mt-1 shrink-0 text-or" /><div><p className="mb-1 text-[10px] uppercase tracking-[0.2em] text-texte-muted">{info.label}</p><p className="whitespace-pre-line text-sm font-light leading-relaxed text-texte">{info.value}</p>{info.href && <a href={info.href} className="mt-2 block text-xs text-or">{info.cta}</a>}</div></motion.div>)}</div>
            <div className="w-full h-[300px] bg-noir-surface border border-or/20 p-2 relative overflow-hidden"><div className="absolute top-4 left-6 z-10 bg-noir/80 backdrop-blur px-3 py-1.5 border border-or/20"><p className="text-[10px] tracking-[0.2em] uppercase text-or">Agence Douala</p></div><iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d127402.13854580525!2d9.658252204733353!3d4.048268875569428" width="100%" height="100%" style={{ border: 0 }} allowFullScreen loading="lazy" referrerPolicy="no-referrer-when-downgrade" className="w-full h-full" /></div>
          </div>
        </div>
      </div>
      <Footer />
    </div>
  );
}
