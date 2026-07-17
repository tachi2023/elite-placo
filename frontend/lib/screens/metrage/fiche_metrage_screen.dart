import 'package:flutter/material.dart';
import '../../models/piece_metrage.dart';

/// Module 5 — fiche de métrage numérique (jusqu'à 30 pièces), export PDF
/// et partage WhatsApp (réutilisation du même mécanisme que le lien de
/// suivi client — voir elite.md §10.14).
class FicheMetrageScreen extends StatefulWidget {
  final int chantierId;
  const FicheMetrageScreen({super.key, required this.chantierId});

  @override
  State<FicheMetrageScreen> createState() => _FicheMetrageScreenState();
}

class _FicheMetrageScreenState extends State<FicheMetrageScreen> {
  final List<PieceMetrage> _pieces = [];

  double get _surfaceNetteTotale =>
      _pieces.fold(0, (total, p) => total + p.surfaceNette);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fiche de métrage')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _pieces.length,
              itemBuilder: (context, i) => ListTile(
                title: Text(_pieces[i].nomPiece),
                trailing: Text('${_pieces[i].surfaceNette.toStringAsFixed(1)} m²'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Surface nette totale : '
                '${_surfaceNetteTotale.toStringAsFixed(1)} m²'),
          ),
          Row(
            children: [
              // TODO : bouton "+ Ajouter une pièce" (limite 30 — §2, Module 5)
              Expanded(
                child: OutlinedButton(
                  onPressed: () { /* TODO : PdfService.genererFicheMetrage */ },
                  child: const Text('Exporter en PDF'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () { /* TODO : WhatsAppShareService.partagerFichier */ },
                  child: const Text('Partager WhatsApp'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
