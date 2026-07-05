import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/di/injection.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/utils/profile_photo.dart';

/// Displays the current user's profile photo from `GET /users/me/profile-photo`
/// with the JWT attached (same approach as the web ProfileAvatar).
class ProfilePhotoAvatar extends StatelessWidget {
  const ProfilePhotoAvatar({
    super.key,
    required this.profilePhotoUrl,
    required this.radius,
    this.localFilePath,
    this.cacheRevision = 0,
    this.fallback,
    this.backgroundColor = const Color(0xFFE8507A),
    this.border,
  });

  final String? profilePhotoUrl;
  final double radius;
  final String? localFilePath;
  final int cacheRevision;
  final Widget? fallback;
  final Color backgroundColor;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(size),
    );
  }

  Widget _buildContent(double size) {
    if (localFilePath != null && localFilePath!.isNotEmpty) {
      return Image.file(
        File(localFilePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    if (!userHasProfilePhoto(profilePhotoUrl)) {
      return Center(child: fallback ?? const SizedBox.shrink());
    }

    return FutureBuilder<String?>(
      future: getIt<SessionManager>().getAccessToken(),
      builder: (context, snapshot) {
        final token = snapshot.data;
        if (token == null || token.isEmpty) {
          return Center(child: fallback ?? const SizedBox.shrink());
        }

        return CachedNetworkImage(
          width: size,
          height: size,
          fit: BoxFit.cover,
          imageUrl: profilePhotoImageUrl(cacheRevision: cacheRevision),
          httpHeaders: {'Authorization': 'Bearer $token'},
          cacheKey: 'profile_photo_$cacheRevision',
          placeholder: (_, __) => Center(
            child: SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (_, __, ___) => Center(
            child: fallback ??
                const Icon(Icons.person, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }
}
