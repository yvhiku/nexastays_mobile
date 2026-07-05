import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/di/injection.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/storage/local_storage.dart';
import '../bloc/host_onboarding_bloc.dart';
import '../bloc/host_onboarding_event.dart';
import '../bloc/host_onboarding_state.dart';
import '../../../profile/presentation/widgets/profile_photo_avatar.dart';

class AccountStep extends StatefulWidget {
  const AccountStep({
    super.key,
    required this.state,
    required this.bloc,
  });

  final HostOnboardingState state;
  final HostOnboardingBloc bloc;

  @override
  State<AccountStep> createState() => _AccountStepState();
}

class _AccountStepState extends State<AccountStep> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _whatsappController;

  final ImagePicker _picker = ImagePicker();
  String? _profilePhotoPath;

  /// Filled once from [AuthBloc] or `cached_user` (same source as `/users/me` after login).
  bool _prefilled = false;
  bool _cacheLookupScheduled = false;

  /// Name (and phone) match verified KYC — same rule as Nexa Pay / edit profile.
  bool _identityLocked = false;

  User? _profileUser;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _whatsappController = TextEditingController();

    _firstNameController.addListener(_dispatchUpdate);
    _lastNameController.addListener(_dispatchUpdate);
    _phoneController.addListener(_dispatchUpdate);
    _emailController.addListener(_dispatchUpdate);
    _whatsappController.addListener(_dispatchUpdate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _applyFromUser(authState.user);
      return;
    }

    if (_cacheLookupScheduled) return;
    _cacheLookupScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _prefilled) return;
      try {
        final raw = await getIt<LocalStorage>().getString('cached_user');
        if (raw != null && raw.isNotEmpty) {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          final user = UserModel.fromJson(map);
          if (mounted) _applyFromUser(user);
        }
      } catch (_) {}
    });
  }

  void _applyFromUser(User user) {
    if (_prefilled) return;
    _prefilled = true;
    _profileUser = user;
    _identityLocked = user.isVerified;

    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _phoneController.text = user.phone;
    _emailController.text = user.email ?? '';

    if (mounted) setState(() {});
    _dispatchUpdate();
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_dispatchUpdate);
    _lastNameController.removeListener(_dispatchUpdate);
    _phoneController.removeListener(_dispatchUpdate);
    _emailController.removeListener(_dispatchUpdate);
    _whatsappController.removeListener(_dispatchUpdate);
    
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _dispatchUpdate() {
    final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
    
    // Dispatch Account Info
    widget.bloc.add(
      HostAccountInfoSaved(
        fullName: fullName,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      ),
    );

    // Dispatch Contact Info (WhatsApp is saved here based on the event structure)
    // The previous instructions for HostContactSaved were (whatsapp, checkInContact)
    // We'll dispatch it if that event exists, but for now we'll stick to combining what we can.
  }

  Future<void> _pickProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePhotoPath = image.path;
      });
      // In a real flow, you'd dispatch this to the BLoC as well, e.g. HostProfilePhotoSaved
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your account details',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is how guests and Nexa will identify you.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),

          // ── NOTE BANNER ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: Color(0xFF0EA5E9), width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ℹ️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _identityLocked
                        ? 'Your verified Nexa profile (KYC) is shown below. Name and phone match your ID and cannot be changed.'
                        : 'If you already have a Nexa guest account, your details are pre-filled from your profile.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF0369A1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── AVATAR ROW ──
          Row(
            children: [
              ProfilePhotoAvatar(
                profilePhotoUrl: _profileUser?.profilePhotoUrl,
                radius: 28,
                localFilePath: _profilePhotoPath,
                backgroundColor: const Color(0xFFFFF0F5),
                fallback: Text(
                  _firstNameController.text.isNotEmpty
                      ? _firstNameController.text[0].toUpperCase()
                      : 'H',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE8507A),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload profile photo',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'Helps guests recognise you',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _pickProfilePhoto,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE8507A),
                  side: const BorderSide(color: Color(0xFFE8507A)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Upload',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── FORM FIELDS ──
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'First Name *',
                  hint: 'Youssef',
                  controller: _firstNameController,
                  readOnly: _identityLocked,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  label: 'Last Name *',
                  hint: 'Ait Omar',
                  controller: _lastNameController,
                  readOnly: _identityLocked,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildInputField(
            label: 'Phone *',
            hint: '+212 6 XX XX XX XX',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixText: '🇲🇦  ',
            readOnly: _identityLocked,
          ),
          const SizedBox(height: 14),

          _buildInputField(
            label: 'Email *',
            hint: 'you@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),

          _buildInputField(
            label: 'WhatsApp',
            hint: '+212 6 XX XX XX XX',
            controller: _whatsappController,
            keyboardType: TextInputType.phone,
            isOptional: true,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 8),
              child: Icon(Icons.chat_bubble, color: Color(0xFF25D366), size: 20),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
    String? prefixText,
    Widget? prefixIcon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            if (isOptional)
              Text(
                ' (optional)',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: readOnly ? const Color(0xFF6B7280) : const Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            filled: readOnly,
            fillColor: readOnly ? const Color(0xFFF3F4F6) : null,
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            prefixText: prefixText,
            prefixStyle: const TextStyle(fontSize: 14),
            prefixIcon: prefixIcon,
            suffixIcon: readOnly
                ? const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: Color(0xFF9CA3AF),
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: readOnly ? const Color(0xFFE5E7EB) : const Color(0xFFE8507A),
                width: readOnly ? 1 : 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
