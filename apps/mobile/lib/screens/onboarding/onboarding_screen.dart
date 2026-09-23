import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../auth/pin_lock_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _bgController;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      titre: 'L\'Excellence\ndu Plâtre',
      description:
          'Gérez vos chantiers de plâtrerie et décoration haut de gamme avec une précision d\'artisan.',
      icon: Icons.architecture_rounded,
      badge: 'GESTION DE CHANTIERS',
    ),
    _OnboardingSlide(
      titre: 'Suivi Financier\nen Temps Réel',
      description:
          'Acomptes, dépenses, matériaux — une vue claire et instantanée sur la rentabilité de chaque projet.',
      icon: Icons.insights_rounded,
      badge: 'COMPTABILITÉ INTELLIGENTE',
    ),
    _OnboardingSlide(
      titre: 'Travaillez\nPartout',
      description:
          'Saisissez vos données directement sur le chantier, même sans internet. La synchronisation se fait automatiquement.',
      icon: Icons.cloud_done_rounded,
      badge: 'MODE HORS-LIGNE',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _terminerOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_vu', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => const PinLockScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // --- Background gradient qui pulse ---
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.5 + _currentPage * 0.5,
                      -0.3 + _bgController.value * 0.2,
                    ),
                    radius: 1.5,
                    colors: [
                      AppTheme.or.withOpacity(0.05 + 0.03 * _bgController.value),
                      const Color(0xFF0A0A0B),
                      const Color(0xFF050505),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              );
            },
          ),

          // --- Contenu principal ---
          SafeArea(
            child: Column(
              children: [
                // Header : Logo + Bouton Passer
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.or.withOpacity(0.65)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.or.withOpacity(0.18),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset('assets/brand-logo.png', fit: BoxFit.contain),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ÉLITE PLACO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.or,
                                  letterSpacing: 3,
                                ),
                              ),
                              Text(
                                'PRIMA BTP',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white.withOpacity(0.3),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Bouton Passer
                      TextButton(
                        onPressed: _terminerOnboarding,
                        child: Text(
                          'Passer',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Slides
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 1),

                            // Badge doré
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.or.withOpacity(0.2)),
                                color: AppTheme.or.withOpacity(0.05),
                              ),
                              child: Text(
                                slide.badge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.or,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Icône avec glow
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.02),
                                border: Border.all(
                                    color: AppTheme.or.withOpacity(0.15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.or.withOpacity(0.1),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFE8CC82),
                                    Color(0xFFD4AF37),
                                    Color(0xFFB5952F),
                                  ],
                                ).createShader(bounds),
                                child: Icon(slide.icon,
                                    size: 52, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Titre
                            Text(
                              slide.titre,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Description
                            Text(
                              slide.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.45),
                                height: 1.6,
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            const Spacer(flex: 2),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // --- Bottom : Dots + Bouton ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots
                      Row(
                        children: List.generate(
                          _slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(right: 8),
                            height: 3,
                            width: _currentPage == index ? 28 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppTheme.or
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      // Bouton Suivant / Commencer
                      GestureDetector(
                        onTap: () {
                          if (_currentPage == _slides.length - 1) {
                            _terminerOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFD4AF37),
                                Color(0xFFE8CC82),
                                Color(0xFFD4AF37),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.or.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _slides.length - 1
                                    ? 'COMMENCER'
                                    : 'SUIVANT',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF050505),
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == _slides.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.chevron_right_rounded,
                                size: 18,
                                color: const Color(0xFF050505),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final String titre;
  final String description;
  final IconData icon;
  final String badge;

  _OnboardingSlide({
    required this.titre,
    required this.description,
    required this.icon,
    required this.badge,
  });
}
