import 'package:flutter/material.dart';
import '../../models/mouvement_financier.dart';

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

    // TODO Phase 6 : construire un MouvementFinancier et l'enregistrer
    // via ChantierRepository (local d'abord, sync ensuite).
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une dépense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catégorie'),
            Wrap(
              spacing: 8,
              children: CategorieDepense.toutes.map((cat) => ChoiceChip(
                label: Text(cat),
                selected: _categorieChoisie == cat,
                onSelected: (_) => setState(() => _categorieChoisie = cat),
              )).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _montantController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _enregistrer, child: const Text('Enregistrer')),
          ],
        ),
      ),
    );
  }
}

