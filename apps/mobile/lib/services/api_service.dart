import 'package:dio/dio.dart';

/// Point d'entrée unique vers l'API Spring Boot.
/// Le jeton JWT est ajouté automatiquement à chaque requête via un
/// intercepteur Dio. Le token est stocké en mémoire et mis à jour
/// par AuthProvider après un login réussi.
class ApiService {
  static final ApiService _instance = ApiService._interne();
  factory ApiService() => _instance;

  late final Dio _dio;
  late final Dio _authDio;
  String? _jetonAcces;
  String? _jetonRafraichissement;
  Future<void>? _refreshEnCours;

  ApiService._interne() {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8081',
    );

    _dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _authDio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_jetonAcces != null && options.extra['skipAuth'] != true) {
          options.headers['Authorization'] = 'Bearer $_jetonAcces';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        final alreadyRetried = error.requestOptions.extra['retried'] == true;

        if (statusCode == 401 && !alreadyRetried && _jetonRafraichissement != null) {
          try {
            await _rafraichirJeton();
            final options = error.requestOptions;
            options.extra['retried'] = true;
            if (_jetonAcces != null) {
              options.headers['Authorization'] = 'Bearer $_jetonAcces';
            }
            final response = await _dio.fetch(options);
            return handler.resolve(response);
          } catch (_) {
            supprimerJetons();
          }
        }

        handler.next(error);
      },
    ));
  }

  Dio get client => _dio;

  /// Appelé par AuthProvider après un login réussi.
  void definirJetons({
    required String jetonAcces,
    required String jetonRafraichissement,
  }) {
    _jetonAcces = jetonAcces;
    _jetonRafraichissement = jetonRafraichissement;
  }

  Future<void> _rafraichirJeton() {
    _refreshEnCours ??= _rafraichirJetonInterne().whenComplete(() {
      _refreshEnCours = null;
    });
    return _refreshEnCours!;
  }

  Future<void> _rafraichirJetonInterne() async {
    if (_jetonRafraichissement == null) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/auth/refresh'),
        error: 'Jeton de rafraîchissement manquant',
        type: DioExceptionType.unknown,
      );
    }

    final response = await _authDio.post(
      '/api/auth/refresh',
      data: {'refreshToken': _jetonRafraichissement},
    );

    final data = response.data as Map<String, dynamic>;
    _jetonAcces = data['jetonAcces'] as String;
    final nouveauRefresh = data['jetonRafraichissement'] as String?;
    if (nouveauRefresh != null && nouveauRefresh.isNotEmpty) {
      _jetonRafraichissement = nouveauRefresh;
    }
  }

  /// Supprime le jeton (déconnexion).
  void supprimerJetons() {
    _jetonAcces = null;
    _jetonRafraichissement = null;
  }

  /// Compatibilité avec l'ancien nom.
  void supprimerJeton() => _jetonAcces = null;

  /// Indique si un jeton est actuellement défini.
  bool get estAuthentifie => _jetonAcces != null;
}
