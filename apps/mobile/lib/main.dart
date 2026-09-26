import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/pin_lock_screen.dart';
import 'screens/dashboard/tableau_de_bord_screen.dart';

import 'repositories/chantier_repository.dart';
import 'repositories/mouvement_repository.dart';

import 'providers/auth_provider.dart';
import 'providers/chantier_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/ouvrier_provider.dart';
import 'providers/materiaux_provider.dart';
import 'providers/metrage_provider.dart';
import 'services/sync_service.dart';
import 'widgets/network_status_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SyncService().init();
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingVu = prefs.getBool('onboarding_vu') ?? false;

  runApp(ElitePlacoApp(onboardingVu: onboardingVu));
}

class ElitePlacoApp extends StatelessWidget {
  final bool onboardingVu;
  const ElitePlacoApp({super.key, required this.onboardingVu});

  @override
  Widget build(BuildContext context) {
    final chantierRepository = ChantierRepository();
    final mouvementRepository = MouvementRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
            create: (_) => ChantierProvider(
                  chantierRepository: chantierRepository,
                  mouvementRepository: mouvementRepository,
                )),
        ChangeNotifierProvider(
            create: (_) => DashboardProvider(
                  chantierRepository: chantierRepository,
                  mouvementRepository: mouvementRepository,
                )),
        ChangeNotifierProvider(
            create: (_) => OuvrierProvider(
                  chantierRepository: chantierRepository,
                  mouvementRepository: mouvementRepository,
                )),
        ChangeNotifierProvider(create: (_) => MateriauxProvider()),
        ChangeNotifierProvider(create: (_) => MetrageProvider()),
      ],
      child: MaterialApp(
        title: 'Élite Placo & Déco',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme, // Thème Premium Anthracite/Or
        home:
            onboardingVu ? const _RouteurPrincipal() : const OnboardingScreen(),
      ),
    );
  }
}

class _RouteurPrincipal extends StatefulWidget {
  const _RouteurPrincipal();

  @override
  State<_RouteurPrincipal> createState() => _RouteurPrincipalState();
}

class _RouteurPrincipalState extends State<_RouteurPrincipal>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Reverrouiller automatiquement l'application lorsqu'elle passe en arrière-plan
      final auth = context.read<AuthProvider>();
      if (auth.estDeverrouille) {
        auth.verrouiller();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Column(
          children: [
            const NetworkStatusBanner(),
            Expanded(
              child: auth.estDeverrouille
                  ? const TableauDeBordScreen()
                  : const PinLockScreen(),
            ),
          ],
        );
      },
    );
  }
}
