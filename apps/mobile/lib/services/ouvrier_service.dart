import '../models/ouvrier.dart';
import '../repositories/ouvrier_repository.dart';
import '../repositories/mouvement_repository.dart';
import '../repositories/chantier_repository.dart';
import '../models/mouvement_financier.dart';
import '../exceptions/app_exception.dart';

/// Module 6 — affectation par chantier, paiements, remontée automatique
/// en dépense "main d'œuvre" (elite.md §10.8).
class OuvrierService {
  final OuvrierRepository _ouvrierRepository;
  final MouvementRepository _mouvementRepository;
  final ChantierRepository _chantierRepository;

  OuvrierService(this._ouvrierRepository, this._mouvementRepository, this._chantierRepository);

  Future<List<Ouvrier>> listerOuvriers() => _ouvrierRepository.listerOuvriers();

  /// §10.8-A1 — nom obligatoire.
  Future<Ouvrier> creerOuvrier({required String nomComplet, String? telephone}) async {
    if (nomComplet.trim().isEmpty) {
      throw const AppException('Le nom de l\'ouvrier est obligatoire.');
    }
    return _ouvrierRepository.creerOuvrier(Ouvrier(nomComplet: nomComplet.trim(), telephone: telephone));
  }

  /// §10.8, étapes 4-8 : enregistre le paiement PUIS répercute
  /// automatiquement le nouveau total main d'œuvre dans les dépenses du
  /// chantier (catégorie MAIN_OEUVRE), ce qui déclenche à son tour le
  /// recalcul du résultat net et de la marge côté FinanceService.
  ///
  /// A2 — montant invalide refusé avant tout enregistrement.
  Future<AffectationOuvrier> enregistrerPaiement({
    required int ouvrierId,
    required int chantierId,
    required double montant,
    required DateTime date,
  }) async {
    if (montant <= 0) {
      throw const AppException('Le montant du paiement doit être positif.');
    }

    final affectation = await _ouvrierRepository.ajouterPaiement(AffectationOuvrier(
      ouvrierId: ouvrierId,
      chantierId: chantierId,
      montantPaye: montant,
      datePaiement: date,
    ));

    // Remontée automatique en dépense "main d'œuvre" (étape 8 du scénario).
    final chantier = await _chantierRepository.trouverParId(chantierId);
    if (chantier != null) {
      await _mouvementRepository.creer(MouvementFinancier(
        typeMouvement: TypeMouvement.depense,
        date: date,
        montant: montant,
        chantierId: chantierId,
        categorie: CategorieDepense.mainOeuvre,
        description: 'Paiement ouvrier (généré automatiquement)',
      ));
      await _chantierRepository.mettreAJour(chantier.copyWith(synchronise: false));
    }

    return affectation;
  }

  Future<double> totalMainOeuvre(int chantierId) =>
      _ouvrierRepository.totalMainOeuvre(chantierId);

  Future<List<AffectationOuvrier>> historiquePaiements(int chantierId) =>
      _ouvrierRepository.listerAffectationsParChantier(chantierId);
}
