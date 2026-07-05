import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/session_manager.dart';
import '../../domain/repositories/host_repository.dart';
import 'host_property_manage_state.dart';

class HostPropertyManageCubit extends Cubit<HostPropertyManageState> {
  HostPropertyManageCubit({
    required this.hostRepository,
    required this.sessionManager,
  }) : super(const HostPropertyManageInitial());

  final HostRepository hostRepository;
  final SessionManager sessionManager;

  Future<void> load(String propertyId) async {
    emit(const HostPropertyManageLoading());

    final userId = sessionManager.userId;
    if (userId == null) {
      emit(const HostPropertyManageError(message: 'User not authenticated.'));
      return;
    }

    final result = await hostRepository.getPropertyManageData(
      userId: userId,
      propertyId: propertyId,
    );

    result.fold(
      (failure) => emit(HostPropertyManageError(message: failure.message)),
      (data) => emit(HostPropertyManageLoaded(data: data)),
    );
  }

  Future<({bool success, String message})> pauseListing(
    String propertyId,
  ) async {
    final result = await hostRepository.pauseListing(propertyId);
    return result.fold(
      (failure) => (success: false, message: failure.message),
      (message) {
        load(propertyId);
        return (success: true, message: message);
      },
    );
  }

  Future<({bool success, String message})> resumeListing(
    String propertyId,
  ) async {
    final result = await hostRepository.resumeListing(propertyId);
    return result.fold(
      (failure) => (success: false, message: failure.message),
      (message) {
        load(propertyId);
        return (success: true, message: message);
      },
    );
  }
}
