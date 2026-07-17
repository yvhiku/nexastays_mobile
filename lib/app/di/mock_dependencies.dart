import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

import '../../core/error/failures.dart';
import '../../core/session/session_manager.dart';
import '../../core/storage/local_storage.dart';

import '../../features/home/domain/entities/property.dart' as home_entity;
import '../../features/home/domain/repositories/property_repository.dart' as home_repo;
import '../../features/home/domain/usecases/get_properties_usecase.dart' as home_usecase;
import '../../features/home/presentation/bloc/home_cubit.dart';

import '../../features/property/domain/entities/property.dart' as prop_entity;
import '../../features/property/domain/repositories/property_repository.dart' as prop_repo;
import '../../features/property/domain/usecases/get_properties_usecase.dart' as prop_usecase;
import '../../features/property/domain/usecases/get_property_detail_usecase.dart';
import '../../features/property/domain/usecases/get_reviews_usecase.dart';
import '../../features/property/domain/entities/review.dart' as prop_review;
import '../../features/property/domain/entities/listing_reviews_result.dart';
import '../../features/property/presentation/listings/bloc/listings_bloc.dart';
import '../../features/property/presentation/detail/bloc/property_detail_cubit.dart';

import '../../features/search/domain/entities/search_filter.dart';
import '../../features/search/domain/search_filter_applier.dart';
import '../../features/search/domain/usecases/search_properties_usecase.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';

import '../../features/identity_verification/domain/entities/verification.dart';
import '../../features/identity_verification/domain/repositories/verification_repository.dart';
import '../../features/host_dashboard/domain/repositories/host_repository.dart' as dashboard_repo;
import '../../features/host_dashboard/domain/entities/host_dashboard_stats.dart';
import '../../features/host_dashboard/domain/entities/host_listing_edit_data.dart';
import '../../features/host_dashboard/domain/entities/host_property_manage_data.dart';
import '../../features/host_dashboard/domain/services/listing_analytics.dart';
import '../../features/host_dashboard/domain/entities/host_me_status.dart';
import '../../features/host_dashboard/presentation/bloc/host_dashboard_cubit.dart';
import '../../features/host_dashboard/presentation/bloc/host_property_manage_cubit.dart';
import '../../features/host_dashboard/presentation/bloc/host_reviews_cubit.dart';

import '../../features/property/data/datasources/property_remote_datasource.dart';

import '../../features/host_onboarding/presentation/bloc/host_onboarding_bloc.dart' as onboarding_bloc;
import '../../features/host_onboarding/presentation/bloc/host_onboarding_state.dart' as onboarding_state;

import '../../features/booking/domain/entities/booking.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/domain/usecases/create_booking_usecase.dart';
import '../../features/booking/domain/usecases/cancel_booking_usecase.dart';
import '../../features/booking/domain/usecases/get_bookings_usecase.dart';
import '../../features/booking/presentation/create/bloc/booking_bloc.dart';
import '../../features/booking/presentation/list/bloc/bookings_cubit.dart';

// ── Profile feature ─────────────────────────────────────────────────
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';

// ── Wishlist feature ────────────────────────────────────────────────
import '../../features/wishlist/domain/repositories/wishlist_repository.dart';
import '../../features/wishlist/domain/usecases/add_to_wishlist_usecase.dart';
import '../../features/wishlist/domain/usecases/remove_from_wishlist_usecase.dart';
import '../../features/wishlist/data/datasources/wishlist_local_datasource.dart';
import '../../features/wishlist/data/repositories/wishlist_repository_impl.dart';
import '../../features/wishlist/presentation/bloc/wishlist_cubit.dart';
import '../../features/property/data/models/property_model.dart';

// ── Dispute feature ─────────────────────────────────────────────────
import '../../features/dispute/domain/entities/dispute.dart';
import '../../features/dispute/domain/repositories/dispute_repository.dart';
import '../../features/dispute/domain/usecases/open_dispute_usecase.dart';
import '../../features/dispute/domain/usecases/get_dispute_status_usecase.dart';
import '../../features/dispute/data/datasources/dispute_remote_datasource.dart';
import '../../features/dispute/data/models/dispute_model.dart';
import '../../features/dispute/data/repositories/dispute_repository_impl.dart';
import '../../features/dispute/presentation/bloc/dispute_cubit.dart';

final GetIt getIt = GetIt.instance;

// ══════════════════════════════════════════════════════════════════════
// Mock Repositories — Existing Features
// ══════════════════════════════════════════════════════════════════════

class MockHomePropertyRepository implements home_repo.PropertyRepository {
  /// No seeded listings — real stays come from the API when mocks are off.
  static final _properties = <home_entity.Property>[];

  @override
  Future<Either<Failure, List<home_entity.Property>>> getProperties({
    bool featured = false,
  }) async {
    return Right(_properties);
  }

  @override
  Future<Either<Failure, List<home_entity.Property>>> searchProperties(SearchFilter filter) async {
    var results = _properties.toList();
    if (filter.city != null && filter.city!.isNotEmpty) {
      results = results.where((p) => p.city.toLowerCase().contains(filter.city!.toLowerCase())).toList();
    }
    if (filter.verifiedOnly) {
      results = results.where((p) => p.isVerified).toList();
    }
    if (filter.instantBookOnly) {
      results = results.where((p) => p.isInstantBook).toList();
    }
    if (filter.guestType == 'couples') {
      results = results.where((p) => p.maxGuests <= 2).toList();
    } else if (filter.guestType == 'family') {
      results = results.where((p) => p.maxGuests >= 4).toList();
    }
    return Right(results);
  }

  @override
  Future<Either<Failure, home_repo.ExploreSearchResult>> exploreProperties(
    SearchFilter filter, {
    String? cursor,
  }) async {
    final result = await searchProperties(filter);
    return result.fold(
      Left.new,
      (list) => Right(home_repo.ExploreSearchResult(
        properties: list,
        hasMore: false,
        nextCursor: null,
      )),
    );
  }

  @override
  Future<Either<Failure, List<home_entity.Property>>> exploreMapPins({
    required double north,
    required double south,
    required double east,
    required double west,
    SearchFilter? filter,
  }) async {
    final result = await searchProperties(filter ?? const SearchFilter());
    return result.fold(Left.new, (list) {
      return Right(list
          .where((p) =>
              p.hasMapCoordinates &&
              p.latitude! >= south &&
              p.latitude! <= north &&
              p.longitude! >= west &&
              p.longitude! <= east)
          .toList());
    });
  }
}

class MockFullPropertyRepository implements prop_repo.PropertyRepository {
  static final _properties = <prop_entity.Property>[];
  static final _reviews = <prop_review.Review>[];

  @override
  Future<Either<Failure, List<prop_entity.Property>>> getProperties({
    SearchFilter? filter, bool featured = false, bool trending = false,
  }) async {
    var results = _properties.toList();
    if (featured) results = results.where((p) => p.rating >= 4.7).toList();
    if (trending) results = results.where((p) => p.isTrending).toList();
    if (filter != null) {
      results = applySearchFilter(results, filter);
    }
    return Right(results);
  }

  @override
  Future<Either<Failure, prop_repo.ExploreSearchPage>> exploreSearch({
    SearchFilter? filter,
    String? cursor,
    int limit = 24,
  }) async {
    final result = await getProperties(filter: filter);
    return result.fold(
      Left.new,
      (list) => Right(prop_repo.ExploreSearchPage(
        properties: list.take(limit).toList(),
        hasMore: false,
        nextCursor: null,
      )),
    );
  }

  @override
  Future<Either<Failure, List<prop_entity.Property>>> exploreMap({
    required double north,
    required double south,
    required double east,
    required double west,
    SearchFilter? filter,
  }) async {
    final result = await getProperties(filter: filter);
    return result.fold(Left.new, (list) {
      return Right(list
          .where((p) =>
              p.hasMapCoordinates &&
              p.latitude! >= south &&
              p.latitude! <= north &&
              p.longitude! >= west &&
              p.longitude! <= east)
          .toList());
    });
  }

  @override
  Future<Either<Failure, prop_entity.Property>> getPropertyById(String id) async {
    final prop = _properties.where((p) => p.id == id).firstOrNull;
    if (prop != null) return Right(prop);
    return const Left(ServerFailure('Property not found'));
  }

  @override
  Future<Either<Failure, ListingReviewsResult>> getReviews({
    required String propertyId, int page = 1, int limit = 10,
  }) async {
    final slice = _reviews.where((r) => r.propertyId == propertyId).toList();
    return Right(
      ListingReviewsResult(reviews: slice, apiTotalCount: slice.length),
    );
  }

  @override
  Future<Either<Failure, List<prop_entity.Property>>> getFeaturedProperties() async =>
      Right(_properties.where((p) => p.rating >= 4.7).toList());

  @override
  Future<Either<Failure, List<prop_entity.Property>>> getTrendingProperties() async =>
      Right(_properties.where((p) => p.isTrending).toList());

  @override
  Future<Either<Failure, List<prop_entity.Property>>> getSavedProperties(String userId) async => const Right([]);

  @override
  Future<Either<Failure, void>> saveProperty({
    required String userId,
    required String propertyId,
    prop_entity.Property? property,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> unsaveProperty({required String userId, required String propertyId}) async => const Right(null);

  @override
  Future<Either<Failure, bool>> isPropertySaved({required String userId, required String propertyId}) async => const Right(false);
}

class MockBookingRepository implements BookingRepository {
  static final _bookings = <Booking>[];

  static List<Booking> get seededBookings => List.unmodifiable(_bookings);

  @override
  Future<Either<Failure, Booking>> createBooking({
    required String propertyId, required String guestId,
    required DateTime checkIn, required DateTime checkOut,
    required int guests, String? specialRequests,
    List<Map<String, dynamic>> occupants = const [],
  }) async {
    return const Left(
      ServerFailure('Bookings are created via the live API when mocks are off.'),
    );
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(String bookingId) async {
    final b = _bookings.where((b) => b.id == bookingId).firstOrNull;
    if (b != null) return Right(b);
    return const Left(ServerFailure('Booking not found'));
  }

  @override
  Future<Either<Failure, List<Booking>>> getGuestBookings(String guestId) async =>
      Right(_bookings.where((b) => b.guestId == guestId || guestId == 'mock-user').toList());

  @override
  Future<Either<Failure, List<Booking>>> getHostBookings(String hostId) async =>
      Right(_bookings.where((b) => b.hostId == hostId).toList());

  @override
  Future<Either<Failure, Booking>> cancelBooking({required String bookingId, required String reason}) async {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return const Left(ServerFailure('Booking not found'));
    final cancelled = _bookings[idx].copyWith(status: BookingStatus.cancelled, cancellationReason: reason, cancelledAt: DateTime.now());
    _bookings[idx] = cancelled;
    return Right(cancelled);
  }

  @override
  Future<Either<Failure, bool>> checkAvailability({required String propertyId, required DateTime checkIn, required DateTime checkOut}) async => const Right(true);

  @override
  Future<Either<Failure, List<DateTime>>> getBlockedDates(String propertyId) async => const Right([]);

  @override
  Future<Either<Failure, Booking>> completeBookingPayment(String bookingId) async {
    return getBookingById(bookingId);
  }

  @override
  Future<Either<Failure, String>> uploadOccupantIdDocument({
    required String filePath,
    required String side,
  }) async =>
      const Right('mock-asset-id');

  @override
  Future<Either<Failure, void>> submitBookingReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async =>
      const Right(null);
}

/// Shared in-memory store so onboarding submissions appear in the dashboard.
class _HostListingStore {
  _HostListingStore._();
  static final instance = _HostListingStore._();

  final List<home_entity.Property> listings = [];

  void addFromOnboardingState(onboarding_state.HostOnboardingState state) {
    final property = home_entity.Property(
      id: 'host-${DateTime.now().millisecondsSinceEpoch}',
      title: state.propertyName ?? 'Untitled Property',
      description: '${state.propertyType ?? 'Property'} in ${state.city ?? 'Unknown'}',
      city: state.city ?? 'Unknown',
      address: state.exactAddress ?? state.neighborhood ?? '',
      pricePerNight: state.nightlyRate ?? 0,
      rating: 0,
      reviewCount: 0,
      imageUrl: '',
      images: const [],
      hostId: 'mock-user',
      isFeatured: false,
      isTrending: false,
      propertyType: state.propertyType ?? 'House',
      maxGuests: state.maxGuests,
      bedrooms: state.beds,
      bathrooms: state.bathrooms,
      amenities: state.amenities,
      createdAt: DateTime.now(),
      latitude: state.geoLat,
      longitude: state.geoLng,
    );
    listings.add(property);
  }
}

class MockHostDashboardRepository implements dashboard_repo.HostRepository {
  static const _approvedHostMe = HostMeStatus(
    isHost: true,
    applicationStatus: 'APPROVED',
    identityStatus: 'VERIFIED',
    hostVerificationStatus: 'APPROVED',
    canCreateListing: true,
    canPublishListing: true,
  );

  @override
  Future<Either<Failure, HostMeStatus>> getHostMe() async {
    return const Right(_approvedHostMe);
  }

  @override
  Future<Either<Failure, HostDashboardStats>> getHostStats(String userId) async {
    return Right(HostDashboardStats(
      listings: _HostListingStore.instance.listings,
      totalEarnings: 0,
      thisMonthEarnings: 0,
      totalBookings: 0,
      pendingBookings: 0,
      activeBookings: 0,
      hostVerificationStatus: VerificationStatus.approved,
      hostMe: _approvedHostMe,
    ));
  }

  @override
  Future<Either<Failure, HostPropertyManageData>> getPropertyManageData({
    required String userId,
    required String propertyId,
  }) async {
    final property =
        _HostListingStore.instance.listings.where((p) => p.id == propertyId).firstOrNull;
    if (property == null) {
      return const Left(ServerFailure('Property not found'));
    }

    final listingBookings =
        MockBookingRepository.seededBookings
            .where((b) => b.propertyId == propertyId)
            .toList();

    return Right(
      HostPropertyManageData(
        property: property,
        analytics: ListingAnalyticsCalculator.fromBookings(listingBookings),
        pastBookings:
            ListingAnalyticsCalculator.historyFromBookings(listingBookings),
      ),
    );
  }

  @override
  Future<Either<Failure, HostListingEditData>> getListingForEdit(
    String listingId,
  ) async {
    final property =
        _HostListingStore.instance.listings.where((p) => p.id == listingId).firstOrNull;
    if (property == null) {
      return const Left(ServerFailure('Property not found'));
    }
    return Right(
      HostListingEditData(
        id: property.id,
        title: property.title,
        listingType: property.propertyType,
        city: property.city,
        neighborhood: '',
        address: property.address,
        description: property.description,
        status: property.listingStatus,
        checkInTime: '14:00',
        checkOutTime: '11:00',
        instantBooking: property.isInstantBook,
        basePrice: property.pricePerNight,
        weekendPrice: 0,
        cleaningFee: 0,
        currency: 'MAD',
        maxGuests: property.maxGuests,
        petsPolicy: 'NO',
        smokingPolicy: 'NOT_ALLOWED',
        amenities: property.amenities,
        cancellationPolicy: 'MODERATE',
        contactName: '',
        contactPhone: '',
        contactRole: 'OWNER',
        accessInstructions: '',
        photoUrls: property.images,
        geoLat: property.latitude,
        geoLng: property.longitude,
      ),
    );
  }

  @override
  Future<Either<Failure, HostListingEditData>> updateListing({
    required String listingId,
    String? title,
    String? city,
    String? neighborhood,
    String? address,
    String? description,
    String? checkInTime,
    String? checkOutTime,
    double? basePrice,
    double? weekendPrice,
    double? cleaningFee,
    int? maxGuests,
    String? petsPolicy,
    String? smokingPolicy,
    List<String>? amenities,
    String? accessInstructions,
    double? geoLat,
    double? geoLng,
  }) async {
    final result = await getListingForEdit(listingId);
    return result.map(
      (listing) => listing.copyWith(
        title: title,
        city: city,
        neighborhood: neighborhood,
        address: address,
        description: description,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        basePrice: basePrice,
        weekendPrice: weekendPrice,
        cleaningFee: cleaningFee,
        maxGuests: maxGuests,
        petsPolicy: petsPolicy,
        smokingPolicy: smokingPolicy,
        amenities: amenities,
        accessInstructions: accessInstructions,
        geoLat: geoLat,
        geoLng: geoLng,
      ),
    );
  }

  @override
  Future<Either<Failure, String>> pauseListing(String listingId) async {
    return const Right('Listing paused (mock).');
  }

  @override
  Future<Either<Failure, String>> resumeListing(String listingId) async {
    return const Right('Listing resumed (mock).');
  }
}

/// Local-only host listing draft until media is uploaded and
/// `POST /stays/host/listings` is wired with asset IDs from the backend.
class MockHostOnboardingRepository implements onboarding_bloc.HostRepository {
  @override
  Future<void> submitProperty(onboarding_state.HostOnboardingState state) async {
    await Future.delayed(const Duration(seconds: 1));
    _HostListingStore.instance.addFromOnboardingState(state);
  }
}

// ══════════════════════════════════════════════════════════════════════
// Mock Repositories — Profile
// ══════════════════════════════════════════════════════════════════════

class MockProfileRepository implements ProfileRepository {
  @override
  Future<Either<Failure, User>> getProfile(String userId) async {
    return Right(User(
      id: userId.isEmpty ? 'mock-user' : userId,
      phone: '+212000000000',
      fullName: 'Demo Guest',
      email: 'demo@example.local',
      dateOfBirth: DateTime(1998, 5, 15),
      isMoroccan: true,
      hasPin: true,
      isVerified: true,
      isHost: false,
      onboardingStep: OnboardingStep.complete,
      createdAt: DateTime(2025, 1, 1),
    ));
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    bool identityLocked = false,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? profilePhotoPath,
  }) async {
    final name = identityLocked
        ? 'Demo Guest'
        : '${firstName ?? 'Demo'} ${lastName ?? 'Guest'}';
    return Right(User(
      id: userId,
      phone: phone ?? '+212000000000',
      fullName: name,
      email: email,
      dateOfBirth: DateTime(1998, 5, 15),
      isMoroccan: true,
      hasPin: true,
      isVerified: true,
      isHost: false,
      onboardingStep: OnboardingStep.complete,
      createdAt: DateTime(2025, 1, 1),
    ));
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteAccount(String userId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateNotificationPreferences({
    required String userId,
    required Map<String, bool> preferences,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> updateLanguagePreference({
    required String userId,
    required String languageCode,
  }) async => const Right(null);

  @override
  Future<Either<Failure, User>> getCachedProfile(String userId) async {
    return getProfile(userId);
  }
}

// ══════════════════════════════════════════════════════════════════════
// Mock Data Sources — Wishlist (local-only, in-memory mock)
// ══════════════════════════════════════════════════════════════════════

class MockWishlistLocalDataSource implements WishlistLocalDataSource {
  final Map<String, Set<String>> _savedIds = {};
  final Map<String, List<PropertyModel>> _cachedProps = {};

  @override
  Future<Set<String>> getSavedIds(String userId) async =>
      _savedIds[userId] ?? {};

  @override
  Future<void> saveId(String userId, String propertyId) async {
    _savedIds.putIfAbsent(userId, () => {}).add(propertyId);
  }

  @override
  Future<void> removeId(String userId, String propertyId) async {
    _savedIds[userId]?.remove(propertyId);
  }

  @override
  Future<bool> isSaved(String userId, String propertyId) async =>
      _savedIds[userId]?.contains(propertyId) ?? false;

  @override
  Future<void> cacheProperty(String userId, PropertyModel property) async {
    final list = _cachedProps.putIfAbsent(userId, () => []);
    list.removeWhere((p) => p.id == property.id);
    list.add(property);
  }

  @override
  Future<List<PropertyModel>> getCachedProperties(String userId) async =>
      _cachedProps[userId] ?? [];

  @override
  Future<void> removeCachedProperty(String userId, String propertyId) async {
    _cachedProps[userId]?.removeWhere((p) => p.id == propertyId);
  }

  @override
  Future<void> clearWishlist(String userId) async {
    _savedIds.remove(userId);
    _cachedProps.remove(userId);
  }
}

// ══════════════════════════════════════════════════════════════════════
// Mock Data Sources — Dispute (returns stub data)
// ══════════════════════════════════════════════════════════════════════

class MockDisputeRemoteDataSource implements DisputeRemoteDataSource {
  final _progressController = StreamController<double>.broadcast();

  @override
  Stream<double> get uploadProgressStream => _progressController.stream;

  @override
  Future<DisputeModel> openDispute({
    required String bookingId,
    required String propertyId,
    required String guestId,
    required String type,
    required String description,
    required List<String> evidencePaths,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DisputeModel(
      id: 'dispute-${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      propertyId: propertyId,
      propertyName: 'Mock Property',
      guestId: guestId,
      guestName: 'Nexa Guest',
      hostId: 'host-1',
      hostName: 'Mock Host',
      type: DisputeType.other,
      description: description,
      evidenceUrls: evidencePaths,
      status: DisputeStatus.open,
      openedAt: DateTime.now(),
    );
  }

  @override
  Future<DisputeModel> getDisputeById(String disputeId) async {
    return DisputeModel(
      id: disputeId,
      bookingId: 'booking-1',
      propertyId: 'prop-1',
      propertyName: 'Mock Property',
      guestId: 'guest-1',
      guestName: 'Nexa Guest',
      hostId: 'host-1',
      hostName: 'Mock Host',
      type: DisputeType.other,
      description: 'Mock dispute',
      evidenceUrls: const [],
      status: DisputeStatus.underReview,
      openedAt: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  @override
  Future<DisputeModel> getDisputeByBookingId(String bookingId) async =>
      getDisputeById('dispute-for-$bookingId');

  @override
  Future<List<DisputeModel>> getGuestDisputes(String guestId) async =>
      const [];

  @override
  Future<DisputeModel> addEvidence({
    required String disputeId,
    required List<String> newEvidencePaths,
  }) async => getDisputeById(disputeId);

  @override
  Future<DisputeModel> closeDispute(String disputeId) async {
    final d = await getDisputeById(disputeId);
    return DisputeModel(
      id: d.id,
      bookingId: d.bookingId,
      propertyId: d.propertyId,
      propertyName: d.propertyName,
      guestId: d.guestId,
      guestName: d.guestName,
      hostId: d.hostId,
      hostName: d.hostName,
      type: d.type,
      description: d.description,
      evidenceUrls: d.evidenceUrls,
      status: DisputeStatus.closed,
      openedAt: d.openedAt,
      resolvedAt: DateTime.now(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Configuration
// ══════════════════════════════════════════════════════════════════════

void configureMockDependencies({bool seedMockAuth = true}) {
  if (!getIt.isRegistered<SessionManager>()) {
    final session = SessionManager();
    getIt.registerSingleton<SessionManager>(session);
    if (seedMockAuth) {
      // Mock mode only: pre-populate session for fast local UX.
      session.saveSession(
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        userId: 'mock-user',
      );
    }
  }

  // Mock mode only: pre-seed cached user so AuthBloc.getCachedUser works.
  if (seedMockAuth && getIt.isRegistered<LocalStorage>()) {
    final localStorage = getIt<LocalStorage>();
    const cachedUserJson = '{'
        '"id":"mock-user",'
        '"phone":"+212000000000",'
        '"full_name":"Demo Guest",'
        '"date_of_birth":"1998-05-15",'
        '"is_moroccan":true,'
        '"has_pin":true,'
        '"is_verified":true,'
        '"is_host":false,'
        '"email":"demo@example.local",'
        '"onboarding_step":"complete",'
        '"created_at":"2025-01-01T00:00:00.000"'
        '}';
    localStorage.setString('cached_user', cachedUserJson);
  }

  // ── Existing feature repositories ─────────────────────────────────
  getIt.registerSingleton<home_repo.PropertyRepository>(MockHomePropertyRepository());
  getIt.registerSingleton<prop_repo.PropertyRepository>(MockFullPropertyRepository());
  getIt.registerSingleton<BookingRepository>(MockBookingRepository());
  getIt.registerSingleton<dashboard_repo.HostRepository>(MockHostDashboardRepository());
  getIt.registerSingleton<onboarding_bloc.HostRepository>(MockHostOnboardingRepository());

  // ── Profile repositories & use cases ──────────────────────────────
  getIt.registerSingleton<ProfileRepository>(MockProfileRepository());
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<ProfileRepository>()),
  );

  // ── Wishlist data source, repo, and use cases ─────────────────────
  getIt.registerSingleton<WishlistLocalDataSource>(MockWishlistLocalDataSource());
  getIt.registerSingleton<WishlistRepositoryImpl>(
    WishlistRepositoryImpl(
      localDataSource: getIt<WishlistLocalDataSource>(),
      sessionManager: getIt<SessionManager>(),
    ),
  );
  // Also register as abstract interface for ProfileCubit dependency
  getIt.registerSingleton<WishlistRepository>(
    getIt<WishlistRepositoryImpl>(),
  );
  getIt.registerLazySingleton<AddToWishlistUseCase>(
    () => AddToWishlistUseCase(getIt<WishlistRepository>()),
  );
  getIt.registerLazySingleton<RemoveFromWishlistUseCase>(
    () => RemoveFromWishlistUseCase(getIt<WishlistRepository>()),
  );

  // ── Dispute data source, repo, and use cases ──────────────────────
  getIt.registerSingleton<DisputeRemoteDataSource>(MockDisputeRemoteDataSource());
  getIt.registerSingleton<DisputeRepositoryImpl>(
    DisputeRepositoryImpl(
      remoteDataSource: getIt<DisputeRemoteDataSource>(),
      localStorage: getIt<LocalStorage>(),
    ),
  );
  getIt.registerSingleton<DisputeRepository>(
    getIt<DisputeRepositoryImpl>(),
  );
  getIt.registerLazySingleton<OpenDisputeUseCase>(
    () => OpenDisputeUseCase(getIt<DisputeRepository>()),
  );
  getIt.registerLazySingleton<GetDisputeStatusUseCase>(
    () => GetDisputeStatusUseCase(getIt<DisputeRepository>()),
  );

  // ── Existing feature use cases ────────────────────────────────────
  getIt.registerLazySingleton<home_usecase.GetPropertiesUseCase>(() => home_usecase.GetPropertiesUseCase(getIt<home_repo.PropertyRepository>()));
  getIt.registerLazySingleton<prop_usecase.GetPropertiesUseCase>(() => prop_usecase.GetPropertiesUseCase(getIt<prop_repo.PropertyRepository>()));
  getIt.registerLazySingleton<SearchPropertiesUseCase>(() => SearchPropertiesUseCase(getIt<home_repo.PropertyRepository>()));
  getIt.registerLazySingleton<CreateBookingUseCase>(() => CreateBookingUseCase(getIt<BookingRepository>()));
  getIt.registerLazySingleton<CancelBookingUseCase>(() => CancelBookingUseCase(getIt<BookingRepository>()));
  getIt.registerLazySingleton<GetBookingsUseCase>(() => GetBookingsUseCase(getIt<BookingRepository>()));
  getIt.registerLazySingleton<GetPropertyDetailUseCase>(() => GetPropertyDetailUseCase(getIt<prop_repo.PropertyRepository>()));
  getIt.registerLazySingleton<GetReviewsUseCase>(() => GetReviewsUseCase(getIt<prop_repo.PropertyRepository>()));

  // ── Existing feature cubits/blocs ─────────────────────────────────
  getIt.registerFactory<HomeCubit>(() => HomeCubit(
    getPropertiesUseCase: getIt<home_usecase.GetPropertiesUseCase>(),
    sessionManager: getIt<SessionManager>(),
    localStorage: getIt<LocalStorage>(),
    hostRepository: getIt.isRegistered<dashboard_repo.HostRepository>()
        ? getIt<dashboard_repo.HostRepository>()
        : null,
  ));

  getIt.registerFactory<SearchBloc>(() => SearchBloc(
    searchUseCase: getIt<SearchPropertiesUseCase>(),
  ));

  getIt.registerFactory<HostDashboardCubit>(() => HostDashboardCubit(
    hostRepository: getIt<dashboard_repo.HostRepository>(),
    sessionManager: getIt<SessionManager>(),
  ));

  getIt.registerFactory<HostPropertyManageCubit>(() => HostPropertyManageCubit(
        hostRepository: getIt<dashboard_repo.HostRepository>(),
        sessionManager: getIt<SessionManager>(),
      ));

  getIt.registerFactory<HostReviewsCubit>(() => HostReviewsCubit(
        propertyRemote: getIt<PropertyRemoteDataSource>(),
      ));

  getIt.registerFactory<onboarding_bloc.HostOnboardingBloc>(() => onboarding_bloc.HostOnboardingBloc(
    hostRepository: getIt<onboarding_bloc.HostRepository>(),
  ));

  getIt.registerFactory<ListingsBloc>(() => ListingsBloc(
    getProperties: getIt<prop_usecase.GetPropertiesUseCase>(),
    propertyRepository: getIt<prop_repo.PropertyRepository>(),
    wishlistRepository: getIt<WishlistRepository>(),
    sessionManager: getIt<SessionManager>(),
  ));

  getIt.registerFactory<PropertyDetailCubit>(() => PropertyDetailCubit(
    getPropertyDetailUseCase: getIt<GetPropertyDetailUseCase>(),
    getReviewsUseCase: getIt<GetReviewsUseCase>(),
    propertyRepository: getIt<prop_repo.PropertyRepository>(),
    sessionManager: getIt<SessionManager>(),
  ));

  getIt.registerFactory<BookingBloc>(() => BookingBloc(
    createBookingUseCase: getIt<CreateBookingUseCase>(),
    cancelBookingUseCase: getIt<CancelBookingUseCase>(),
    bookingRepository: getIt<BookingRepository>(),
    propertyRepository: getIt<prop_repo.PropertyRepository>(),
    sessionManager: getIt<SessionManager>(),
  ));

  getIt.registerFactory<BookingsCubit>(() => BookingsCubit(
    getBookingsUseCase: getIt<GetBookingsUseCase>(),
    cancelBookingUseCase: getIt<CancelBookingUseCase>(),
    sessionManager: getIt<SessionManager>(),
  ));

  // ── Profile cubit ─────────────────────────────────────────────────
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(
    updateProfileUseCase: getIt<UpdateProfileUseCase>(),
    profileRepository: getIt<ProfileRepository>(),
    wishlistRepository: getIt<WishlistRepository>(),
    bookingRepository: getIt<BookingRepository>(),
    verificationRepository: getIt<VerificationRepository>(),
    sessionManager: getIt<SessionManager>(),
    localStorage: getIt<LocalStorage>(),
    authBloc: getIt<AuthBloc>(),
  ));

  // ── Wishlist cubit ────────────────────────────────────────────────
  if (getIt.isRegistered<WishlistCubit>()) {
    getIt.unregister<WishlistCubit>();
  }
  getIt.registerLazySingleton<WishlistCubit>(() => WishlistCubit(
    addToWishlistUseCase: getIt<AddToWishlistUseCase>(),
    removeFromWishlistUseCase: getIt<RemoveFromWishlistUseCase>(),
    wishlistRepository: getIt<WishlistRepositoryImpl>(),
    sessionManager: getIt<SessionManager>(),
  ));

  // ── Dispute cubit ─────────────────────────────────────────────────
  getIt.registerFactory<DisputeCubit>(() => DisputeCubit(
    openDisputeUseCase: getIt<OpenDisputeUseCase>(),
    getDisputeStatusUseCase: getIt<GetDisputeStatusUseCase>(),
    disputeRepository: getIt<DisputeRepositoryImpl>(),
    sessionManager: getIt<SessionManager>(),
  ));
}
