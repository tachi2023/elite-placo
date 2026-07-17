import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _pinSaisi = '';
  String? _pinCree; // Utilisé pendant la phase de création/confirmation
  bool _isLoading = false;
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startTimerIfNeeded();
  }

  void _startTimerIfNeeded() {
    final auth = context.read<AuthProvider>();
    if (auth.isLockedOut) {
      final diff = auth.lockoutUntil!.difference(DateTime.now()).inSeconds;
      if (diff > 0) {
        setState(() => _secondsLeft = diff);
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_secondsLeft > 0) {
            setState(() => _secondsLeft--);
          } else {
            timer.cancel();
            auth.notifyListeners(); // Refresh state
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _appuyerTouche(String touche) async {
    if (_isLoading) return;

    final auth = context.read<AuthProvider>();
    if (auth.isLockedOut) return;

    if (touche == 'DEL') {
      if (_pinSaisi.isNotEmpty) {
        setState(() => _pinSaisi = _pinSaisi.substring(0, _pinSaisi.length - 1));
      }
      return;
    }

    if (_pinSaisi.length >= 4) return;
    setState(() => _pinSaisi += touche);

    if (_pinSaisi.length == 4) {
      setState(() => _isLoading = true);

      if (!auth.isPinConfigured) {
        // Phase de création du PIN
        if (_pinCree == null) {
          // Premier passage : on enregistre le PIN saisi et on demande de confirmer
          setState(() {
            _pinCree = _pinSaisi;
            _pinSaisi = '';
            _isLoading = false;
          });
        } else {
          // Deuxième passage : confirmation
          if (_pinCree == _pinSaisi) {
            await auth.creerPin(_pinCree!);
            // Le provider passera 'estDeverrouille = true'
          } else {
            setState(() {
              _pinCree = null;
              _pinSaisi = '';
              _isLoading = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Les codes ne correspondent pas. Réessayez.'),
                  backgroundColor: AppTheme.erreur,
                ),
              );
            }
          }
        }
      } else {
        // Phase de vérification normale
        final ok = await auth.verifierPin(_pinSaisi);
        if (!ok && mounted) {
          setState(() {
            _pinSaisi = '';
            _isLoading = false;
          });
          _startTimerIfNeeded();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(auth.erreurConnexion ?? 'Code PIN incorrect.'),
              backgroundColor: AppTheme.erreur,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildKeypadButton(String text) {
    final isDel = text == 'DEL';
    final auth = context.watch<AuthProvider>();
    final disabled = auth.isLockedOut || _isLoading;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: disabled ? null : () => _appuyerTouche(text),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDel || disabled ? Colors.transparent : AppTheme.anthraciteClair,
            border: isDel ? Border.all(color: disabled ? AppTheme.anthraciteClair : AppTheme.grisFonce) : null,
          ),
          alignment: Alignment.center,
          child: isDel
              ? Icon(Icons.backspace_outlined, color: disabled ? AppTheme.anthraciteClair : AppTheme.grisFonce)
              : Text(
                  text,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: disabled ? AppTheme.anthraciteClair : AppTheme.blanc,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitializing) {
      return const Scaffold(
        backgroundColor: AppTheme.anthracite,
        body: Center(child: CircularProgressIndicator(color: AppTheme.or)),
      );
    }

    String titre = 'Saisissez votre code PIN';
    if (!auth.isPinConfigured) {
      titre = _pinCree == null ? 'Créez votre code PIN' : 'Confirmez votre code PIN';
    } else if (auth.isLockedOut) {
      titre = 'Bloqué. Réessayez dans $_secondsLeft s';
    }

    return Scaffold(
      backgroundColor: AppTheme.anthracite,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Icon(auth.isLockedOut ? Icons.lock_clock_outlined : Icons.architecture_rounded, 
                 size: 64, color: auth.isLockedOut ? AppTheme.erreur : AppTheme.or),
            const SizedBox(height: 16),
            Text(
              'ÉLITE PLACO',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titre,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: auth.isLockedOut ? AppTheme.erreur : AppTheme.grisClair,
                fontWeight: auth.isLockedOut ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(flex: 1),
            
            // Indicateurs PIN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final estRempli = i < _pinSaisi.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: estRempli ? AppTheme.or : Colors.transparent,
                    border: Border.all(
                      color: estRempli ? AppTheme.or : AppTheme.grisFonce,
                      width: 2,
                    ),
                    boxShadow: estRempli ? [
                      BoxShadow(
                        color: AppTheme.or.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ] : null,
                  ),
                );
              }),
            ),
            const Spacer(flex: 1),
            
            if (_isLoading)
              const CircularProgressIndicator(color: AppTheme.or)
            else
              const SizedBox(height: 36),
              
            const Spacer(flex: 1),
            
            // Clavier numérique
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['1', '2', '3'].map(_buildKeypadButton).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['4', '5', '6'].map(_buildKeypadButton).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['7', '8', '9'].map(_buildKeypadButton).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 88), // Espace vide à gauche
                      _buildKeypadButton('0'),
                      _buildKeypadButton('DEL'),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

