import 'package:equatable/equatable.dart';

enum HostOnboardingFlow {
  hostApplication,
  listingForApproval,
}

/// The single mutable state class representing the host onboarding flow.
///
/// Steps reference (10 visible steps — identity is reused from Sumsub KYC):
///   1: Host Type      2: Account    3: Contact
///   5: Property Basics  6: Amenities  7: Pricing
///   8: Check-in info  9: Photos     10: Video     11: Submit
class HostOnboardingState extends Equatable {
  const HostOnboardingState({
    this.currentStep = 1,
    this.flow = HostOnboardingFlow.hostApplication,
    this.hostType,
    this.propertyType,
    this.propertyName,
    this.city,
    this.neighborhood,
    this.exactAddress,
    this.beds = 1,
    this.bathrooms = 1,
    this.petsAllowed = false,
    this.smokingAllowed = false,
    this.eventsAllowed = false,
    this.suitableForInfants = true,
    this.quietHoursFrom = '22:00',
    this.quietHoursUntil = '08:00',
    this.maxGuests = 2,
    this.nightlyRate,
    this.weeklyDiscountPercent,
    this.monthlyDiscountPercent,
    this.minimumNights = 1,
    this.checkInContact,
    this.checkInInstructions,
    this.amenities = const [],
    this.photoPaths = const [],
    this.videoPath,
    this.checkInMethod,
    this.additionalRules,
    this.stepValidation = const {},
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  // Step tracking
  final int currentStep;
  final HostOnboardingFlow flow;
  final Map<int, bool> stepValidation;

  // Global state flags
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;

  // Form payload fields
  final String? hostType;
  final String? propertyType;
  final String? propertyName;
  final String? city;
  final String? neighborhood;
  final String? exactAddress;
  final int beds;
  final int bathrooms;
  final bool petsAllowed;
  final bool smokingAllowed;
  final bool eventsAllowed;
  final bool suitableForInfants;
  final String quietHoursFrom;
  final String quietHoursUntil;
  final int maxGuests;
  final double? nightlyRate;
  final double? weeklyDiscountPercent;
  final double? monthlyDiscountPercent;
  final int minimumNights;
  final String? checkInContact;
  final String? checkInInstructions;
  final List<String> amenities;
  final List<String> photoPaths;
  final String? videoPath;
  final String? checkInMethod;
  final String? additionalRules;

  /// Returns whether the current step is considered valid and ready to proceed.
  bool get isStepValid => stepValidation[currentStep] ?? false;

  bool get isListingFlow => flow == HostOnboardingFlow.listingForApproval;

  /// Step 4 (manual ID upload) is omitted — host apply requires Sumsub KYC upfront.
  List<int> get visibleSteps =>
      const [1, 2, 3, 5, 6, 7, 8, 9, 10, 11];

  int get totalSteps => visibleSteps.length;

  int get displayStepIndex {
    final idx = visibleSteps.indexOf(currentStep);
    return idx == -1 ? 1 : idx + 1;
  }

  int get firstVisibleStep => visibleSteps.first;
  int get lastVisibleStep => visibleSteps.last;
  bool get isLastStep => currentStep == lastVisibleStep;

  int? get nextStep {
    final idx = visibleSteps.indexOf(currentStep);
    if (idx == -1 || idx >= visibleSteps.length - 1) return null;
    return visibleSteps[idx + 1];
  }

  int? get previousStep {
    final idx = visibleSteps.indexOf(currentStep);
    if (idx <= 0) return null;
    return visibleSteps[idx - 1];
  }

  /// Validates that the most strictly required items across all steps are completed.
  /// (e.g. valid host identity, address, baseline pricing, minimum 12 photos, and a video)
  bool get allRequiredComplete =>
      hostType != null &&
      propertyName != null &&
      city != null &&
      nightlyRate != null &&
      photoPaths.length >= 12 &&
      videoPath != null;

  HostOnboardingState copyWith({
    int? currentStep,
    HostOnboardingFlow? flow,
    String? hostType,
    String? propertyType,
    String? propertyName,
    String? city,
    String? neighborhood,
    String? exactAddress,
    int? beds,
    int? bathrooms,
    bool? petsAllowed,
    bool? smokingAllowed,
    bool? eventsAllowed,
    bool? suitableForInfants,
    String? quietHoursFrom,
    String? quietHoursUntil,
    int? maxGuests,
    double? nightlyRate,
    double? weeklyDiscountPercent,
    double? monthlyDiscountPercent,
    int? minimumNights,
    String? checkInContact,
    String? checkInInstructions,
    List<String>? amenities,
    List<String>? photoPaths,
    String? videoPath,
    String? checkInMethod,
    String? additionalRules,
    Map<int, bool>? stepValidation,
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
  }) {
    return HostOnboardingState(
      currentStep: currentStep ?? this.currentStep,
      flow: flow ?? this.flow,
      hostType: hostType ?? this.hostType,
      propertyType: propertyType ?? this.propertyType,
      propertyName: propertyName ?? this.propertyName,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      exactAddress: exactAddress ?? this.exactAddress,
      beds: beds ?? this.beds,
      bathrooms: bathrooms ?? this.bathrooms,
      petsAllowed: petsAllowed ?? this.petsAllowed,
      smokingAllowed: smokingAllowed ?? this.smokingAllowed,
      eventsAllowed: eventsAllowed ?? this.eventsAllowed,
      suitableForInfants: suitableForInfants ?? this.suitableForInfants,
      quietHoursFrom: quietHoursFrom ?? this.quietHoursFrom,
      quietHoursUntil: quietHoursUntil ?? this.quietHoursUntil,
      maxGuests: maxGuests ?? this.maxGuests,
      nightlyRate: nightlyRate ?? this.nightlyRate,
      weeklyDiscountPercent: weeklyDiscountPercent ?? this.weeklyDiscountPercent,
      monthlyDiscountPercent: monthlyDiscountPercent ?? this.monthlyDiscountPercent,
      minimumNights: minimumNights ?? this.minimumNights,
      checkInContact: checkInContact ?? this.checkInContact,
      checkInInstructions: checkInInstructions ?? this.checkInInstructions,
      amenities: amenities ?? this.amenities,
      photoPaths: photoPaths ?? this.photoPaths,
      videoPath: videoPath ?? this.videoPath,
      checkInMethod: checkInMethod ?? this.checkInMethod,
      additionalRules: additionalRules ?? this.additionalRules,
      stepValidation: stepValidation ?? this.stepValidation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        flow,
        hostType,
        propertyType,
        propertyName,
        city,
        neighborhood,
        exactAddress,
        beds,
        bathrooms,
        petsAllowed,
        smokingAllowed,
        eventsAllowed,
        suitableForInfants,
        quietHoursFrom,
        quietHoursUntil,
        maxGuests,
        nightlyRate,
        weeklyDiscountPercent,
        monthlyDiscountPercent,
        minimumNights,
        checkInContact,
        checkInInstructions,
        amenities,
        photoPaths,
        videoPath,
        checkInMethod,
        additionalRules,
        stepValidation,
        isSubmitting,
        isSubmitted,
        errorMessage,
      ];
}
