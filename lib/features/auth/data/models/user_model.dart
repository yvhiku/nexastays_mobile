import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.phone,
    required super.fullName,
    required super.dateOfBirth,
    required super.isMoroccan,
    super.nationality,
    super.countryOfCitizenship,
    super.profilePhotoUrl,
    required super.hasPin,
    required super.isVerified,
    required super.isHost,
    super.email,
    required super.onboardingStep,
    required super.createdAt,
  });

  /// Maps [GET /users/me](https://api) payload from nexa_backend (Pay users module).
  factory UserModel.fromUsersMe(
    Map<String, dynamic> json, {
    required String phoneFallback,
  }) {
    final kyc = (json['kyc_status'] as String? ?? '').toUpperCase();
    final verified = kyc == 'APPROVED' || kyc == 'VERIFIED';
    final dobRaw = json['date_of_birth'];
    DateTime dob;
    if (dobRaw == null || dobRaw.toString().isEmpty) {
      dob = DateTime(2000, 1, 1);
    } else {
      dob = DateTime.tryParse(dobRaw.toString()) ?? DateTime(2000, 1, 1);
    }
    return UserModel(
      id: json['id'] as String? ?? '',
      phone: json['phone_number'] as String? ?? phoneFallback,
      fullName: json['full_name'] as String? ?? '',
      dateOfBirth: dob,
      isMoroccan: (json['nationality'] as String? ?? '') == 'MA',
      nationality: json['nationality'] as String?,
      countryOfCitizenship: null,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      hasPin: true,
      isVerified: verified,
      isHost: false,
      email: json['email'] as String?,
      onboardingStep:
          verified ? OnboardingStep.complete : OnboardingStep.personalInfo,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final kyc = (json['kyc_status'] as String? ?? '').toUpperCase();
    final verifiedFromKyc = kyc == 'APPROVED' || kyc == 'VERIFIED';
    final explicitVerified = json['is_verified'] as bool? ?? false;
    final isVerified = explicitVerified || verifiedFromKyc;
    return UserModel(
      id: json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String) ?? DateTime.now()
          : DateTime.now(),
      isMoroccan: json['is_moroccan'] as bool? ?? false,
      nationality: json['nationality'] as String?,
      countryOfCitizenship: json['country_of_citizenship'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      hasPin: json['has_pin'] as bool? ?? false,
      isVerified: isVerified,
      isHost: json['is_host'] as bool? ?? false,
      email: json['email'] as String?,
      onboardingStep: _parseStep(json['onboarding_step'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'is_moroccan': isMoroccan,
      'nationality': nationality,
      'country_of_citizenship': countryOfCitizenship,
      'profile_photo_url': profilePhotoUrl,
      'has_pin': hasPin,
      if (isVerified) 'kyc_status': 'VERIFIED',
      'is_verified': isVerified,
      'is_host': isHost,
      'email': email,
      'onboarding_step': _stepToString(onboardingStep),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      phone: user.phone,
      fullName: user.fullName,
      dateOfBirth: user.dateOfBirth,
      isMoroccan: user.isMoroccan,
      nationality: user.nationality,
      countryOfCitizenship: user.countryOfCitizenship,
      profilePhotoUrl: user.profilePhotoUrl,
      hasPin: user.hasPin,
      isVerified: user.isVerified,
      isHost: user.isHost,
      email: user.email,
      onboardingStep: user.onboardingStep,
      createdAt: user.createdAt,
    );
  }

  static OnboardingStep _parseStep(String? value) {
    switch (value) {
      case 'phone_entry':
        return OnboardingStep.phoneEntry;
      case 'otp_verify':
        return OnboardingStep.otpVerify;
      case 'personal_info':
        return OnboardingStep.personalInfo;
      case 'document_type':
        return OnboardingStep.documentType;
      case 'document_capture':
        return OnboardingStep.documentCapture;
      case 'pin_setup':
        return OnboardingStep.pinSetup;
      case 'complete':
        return OnboardingStep.complete;
      default:
        return OnboardingStep.phoneEntry;
    }
  }

  static String _stepToString(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.phoneEntry:
        return 'phone_entry';
      case OnboardingStep.otpVerify:
        return 'otp_verify';
      case OnboardingStep.personalInfo:
        return 'personal_info';
      case OnboardingStep.documentType:
        return 'document_type';
      case OnboardingStep.documentCapture:
        return 'document_capture';
      case OnboardingStep.pinSetup:
        return 'pin_setup';
      case OnboardingStep.complete:
        return 'complete';
    }
  }
}
