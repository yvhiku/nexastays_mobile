// =============================================================================
// NexaStays App Assets
// =============================================================================
// Centralised asset paths. Every path listed here MUST have a corresponding
// entry in the `assets` section of pubspec.yaml, otherwise Flutter will not
// bundle the file and a runtime error will occur.
// =============================================================================

/// Static asset paths used throughout the NexaStays app.
class AppAssets {
  AppAssets._();

  // ── Images / UI ─────────────────────────────────────────────────────

  /// NexaStays brand logo.
  static const String logo = 'assets/images/ui/logo.png';

  /// Fallback image shown when a property photo is unavailable.
  static const String placeholderProperty = 'assets/images/ui/empty.png';

  // ── Onboarding ──────────────────────────────────────────────────────

  /// Illustration for "Discover unique stays" slide.
  static const String onboardingDiscover =
      'assets/images/onboarding/discover.png';

  /// Illustration for "Verified & Trusted" slide.
  static const String onboardingTrusted =
      'assets/images/onboarding/trusted.png';

  /// Illustration for "Become a Host" slide.
  static const String onboardingHost = 'assets/images/onboarding/host.png';

  // ── Animations (Lottie) ─────────────────────────────────────────────

  /// Full-screen loading spinner (Lottie JSON).
  static const String loadingAnimation = 'assets/animations/loading.json';
}
