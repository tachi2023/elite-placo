import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  String _pinSaisi = '';
  String? _pinCree;
  bool _isLoading = false;
  Timer? _timer;
  int _secondsLeft = 0;
  bool _biometrieTente = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startTimerIfNeeded();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tenterBiometrieAuto();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startTimerIfNeeded();
  }

  void _tenterBiometrieAuto() async {
    if (_biometrieTente) return;
    final auth = context.read<AuthProvider>();
    if (auth.isPinConfigured &&
        auth.peutUtiliserBiometrie &&
        !auth.isLockedOut) {
      _biometrieTente = true;
      await auth.verifierBiometrie();
    }
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
            if (mounted) setState(() {});
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _appuyerTouche(String touche) async {
    if (_isLoading) return;
    final auth = context.read<AuthProvider>();
    if (auth.isLockedOut) return;

    HapticFeedback.lightImpact();

    if (touche == 'DEL') {
      if (_pinSaisi.isNotEmpty) {
        setState(
            () => _pinSaisi = _pinSaisi.substring(0, _pinSaisi.length - 1));
      }
      return;
    }

    if (_pinSaisi.length >= 4) return;
    setState(() => _pinSaisi += touche);

    if (_pinSaisi.length == 4) {
      setState(() => _isLoading = true);

      if (!auth.isPinConfigured) {
        if (_pinCree == null) {
          setState(() {
            _pinCree = _pinSaisi;
            _pinSaisi = '';
            _isLoading = false;
          });
        } else {
          if (_pinCree == _pinSaisi) {
            await auth.creerPin(_pinCree!);
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
      padding: const EdgeInsets.all(6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : () => _appuyerTouche(text),
          borderRadius: BorderRadius.circular(40),
          splashColor: AppTheme.or.withOpacity(0.15),
          highlightColor: AppTheme.or.withOpacity(0.05),
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDel || disabled
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.04),
              border: Border.all(
                color: isDel
                    ? (disabled
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.12))
                    : Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: isDel
                ? Icon(Icons.backspace_outlined,
                    size: 22,
                    color: disabled
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.grisClair)
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: disabled
                          ? Colors.white.withOpacity(0.1)
                          : AppTheme.blanc,
                      letterSpacing: 1,
                    ),
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
        backgroundColor: Color(0xFF0A0A0B),
        body: Center(child: CircularProgressIndicator(color: AppTheme.or)),
      );
    }

    String titre = 'Saisissez votre code PIN';
    String sousTitre = 'Accès sécurisé à votre espace de gestion';
    if (!auth.isPinConfigured) {
      titre = _pinCree == null
          ? 'Créez votre code PIN'
          : 'Confirmez votre code PIN';
      sousTitre = _pinCree == null
          ? 'Choisissez un code à 4 chiffres pour sécuriser vos données'
          : 'Saisissez à nouveau votre code pour confirmer';
    } else if (auth.isLockedOut) {
      titre = 'Accès temporairement bloqué';
      sousTitre = 'Réessayez dans $_secondsLeft secondes';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              AppTheme.or.withOpacity(0.06),
              const Color(0xFF0A0A0B),
              const Color(0xFF050505),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // --- Logo & Branding ---
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.or.withOpacity(
                            0.2 + 0.15 * _pulseController.value),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.or
                              .withOpacity(0.08 + 0.08 * _pulseController.value),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: auth.isLockedOut
                        ? const Icon(Icons.lock_outline, size: 36, color: AppTheme.erreur)
                        : ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Image.asset('assets/logo.jpg', fit: BoxFit.cover),
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Titre
              Text(
                'ÉLITE PLACO & DÉCO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.or,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PRIMA BTP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.or.withOpacity(0.5),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 28),

              // Message d'état
              Text(
                titre,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: auth.isLockedOut ? AppTheme.erreur : AppTheme.blanc,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  sousTitre,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: auth.isLockedOut
                        ? AppTheme.erreur.withOpacity(0.7)
                        : Colors.white.withOpacity(0.4),
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // --- Indicateurs PIN (4 dots) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final estRempli = i < _pinSaisi.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    width: estRempli ? 18 : 14,
                    height: estRempli ? 18 : 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: estRempli ? AppTheme.or : Colors.transparent,
                      border: Border.all(
                        color: estRempli
                            ? AppTheme.or
                            : Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: estRempli
                          ? [
                              BoxShadow(
                                color: AppTheme.or.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 12),

              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppTheme.or,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else
                const SizedBox(height: 36),

              const Spacer(flex: 1),

              // --- Clavier numérique ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          ['1', '2', '3'].map(_buildKeypadButton).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          ['4', '5', '6'].map(_buildKeypadButton).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          ['7', '8', '9'].map(_buildKeypadButton).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (auth.isPinConfigured && auth.peutUtiliserBiometrie)
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isLoading
                                    ? null
                                    : () => auth.verifierBiometrie(),
                                borderRadius: BorderRadius.circular(40),
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.or.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.fingerprint,
                                      size: 32, color: AppTheme.or),
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 88),
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
      ),
    );
  }
}
