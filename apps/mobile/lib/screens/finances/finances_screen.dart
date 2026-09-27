import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';

/// Vue mobile des finances inspirée de l'écran Finances du prototype.
/// Les montants viennent de la même vue locale que le tableau de bord afin de
/// rester disponibles hors connexion.
class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  final _format = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DashboardProvider>().charger();
    });
  }

  String _money(double value) => _format.format(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () => context.read<DashboardProvider>().charger(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajoutez une dépense depuis le détail d’un chantier.')),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Dépense'),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          final vue = provider.vueGlobale;
          if (provider.enChargement && vue == null) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.or));
          }
          if (vue == null) {
            return const Center(child: Text('Aucune donnée financière.'));
          }

          return RefreshIndicator(
            color: AppTheme.or,
            backgroundColor: AppTheme.anthraciteClair,
            onRefresh: provider.charger,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              physics: const BouncingScrollPhysics(),
              children: [
                if (vue.donneesPartiellementNonSynchronisees) _offlineNotice(),
                _sectionTitle('Vue financière', 'Une synthèse claire de vos encaissements et dépenses.'),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 600 ? 4 : 2;
                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: columns == 4 ? 1.3 : 1.35,
                      children: [
                        _metric('Revenus', _money(vue.totalEncaisseGlobal), Icons.arrow_upward_rounded, AppTheme.succes),
                        _metric('Dépenses', _money(vue.totalDepensesGlobal), Icons.arrow_downward_rounded, AppTheme.erreur),
                        _metric('Résultat net', _money(vue.resultatNetGlobal), Icons.insights_rounded, AppTheme.or),
                        _metric('Marge', '${vue.margeGlobalePourcent.toStringAsFixed(1)} %', Icons.donut_large_rounded, AppTheme.or),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                _sectionTitle('Situation par chantier', '${vue.resumesChantiers.length} projet(s) suivi(s).'),
                const SizedBox(height: 12),
                ...vue.resumesChantiers.map(_projectCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _offlineNotice() => Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.or.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.or.withValues(alpha: 0.28)),
        ),
        child: const Row(children: [
          Icon(Icons.cloud_off_rounded, color: AppTheme.or, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text('Hors connexion : les écritures locales seront synchronisées au retour du réseau.')),
        ]),
      );

  Widget _sectionTitle(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.blanc)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.grisFonce)),
        ],
      );

  Widget _metric(String label, String value, IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.anthraciteClair,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: color),
          const Spacer(),
          Text(label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppTheme.grisFonce, letterSpacing: 0.7)),
          const SizedBox(height: 5),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ]),
      );

  Widget _projectCard(dynamic resume) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.anthraciteClair,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: resume.situation.indicateur == 'VERT' ? AppTheme.vert : AppTheme.orange)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(resume.chantier.nomClient, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text('${resume.chantier.ville ?? 'Ville non précisée'} · ${resume.chantier.typeTravaux ?? 'Travaux'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppTheme.grisFonce)),
          ])),
          Text('${resume.situation.margeBrutePourcent.toStringAsFixed(1)} %', style: TextStyle(fontWeight: FontWeight.w700, color: resume.situation.margeBrutePourcent >= 0 ? AppTheme.succes : AppTheme.erreur)),
        ]),
      );
}
