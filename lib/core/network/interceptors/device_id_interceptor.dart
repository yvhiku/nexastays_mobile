import 'package:dio/dio.dart';

import '../../device/device_id_service.dart';

/// Attaches stable `x-device-id` on identity requests.
class DeviceIdInterceptor extends Interceptor {
  DeviceIdInterceptor({DeviceIdService? deviceIdService})
      : _deviceIdService = deviceIdService ?? DeviceIdService();

  final DeviceIdService _deviceIdService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final deviceId = await _deviceIdService.getDeviceId();
      options.headers['x-device-id'] = deviceId;
    } catch (_) {
      /* proceed without device id */
    }
    handler.next(options);
  }
}
