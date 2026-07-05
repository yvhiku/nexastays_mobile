import 'package:flutter_bloc/flutter_bloc.dart';

import 'host_onboarding_event.dart';
import 'host_onboarding_state.dart';

// TODO: Replace with actual domain repository once created
abstract class HostRepository {
  Future<void> submitProperty(HostOnboardingState state);
}

/// BLoC managing the 10-step host onboarding flow (identity reused from Sumsub KYC).
class HostOnboardingBloc
    extends Bloc<HostOnboardingEvent, HostOnboardingState> {
  HostOnboardingBloc({
    required this.hostRepository,
    HostOnboardingFlow flow = HostOnboardingFlow.hostApplication,
  }) : super(HostOnboardingState(flow: flow)) {
    on<HostStepChanged>(_onStepChanged);
    on<HostTypeSelected>(_onTypeSelected);
    on<HostAccountInfoSaved>(_onAccountInfoSaved);
    on<HostPropertyTypeSaved>(_onPropertyTypeSaved);
    on<HostContactSaved>(_onContactSaved);
    on<HostBasicsSaved>(_onBasicsSaved);
    on<HostRulesSaved>(_onRulesSaved);
    on<HostPricingSaved>(_onPricingSaved);
    on<HostDiscountsSaved>(_onDiscountsSaved);
    on<HostCheckInSaved>(_onCheckInSaved);
    on<HostAmenitiesSaved>(_onAmenitiesSaved);
    on<HostPhotosSaved>(_onPhotosSaved);
    on<HostVideoSaved>(_onVideoSaved);
    on<HostSubmitRequested>(_onSubmitRequested);
    on<HostStepValidated>(_onStepValidated);
  }

  final HostRepository hostRepository;

  void _onStepChanged(
    HostStepChanged event,
    Emitter<HostOnboardingState> emit,
  ) {
    if (!state.visibleSteps.contains(event.step)) {
      return;
    }
    // If moving forward, require current step to be valid first.
    final currentIdx = state.visibleSteps.indexOf(state.currentStep);
    final nextIdx = state.visibleSteps.indexOf(event.step);
    if (nextIdx > currentIdx) {
      if (!state.isStepValid) {
        emit(state.copyWith(
          errorMessage: 'Please complete this step before continuing.',
        ));
        // Clear the error message so it doesn't persist
        emit(state.copyWith(errorMessage: null));
        return;
      }
    }

    emit(state.copyWith(currentStep: event.step));
  }

  void _onTypeSelected(
    HostTypeSelected event,
    Emitter<HostOnboardingState> emit,
  ) {
    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    updatedValidation[1] = true;

    emit(state.copyWith(
      hostType: event.hostType,
      stepValidation: updatedValidation,
    ));
  }

  void _onAccountInfoSaved(
    HostAccountInfoSaved event,
    Emitter<HostOnboardingState> emit,
  ) {
    final bool isValid = event.fullName.isNotEmpty &&
        event.phone.isNotEmpty &&
        event.email.isNotEmpty;

    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    updatedValidation[2] = isValid;

    // We assume account info is saved globally or handled here as needed.
    // The state object doesn't currently hold fullName/phone/email,
    // so we just validate the step for now.
    emit(state.copyWith(stepValidation: updatedValidation));
  }

  void _onPropertyTypeSaved(
    HostPropertyTypeSaved event,
    Emitter<HostOnboardingState> emit,
  ) {
    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    updatedValidation[5] = true; // Assuming Type is part of basics (step 5)

    emit(state.copyWith(
      propertyType: event.propertyType,
      stepValidation: updatedValidation,
    ));
  }

  void _onContactSaved(
    HostContactSaved event,
    Emitter<HostOnboardingState> emit,
  ) {
    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    updatedValidation[3] = event.whatsapp.isNotEmpty || event.checkInContact.isNotEmpty;

    emit(state.copyWith(
      checkInContact: event.checkInContact,
      checkInInstructions: event.checkInInstructions,
      stepValidation: updatedValidation,
    ));
  }

  void _onBasicsSaved(
    HostBasicsSaved event,
    Emitter<HostOnboardingState> emit,
  ) {
    final bool isValid = event.propertyName.isNotEmpty &&
        event.city.isNotEmpty &&
        event.neighborhood.isNotEmpty &&
        event.exactAddress.isNotEmpty;

    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    updatedValidation[5] = isValid; // Step 5: Property Basics

    emit(state.copyWith(
      propertyName: event.propertyName,
      city: event.city,
      neighborhood: event.neighborhood,
      exactAddress: event.exactAddress,
      beds: event.beds,
      bathrooms: event.bathrooms,
      stepValidation: updatedValidation,
    ));
  }

  void _onRulesSaved(
    HostRulesSaved event,
    Emitter<HostOnboardingState> emit,
  ) {
    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    updatedValidation[6] = true; // Step 6: Amenities/Rules

    emit(state.copyWith(
      petsAllowed: event.petsAllowed,
      smokingAllowed: event.smokingAllowed,
      maxGuests: event.maxGuests,
      stepValidation: updatedValidation,
    ));
  }

  void _onPricingSaved(
    HostPricingSaved event,
    Emitter<HostOnboardingState> emit,
  ) {
    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    updatedValidation[7] = event.nightlyRate > 0; // Step 7: Pricing

    emit(state.copyWith(
      nightlyRate: event.nightlyRate,
      stepValidation: updatedValidation,
    ));
  }

  void _onDiscountsSaved(
    HostDiscountsSaved event,
    Emitter<HostOnboardingState> emit,
  ) {
    emit(state.copyWith(
      weeklyDiscountPercent: event.weeklyDiscountPercent,
      monthlyDiscountPercent: event.monthlyDiscountPercent,
      minimumNights: event.minimumNights,
    ));
  }

  void _onCheckInSaved(
    HostCheckInSaved event,
    Emitter<HostOnboardingState> emit,
  ) {
    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    // Requires checkInMethod and a valid maxGuests.
    final isValid = event.checkInMethod.isNotEmpty && event.maxGuests > 0;
    updatedValidation[8] = isValid; // Step 8: Check-in

    emit(state.copyWith(
      petsAllowed: event.petsAllowed,
      smokingAllowed: event.smokingAllowed,
      eventsAllowed: event.eventsAllowed,
      suitableForInfants: event.suitableForInfants,
      quietHoursFrom: event.quietHoursFrom,
      quietHoursUntil: event.quietHoursUntil,
      maxGuests: event.maxGuests,
      checkInMethod: event.checkInMethod,
      additionalRules: event.additionalRules,
      stepValidation: updatedValidation,
    ));
  }

  void _onAmenitiesSaved(
    HostAmenitiesSaved event,
    Emitter<HostOnboardingState> emit,
  ) {
    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    updatedValidation[6] = event.amenities.isNotEmpty;

    emit(state.copyWith(
      amenities: event.amenities,
      stepValidation: updatedValidation,
    ));
  }

  void _onPhotosSaved(
    HostPhotosSaved event,
    Emitter<HostOnboardingState> emit,
  ) {
    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    // Requires at least 12 photos as per spec
    updatedValidation[9] = event.photoPaths.length >= 12;

    emit(state.copyWith(
      photoPaths: event.photoPaths,
      stepValidation: updatedValidation,
    ));
  }

  void _onVideoSaved(
    HostVideoSaved event,
    Emitter<HostOnboardingState> emit,
  ) {
    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    updatedValidation[10] = event.videoPath.isNotEmpty;

    emit(state.copyWith(
      videoPath: event.videoPath,
      stepValidation: updatedValidation,
    ));
  }

  void _onStepValidated(
    HostStepValidated event,
    Emitter<HostOnboardingState> emit,
  ) {
    final updatedValidation = Map<int, bool>.from(state.stepValidation);
    updatedValidation[event.step] = event.isValid;

    emit(state.copyWith(stepValidation: updatedValidation));
  }

  Future<void> _onSubmitRequested(
    HostSubmitRequested event,
    Emitter<HostOnboardingState> emit,
  ) async {
    if (!state.allRequiredComplete) {
      emit(state.copyWith(
          errorMessage: 'Cannot submit: Required fields are missing.'));
      emit(state.copyWith(errorMessage: null));
      return;
    }

    emit(state.copyWith(isSubmitting: true));

    try {
      await hostRepository.submitProperty(state);
      emit(state.copyWith(isSubmitting: false, isSubmitted: true));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit property: ${e.toString()}',
      ));
    }
  }
}
