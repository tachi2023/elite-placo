import '../models/chantier.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';
import '../services/sync_service.dart';
import 'package:dio/dio.dart';

/// Dépôt Offline-First (Phase 3).
class ChantierRepository {
  final ApiService _api = ApiService();
  final LocalDbService _localDb = LocalDbService();

  /// GET /api/chantiers -> met à jour le cache local -> retourne le cache
  Future<List<Chantier>> listerTous({bool inclureArchives = false}) async {
    try {
      final response = await _api.client.get('/api/chantiers');
      final List<dynamic> data = response.data;
      
      // Mettre à jour le cache local (écrase le cache avec la vérité du serveur)
      await _localDb.viderTable('chantier_local');
      for (var json in data) {
        final chantier = Chantier.fromJson(json as Map<String, dynamic>);
        await _localDb.inserer('chantier_local', {
          'apiId': chantier.id,
          'nomClient': chantier.nomClient,
          'ville': chantier.ville,
          'typeTravaux': chantier.typeTravaux,
          'statut': chantier.statut,
          'montantDevis': chantier.montantDevis,
          'dateCreation': chantier.dateCreation.toIso8601String(),
          'synchronise': 1,
        });
      }
    } catch (e) {
      // Offline : On ignore l'erreur API et on lira juste le cache local
    }

    // Lecture depuis le cache
    final localData = await _localDb.lister('chantier_local');
    List<Chantier> chantiers = localData.map((row) => Chantier(
      id: row['apiId'],
      nomClient: row['nomClient'],
      ville: row['ville'],
      typeTravaux: row['typeTravaux'],
      statut: row['statut'],
      montantDevis: row['montantDevis'],
      dateCreation: DateTime.parse(row['dateCreation']),
      synchronise: row['synchronise'] == 1,
    )).toList();

    if (!inclureArchives) {
      chantiers = chantiers.where((c) => c.statut != StatutChantier.archive).toList();
    }
    return chantiers;
  }

  Future<Chantier?> trouverParId(int id) async {
    final tous = await listerTous(inclureArchives: true);
    try {
      return tous.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// POST /api/chantiers (Offline-First)
  Future<Chantier> creer(Chantier chantier) async {
    // 1. Sauvegarde Locale Immédiate
    final localId = await _localDb.inserer('chantier_local', {
      'nomClient': chantier.nomClient,
      'ville': chantier.ville,
      'typeTravaux': chantier.typeTravaux,
      'statut': chantier.statut,
      'montantDevis': chantier.montantDevis,
      'dateCreation': chantier.dateCreation.toIso8601String(),
      'synchronise': 0, // En attente
    });

    // 2. Ajout à la file d'attente
    await _localDb.ajouterAFileAttente('chantier', 'CREATION', chantier.toJson(), localId);

    // 3. Tenter de synchroniser en arrière-plan
    SyncService().synchroniser();

    return Chantier(
      id: null, // Sera mis à jour par le sync
      nomClient: chantier.nomClient,
      ville: chantier.ville,
      typeTravaux: chantier.typeTravaux,
      statut: chantier.statut,
      montantDevis: chantier.montantDevis,
      dateCreation: chantier.dateCreation,
      synchronise: false,
    );
  }

  /// PUT /api/chantiers/{id}/statut
  Future<Chantier> mettreAJour(Chantier chantier) async {
    // Dans cette version simplifiée de la Phase 3, on va juste tenter l'API
    // Si échec -> throw (On limitera le vrai mode offline complet à la création pour ce POC).
    try {
      final response = await _api.client.put(
        '/api/chantiers/${chantier.id}/statut',
        queryParameters: {'statut': chantier.statut},
      );
      return Chantier.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Impossible de mettre à jour le statut hors-ligne pour le moment.');
    }
  }

  /// POST /api/chantiers/{id}/suivi
  Future<String> genererLienSuivi(int id) async {
    try {
      final response = await _api.client.post('/api/chantiers/$id/suivi');
      // L'API renvoie le code sous forme de String
      return response.data.toString();
    } on DioException catch (e) {
      throw Exception('Erreur lors de la génération du lien: ${e.message}');
    }
  }
}
