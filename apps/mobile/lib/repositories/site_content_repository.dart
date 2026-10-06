import '../models/site_content.dart';
import '../services/api_service.dart';

class SiteContentRepository {
  final ApiService _api = ApiService();

  Future<List<SiteContent>> listByType(String type) async {
    final response = await _api.client.get('/api/contenu-site/admin/type/$type');
    return (response.data as List<dynamic>)
        .map((item) => SiteContent.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SiteContent> create(SiteContent content) async {
    final response = await _api.client.post(
      '/api/contenu-site',
      data: content.toJson(),
    );
    return SiteContent.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SiteContent> update(SiteContent content) async {
    final response = await _api.client.put(
      '/api/contenu-site/${content.id}',
      data: content.toJson(),
    );
    return SiteContent.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.client.delete('/api/contenu-site/$id');
}
