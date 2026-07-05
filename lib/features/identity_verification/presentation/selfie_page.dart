import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../navigation/app_routes.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart' as auth_state;
import 'bloc/verification_cubit.dart';
import 'bloc/verification_state.dart';

class SelfiePage extends StatefulWidget {
  const SelfiePage({super.key});

  @override
  State<SelfiePage> createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(void Function(String) onPicked) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFE8507A)),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    onPicked(image.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFE8507A)),
                title: const Text(
                  'Upload from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    onPicked(image.path);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Step 1 of 2',
                style: TextStyle(
                  color: Color(0xFFE8507A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 2,
                color: const Color(0xFFF3F4F6),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 2,
                color: const Color(0xFFE8507A),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<VerificationCubit, VerificationState>(
        listener: (context, state) {
          if (state is VerificationSubmitted) {
            context.go(AppRoutes.createPin);
          } else if (state is VerificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          String? documentPath;
          String? selfiePath;
          bool isUploading = false;

          if (state is VerificationFormReady) {
            documentPath = state.idFrontPath;
            selfiePath = state.profilePhotoPath;
          } else if (state is VerificationUploading) {
            isUploading = true;
          }

          final canContinue = documentPath != null && selfiePath != null;

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Text(
                              'Capture Documents',
                              style: TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Take clear photos of your document and yourself',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                                ),
                            ),
                            const SizedBox(height: 32),

                            // Document Photo Section
                            const Text(
                              'Document photo',
                              style: TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                ),
                            ),
                            const SizedBox(height: 12),
                            _buildCaptureBox(
                              context: context,
                              path: documentPath,
                              icon: Icons.camera_alt,
                              buttonText: documentPath == null
                                  ? 'Capture Document'
                                  : 'Retake Document',
                              onTap: () => _pickImage((path) {
                                context.read<VerificationCubit>().pickIdFront(path);
                                // Set back path the same to satisfy existing domain constraints for now
                                context.read<VerificationCubit>().pickIdBack(path);
                                // Provide an arbitrary ID number to satisfy existing constraints
                                context.read<VerificationCubit>().updateIdNumber('N/A');
                              }),
                              bullets: [
                                'Ensure all text is clear and readable',
                                'Avoid glare and shadows',
                                'Include all edges and document',
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Selfie Photo Section
                            const Text(
                              'Selfie photo',
                              style: TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                ),
                            ),
                            const SizedBox(height: 12),
                            _buildCaptureBox(
                              context: context,
                              path: selfiePath,
                              icon: Icons.face,
                              buttonText: selfiePath == null
                                  ? 'Take Selfie'
                                  : 'Retake Selfie',
                              onTap: () => _pickImage((path) {
                                context.read<VerificationCubit>().pickProfilePhoto(path);
                              }),
                              bullets: [
                                'Keep your face within the oval frame',
                                'Remove sunglasses, masks, or hats',
                              ],
                            ),

                            const Spacer(),

                            // Continue Button
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: canContinue && !isUploading
                                        ? [
                                            const Color(0xFFE8507A),
                                            const Color(0xFFFF6B9D)
                                          ]
                                        : [Colors.grey[300]!, Colors.grey[300]!],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: canContinue && !isUploading
                                      ? () {
                                          final authState =
                                              context.read<AuthBloc>().state;
                                          String? userId;
                                          if (authState is auth_state.AuthAuthenticated) {
                                            userId = authState.user.id;
                                          } else if (authState
                                              is auth_state.AuthPersonalInfoSaved) {
                                            userId = authState.user.id;
                                          } else if (authState
                                              is auth_state.AuthOtpVerified) {
                                            userId = authState.user.id;
                                          }
                                          if (userId != null) {
                                            context
                                                .read<VerificationCubit>()
                                                .submitVerification(userId);
                                          }
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    isUploading ? 'Uploading...' : 'Continue',
                                    style: TextStyle(
                                      color: canContinue ? Colors.white : Colors.grey[500],
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaptureBox({
    required BuildContext context,
    required String? path,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
    required List<String> bullets,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: path == null ? const Color(0xFFFFF0F5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: path == null ? const Color(0xFFE8507A).withOpacity(0.5) : const Color(0xFFE8507A),
          width: path == null ? 1 : 1.5,
          style: path == null ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (path != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: kIsWeb
                  ? Image.network(
                      path,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(path),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            )
          else ...[
            Icon(icon, color: const Color(0xFFE8507A), size: 32),
            const SizedBox(height: 12),
          ],
          if (path != null) const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8507A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                ),
            ),
          ),
          if (path == null) ...[
            const SizedBox(height: 16),
            ...bullets.map((bullet) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          bullet,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                            ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
