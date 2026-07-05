// =============================================================================
// NexaStays Location Service
// =============================================================================
// Wrapper over `geolocator` and `geocoding` to handle device permissions,
// current coordinate fetching, and reverse geocoding to human-readable cities.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Centralised manager for device location and coordinate translation.
class LocationService {
  /// Checks and explicitly requests location permissions from the user.
  ///
  /// Returns `true` if permission is granted or restricted but usable
  /// (e.g. `whileInUse`). Returns `false` if explicitly denied permanently.
  Future<bool> requestPermission() async {
    try {
      // First check if location services are literally turned off on the phone
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode)
          print('⚠️ [LocationService] Device location services are disabled.');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode)
            print('⚠️ [LocationService] User denied location permission.');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode)
          print(
              '⚠️ [LocationService] Location permissions are permanently denied.');
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode)
        print('❌ [LocationService] Error requesting permission: $e');
      return false;
    }
  }

  /// Retrieves the device's high-accuracy current [Position].
  ///
  /// Automatically requests permission if not yet granted.
  /// Returns `null` if the user denies the request or if an error occurs.
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter:
              10, // Wait until user moves 10 meters before updating (if listening)
        ),
      );
    } catch (e) {
      if (kDebugMode) print('❌ [LocationService] Error fetching location: $e');
      return null;
    }
  }

  /// Reverse-geocodes a [Position] coordinate into a human-readable city string.
  ///
  /// Example return value: `"Marrakech, Morocco"`.
  /// Returns `null` if reverse-geocoding fails.
  Future<String?> getCityName(Position position) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Construct a clean location string. Some regions report `locality`
        // while others report `subAdministrativeArea`. We prioritize `locality`.
        final city =
            place.locality ?? place.subAdministrativeArea ?? place.name;
        final country = place.country;

        if (city != null && country != null) {
          return '$city, $country';
        } else if (city != null) {
          return city;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode)
        print('❌ [LocationService] Error computing city name: $e');
      return null;
    }
  }

  /// Calculates the straight-line distance (in meters) between two coordinates.
  ///
  /// Uses [Geolocator]'s built-in Vincenty formula implementation.
  double distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }
}
