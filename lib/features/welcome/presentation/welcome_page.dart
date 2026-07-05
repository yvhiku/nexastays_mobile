// =============================================================================
// NexaStays Welcome Page
// =============================================================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/buttons/primary_button.dart';
import '../../../design_system/components/buttons/secondary_button.dart';
import '../../../design_system/tokens/colors.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/tokens/typography.dart';
import '../../../design_system/components/nexa_stays_wordmark.dart';
import '../../../navigation/app_routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image with Pink Overlay
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/onboarding/discover.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    DSColors.primary.withOpacity(0.9),
                    BlendMode.srcOver,
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      DSColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.l),
                      child: Column(
                        children: [
                          const SizedBox(height: DSSpacing.xxl),
                          // Splash icon replacing house logo
                          Image.asset(
                            'assets/images/ui/splash.png',
                            height: 64,
                            width: 64,
                          ),
                          const SizedBox(height: DSSpacing.m),
                          // Title
                          const NexaStaysWordmark(
                            fontSize: 40,
                            variant: NexaStaysWordmarkVariant.onGradient,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: DSSpacing.xs),
                          Text(
                            'Verified stays in Morocco',
                            style: DSTypography.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: DSSpacing.l),
                          // Chips
                          Wrap(
                            spacing: DSSpacing.s,
                            runSpacing: DSSpacing.s,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildChip('🇲🇦 Verified'),
                              _buildChip('🪪 ID-checked'),
                              _buildChip('🤩 Fair'),
                            ],
                          ),
                          const SizedBox(height: 64.0),
                          // Preview Card
                          _buildPreviewCard(),
                          const SizedBox(height: DSSpacing.xxl),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bottom Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    DSSpacing.l,
                    DSSpacing.xl,
                    DSSpacing.l,
                    DSSpacing.xxl, // extra padding for bottom safe area
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Book stays in Morocco with real trust.',
                        style: DSTypography.heading2.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 32,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xxl),
                      PrimaryButton(
                        label: 'Get Started',
                        onPressed: () => context.push(AppRoutes.register),
                      ),
                      const SizedBox(height: DSSpacing.m),
                      SecondaryButton(
                        label: 'Sign In',
                        onPressed: () => context.push(AppRoutes.login),
                      ),
                      const SizedBox(height: DSSpacing.l),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.go(AppRoutes.home),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RichText(
                              text: TextSpan(
                                text: 'Browse without account? ',
                                style: DSTypography.bodySmall.copyWith(
                                  color: DSColors.neutral,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Skip →',
                                    style: DSTypography.bodySmall.copyWith(
                                      color: DSColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: DSTypography.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/properties/riad1.jpg',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 72,
                  height: 72,
                  color: DSColors.background,
                  child: Icon(Icons.home, color: DSColors.primary),
                );
              },
            ),
          ),
          const SizedBox(width: DSSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rooftop riad in Marrakesh',
                  style: DSTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: DSColors.neutral,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Marrakech · Medina',
                  style: DSTypography.bodySmall.copyWith(
                    color: DSColors.neutral,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DSColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.luggage,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: DSSpacing.xs),
        ],
      ),
    );
  }
}
