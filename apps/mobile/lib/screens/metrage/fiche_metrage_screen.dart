import 'package:flutter/material.dart';

import '../../models/fiche_metrage.dart';
import '../../services/pdf_service.dart';
import '../../services/whatsapp_share_service.dart';
import '../../widgets/app_ui.dart';

/// Module 5 — fiche de métrage numérique (jusqu'à 30 pièces), export PDF
/// et partage WhatsApp.
class FicheMetrageScreen extends StatefulWidget {
  final int chantierId;
  const FicheMetrageScreen({super.key, required this.chantierId});

  @override
  State<FicheMetrageScreen> createState() => _FicheMetrageScreenState();
}

class _FicheMetrageScreenState extends State<FicheMetrageScreen> {
  final List<PieceMetrage> _pieces = [];
  final PdfService _pdfService = PdfService();
  final WhatsAppShareService _shareService = WhatsAppShareService();
  bool _isProcessing = false;
  String _systeme = SystemePlatrerie.corniereFourrureBa13;

  double get _surfaceNetteTotale =>
      _pieces.fold(0, (total, p) => total + p.surfaceNette);

  Future<void> _ajouterPiece() async {
    if (_pieces.length >= 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une fiche est limitée à 30 pièces.')),
      );
      return;
    }

    final nomController = TextEditingController();
    final longueurController = TextEditingController();
    final largeurController = TextEditingController();
    final deductionController = TextEditingController(text: '0');

    final piece = await showDialog<PieceMetrage>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ajouter une pièce'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom de la pièce'),
                ),
                TextField(
                  controller: longueurController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Longueur (m)'),
                ),
                TextField(
                  controller: largeurController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Largeur (m)'),
                ),
                TextField(
                  controller: deductionController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Déduction (m²)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final nom = nomController.text.trim();
                final longueur = double.tryParse(longueurController.text.replaceAll(',', '.'));
                final largeur = double.tryParse(largeurController.text.replaceAll(',', '.'));
                final deduction = double.tryParse(deductionController.text.replaceAll(',', '.')) ?? 0;

                if (nom.isEmpty || longueur == null || longueur <= 0 || largeur == null || largeur <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nom, longueur et largeur sont obligatoires.')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(
                  PieceMetrage(
                    nomPiece: nom,
                    longueur: longueur,
                    largeur: largeur,
                    surfaceDeduction: deduction < 0 ? 0 : deduction,
                  ),
                );
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    nomController.dispose();
    longueurController.dispose();
    largeurController.dispose();
    deductionController.dispose();

    if (!mounted || piece == null) return;
    setState(() => _pieces.add(piece));
  }

  Future<void> _exporterPdf() async {
    if (_pieces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins une pièce avant d’exporter.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final bytes = await _pdfService.genererFicheMetrage(
        chantierId: widget.chantierId,
        systeme: _systeme,
        pieces: _pieces,
      );
      await _shareService.partagerPdfBytes(
        bytes,
        filename: 'fiche_metrage_chantier_${widget.chantierId}.pdf',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF prêt à partager.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de l’export PDF : $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _partagerWhatsApp() async {
    if (_pieces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins une pièce avant de partager.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final bytes = await _pdfService.genererFicheMetrage(
        chantierId: widget.chantierId,
        systeme: _systeme,
        pieces: _pieces,
      );
      await _shareService.partagerPdfBytes(
        bytes,
        filename: 'fiche_metrage_chantier_${widget.chantierId}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de partager : $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiche de métrage'),
        actions: [
          IconButton(
            onPressed: _ajouterPiece,
            tooltip: 'Ajouter une pièce',
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: ResponsiveContent(
            maxWidth: 900,
            child: Column(
              children: [
                AppCard(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: DropdownButtonFormField<String>(
                    value: _systeme,
                    decoration: const InputDecoration(labelText: 'Système'),
                    items: const [
                      DropdownMenuItem(
                        value: SystemePlatrerie.corniereFourrureBa13,
                        child: Text('Cornière + Fourrure + BA13'),
                      ),
                      DropdownMenuItem(
                        value: SystemePlatrerie.railsMontantsBa13,
                        child: Text('Rails + Montants + BA13'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _systeme = value);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: _pieces.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.layers_outlined, size: 56),
                                  const SizedBox(height: 12),
                                  const Text('Aucune pièce encore ajoutée.'),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _ajouterPiece,
                                    child: const Text('Ajouter la première pièce'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _pieces.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final piece = _pieces[i];
                              return ListTile(
                                title: Text(piece.nomPiece),
                                subtitle: Text(
                                  'Brute ${piece.surfaceBrute.toStringAsFixed(1)} m² • '
                                  'Déduction ${piece.surfaceDeduction.toStringAsFixed(1)} m²',
                                ),
                                trailing: Text('${piece.surfaceNette.toStringAsFixed(1)} m²'),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Surface nette totale : ${_surfaceNetteTotale.toStringAsFixed(1)} m²',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final buttons = [
                            OutlinedButton.icon(
                              onPressed: _isProcessing ? null : _exporterPdf,
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Exporter en PDF'),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isProcessing ? null : _partagerWhatsApp,
                              icon: const Icon(Icons.send),
                              label: const Text('Partager WhatsApp'),
                            ),
                          ];
                          if (constraints.maxWidth < 520) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [buttons[0], buttons[1]],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: buttons[0]),
                              const SizedBox(width: 12),
                              Expanded(child: buttons[1]),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _ajouterPiece,
        icon: const Icon(Icons.add),
        label: const Text('Pièce'),
      ),
    );
  }
}
