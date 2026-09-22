/// Une ligne du budget de matériaux calculé (Module 3).
class QuantiteMateriau {
  final String nomMateriau;
  final double quantite;
  final String unite;      // 'plaque', 'ml', 'unité', 'rouleau', 'kg'
  final double? prixUnitaire; // FCFA — null si non renseigné (§10.5-A4)

  const QuantiteMateriau({
    required this.nomMateriau,
    required this.quantite,
    required this.unite,
    this.prixUnitaire,
  });

  double? get sousTotal => prixUnitaire == null ? null : quantite * prixUnitaire!;
}

/// Résultat complet d'un calcul de matériaux pour un chantier (§10.5).
class ResultatCalculMateriaux {
  final String systeme;
  final double surfaceM2;
  final List<QuantiteMateriau> lignes;
  final DateTime dateCalcul;

  ResultatCalculMateriaux({
    required this.systeme,
    required this.surfaceM2,
    required this.lignes,
    DateTime? dateCalcul,
  }) : dateCalcul = dateCalcul ?? DateTime.now();

  /// Budget total — incomplet (null) si au moins un prix unitaire manque,
  /// avec alerte à afficher (§10.5-A4).
  double? get budgetTotal {
    double total = 0;
    for (final ligne in lignes) {
      final sousTotal = ligne.sousTotal;
      if (sousTotal == null) return null;
      total += sousTotal;
    }
    return total;
  }

  bool get budgetIncomplet => lignes.any((l) => l.prixUnitaire == null);
}
