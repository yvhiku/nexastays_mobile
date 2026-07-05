import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../property/domain/entities/property.dart';
import '../entities/host_preferences.dart';

// =============================================================================
// Host Repository (Abstract Interface)
// =============================================================================

/// Contract for host-side operations: onboarding, listing management, and
/// earnings stats.
///
/// All methods return `Future<Either<Failure, T>>` so callers can handle
/// errors without exceptions.
abstract class HostRepository {
  /// Registers the current user as a host.
  Future<Either<Failure, void>> registerHost({
    required String userId,
    required String hostType,
  });

  /// Submits a new property listing for review / publication.
  Future<Either<Failure, Property>> submitProperty({
    required String hostId,
    required String hostType,
    required String propertyType,
    required String propertyName,
    required String city,
    required String neighborhood,
    required String exactAddress,
    required int beds,
    required int bathrooms,
    required int maxGuests,
    required double nightlyRate,
    required double? weeklyDiscountPercent,
    required double? monthlyDiscountPercent,
    required int minimumNights,
    required String checkInContact,
    required String checkInContactPhone,
    required String checkInInstructions,
    required String checkInMethod,
    required List<String> photoPaths,
    required String videoPath,
    required HostPreferences rules,
    required List<String> amenities,
    required List<String> vibeTags,
  });

  /// Returns all listings owned by [hostId].
  Future<Either<Failure, List<Property>>> getHostListings(String hostId);

  /// Partially updates a listing. Only keys present in [updates] are changed.
  Future<Either<Failure, Property>> updateListing({
    required String propertyId,
    required Map<String, dynamic> updates,
  });

  /// Fetches aggregated host statistics (earnings, bookings, etc.).
  Future<Either<Failure, HostStats>> getHostStats(String hostId);

  /// Temporarily hides a listing from search results.
  Future<Either<Failure, void>> pauseListing(String propertyId);

  /// Re-activates a previously paused listing.
  Future<Either<Failure, void>> resumeListing(String propertyId);
}

// =============================================================================
// Host Stats
// =============================================================================

/// Aggregated statistics shown on the host dashboard.
class HostStats extends Equatable {
  const HostStats({
    required this.hostId,
    required this.totalEarnings,
    required this.thisMonthEarnings,
    required this.totalBookings,
    required this.pendingBookings,
    required this.activeBookings,
    required this.totalListings,
    required this.weeklyEarnings,
  });

  final String hostId;
  final double totalEarnings;
  final double thisMonthEarnings;
  final int totalBookings;
  final int pendingBookings;
  final int activeBookings;
  final int totalListings;

  /// Earnings broken down by week: keys are `'W1'`, `'W2'`, `'W3'`, `'W4'`.
  final Map<String, double> weeklyEarnings;

  @override
  List<Object?> get props => [
        hostId,
        totalEarnings,
        thisMonthEarnings,
        totalBookings,
        pendingBookings,
        activeBookings,
        totalListings,
        weeklyEarnings,
      ];
}
