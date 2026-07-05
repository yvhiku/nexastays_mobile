import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthResending extends AuthState {
  const AuthResending();
}

class AuthOtpSent extends AuthState {
  final String phone;
  final int resendCountdown;

  const AuthOtpSent({
    required this.phone,
    required this.resendCountdown,
  });

  @override
  List<Object?> get props => [phone, resendCountdown];
}

class AuthOtpVerified extends AuthState {
  final User user;
  final bool isNewUser;

  const AuthOtpVerified({
    required this.user,
    required this.isNewUser,
  });

  @override
  List<Object?> get props => [user, isNewUser];
}

class AuthPersonalInfoSaved extends AuthState {
  final User user;

  const AuthPersonalInfoSaved({
    required this.user,
  });

  @override
  List<Object?> get props => [user];
}

class AuthPinRequired extends AuthState {
  final String phone;

  const AuthPinRequired({
    required this.phone,
  });

  @override
  List<Object?> get props => [phone];
}

class AuthPinSuccess extends AuthState {
  final User user;

  const AuthPinSuccess({
    required this.user,
  });

  @override
  List<Object?> get props => [user];
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({
    required this.user,
  });

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final bool isOtpError;
  final bool isPinError;

  const AuthError({
    required this.message,
    this.isOtpError = false,
    this.isPinError = false,
  });

  @override
  List<Object?> get props => [message, isOtpError, isPinError];
}
