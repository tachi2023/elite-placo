import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chantier_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';
import 'fiche_metrage_screen.dart';

/// Point d'entrée mobile des métrés : le prototype affiche le module comme
/// une destination globale, alors que l'API rattache chaque fiche à un chantier.
class SelectionMetrageScreen extends StatefulWidget {
  const SelectionMetrageScreen({super.key});

  @override
  State<SelectionMetrageScreen> createState() => _SelectionMetrageScreenState();
}

class _SelectionMetrageScreenState extends State<SelectionMetrageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ChantierProvider>().chargerChantiers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Métrés')),
      body: Consumer<ChantierProvider>(
        builder: (context, provider, _) {
          if (provider.enChargement) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.or),
            );
          }
          if (provider.chantiers.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Créez un chantier pour commencer une fiche de métrage.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.grisClair),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ResponsiveContent(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSectionTitle(
                  title: 'Choisir un chantier',
                  subtitle: 'Chaque fiche de métrage reste liée à son projet.',
                ),
                const SizedBox(height: 16),
                ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.chantiers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final chantier = provider.chantiers[index];
                      return AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FicheMetrageScreen(chantierId: chantier.id!),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Color(0x24C9A84C),
                            child: Icon(Icons.straighten_rounded, color: AppTheme.or),
                          ),
                          title: Text(chantier.nomClient, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(chantier.ville ?? 'Ville non précisée'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}
