// =============================================================================
// NexaStays Media Service
// =============================================================================
// Manages device gallery / camera interactions and multi-part image uploads
// to the backend for profile pictures, feedback attachments, etc.
// =============================================================================

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/api_endpoints.dart';
import '../core/error/exceptions.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';

/// Service responsible for capturing, picking, and uploading media.
class MediaService {
  MediaService({required this.dioClient});

  /// The underlying network client used for multi-part uploads.
  final DioClient dioClient;

  /// Native image picker instance.
  final ImagePicker _picker = ImagePicker();

  /// Prompts the user to select an image from their device gallery.
  ///
  /// Returns a [File] if an image was picked, or `null` if the user cancelled.
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        // Optional pre-compression via image_picker
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MediaService] Failed to pick image from gallery: $e');
      }
      throw const UnknownException('Failed to access device gallery.');
    }
  }

  /// Prompts the user to capture an image using the device camera.
  ///
  /// Returns a [File] if an image was captured, or `null` if the user cancelled.
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        // Optional pre-compression via image_picker
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MediaService] Failed to capture image from camera: $e');
      }
      throw const UnknownException('Failed to access device camera.');
    }
  }

  /// Uploads a given [file] to the backend and returns the hosted URL.
  ///
  /// Uses a `multipart/form-data` request via [Dio].
  /// Throws [AppException] subtypes on network or server failures.
  Future<String> uploadImage(File file) async {
    try {
      // Create multi-part payload
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      // Send via Dio
      final response = await dioClient.post(
        ApiEndpoints.uploadMedia,
        data: formData,
        options: Options(
          headers: {
            // Override the default application/json header for uploads
            // Note: dio usually handles multipart headers automatically
            // when it detects a FormData payload, but we explicitly note it.
          },
        ),
      );

      // Parse backend response
      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Assume backend returns { "success": true, "data": { "url": "https://..." } }
        final url = apiResponse.data!['url'] as String?;
        if (url != null && url.isNotEmpty) {
          return url;
        }
      }

      throw const ServerException('Invalid response format from media server.');
    } catch (e) {
      // The ErrorInterceptor guarantees HTTP/network errors are AppExceptions
      if (e is AppException) rethrow;

      if (kDebugMode) {
        print('❌ [MediaService] Failed to upload image: $e');
      }
      throw UnknownException('Failed to upload image. $e');
    }
  }
}
