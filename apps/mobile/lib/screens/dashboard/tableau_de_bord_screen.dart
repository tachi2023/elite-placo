import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/indicateur_pastille.dart';
import '../chantiers/nouveau_chantier_screen.dart';
import '../settings/gestion_site_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';
import '../../models/chantier.dart';
import '../../providers/auth_provider.dart';
import '../chantiers/chantiers_list_screen.dart';
import '../materiaux/calcul_materiaux_screen.dart';
import '../finances/finances_screen.dart';
import '../ouvriers/ouvriers_screen.dart';
import '../devis/demandes_devis_screen.dart';
import '../settings/changer_mot_de_passe_screen.dart';
import '../metrage/selection_metrage_screen.dart';
import '../../widgets/brand_logo.dart';

class TableauDeBordScreen extends StatefulWidget {
  const TableauDeBordScreen({super.key});

  @override
  State<TableauDeBordScreen> createState() => _TableauDeBordScreenState();
}

class _TableauDeBordScreenState extends State<TableauDeBordScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Ouvrir le menu',
          icon: const Icon(Icons.menu_rounded, color: AppTheme.or),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const BrandLogo(centered: true, titleSize: 15),
        backgroundColor: AppTheme.anthracite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: const Icon(Icons.notifications_none_rounded,
                    color: AppTheme.grisClair),
                onPressed: () {},
              ),
              Positioned(
                top: 11,
                right: 11,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.or,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
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
              if (provider.erreur != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_rounded,
                            size: 58, color: AppTheme.or),
                        const SizedBox(height: 18),
                        const Text('Connexion indisponible',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(
                          'Le serveur est peut-être en réveil ou le réseau est coupé. Vos données n’ont pas été supprimées.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.grisClair),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: provider.charger,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                );
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
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const CalculMateriauxScreen()));
        } else if (index == 3) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SelectionMetrageScreen()));
        } else {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OuvriersScreen()));
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
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Calcul.'),
        NavigationDestination(
            icon: Icon(Icons.straighten_outlined),
            selectedIcon: Icon(Icons.straighten),
            label: 'Métrés'),
        NavigationDestination(
            icon: Icon(Icons.engineering_outlined),
            selectedIcon: Icon(Icons.engineering),
            label: 'Ouvriers'),
      ],
    );
  }

  Widget _buildKpiCard(String label, String valeur, IconData icon,
      {bool fullWidth = false, bool isHighlight = false, Color? color}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: AppCard(
      accent: isHighlight ? AppTheme.or : color,
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 18),
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
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.anthraciteClair,
      width: 292,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Row(
                children: [
                  const Expanded(child: BrandLogo(titleSize: 18)),
                  IconButton(
                    tooltip: 'Fermer le menu',
                    icon: const Icon(Icons.close, color: AppTheme.grisClair),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 22, 20, 8),
              child: Text('PILOTAGE', style: TextStyle(
                color: AppTheme.grisFonce,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              )),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _drawerItem(Icons.dashboard_rounded, 'Tableau de bord'),
                  _drawerItem(Icons.business_rounded, 'Mes chantiers',
                      () => const ChantiersListScreen()),
                  _drawerItem(Icons.payments_rounded, 'Finances',
                      () => const FinancesScreen()),
                  _drawerItem(Icons.calculate_rounded, 'Calcul matériaux',
                      () => const CalculMateriauxScreen()),
                  _drawerItem(Icons.straighten_rounded, 'Métrés',
                      () => const SelectionMetrageScreen()),
                  _drawerItem(Icons.engineering_rounded, 'Ouvriers',
                      () => const OuvriersScreen()),
                  _drawerItem(Icons.request_quote_rounded, 'Demandes de devis',
                      () => const DemandesDevisScreen()),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white12),
                  ),
                  _drawerItem(Icons.settings_rounded, 'Paramètres du site',
                      () => const GestionSiteScreen()),
                  _drawerItem(Icons.lock_reset_rounded, 'Changer le mot de passe',
                      () => const ChangerMotDePasseScreen()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
              child: ListTile(
                leading: const Icon(Icons.lock_outline_rounded,
                    color: AppTheme.grisClair),
                title: const Text('Verrouiller l’application'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthProvider>().verrouiller();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, [Widget Function()? page]) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.or),
      title: Text(label),
      trailing: page == null
          ? const Icon(Icons.check, color: AppTheme.or, size: 18)
          : const Icon(Icons.chevron_right),
      onTap: page == null
          ? () => Navigator.pop(context)
          : () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => page()));
            },
    );
  }
}
