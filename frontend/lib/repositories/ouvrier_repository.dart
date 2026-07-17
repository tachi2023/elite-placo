import '../models/ouvrier.dart';
import '../services/api_service.dart';

/// Dépôt connecté à l'API REST Spring Boot pour les ouvriers et paiements.
class OuvrierRepository {
  final ApiService _api = ApiService();

  /// GET /api/ouvriers
  Future<List<Ouvrier>> listerOuvriers() async {
    final response = await _api.client.get('/api/ouvriers');
    final List<dynamic> data = response.data;
    return data.map((json) => Ouvrier.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// POST /api/ouvriers
  Future<Ouvrier> creerOuvrier(Ouvrier ouvrier) async {
    final response = await _api.client.post('/api/ouvriers', data: {
      'nomComplet': ouvrier.nomComplet,
      if (ouvrier.telephone != null) 'telephone': ouvrier.telephone,
    });
    return Ouvrier.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/chantiers/{id}/ouvriers — historique des paiements sur un chantier.
  Future<List<AffectationOuvrier>> listerAffectationsParChantier(int chantierId) async {
    final response = await _api.client.get('/api/chantiers/$chantierId/ouvriers');
    final List<dynamic> data = response.data;
    return data
        .map((json) => AffectationOuvrier.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/chantiers/{chantierId}/ouvriers/{ouvrierId}/paiement
  Future<AffectationOuvrier> ajouterPaiement(AffectationOuvrier affectation) async {
    final response = await _api.client.post(
      '/api/chantiers/${affectation.chantierId}/ouvriers/${affectation.ouvrierId}/paiement',
      data: {
        'montant': affectation.montantPaye,
        'date': affectation.datePaiement.toIso8601String().split('T').first,
      },
    );
    return AffectationOuvrier.fromJson(response.data as Map<String, dynamic>);
  }

  /// Calcule le total des paiements main d'œuvre sur un chantier.
  /// Fait la somme côté client à partir de l'historique.
  Future<double> totalMainOeuvre(int chantierId) async {
    final affectations = await listerAffectationsParChantier(chantierId);
    return affectations.fold<double>(0.0, (sum, a) => sum + a.montantPaye);
  }
}
