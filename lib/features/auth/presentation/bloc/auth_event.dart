import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class AuthCheckCachedUser extends AuthEvent {
  const AuthCheckCachedUser();

  @override
  List<Object> get props => [];
}

class AuthPhoneSubmitted extends AuthEvent {
  final String phone;
  final bool agreedToTerms;

  const AuthPhoneSubmitted({
    required this.phone,
    required this.agreedToTerms,
  });

  @override
  List<Object> get props => [phone, agreedToTerms];
}

class AuthOtpSubmitted extends AuthEvent {
  final String phone;
  final String otp;

  const AuthOtpSubmitted({
    required this.phone,
    required this.otp,
  });

  @override
  List<Object> get props => [phone, otp];
}

class AuthOtpResendRequested extends AuthEvent {
  final String phone;

  const AuthOtpResendRequested({
    required this.phone,
  });

  @override
  List<Object> get props => [phone];
}

class AuthPersonalInfoSubmitted extends AuthEvent {
  final String userId;
  final String fullName;
  final DateTime dateOfBirth;
  final bool isMoroccan;
  final String? email;
  final String? city;
  final String? nationality;
  final String? countryOfCitizenship;

  const AuthPersonalInfoSubmitted({
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    required this.isMoroccan,
    this.email,
    this.city,
    this.nationality,
    this.countryOfCitizenship,
  });

  @override
  List<Object> get props => [
        userId,
        fullName,
        dateOfBirth,
        isMoroccan,
        email ?? '',
        city ?? '',
        nationality ?? '',
        countryOfCitizenship ?? '',
      ];
}

class AuthKycSubmitted extends AuthEvent {
  final String fullName;
  final DateTime dateOfBirth;
  final bool isMoroccan;
  final String? email;
  final String? city;
  final String? nationality;

  const AuthKycSubmitted({
    required this.fullName,
    required this.dateOfBirth,
    required this.isMoroccan,
    this.email,
    this.city,
    this.nationality,
  });

  @override
  List<Object> get props => [
        fullName,
        dateOfBirth,
        isMoroccan,
        email ?? '',
        city ?? '',
        nationality ?? '',
      ];
}

class AuthPinCreated extends AuthEvent {
  final String userId;
  final String pin;
  final String confirmPin;

  const AuthPinCreated({
    required this.userId,
    required this.pin,
    required this.confirmPin,
  });

  @override
  List<Object> get props => [userId, pin, confirmPin];
}

class AuthPinLoginRequested extends AuthEvent {
  final String phone;
  final String pin;

  const AuthPinLoginRequested({
    required this.phone,
    required this.pin,
  });

  @override
  List<Object> get props => [phone, pin];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();

  @override
  List<Object> get props => [];
}
