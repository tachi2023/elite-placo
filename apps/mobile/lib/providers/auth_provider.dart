import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/sync_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _estDeverrouille = false;
  int _tentativesEchouees = 0;
  String? _erreurConnexion;
  bool _isPinConfigured = false;
  DateTime? _lockoutUntil;
  bool _peutUtiliserBiometrie = false;
  bool _isInitializing = true;

  bool get isInitializing => _isInitializing;
  bool get estDeverrouille => _estDeverrouille;
  int get tentativesEchouees => _tentativesEchouees;
  String? get erreurConnexion => _erreurConnexion;
  bool get isPinConfigured => _isPinConfigured;
  DateTime? get lockoutUntil => _lockoutUntil;
  bool get peutUtiliserBiometrie => _peutUtiliserBiometrie;
  bool get isLockedOut => _lockoutUntil != null && _lockoutUntil!.isAfter(DateTime.now());

  final ApiService _api = ApiService();
  final _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const _pinKey = 'user_pin_hash';
  static const _pinSaltKey = 'user_pin_salt';
  static const _refreshTokenKey = 'refresh_token';
  static const _attemptsKey = 'failed_attempts';
  static const _lockoutKey = 'lockout_until';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHash = await _secureStorage.read(key: _pinKey);
    _isPinConfigured = savedHash != null && savedHash.isNotEmpty;
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
    try {
      _peutUtiliserBiometrie = await _localAuth.canCheckBiometrics && await _localAuth.isDeviceSupported();
    } catch (_) {
      _peutUtiliserBiometrie = false;
    }
    _isInitializing = false;
    notifyListeners();
  }

  String _hashPin(String pin, String salt) => sha256.convert(utf8.encode('$salt:$pin')).toString();

  Future<bool> seConnecter(String identifiant, String motDePasse) async {
    _erreurConnexion = null;
    try {
      final response = await _api.client.post('/api/auth/login', data: {
        'identifiant': identifiant.trim(),
        'motDePasse': motDePasse,
      });
      final data = response.data as Map<String, dynamic>;
      final access = data['jetonAcces'] as String;
      final refresh = data['jetonRafraichissement'] as String;
      _api.definirJetons(jetonAcces: access, jetonRafraichissement: refresh);
      await _secureStorage.write(key: _refreshTokenKey, value: refresh);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _erreurConnexion = e.response?.statusCode == 429
          ? 'Trop de tentatives. Réessayez plus tard.'
          : 'Identifiant ou mot de passe incorrect.';
      notifyListeners();
      return false;
    } catch (_) {
      _erreurConnexion = 'Impossible de joindre le serveur.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> creerPin(String pin) async {
    if (pin.length != 6) return false;
    final salt = base64UrlEncode(List<int>.generate(16, (_) => Random.secure().nextInt(256)));
    await _secureStorage.write(key: _pinSaltKey, value: salt);
    await _secureStorage.write(key: _pinKey, value: _hashPin(pin, salt));
    _isPinConfigured = true;
    _estDeverrouille = true;
    notifyListeners();
    unawaited(SyncService().synchroniser());
    return true;
  }

  Future<bool> verifierPin(String pinSaisi) async {
    if (isLockedOut) {
      _erreurConnexion = 'Application bloquée temporairement.';
      notifyListeners();
      return false;
    }
    final savedHash = await _secureStorage.read(key: _pinKey);
    final salt = await _secureStorage.read(key: _pinSaltKey);
    final hash = salt == null ? sha256.convert(utf8.encode(pinSaisi)).toString() : _hashPin(pinSaisi, salt);
    if (savedHash != hash) {
      await _incrementerEchec();
      notifyListeners();
      return false;
    }
    await _effacerTentatives();
    _estDeverrouille = true;
    notifyListeners();
    unawaited(_restaurerSessionApi());
    return true;
  }

  Future<void> _incrementerEchec() async {
    _tentativesEchouees++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_attemptsKey, _tentativesEchouees);
    if (_tentativesEchouees >= 5) {
      final minutes = _tentativesEchouees == 5 ? 5 : 15;
      _lockoutUntil = DateTime.now().add(Duration(minutes: minutes));
      await prefs.setInt(_lockoutKey, _lockoutUntil!.millisecondsSinceEpoch);
      _erreurConnexion = 'Trop d\'échecs. Réessayez dans $minutes minutes ou reconnectez-vous avec votre mot de passe.';
    } else {
      _erreurConnexion = 'Code PIN incorrect. ${5 - _tentativesEchouees} essai(s) restant(s).';
    }
  }

  Future<void> _effacerTentatives() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_attemptsKey);
    await prefs.remove(_lockoutKey);
    _tentativesEchouees = 0;
    _lockoutUntil = null;
  }

  Future<void> _restaurerSessionApi() async {
    final refresh = await _secureStorage.read(key: _refreshTokenKey);
    if (refresh == null || refresh.isEmpty) {
      _erreurConnexion = 'Reconnectez-vous avec votre mot de passe.';
      return;
    }
    try {
      final response = await _api.client.post('/api/auth/refresh', data: {'refreshToken': refresh});
      final data = response.data as Map<String, dynamic>;
      _api.definirJetons(jetonAcces: data['jetonAcces'] as String, jetonRafraichissement: data['jetonRafraichissement'] as String? ?? refresh);
      await SyncService().synchroniser();
    } on DioException catch (_) {
      _erreurConnexion = 'Serveur indisponible : mode hors-ligne activé.';
    }
  }

  Future<bool> verifierBiometrie() async {
    if (isLockedOut) return false;
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: 'Déverrouillez votre application Élite Placo',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (ok) {
        await _effacerTentatives();
        _estDeverrouille = true;
        notifyListeners();
        unawaited(_restaurerSessionApi());
      }
      return ok;
    } catch (_) {
      _erreurConnexion = 'Biométrie non disponible.';
      notifyListeners();
      return false;
    }
  }

  Future<void> deconnexionComplete() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.delete(key: _pinSaltKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _effacerTentatives();
    _api.supprimerJetons();
    _isPinConfigured = false;
    _estDeverrouille = false;
    notifyListeners();
  }

  void verrouiller() {
    _estDeverrouille = false;
    _api.supprimerJeton();
    notifyListeners();
  }
}
