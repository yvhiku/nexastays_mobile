/// Phone normalization for API calls (E.164).
/// Bare national digits / leading 0 default to Morocco (+212).
/// Numbers that already include `+` or `00` keep their country code.

final _e164 = RegExp(r'^\+[1-9]\d{7,14}$');

/// True when [phone] looks like a valid E.164 number.
bool isValidE164(String phone) => _e164.hasMatch(phone);

/// Normalizes user input to E.164.
/// Preserves an explicit international prefix (`+` / `00`).
String normalizePhone(String raw, {String defaultDialCode = '212'}) {
  var phone = raw.trim().replaceAll(RegExp(r'\s+'), '');
  if (phone.isEmpty) return phone;

  if (phone.startsWith('00')) {
    phone = '+${phone.substring(2)}';
  }

  if (phone.startsWith('+')) {
    phone = '+${phone.substring(1).replaceAll(RegExp(r'[^0-9]'), '')}';
    // +2120612345678 (06… with country code) → +212612345678
    if (RegExp(r'^\+2120\d{9}$').hasMatch(phone)) {
      phone = '+212${phone.substring(5)}';
    }
    return phone;
  }

  // Bare national → default country (Morocco unless overridden)
  if (phone.startsWith('0')) {
    phone = '+$defaultDialCode${phone.substring(1)}';
  } else if (RegExp(r'^212\d+').hasMatch(phone)) {
    phone = '+$phone';
  } else {
    phone = '+$defaultDialCode$phone';
  }

  if (RegExp(r'^\+2120\d{9}$').hasMatch(phone)) {
    phone = '+212${phone.substring(5)}';
  }
  return phone;
}

/// Legacy alias — prefers Morocco for bare digits; preserves `+` E.164.
String normalizeMoroccoPhone(String raw) => normalizePhone(raw);

/// Best-effort normalization for contact matching.
String? normalizeContactPhoneForMatch(String? raw) {
  if (raw == null) return null;
  final t = raw.trim().replaceAll(RegExp(r'[\s\-\.]'), '');
  if (t.isEmpty) return null;
  if (t.startsWith('+')) return normalizePhone(t);
  if (t.startsWith('00')) return normalizePhone(t);
  if (t.startsWith('0')) return normalizePhone(t);
  if (RegExp(r'^212').hasMatch(t)) return normalizePhone(t);
  if (RegExp(r'^[6-7]\d{8}$').hasMatch(t)) {
    return '+212$t';
  }
  if (RegExp(r'^\d{9,}$').hasMatch(t)) {
    return normalizePhone(t);
  }
  return null;
}
