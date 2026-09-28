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

  static const _gold = Color(0xFFC9A84C);
  static const _ink = Color(0xFFF5F5F5);
  static const _muted = Color(0xFFA6A6A6);

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Des chantiers',
      accent: 'sous contrôle',
      description:
          'Centralisez vos projets, vos équipes et vos finances dans une seule application pensée pour le terrain.',
      icon: Icons.construction_rounded,
    ),
    _OnboardingSlide(
      title: 'Chaque détail',
      accent: 'au bon endroit',
      description:
          'Suivez les métrés, les matériaux, les ouvriers et les factures sans perdre de temps entre deux rendez-vous.',
      icon: Icons.dashboard_customize_rounded,
    ),
    _OnboardingSlide(
      title: 'Travaillez',
      accent: 'hors ligne',
      description:
          'Saisissez vos informations sur chantier, puis synchronisez automatiquement dès que le réseau revient.',
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
      backgroundColor: const Color(0xFF1E1E1E),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          final horizontal = compact ? 24.0 : 42.0;

          return Stack(
            children: [
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, _) => Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(
                          -0.7 + (_currentPage * 0.35),
                          -0.55 + (_glowController.value * 0.12),
                        ),
                        radius: 1.3,
                        colors: const [
                          Color(0xFF3B3526),
                          Color(0xFF272727),
                          Color(0xFF1E1E1E),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ELITE PLACO',
                                  style: GoogleFonts.dmSans(
                                    color: _gold,
                                    fontSize: 11,
                                    letterSpacing: 3.2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PAR PRIMA BTP',
                                  style: GoogleFonts.dmSans(
                                    color: const Color(0xFFB7B7B7),
                                    fontSize: 10,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _terminerOnboarding,
                            style: TextButton.styleFrom(
                              foregroundColor: _gold,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                      const SizedBox(height: 8),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _slides.length,
                          onPageChanged: (page) =>
                              setState(() => _currentPage = page),
                          itemBuilder: (context, index) => _buildSlide(
                            _slides[index],
                            compact: compact,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: _currentPage == index ? 26 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? _gold
                                  : const Color(0xFF5E5A50),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton(
                          onPressed: _continuer,
                          style: FilledButton.styleFrom(
                            backgroundColor: _gold,
                            foregroundColor: const Color(0xFF1E1E1E),
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
                            side: const BorderSide(color: Color(0xFF5E5E5E)),
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
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSlide(_OnboardingSlide slide, {required bool compact}) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: compact ? 136 : 160,
              height: compact ? 136 : 160,
              decoration: BoxDecoration(
                color: const Color(0x33C9A84C),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0x4DC9A84C), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55C9A84C),
                    blurRadius: 35,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(slide.icon, color: _gold, size: compact ? 58 : 68),
            ),
            const SizedBox(height: 32),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${slide.title}\n',
                    style: const TextStyle(color: _ink),
                  ),
                  TextSpan(
                    text: slide.accent,
                    style: const TextStyle(
                      color: _gold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                color: _ink,
                fontSize: compact ? 34 : 42,
                height: 1.1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
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
