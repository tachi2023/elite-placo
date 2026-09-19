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

      final db = await _localDb.database;
      await db.delete('mouvement_local',
          where: 'chantierId = ? AND synchronise = 1', whereArgs: [chantierId]);

      for (var json in data) {
        final mvmt = MouvementFinancier.fromJson(json as Map<String, dynamic>, chantierId: chantierId);
        final valeurs = {
          'apiId': mvmt.id,
          'typeMouvement': mvmt.typeMouvement,
          'date': mvmt.date.toIso8601String().split('T').first,
          'montant': mvmt.montant,
          'chantierId': mvmt.chantierId,
          'nature': mvmt.nature,
          'categorie': mvmt.categorie,
          'description': mvmt.description,
          'synchronise': 1,
        };
        final existant = await db.query(
          'mouvement_local', where: 'apiId = ?', whereArgs: [mvmt.id], limit: 1);
        if (existant.isEmpty) {
          await db.insert('mouvement_local', valeurs);
        } else if (existant.first['synchronise'] == 1) {
          await db.update('mouvement_local', valeurs,
              where: 'apiId = ?', whereArgs: [mvmt.id]);
        }
      }
    } catch (e) {
      // Offline : on conserve le cache local.
    }

    final db = await _localDb.database;
    final localData = await db.query(
      'mouvement_local',
      where: 'chantierId = ?',
      whereArgs: [chantierId],
      orderBy: 'date DESC',
    );

    return localData.map((row) => MouvementFinancier(
          id: row['apiId'] as int?,
          typeMouvement: row['typeMouvement'] as String,
          date: DateTime.parse(row['date'] as String),
          montant: (row['montant'] as num).toDouble(),
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
    return localData
        .map((row) => MouvementFinancier(
              id: row['apiId'] as int?,
              typeMouvement: row['typeMouvement'] as String,
              date: DateTime.parse(row['date'] as String),
              montant: (row['montant'] as num).toDouble(),
              chantierId: row['chantierId'] as int,
              nature: row['nature'] as String?,
              categorie: row['categorie'] as String?,
              description: row['description'] as String?,
              synchronise: row['synchronise'] == 1,
            ))
        .toList();
  }

  /// Création Offline-First générique
  Future<MouvementFinancier> creer(MouvementFinancier mouvement) async {
    final isEncaissement = mouvement.typeMouvement == TypeMouvement.encaissement;

    final localId = await _localDb.inserer('mouvement_local', {
      'typeMouvement': mouvement.typeMouvement,
      'date': mouvement.date.toIso8601String().split('T').first,
      'montant': mouvement.montant,
      'chantierId': mouvement.chantierId,
      'nature': mouvement.nature,
      'categorie': mouvement.categorie,
      'description': mouvement.description,
      'synchronise': 0,
    });

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
    await _localDb.ajouterAFileAttente(
      'mouvement',
      action,
      {'chantierId': mouvement.chantierId, ...donneesApi},
      localId,
    );

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
          if (mouvement.typeMouvement == TypeMouvement.encaissement) 'nature': mouvement.nature,
          if (mouvement.typeMouvement == TypeMouvement.depense) 'categorie': mouvement.categorie,
          if (mouvement.description != null) 'description': mouvement.description,
        },
      );
      final mouvementServeur = MouvementFinancier.fromJson(
        response.data as Map<String, dynamic>,
        chantierId: mouvement.chantierId,
      );
      await _mettreAJourCacheLocal(mouvementServeur, synchronise: true);
      return mouvementServeur;
    } on DioException {
      if (mouvement.id == null) {
        throw Exception('Impossible de synchroniser un mouvement local sans identifiant serveur.');
      }
      final localRowId = await _mettreAJourCacheLocal(mouvement, synchronise: false);
      final donnees = mouvement.toJson()..['chantierId'] = mouvement.chantierId;
      await _localDb.ajouterAFileAttente(
        'mouvement',
        'MODIFICATION_MOUVEMENT',
        donnees,
        localRowId,
      );
      SyncService().synchroniser();
      return mouvement.copyWith(synchronise: false);
    }
  }

  Future<void> supprimer(MouvementFinancier mouvement) async {
    try {
      if (mouvement.id == null) {
        throw Exception('Identifiant mouvement manquant.');
      }
      await _api.client.delete('/api/chantiers/${mouvement.chantierId}/mouvements/${mouvement.id}');
      final db = await _localDb.database;
      await db.delete('mouvement_local', where: 'apiId = ?', whereArgs: [mouvement.id]);
    } on DioException {
      if (mouvement.id == null) {
        throw Exception('Impossible de synchroniser un mouvement local sans identifiant serveur.');
      }
      final db = await _localDb.database;
      final existing = await db.query('mouvement_local', where: 'apiId = ?', whereArgs: [mouvement.id], limit: 1);
      await db.delete('mouvement_local', where: 'apiId = ?', whereArgs: [mouvement.id]);
      await _localDb.ajouterAFileAttente(
        'mouvement',
        'SUPPRESSION_MOUVEMENT',
        {
          'id': mouvement.id,
          'chantierId': mouvement.chantierId,
        },
        existing.isNotEmpty ? existing.first['id'] as int : mouvement.id!,
      );
      SyncService().synchroniser();
    }
  }

  Future<int> _mettreAJourCacheLocal(MouvementFinancier mouvement, {required bool synchronise}) async {
    final db = await _localDb.database;
    final valeurs = {
      'apiId': mouvement.id,
      'typeMouvement': mouvement.typeMouvement,
      'date': mouvement.date.toIso8601String().split('T').first,
      'montant': mouvement.montant,
      'chantierId': mouvement.chantierId,
      'nature': mouvement.nature,
      'categorie': mouvement.categorie,
      'description': mouvement.description,
      'synchronise': synchronise ? 1 : 0,
    };
    final dejaPresent = await db.query('mouvement_local', where: 'apiId = ?', whereArgs: [mouvement.id], limit: 1);
    if (dejaPresent.isNotEmpty) {
      await db.update('mouvement_local', valeurs, where: 'apiId = ?', whereArgs: [mouvement.id]);
      return dejaPresent.first['id'] as int;
    } else {
      return db.insert('mouvement_local', valeurs);
    }
  }
}
