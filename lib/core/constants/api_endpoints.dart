// =============================================================================
// NexaStays API Endpoints
// =============================================================================
// Canonical API paths used by NexaStays Flutter.
// Mirrors nexastays_web/lib/stays-api.ts and backend stays/identity controllers.
// =============================================================================

class ApiEndpoints {
  ApiEndpoints._();

  // Identity — auth & users
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/refresh';
  static const String accountSelect = '/auth/account/select';
  static const String pinVerify = '/auth/pin/verify';
  static const String pinSet = '/auth/pin/set';
  static const String registrationComplete = '/auth/registration/complete';
  static const String logout = '/auth/logout';

  /// Legacy aliases — prefer [pinSet] / [pinVerify].
  static const String createPin = pinSet;
  static const String confirmPin = pinSet;
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String personalInfo = '/auth/personal-info';

  // Identity — KYC / Sumsub
  static const String kycSubmit = '/kyc/submit';
  static const String kycSumsubToken = '/kyc/sumsub/token';
  static const String kycSumsubSync = '/kyc/sumsub/sync-status';

  // Identity — profile
  static const String usersMe = '/users/me';
  static const String usersProfile = '/users/profile';
  static const String usersProfilePhoto = '/users/me/profile-photo';
  static const String pushToken = '/users/me/push-token';

  // Stays — public config & listings
  static const String staysConfigFees = '/stays/config/fees';
  static const String staysExplore = '/stays/explore';
  static const String staysExploreMap = '/stays/explore/map';
  static const String staysListingsSearch = '/stays/listings/search';
  static const String staysListingById = '/stays/listings/{id}';
  static const String staysListingReviews = '/stays/listings/{id}/reviews';
  static const String staysListingMedia = '/stays/listings/{id}/media/{assetId}';

  // Stays — bookings (guest)
  static const String staysBookings = '/stays/bookings';
  static const String staysBookingById = '/stays/bookings/{id}';
  static const String staysBookingCancel = '/stays/bookings/{id}/cancel';
  static const String staysBookingReview = '/stays/bookings/{id}/review';
  static const String staysBookingOccupantUploadId =
      '/stays/bookings/occupants/upload-id';
  static const String staysBookingPaymentIntent =
      '/stays/bookings/{id}/payments/intent';
  static const String staysBookingPaymentWallet =
      '/stays/bookings/{id}/payments/wallet';
  static const String staysPaymentMockWebhook =
      '/stays/webhooks/payments/mock';

  // Host onboarding & dashboard
  static const String staysHostOnboarding = '/stays/host/onboarding';
  static const String staysHostMe = '/stays/host/me';
  static const String staysHostApply = '/stays/host/apply';
  static const String staysHostApplicationStatus =
      '/stays/host/application/status';
  static const String staysHostStats = '/stays/host/stats';
  static const String staysHostListings = '/stays/host/listings';
  static String staysHostListingById(String id) => '/stays/host/listings/$id';
  static String staysHostListingPause(String id) =>
      '/stays/host/listings/$id/pause';
  static String staysHostListingResume(String id) =>
      '/stays/host/listings/$id/resume';
  static const String staysHostListingPhotoUpload =
      '/stays/host/listings/media/photo';
  static const String staysHostListingWalkthroughUpload =
      '/stays/host/listings/media/walkthrough';
  static const String staysHostBookings = '/stays/host/bookings';
  static const String staysHostReviews = '/stays/host/reviews';
  static const String staysHostVerification = '/stays/host/verification';
  static const String staysHostVerificationFront =
      '/stays/host/verification/documents/front';
  static const String staysHostVerificationBack =
      '/stays/host/verification/documents/back';
  static const String staysHostVerificationSelfie =
      '/stays/host/verification/documents/selfie';

  static const String uploadMedia = '/media/upload';

  // Disputes
  static const String disputes = '/disputes';

  static String disputeById(String id) => '/disputes/$id';

  static String disputeEvidence(String id) => '/disputes/$id/evidence';

  static String disputeClose(String id) => '/disputes/$id/close';

  /// Admin (JWT + `ADMIN` role)
  static const String adminStaysStats = '/admin/stays/stats';
  static const String adminStaysListings = '/admin/stays/listings';
  static const String adminStaysHosts = '/admin/stays/hosts';

  static String adminListingById(String id) => '/admin/stays/listings/$id';

  static String listingById(String id) =>
      staysListingById.replaceFirst('{id}', id);

  static String listingReviews(String listingId) =>
      staysListingReviews.replaceFirst('{id}', listingId);

  static String listingMedia(String listingId, String assetId) =>
      staysListingMedia
          .replaceFirst('{id}', listingId)
          .replaceFirst('{assetId}', assetId);

  static String bookingById(String id) =>
      staysBookingById.replaceFirst('{id}', id);

  static String cancelBookingById(String id) =>
      staysBookingCancel.replaceFirst('{id}', id);

  static String bookingReviewById(String id) =>
      staysBookingReview.replaceFirst('{id}', id);

  static String paymentIntentByBookingId(String id) =>
      staysBookingPaymentIntent.replaceFirst('{id}', id);

  static String paymentWalletByBookingId(String id) =>
      staysBookingPaymentWallet.replaceFirst('{id}', id);

  static String mockPaymentWebhook() => staysPaymentMockWebhook;
}
