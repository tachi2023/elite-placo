import { useState } from 'react';
import type { FormEvent } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { ArrowLeft, LockKeyhole } from 'lucide-react';
import logoImg from '../assets/brand-logo.png';
import { API_BASE_URL } from '../lib/siteApi';

export default function AdminLoginPage() {
  const navigate = useNavigate();
  const [identifiant, setIdentifiant] = useState('');
  const [motDePasse, setMotDePasse] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function submit(event: FormEvent) {
    event.preventDefault();
    setLoading(true);
    setError('');
    try {
      const response = await fetch(`${API_BASE_URL}/api/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ identifiant, motDePasse }),
      });
      const payload = await response.json();
      if (!response.ok) throw new Error(payload.message || 'Identifiants incorrects.');
      localStorage.setItem('elite_access_token', payload.accessToken);
      localStorage.setItem('elite_refresh_token', payload.refreshToken);
      navigate('/admin/site');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Connexion impossible.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="min-h-screen bg-noir px-6 py-12 text-texte">
      <div className="mx-auto flex min-h-[80vh] max-w-md flex-col justify-center">
        <Link to="/" className="mb-10 inline-flex items-center gap-2 text-xs uppercase tracking-[0.2em] text-or"><ArrowLeft size={15} /> Retour au site</Link>
        <div className="border border-or/20 bg-noir-surface p-8 shadow-[0_25px_80px_rgba(0,0,0,0.35)]">
          <img src={logoImg} alt="Élite Placo & Déco" className="mb-10 h-14 w-auto max-w-[250px] object-contain" />
          <div className="mb-8 flex items-center gap-3"><LockKeyhole className="text-or" size={20} /><div><p className="text-xs uppercase tracking-[0.25em] text-or">Administration</p><h1 className="font-display text-3xl font-light">Accès sécurisé</h1></div></div>
          <form onSubmit={submit} className="space-y-4">
            <input value={identifiant} onChange={(event) => setIdentifiant(event.target.value)} required placeholder="Identifiant" className="w-full border border-or/20 bg-noir px-4 py-3 text-sm outline-none focus:border-or" />
            <input value={motDePasse} onChange={(event) => setMotDePasse(event.target.value)} required type="password" placeholder="Mot de passe" className="w-full border border-or/20 bg-noir px-4 py-3 text-sm outline-none focus:border-or" />
            {error && <p className="text-sm text-erreur">{error}</p>}
            <button disabled={loading} className="w-full bg-or px-5 py-3 text-xs font-semibold uppercase tracking-[0.2em] text-noir disabled:opacity-50">{loading ? 'Connexion...' : 'Ouvrir l’administration'}</button>
          </form>
        </div>
      </div>
    </main>
  );
}
