/// Catégories de dépenses définies dans le cahier des charges (elite.md §2,
/// Module 2). L'ordre reprend celui du document source.
class CategorieDepense {
  static const ba13 = 'BA13';
  static const ossature = 'OSSATURE';
  static const visserie = 'VISSERIE';
  static const peintureEnduit = 'PEINTURE_ENDUIT';
  static const transport = 'TRANSPORT';
  static const mainOeuvre = 'MAIN_OEUVRE';
  static const sousTraitant = 'SOUS_TRAITANT';
  static const locationMateriel = 'LOCATION_MATERIEL';
  static const divers = 'DIVERS';

  static const List<String> toutes = [
    ba13, ossature, visserie, peintureEnduit, transport,
    mainOeuvre, sousTraitant, locationMateriel, divers,
  ];

  static String libelle(String categorie) => switch (categorie) {
        ba13 => 'BA13',
        ossature => 'Ossature',
        visserie => 'Visserie',
        peintureEnduit => 'Peinture / enduit',
        transport => 'Transport',
        mainOeuvre => "Main d'œuvre",
        sousTraitant => 'Sous-traitant',
        locationMateriel => 'Location matériel',
        divers => 'Divers',
        _ => categorie,
      };
}

class NatureEncaissement {
  static const acompte = 'ACOMPTE';
  static const versement = 'VERSEMENT';
  static const solde = 'SOLDE';

  static const List<String> toutes = [acompte, versement, solde];

  static String libelle(String nature) => switch (nature) {
        acompte => 'Acompte',
        versement => 'Versement',
        solde => 'Solde',
        _ => nature,
      };
}

class TypeMouvement {
  static const encaissement = 'ENCAISSEMENT';
  static const depense = 'DEPENSE';
}

/// Encaissement ou dépense rattaché à un chantier (table unique côté
/// backend — stratégie SINGLE_TABLE, voir Architecture_Technique §"héritage").
class MouvementFinancier {
  final int? id;
  final String typeMouvement; // TypeMouvement.encaissement | .depense
  final DateTime date;
  final double montant;
  final int chantierId;
  final String? nature;       // renseigné si ENCAISSEMENT
  final String? categorie;    // renseigné si DEPENSE
  final String? description;
  final bool synchronise;

  const MouvementFinancier({
    this.id,
    required this.typeMouvement,
    required this.date,
    required this.montant,
    required this.chantierId,
    this.nature,
    this.categorie,
    this.description,
    this.synchronise = false,
  });

  MouvementFinancier copyWith({
    int? id,
    DateTime? date,
    double? montant,
    String? nature,
    String? categorie,
    String? description,
    bool? synchronise,
  }) {
    return MouvementFinancier(
      id: id ?? this.id,
      typeMouvement: typeMouvement,
      date: date ?? this.date,
      montant: montant ?? this.montant,
      chantierId: chantierId,
      nature: nature ?? this.nature,
      categorie: categorie ?? this.categorie,
      description: description ?? this.description,
      synchronise: synchronise ?? this.synchronise,
    );
  }

  /// Désérialisation depuis l'API REST Spring Boot.
  /// Le backend renvoie `chantier` comme objet imbriqué {"id": 1, ...}.
  factory MouvementFinancier.fromJson(
    Map<String, dynamic> json, {
    int? chantierId,
  }) {
    final int resolvedChantierId = chantierId ??
        (json['chantier'] != null
            ? (json['chantier']['id'] as int)
            : json['chantierId'] as int);
    return MouvementFinancier(
      id: json['id'] as int?,
      typeMouvement: json['typeMouvement'] as String,
      date: DateTime.parse(json['date'] as String),
      montant: (json['montant'] as num).toDouble(),
      chantierId: resolvedChantierId,
      nature: json['nature'] as String?,
      categorie: json['categorie'] as String?,
      description: json['description'] as String?,
      synchronise: json['synchronise'] as bool? ?? false,
    );
  }

  /// Sérialisation pour l'envoi à l'API REST (corps de requête JSON).
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'typeMouvement': typeMouvement,
        'montant': montant,
        'date': date.toIso8601String().split('T').first,
        if (nature != null) 'nature': nature,
        if (categorie != null) 'categorie': categorie,
        if (description != null) 'description': description,
        'synchronise': synchronise,
      };
}
