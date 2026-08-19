import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../repositories/chantier_repository.dart';
import '../repositories/mouvement_repository.dart';
import '../services/finance_service.dart';
import '../services/dashboard_service.dart';

/// Module 4 — expose la vue globale à l'écran Tableau de bord.
/// Réutilise les MÊMES instances de repositories que ChantierProvider afin
/// que les deux vues restent cohérentes (voir main.dart : les repositories
/// sont créés une seule fois puis injectés partout).
class DashboardProvider extends ChangeNotifier {
  late final DashboardService _service;

  DashboardProvider({
    required ChantierRepository chantierRepository,
    required MouvementRepository mouvementRepository,
  }) {
    final financeService = FinanceService(mouvementRepository, chantierRepository);
    _service = DashboardService(chantierRepository, financeService);
  }

  VueGlobale? _vueGlobale;
  bool _enChargement = false;
  String? _erreur;

  VueGlobale? get vueGlobale => _vueGlobale;
  bool get enChargement => _enChargement;
  String? get erreur => _erreur;

  Future<void> charger() async {
    _enChargement = true;
    _erreur = null;
    notifyListeners();
    try {
      _vueGlobale = await _service.calculerVueGlobale();
    } catch (e) {
      debugPrint('DashboardProvider.charger() erreur: $e');
      _erreur = e.toString();
      // En cas d'erreur (ex: sqflite non dispo sur web), fournir une vue vide
      // pour que l'UI ne reste pas bloquée en chargement infini.
      _vueGlobale ??= VueGlobale.vide();
    }
    _enChargement = false;
    notifyListeners();
  }
}
