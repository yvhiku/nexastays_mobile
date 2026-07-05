import 'package:equatable/equatable.dart';

// =============================================================================
// Host Preferences  (CANONICAL definition)
// =============================================================================

/// House rules, check-in policy, and amenity list chosen by a host during
/// onboarding (or later via property settings).
///
/// Other features that need [HostPreferences] should **import from here**
/// rather than defining their own copy.
class HostPreferences extends Equatable {
  const HostPreferences({
    this.petsAllowed = false,
    this.smokingAllowed = false,
    this.eventsAllowed = false,
    this.suitableForInfants = true,
    this.quietHoursFrom = '22:00',
    this.quietHoursUntil = '08:00',
    this.maxGuests = 2,
    this.additionalRules,
    this.checkInFrom = '14:00',
    this.checkOutBefore = '11:00',
    this.checkInMethod = 'self',
    this.amenities = const [],
  });

  /// Returns an instance with every field set to its default value.
  factory HostPreferences.defaults() => const HostPreferences();

  // ── Fields ──────────────────────────────────────────────────────────────

  final bool petsAllowed;
  final bool smokingAllowed;
  final bool eventsAllowed;
  final bool suitableForInfants;

  /// Start of quiet hours, e.g. `"22:00"`.
  final String quietHoursFrom;

  /// End of quiet hours, e.g. `"08:00"`.
  final String quietHoursUntil;

  final int maxGuests;

  /// Free-text additional rules set by the host.
  final String? additionalRules;

  /// Earliest check-in time, e.g. `"14:00"`.
  final String checkInFrom;

  /// Latest check-out time, e.g. `"11:00"`.
  final String checkOutBefore;

  /// One of `'self'`, `'host'`, `'smartlock'`, or `'reception'`.
  final String checkInMethod;

  final List<String> amenities;

  // ── Getters ─────────────────────────────────────────────────────────────

  /// Human-readable list of active house rules.
  List<String> get activeRuleLabels {
    final labels = <String>[];

    if (!petsAllowed) labels.add('No pets');
    if (!smokingAllowed) labels.add('No smoking');
    if (!eventsAllowed) labels.add('No events or parties');

    labels.add('Quiet after $quietHoursFrom');
    labels.add('Check-in from $checkInFrom');
    labels.add('Check-out before $checkOutBefore');
    labels.add('Max $maxGuests guests');

    if (additionalRules != null) labels.add(additionalRules!);

    return labels;
  }

  /// `true` when at least one of pets / smoking / events is disallowed.
  bool get hasRestrictiveRules =>
      !petsAllowed || !smokingAllowed || !eventsAllowed;

  // ── copyWith ────────────────────────────────────────────────────────────

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
    String? checkInMethod,
    List<String>? amenities,
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
      checkInMethod: checkInMethod ?? this.checkInMethod,
      amenities: amenities ?? this.amenities,
    );
  }

  // ── Equatable ───────────────────────────────────────────────────────────

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
        checkInMethod,
        amenities,
      ];
}
