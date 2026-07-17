import '../models/mouvement_financier.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';
import '../services/sync_service.dart';
import 'package:dio/dio.dart';

/// Dépôt Offline-First (Phase 3).
class MouvementRepository {
  final ApiService _api = ApiService();
  final LocalDbService _localDb = LocalDbService();

  /// GET /api/chantiers/{id}/mouvements
  Future<List<MouvementFinancier>> listerParChantier(int chantierId) async {
    try {
      final response = await _api.client.get('/api/chantiers/$chantierId/mouvements');
      final List<dynamic> data = response.data;
      
      // On supprime les vieux enregistrements de ce chantier pour remplacer par la source de vérité
      final db = await _localDb.database;
      await db.delete('mouvement_local', where: 'chantierId = ?', whereArgs: [chantierId]);
      
      for (var json in data) {
        final mvmt = MouvementFinancier.fromJson(json as Map<String, dynamic>, chantierId: chantierId);
        await _localDb.inserer('mouvement_local', {
          'apiId': mvmt.id,
          'typeMouvement': mvmt.typeMouvement,
          'date': mvmt.date.toIso8601String().split('T').first,
          'montant': mvmt.montant,
          'chantierId': mvmt.chantierId,
          'nature': mvmt.nature,
          'categorie': mvmt.categorie,
          'description': mvmt.description,
          'synchronise': 1,
        });
      }
    } catch (e) {
      // Offline : ignore l'erreur API
    }

    // Lecture depuis le cache local
    final db = await _localDb.database;
    final localData = await db.query('mouvement_local', where: 'chantierId = ?', whereArgs: [chantierId], orderBy: 'date DESC');
    
    return localData.map((row) => MouvementFinancier(
      id: row['apiId'] as int?,
      typeMouvement: row['typeMouvement'] as String,
      date: DateTime.parse(row['date'] as String),
      montant: row['montant'] as double,
      chantierId: row['chantierId'] as int,
      nature: row['nature'] as String?,
      categorie: row['categorie'] as String?,
      description: row['description'] as String?,
      synchronise: row['synchronise'] == 1,
    )).toList();
  }

  Future<List<MouvementFinancier>> listerTous() async {
    final db = await _localDb.database;
    final localData = await db.query('mouvement_local', orderBy: 'date DESC');
    return localData.map((row) => MouvementFinancier(
      id: row['apiId'] as int?,
      typeMouvement: row['typeMouvement'] as String,
      date: DateTime.parse(row['date'] as String),
      montant: row['montant'] as double,
      chantierId: row['chantierId'] as int,
      nature: row['nature'] as String?,
      categorie: row['categorie'] as String?,
      description: row['description'] as String?,
      synchronise: row['synchronise'] == 1,
    )).toList();
  }

  /// Création Offline-First générique
  Future<MouvementFinancier> creer(MouvementFinancier mouvement) async {
    final isEncaissement = mouvement.typeMouvement == TypeMouvement.encaissement;
    
    // 1. Sauvegarde Locale Immédiate
    final localId = await _localDb.inserer('mouvement_local', {
      'typeMouvement': mouvement.typeMouvement,
      'date': mouvement.date.toIso8601String().split('T').first,
      'montant': mouvement.montant,
      'chantierId': mouvement.chantierId,
      'nature': mouvement.nature,
      'categorie': mouvement.categorie,
      'description': mouvement.description,
      'synchronise': 0, // En attente
    });

    // 2. File d'attente
    final Map<String, dynamic> donneesApi = isEncaissement 
      ? {
          'montant': mouvement.montant,
          'date': mouvement.date.toIso8601String().split('T').first,
          'nature': mouvement.nature,
        }
      : {
          'montant': mouvement.montant,
          'date': mouvement.date.toIso8601String().split('T').first,
          'categorie': mouvement.categorie,
          'description': mouvement.description,
        };

    final action = isEncaissement ? 'CREATION_ENCAISSEMENT' : 'CREATION_DEPENSE';
    await _localDb.ajouterAFileAttente('mouvement', action, {'chantierId': mouvement.chantierId, ...donneesApi}, localId);

    // 3. Tenter de synchroniser
    SyncService().synchroniser();

    return MouvementFinancier(
      id: null,
      typeMouvement: mouvement.typeMouvement,
      date: mouvement.date,
      montant: mouvement.montant,
      chantierId: mouvement.chantierId,
      nature: mouvement.nature,
      categorie: mouvement.categorie,
      description: mouvement.description,
      synchronise: false,
    );
  }

  Future<MouvementFinancier> mettreAJour(MouvementFinancier mouvement) async {
    try {
      final response = await _api.client.put(
        '/api/chantiers/${mouvement.chantierId}/mouvements/${mouvement.id}',
        data: {
          'montant': mouvement.montant,
          'date': mouvement.date.toIso8601String().split('T').first,
        },
      );
      return MouvementFinancier.fromJson(response.data as Map<String, dynamic>, chantierId: mouvement.chantierId);
    } on DioException catch (_) {
      throw Exception('Impossible de mettre à jour le mouvement hors-ligne pour le moment.');
    }
  }

  Future<void> supprimer(int id) async {
    try {
      await _api.client.delete('/api/mouvements/$id');
    } catch (_) {
      throw Exception('Impossible de supprimer le mouvement hors-ligne pour le moment.');
    }
  }
}
