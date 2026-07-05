// =============================================================================
// NexaStays App Strings
// =============================================================================
// All user-facing strings in one place for easy localisation.
//
// TODO: Replace with flutter_localizations / intl ARB files when l10n is
//       configured. Each constant here maps 1-to-1 to a future ARB key.
// =============================================================================

/// User-facing copy used across the NexaStays app (English defaults).
class AppStrings {
  AppStrings._();

  // ── Branding ────────────────────────────────────────────────────────

  static const String appName = 'Nexa Stays';
  static const String tagline = 'Find your perfect stay';

  // ── Search ──────────────────────────────────────────────────────────

  static const String searchPlaceholder = 'Search destinations...';

  // ── Onboarding ──────────────────────────────────────────────────────

  static const String onboardingTitle1 = 'Discover unique stays';
  static const String onboardingSubtitle1 =
      'Find riads, villas and apartments across Morocco';

  static const String onboardingTitle2 = 'Verified & Trusted';
  static const String onboardingSubtitle2 =
      'Every stay is checked for quality and safety';

  static const String onboardingTitle3 = 'Become a Host';
  static const String onboardingSubtitle3 =
      'List your property and start earning';

  // ── Auth ────────────────────────────────────────────────────────────

  static const String loginTitle = 'Welcome back';
  static const String registerTitle = 'Create your account';
  static const String logoutLabel = 'Log out';
  static const String emailHint = 'Email address';
  static const String passwordHint = 'Password';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccount = "Don't have an account? ";
  static const String signUp = 'Sign up';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signIn = 'Sign in';

  // ── General actions ─────────────────────────────────────────────────

  static const String continueLabel = 'Continue';
  static const String getStarted = 'Get Started';
  static const String skip = 'Skip';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String done = 'Done';

  // ── Errors ──────────────────────────────────────────────────────────

  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'Unable to connect. Please check your internet connection and try again.';
  static const String sessionExpired =
      'Your session has expired. Please sign in again.';
}
