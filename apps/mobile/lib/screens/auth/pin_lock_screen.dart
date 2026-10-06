import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

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

    if (_pinSaisi.length >= 6) return;
    setState(() => _pinSaisi += touche);

    if (_pinSaisi.length == 6) {
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

  Widget _buildKeypadButton(String text, {double size = 76}) {
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
          splashColor: AppTheme.or.withValues(alpha: 0.15),
          highlightColor: AppTheme.or.withValues(alpha: 0.05),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDel || disabled
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: isDel
                    ? (disabled
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.12))
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: isDel
                ? Icon(Icons.backspace_outlined,
                    size: 22,
                    color: disabled
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppTheme.grisClair)
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: disabled
                          ? Colors.white.withValues(alpha: 0.1)
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
          ? 'Choisissez un code à 6 chiffres pour sécuriser vos données'
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
            center: const Alignment(0, -0.35),
            radius: 1.25,
            colors: [
              AppTheme.or.withValues(alpha: 0.08),
              const Color(0xFF101010),
              const Color(0xFF050505),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: compact ? 18 : 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.or.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'ELITE PLACO',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 3,
                                  color: AppTheme.or,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PAR PRIMA BTP',
                                style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 1.7,
                                  color:
                                      AppTheme.grisClair.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) {
                            return Container(
                              width: compact ? 86 : 94,
                              height: compact ? 86 : 94,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.or.withValues(
                                      alpha:
                                          0.2 + 0.15 * _pulseController.value),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.or.withValues(
                                        alpha: 0.08 +
                                            0.08 * _pulseController.value),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: auth.isLockedOut
                                  ? const Icon(Icons.lock_outline,
                                      size: 36, color: AppTheme.erreur)
                                  : const Icon(Icons.architecture_rounded,
                                      size: 36, color: AppTheme.or),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'ESPACE PRIVÉ',
                          style: TextStyle(
                            color: AppTheme.or,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.8,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          titre,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: compact ? 22 : 24,
                            fontWeight: FontWeight.w600,
                            color: auth.isLockedOut
                                ? AppTheme.erreur
                                : AppTheme.blanc,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: compact ? 18 : 28),
                          child: Text(
                            sousTitre,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: auth.isLockedOut
                                  ? AppTheme.erreur.withValues(alpha: 0.7)
                                  : Colors.white.withValues(alpha: 0.42),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const Spacer(flex: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            final estRempli = i < _pinSaisi.length;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              width: estRempli ? 18 : 14,
                              height: estRempli ? 18 : 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: estRempli
                                    ? AppTheme.or
                                    : Colors.transparent,
                                border: Border.all(
                                  color: estRempli
                                      ? AppTheme.or
                                      : Colors.white.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                                boxShadow: estRempli
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.or
                                              .withValues(alpha: 0.5),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        if (_isLoading)
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.or,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          const SizedBox(height: 26),
                        const Spacer(flex: 1),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final buttonSize = min(
                                72.0,
                                max(52.0,
                                    (constraints.maxWidth - 24) / 3 - 12));
                            final buttonSlot = buttonSize + 12;
                            Widget row(List<String> keys) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: keys
                                      .map((key) => _buildKeypadButton(key,
                                          size: buttonSize))
                                      .toList(),
                                );

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  row(['1', '2', '3']),
                                  row(['4', '5', '6']),
                                  row(['7', '8', '9']),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (auth.isPinConfigured &&
                                          auth.peutUtiliserBiometrie)
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: _isLoading
                                                  ? null
                                                  : () =>
                                                      auth.verifierBiometrie(),
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              child: Container(
                                                width: buttonSize,
                                                height: buttonSize,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppTheme.or
                                                        .withValues(alpha: 0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(Icons.fingerprint,
                                                    size: min(
                                                        30, buttonSize * .42),
                                                    color: AppTheme.or),
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        SizedBox(width: buttonSlot),
                                      _buildKeypadButton('0', size: buttonSize),
                                      _buildKeypadButton('DEL',
                                          size: buttonSize),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Spacer(flex: 1),
                        if (auth.isPinConfigured && !auth.isLockedOut)
                          TextButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    await auth.deconnexionComplete();
                                    if (!context.mounted) return;
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                      (_) => false,
                                    );
                                  },
                            icon: const Icon(Icons.password_outlined),
                            label: const Text(
                              'Se reconnecter avec le mot de passe',
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  AppTheme.or.withValues(alpha: 0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
