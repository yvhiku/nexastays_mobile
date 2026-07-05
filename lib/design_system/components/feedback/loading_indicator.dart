// =============================================================================
// NexaStays Design System — Loading Indicator
// =============================================================================
// Centered, semantically-labelled loading indicator. Uses a designated
// Lottie animation by default if available; otherwise falls back to a
// themed CircularProgressIndicator.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_assets.dart';
import '../../tokens/colors.dart';

/// A standard loading spinner for screen content.
///
/// Automatically centers itself and provides a structural semantic
/// label for accessibility ('Loading').
///
/// ```dart
/// if (isLoading) return const DSLoadingIndicator();
/// ```
class DSLoadingIndicator extends StatelessWidget {
  const DSLoadingIndicator({
    this.size = 64.0,
    this.useLottie = true,
    super.key,
  });

  /// The dimension of the spinner (width and height).
  final double size;

  /// If `true` and [AppAssets.loadingAnimation] exists, plays the Lottie file.
  /// Falls back to [CircularProgressIndicator] if `false` or if the animation
  /// fails to load.
  final bool useLottie;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Loading',
        child: SizedBox(
          width: size,
          height: size,
          child: _buildIndicator(),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    if (useLottie) {
      return Lottie.asset(
        AppAssets.loadingAnimation,
        width: size,
        height: size,
        fit: BoxFit.contain,
        // If the Lottie file is missing in pubspec or the path is wrong,
        // gracefully fall back to the native Material spinner.
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return const Padding(
      // Add slight inner padding so the spinner doesn't exactly touch the edge
      padding: EdgeInsets.all(8.0),
      child: CircularProgressIndicator(
        color: DSColors.primary,
        strokeWidth: 3.0,
      ),
    );
  }
}
