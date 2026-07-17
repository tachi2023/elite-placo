import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _estDeverrouille = false;
  int _tentativesEchouees = 0;
  String? _erreurConnexion;
  bool _isPinConfigured = true;
  DateTime? _lockoutUntil;
  
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  bool get estDeverrouille => _estDeverrouille;
  int get tentativesEchouees => _tentativesEchouees;
  String? get erreurConnexion => _erreurConnexion;
  bool get isPinConfigured => _isPinConfigured;
  DateTime? get lockoutUntil => _lockoutUntil;
  
  bool get isLockedOut => _lockoutUntil != null && _lockoutUntil!.isAfter(DateTime.now());

  final ApiService _api = ApiService();
  final _secureStorage = const FlutterSecureStorage();
  static const _pinKey = 'user_pin_hash';
  static const _attemptsKey = 'failed_attempts';
  static const _lockoutKey = 'lockout_until';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Charger le statut du PIN
    final savedHash = await _secureStorage.read(key: _pinKey);
    _isPinConfigured = savedHash != null && savedHash.isNotEmpty;

    // Charger les infos de blocage
    _tentativesEchouees = prefs.getInt(_attemptsKey) ?? 0;
    final lockoutMs = prefs.getInt(_lockoutKey);
    if (lockoutMs != null) {
      _lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lockoutMs);
      if (!isLockedOut) {
        _lockoutUntil = null;
        _tentativesEchouees = 0;
        await prefs.remove(_attemptsKey);
        await prefs.remove(_lockoutKey);
      }
    }
    
    _isInitializing = false;
    notifyListeners();
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> creerPin(String pin) async {
    final hashed = _hashPin(pin);
    await _secureStorage.write(key: _pinKey, value: hashed);
    _isPinConfigured = true;
    _estDeverrouille = true; // Auto-login après création
    notifyListeners();
    return true;
  }

  Future<bool> verifierPin(String pinSaisi) async {
    if (isLockedOut) {
      _erreurConnexion = 'Application bloquée temporairement.';
      notifyListeners();
      return false;
    }

    final savedHash = await _secureStorage.read(key: _pinKey);
    final hashedSaisi = _hashPin(pinSaisi);

    if (savedHash != hashedSaisi) {
      await _incrementerEchec();
      notifyListeners();
      return false;
    }

    // Succès
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_attemptsKey);
    await prefs.remove(_lockoutKey);
    _tentativesEchouees = 0;
    _lockoutUntil = null;
    
    await _tenterConnexionApi();

    _estDeverrouille = true;
    notifyListeners();
    return true;
  }

  Future<void> _incrementerEchec() async {
    _tentativesEchouees++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_attemptsKey, _tentativesEchouees);

    if (_tentativesEchouees >= 3) {
      int minutes = 0;
      if (_tentativesEchouees == 3) minutes = 1; // 3 essais = 1 min (simplifié, ou 30s)
      else if (_tentativesEchouees == 4) minutes = 2; // 4 essais = 2 min
      else minutes = 5; // > 4 = 5 min

      _lockoutUntil = DateTime.now().add(Duration(minutes: minutes));
      await prefs.setInt(_lockoutKey, _lockoutUntil!.millisecondsSinceEpoch);
      _erreurConnexion = 'Code incorrect. Bloqué pour $minutes minute(s).';
    } else {
      final restants = 3 - _tentativesEchouees;
      _erreurConnexion = 'Code PIN incorrect. $restants essai(s) restant(s).';
    }
  }

  Future<void> _tenterConnexionApi() async {
    try {
      final response = await _api.client.post('/api/auth/login', data: {
        'identifiant': 'raoul.michel',
        'motDePasse': 'changeme',
      });
      final String jeton = response.data['jetonAcces'] as String;
      _api.definirJeton(jeton);
      _erreurConnexion = null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        _erreurConnexion = 'Mode hors-ligne — données locales uniquement.';
      } else {
        _erreurConnexion = 'Connexion serveur échouée (${e.response?.statusCode}).';
      }
    } catch (_) {
      _erreurConnexion = 'Erreur inattendue lors de la connexion.';
    }
  }

  void verrouiller() {
    _estDeverrouille = false;
    _api.supprimerJeton();
    notifyListeners();
  }
}
