import 'package:equatable/equatable.dart';

import '../../listing_wizard/listing_step_config.dart';

/// Base event class for the Host Onboarding BLoC.
sealed class HostOnboardingEvent extends Equatable {
  const HostOnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user navigates between the 11 onboarding steps.
class HostStepChanged extends HostOnboardingEvent {
  const HostStepChanged({required this.step});

  final int step;

  @override
  List<Object?> get props => [step];
}

/// Dispatched when the user selects their host category
/// ('individual' | 'portfolio' | 'hotel' | 'partner').
class HostTypeSelected extends HostOnboardingEvent {
  const HostTypeSelected({required this.hostType});

  final String hostType;

  @override
  List<Object?> get props => [hostType];
}

/// Dispatched when the host's account information is saved.
class HostAccountInfoSaved extends HostOnboardingEvent {
  const HostAccountInfoSaved({
    required this.fullName,
    required this.phone,
    required this.email,
  });

  final String fullName;
  final String phone;
  final String email;

  @override
  List<Object?> get props => [fullName, phone, email];
}

/// Dispatched when the property type is selected.
class HostPropertyTypeSaved extends HostOnboardingEvent {
  const HostPropertyTypeSaved({required this.propertyType});

  final String propertyType;

  @override
  List<Object?> get props => [propertyType];
}

class HostBookingModelSaved extends HostOnboardingEvent {
  const HostBookingModelSaved({required this.bookingModel});

  final String bookingModel;

  @override
  List<Object?> get props => [bookingModel];
}

class HostListingDetailsSaved extends HostOnboardingEvent {
  const HostListingDetailsSaved({
    required this.description,
    required this.maxGuests,
    required this.beds,
    required this.bathrooms,
    this.sizeSqm,
    this.propertyDetails = const {},
  });

  final String description;
  final int maxGuests;
  final int beds;
  final int bathrooms;
  final double? sizeSqm;
  final Map<String, Object?> propertyDetails;

  @override
  List<Object?> get props => [
        description,
        maxGuests,
        beds,
        bathrooms,
        sizeSqm,
        propertyDetails,
      ];
}

class HostUnitTypesSaved extends HostOnboardingEvent {
  const HostUnitTypesSaved({required this.unitTypes});

  final List<ListingUnitDraft> unitTypes;

  @override
  List<Object?> get props => [unitTypes];
}

/// Dispatched when the secondary contact info is saved.
class HostContactSaved extends HostOnboardingEvent {
  const HostContactSaved({
    required this.whatsapp,
    required this.checkInContact,
    required this.checkInInstructions,
  });

  final String whatsapp;
  final String checkInContact;
  final String checkInInstructions;

  @override
  List<Object?> get props => [whatsapp, checkInContact, checkInInstructions];
}

/// Dispatched when the physical basics of the property are defined.
class HostBasicsSaved extends HostOnboardingEvent {
  const HostBasicsSaved({
    required this.propertyName,
    required this.city,
    required this.neighborhood,
    required this.exactAddress,
    required this.beds,
    required this.bathrooms,
    this.geoLat,
    this.geoLng,
  });

  final String propertyName;
  final String city;
  final String neighborhood;
  final String exactAddress;
  final int beds;
  final int bathrooms;
  final double? geoLat;
  final double? geoLng;

  @override
  List<Object?> get props => [
        propertyName,
        city,
        neighborhood,
        exactAddress,
        beds,
        bathrooms,
        geoLat,
        geoLng,
      ];
}

/// Dispatched when the host sets house rules.
class HostRulesSaved extends HostOnboardingEvent {
  const HostRulesSaved({
    required this.petsAllowed,
    required this.smokingAllowed,
    required this.quietHours,
    required this.maxGuests,
  });

  final bool petsAllowed;
  final bool smokingAllowed;
  final String quietHours;
  final int maxGuests;

  @override
  List<Object?> get props => [
        petsAllowed,
        smokingAllowed,
        quietHours,
        maxGuests,
      ];
}

/// Dispatched when pricing constraints are set.
class HostPricingSaved extends HostOnboardingEvent {
  const HostPricingSaved({
    required this.nightlyRate,
  });

  final double nightlyRate;

  @override
  List<Object?> get props => [nightlyRate];
}

/// Dispatched when discount settings are saved.
class HostDiscountsSaved extends HostOnboardingEvent {
  const HostDiscountsSaved({
    this.weeklyDiscountPercent,
    this.monthlyDiscountPercent,
    required this.minimumNights,
  });

  final double? weeklyDiscountPercent;
  final double? monthlyDiscountPercent;
  final int minimumNights;

  @override
  List<Object?> get props => [
        weeklyDiscountPercent,
        monthlyDiscountPercent,
        minimumNights,
      ];
}

/// Dispatched when check-in logistics and house rules are updated.
class HostCheckInSaved extends HostOnboardingEvent {
  const HostCheckInSaved({
    required this.petsAllowed,
    required this.smokingAllowed,
    required this.eventsAllowed,
    required this.suitableForInfants,
    required this.quietHoursFrom,
    required this.quietHoursUntil,
    required this.maxGuests,
    required this.checkInMethod,
    this.additionalRules,
  });

  final bool petsAllowed;
  final bool smokingAllowed;
  final bool eventsAllowed;
  final bool suitableForInfants;
  final String quietHoursFrom;
  final String quietHoursUntil;
  final int maxGuests;
  final String checkInMethod;
  final String? additionalRules;

  @override
  List<Object?> get props => [
        petsAllowed,
        smokingAllowed,
        eventsAllowed,
        suitableForInfants,
        quietHoursFrom,
        quietHoursUntil,
        maxGuests,
        checkInMethod,
        additionalRules,
      ];
}

/// Dispatched when property amenities are saved.
class HostAmenitiesSaved extends HostOnboardingEvent {
  const HostAmenitiesSaved({required this.amenities});

  final List<String> amenities;

  @override
  List<Object?> get props => [amenities];
}

/// Dispatched when property photos are uploaded.
class HostPhotosSaved extends HostOnboardingEvent {
  const HostPhotosSaved({required this.photoPaths});

  final List<String> photoPaths;

  @override
  List<Object?> get props => [photoPaths];
}

/// Dispatched when an optional property video is added.
class HostVideoSaved extends HostOnboardingEvent {
  const HostVideoSaved({required this.videoPath});

  final String videoPath;

  @override
  List<Object?> get props => [videoPath];
}

/// Dispatched when the user explicitly reaches the end and submits the listing.
class HostSubmitRequested extends HostOnboardingEvent {
  const HostSubmitRequested();
}

/// Dispatched internally or via form inputs to indicate validity for the current step.
class HostStepValidated extends HostOnboardingEvent {
  const HostStepValidated({
    required this.step,
    required this.isValid,
  });

  final int step;
  final bool isValid;

  @override
  List<Object?> get props => [step, isValid];
}
