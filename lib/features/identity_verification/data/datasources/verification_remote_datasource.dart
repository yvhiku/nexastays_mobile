import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/verification_model.dart';

class UploadProgressEvent {
  final String fileName;
  final double progress;
  final bool isDone;

  const UploadProgressEvent({
    required this.fileName,
    required this.progress,
    required this.isDone,
  });
}

abstract class VerificationRemoteDataSource {
  Stream<UploadProgressEvent> get uploadProgressStream;

  Future<void> uploadIdDocument({
    required String userId,
    required String idType,
    required String idNumber,
    required String idFrontPath,
    required String idBackPath,
  });

  Future<void> uploadProfilePhoto({
    required String userId,
    required String profilePhotoPath,
  });

  Future<VerificationModel> submitVerification(String userId);
  Future<VerificationModel> getVerificationStatus(String userId);

  Future<VerificationModel> resubmitVerification({
    required String userId,
    required String idFrontPath,
    required String idBackPath,
    required String profilePhotoPath,
  });
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  VerificationRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;
  final StreamController<UploadProgressEvent> _progressController =
      StreamController<UploadProgressEvent>.broadcast();

  String? _frontAssetId;
  String? _backAssetId;
  String? _selfieAssetId;
  String _docType = 'cnie';
  String _docNumber = '';

  @override
  Stream<UploadProgressEvent> get uploadProgressStream =>
      _progressController.stream;

  dynamic _unwrap(dynamic body) {
    if (body is Map<String, dynamic> && body['data'] != null) return body['data'];
    return body;
  }

  Future<String> _uploadAsset({
    required String filePath,
    required String endpoint,
    required String label,
  }) async {
    _progressController.add(UploadProgressEvent(fileName: label, progress: 0, isDone: false));
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filePath.split(Platform.pathSeparator).last),
    });
    final response = await dioClient.dio.post(
      endpoint,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: (sent, total) {
        if (total > 0) {
          _progressController.add(
            UploadProgressEvent(
              fileName: label,
              progress: sent / total,
              isDone: false,
            ),
          );
        }
      },
    );
    final body = _unwrap(response.data);
    final assetId = (body is Map<String, dynamic> ? body['asset_id'] : null)?.toString();
    if (assetId == null || assetId.isEmpty) {
      throw Exception('Upload did not return asset_id');
    }
    _progressController.add(
      UploadProgressEvent(fileName: label, progress: 1, isDone: true),
    );
    return assetId;
  }

  @override
  Future<void> uploadIdDocument({
    required String userId,
    required String idType,
    required String idNumber,
    required String idFrontPath,
    required String idBackPath,
  }) async {
    _docType = idType;
    _docNumber = idNumber;
    _frontAssetId = await _uploadAsset(
      filePath: idFrontPath,
      endpoint: ApiEndpoints.staysHostVerificationFront,
      label: 'id_front',
    );
    _backAssetId = await _uploadAsset(
      filePath: idBackPath,
      endpoint: ApiEndpoints.staysHostVerificationBack,
      label: 'id_back',
    );
  }

  @override
  Future<void> uploadProfilePhoto({
    required String userId,
    required String profilePhotoPath,
  }) async {
    _selfieAssetId = await _uploadAsset(
      filePath: profilePhotoPath,
      endpoint: ApiEndpoints.staysHostVerificationSelfie,
      label: 'selfie',
    );
  }

  @override
  Future<VerificationModel> submitVerification(String userId) async {
    await dioClient.post(
      ApiEndpoints.staysHostVerification,
      data: {
        'document_type': _docType,
        'document_number_hash': _docNumber,
        'document_front_asset_id': _frontAssetId,
        'document_back_asset_id': _backAssetId,
        'selfie_asset_id': _selfieAssetId,
      },
      options: Options(),
    );
    return getVerificationStatus(userId);
  }

  @override
  Future<VerificationModel> getVerificationStatus(String userId) async {
    final response = await dioClient.get(ApiEndpoints.staysHostVerification);
    final body = _unwrap(response.data);
    final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final status = (map['status'] ?? 'NOT_STARTED').toString().toLowerCase();
    return VerificationModel.fromJson({
      'user_id': userId,
      'id_type': _docType,
      'id_number': _docNumber,
      'status': status,
      'id_front_url': _frontAssetId,
      'id_back_url': _backAssetId,
      'profile_photo_url': _selfieAssetId,
      'rejection_reasons': [
        if (map['rejection_reason'] != null) map['rejection_reason'].toString(),
      ],
      'attempts_remaining': 3,
      'submitted_at': map['submitted_at'],
      'reviewed_at': map['reviewed_at'],
    });
  }

  @override
  Future<VerificationModel> resubmitVerification({
    required String userId,
    required String idFrontPath,
    required String idBackPath,
    required String profilePhotoPath,
  }) async {
    await uploadIdDocument(
      userId: userId,
      idType: _docType,
      idNumber: _docNumber,
      idFrontPath: idFrontPath,
      idBackPath: idBackPath,
    );
    await uploadProfilePhoto(userId: userId, profilePhotoPath: profilePhotoPath);
    return submitVerification(userId);
  }
}
