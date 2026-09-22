import 'package:flutter/material.dart';
import '../models/ouvrier.dart';
import '../repositories/ouvrier_repository.dart';
import '../repositories/mouvement_repository.dart';
import '../repositories/chantier_repository.dart';
import '../services/ouvrier_service.dart';
import '../exceptions/app_exception.dart';

/// Module 6 — expose la liste des ouvriers et leurs paiements à l'UI.
class OuvrierProvider extends ChangeNotifier {
  late final OuvrierService _service;
  final OuvrierRepository ouvrierRepository;

  OuvrierProvider({
    OuvrierRepository? ouvrierRepository,
    required ChantierRepository chantierRepository,
    required MouvementRepository mouvementRepository,
  }) : ouvrierRepository = ouvrierRepository ?? OuvrierRepository() {
    _service = OuvrierService(this.ouvrierRepository, mouvementRepository, chantierRepository);
  }

  List<Ouvrier> _ouvriers = [];
  String? _derniereErreur;

  List<Ouvrier> get ouvriers => _ouvriers;
  String? get derniereErreur => _derniereErreur;

  Future<void> charger() async {
    _ouvriers = await _service.listerOuvriers();
    notifyListeners();
  }

  Future<bool> creerOuvrier(String nomComplet, {String? telephone}) async {
    try {
      await _service.creerOuvrier(nomComplet: nomComplet, telephone: telephone);
      _derniereErreur = null;
      await charger();
      return true;
    } on AppException catch (e) {
      _derniereErreur = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> enregistrerPaiement({
    required int ouvrierId,
    required int chantierId,
    required double montant,
    required DateTime date,
  }) async {
    try {
      await _service.enregistrerPaiement(
        ouvrierId: ouvrierId, chantierId: chantierId, montant: montant, date: date,
      );
      _derniereErreur = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _derniereErreur = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<double> totalMainOeuvre(int chantierId) => _service.totalMainOeuvre(chantierId);
}
