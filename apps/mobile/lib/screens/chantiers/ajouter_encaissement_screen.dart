import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chantier.dart';
import '../../models/mouvement_financier.dart';
import '../../providers/chantier_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';

/// §10.3 — formulaire d'ajout d'encaissement. A3 : le dépassement du reste
/// à encaisser affiche un avertissement mais n'empêche pas la validation.
class AjouterEncaissementScreen extends StatefulWidget {
  final Chantier chantier;
  const AjouterEncaissementScreen({super.key, required this.chantier});

  @override
  State<AjouterEncaissementScreen> createState() => _AjouterEncaissementScreenState();
}

class _AjouterEncaissementScreenState extends State<AjouterEncaissementScreen> {
  final _montantController = TextEditingController();
  String _nature = NatureEncaissement.acompte;

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final montant = double.tryParse(_montantController.text.replaceAll(' ', ''));
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Montant invalide.')));
      return;
    }

    final provider = context.read<ChantierProvider>();
    try {
      final resultat = await provider.ajouterEncaissement(
        chantierId: widget.chantier.id!,
        montant: montant,
        date: DateTime.now(),
        nature: _nature,
      );
      if (!mounted) return;
      if (resultat.avertissement != null && resultat.avertissement!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultat.avertissement!)),
        );
      }
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'enregistrer l\'encaissement.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Encaissement — ${widget.chantier.nomClient}')),
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
                    const AppSectionTitle(title: 'Nature', icon: Icons.account_balance_wallet_outlined),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: NatureEncaissement.toutes.map((n) => ChoiceChip(
                        label: Text(NatureEncaissement.libelle(n)),
                        selected: _nature == n,
                        selectedColor: AppTheme.or.withValues(alpha: 0.25),
                        onSelected: (_) => setState(() => _nature = n),
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
