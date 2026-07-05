import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../navigation/app_routes.dart';
import 'bloc/verification_cubit.dart';
import 'bloc/verification_state.dart';
import 'widgets/id_upload_box.dart';

class IdCapturePage extends StatefulWidget {
  const IdCapturePage({super.key});

  @override
  State<IdCapturePage> createState() => _IdCapturePageState();
}

class _IdCapturePageState extends State<IdCapturePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isFront) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFE8507A)),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picked = await _picker.pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    if (isFront) {
                      context.read<VerificationCubit>().pickIdFront(picked.path);
                    } else {
                      context.read<VerificationCubit>().pickIdBack(picked.path);
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF3B82F6)),
                title: const Text('Upload from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picked = await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    if (isFront) {
                      context.read<VerificationCubit>().pickIdFront(picked.path);
                    } else {
                      context.read<VerificationCubit>().pickIdBack(picked.path);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
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
      ),
      body: SafeArea(
        child: BlocBuilder<VerificationCubit, VerificationState>(
          builder: (context, state) {
            String? frontPath;
            String? backPath;
            bool canContinue = false;

            if (state is VerificationFormReady) {
              frontPath = state.idFrontPath;
              backPath = state.idBackPath;
              canContinue = frontPath != null && backPath != null;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            color: Color(0xFFE8507A), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Capture Document',
                          style: TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload or capture clear photos of the front and back of your selected identity document.',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      ),
                  ),
                  const SizedBox(height: 32),

                  // Front Upload
                  const Text(
                    'Front of Document *',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      ),
                  ),
                  const SizedBox(height: 12),
                  IdUploadBox(
                    label: 'Tap to upload or take photo of the front',
                    filePath: frontPath,
                    isLarge: true,
                    onTap: () => _pickImage(true),
                  ),

                  const SizedBox(height: 24),

                  // Back Upload
                  const Text(
                    'Back of Document *',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      ),
                  ),
                  const SizedBox(height: 12),
                  IdUploadBox(
                    label: 'Tap to upload or take photo of the back',
                    filePath: backPath,
                    isLarge: true,
                    onTap: () => _pickImage(false),
                  ),

                  const Spacer(),

                  // Bottom Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: canContinue
                              ? [const Color(0xFFE8507A), const Color(0xFFFF6B9D)]
                              : [Colors.grey[300]!, Colors.grey[300]!],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: canContinue
                            ? () {
                                context.push(AppRoutes.selfieCapture);
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
                          'Continue to Selfie',
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
            );
          },
        ),
      ),
    );
  }
}
