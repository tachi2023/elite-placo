import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Signal visuel commun à tous les écrans lorsque les écritures restent
/// locales et attendent le prochain retour du réseau.
class NetworkStatusBanner extends StatefulWidget {
  const NetworkStatusBanner({super.key});

  @override
  State<NetworkStatusBanner> createState() => _NetworkStatusBannerState();
}

class _NetworkStatusBannerState extends State<NetworkStatusBanner> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _horsLigne = false;

  @override
  void initState() {
    super.initState();
    _verifierConnexion();
    _subscription = Connectivity().onConnectivityChanged.listen((resultats) {
      if (!mounted) return;
      setState(() => _horsLigne = resultats.contains(ConnectivityResult.none));
    });
  }

  Future<void> _verifierConnexion() async {
    final resultats = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() => _horsLigne = resultats.contains(ConnectivityResult.none));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_horsLigne) return const SizedBox.shrink();

    return Material(
      color: AppTheme.anthraciteClair,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: AppTheme.or.withValues(alpha: 0.35))),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_rounded, color: AppTheme.or, size: 17),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Hors connexion · vos modifications sont enregistrées localement.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.grisClair),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
