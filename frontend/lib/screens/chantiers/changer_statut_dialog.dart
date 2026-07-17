import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chantier.dart';
import '../../providers/chantier_provider.dart';
import '../../theme/app_theme.dart';

class ChangerStatutDialog extends StatelessWidget {
  final Chantier chantier;
  
  const ChangerStatutDialog({super.key, required this.chantier});

  @override
  Widget build(BuildContext context) {
    final transitions = StatutChantier.transitionsValides[chantier.statut] ?? [];

    return AlertDialog(
      backgroundColor: AppTheme.anthraciteClair,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.or.withOpacity(0.3)),
      ),
      title: const Text('Changer le statut', style: TextStyle(color: AppTheme.or, fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
      content: transitions.isEmpty
          ? const Text('Aucune transition disponible depuis ce statut.', style: TextStyle(color: Colors.white))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: transitions.map((statut) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppTheme.anthracite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: ListTile(
                  title: Text(
                    StatutChantier.libelle(statut),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.or),
                  onTap: () async {
                    final provider = context.read<ChantierProvider>();
                    final ok = await provider.changerStatut(chantier.id!, statut);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.derniereErreur ?? 'Erreur inconnue.'),
                          backgroundColor: AppTheme.rouge,
                        ),
                      );
                    }
                  },
                ),
              )).toList(),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
