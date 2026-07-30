import 'package:dio/dio.dart';

/// Point d'entrée unique vers l'API Spring Boot.
/// Le jeton JWT est ajouté automatiquement à chaque requête via un
/// intercepteur Dio. Le token est stocké en mémoire et mis à jour
/// par AuthProvider après un login réussi.
class ApiService {
  static final ApiService _instance = ApiService._interne();
  factory ApiService() => _instance;

  late final Dio _dio;
  String? _jeton;

  ApiService._interne() {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    );

    _dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_jeton != null) {
          options.headers['Authorization'] = 'Bearer $_jeton';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // 401 → le jeton a expiré, on pourrait tenter un refresh ici
        // TODO Phase 5 : implémenter le rafraîchissement automatique du JWT
        handler.next(error);
      },
    ));
  }

  Dio get client => _dio;

  /// Appelé par AuthProvider après un login réussi.
  void definirJeton(String jeton) => _jeton = jeton;

  /// Supprime le jeton (déconnexion).
  void supprimerJeton() => _jeton = null;

  /// Indique si un jeton est actuellement défini.
  bool get estAuthentifie => _jeton != null;
}
