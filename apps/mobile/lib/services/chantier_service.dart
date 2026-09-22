import '../models/chantier.dart';
import '../repositories/chantier_repository.dart';
import '../exceptions/app_exception.dart';

/// Module 1 — création, statuts, modification, archivage, liste temps
/// réel des chantiers (elite.md §10.2, §10.9, §10.10).
class ChantierService {
  final ChantierRepository _repository;
  ChantierService(this._repository);

  Future<List<Chantier>> listerChantiersActifs() =>
      _repository.listerTous(inclureArchives: false);

  Future<List<Chantier>> listerChantiersArchives() async {
    final tous = await _repository.listerTous(inclureArchives: true);
    return tous.where((c) => c.statut == StatutChantier.archive).toList();
  }

  Future<List<Chantier>> filtrerParStatut(String statut) async {
    final tous = await listerChantiersActifs();
    return tous.where((c) => c.statut == statut).toList();
  }

  /// §10.2 — création d'un chantier. A1/A2 : validation stricte avant tout
  /// enregistrement (aucune donnée invalide ne doit atteindre le dépôt).
  Future<Chantier> creerChantier({
    required String nomClient,
    String? ville,
    required String typeTravaux,
    required double montantDevis,
  }) async {
    if (nomClient.trim().isEmpty) {
      throw const AppException('Le nom du client est obligatoire.');
    }
    if (typeTravaux.trim().isEmpty) {
      throw const AppException('Le type de travaux est obligatoire.');
    }
    if (montantDevis < 0) {
      throw const AppException('Le montant du devis ne peut pas être négatif.');
    }

    final chantier = Chantier(
      nomClient: nomClient.trim(),
      ville: ville?.trim(),
      typeTravaux: typeTravaux.trim(),
      montantDevis: montantDevis,
      statut: StatutChantier.aVenir, // toujours "À venir" à la création (§10.2, étape 4)
      synchronise: false,            // en attente tant que non envoyé au serveur
    );

    return _repository.creer(chantier);
  }

  /// §10.9 — changement de statut, en respectant le cycle de vie défini
  /// dans StatutChantier.transitionsValides (A1 : pas de saut d'étape).
  Future<Chantier> changerStatut(int chantierId, String nouveauStatut) async {
    final chantier = await _repository.trouverParId(chantierId);
    if (chantier == null) {
      throw const AppException('Chantier introuvable.');
    }
    // A3 — chantier archivé : bloque tout changement de statut direct.
    if (chantier.statut == StatutChantier.archive) {
      throw const AppException(
          'Ce chantier est archivé. Désarchivez-le avant de changer son statut.');
    }
    final transitionsPermises = StatutChantier.transitionsValides[chantier.statut] ?? [];
    if (!transitionsPermises.contains(nouveauStatut)) {
      final possibles = transitionsPermises.map(StatutChantier.libelle).join(', ');
      throw AppException(
          'Transition invalide : "${StatutChantier.libelle(chantier.statut)}" ne peut aller '
          'que vers : ${possibles.isEmpty ? "aucun statut" : possibles}.');
    }

    final misAJour = chantier.copyWith(
      statut: nouveauStatut,
      dateChangementStatut: DateTime.now(),
      synchronise: false,
    );
    return _repository.mettreAJour(misAJour);
  }

  /// §10.10 — archivage : uniquement depuis "Terminé" (A1).
  Future<Chantier> archiver(int chantierId) async {
    final chantier = await _repository.trouverParId(chantierId);
    if (chantier == null) {
      throw const AppException('Chantier introuvable.');
    }
    if (chantier.statut != StatutChantier.termine) {
      throw const AppException(
          'Seul un chantier "Terminé" peut être archivé.');
    }
    final archive = chantier.copyWith(
      statut: StatutChantier.archive,
      dateChangementStatut: DateTime.now(),
      synchronise: false,
    );
    return _repository.mettreAJour(archive);
  }

  /// §10.10-A3 — désarchivage (point ouvert, fonctionnalité proposée mais
  /// à confirmer avec le dirigeant avant mise en production réelle).
  Future<Chantier> desarchiver(int chantierId, {String versStatut = StatutChantier.termine}) async {
    final chantier = await _repository.trouverParId(chantierId);
    if (chantier == null) {
      throw const AppException('Chantier introuvable.');
    }
    if (chantier.statut != StatutChantier.archive) {
      throw const AppException('Ce chantier n\'est pas archivé.');
    }
    final restaure = chantier.copyWith(
      statut: versStatut,
      dateChangementStatut: DateTime.now(),
      synchronise: false,
    );
    return _repository.mettreAJour(restaure);
  }
}
