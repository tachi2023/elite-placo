import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chantier_provider.dart';
import '../../theme/app_theme.dart';
import 'chantier_detail_screen.dart';

class ChantiersListScreen extends StatefulWidget {
  const ChantiersListScreen({super.key});

  @override
  State<ChantiersListScreen> createState() => _ChantiersListScreenState();
}

class _ChantiersListScreenState extends State<ChantiersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChantierProvider>().chargerChantiers();
    });
  }

  Color _getCouleurIndicateur(String? indicateur) {
    switch (indicateur) {
      case 'VERT': return AppTheme.vert;
      case 'ORANGE': return AppTheme.orange;
      case 'ROUGE': return AppTheme.rouge;
      default: return Colors.grey;
    }
  }

  Color _getCouleurStatut(String statut) {
    if (statut == 'A_VENIR' || statut == 'EN_COURS') return AppTheme.vert;
    if (statut == 'EN_PAUSE') return Colors.grey;
    return AppTheme.or; // TERMINE / ARCHIVE
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Chantiers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ChantierProvider>().chargerChantiers(),
          )
        ],
      ),
      body: Consumer<ChantierProvider>(
        builder: (context, provider, _) {
          if (provider.enChargement) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.or));
          }
          if (provider.chantiers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.architecture, size: 64, color: AppTheme.or),
                  const SizedBox(height: 16),
                  const Text('Aucun chantier.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Créez votre premier chantier pour commencer.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.chantiers.length,
            itemBuilder: (context, index) {
              final c = provider.chantiers[index];
              final situation = provider.situationDe(c.id ?? 0);
              final String indicateur = situation?.indicateur ?? 'GRIS';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChantierDetailScreen(chantierId: c.id!)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                c.nomClient,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getCouleurIndicateur(indicateur),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getCouleurIndicateur(indicateur).withOpacity(0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(c.ville ?? 'Ville non précisée', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getCouleurStatut(c.statut).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                c.statut.replaceAll('_', ' '),
                                style: TextStyle(
                                  color: _getCouleurStatut(c.statut),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/nouveau_chantier'),
        backgroundColor: AppTheme.or,
        child: const Icon(Icons.add, color: AppTheme.anthracite),
      ),
    );
  }
}
