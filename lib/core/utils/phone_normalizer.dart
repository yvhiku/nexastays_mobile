/// Normalizes user input to E.164-style Morocco numbers for API calls.
String normalizeMoroccoPhone(String raw) {
  String phone = raw.trim().replaceAll(RegExp(r'\s+'), '');
  if (phone.isEmpty) return phone;
  if (phone.startsWith('00')) {
    phone = '+${phone.substring(2)}';
  }
  if (phone.startsWith('0')) {
    phone = '+212${phone.substring(1)}';
  } else if (RegExp(r'^212\d+').hasMatch(phone) && !phone.startsWith('+')) {
    phone = '+$phone';
  } else if (!phone.startsWith('+')) {
    phone = '+212$phone';
  }
  // +2120612345678 (06… with country code) → +212612345678
  if (RegExp(r'^\+2120\d{9}$').hasMatch(phone)) {
    phone = '+212${phone.substring(5)}';
  }
  return phone;
}

/// Best-effort normalization for contact matching.
String? normalizeContactPhoneForMatch(String? raw) {
  if (raw == null) return null;
  final t = raw.trim().replaceAll(RegExp(r'[\s\-\.]'), '');
  if (t.isEmpty) return null;
  if (t.startsWith('+')) return normalizeMoroccoPhone(t);
  if (t.startsWith('00')) return normalizeMoroccoPhone(t);
  if (t.startsWith('0')) return normalizeMoroccoPhone(t);
  if (RegExp(r'^212').hasMatch(t)) return normalizeMoroccoPhone(t);
  if (RegExp(r'^[6-7]\d{8}$').hasMatch(t)) {
    return '+212$t';
  }
  if (RegExp(r'^\d{9,}$').hasMatch(t)) {
    return normalizeMoroccoPhone(t);
  }
  return null;
}
