// =============================================================================
// NexaStays Centralised Route Definitions
// =============================================================================
// Single source of truth for all named route paths used by GoRouter.
// Avoids magic strings scattered across the codebase.
// =============================================================================

/// Static route path constants and parameterised helpers for GoRouter.
abstract class AppRoutes {
  AppRoutes._();

  // ─── PUBLIC (no auth) ──────────────────────────────────────────
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const verifyPhone = '/verify-phone';
  static const createPin = '/create-pin';
  static const welcome = '/welcome';

  // ─── IDENTITY VERIFICATION (auth, no verification needed) ──────
  static const verifyId = '/verify-id';
  static const idCapture = '/id-capture';
  static const selfieCapture = '/selfie-capture';
  static const verificationStatus = '/verification-status';
  static const documentType = '/document-type';

  // ─── MAIN APP (auth required) ──────────────────────────────────
  static const home = '/home';
  static const explore = '/explore';
  static const listings = '/listings';
  static const propertyDetail = '/property/:id';
  /// Legacy path used by older widgets — redirects to [propertyDetailOf].
  static const propertyDetailLegacy = '/property-detail';
  static const saved = '/saved';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const settings = '/settings';
  static const help = '/help';
  static const about = '/about';
  static const contact = '/contact';
  static const contactForm = '/contact/form';

  // ─── BOOKING (auth + isVerified required) ──────────────────────
  static const booking = '/booking';
  static const confirmBooking = '/booking/confirm';
  static const bookingSuccess = '/booking/success';
  static const myBookings = '/my-bookings';
  static const bookingDetail = '/booking/:id';
  static const bookingCheckout = '/booking/:id/checkout';

  // ─── DISPUTE ───────────────────────────────────────────────────
  static const openDispute = '/dispute/open';
  static const disputeStatus = '/dispute/status';

  // ─── HOST ──────────────────────────────────────────────────────
  static const hostRegister = '/host-register';
  static const hostListProperty = '/host-list-property';
  static const hostDashboard = '/host-dashboard';
  static const hostCalendar = '/host-calendar';
  static const hostInsights = '/host-insights';
  static const hostReviews = '/host-reviews';
  static const hostPropertyManage = '/host-property-manage/:id';
  static const hostListingEdit = '/host-listing-edit/:id';
  static const videoRecord = '/video-record';

  // ─── HELPERS ───────────────────────────────────────────────────
  static String propertyDetailOf(String id) => '/property/$id';
  static String bookingDetailOf(String id) => '/booking/$id';
  static String bookingCheckoutOf(String id) => '/booking/$id/checkout';
  static String hostPropertyManageOf(String id) => '/host-property-manage/$id';
  static String hostListingEditOf(String id, {String? section}) {
    final base = '/host-listing-edit/$id';
    if (section == null || section.isEmpty) return base;
    return '$base?section=$section';
  }
}
