import 'dart:math';

import '../storage/secure_storage.dart';

/// Persists a stable device identifier for `x-device-id` headers.
class DeviceIdService {
  DeviceIdService({SecureStorageService? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorageService();

  static const _storageKey = 'nexastays_device_id';

  final SecureStorageService _secureStorage;
  String? _cached;

  Future<String> getDeviceId() async {
    if (_cached != null && _cached!.isNotEmpty) {
      return _cached!;
    }
    var id = await _secureStorage.read(_storageKey);
    if (id == null || id.isEmpty) {
      id = _generateUuidV4();
      await _secureStorage.write(_storageKey, id);
    }
    _cached = id;
    return id;
  }

  String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final s = bytes.map(hex).join();
    return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
  }
}
