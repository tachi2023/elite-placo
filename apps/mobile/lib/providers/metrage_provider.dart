import 'package:flutter/material.dart';
import '../models/fiche_metrage.dart';
import '../repositories/metrage_repository.dart';
import '../services/metrage_service.dart';
import '../services/materiaux_service.dart';
import '../models/calcul_materiaux.dart';
import '../exceptions/app_exception.dart';

/// Modules 3 + 5 réunis côté UI : une fiche de métrage alimente
/// directement le calcul de matériaux (voir MateriauxService.calculerDepuisFiche).
class MetrageProvider extends ChangeNotifier {
  final MetrageService _metrageService;
  final MateriauxService _materiauxService = MateriauxService();

  MetrageProvider({MetrageRepository? repository})
      : _metrageService = MetrageService(repository ?? MetrageRepository());

  FicheMetrage? _ficheEnCours;
  String? _derniereErreur;
  ResultatCalculMateriaux? _dernierCalcul;

  FicheMetrage? get ficheEnCours => _ficheEnCours;
  String? get derniereErreur => _derniereErreur;
  ResultatCalculMateriaux? get dernierCalcul => _dernierCalcul;

  void demarrerFiche(int chantierId, String systeme) {
    _ficheEnCours = FicheMetrage(chantierId: chantierId, systeme: systeme);
    notifyListeners();
  }

  Future<bool> ajouterPiece(PieceMetrage piece) async {
    if (_ficheEnCours == null) return false;
    try {
      _ficheEnCours = await _metrageService.ajouterPiece(_ficheEnCours!, piece);
      _derniereErreur = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _derniereErreur = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> validerFiche() async {
    if (_ficheEnCours == null) return false;
    try {
      _ficheEnCours = await _metrageService.validerFiche(_ficheEnCours!);
      _derniereErreur = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _derniereErreur = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Calcule directement les matériaux à partir de la fiche validée
  /// (réutilise surface nette + périmètre déjà calculés — Module 3 + 5).
  bool calculerMateriaux({Map<String, double>? prixUnitaires}) {
    if (_ficheEnCours == null) return false;
    try {
      _dernierCalcul = _materiauxService.calculerDepuisFiche(_ficheEnCours!, prixUnitaires: prixUnitaires);
      _derniereErreur = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _derniereErreur = e.message;
      notifyListeners();
      return false;
    }
  }
}
