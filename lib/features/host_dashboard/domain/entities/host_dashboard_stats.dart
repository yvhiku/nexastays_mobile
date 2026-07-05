import '../../../../features/home/domain/entities/property.dart';
import '../../../../features/identity_verification/domain/entities/verification.dart';
import 'host_me_status.dart';

class HostDashboardStats {
  const HostDashboardStats({
    required this.listings,
    required this.totalEarnings,
    required this.thisMonthEarnings,
    required this.totalBookings,
    required this.pendingBookings,
    required this.activeBookings,
    required this.hostVerificationStatus,
    required this.hostMe,
    this.earningsTrendPct = 0,
  });

  final List<Property> listings;
  final double totalEarnings;
  final double thisMonthEarnings;
  final int totalBookings;
  final int pendingBookings;
  final int activeBookings;
  final VerificationStatus hostVerificationStatus;
  final HostMeStatus hostMe;
  final double earningsTrendPct;
}
