import 'package:equatable/equatable.dart';

class HostPreferences extends Equatable {
  final bool petsAllowed;
  final bool smokingAllowed;
  final bool eventsAllowed;
  final bool suitableForInfants;
  final String quietHoursFrom;
  final String quietHoursUntil;
  final int maxGuests;
  final String? additionalRules;
  final String checkInFrom;
  final String checkOutBefore;

  const HostPreferences({
    this.petsAllowed = false,
    this.smokingAllowed = false,
    this.eventsAllowed = false,
    this.suitableForInfants = true,
    this.quietHoursFrom = "22:00",
    this.quietHoursUntil = "08:00",
    this.maxGuests = 2,
    this.additionalRules,
    required this.checkInFrom,
    required this.checkOutBefore,
  });

  List<String> get activeRules {
    final rules = <String>[];
    if (!petsAllowed) rules.add("No pets");
    if (!smokingAllowed) rules.add("No smoking");
    if (!eventsAllowed) rules.add("No events");
    if (!suitableForInfants) rules.add("Not suitable for infants");
    rules.add("Quiet after $quietHoursFrom until $quietHoursUntil");
    rules.add("Check-in from $checkInFrom");
    rules.add("Check-out before $checkOutBefore");
    rules.add("Maximum $maxGuests guests");
    if (additionalRules != null && additionalRules!.isNotEmpty) {
      rules.add(additionalRules!);
    }
    return rules;
  }

  bool get hasRestrictiveRules => !petsAllowed || !smokingAllowed || !eventsAllowed;

  HostPreferences copyWith({
    bool? petsAllowed,
    bool? smokingAllowed,
    bool? eventsAllowed,
    bool? suitableForInfants,
    String? quietHoursFrom,
    String? quietHoursUntil,
    int? maxGuests,
    String? additionalRules,
    String? checkInFrom,
    String? checkOutBefore,
  }) {
    return HostPreferences(
      petsAllowed: petsAllowed ?? this.petsAllowed,
      smokingAllowed: smokingAllowed ?? this.smokingAllowed,
      eventsAllowed: eventsAllowed ?? this.eventsAllowed,
      suitableForInfants: suitableForInfants ?? this.suitableForInfants,
      quietHoursFrom: quietHoursFrom ?? this.quietHoursFrom,
      quietHoursUntil: quietHoursUntil ?? this.quietHoursUntil,
      maxGuests: maxGuests ?? this.maxGuests,
      additionalRules: additionalRules ?? this.additionalRules,
      checkInFrom: checkInFrom ?? this.checkInFrom,
      checkOutBefore: checkOutBefore ?? this.checkOutBefore,
    );
  }

  @override
  List<Object?> get props => [
        petsAllowed,
        smokingAllowed,
        eventsAllowed,
        suitableForInfants,
        quietHoursFrom,
        quietHoursUntil,
        maxGuests,
        additionalRules,
        checkInFrom,
        checkOutBefore,
      ];
}
