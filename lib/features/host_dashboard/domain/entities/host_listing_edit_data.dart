class HostListingEditData {
  const HostListingEditData({
    required this.id,
    required this.title,
    required this.listingType,
    required this.city,
    required this.neighborhood,
    required this.address,
    required this.description,
    required this.status,
    required this.checkInTime,
    required this.checkOutTime,
    required this.instantBooking,
    required this.basePrice,
    required this.weekendPrice,
    required this.cleaningFee,
    required this.currency,
    required this.maxGuests,
    required this.petsPolicy,
    required this.smokingPolicy,
    required this.amenities,
    required this.cancellationPolicy,
    required this.contactName,
    required this.contactPhone,
    required this.contactRole,
    required this.accessInstructions,
    required this.photoUrls,
    this.geoLat,
    this.geoLng,
  });

  final String id;
  final String title;
  final String listingType;
  final String city;
  final String neighborhood;
  final String address;
  final String description;
  final String status;
  final String checkInTime;
  final String checkOutTime;
  final bool instantBooking;
  final double basePrice;
  final double weekendPrice;
  final double cleaningFee;
  final String currency;
  final int maxGuests;
  final String petsPolicy;
  final String smokingPolicy;
  final List<String> amenities;
  final String cancellationPolicy;
  final String contactName;
  final String contactPhone;
  final String contactRole;
  final String accessInstructions;
  final List<String> photoUrls;
  final double? geoLat;
  final double? geoLng;

  bool get isPaused => status.toUpperCase() == 'PAUSED';
  bool get canPause {
    final s = status.toUpperCase();
    return s == 'LIVE' || s == 'APPROVED';
  }

  bool get canResume => isPaused;

  HostListingEditData copyWith({
    String? title,
    String? city,
    String? neighborhood,
    String? address,
    String? description,
    String? status,
    String? checkInTime,
    String? checkOutTime,
    double? basePrice,
    double? weekendPrice,
    double? cleaningFee,
    int? maxGuests,
    String? petsPolicy,
    String? smokingPolicy,
    List<String>? amenities,
    String? accessInstructions,
    double? geoLat,
    double? geoLng,
  }) {
    return HostListingEditData(
      id: id,
      title: title ?? this.title,
      listingType: listingType,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      address: address ?? this.address,
      description: description ?? this.description,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      instantBooking: instantBooking,
      basePrice: basePrice ?? this.basePrice,
      weekendPrice: weekendPrice ?? this.weekendPrice,
      cleaningFee: cleaningFee ?? this.cleaningFee,
      currency: currency,
      maxGuests: maxGuests ?? this.maxGuests,
      petsPolicy: petsPolicy ?? this.petsPolicy,
      smokingPolicy: smokingPolicy ?? this.smokingPolicy,
      amenities: amenities ?? this.amenities,
      cancellationPolicy: cancellationPolicy,
      contactName: contactName,
      contactPhone: contactPhone,
      contactRole: contactRole,
      accessInstructions: accessInstructions ?? this.accessInstructions,
      photoUrls: photoUrls,
      geoLat: geoLat ?? this.geoLat,
      geoLng: geoLng ?? this.geoLng,
    );
  }
}
