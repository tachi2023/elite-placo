import { useEffect, useRef, useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Menu, X } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import BrandLogo from './BrandLogo';

const navLinks = [
  { label: 'Accueil', to: '/' },
  { label: 'Services', to: '/services' },
  { label: 'Réalisations', to: '/realisations' },
  { label: 'Devis', to: '/devis' },
  { label: 'Contact', to: '/contact' },
];

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const [isScrolling, setIsScrolling] = useState(false);
  const scrollTimer = useRef<number | undefined>(undefined);
  const location = useLocation();

  useEffect(() => {
    setOpen(false);
  }, [location.pathname]);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolling(true);
      window.clearTimeout(scrollTimer.current);
      scrollTimer.current = window.setTimeout(() => setIsScrolling(false), 900);
    };
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setOpen(false);
    };

    window.addEventListener('scroll', handleScroll);
    window.addEventListener('keydown', handleKeyDown);
    return () => {
      window.removeEventListener('scroll', handleScroll);
      window.removeEventListener('keydown', handleKeyDown);
      window.clearTimeout(scrollTimer.current);
    };
  }, []);

  useEffect(() => {
    if (!open) return;
    const closeOnScroll = () => setOpen(false);
    window.addEventListener('scroll', closeOnScroll, { passive: true });
    return () => window.removeEventListener('scroll', closeOnScroll);
  }, [open]);

  const darkMode = isScrolling || open;

  return (
    <header className={`fixed top-0 left-0 right-0 z-50 border-b transition-all duration-500 ${darkMode ? 'h-16 border-or/15 bg-noir/95 shadow-[0_12px_40px_rgba(0,0,0,.3)] backdrop-blur-xl' : 'h-20 border-transparent bg-transparent'}`}>
      <div className="w-full min-w-0 px-4 sm:px-6 md:px-[50px] h-full flex items-center justify-between gap-4">
        {/* Logo */}
        <Link to="/" className="flex min-w-0 items-center leading-none">
          <BrandLogo titleClassName="text-lg sm:text-xl" />
        </Link>

        {/* Right side group: Nav links + CTAs */}
        <div className="hidden lg:flex items-center gap-16">
          
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
          type="button"
          aria-label={open ? 'Fermer le menu' : 'Ouvrir le menu'}
          aria-expanded={open}
          className="lg:hidden shrink-0 text-texte p-2"
          onClick={() => setOpen((value) => !value)}
        >
          {open ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>

      {/* Mobile Menu */}
      <AnimatePresence>
        {open && (
          <>
            <motion.button
              type="button"
              aria-label="Fermer le menu"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setOpen(false)}
              className="fixed inset-0 top-16 bg-black/55 lg:hidden"
            />
            <motion.nav
              initial={{ opacity: 0, y: -8 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -8 }}
              className="relative z-10 lg:hidden flex max-h-[calc(100vh-4rem)] flex-col gap-2 overflow-y-auto border-t border-or/15 bg-noir/95 px-5 py-5 shadow-[0_18px_40px_rgba(0,0,0,.4)] backdrop-blur-xl sm:px-6 sm:py-7"
            >
              {navLinks.map((link) => (
                <Link
                  key={link.to}
                  to={link.to}
                  onClick={() => setOpen(false)}
                  className={`rounded-sm px-3 py-3 text-sm tracking-widest uppercase font-light transition-colors hover:bg-or/10 ${
                    location.pathname === link.to ? 'text-or' : 'text-texte'
                  }`}
                >
                  {link.label}
                </Link>
              ))}
              <hr className="my-2 border-or/20" />
              <Link
                to="/espace-client"
                onClick={() => setOpen(false)}
                className="rounded-sm px-3 py-3 text-sm tracking-widest uppercase text-or hover:bg-or/10"
              >
                Espace Client
              </Link>
              <Link
                to="/devis"
                onClick={() => setOpen(false)}
                className="mt-1 text-center text-xs tracking-widest uppercase bg-or text-noir font-semibold px-5 py-3"
              >
                Devis gratuit
              </Link>
            </motion.nav>
          </>
        )}
      </AnimatePresence>
    </header>
  );
}

