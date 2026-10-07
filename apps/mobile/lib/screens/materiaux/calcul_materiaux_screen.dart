import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fiche_metrage.dart';
import '../../providers/materiaux_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';

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

  @override
  void dispose() {
    _surfaceController.dispose();
    super.dispose();
  }

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
      body: ResponsiveContent(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              accent: AppTheme.or,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionTitle(
                    title: 'Préparer votre commande',
                    subtitle: 'Renseignez la surface, puis choisissez le système de pose.',
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _surfaceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Surface totale (m²)', prefixIcon: Icon(Icons.square_foot_rounded)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _systeme,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Système de plâtrerie'),
                    items: const [
                      DropdownMenuItem(value: SystemePlatrerie.railsMontantsBa13, child: Text('Rails + montants + BA13')),
                      DropdownMenuItem(value: SystemePlatrerie.corniereFourrureBa13, child: Text('Cornière + fourrure + BA13')),
                    ],
                    onChanged: (value) { if (value != null) setState(() => _systeme = value); },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(onPressed: _calculer, icon: const Icon(Icons.calculate_rounded), label: const Text('Calculer les quantités')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Consumer<MateriauxProvider>(
              builder: (context, provider, _) {
                if (provider.derniereErreur != null) {
                  return Text(provider.derniereErreur!, style: const TextStyle(color: Colors.red));
                }
                final resultat = provider.resultat;
                if (resultat == null) return const SizedBox.shrink();

                return AppCard(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 430),
                      child: ListView(
                      children: [
                        const AppSectionTitle(title: 'Quantités estimées', subtitle: 'Marge de perte incluse selon le système choisi.'),
                        const SizedBox(height: 12),
                        if (resultat.budgetIncomplet)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Budget incomplet : renseignez les prix unitaires pour un total exact.',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ...resultat.lignes.map((l) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.inventory_2_outlined, color: AppTheme.or),
                          title: Text(l.nomMateriau),
                          trailing: Text('${l.quantite.toStringAsFixed(1)} ${l.unite}'),
                        )),
                        if (!resultat.budgetIncomplet)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Budget total estimé : ${resultat.budgetTotal!.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.or),
                            ),
                          ),
                      ],
                      ),
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
