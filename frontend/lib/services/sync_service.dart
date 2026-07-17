import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'local_db_service.dart';

/// Service de synchronisation en arrière-plan (Phase 3).
/// Écoute les changements de connectivité et vide la file d'attente
/// vers le backend quand Internet est disponible.
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final LocalDbService _localDb = LocalDbService();
  final ApiService _api = ApiService();
  bool _isSyncing = false;

  /// Démarrer l'écoute réseau
  void init() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Si on n'est pas en "none", on essaie de synchroniser
      if (!results.contains(ConnectivityResult.none)) {
        synchroniser();
      }
    });
  }

  /// Déclenche la synchronisation manuelle ou automatique.
  Future<void> synchroniser() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final fileAttente = await _localDb.listerFileAttente();
      if (fileAttente.isEmpty) return; // Rien à synchroniser

      for (var actionRow in fileAttente) {
        final int idAction = actionRow['id'];
        final String entite = actionRow['entite'];
        final String action = actionRow['action'];
        final Map<String, dynamic> donnees = jsonDecode(actionRow['donneesJson']);
        final int? localId = actionRow['localId'];

        bool succes = false;

        try {
          if (entite == 'chantier' && action == 'CREATION') {
            final response = await _api.client.post('/api/chantiers', data: donnees);
            final apiId = response.data['id'];
            if (localId != null) {
              await _localDb.mettreAJour('chantier_local', {'apiId': apiId, 'synchronise': 1}, localId);
            }
            succes = true;
          } else if (entite == 'mouvement') {
            final chantierId = donnees['chantierId'];
            donnees.remove('chantierId'); // pas besoin dans le body pour l'API Spring
            if (action == 'CREATION_ENCAISSEMENT') {
              final response = await _api.client.post('/api/chantiers/$chantierId/mouvements/encaissements', data: donnees);
              if (localId != null) {
                await _localDb.mettreAJour('mouvement_local', {'apiId': response.data['id'], 'synchronise': 1}, localId);
              }
              succes = true;
            } else if (action == 'CREATION_DEPENSE') {
              final response = await _api.client.post('/api/chantiers/$chantierId/mouvements/depenses', data: donnees);
              if (localId != null) {
                await _localDb.mettreAJour('mouvement_local', {'apiId': response.data['id'], 'synchronise': 1}, localId);
              }
              succes = true;
            }
          }

          if (succes) {
            await _localDb.supprimerDeFileAttente(idAction);
          }
        } on DioException catch (e) {
          // Erreur serveur (500) ou timeout : on laisse l'action dans la file.
          if (e.response?.statusCode != null && e.response!.statusCode! >= 400 && e.response!.statusCode! < 500) {
            // Erreur 400 : donnée invalide (ex: validation Spring Boot échouée). 
            // On la supprime pour ne pas bloquer infiniment la boucle.
            // Dans une app réelle, on notifierait l'utilisateur d'un conflit.
            await _localDb.supprimerDeFileAttente(idAction);
          }
        } catch (e) {
          // Exception non liée au réseau, on continue.
        }
      }

      // TODO : Après avoir vidé la file d'attente (Upload), on pourrait
      // faire un (Download) pour récupérer les données modifiées par un
      // autre utilisateur (ex: l'associé).

    } finally {
      _isSyncing = false;
    }
  }
}
