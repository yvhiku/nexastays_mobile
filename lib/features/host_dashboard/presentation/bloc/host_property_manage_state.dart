import 'package:equatable/equatable.dart';

import '../../domain/entities/host_property_manage_data.dart';

abstract class HostPropertyManageState extends Equatable {
  const HostPropertyManageState();

  @override
  List<Object?> get props => [];
}

class HostPropertyManageInitial extends HostPropertyManageState {
  const HostPropertyManageInitial();
}

class HostPropertyManageLoading extends HostPropertyManageState {
  const HostPropertyManageLoading();
}

class HostPropertyManageLoaded extends HostPropertyManageState {
  const HostPropertyManageLoaded({required this.data});

  final HostPropertyManageData data;

  @override
  List<Object?> get props => [data];
}

class HostPropertyManageError extends HostPropertyManageState {
  const HostPropertyManageError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
