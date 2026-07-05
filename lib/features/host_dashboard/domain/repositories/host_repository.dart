import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/host_dashboard_stats.dart';
import '../entities/host_me_status.dart';
import '../entities/host_property_manage_data.dart';
import '../entities/host_listing_edit_data.dart';

abstract class HostRepository {
  Future<Either<Failure, HostDashboardStats>> getHostStats(String userId);

  /// Lightweight host onboarding status (`GET /stays/host/me`).
  Future<Either<Failure, HostMeStatus>> getHostMe();

  /// Property manage screen — listing detail + per-listing bookings analytics.
  Future<Either<Failure, HostPropertyManageData>> getPropertyManageData({
    required String userId,
    required String propertyId,
  });

  Future<Either<Failure, HostListingEditData>> getListingForEdit(String listingId);

  Future<Either<Failure, HostListingEditData>> updateListing({
    required String listingId,
    String? title,
    String? city,
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
  });

  Future<Either<Failure, String>> pauseListing(String listingId);

  Future<Either<Failure, String>> resumeListing(String listingId);
}
