import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mouvement_financier.dart';
import '../../providers/chantier_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';

/// Formulaire d'ajout de dépense (scénario type §10.12). Écrit toujours
/// en local d'abord — aucune perte de donnée tolérée même sans réseau.
class AjouterDepenseScreen extends StatefulWidget {
  final int chantierId;
  const AjouterDepenseScreen({super.key, required this.chantierId});

  @override
  State<AjouterDepenseScreen> createState() => _AjouterDepenseScreenState();
}

class _AjouterDepenseScreenState extends State<AjouterDepenseScreen> {
  String? _categorieChoisie;
  final _montantController = TextEditingController();

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  void _enregistrer() {
    // A1 (§10.13) — montant invalide : refuser et signaler le champ,
    // ne jamais planter silencieusement.
    final montant = double.tryParse(_montantController.text.replaceAll(' ', ''));
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide.')),
      );
      return;
    }
    if (_categorieChoisie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez une catégorie.')),
      );
      return;
    }

    final provider = context.read<ChantierProvider>();
    provider
        .ajouterDepense(
          chantierId: widget.chantierId,
          montant: montant,
          date: DateTime.now(),
          categorie: _categorieChoisie!,
        )
        .then((_) {
          if (!mounted) return;
          Navigator.of(context).pop();
        })
        .catchError((error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une dépense')),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ResponsiveContent(
              maxWidth: 680,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppSectionTitle(title: 'Catégorie', icon: Icons.category_outlined),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CategorieDepense.toutes.map((cat) => ChoiceChip(
                        label: Text(cat),
                        selected: _categorieChoisie == cat,
                        selectedColor: AppTheme.or.withValues(alpha: 0.25),
                        onSelected: (_) => setState(() => _categorieChoisie = cat),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _montantController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Montant (FCFA)', prefixIcon: Icon(Icons.payments_outlined)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(onPressed: _enregistrer, icon: const Icon(Icons.save_outlined), label: const Text('Enregistrer')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
