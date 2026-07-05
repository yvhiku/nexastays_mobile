import 'package:equatable/equatable.dart';

// Assuming these domain models exist, adjusting based on existing files or standard structures
import '../../../../features/home/domain/entities/property.dart';
import '../../../../features/identity_verification/domain/entities/verification.dart';
import '../../domain/entities/host_me_status.dart';

sealed class HostDashboardState extends Equatable {
  const HostDashboardState();

  @override
  List<Object?> get props => [];
}

class HostDashboardInitial extends HostDashboardState {
  const HostDashboardInitial();
}

class HostDashboardLoading extends HostDashboardState {
  const HostDashboardLoading();
}

class HostDashboardLoaded extends HostDashboardState {
  const HostDashboardLoaded({
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

  @override
  List<Object?> get props => [
        listings,
        totalEarnings,
        thisMonthEarnings,
        totalBookings,
        pendingBookings,
        activeBookings,
        hostVerificationStatus,
        hostMe,
        earningsTrendPct,
      ];
}

class HostDashboardError extends HostDashboardState {
  const HostDashboardError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
