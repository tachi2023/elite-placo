import '../models/fiche_metrage.dart';
import '../repositories/metrage_repository.dart';
import '../exceptions/app_exception.dart';

/// Module 5 — jusqu'à 30 pièces, déductions, récapitulatif automatique
/// (elite.md §10.6).
class MetrageService {
  static const int limitePieces = 30; // §10.6-A2

  final MetrageRepository _repository;
  MetrageService(this._repository);

  Future<FicheMetrage> creerFiche(
      {required int chantierId, required String systeme}) {
    return _repository
        .creer(FicheMetrage(chantierId: chantierId, systeme: systeme));
  }

  /// §10.6, étapes 2-4 + A1/A2. Ajoute une pièce à une fiche déjà créée ;
  /// une pièce invalide n'empêche pas la saisie des autres (A1).
  Future<FicheMetrage> ajouterPiece(
      FicheMetrage fiche, PieceMetrage piece) async {
    if (piece.longueur <= 0 || piece.largeur <= 0) {
      throw AppException(
          'Longueur et largeur doivent être des nombres positifs pour "${piece.nomPiece}".');
    }
    if (fiche.pieces.length >= limitePieces) {
      throw const AppException(
          'Une fiche de métrage est limitée à $limitePieces pièces.');
    }
    if (piece.surfaceDeduction > piece.surfaceBrute) {
      // A4 — incohérence signalée mais non bloquante : c'est à l'appelant
      // (UI) de décider d'afficher un avertissement et de laisser
      // continuer le dirigeant, comme prévu au scénario.
    }

    final pieces = List<PieceMetrage>.of(fiche.pieces)..add(piece);
    final misAJour = FicheMetrage(
      id: fiche.id,
      chantierId: fiche.chantierId,
      systeme: fiche.systeme,
      pieces: pieces,
      dateCreation: fiche.dateCreation,
      synchronise: false,
    );
    if (fiche.id == null) {
      return misAJour;
    } else {
      return await _repository.mettreAJour(misAJour);
    }
  }

  /// §10.6-A3 — la validation finale exige au moins une pièce.
  Future<FicheMetrage> validerFiche(FicheMetrage fiche) async {
    if (fiche.pieces.isEmpty) {
      throw const AppException(
          'Ajoutez au moins une pièce avant de valider la fiche.');
    }
    if (fiche.id == null) {
      return await _repository.creer(fiche);
    } else {
      return await _repository.mettreAJour(fiche);
    }
  }

  Future<List<FicheMetrage>> listerParChantier(int chantierId) =>
      _repository.listerParChantier(chantierId);
}
