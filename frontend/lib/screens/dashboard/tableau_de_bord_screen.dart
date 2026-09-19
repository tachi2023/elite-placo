import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/indicateur_pastille.dart';
import '../chantiers/nouveau_chantier_screen.dart';
import '../settings/gestion_site_screen.dart';
import '../../theme/app_theme.dart';
import '../../models/chantier.dart';

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
    final formatter = NumberFormat.currency(
        locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);
    return formatter.format(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Tableau de Bord',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.or),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GestionSiteScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.or),
            onPressed: () => context.read<DashboardProvider>().charger(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.or,
        foregroundColor: AppTheme.anthracite,
        elevation: 8,
        onPressed: () async {
          final provider = context.read<DashboardProvider>();
          await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NouveauChantierScreen()));
          if (!context.mounted) return;
          provider.charger();
        },
        icon: const Icon(Icons.add),
        label: const Text('NOUVEAU PROJET',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E24), // Anthracite légèrement plus clair
              AppTheme.anthracite, // Anthracite profond
              Color(0xFF0F0F12), // Presque noir
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Consumer<DashboardProvider>(
            builder: (context, provider, _) {
              if (provider.enChargement) {
                return const Center(
                    child: CircularProgressIndicator(color: AppTheme.or));
              }
              final vue = provider.vueGlobale;
              if (vue == null || vue.resumesChantiers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.architecture_rounded,
                          size: 80, color: AppTheme.or.withValues(alpha: 0.3)),
                      const SizedBox(height: 24),
                      Text(
                        'Aucun projet en cours',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(color: AppTheme.blanc),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Créez votre premier chantier pour commencer.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppTheme.grisFonce),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppTheme.or,
                backgroundColor: AppTheme.anthracite,
                onRefresh: () => provider.charger(),
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (vue.donneesPartiellementNonSynchronisees)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.or.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.or.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off_rounded,
                                color: AppTheme.or, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Mode hors-ligne : Données en attente de synchronisation.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppTheme.or),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Text('Aperçu Financier',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),

                    // KPIs en grille
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 720 ? 4 : 2;
                        return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: columns == 4 ? 1.25 : 1.45,
                      children: [
                        _buildKpiCard(
                            'Chiffre d\'Affaires',
                            _fmt(vue.chiffreAffairesTotal),
                            Icons.account_balance),
                        _buildKpiCard('Résultat Net',
                            _fmt(vue.resultatNetGlobal), Icons.insights,
                            isHighlight: true),
                        _buildKpiCard(
                            'Total Encaissé',
                            _fmt(vue.totalEncaisseGlobal),
                            Icons.arrow_circle_down,
                            color: AppTheme.succes),
                        _buildKpiCard(
                            'Total Dépenses',
                            _fmt(vue.totalDepensesGlobal),
                            Icons.arrow_circle_up,
                            color: AppTheme.erreur),
                      ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    _buildKpiCard(
                        'Marge Globale',
                        '${vue.margeGlobalePourcent.toStringAsFixed(1)}%',
                        Icons.donut_large,
                        fullWidth: true,
                        isHighlight: true),

                    const SizedBox(height: 40),
                    Text('Projets Récents',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),

                    ...vue.resumesChantiers.map((resume) => Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            leading: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.or.withValues(alpha: 0.5)),
                              ),
                              child: IndicateurPastille(
                                  indicateur: resume.situation.indicateur),
                            ),
                            title: Text(
                              resume.chantier.nomClient,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.blanc),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 14,
                                      color:
                                          AppTheme.or.withValues(alpha: 0.8)),
                                  const SizedBox(width: 4),
                                  Text(resume.chantier.ville ?? 'N/A',
                                      style: const TextStyle(
                                          color: AppTheme.grisClair)),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.or.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      StatutChantier.libelle(
                                          resume.chantier.statut),
                                      style: const TextStyle(
                                          color: AppTheme.or,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Marge',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.grisFonce,
                                      letterSpacing: 1),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${resume.situation.margeBrutePourcent.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        resume.situation.margeBrutePourcent < 0
                                            ? AppTheme.erreur
                                            : AppTheme.succes,
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
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String valeur, IconData icon,
      {bool fullWidth = false, bool isHighlight = false, Color? color}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppTheme.or.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlight
              ? AppTheme.or.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: color ??
                      (isHighlight ? AppTheme.or : AppTheme.grisClair)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isHighlight ? AppTheme.or : AppTheme.grisFonce,
                      letterSpacing: 0.5),
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
                  color: color ?? (isHighlight ? AppTheme.or : AppTheme.blanc),
                  fontSize: fullWidth ? 28 : 20,
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
