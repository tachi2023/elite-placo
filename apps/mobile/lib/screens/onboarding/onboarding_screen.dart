import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/pin_lock_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _glowController;
  int _currentPage = 0;

  static const _indigo = Color(0xFF5146E5);
  static const _ink = Color(0xFF171724);
  static const _muted = Color(0xFF777791);

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Des chantiers\nplus ',
      accent: 'maîtrisés',
      description:
          'Centralisez vos projets, vos équipes et vos finances dans une seule application pensée pour le terrain.',
      icon: Icons.auto_awesome_rounded,
    ),
    _OnboardingSlide(
      title: 'Chaque détail\n',
      accent: 'au bon endroit',
      description:
          'Retrouvez vos métrés, matériaux, ouvriers et documents sans perdre de temps entre deux rendez-vous.',
      icon: Icons.dashboard_customize_rounded,
    ),
    _OnboardingSlide(
      title: 'Travaillez\n',
      accent: 'même hors-ligne',
      description:
          'Saisissez vos informations sur chantier. Elles restent disponibles et se synchronisent dès que le réseau revient.',
      icon: Icons.cloud_done_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _terminerOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_vu', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const PinLockScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _continuer() {
    if (_currentPage == _slides.length - 1) {
      _terminerOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          final horizontal = compact ? 28.0 : 48.0;

          return Stack(
            children: [
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) => Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(
                          -0.72 + (_currentPage * 0.35),
                          -0.65 + (_glowController.value * 0.12),
                        ),
                        radius: 1.25,
                        colors: const [
                          Color(0xFFECEBFF),
                          Color(0xFFF9F9FE),
                          Colors.white,
                        ],
                        stops: const [0, 0.42, 1],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _terminerOnboarding,
                            style: TextButton.styleFrom(
                              foregroundColor: _muted,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                            child: Text(
                              'Passer',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _slides.length,
                        onPageChanged: (page) => setState(() => _currentPage = page),
                        itemBuilder: (context, index) => _buildSlide(
                          _slides[index],
                          compact: compact,
                          horizontal: horizontal,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _slides.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? _indigo
                                      : const Color(0xFFDCDCE8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: FilledButton(
                              onPressed: _continuer,
                              style: FilledButton.styleFrom(
                                backgroundColor: _indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPage == _slides.length - 1
                                        ? 'Accéder à mon espace'
                                        : 'Commencer',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.arrow_forward_rounded, size: 19),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton(
                              onPressed: _terminerOnboarding,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _ink,
                                side: const BorderSide(color: Color(0xFFE2E2EA)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'J’ai déjà un compte',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
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
          );
        },
      ),
    );
  }

  Widget _buildSlide(
    _OnboardingSlide slide, {
    required bool compact,
    required double horizontal,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 124 : 142,
                height: compact ? 124 : 142,
                decoration: BoxDecoration(
                  color: const Color(0xFFECEEFF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(slide.icon, color: _indigo, size: compact ? 56 : 64),
              ),
              SizedBox(height: compact ? 38 : 48),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: slide.title),
                    TextSpan(
                      text: slide.accent,
                      style: const TextStyle(
                        color: _indigo,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: _ink,
                  fontSize: compact ? 34 : 42,
                  height: 1.12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: _muted,
                    fontSize: compact ? 15 : 16,
                    height: 1.65,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String accent;
  final String description;
  final IconData icon;

  const _OnboardingSlide({
    required this.title,
    required this.accent,
    required this.description,
    required this.icon,
  });
}
