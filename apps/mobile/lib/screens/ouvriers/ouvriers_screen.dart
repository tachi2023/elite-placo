import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ouvrier_provider.dart';

/// §10.8 — liste des ouvriers connus + création + paiement rapide sur un
/// chantier donné (le chantier est présélectionné, comme prévu au scénario).
class OuvriersScreen extends StatefulWidget {
  final int chantierId;
  const OuvriersScreen({super.key, required this.chantierId});

  @override
  State<OuvriersScreen> createState() => _OuvriersScreenState();
}

class _OuvriersScreenState extends State<OuvriersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OuvrierProvider>().charger();
  }

  void _ajouterOuvrier() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvel ouvrier'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Nom complet')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              final ok = await context.read<OuvrierProvider>().creerOuvrier(controller.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.read<OuvrierProvider>().derniereErreur ?? 'Erreur.')),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _enregistrerPaiement(int ouvrierId) {
    final montantController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enregistrer un paiement'),
        content: TextField(
          controller: montantController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              final montant = double.tryParse(montantController.text.replaceAll(' ', '')) ?? -1;
              final ok = await context.read<OuvrierProvider>().enregistrerPaiement(
                    ouvrierId: ouvrierId,
                    chantierId: widget.chantierId,
                    montant: montant,
                    date: DateTime.now(),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.read<OuvrierProvider>().derniereErreur ?? 'Erreur.')),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ouvriers')),
      floatingActionButton: FloatingActionButton(onPressed: _ajouterOuvrier, child: const Icon(Icons.person_add)),
      body: Consumer<OuvrierProvider>(
        builder: (context, provider, _) {
          if (provider.ouvriers.isEmpty) {
            return const Center(child: Text('Aucun ouvrier enregistré pour le moment.'));
          }
          return ListView.builder(
            itemCount: provider.ouvriers.length,
            itemBuilder: (context, i) {
              final o = provider.ouvriers[i];
              return ListTile(
                title: Text(o.nomComplet),
                subtitle: Text(o.telephone ?? ''),
                trailing: TextButton(
                  onPressed: () => _enregistrerPaiement(o.id!),
                  child: const Text('Payer'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
