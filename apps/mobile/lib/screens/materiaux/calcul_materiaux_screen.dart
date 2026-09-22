import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fiche_metrage.dart';
import '../../providers/materiaux_provider.dart';

/// §10.5 — saisie surface + système, affichage des quantités calculées
/// (+15% de marge de perte déjà appliquée par MateriauxService).
class CalculMateriauxScreen extends StatefulWidget {
  const CalculMateriauxScreen({super.key});

  @override
  State<CalculMateriauxScreen> createState() => _CalculMateriauxScreenState();
}

class _CalculMateriauxScreenState extends State<CalculMateriauxScreen> {
  final _surfaceController = TextEditingController();
  String _systeme = SystemePlatrerie.railsMontantsBa13;

  void _calculer() {
    final surface = double.tryParse(_surfaceController.text.replaceAll(',', '.'));
    if (surface == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Surface invalide.')),
      );
      return;
    }
    context.read<MateriauxProvider>().calculer(surfaceM2: surface, systeme: _systeme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculer les matériaux')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _surfaceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Surface (m²)'),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: SystemePlatrerie.railsMontantsBa13, label: Text('Rails + Montants')),
                ButtonSegment(value: SystemePlatrerie.corniereFourrureBa13, label: Text('Cornière + Fourrure')),
              ],
              selected: {_systeme},
              onSelectionChanged: (s) => setState(() => _systeme = s.first),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _calculer, child: const Text('Calculer')),
            const SizedBox(height: 20),
            Consumer<MateriauxProvider>(
              builder: (context, provider, _) {
                if (provider.derniereErreur != null) {
                  return Text(provider.derniereErreur!, style: const TextStyle(color: Colors.red));
                }
                final resultat = provider.resultat;
                if (resultat == null) return const SizedBox.shrink();

                return Expanded(
                  child: ListView(
                    children: [
                      if (resultat.budgetIncomplet)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Budget incomplet : renseignez les prix unitaires pour un total exact.',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ...resultat.lignes.map((l) => ListTile(
                        title: Text(l.nomMateriau),
                        trailing: Text('${l.quantite.toStringAsFixed(1)} ${l.unite}'),
                      )),
                      if (!resultat.budgetIncomplet)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Budget total estimé : ${resultat.budgetTotal!.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
