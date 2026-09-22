import '../models/fiche_metrage.dart';
import '../services/api_service.dart';

/// Dépôt connecté à l'API REST Spring Boot pour les fiches de métrage.
class MetrageRepository {
  final ApiService _api = ApiService();

  /// GET /api/chantiers/{id}/fiches-metrage
  Future<List<FicheMetrage>> listerParChantier(int chantierId) async {
    final response = await _api.client.get('/api/chantiers/$chantierId/fiches-metrage');
    final List<dynamic> data = response.data;
    return data.map((json) => FicheMetrage.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// POST /api/chantiers/{id}/fiches-metrage
  Future<FicheMetrage> creer(FicheMetrage fiche) async {
    final response = await _api.client.post(
      '/api/chantiers/${fiche.chantierId}/fiches-metrage',
      data: {'systeme': fiche.systeme},
    );
    return FicheMetrage.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/chantiers/{chantierId}/fiches-metrage/{ficheId}/pieces
  Future<FicheMetrage> ajouterPiece(int ficheId, int chantierId, PieceMetrage piece) async {
    final response = await _api.client.post(
      '/api/chantiers/$chantierId/fiches-metrage/$ficheId/pieces',
      data: {
        'nomPiece': piece.nomPiece,
        'longueur': piece.longueur,
        'largeur': piece.largeur,
        'surfaceDeduction': piece.surfaceDeduction,
      },
    );
    return FicheMetrage.fromJson(response.data as Map<String, dynamic>);
  }

  /// POST /api/chantiers/{chantierId}/fiches-metrage/{ficheId}/valider
  Future<FicheMetrage> valider(int ficheId, int chantierId) async {
    final response = await _api.client.post(
      '/api/chantiers/$chantierId/fiches-metrage/$ficheId/valider',
    );
    return FicheMetrage.fromJson(response.data as Map<String, dynamic>);
  }

  /// Alias pour compatibilité avec le MetrageService existant.
  Future<FicheMetrage> mettreAJour(FicheMetrage fiche) async {
    // Pas d'endpoint PUT global sur la fiche — on retourne la fiche telle quelle
    // (les mises à jour passent par ajouterPiece et valider).
    return fiche;
  }
}
