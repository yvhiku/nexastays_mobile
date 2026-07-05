// =============================================================================
// NexaStays Route Guard
// =============================================================================
// Centralised authentication gate used inside GoRouter's global `redirect`
// callback to protect pages and enforce login/register forwarding.

import '../core/session/session_manager.dart';
import 'app_routes.dart';

/// Route-level authentication guard for GoRouter.
///
/// ## Example usage in GoRouter:
///
/// ```dart
/// final routeGuard = RouteGuard(sessionManager: sessionManager);
///
/// final router = GoRouter(
///   redirect: (context, state) {
///     return routeGuard.redirectIfNotAuthenticated(state.matchedLocation);
///   },
///   routes: [ ... ],
/// );
/// ```
class RouteGuard {
  const RouteGuard({required this.sessionManager});

  /// The session manager used to check authentication status.
  final SessionManager sessionManager;

  /// Routes that do NOT require authentication.
  static const List<String> _publicRoutes = [
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.verifyPhone,
    AppRoutes.verifyId,
    AppRoutes.selfieCapture,
    AppRoutes.verificationStatus,
  ];

  /// Routes that are only accessible to unauthenticated users.
  static const List<String> _authOnlyRoutes = [
    AppRoutes.login,
    AppRoutes.register,
  ];

  /// Evaluates the current [location] against the user's auth state and
  /// returns a redirect path — or `null` if no redirect is needed.
  ///
  /// **Logic:**
  /// 1. If NOT authenticated AND trying to reach a protected route → redirect to login.
  /// 2. If authenticated AND trying to reach login/register → redirect to home.
  /// 3. Otherwise → `null` (no redirect, proceed normally).
  String? redirectIfNotAuthenticated(String location) {
    final isAuthenticated = sessionManager.isAuthenticated;
    final isPublicRoute =
        _publicRoutes.any((r) => location.startsWith(r) && r != '/');
    final isRootSplash = location == AppRoutes.splash;
    final isAuthRoute = _authOnlyRoutes.any((r) => location.startsWith(r));

    // ── Case 1: Unauthenticated user trying to access a protected route ──
    if (!isAuthenticated && !isPublicRoute && !isRootSplash) {
      return AppRoutes.login;
    }

    // ── Case 2: Authenticated user trying to access login/register ──
    if (isAuthenticated && isAuthRoute) {
      return AppRoutes.home;
    }

    // ── Default: No redirect needed ──
    return null;
  }
}
