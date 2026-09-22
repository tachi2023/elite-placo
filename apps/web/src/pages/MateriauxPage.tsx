import { Link } from 'react-router-dom';
import { ArrowLeft, Package2 } from 'lucide-react';
import ManagementShell from '../components/ManagementShell';

const tarifs = [
  { nom: 'Plaque BA13', unite: 'par plaque', prix: '4 500 FCFA' },
  { nom: 'Fourrure F530', unite: 'par barre', prix: '2 200 FCFA' },
  { nom: 'Cornière', unite: 'par barre', prix: '1 500 FCFA' },
  { nom: 'Rail R48', unite: 'par barre', prix: '2 800 FCFA' },
  { nom: 'Montant M48', unite: 'par barre', prix: '2 600 FCFA' },
  { nom: 'Vis placo', unite: 'par boîte', prix: '3 500 FCFA' },
  { nom: 'Vis autoperceuse', unite: 'par boîte', prix: '2 500 FCFA' },
  { nom: 'Bande à joints', unite: 'par rouleau', prix: '1 800 FCFA' },
  { nom: 'Enduit', unite: 'par sac', prix: '6 500 FCFA' },
];

export default function MateriauxPage() {
  return (
    <ManagementShell title="Prix matériaux" subtitle="Tarifs des matériaux utilisés pour le calcul des budgets">
      <div className="rounded-[24px] border border-white/10 bg-[#121214] p-4 sm:p-6">
        <div className="mb-5 flex items-center gap-3 text-sm text-gray-400">
          <Link to="/parametres" className="inline-flex items-center gap-2 rounded-full border border-white/10 px-3 py-2 text-gray-300">
            <ArrowLeft size={16} /> Retour
          </Link>
          <span>Les nouveaux calculs utiliseront ces tarifs.</span>
        </div>

        <div className="grid gap-3 md:grid-cols-2">
          {tarifs.map((item) => (
            <div key={item.nom} className="flex items-center justify-between rounded-[20px] border border-white/10 bg-[#0A0A0B] px-4 py-4">
              <div className="flex items-center gap-3">
                <div className="rounded-2xl border border-[#C9A84C]/20 bg-[#C9A84C]/10 p-2 text-[#C9A84C]">
                  <Package2 size={18} />
                </div>
                <div>
                  <div className="font-medium text-white">{item.nom}</div>
                  <div className="text-sm text-gray-400">{item.unite}</div>
                </div>
              </div>
              <div className="rounded-full border border-[#C9A84C]/20 bg-[#C9A84C]/10 px-3 py-1 text-sm font-semibold text-[#C9A84C]">
                {item.prix}
              </div>
            </div>
          ))}
        </div>
      </div>
    </ManagementShell>
  );
}
