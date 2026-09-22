import { Link } from 'react-router-dom';
import ManagementShell from '../components/ManagementShell';

const cards = [
  { title: 'CA signé', value: '0 FCFA' },
  { title: 'Encaissé', value: '0 FCFA' },
  { title: 'Dépenses', value: '0 FCFA' },
  { title: 'Marge', value: '0%' },
];

export default function DashboardPage() {
  return (
    <ManagementShell title="Bilan global" subtitle="Vue d’ensemble de la santé financière">
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        {cards.map((card) => (
          <div key={card.title} className="rounded-[24px] border border-white/10 bg-[#121214] p-5">
            <div className="text-sm text-gray-400">{card.title}</div>
            <div className="mt-3 text-3xl font-semibold text-white">{card.value}</div>
          </div>
        ))}
      </div>

      <div className="mt-6 rounded-[28px] border border-white/10 bg-[#121214] p-6">
        <div className="flex items-center justify-between">
          <h2 className="text-xl font-semibold text-white">Recettes vs Dépenses</h2>
          <div className="rounded-full border border-[#C9A84C]/20 bg-[#C9A84C]/10 px-3 py-1 text-sm text-[#C9A84C]">
            Aucune donnée
          </div>
        </div>
        <div className="mt-6 rounded-[24px] border border-dashed border-white/10 px-6 py-14 text-center text-gray-400">
          Les chiffres apparaîtront ici dès qu’un chantier sera renseigné.
        </div>
      </div>

      <div className="mt-6 rounded-[28px] border border-white/10 bg-[#121214] p-6">
        <div className="flex items-center justify-between">
          <h2 className="text-xl font-semibold text-white">Tous les chantiers</h2>
          <Link to="/chantiers" className="text-sm text-[#C9A84C]">Voir la liste</Link>
        </div>
        <div className="mt-4 rounded-[20px] border border-white/10 bg-[#0A0A0B] px-4 py-5 text-sm text-gray-400">
          Aucun chantier pour le moment. Créez votre premier chantier depuis la section dédiée.
        </div>
      </div>
    </ManagementShell>
  );
}
