/// Une pièce dans une fiche de métrage (Module 5 — jusqu'à 30 pièces).
class PieceMetrage {
  final String nomPiece;
  final double longueur;
  final double largeur;
  final double surfaceDeduction; // poutres, piliers, gaines, baies

  PieceMetrage({
    required this.nomPiece,
    required this.longueur,
    required this.largeur,
    this.surfaceDeduction = 0,
  });

  double get surfaceBrute => longueur * largeur;
  double get surfaceNette => surfaceBrute - surfaceDeduction;
}
