import '../models/calcul_materiaux.dart';
import '../models/fiche_metrage.dart';
import '../exceptions/app_exception.dart';

/// Module 3 — calcul automatique des matériaux à partir de la surface et
/// du système choisi, avec +15% de marge de perte (elite.md §2, Module 3 ;
/// §10.5).
///
/// ⚠️ Les coefficients ci-dessous (espacement des fourrures/montants,
/// couverture d'une plaque BA13, consommation de vis/enduit au m²) sont
/// des VALEURS DE CHANTIER STANDARD, non fixées par le cahier des charges
/// (qui ne donne pas de formule). À FAIRE VALIDER avec le dirigeant avant
/// tout usage réel — même principe que les seuils de marge dans elite.md.
class MateriauxService {
  static const double margePerte = 1.15; // +15%, imposé par le cahier des charges

  // Dimensions standard d'une plaque BA13 (m).
  static const double _longueurPlaqueBa13 = 2.60;
  static const double _largeurPlaqueBa13 = 1.20;
  static double get _surfacePlaque => _longueurPlaqueBa13 * _largeurPlaqueBa13; // 3.12 m²

  static const double _longueurBarreFourrureOuMontant = 4.0; // m, barre standard
  static const double _longueurBarreRailOuCorniere = 3.0;    // m, barre standard
  static const double _espacementEntraxe = 0.60;              // m, entre fourrures/montants
  static const double _consommationVisPlacoParM2 = 25;        // vis / m² de BA13
  static const double _consommationVisAutoforeuseParM2 = 10;  // vis / m² d'ossature
  static const double _mlBandeAJointParM2 = 0.4;               // ml de bande / m²
  static const double _kgEnduitParM2 = 0.3;                    // kg / m²

  ResultatCalculMateriaux calculer({
    required double surfaceM2,
    required String systeme,
    double? perimetreM,
    Map<String, double>? prixUnitaires, // clé = nom du matériau, valeur = FCFA
  }) {
    // A1 — surface invalide.
    if (surfaceM2 <= 0) {
      throw const AppException('La surface doit être un nombre positif.');
    }
    // A2 — système non sélectionné.
    if (systeme != SystemePlatrerie.corniereFourrureBa13 &&
        systeme != SystemePlatrerie.railsMontantsBa13) {
      throw const AppException('Choisissez un système de plâtrerie.');
    }

    final perimetre = perimetreM ?? _perimetreEstime(surfaceM2);

    final nombrePlaques = _avecMarge(surfaceM2 / _surfacePlaque);
    final visPlaco = _avecMarge(surfaceM2 * _consommationVisPlacoParM2);
    final visAutoforeuses = _avecMarge(surfaceM2 * _consommationVisAutoforeuseParM2);
    final bandeAJoint = _avecMarge(surfaceM2 * _mlBandeAJointParM2);
    final enduit = _avecMarge(surfaceM2 * _kgEnduitParM2);

    final lignes = <QuantiteMateriau>[
      QuantiteMateriau(
        nomMateriau: 'Plaques BA13 (2,60 × 1,20 m)',
        quantite: nombrePlaques.ceilToDouble(),
        unite: 'plaque',
        prixUnitaire: prixUnitaires?['ba13'],
      ),
    ];

    if (systeme == SystemePlatrerie.corniereFourrureBa13) {
      // Plafond : fourrures espacées de 60 cm sur la largeur, cornière en périphérie.
      final mlFourrure = _avecMarge((surfaceM2 / _espacementEntraxe));
      final nbFourrures = (mlFourrure / _longueurBarreFourrureOuMontant).ceilToDouble();
      final nbCornieres = _avecMarge(perimetre / _longueurBarreRailOuCorniere).ceilToDouble();

      lignes.add(QuantiteMateriau(
        nomMateriau: 'Fourrures (barres de ${_longueurBarreFourrureOuMontant.toStringAsFixed(0)} m)',
        quantite: nbFourrures,
        unite: 'barre',
        prixUnitaire: prixUnitaires?['fourrure'],
      ));
      lignes.add(QuantiteMateriau(
        nomMateriau: 'Cornières (barres de ${_longueurBarreRailOuCorniere.toStringAsFixed(0)} m)',
        quantite: nbCornieres,
        unite: 'barre',
        prixUnitaire: prixUnitaires?['corniere'],
      ));
    } else {
      // Cloison : rails en haut et en bas (2 × périmètre), montants tous les 60 cm.
      final mlRails = _avecMarge(perimetre * 2);
      final nbRails = (mlRails / _longueurBarreRailOuCorniere).ceilToDouble();
      final nbMontants = (_avecMarge(perimetre / _espacementEntraxe)).ceilToDouble();

      lignes.add(QuantiteMateriau(
        nomMateriau: 'Rails (barres de ${_longueurBarreRailOuCorniere.toStringAsFixed(0)} m)',
        quantite: nbRails,
        unite: 'barre',
        prixUnitaire: prixUnitaires?['rail'],
      ));
      lignes.add(QuantiteMateriau(
        nomMateriau: 'Montants (barres de ${_longueurBarreFourrureOuMontant.toStringAsFixed(0)} m)',
        quantite: nbMontants,
        unite: 'barre',
        prixUnitaire: prixUnitaires?['montant'],
      ));
    }

    lignes.addAll([
      QuantiteMateriau(nomMateriau: 'Vis placo', quantite: visPlaco.ceilToDouble(), unite: 'unité', prixUnitaire: prixUnitaires?['vis_placo']),
      QuantiteMateriau(nomMateriau: 'Vis autoforeuses', quantite: visAutoforeuses.ceilToDouble(), unite: 'unité', prixUnitaire: prixUnitaires?['vis_autoforeuse']),
      QuantiteMateriau(nomMateriau: 'Bande à joints', quantite: bandeAJoint, unite: 'ml', prixUnitaire: prixUnitaires?['bande_joint']),
      QuantiteMateriau(nomMateriau: 'Enduit de jointoiement', quantite: enduit, unite: 'kg', prixUnitaire: prixUnitaires?['enduit']),
    ]);

    return ResultatCalculMateriaux(systeme: systeme, surfaceM2: surfaceM2, lignes: lignes);
  }

  /// À partir d'une fiche de métrage déjà saisie (Module 5), réutilise la
  /// surface nette et le périmètre déjà calculés — évite une double saisie.
  ResultatCalculMateriaux calculerDepuisFiche(FicheMetrage fiche, {Map<String, double>? prixUnitaires}) {
    if (fiche.pieces.isEmpty) {
      throw const AppException('La fiche de métrage ne contient aucune pièce.');
    }
    return calculer(
      surfaceM2: fiche.surfaceNetteTotale,
      systeme: fiche.systeme,
      perimetreM: fiche.perimetreTotal,
      prixUnitaires: prixUnitaires,
    );
  }

  double _avecMarge(double valeur) => valeur * margePerte;

  /// Estimation grossière du périmètre à partir de la surface, utilisée
  /// UNIQUEMENT si le dirigeant n'a pas de fiche de métrage détaillée
  /// (hypothèse : pièce carrée) — préférer toujours calculerDepuisFiche().
  double _perimetreEstime(double surfaceM2) => 4 * (surfaceM2 > 0 ? surfaceM2 : 0).abs().toDouble().let((s) => _racine(s));

  double _racine(double x) {
    if (x <= 0) return 0;
    double estimation = x / 2;
    for (int i = 0; i < 20; i++) {
      estimation = 0.5 * (estimation + x / estimation);
    }
    return estimation;
  }
}

/// Petit utilitaire d'extension pour garder _perimetreEstime lisible
/// (équivalent d'un `.let {}` façon Kotlin, familier si vous venez d'un
/// contexte Android/Kotlin comme mentionné dans le cahier des charges).
extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
