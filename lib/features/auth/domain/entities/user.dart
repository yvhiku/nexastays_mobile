import 'package:equatable/equatable.dart';

enum OnboardingStep {
  phoneEntry,
  otpVerify,
  personalInfo,
  documentType,
  documentCapture,
  pinSetup,
  complete,
}

class User extends Equatable {
  final String id;
  final String phone;
  final String fullName;
  final DateTime dateOfBirth;
  final bool isMoroccan;
  final String? nationality;
  final String? countryOfCitizenship;
  final String? profilePhotoUrl;
  final bool hasPin;
  final bool isVerified;
  final bool isHost;
  final String? email;
  final OnboardingStep onboardingStep;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.dateOfBirth,
    required this.isMoroccan,
    this.nationality,
    this.countryOfCitizenship,
    this.profilePhotoUrl,
    required this.hasPin,
    required this.isVerified,
    required this.isHost,
    this.email,
    required this.onboardingStep,
    required this.createdAt,
  });

  String get firstName => fullName.trim().split(' ').first;

  String get lastName {
    final parts = fullName.trim().split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  String get initials => fullName
      .trim()
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();

  String get maskedPhone => phone.length > 6
      ? phone.substring(0, 6) + '*** ***' + phone.substring(phone.length - 2)
      : phone;

  bool get isOnboardingComplete => onboardingStep == OnboardingStep.complete;

  bool get canBook => isVerified && hasPin;

  bool get needsPin => !hasPin;

  bool get isKycApproved => isVerified;

  User copyWith({
    String? id,
    String? phone,
    String? fullName,
    DateTime? dateOfBirth,
    bool? isMoroccan,
    String? nationality,
    String? countryOfCitizenship,
    String? profilePhotoUrl,
    bool? hasPin,
    bool? isVerified,
    bool? isHost,
    String? email,
    OnboardingStep? onboardingStep,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isMoroccan: isMoroccan ?? this.isMoroccan,
      nationality: nationality ?? this.nationality,
      countryOfCitizenship: countryOfCitizenship ?? this.countryOfCitizenship,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      hasPin: hasPin ?? this.hasPin,
      isVerified: isVerified ?? this.isVerified,
      isHost: isHost ?? this.isHost,
      email: email ?? this.email,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phone,
        fullName,
        dateOfBirth,
        isMoroccan,
        nationality,
        countryOfCitizenship,
        profilePhotoUrl,
        hasPin,
        isVerified,
        isHost,
        email,
        onboardingStep,
        createdAt,
      ];
}
