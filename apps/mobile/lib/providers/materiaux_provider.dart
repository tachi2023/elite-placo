import 'package:flutter/material.dart';
import '../models/calcul_materiaux.dart';
import '../services/materiaux_service.dart';
import '../exceptions/app_exception.dart';

/// Module 3 — calcul direct (surface saisie à la main, sans passer par une
/// fiche de métrage). Pour le calcul basé sur une fiche déjà saisie,
/// voir MetrageProvider.calculerMateriaux() (Script 6).
class MateriauxProvider extends ChangeNotifier {
  final MateriauxService _service = MateriauxService();

  ResultatCalculMateriaux? _resultat;
  String? _derniereErreur;

  ResultatCalculMateriaux? get resultat => _resultat;
  String? get derniereErreur => _derniereErreur;

  bool calculer({
    required double surfaceM2,
    required String systeme,
    Map<String, double>? prixUnitaires,
  }) {
    try {
      _resultat = _service.calculer(
        surfaceM2: surfaceM2, systeme: systeme, prixUnitaires: prixUnitaires,
      );
      _derniereErreur = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _derniereErreur = e.message;
      _resultat = null;
      notifyListeners();
      return false;
    }
  }
}
