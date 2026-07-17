import 'package:equatable/equatable.dart';

abstract final class ListingStepIds {
  static const propertyType = 1;
  static const bookingModel = 12;
  static const location = 5;
  static const details = 13;
  static const unitTypes = 14;
  static const amenities = 6;
  static const policies = 8;
  static const pricing = 7;
  static const photos = 9;
  static const video = 10;
  static const review = 11;
}

class ListingStepDefinition {
  const ListingStepDefinition(this.id, this.label);

  final int id;
  final String label;
}

class BookingModelOption {
  const BookingModelOption({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

class ListingUnitDraft extends Equatable {
  const ListingUnitDraft({
    required this.id,
    required this.kind,
    required this.name,
    this.quantity = 1,
    this.maxGuests = 2,
    this.bedConfig = '1 double bed',
    this.sizeSqm,
    this.basePrice = 0,
    this.pricingUnit = 'ROOM_NIGHT',
    this.details = const {},
  });

  final String id;
  final String kind;
  final String name;
  final int quantity;
  final int maxGuests;
  final String bedConfig;
  final double? sizeSqm;
  final double basePrice;
  final String pricingUnit;
  final Map<String, Object?> details;

  ListingUnitDraft copyWith({
    String? kind,
    String? name,
    int? quantity,
    int? maxGuests,
    String? bedConfig,
    double? sizeSqm,
    double? basePrice,
    String? pricingUnit,
    Map<String, Object?>? details,
  }) {
    return ListingUnitDraft(
      id: id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      maxGuests: maxGuests ?? this.maxGuests,
      bedConfig: bedConfig ?? this.bedConfig,
      sizeSqm: sizeSqm ?? this.sizeSqm,
      basePrice: basePrice ?? this.basePrice,
      pricingUnit: pricingUnit ?? this.pricingUnit,
      details: details ?? this.details,
    );
  }

  Map<String, Object?> toApiJson(int sortOrder) => {
        'kind': kind,
        'name': name.trim(),
        'quantity': quantity,
        'max_guests': maxGuests,
        'bed_config': [
          {'summary': bedConfig.trim()}
        ],
        if (sizeSqm != null) 'size_sqm': sizeSqm,
        'amenities': const <String>[],
        'pricing_unit': pricingUnit,
        'base_price': basePrice,
        'currency': 'MAD',
        'details': details,
        'sort_order': sortOrder,
        'is_active': true,
      };

  @override
  List<Object?> get props => [
        id,
        kind,
        name,
        quantity,
        maxGuests,
        bedConfig,
        sizeSqm,
        basePrice,
        pricingUnit,
        details,
      ];
}

const listingTypes = ['APARTMENT', 'VILLA', 'RIAD', 'HOTEL', 'HOSTEL'];

List<BookingModelOption> bookingModelOptions(String type) {
  switch (type) {
    case 'APARTMENT':
    case 'VILLA':
      return const [
        BookingModelOption(
          id: 'ENTIRE_PROPERTY',
          title: 'Entire place',
          subtitle: 'Guests get the whole property to themselves.',
        ),
        BookingModelOption(
          id: 'PRIVATE_ROOM',
          title: 'Private room',
          subtitle: 'Guests book one bedroom; some spaces may be shared.',
        ),
        BookingModelOption(
          id: 'MULTI_UNIT',
          title: 'Several similar units',
          subtitle: 'Manage similar apartments or villas in one listing.',
        ),
      ];
    case 'RIAD':
      return const [
        BookingModelOption(
          id: 'ENTIRE_PROPERTY',
          title: 'Entire riad',
          subtitle: 'One booking reserves the full riad.',
        ),
        BookingModelOption(
          id: 'ROOM_TYPES',
          title: 'Individual rooms',
          subtitle: 'Guests book room categories with quantities.',
        ),
        BookingModelOption(
          id: 'BOTH',
          title: 'Entire riad and rooms',
          subtitle: 'Offer both booking structures.',
        ),
      ];
    case 'HOTEL':
      return const [
        BookingModelOption(
          id: 'ROOM_TYPES',
          title: 'Hotel room types',
          subtitle: 'Add categories such as Standard, Deluxe, and Suite.',
        ),
      ];
    default:
      return const [
        BookingModelOption(
          id: 'DORM_BEDS',
          title: 'Dorm beds only',
          subtitle: 'Price is per shared dorm bed, per night.',
        ),
        BookingModelOption(
          id: 'PRIVATE_ROOMS',
          title: 'Private rooms only',
          subtitle: 'Price is per private room, per night.',
        ),
        BookingModelOption(
          id: 'DORM_AND_PRIVATE',
          title: 'Dorms and private rooms',
          subtitle: 'Offer both kinds under one property.',
        ),
      ];
  }
}

bool isMultiUnitFlow(String? type, String? model) {
  if (type == null || model == null) return false;
  return type == 'HOTEL' ||
      type == 'HOSTEL' ||
      (type == 'RIAD' && (model == 'ROOM_TYPES' || model == 'BOTH')) ||
      model == 'MULTI_UNIT';
}

List<ListingStepDefinition> listingStepsFor(String? type, String? model) {
  const typeStep = ListingStepDefinition(
    ListingStepIds.propertyType,
    'Type',
  );
  const bookingStep = ListingStepDefinition(
    ListingStepIds.bookingModel,
    'Booking',
  );
  if (type == null) return const [typeStep];
  if (model == null) return const [typeStep, bookingStep];

  final detailsLabel = switch (type) {
    'HOTEL' => 'Hotel',
    'HOSTEL' => 'Hostel',
    'VILLA' => 'Villa',
    'RIAD' => 'Riad',
    _ => 'Details',
  };
  final unitLabel = switch (type) {
    'HOTEL' => 'Rooms',
    'HOSTEL' => 'Beds',
    'RIAD' => 'Rooms',
    _ => 'Units',
  };

  return [
    typeStep,
    bookingStep,
    const ListingStepDefinition(ListingStepIds.location, 'Location'),
    ListingStepDefinition(ListingStepIds.details, detailsLabel),
    if (isMultiUnitFlow(type, model))
      ListingStepDefinition(ListingStepIds.unitTypes, unitLabel),
    const ListingStepDefinition(ListingStepIds.amenities, 'Amenities'),
    const ListingStepDefinition(ListingStepIds.policies, 'Policies'),
    const ListingStepDefinition(ListingStepIds.pricing, 'Pricing'),
    const ListingStepDefinition(ListingStepIds.photos, 'Media'),
    const ListingStepDefinition(ListingStepIds.video, 'Media'),
    const ListingStepDefinition(ListingStepIds.review, 'Submit'),
  ];
}

String defaultUnitKind(String type, String model) {
  if (type == 'HOSTEL') {
    return model == 'PRIVATE_ROOMS' ? 'HOSTEL_PRIVATE' : 'HOSTEL_DORM';
  }
  return switch (type) {
    'HOTEL' => 'HOTEL_ROOM',
    'RIAD' => 'RIAD_ROOM',
    'VILLA' => 'VILLA_UNIT',
    _ => 'APARTMENT_UNIT',
  };
}

String defaultPricingUnit(String kind) =>
    kind == 'HOSTEL_DORM' ? 'BED_NIGHT' : 'ROOM_NIGHT';
