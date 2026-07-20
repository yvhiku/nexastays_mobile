import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

class PushTokenDataSource {
  PushTokenDataSource(this._client);

  final DioClient _client;

  Future<void> registerPushToken({
    required String token,
    required String platform,
    bool enabled = true,
  }) async {
    await _client.post(
      ApiEndpoints.pushToken,
      data: {
        'token': token,
        'platform': platform,
        'enabled': enabled,
      },
    );
  }

  Future<void> deactivatePushToken({String? token}) async {
    await _client.dio.delete(
      ApiEndpoints.pushToken,
      data: token != null ? {'token': token} : null,
    );
  }
}
