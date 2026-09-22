import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'api_service.dart';
import 'local_db_service.dart';

/// Synchronisation Offline-First : push confirmé puis pull incrémental.
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const int _tailleLot = 25;
  final LocalDbService _localDb = LocalDbService();
  final ApiService _api = ApiService();
  bool _isSyncing = false;
  bool _ecouteInitialisee = false;

  /// Relance une synchronisation au retour de la connexion réseau.
  void init() {
    if (_ecouteInitialisee) return;
    _ecouteInitialisee = true;
    Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        synchroniser();
      }
    });
  }

  Future<void> synchroniser() async {
    if (_isSyncing || !_api.estAuthentifie) return;
    _isSyncing = true;
    try {
      var doitContinuer = true;
      while (doitContinuer) {
        final lignes = await _localDb.listerFileAttente(limite: _tailleLot);
        if (lignes.isEmpty) break;
        doitContinuer = await _pousserLot(lignes);
      }
      await _telechargerDelta();
    } on DioException {
      // Les lignes restent dans la file et seront retentées au prochain réseau.
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _pousserLot(List<Map<String, dynamic>> lignes) async {
    final operations = lignes.map((ligne) {
      final operationId = ligne['operationId'] as String? ?? 'legacy-${ligne['id']}';
      return {
        'operationId': operationId,
        'entite': ligne['entite'],
        'action': ligne['action'],
        'localId': ligne['localId'],
        'donnees': jsonDecode(ligne['donneesJson'] as String),
      };
    }).toList();

    final response = await _api.client.post('/api/synchronisation/lot', data: operations);
    final resultats = (response.data as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final parOperation = {
      for (final ligne in lignes)
        (ligne['operationId'] as String? ?? 'legacy-${ligne['id']}'): ligne,
    };

    for (final resultat in resultats) {
      final operationId = resultat['operationId'] as String?;
      final ligne = operationId == null ? null : parOperation[operationId];
      if (ligne == null) continue;
      final idLigne = ligne['id'] as int;
      if (resultat['succes'] == true) {
        await _marquerLigneSynchronisee(ligne, resultat['serveurId'] as int?);
        await _localDb.supprimerDeFileAttente(idLigne);
      } else {
        await _localDb.marquerEchecFileAttente(
          idLigne,
          resultat['message'] as String? ?? 'Échec de synchronisation.',
        );
      }
    }

    // Si une opération échoue, on attend une correction avant de rejouer les suivantes.
    return resultats.length == lignes.length &&
        resultats.every((resultat) => resultat['succes'] == true);
  }

  Future<void> _marquerLigneSynchronisee(
    Map<String, dynamic> ligne,
    int? serveurId,
  ) async {
    final localId = ligne['localId'] as int?;
    if (localId == null) return;
    final entite = ligne['entite'] as String;
    final valeurs = <String, dynamic>{'synchronise': 1};
    if (serveurId != null) valeurs['apiId'] = serveurId;
    await _localDb.mettreAJour(
      entite == 'chantier' ? 'chantier_local' : 'mouvement_local',
      valeurs,
      localId,
    );
  }

  Future<void> _telechargerDelta() async {
    final curseur = await _localDb.lireCurseurSynchronisation();
    final response = await _api.client.get(
      '/api/synchronisation/delta',
      queryParameters: {if (curseur != null) 'depuis': curseur},
    );
    final delta = response.data as Map<String, dynamic>;
    await _fusionnerChantiers((delta['chantiers'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>());
    await _fusionnerMouvements((delta['mouvements'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>());
    final nouveauCurseur = delta['serveurDate'] as String?;
    if (nouveauCurseur != null) {
      await _localDb.enregistrerCurseurSynchronisation(nouveauCurseur);
    }
  }

  Future<void> _fusionnerChantiers(List<Map<String, dynamic>> chantiers) async {
    final db = await _localDb.database;
    for (final chantier in chantiers) {
      final apiId = chantier['id'] as int?;
      if (apiId == null) continue;
      final existant = await db.query(
        'chantier_local',
        where: 'apiId = ?',
        whereArgs: [apiId],
        limit: 1,
      );
      if (existant.isNotEmpty && existant.first['synchronise'] == 0) continue;
      final valeurs = {
        'apiId': apiId,
        'nomClient': chantier['nomClient'],
        'ville': chantier['ville'],
        'typeTravaux': chantier['typeTravaux'],
        'statut': chantier['statut'],
        'montantDevis': chantier['montantDevis'],
        'dateCreation': existant.isNotEmpty
            ? existant.first['dateCreation']
            : DateTime.now().toIso8601String(),
        'synchronise': 1,
      };
      if (existant.isEmpty) {
        await db.insert('chantier_local', valeurs);
      } else {
        await db.update('chantier_local', valeurs, where: 'apiId = ?', whereArgs: [apiId]);
      }
    }
  }

  Future<void> _fusionnerMouvements(List<Map<String, dynamic>> mouvements) async {
    final db = await _localDb.database;
    for (final mouvement in mouvements) {
      final apiId = mouvement['id'] as int?;
      final chantierId = mouvement['chantierId'] as int?;
      if (apiId == null || chantierId == null) continue;
      final existant = await db.query(
        'mouvement_local',
        where: 'apiId = ?',
        whereArgs: [apiId],
        limit: 1,
      );
      if (existant.isNotEmpty && existant.first['synchronise'] == 0) continue;
      final valeurs = {
        'apiId': apiId,
        'typeMouvement': mouvement['typeMouvement'],
        'date': _dateLocale(mouvement['date']),
        'montant': _montant(mouvement['montant']),
        'chantierId': chantierId,
        'nature': mouvement['nature'],
        'categorie': mouvement['categorie'],
        'description': mouvement['description'],
        'synchronise': 1,
      };
      if (existant.isEmpty) {
        await db.insert('mouvement_local', valeurs);
      } else {
        await db.update('mouvement_local', valeurs, where: 'apiId = ?', whereArgs: [apiId]);
      }
    }
  }

  String _dateLocale(Object? valeur) => valeur is String && valeur.contains('T')
      ? valeur.split('T').first
      : (valeur as String? ?? DateTime.now().toIso8601String().split('T').first);

  double _montant(Object? valeur) => valeur is num
      ? valeur.toDouble()
      : double.tryParse('$valeur') ?? 0;
}
