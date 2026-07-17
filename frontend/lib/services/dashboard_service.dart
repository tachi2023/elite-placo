import '../models/chantier.dart';
import '../repositories/chantier_repository.dart';
import 'finance_service.dart';

/// Résumé d'un chantier tel qu'affiché dans la liste du tableau de bord
/// (§10.11, étape 3).
class ResumeChantier {
  final Chantier chantier;
  final SituationFinanciere situation;
  const ResumeChantier(this.chantier, this.situation);
}

/// Vue consolidée de l'entreprise (§10.11, étape 2).
class VueGlobale {
  final double chiffreAffairesTotal;   // somme des devis signés
  final double totalEncaisseGlobal;
  final double totalDepensesGlobal;
  final double resultatNetGlobal;
  final double margeGlobalePourcent;
  final List<ResumeChantier> resumesChantiers;
  final bool donneesPartiellementNonSynchronisees; // A2

  const VueGlobale({
    required this.chiffreAffairesTotal,
    required this.totalEncaisseGlobal,
    required this.totalDepensesGlobal,
    required this.resultatNetGlobal,
    required this.margeGlobalePourcent,
    required this.resumesChantiers,
    required this.donneesPartiellementNonSynchronisees,
  });
}

/// Module 4 — CA total, encaissé/dépenses global, résultat net et marge
/// globale, résumé par chantier (elite.md §10.11). Les données locales
/// font foi même partiellement synchronisées (A2) : aucun blocage ici,
/// seulement un indicateur discret à afficher côté UI.
class DashboardService {
  final ChantierRepository _chantierRepository;
  final FinanceService _financeService;

  DashboardService(this._chantierRepository, this._financeService);

  /// [inclureArchives] correspond au point ouvert §10.11-A3 : par défaut
  /// les chantiers archivés comptent dans les totaux mais peuvent être
  /// exclus de la liste détaillée — ici on les inclut dans les deux tant
  /// que le dirigeant n'a pas tranché, pour ne perdre aucune donnée.
  Future<VueGlobale> calculerVueGlobale({bool inclureArchives = true}) async {
    final chantiers = await _chantierRepository.listerTous(inclureArchives: inclureArchives);

    // A1 — aucun chantier créé : vue vide, pas d'erreur.
    if (chantiers.isEmpty) {
      return const VueGlobale(
        chiffreAffairesTotal: 0,
        totalEncaisseGlobal: 0,
        totalDepensesGlobal: 0,
        resultatNetGlobal: 0,
        margeGlobalePourcent: 0,
        resumesChantiers: [],
        donneesPartiellementNonSynchronisees: false,
      );
    }

    double ca = 0, encaisseGlobal = 0, depensesGlobal = 0;
    bool nonSync = false;
    final resumes = <ResumeChantier>[];

    for (final chantier in chantiers) {
      final situation = await _financeService.calculerSituation(chantier);
      ca += chantier.montantDevis;
      encaisseGlobal += situation.totalEncaisse;
      depensesGlobal += situation.totalDepenses;
      if (!chantier.synchronise) nonSync = true;
      resumes.add(ResumeChantier(chantier, situation));
    }

    final resultatNet = encaisseGlobal - depensesGlobal;
    final margeGlobale = encaisseGlobal > 0 ? (resultatNet / encaisseGlobal) * 100 : 0.0;

    return VueGlobale(
      chiffreAffairesTotal: ca,
      totalEncaisseGlobal: encaisseGlobal,
      totalDepensesGlobal: depensesGlobal,
      resultatNetGlobal: resultatNet,
      margeGlobalePourcent: margeGlobale,
      resumesChantiers: resumes,
      donneesPartiellementNonSynchronisees: nonSync,
    );
  }
}
