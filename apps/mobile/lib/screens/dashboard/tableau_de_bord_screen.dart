import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/indicateur_pastille.dart';
import '../chantiers/nouveau_chantier_screen.dart';
import '../settings/gestion_site_screen.dart';
import '../../theme/app_theme.dart';
import '../../models/chantier.dart';
import '../../providers/auth_provider.dart';
import '../chantiers/chantiers_list_screen.dart';
import '../materiaux/calcul_materiaux_screen.dart';
import '../finances/finances_screen.dart';
import '../ouvriers/ouvriers_screen.dart';

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
        leading: IconButton(
          tooltip: 'Ouvrir le menu',
          icon: const Icon(Icons.menu_rounded, color: AppTheme.or),
          onPressed: _ouvrirMenu,
        ),
        title: const Text('Tableau de bord',
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
      bottomNavigationBar: _buildBottomNavigation(),
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
              Color(0xFF1E1E24),
              AppTheme.anthracite,
              Color(0xFF0F0F12),
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
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (vue.donneesPartiellementNonSynchronisees)
                      Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.or.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.or.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off_rounded,
                                color: AppTheme.or, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Mode hors-ligne : données en attente de synchronisation.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppTheme.or),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonjour, Raoul',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(fontSize: 28),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Voici le statut général de vos chantiers et finances.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppTheme.grisClair),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.or.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppTheme.or.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: const Text(
                                  'PRIMA BTP · ÉLITE PLACO',
                                  style: TextStyle(
                                    color: AppTheme.or,
                                    fontSize: 10,
                                    letterSpacing: 1.8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.or.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.or.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(Icons.notifications_none_rounded,
                              color: AppTheme.or),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 720 ? 4 : 2;
                        return GridView.count(
                          crossAxisCount: columns,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: columns == 4 ? 1.28 : 1.42,
                          children: [
                            _buildKpiCard(
                                'Chiffre d\'affaires',
                                _fmt(vue.chiffreAffairesTotal),
                                Icons.account_balance_wallet_rounded),
                            _buildKpiCard(
                                'Résultat net',
                                _fmt(vue.resultatNetGlobal),
                                Icons.insights_rounded,
                                isHighlight: true),
                            _buildKpiCard(
                                'Total encaissé',
                                _fmt(vue.totalEncaisseGlobal),
                                Icons.arrow_downward_rounded,
                                color: AppTheme.succes),
                            _buildKpiCard(
                                'Total dépenses',
                                _fmt(vue.totalDepensesGlobal),
                                Icons.arrow_upward_rounded,
                                color: AppTheme.erreur),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _buildKpiCard(
                        'Marge globale',
                        '${vue.margeGlobalePourcent.toStringAsFixed(1)}%',
                        Icons.pie_chart_outline_rounded,
                        fullWidth: true,
                        isHighlight: true),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Projets récents',
                            style: Theme.of(context).textTheme.titleLarge),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ChantiersListScreen())),
                          child: const Text('Voir tout'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...vue.resumesChantiers.map((resume) => Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            leading: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.or.withValues(alpha: 0.45)),
                              ),
                              child: IndicateurPastille(
                                  indicateur: resume.situation.indicateur),
                            ),
                            title: Text(
                              resume.chantier.nomClient,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
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
                                  Expanded(
                                    child: Text(
                                      resume.chantier.ville ?? 'N/A',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: AppTheme.grisClair),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.or.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      StatutChantier.libelle(
                                          resume.chantier.statut),
                                      style: const TextStyle(
                                          color: AppTheme.or,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700),
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
                                    fontWeight: FontWeight.w700,
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

  Widget _buildBottomNavigation() {
    return NavigationBar(
      selectedIndex: 0,
      backgroundColor: AppTheme.anthraciteClair,
      indicatorColor: AppTheme.or.withValues(alpha: 0.18),
      onDestinationSelected: (index) {
        if (index == 0) return;
        if (index == 1) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChantiersListScreen()));
        } else if (index == 2) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const FinancesScreen()));
        } else if (index == 3) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CalculMateriauxScreen()));
        } else {
          _ouvrirMenu();
        }
      },
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Accueil'),
        NavigationDestination(
            icon: Icon(Icons.folder_copy_outlined),
            selectedIcon: Icon(Icons.folder_copy),
            label: 'Projets'),
        NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Finances'),
        NavigationDestination(
            icon: Icon(Icons.straighten_outlined),
            selectedIcon: Icon(Icons.straighten),
            label: 'Métrés'),
        NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.menu),
            label: 'Plus'),
      ],
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

  void _ouvrirMenu() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.anthraciteClair,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Élite Placo & Déco',
                      style: TextStyle(
                          color: AppTheme.or,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                _menuItem(sheetContext, Icons.dashboard_rounded,
                    'Tableau de bord', null),
                _menuItem(sheetContext, Icons.business_rounded, 'Mes chantiers',
                    () => const ChantiersListScreen()),
                _menuItem(sheetContext, Icons.calculate_rounded,
                    'Calcul matériaux', () => const CalculMateriauxScreen()),
                _menuItem(sheetContext, Icons.payments_rounded, 'Finances',
                    () => const FinancesScreen()),
                _menuItem(sheetContext, Icons.engineering_rounded, 'Ouvriers',
                    () => const OuvriersScreen()),
                _menuItem(sheetContext, Icons.settings_rounded,
                    'Paramètres du site', () => const GestionSiteScreen()),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded,
                      color: AppTheme.grisClair),
                  title: const Text('Verrouiller l’application'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<AuthProvider>().verrouiller();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem(BuildContext sheetContext, IconData icon, String label,
      Widget Function()? page) {
    final destination = page;
    return ListTile(
      leading: Icon(icon, color: AppTheme.or),
      title: Text(label),
      trailing: destination == null
          ? const Icon(Icons.check, color: AppTheme.or, size: 18)
          : const Icon(Icons.chevron_right),
      onTap: destination == null
          ? () => Navigator.pop(sheetContext)
          : () {
              Navigator.pop(sheetContext);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => destination()));
            },
    );
  }
}
