import 'package:flutter/material.dart';
import '../models/chantier.dart';
import '../repositories/chantier_repository.dart';
import '../repositories/mouvement_repository.dart';
import '../services/chantier_service.dart';
import '../services/finance_service.dart';
import '../exceptions/app_exception.dart';

/// Expose la liste des chantiers et leur situation financière à l'UI.
/// Branché sur les vrais services métier (Modules 1 et 2) — plus de TODO.
class ChantierProvider extends ChangeNotifier {
  final ChantierRepository chantierRepository;
  final MouvementRepository mouvementRepository;
  late final ChantierService _chantierService;
  late final FinanceService _financeService;

  ChantierProvider({ChantierRepository? chantierRepository, MouvementRepository? mouvementRepository})
      : chantierRepository = chantierRepository ?? ChantierRepository(),
        mouvementRepository = mouvementRepository ?? MouvementRepository() {
    _chantierService = ChantierService(this.chantierRepository);
    _financeService = FinanceService(this.mouvementRepository, this.chantierRepository);
  }

  List<Chantier> _chantiers = [];
  final Map<int, SituationFinanciere> _situations = {};
  bool _enChargement = false;
  String? _derniereErreur;

  List<Chantier> get chantiers => _chantiers;
  bool get enChargement => _enChargement;
  String? get derniereErreur => _derniereErreur;
  SituationFinanciere? situationDe(int chantierId) => _situations[chantierId];

  Future<void> chargerChantiers() async {
    _enChargement = true;
    notifyListeners();

    _chantiers = await _chantierService.listerChantiersActifs();
    for (final c in _chantiers) {
      _situations[c.id!] = await _financeService.calculerSituation(c);
    }

    _enChargement = false;
    notifyListeners();
  }

  List<Chantier> filtrerParStatut(String? statut) {
    if (statut == null) return _chantiers;
    return _chantiers.where((c) => c.statut == statut).toList();
  }

  /// Retourne true si la création a réussi ; en cas d'échec, le message
  /// est disponible dans `derniereErreur` (à afficher dans un SnackBar).
  Future<bool> creerChantier({
    required String nomClient,
    String? ville,
    required String typeTravaux,
    required double montantDevis,
  }) async {
    try {
      await _chantierService.creerChantier(
        nomClient: nomClient, ville: ville, typeTravaux: typeTravaux, montantDevis: montantDevis,
      );
      _derniereErreur = null;
      await chargerChantiers();
      return true;
    } on AppException catch (e) {
      _derniereErreur = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changerStatut(int chantierId, String nouveauStatut) async {
    try {
      await _chantierService.changerStatut(chantierId, nouveauStatut);
      _derniereErreur = null;
      await chargerChantiers();
      return true;
    } on AppException catch (e) {
      _derniereErreur = e.message;
      notifyListeners();
      return false;
    }
  }
}
