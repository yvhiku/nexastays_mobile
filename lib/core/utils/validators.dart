// =============================================================================
// NexaStays Input Validators
// =============================================================================
// Standalone validator functions used in form fields across the app.
// Each returns `null` if the input is valid, or a localised error string
// if it fails validation.
// =============================================================================

import 'package:nexa_stays_f/core/extensions/string_ext.dart';

/// Form-field validation helpers.
class Validators {
  Validators._();

  /// Validates an email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    if (!value.trim().isEmail) {
      return 'Please enter a valid email address';
    }

    return null; // valid
  }

  /// Validates a password against complexity rules:
  /// - Minimum 8 characters
  /// - At least 1 uppercase letter
  /// - At least 1 number
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null; // valid
  }

  /// Validates a human name (first, last, or full).
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    // Optional: block numbers/special chars if strictly required.
    // For now, ensuring it's not empty/single-char is usually enough.
    return null; // valid
  }

  /// Validates an international phone number.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    if (!value.trim().isPhone) {
      return 'Please enter a valid phone number';
    }

    return null; // valid
  }
}
