import { Link } from 'react-router-dom';
import { ArrowRight, ShieldCheck, Settings2, Package2 } from 'lucide-react';
import ManagementShell from '../components/ManagementShell';

const cards = [
  {
    title: 'Prix des matériaux',
    description: 'Modifier les tarifs unitaires utilisés pour les nouveaux calculs.',
    to: '/parametres/materiaux',
    icon: Package2,
  },
  {
    title: 'Code de sécurité',
    description: 'Définir ou modifier le code d’accès au suivi client.',
    to: '/parametres',
    icon: ShieldCheck,
  },
  {
    title: 'Préférences',
    description: 'Gérer les options visibles depuis l’interface d’administration.',
    to: '/parametres',
    icon: Settings2,
  },
];

export default function ParametresPage() {
  return (
    <ManagementShell title="Paramètres" subtitle="Configuration de l’application et des tarifs">
      <div className="grid gap-4 md:grid-cols-3">
        {cards.map(({ title, description, to, icon: Icon }) => (
          <Link
            key={title}
            to={to}
            className="rounded-[24px] border border-white/10 bg-[#121214] p-6 transition hover:border-[#C9A84C]/40"
          >
            <div className="mb-4 inline-flex rounded-2xl border border-[#C9A84C]/20 bg-[#C9A84C]/10 p-3 text-[#C9A84C]">
              <Icon size={22} />
            </div>
            <h2 className="text-lg font-semibold text-white">{title}</h2>
            <p className="mt-2 text-sm leading-6 text-gray-400">{description}</p>
            <div className="mt-4 inline-flex items-center gap-2 text-sm font-medium text-[#C9A84C]">
              Ouvrir <ArrowRight size={16} />
            </div>
          </Link>
        ))}
      </div>

      <div className="mt-6 rounded-[28px] border border-white/10 bg-[#121214] p-6">
        <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div>
            <h3 className="text-xl font-semibold text-white">Élite Placo & Déco</h3>
            <p className="mt-1 text-sm text-gray-400">Raoul Michel • +237 688 92 12 13</p>
          </div>
          <div className="rounded-full border border-[#C9A84C]/20 bg-[#C9A84C]/10 px-3 py-1.5 text-sm text-[#C9A84C]">
            Douala, Cameroun • FCFA
          </div>
        </div>
      </div>
    </ManagementShell>
  );
}
