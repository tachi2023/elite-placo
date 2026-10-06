import '../services/api_service.dart';

class ChantierAdminRepository {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> etapes(int chantierId) async =>
      _list('/api/chantiers/$chantierId/etapes');

  Future<Map<String, dynamic>> ajouterEtape(int chantierId, String libelle, int ordre) async {
    final response = await _api.client.post('/api/chantiers/$chantierId/etapes', data: {
      'libelle': libelle,
      'ordre': ordre,
      'statut': 'A_FAIRE',
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> modifierEtape(int chantierId, Map<String, dynamic> etape) async {
    final response = await _api.client.put('/api/chantiers/$chantierId/etapes/${etape['id']}', data: {
      'libelle': etape['libelle'],
      'ordre': etape['ordre'],
      'statut': etape['statut'],
      'dateFin': etape['dateFin'],
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> supprimerEtape(int chantierId, int id) =>
      _api.client.delete('/api/chantiers/$chantierId/etapes/$id');

  Future<List<Map<String, dynamic>>> photos(int chantierId) async =>
      _list('/api/chantiers/$chantierId/medias/photos');

  Future<List<Map<String, dynamic>>> documents(int chantierId) async =>
      _list('/api/chantiers/$chantierId/medias/documents');

  Future<Map<String, dynamic>> ajouterMedia(int chantierId, String kind, {
    required String url,
    String? publicId,
    String? libelle,
    String? avantApres,
    bool visibleClient = true,
  }) async {
    final response = await _api.client.post('/api/chantiers/$chantierId/medias/$kind', data: {
      'url': url,
      'publicId': publicId,
      'libelle': libelle,
      'avantApres': avantApres,
      'visibleClient': visibleClient,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> modifierVisibilite(int chantierId, String kind, int id, bool visible) =>
      _api.client.patch('/api/chantiers/$chantierId/medias/$kind/$id/visibilite', queryParameters: {'visible': visible});

  Future<void> supprimerMedia(int chantierId, String kind, int id) =>
      _api.client.delete('/api/chantiers/$chantierId/medias/$kind/$id');

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final response = await _api.client.get(path);
    return (response.data as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }
}
