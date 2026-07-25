import { Link } from 'react-router-dom';
import ManagementShell from '../components/ManagementShell';

export default function NewChantierPage() {
  return (
    <ManagementShell title="Nouveau chantier" subtitle="Créer rapidement un chantier et le suivre">
      <div className="rounded-[28px] border border-white/10 bg-[#121214] p-6 sm:p-8">
        <div className="grid gap-5 md:grid-cols-2">
          <label className="text-sm text-gray-300">
            <span className="mb-2 block">Nom du client *</span>
            <input className="w-full rounded-2xl border border-white/10 bg-[#0A0A0B] px-4 py-3 text-white outline-none focus:border-[#C9A84C]" placeholder="Ex. M. Kouam" />
          </label>

          <label className="text-sm text-gray-300">
            <span className="mb-2 block">Ville</span>
            <input className="w-full rounded-2xl border border-white/10 bg-[#0A0A0B] px-4 py-3 text-white outline-none focus:border-[#C9A84C]" placeholder="Douala" />
          </label>

          <label className="text-sm text-gray-300">
            <span className="mb-2 block">Type de travaux</span>
            <select className="w-full rounded-2xl border border-white/10 bg-[#0A0A0B] px-4 py-3 text-white outline-none focus:border-[#C9A84C]">
              <option>Plafond BA13</option>
              <option>Décoration</option>
              <option>Finition</option>
              <option>Cloison</option>
            </select>
          </label>

          <label className="text-sm text-gray-300">
            <span className="mb-2 block">Statut initial</span>
            <select className="w-full rounded-2xl border border-white/10 bg-[#0A0A0B] px-4 py-3 text-white outline-none focus:border-[#C9A84C]">
              <option>À venir</option>
              <option>En cours</option>
              <option>En pause</option>
            </select>
          </label>

          <label className="text-sm text-gray-300">
            <span className="mb-2 block">Date de début</span>
            <input type="date" className="w-full rounded-2xl border border-white/10 bg-[#0A0A0B] px-4 py-3 text-white outline-none focus:border-[#C9A84C]" />
          </label>

          <label className="text-sm text-gray-300">
            <span className="mb-2 block">Devis signé (FCFA)</span>
            <input type="number" className="w-full rounded-2xl border border-white/10 bg-[#0A0A0B] px-4 py-3 text-white outline-none focus:border-[#C9A84C]" placeholder="0" />
          </label>
        </div>

        <label className="mt-5 block text-sm text-gray-300">
          <span className="mb-2 block">Description</span>
          <textarea rows={4} className="w-full rounded-2xl border border-white/10 bg-[#0A0A0B] px-4 py-3 text-white outline-none focus:border-[#C9A84C]" placeholder="Détails du chantier" />
        </label>

        <div className="mt-6 flex flex-wrap gap-3">
          <button type="button" className="rounded-full bg-[#C9A84C] px-5 py-3 font-semibold text-black">Créer le chantier</button>
          <Link to="/chantiers" className="rounded-full border border-white/10 px-5 py-3 font-semibold text-gray-300">Annuler</Link>
        </div>
      </div>
    </ManagementShell>
  );
}
