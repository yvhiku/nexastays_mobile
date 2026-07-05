// =============================================================================
// NexaStays Onboarding Page
// =============================================================================
// Full-screen onboarding experience with swipeable slides, page indicators,
// Skip / Next / Get Started controls, and automatic Cubit management.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/buttons/primary_button.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../navigation/app_routes.dart';
import 'bloc/onboarding_cubit.dart';
import 'bloc/onboarding_state.dart';
import 'onboarding_slide.dart';

/// The main onboarding screen shown to first-time users.
///
/// Wraps the slide [PageView], dot indicators, and navigation controls
/// inside a [BlocProvider] so all children can react to page changes.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: const _OnboardingView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private inner view (has access to the Cubit via context)
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Slide data ──────────────────────────────────────────────────────

  static const _slides = [
    _SlideData(
      image: 'assets/images/onboarding/discover.jpg',
      title: 'Discover Unique Stays',
      description:
          'Find beautiful riads, apartments, and homes across Morocco.',
    ),
    _SlideData(
      image: 'assets/images/onboarding/trusted.jpg',
      title: 'Trusted & Verified',
      description: 'Every stay is verified to ensure comfort and safety.',
    ),
    _SlideData(
      image: 'assets/images/onboarding/host.jpg',
      title: 'Easy Booking',
      description: 'Book your stay quickly and securely in just a few taps.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.l,
            vertical: DSSpacing.m,
          ),
          child: Column(
            children: [
              // ── Top Header (Skip Button) ────────────────────────
              BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  final cubit = context.read<OnboardingCubit>();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedOpacity(
                      opacity: state.isLastPage ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: TextButton(
                        onPressed: state.isLastPage
                            ? null
                            : () => cubit.skip(_pageController),
                        child: Text(
                          'Skip',
                          style: DSTypography.bodyLarge.copyWith(
                            color: DSColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ── Slides ──────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: OnboardingCubit.totalPages,
                  onPageChanged: (index) {
                    context.read<OnboardingCubit>().updatePage(index);
                  },
                  itemBuilder: (_, index) {
                    final slide = _slides[index];
                    return OnboardingSlide(
                      image: slide.image,
                      title: slide.title,
                      description: slide.description,
                    );
                  },
                ),
              ),

              const SizedBox(height: DSSpacing.xl),

              // ── Bottom area: Dots + Button ──────────────────────
              BlocBuilder<OnboardingCubit, OnboardingState>(
                builder: (context, state) {
                  final cubit = context.read<OnboardingCubit>();

                  return Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          OnboardingCubit.totalPages,
                          (index) => _DotIndicator(
                            isActive: index == state.currentPage,
                          ),
                        ),
                      ),

                      const SizedBox(height: DSSpacing.xxl),

                      // Next / Get Started Button (Full width)
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: state.isLastPage ? 'Get Started' : 'Continue',
                          onPressed: () {
                            if (state.isLastPage) {
                              context.go(AppRoutes.login);
                            } else {
                              cubit.nextPage(_pageController);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: DSSpacing.m),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dot indicator
// ─────────────────────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive
            ? DSColors.primary
            : DSColors.primary.withValues(alpha: 0.2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide data model
// ─────────────────────────────────────────────────────────────────────────────

class _SlideData {
  const _SlideData({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;
}
