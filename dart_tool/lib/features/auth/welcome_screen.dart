import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    this.onGetStarted,
    this.onLogIn,
  });

  final VoidCallback? onGetStarted;
  final VoidCallback? onLogIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: Stack(
          children: [
            // Decorative background circle outline
            Positioned(
              top: -200,
              right: -200,
              child: IgnorePointer(
                child: Container(
                  width: 650,
                  height: 650,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 850;
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 64 : 24,
                      vertical: 32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1300),
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(child: _buildLeftHero(context)),
                                  const SizedBox(width: 60),
                                  Expanded(child: _buildHeroCard(context)),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLeftHero(context),
                                  const SizedBox(height: 36),
                                  _buildHeroCard(context),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand & Eyebrow
        const Text(
          'SMRITI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.2,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Smriti — A Personal Digital Companion',
          style: TextStyle(
            color: Color(0xFFDCE8FF),
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 14),

        // Main Headline
        Text(
          'Remember.\nEngage.\nConnect.',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontFamily: 'Fraunces',
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 0.98,
                letterSpacing: -2.0,
                fontSize: 56,
              ),
        ),
        const SizedBox(height: 20),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const Text(
            'A gentle companion for everyday life — keeping familiar memories alive, routines calm, and family close.',
            style: TextStyle(
              color: Color(0xFFE3EDFF),
              fontSize: 18,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Action Buttons
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.blue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                if (onGetStarted != null) {
                  onGetStarted!();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthScreen(initialIsSignUp: true)),
                  );
                }
              },
              child: const Text('Get started'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF4FF),
                foregroundColor: AppColors.blue,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                if (onLogIn != null) {
                  onLogIn!();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthScreen(initialIsSignUp: false)),
                  );
                }
              },
              child: const Text('Log in'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D01154F),
            blurRadius: 70,
            offset: Offset(0, 30),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A LITTLE MOMENT, JUST FOR YOU',
            style: TextStyle(
              color: AppColors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '“Tell me about your favourite childhood meal.”',
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontFamilyFallback: AppFonts.headingFallback,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 22),
          _buildHeroRow(
            icon: '◉',
            title: 'Speak naturally',
            subtitle: 'SMRITI listens at your pace.',
          ),
          const SizedBox(height: 12),
          _buildHeroRow(
            icon: '♡',
            title: 'Keep stories close',
            subtitle: 'Share only when you choose.',
          ),
        ],
      ),
    );
  }

  Widget _buildHeroRow({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
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
