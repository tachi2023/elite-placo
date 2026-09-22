/// Statuts possibles d'un chantier (cycle de vie — voir Diagramme
/// d'états-transitions, elite.md §5 et §10.9).
class StatutChantier {
  static const aVenir = 'A_VENIR';
  static const enCours = 'EN_COURS';
  static const enPause = 'EN_PAUSE';
  static const termine = 'TERMINE';
  static const archive = 'ARCHIVE';

  /// Transitions valides depuis chaque statut (§10.9-A1 : on ne peut pas
  /// sauter une étape, ex. "À venir" -> "Terminé" est interdit).
  static const Map<String, List<String>> transitionsValides = {
    aVenir: [enCours],
    enCours: [enPause, termine],
    enPause: [enCours],
    termine: [archive], // archivage = scénario dédié §10.10, pas un statut du cycle normal
    archive: [], // désarchivage traité à part (point ouvert §9)
  };

  static const List<String> tous = [aVenir, enCours, enPause, termine, archive];

  static String libelle(String statut) => switch (statut) {
        aVenir => 'À venir',
        enCours => 'En cours',
        enPause => 'En pause',
        termine => 'Terminé',
        archive => 'Archivé',
        _ => statut,
      };
}

/// Modèle de données Chantier côté client (miroir de l'entité JPA backend
/// et du schéma V1/V2 généré par le Script 2 — table `chantier`).
class Chantier {
  final int? id;
  final String nomClient;
  final String? ville;
  final String? typeTravaux;
  final String statut;
  final double montantDevis;
  final DateTime dateCreation;
  final DateTime? dateChangementStatut;
  final bool synchronise;

  Chantier({
    this.id,
    required this.nomClient,
    this.ville,
    this.typeTravaux,
    this.statut = StatutChantier.aVenir,
    this.montantDevis = 0.0,
    DateTime? dateCreation,
    this.dateChangementStatut,
    this.synchronise = false,
  }) : dateCreation = dateCreation ?? DateTime.now();

  Chantier copyWith({
    int? id,
    String? nomClient,
    String? ville,
    String? typeTravaux,
    String? statut,
    double? montantDevis,
    DateTime? dateChangementStatut,
    bool? synchronise,
  }) {
    return Chantier(
      id: id ?? this.id,
      nomClient: nomClient ?? this.nomClient,
      ville: ville ?? this.ville,
      typeTravaux: typeTravaux ?? this.typeTravaux,
      statut: statut ?? this.statut,
      montantDevis: montantDevis ?? this.montantDevis,
      dateCreation: dateCreation,
      dateChangementStatut: dateChangementStatut ?? this.dateChangementStatut,
      synchronise: synchronise ?? this.synchronise,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nom_client': nomClient,
        'ville': ville,
        'type_travaux': typeTravaux,
        'statut': statut,
        'montant_devis': montantDevis,
        'date_creation': dateCreation.toIso8601String(),
        'synchronise': synchronise ? 1 : 0,
      };

  factory Chantier.fromMap(Map<String, dynamic> map) => Chantier(
        id: map['id'] as int?,
        nomClient: map['nom_client'] as String,
        ville: map['ville'] as String?,
        typeTravaux: map['type_travaux'] as String?,
        statut: map['statut'] as String,
        montantDevis: (map['montant_devis'] as num).toDouble(),
        dateCreation: DateTime.parse(map['date_creation'] as String),
        synchronise: (map['synchronise'] as int) == 1,
      );

  /// Désérialisation depuis la réponse JSON de l'API REST Spring Boot.
  /// Les clés sont en camelCase (nomClient, montantDevis, etc.).
  factory Chantier.fromJson(Map<String, dynamic> json) => Chantier(
        id: json['id'] as int?,
        nomClient: json['nomClient'] as String,
        ville: json['ville'] as String?,
        typeTravaux: json['typeTravaux'] as String?,
        statut: json['statut'] as String,
        montantDevis: (json['montantDevis'] as num).toDouble(),
        dateCreation: json['dateCreation'] != null
            ? DateTime.parse(json['dateCreation'] as String)
            : null,
        synchronise: json['synchronise'] as bool? ?? false,
      );

  /// Sérialisation vers le JSON REST API (clés camelCase).
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nomClient': nomClient,
        'ville': ville,
        'typeTravaux': typeTravaux,
        'statut': statut,
        'montantDevis': montantDevis,
        'dateCreation': dateCreation.toIso8601String(),
        'synchronise': synchronise,
      };
}
