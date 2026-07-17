import '../models/chantier.dart';
import '../models/mouvement_financier.dart';
import '../repositories/chantier_repository.dart';
import '../repositories/mouvement_repository.dart';
import '../exceptions/app_exception.dart';

/// Situation financière calculée d'un chantier — c'est cet objet que
/// l'UI affiche sur la fiche chantier et le tableau de bord (§10.3,
/// étapes 6-7 ; §10.4, étapes 6-7).
class SituationFinanciere {
  final double totalEncaisse;
  final double totalDepenses;
  final double resteAEncaisser;
  final double resultatNet;
  final double margeBrutePourcent;
  final String indicateur; // 'VERT' | 'ORANGE' | 'ROUGE'

  const SituationFinanciere({
    required this.totalEncaisse,
    required this.totalDepenses,
    required this.resteAEncaisser,
    required this.resultatNet,
    required this.margeBrutePourcent,
    required this.indicateur,
  });
}

/// Module 2 — devis signé, encaissements, dépenses, calculs automatiques,
/// indicateur vert/orange/rouge (elite.md §2, Module 2 ; §10.3, §10.4, §10.13).
class FinanceService {
  final MouvementRepository _mouvementRepository;
  final ChantierRepository _chantierRepository;

  FinanceService(this._mouvementRepository, this._chantierRepository);

  /// Seuils de marge — hypothèse de travail cohérente avec le prototype
  /// d'interfaces déjà validé, À CONFIRMER avec le dirigeant avant mise en
  /// production (le cahier des charges ne fixe pas de seuil chiffré).
  static const double seuilVert = 20.0;
  static const double seuilOrange = 5.0;

  String calculerIndicateur(double margePourcent) {
    if (margePourcent >= seuilVert) return 'VERT';
    if (margePourcent >= seuilOrange) return 'ORANGE';
    return 'ROUGE';
  }

  Future<SituationFinanciere> calculerSituation(Chantier chantier) async {
    final mouvements = await _mouvementRepository.listerParChantier(chantier.id!);

    final totalEncaisse = mouvements
        .where((m) => m.typeMouvement == TypeMouvement.encaissement)
        .fold(0.0, (t, m) => t + m.montant);

    final totalDepenses = mouvements
        .where((m) => m.typeMouvement == TypeMouvement.depense)
        .fold(0.0, (t, m) => t + m.montant);

    final resultatNet = totalEncaisse - totalDepenses;
    final margePourcent = totalEncaisse > 0 ? (resultatNet / totalEncaisse) * 100 : 0.0;
    final resteAEncaisser = chantier.montantDevis - totalEncaisse;

    return SituationFinanciere(
      totalEncaisse: totalEncaisse,
      totalDepenses: totalDepenses,
      resteAEncaisser: resteAEncaisser,
      resultatNet: resultatNet,
      margeBrutePourcent: margePourcent,
      indicateur: calculerIndicateur(margePourcent),
    );
  }

  /// §10.3 — enregistrer un encaissement. A1 : validation stricte.
  /// A3 : avertissement (non bloquant) si le montant dépasse le reste dû —
  /// remonté à l'UI via le champ `avertissement` du résultat, la décision
  /// finale de valider quand même reste au dirigeant.
  Future<({MouvementFinancier mouvement, String? avertissement})> enregistrerEncaissement({
    required Chantier chantier,
    required double montant,
    required DateTime date,
    required String nature,
  }) async {
    if (montant <= 0) {
      throw const AppException('Le montant doit être un nombre positif.');
    }
    if (date.isAfter(DateTime.now())) {
      throw const AppException('La date ne peut pas être postérieure à aujourd\'hui.');
    }
    if (!NatureEncaissement.toutes.contains(nature)) {
      throw const AppException('Nature d\'encaissement invalide.');
    }

    final situationActuelle = await calculerSituation(chantier);
    String? avertissement;
    if (montant > situationActuelle.resteAEncaisser) {
      avertissement = 'Ce montant dépasse le reste à encaisser '
          '(${situationActuelle.resteAEncaisser.toStringAsFixed(0)} FCFA).';
    }

    final mouvement = await _mouvementRepository.creer(MouvementFinancier(
      typeMouvement: TypeMouvement.encaissement,
      date: date,
      montant: montant,
      chantierId: chantier.id!,
      nature: nature,
    ));

    // Marque le chantier comme "à synchroniser" (une donnée liée a changé).
    await _chantierRepository.mettreAJour(chantier.copyWith(synchronise: false));

    return (mouvement: mouvement, avertissement: avertissement);
  }

  /// §10.4 — enregistrer une dépense. A1/A2 : montant et catégorie
  /// obligatoires. A3 : l'enregistrement reste autorisé même si le
  /// chantier passe en perte — seul l'indicateur change.
  Future<MouvementFinancier> enregistrerDepense({
    required Chantier chantier,
    required double montant,
    required DateTime date,
    required String categorie,
    String? description,
  }) async {
    if (montant <= 0) {
      throw const AppException('Le montant doit être un nombre positif.');
    }
    if (!CategorieDepense.toutes.contains(categorie)) {
      throw const AppException('Choisissez une catégorie de dépense.');
    }

    final mouvement = await _mouvementRepository.creer(MouvementFinancier(
      typeMouvement: TypeMouvement.depense,
      date: date,
      montant: montant,
      chantierId: chantier.id!,
      categorie: categorie,
      description: description,
    ));

    await _chantierRepository.mettreAJour(chantier.copyWith(synchronise: false));

    return mouvement;
  }

  /// §10.13 — modification d'un mouvement existant. A1 : montant invalide
  /// refusé sans toucher à la donnée existante.
  Future<MouvementFinancier> modifierMouvement(MouvementFinancier mouvement, {
    double? nouveauMontant,
    DateTime? nouvelleDate,
    String? nouvelleCategorie,
    String? nouvelleDescription,
  }) async {
    if (nouveauMontant != null && nouveauMontant <= 0) {
      throw const AppException('Le nouveau montant doit être positif.');
    }
    final misAJour = mouvement.copyWith(
      montant: nouveauMontant,
      date: nouvelleDate,
      categorie: nouvelleCategorie,
      description: nouvelleDescription,
      synchronise: false,
    );
    return _mouvementRepository.mettreAJour(misAJour);
  }

  /// §10.13-A2 — la confirmation explicite est de la responsabilité de
  /// l'écran (dialogue de confirmation) ; ce service exécute la suppression
  /// une fois la confirmation obtenue.
  Future<void> supprimerMouvement(int mouvementId) =>
      _mouvementRepository.supprimer(mouvementId);
}
