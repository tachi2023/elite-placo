import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/indicateur_pastille.dart';
import '../chantiers/nouveau_chantier_screen.dart';
import '../../theme/app_theme.dart';

class TableauDeBordScreen extends StatefulWidget {
  const TableauDeBordScreen({super.key});

  @override
  State<TableauDeBordScreen> createState() => _TableauDeBordScreenState();
}

class _TableauDeBordScreenState extends State<TableauDeBordScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardProvider>().charger();
      }
    });
  }

  String _fmt(double v) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
    return formatter.format(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.anthracite,
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardProvider>().charger(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.or,
        foregroundColor: AppTheme.anthracite,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau projet', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NouveauChantierScreen()));
          if (mounted) context.read<DashboardProvider>().charger();
        },
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.enChargement) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.or));
          }
          final vue = provider.vueGlobale;
          if (vue == null || vue.resumesChantiers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.architecture_rounded, size: 80, color: AppTheme.grisFonce.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun projet en cours.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.grisFonce),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre premier chantier pour commencer.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.or,
            backgroundColor: AppTheme.anthraciteClair,
            onRefresh: () => provider.charger(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (vue.donneesPartiellementNonSynchronisees)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.or.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.or.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_sync_rounded, color: AppTheme.or, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Synchronisation en attente (Mode hors-ligne actif)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.or),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                Text('Aperçu Financier', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                
                // KPIs en grille
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildKpiCard('Chiffre d\'Affaires', _fmt(vue.chiffreAffairesTotal), Icons.monetization_on_outlined),
                    _buildKpiCard('Résultat Net', _fmt(vue.resultatNetGlobal), Icons.account_balance_wallet_outlined, isHighlight: true),
                    _buildKpiCard('Total Encaissé', _fmt(vue.totalEncaisseGlobal), Icons.arrow_downward_rounded, color: AppTheme.succes),
                    _buildKpiCard('Total Dépenses', _fmt(vue.totalDepensesGlobal), Icons.arrow_upward_rounded, color: AppTheme.erreur),
                  ],
                ),
                
                const SizedBox(height: 16),
                _buildKpiCard(
                  'Marge Globale', 
                  '${vue.margeGlobalePourcent.toStringAsFixed(1)}%', 
                  Icons.pie_chart_outline,
                  fullWidth: true
                ),

                const SizedBox(height: 32),
                Text('Projets Récents', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                
                ...vue.resumesChantiers.map((resume) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.grisFonce),
                      ),
                      child: IndicateurPastille(indicateur: resume.situation.indicateur),
                    ),
                    title: Text(
                      resume.chantier.nomClient,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: AppTheme.grisFonce),
                          const SizedBox(width: 4),
                          Text('${resume.chantier.ville ?? 'N/A'}'),
                          const SizedBox(width: 8),
                          Text('• ${resume.chantier.statut}'),
                        ],
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Marge',
                          style: TextStyle(fontSize: 10, color: AppTheme.grisFonce),
                        ),
                        Text(
                          '${resume.situation.margeBrutePourcent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: resume.situation.margeBrutePourcent < 0 ? AppTheme.erreur : AppTheme.succes,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard(String label, String valeur, IconData icon, {bool fullWidth = false, bool isHighlight = false, Color? color}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? AppTheme.or.withOpacity(0.1) : AppTheme.anthraciteClair,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? AppTheme.or.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color ?? (isHighlight ? AppTheme.or : AppTheme.grisFonce)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, color: isHighlight ? AppTheme.or : AppTheme.grisFonce),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            valeur,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color ?? AppTheme.blanc,
              fontSize: fullWidth ? 24 : 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
