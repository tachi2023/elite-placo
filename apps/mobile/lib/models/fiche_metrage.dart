/// Systèmes de plâtrerie proposés au calcul des matériaux (Module 3) et
/// utilisés pour la fiche de métrage (Module 5).
class SystemePlatrerie {
  static const corniereFourrureBa13 = 'CORNIERE_FOURRURE_BA13'; // plafond
  static const railsMontantsBa13 = 'RAILS_MONTANTS_BA13';       // cloison

  static String libelle(String systeme) => switch (systeme) {
        corniereFourrureBa13 => 'Cornière + Fourrure + BA13',
        railsMontantsBa13 => 'Rails + Montants + BA13',
        _ => systeme,
      };
}

/// Une pièce dans une fiche de métrage (Module 5 — jusqu'à 30 pièces,
/// elite.md §10.6-A2).
class PieceMetrage {
  final String nomPiece;
  final double longueur;   // mètres
  final double largeur;    // mètres
  final double surfaceDeduction; // poutres, piliers, gaines, baies (m²)

  const PieceMetrage({
    required this.nomPiece,
    required this.longueur,
    required this.largeur,
    this.surfaceDeduction = 0,
  });

  double get surfaceBrute => longueur * largeur;
  double get perimetre => 2 * (longueur + largeur);
  double get surfaceNette {
    final nette = surfaceBrute - surfaceDeduction;
    return nette < 0 ? 0 : nette; // une déduction ne rend jamais une surface négative
  }

  /// Désérialisation depuis l'API REST Spring Boot.
  factory PieceMetrage.fromJson(Map<String, dynamic> json) => PieceMetrage(
        nomPiece: json['nomPiece'] as String,
        longueur: (json['longueur'] as num).toDouble(),
        largeur: (json['largeur'] as num).toDouble(),
        surfaceDeduction: (json['surfaceDeduction'] as num? ?? 0).toDouble(),
      );

  /// Sérialisation pour l'envoi à l'API REST.
  Map<String, dynamic> toJson() => {
        'nomPiece': nomPiece,
        'longueur': longueur,
        'largeur': largeur,
        'surfaceDeduction': surfaceDeduction,
      };
}

/// Fiche de métrage complète, rattachée à un chantier (§10.6).
class FicheMetrage {
  final int? id;
  final int chantierId;
  final String systeme;
  final List<PieceMetrage> pieces;
  final DateTime dateCreation;
  final bool synchronise;

  FicheMetrage({
    this.id,
    required this.chantierId,
    required this.systeme,
    List<PieceMetrage>? pieces,
    DateTime? dateCreation,
    this.synchronise = false,
  })  : pieces = pieces ?? [],
        dateCreation = dateCreation ?? DateTime.now();

  double get surfaceNetteTotale =>
      pieces.fold(0.0, (total, p) => total + p.surfaceNette);

  double get perimetreTotal =>
      pieces.fold(0.0, (total, p) => total + p.perimetre);

  /// Désérialisation depuis l'API REST Spring Boot.
  factory FicheMetrage.fromJson(Map<String, dynamic> json) {
    final List<dynamic> piecesJson = json['pieces'] as List<dynamic>? ?? [];
    return FicheMetrage(
      id: json['id'] as int?,
      chantierId: json['chantier'] != null
          ? (json['chantier']['id'] as int)
          : json['chantierId'] as int,
      systeme: json['systeme'] as String,
      pieces: piecesJson
          .map((p) => PieceMetrage.fromJson(p as Map<String, dynamic>))
          .toList(),
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'] as String)
          : null,
      synchronise: json['synchronise'] as bool? ?? false,
    );
  }

  /// Sérialisation pour l'envoi à l'API REST.
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'chantierId': chantierId,
        'systeme': systeme,
        'pieces': pieces.map((p) => p.toJson()).toList(),
        'dateCreation': dateCreation.toIso8601String(),
        'synchronise': synchronise,
      };
}
