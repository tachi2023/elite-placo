import 'package:flutter/foundation.dart';
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
      final serveurChantiers = data
          .map((json) => Chantier.fromJson(json as Map<String, dynamic>))
          .toList();

      // SQLite chiffré est réservé aux applications natives. Le navigateur
      // utilise directement la réponse API pour rester compatible iOS/Web.
      if (kIsWeb) {
        return inclureArchives
            ? serveurChantiers
            : serveurChantiers
                .where((c) => c.statut != StatutChantier.archive)
                .toList();
      }

      // Mettre à jour le cache local (écrase le cache avec la vérité du serveur)
      final db = await _localDb.database;
      for (final chantier in serveurChantiers) {
        final valeurs = {
          'apiId': chantier.id,
          'nomClient': chantier.nomClient,
          'ville': chantier.ville,
          'typeTravaux': chantier.typeTravaux,
          'statut': chantier.statut,
          'montantDevis': chantier.montantDevis,
          'dateCreation': chantier.dateCreation.toIso8601String(),
          'synchronise': 1,
        };
        final existant = await db.query('chantier_local',
            where: 'apiId = ?', whereArgs: [chantier.id], limit: 1);
        if (existant.isEmpty) {
          await db.insert('chantier_local', valeurs);
        } else if (existant.first['synchronise'] == 1) {
          await db.update('chantier_local', valeurs,
              where: 'apiId = ?', whereArgs: [chantier.id]);
        }
      }
    } catch (e) {
      // Offline : On ignore l'erreur API et on lira juste le cache local
      if (kIsWeb) return const [];
    }

    // Lecture depuis le cache
    final localData = await _localDb.lister('chantier_local');
    List<Chantier> chantiers = localData
        .map((row) => Chantier(
              id: row['apiId'],
              nomClient: row['nomClient'],
              ville: row['ville'],
              typeTravaux: row['typeTravaux'],
              statut: row['statut'],
              montantDevis: (row['montantDevis'] as num).toDouble(),
              dateCreation: DateTime.parse(row['dateCreation']),
              synchronise: row['synchronise'] == 1,
            ))
        .toList();

    if (!inclureArchives) {
      chantiers =
          chantiers.where((c) => c.statut != StatutChantier.archive).toList();
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
    if (kIsWeb) {
      final response =
          await _api.client.post('/api/chantiers', data: chantier.toJson());
      return Chantier.fromJson(response.data as Map<String, dynamic>);
    }

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
    await _localDb.ajouterAFileAttente(
        'chantier', 'CREATION', chantier.toJson(), localId);

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
    try {
      final response = await _api.client.put(
        '/api/chantiers/${chantier.id}/statut',
        queryParameters: {'statut': chantier.statut},
      );
      final chantierServeur =
          Chantier.fromJson(response.data as Map<String, dynamic>);
      if (kIsWeb) return chantierServeur;
      await _mettreAJourCacheLocal(chantierServeur, synchronise: true);
      return chantierServeur;
    } on DioException {
      if (kIsWeb) rethrow;
      if (chantier.id == null) {
        throw Exception(
            'Impossible de synchroniser un chantier local sans identifiant serveur.');
      }
      final localRowId =
          await _mettreAJourCacheLocal(chantier, synchronise: false);
      await _localDb.ajouterAFileAttente(
        'chantier',
        'MODIFICATION_STATUT',
        {
          'id': chantier.id,
          'statut': chantier.statut,
          'lastModifiedDate':
              chantier.dateChangementStatut?.toIso8601String() ??
                  DateTime.now().toIso8601String(),
        },
        localRowId,
      );
      SyncService().synchroniser();
      return chantier.copyWith(synchronise: false);
    }
  }

  Future<int> _mettreAJourCacheLocal(Chantier chantier,
      {required bool synchronise}) async {
    final db = await _localDb.database;
    final whereArgs = [chantier.id];
    final existing = await db.query('chantier_local',
        where: 'apiId = ?', whereArgs: whereArgs, limit: 1);
    final valeurs = {
      'apiId': chantier.id,
      'nomClient': chantier.nomClient,
      'ville': chantier.ville,
      'typeTravaux': chantier.typeTravaux,
      'statut': chantier.statut,
      'montantDevis': chantier.montantDevis,
      'dateCreation': chantier.dateCreation.toIso8601String(),
      'synchronise': synchronise ? 1 : 0,
    };
    if (existing.isNotEmpty) {
      await db.update('chantier_local', valeurs,
          where: 'apiId = ?', whereArgs: whereArgs);
      return existing.first['id'] as int;
    } else {
      return db.insert('chantier_local', valeurs);
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
