import { Link } from 'react-router-dom';
import { MapPin, Phone, Mail, ArrowRight } from 'lucide-react';
import logoImg from '../assets/logo.jpg';

export default function Footer() {
  return (
    <footer className="border-t border-or/20 bg-noir-surface pt-20 pb-10">
      <div className="w-full px-6 xl:px-[200px] grid grid-cols-1 md:grid-cols-4 gap-12 mb-16">
        {/* Brand */}
        <div className="md:col-span-1">
          <div className="flex items-center gap-3 mb-5">
            <img src={logoImg} alt="Élite Placo & Déco" className="w-12 h-12 rounded-full object-cover border border-or/40" />
            <div>
            <div className="font-display text-xl font-semibold tracking-widest text-texte">Élite Placo & Déco</div>
            <div className="text-[10px] tracking-[0.3em] text-or uppercase font-light">PRIMA BTP</div>
            </div>
          </div>
          <p className="text-texte-muted text-sm leading-relaxed">
            L'excellence du plâtre, l'art de la décoration. Plâtrerie et décoration intérieure haut de gamme à Douala.
          </p>
        </div>

        {/* Services */}
        <div>
          <h4 className="text-xs tracking-[0.2em] uppercase text-or mb-6 font-medium">Services</h4>
          <ul className="space-y-3 text-sm text-texte-muted">
            {['Plâtrerie', 'Faux Plafonds', 'Décoration Intérieure', 'Revêtements Muraux', 'Peinture Décorative', 'Isolation'].map(s => (
              <li key={s} className="hover:text-texte transition-colors cursor-pointer">{s}</li>
            ))}
          </ul>
        </div>

        {/* Contact */}
        <div>
          <h4 className="text-xs tracking-[0.2em] uppercase text-or mb-6 font-medium">Contact</h4>
          <ul className="space-y-3 text-sm text-texte-muted">
            <li className="flex items-center gap-2"><MapPin size={14} className="text-or shrink-0" /> Douala, Cameroun</li>
            <li className="flex items-center gap-2"><Phone size={14} className="text-or shrink-0" /> +237 688 92 12 13</li>
            <li className="flex items-center gap-2"><Mail size={14} className="text-or shrink-0" /> raoulmichel20@gmail.com</li>
          </ul>
        </div>

        {/* CTA */}
        <div>
          <h4 className="text-xs tracking-[0.2em] uppercase text-or mb-6 font-medium">Suivez-nous</h4>
          <Link
            to="/devis"
            className="inline-flex items-center gap-2 text-sm text-texte hover:text-or transition-colors"
          >
            Demander un devis <ArrowRight size={16} />
          </Link>
        </div>
      </div>

      <div className="w-full px-6 xl:px-[200px] pt-8 border-t border-or/20 flex flex-col md:flex-row items-center justify-between gap-4">
        <p className="text-xs text-texte-muted tracking-widest">
          &copy; {new Date().getFullYear()} Élite Placo & Déco — PRIMA BTP. Tous droits réservés.
        </p>
        <Link to="/espace-client" className="text-xs text-or hover:text-or-clair tracking-widest uppercase transition-colors">
          Espace Client
        </Link>
      </div>
    </footer>
  );
}


