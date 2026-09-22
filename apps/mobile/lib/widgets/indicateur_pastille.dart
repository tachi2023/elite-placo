import 'package:flutter/material.dart';

/// Pastille vert/orange/rouge réutilisée partout où un chantier est listé
/// (accueil mobile, tableau de bord web) — logique de couleur centralisée
/// côté backend dans ChantierService, ce widget ne fait qu'afficher.
class IndicateurPastille extends StatelessWidget {
  final String indicateur; // 'VERT' | 'ORANGE' | 'ROUGE'
  const IndicateurPastille({super.key, required this.indicateur});

  Color get _couleur => switch (indicateur) {
        'VERT' => const Color(0xFF4CAF7D),
        'ORANGE' => const Color(0xFFE0B84C),
        'ROUGE' => const Color(0xFFE05555),
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(color: _couleur, shape: BoxShape.circle),
    );
  }
}
