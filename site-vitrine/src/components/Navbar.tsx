import { useEffect, useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Menu, X } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const navLinks = [
  { label: 'Accueil', to: '/' },
  { label: 'Services', to: '/services' },
  { label: 'Réalisations', to: '/realisations' },
  { label: 'Devis', to: '/devis' },
  { label: 'Contact', to: '/contact' },
];

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const location = useLocation();

  useEffect(() => {
    setOpen(false);
  }, [location.pathname]);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 10);
    };
    
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 border-b ${isScrolled ? 'glass border-or/10 h-16' : 'bg-transparent border-transparent h-20'}`}>
      <div className="w-full px-[50px] h-full flex items-center justify-between">
        {/* Logo */}
        <Link to="/" className="flex flex-col leading-none">
          <span className="font-display text-xl font-semibold tracking-widest text-texte">
            Élite Placo & Déco
          </span>
          <span className="text-[10px] tracking-[0.3em] text-or uppercase font-light mt-1">
            PRIMA BTP
          </span>
        </Link>

        {/* Right side group: Nav links + CTAs */}
        <div className="hidden md:flex items-center gap-16">
          
          {/* Desktop Nav */}
          <nav className="flex items-center gap-8">
            {navLinks.map((link) => (
              <Link
                key={link.to}
                to={link.to}
                className={`relative font-display text-lg tracking-wide transition-colors duration-300 group ${
                  location.pathname === link.to
                    ? 'text-or'
                    : 'text-texte-muted hover:text-texte'
                }`}
              >
                {link.label}
                <span className={`absolute -bottom-1 left-0 w-full h-[1px] bg-or transition-transform duration-300 ${
                  location.pathname === link.to ? 'scale-x-100' : 'scale-x-0 group-hover:scale-x-100'
                } origin-left`} />
              </Link>
            ))}
          </nav>

          {/* Desktop CTA */}
          <div className="flex items-center gap-4">
            <Link
              to="/espace-client"
              className="text-xs tracking-widest uppercase text-texte-muted hover:text-or border border-transparent hover:border-or/40 px-4 py-2 transition-all duration-300"
            >
              Espace Client
            </Link>
            <Link
              to="/devis"
              className="relative overflow-hidden text-xs tracking-widest uppercase bg-or text-noir font-semibold px-6 py-3 hover:bg-or-clair transition-all duration-300 group"
            >
              <span className="relative z-10">Devis gratuit</span>
              <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:animate-shimmer" />
            </Link>
          </div>
        </div>

        {/* Mobile burger */}
        <button
          className="md:hidden text-texte p-2"
          onClick={() => setOpen(!open)}
        >
          {open ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>

      {/* Mobile Menu */}
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="md:hidden glass border-t border-or/10 px-6 py-8 flex flex-col gap-6"
          >
            {navLinks.map((link) => (
              <Link
                key={link.to}
                to={link.to}
                onClick={() => setOpen(false)}
                className={`text-sm tracking-widest uppercase font-light transition-colors ${
                  location.pathname === link.to ? 'text-or' : 'text-texte'
                }`}
              >
                {link.label}
              </Link>
            ))}
            <hr className="border-or/20" />
            <Link
              to="/espace-client"
              onClick={() => setOpen(false)}
              className="text-sm tracking-widest uppercase text-or"
            >
              Espace Client
            </Link>
            <Link
              to="/devis"
              onClick={() => setOpen(false)}
              className="text-center text-xs tracking-widest uppercase bg-or text-noir font-semibold px-5 py-3"
            >
              Devis gratuit
            </Link>
          </motion.div>
        )}
      </AnimatePresence>
    </header>
  );
}

