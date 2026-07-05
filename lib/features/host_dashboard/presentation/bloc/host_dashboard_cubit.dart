import 'package:flutter_bloc/flutter_bloc.dart';

import 'host_dashboard_state.dart';
import '../../domain/repositories/host_repository.dart';
import '../../../../core/session/session_manager.dart';

class HostDashboardCubit extends Cubit<HostDashboardState> {
  HostDashboardCubit({
    required this.hostRepository,
    required this.sessionManager,
  }) : super(const HostDashboardInitial());

  final HostRepository hostRepository;
  final SessionManager sessionManager;

  Future<void> loadDashboard() async {
    emit(const HostDashboardLoading());

    final userId = sessionManager.userId;
    if (userId == null) {
      emit(const HostDashboardError(message: 'User not authenticated.'));
      return;
    }

    final result = await hostRepository.getHostStats(userId);

    result.fold(
      (failure) {
        emit(HostDashboardError(message: failure.message));
      },
      (stats) {
        emit(HostDashboardLoaded(
          listings: stats.listings,
          totalEarnings: stats.totalEarnings,
          thisMonthEarnings: stats.thisMonthEarnings,
          totalBookings: stats.totalBookings,
          pendingBookings: stats.pendingBookings,
          activeBookings: stats.activeBookings,
          hostVerificationStatus: stats.hostVerificationStatus,
          hostMe: stats.hostMe,
          earningsTrendPct: stats.earningsTrendPct,
        ));
      },
    );
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
