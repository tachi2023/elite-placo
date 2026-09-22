/// Un ouvrier payé sur chantier (Module 6). Peut être affecté à plusieurs
/// chantiers en parallèle (elite.md §10.8-A3).
class Ouvrier {
  final int? id;
  final String nomComplet;
  final String? telephone;

  const Ouvrier({this.id, required this.nomComplet, this.telephone});

  /// Désérialisation depuis l'API REST Spring Boot.
  factory Ouvrier.fromJson(Map<String, dynamic> json) => Ouvrier(
        id: json['id'] as int?,
        nomComplet: json['nomComplet'] as String,
        telephone: json['telephone'] as String?,
      );

  /// Sérialisation pour l'envoi à l'API REST.
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nomComplet': nomComplet,
        if (telephone != null) 'telephone': telephone,
      };
}

/// Paiement d'un ouvrier sur un chantier donné (§10.8). Le total remonte
/// automatiquement dans les dépenses "main d'œuvre" du chantier — voir
/// OuvrierService.enregistrerPaiement().
class AffectationOuvrier {
  final int? id;
  final int ouvrierId;
  final int chantierId;
  final double montantPaye;
  final DateTime datePaiement;
  final bool synchronise;

  const AffectationOuvrier({
    this.id,
    required this.ouvrierId,
    required this.chantierId,
    required this.montantPaye,
    required this.datePaiement,
    this.synchronise = false,
  });

  /// Désérialisation depuis l'API REST Spring Boot.
  /// Le backend renvoie ouvrier et chantier comme objets imbriqués.
  factory AffectationOuvrier.fromJson(Map<String, dynamic> json) =>
      AffectationOuvrier(
        id: json['id'] as int?,
        ouvrierId: json['ouvrier'] != null
            ? (json['ouvrier']['id'] as int)
            : json['ouvrierId'] as int,
        chantierId: json['chantier'] != null
            ? (json['chantier']['id'] as int)
            : json['chantierId'] as int,
        montantPaye: (json['montantPaye'] as num).toDouble(),
        datePaiement: DateTime.parse(json['datePaiement'] as String),
        synchronise: json['synchronise'] as bool? ?? false,
      );

  /// Sérialisation pour l'envoi à l'API REST.
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'montant': montantPaye,
        'date': datePaiement.toIso8601String().split('T').first,
        'synchronise': synchronise,
      };
}
