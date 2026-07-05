// =============================================================================
// NexaStays Splash Screen
// =============================================================================
// Premium animated splash screen displayed on app launch.
// Shows the NexaStays branding with smooth fade-in and scale animations,
// then navigates to the onboarding or home route.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../design_system/tokens/colors.dart';
import '../../../design_system/components/nexa_stays_wordmark.dart';
import '../../../navigation/app_routes.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';

/// The very first screen the user sees when launching NexaStays.
///
/// Plays a polished entrance animation sequence and then automatically
/// navigates to [AppRoutes.onboarding] (or home if already authenticated).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // ── Animation controllers ───────────────────────────────────────────
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _shimmerController;

  // ── Animations ──────────────────────────────────────────────────────
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineFade;

  // ── Design tokens ──────────────────────────────────────────────────
  static const _primary = DSColors.primary;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    // Logo: scale-up + fade-in (0 → 800ms)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Text: fade-in + slide-up (staggered after logo)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFade = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _taglineFade = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    // Subtle shimmer loop for the accent ring
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  Future<void> _startSequence() async {
    // Small delay so the system UI settles
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    _textController.forward();
    _shimmerController.repeat(reverse: true);

    // Navigate after branding has been shown
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    await _waitForAuthResolved();
    if (!mounted) return;

    _navigateAfterSplash();
  }

  /// Waits until [AuthBloc] has finished restoring cached session (not [AuthInitial]).
  Future<void> _waitForAuthResolved() async {
    final bloc = context.read<AuthBloc>();
    if (bloc.state is! AuthInitial) return;
    // Yield so a completed [AuthCheckCachedUser] emit is visible on [bloc.state].
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    if (bloc.state is! AuthInitial) return;
    try {
      await bloc.stream
          .firstWhere((s) => s is! AuthInitial)
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      // Proceed as guest if session restore hangs.
    }
  }

  void _navigateAfterSplash() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.go(AppRoutes.home);
    } else if (auth is AuthOtpVerified) {
      context.go(AppRoutes.register);
    } else if (auth is AuthPinRequired) {
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primary,
      body: Stack(
        children: [
          // ── Background image with color overlay ─────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/ui/background.jpg',
              fit: BoxFit.cover,
              color: _primary.withValues(alpha: 0.85),
              colorBlendMode: BlendMode.srcOver,
            ),
          ),

          // ── Background decorative circles ───────────────────────────
          _buildBackgroundDecoration(),

          // ── Main content ────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated logo / illustration
                _buildLogo(),

                const SizedBox(height: 16),

                // Brand name
                _buildBrandName(),

                const SizedBox(height: 8),

                // Tagline
                _buildTagline(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Background decoration ─────────────────────────────────────────

  Widget _buildBackgroundDecoration() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmer = _shimmerController.value;
        return Stack(
          children: [
            // Top-right accent blob
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 200 + (shimmer * 20),
                height: 200 + (shimmer * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.1 + shimmer * 0.05),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom-left accent blob
            Positioned(
              bottom: -80,
              left: -50,
              child: Container(
                width: 250 + (shimmer * 15),
                height: 250 + (shimmer * 15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08 + shimmer * 0.04),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Logo / illustration ───────────────────────────────────────────

  Widget _buildLogo() {
    return FadeTransition(
      opacity: _logoFade,
      child: ScaleTransition(
        scale: _logoScale,
        child: Image.asset(
          'assets/images/ui/splash.png',
          width: 140,
          height: 140,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ── Brand name ────────────────────────────────────────────────────

  Widget _buildBrandName() {
    return SlideTransition(
      position: _textSlide,
      child: FadeTransition(
        opacity: _textFade,
        child: const NexaStaysWordmark(
          fontSize: 48,
          variant: NexaStaysWordmarkVariant.onGradient,
        ),
      ),
    );
  }

  // ── Tagline ───────────────────────────────────────────────────────

  Widget _buildTagline() {
    return FadeTransition(
      opacity: _taglineFade,
      child: Text(
        'Verified stays in Morocco',
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.9),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
