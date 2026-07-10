import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/storage/local_storage.dart';
import '../../presentation/bloc/host_onboarding_bloc.dart';
import '../../presentation/bloc/host_onboarding_state.dart';

/// Submits the Nexa Stays host wizard to the backend so ops can review it.
///
/// Backend: `POST /stays/host/onboarding` (or compat `/stays/host/apply`) →
/// `stays_host_profiles`. Listing creation is separate and requires approved host.
class StaysHostOnboardingRepository implements HostRepository {
  StaysHostOnboardingRepository({
    required DioClient dioClient,
    required SessionManager sessionManager,
    required LocalStorage localStorage,
  })  : _client = dioClient,
        _session = sessionManager,
        _local = localStorage;

  final DioClient _client;
  final SessionManager _session;
  final LocalStorage _local;

  @override
  Future<void> submitProperty(HostOnboardingState state) async {
    if (state.isListingFlow) {
      await _submitListingForApproval(state);
      return;
    }
    await _submitHostOnboarding(state);
  }

  Future<void> _submitHostOnboarding(HostOnboardingState state) async {
    final userId = _session.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception('Please sign in to submit your host application.');
    }

    var fullName = '';
    String? email;
    final cached = await _local.getString('cached_user');
    if (cached != null && cached.isNotEmpty) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        fullName = (map['full_name'] as String? ?? '').trim();
        final e = map['email'] as String?;
        if (e != null && e.trim().isNotEmpty) email = e.trim();
      } catch (_) {}
    }

    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.staysHostOnboarding,
        data: <String, dynamic>{
          'hosting_policies_accepted': true,
          'identity_reused': true,
          'use_existing_kyc': true,
          'source': 'MOBILE',
          'submitted_from': 'MOBILE_BECOME_HOST',
          if (fullName.isNotEmpty) 'full_name': fullName,
          if (email != null) 'email': email,
          if (state.city != null && state.city!.isNotEmpty) 'city': state.city,
          if (state.hostType != null && state.hostType!.isNotEmpty)
            'host_type': state.hostType,
        },
      );
      final code = response.statusCode ?? 500;
      if (code >= 300) {
        throw _messageFromResponse(response.data);
      }
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    }
  }

  Future<void> _submitListingForApproval(HostOnboardingState state) async {
    final userId = _session.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception('Please sign in to submit your property listing.');
    }
    if (state.photoPaths.length < 12) {
      throw Exception('Please upload at least 12 photos.');
    }
    if (state.videoPath == null || state.videoPath!.isEmpty) {
      throw Exception('Please upload a walkthrough video.');
    }

    try {
      var fullName = 'Host';
      var phone = '';
      final cached = await _local.getString('cached_user');
      if (cached != null && cached.isNotEmpty) {
        try {
          final map = jsonDecode(cached) as Map<String, dynamic>;
          fullName = (map['full_name'] as String? ?? 'Host').trim();
          phone = (map['phone_number'] as String? ?? '').trim();
        } catch (_) {}
      }

      final photoAssets = <Map<String, dynamic>>[];
      for (var i = 0; i < state.photoPaths.length; i++) {
        final path = state.photoPaths[i];
        final assetId = await _uploadAsset(path, kind: 'PHOTO');
        photoAssets.add({
          'asset_id': assetId,
          'kind': 'PHOTO',
          'sort_order': i,
        });
      }
      final walkthroughAsset = await _uploadAsset(
        state.videoPath!,
        kind: 'WALKTHROUGH',
      );

      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiEndpoints.staysHostListings,
        data: <String, dynamic>{
          'title': state.propertyName ?? 'Untitled Property',
          'description':
              'Submitted from mobile host listing flow for admin approval.',
          'city': state.city ?? '',
          'address': state.exactAddress ?? '',
          'listing_type': _toListingType(state.propertyType),
          'checkin_time': state.quietHoursUntil,
          'checkout_time': state.quietHoursFrom,
          'instant_booking': false,
          'rate_plan': {
            'base_price': state.nightlyRate ?? 0,
            'cleaning_fee': 0,
            'currency': 'MAD',
          },
          'rules': {
            'max_guests': state.maxGuests,
            'pets_policy': state.petsAllowed ? 'ALLOWED' : 'NO',
            'smoking_policy': state.smokingAllowed ? 'ALLOWED' : 'NOT_ALLOWED',
            'quiet_hours': true,
            'couples_welcome': true,
            'amenities': state.amenities,
          },
          'check_in_contact': {
            'full_name': fullName.isEmpty ? 'Host' : fullName,
            'phone': phone.isEmpty ? '+212000000000' : phone,
            'role': 'OWNER',
          },
          'media': [
            ...photoAssets,
            {
              'asset_id': walkthroughAsset,
              'kind': 'WALKTHROUGH',
              'sort_order': state.photoPaths.length,
            }
          ],
        },
      );
      final code = response.statusCode ?? 500;
      if (code >= 300) {
        throw _messageFromResponse(response.data);
      }
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    }
  }

  Future<String> _uploadAsset(
    String filePath, {
    required String kind,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw Exception('Media file not found: $filePath');
    }
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split(Platform.pathSeparator).last,
      ),
    });
    final response = await _client.dio.post<Map<String, dynamic>>(
      kind == 'WALKTHROUGH'
          ? ApiEndpoints.staysHostListingWalkthroughUpload
          : ApiEndpoints.staysHostListingPhotoUpload,
      data: formData,
    );
    final payload = response.data ?? const <String, dynamic>{};
    final data =
        payload['data'] is Map<String, dynamic> ? payload['data'] as Map<String, dynamic> : payload;
    final assetId = (data['asset_id'] ?? data['id'] ?? data['file_id'])?.toString();
    if (assetId == null || assetId.isEmpty) {
      throw Exception('Invalid media upload response.');
    }
    return assetId;
  }

  String _toListingType(String? raw) {
    final value = (raw ?? '').trim().toUpperCase();
    if (value == 'APARTMENT' ||
        value == 'HOTEL' ||
        value == 'RIAD' ||
        value == 'VILLA' ||
        value == 'HOSTEL') {
      return value;
    }
    if (value.contains('HOSTEL')) return 'HOSTEL';
    if (value.contains('RIAD')) return 'RIAD';
    if (value.contains('HOTEL')) return 'HOTEL';
    if (value.contains('VILLA')) return 'VILLA';
    return 'APARTMENT';
  }

  String _dioErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final m = data['message'];
      if (m is String && m.isNotEmpty) return m;
      if (m is List && m.isNotEmpty) return m.first.toString();
    }
    return e.message ?? 'Could not submit host application';
  }

  Exception _messageFromResponse(Object? data) {
    if (data is! Map) return Exception('Host application failed');
    final m = data['message'];
    if (m is String && m.isNotEmpty) return Exception(m);
    return Exception('Host application failed');
  }
}
