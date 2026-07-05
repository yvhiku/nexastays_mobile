import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../auth/domain/entities/user.dart';

import 'bloc/profile_cubit.dart';
import 'bloc/profile_state.dart';
import 'widgets/profile_photo_avatar.dart';

// =============================================================================
// Edit Profile Page
// =============================================================================

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;

  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  String? _newPhotoPath;
  bool _passwordExpanded = false;
  bool _showCurrentPw = false;
  bool _showNewPw = false;
  bool _showConfirmPw = false;

  User? _originalUser;
  bool _initialised = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  void _initFromUser(User user) {
    if (_initialised) return;
    _originalUser = user;
    _firstNameCtrl = TextEditingController(text: user.firstName);
    _lastNameCtrl = TextEditingController(text: user.lastName);
    _dobCtrl = TextEditingController(text: _formatDob(user.dateOfBirth));
    _phoneCtrl = TextEditingController(text: user.phone);
    _emailCtrl = TextEditingController(text: user.email ?? '');
    _initialised = true;
  }

  String _formatDob(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  bool get _identityLocked => _originalUser?.isVerified == true;

  bool get _hasChanges {
    if (_originalUser == null) return false;
    final u = _originalUser!;
    if (_identityLocked) {
      return _phoneCtrl.text != u.phone ||
          (_emailCtrl.text != (u.email ?? '')) ||
          _newPhotoPath != null;
    }
    return _firstNameCtrl.text != u.firstName ||
        _lastNameCtrl.text != u.lastName ||
        _phoneCtrl.text != u.phone ||
        (_emailCtrl.text != (u.email ?? '')) ||
        _newPhotoPath != null;
  }

  bool get _passwordsMatch =>
      _newPwCtrl.text == _confirmPwCtrl.text || _confirmPwCtrl.text.isEmpty;

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF1A1A2E),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: false,
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final isUpdating = state is ProfileUpdating;
              final enabled = _hasChanges && !isUpdating;
              return TextButton(
                onPressed: enabled ? _onSave : null,
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: enabled
                        ? const Color(0xFFE8507A)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: _onStateChange,
        builder: (context, state) {
          // Initialise from the first ProfileLoaded we see.
          User? user;
          if (state is ProfileLoaded) user = state.user;
          if (state is ProfileUpdating) user = state.currentUser;
          if (state is ProfileUpdateSuccess) user = state.updatedUser;
          if (state is ProfileError) user = state.currentUser;

          if (user != null) _initFromUser(user);
          if (!_initialised) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
              ),
            );
          }

          final isUpdating = state is ProfileUpdating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ── Avatar ──────────────────────────────────────
                _buildAvatar(context, user!, state),
                const SizedBox(height: 24),

                // ── Name row ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _firstNameCtrl,
                        label: 'First Name *',
                        readOnly: _identityLocked,
                        locked: _identityLocked,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _lastNameCtrl,
                        label: 'Last Name *',
                        readOnly: _identityLocked,
                        locked: _identityLocked,
                      ),
                    ),
                  ],
                ),
                if (_identityLocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Name matches your verified ID and cannot be changed.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // ── Date of birth (identity; read-only) ─────────
                _buildField(
                  controller: _dobCtrl,
                  label: 'Date of birth',
                  readOnly: true,
                  locked: _identityLocked,
                  keyboardType: TextInputType.none,
                ),
                if (_identityLocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Date of birth matches your verified document.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // ── Phone ───────────────────────────────────────
                _buildField(
                  controller: _phoneCtrl,
                  label: 'Phone *',
                  hint: '+212 6 XX XX XX XX',
                  keyboardType: TextInputType.phone,
                  prefix: const Text('🇲🇦 ',
                      style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 14),

                // ── Email ───────────────────────────────────────
                _buildField(
                  controller: _emailCtrl,
                  label: 'Email *',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                // ── Password section ────────────────────────────
                _buildPasswordSection(),
                const SizedBox(height: 24),

                // ── Save button ─────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        _hasChanges && !isUpdating ? _onSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8507A),
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                        : const Text(
                            'Save changes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onStateChange(BuildContext context, ProfileState state) {
    if (state is ProfileUpdateSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Saved ✓',
              style: TextStyle(fontSize: 13)),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.pop();
    } else if (state is PasswordChangeSuccess) {
      setState(() {
        _passwordExpanded = false;
        _currentPwCtrl.clear();
        _newPwCtrl.clear();
        _confirmPwCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed ✓',
              style: TextStyle(fontSize: 13)),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (state is PasswordChangeError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message,
              style: const TextStyle(fontSize: 13)),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (state is ProfileError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message,
              style: const TextStyle(fontSize: 13)),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _onSave() {
    final cubit = context.read<ProfileCubit>();
    final u = _originalUser!;

    // Only send changed fields. Name is never updated when KYC is verified.
    cubit.updateProfile(
      firstName: _identityLocked || _firstNameCtrl.text == u.firstName
          ? null
          : _firstNameCtrl.text,
      lastName: _identityLocked || _lastNameCtrl.text == u.lastName
          ? null
          : _lastNameCtrl.text,
      phone: _phoneCtrl.text != u.phone ? _phoneCtrl.text : null,
      email: _emailCtrl.text != (u.email ?? '') ? _emailCtrl.text : null,
      profilePhotoPath: _newPhotoPath,
    );
  }

  // ── Avatar ───────────────────────────────────────────────────────────

  Widget _buildAvatar(BuildContext context, User user, ProfileState state) {
    final revision = state is ProfileLoaded ? state.profilePhotoRevision : 0;

    return Column(
      children: [
        Stack(
          children: [
            ProfilePhotoAvatar(
              profilePhotoUrl: user.profilePhotoUrl,
              radius: 45,
              localFilePath: _newPhotoPath,
              cacheRevision: revision,
              fallback: Text(
                user.fullName.isNotEmpty
                    ? user.fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickPhoto,
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFE8507A),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap to change photo',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('📸', style: TextStyle(fontSize: 20)),
                title: const Text('Take photo',
                    style: TextStyle(fontSize: 14)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Text('🖼️', style: TextStyle(fontSize: 20)),
                title: const Text('Choose from gallery',
                    style: TextStyle(fontSize: 14)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _newPhotoPath = picked.path);
    }
  }

  // ── Text field ───────────────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    Widget? prefix,
    bool obscure = false,
    Widget? suffix,
    bool readOnly = false,
    bool locked = false,
  }) {
    final fillColor =
        readOnly ? const Color(0xFFF3F4F6) : Colors.white;
    final lockSuffix = locked
        ? const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: Color(0xFF9CA3AF),
            ),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          readOnly: readOnly,
          onChanged: readOnly ? null : (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
            ),
            filled: readOnly,
            fillColor: fillColor,
            prefixIcon: prefix != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, right: 4),
                    child: prefix,
                  )
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffix ?? lockSuffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: readOnly ? const Color(0xFFE5E7EB) : const Color(0xFFE8507A),
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          style: TextStyle(
            fontSize: 14,
            color: readOnly ? const Color(0xFF6B7280) : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  // ── Password section ─────────────────────────────────────────────────

  Widget _buildPasswordSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Header.
          GestureDetector(
            onTap: () =>
                setState(() => _passwordExpanded = !_passwordExpanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Text(
                    '🔒 Change password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _passwordExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF9CA3AF), size: 22),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content.
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPasswordField(
                    controller: _currentPwCtrl,
                    label: 'Current password',
                    show: _showCurrentPw,
                    onToggle: () =>
                        setState(() => _showCurrentPw = !_showCurrentPw),
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: _newPwCtrl,
                    label: 'New password',
                    show: _showNewPw,
                    onToggle: () =>
                        setState(() => _showNewPw = !_showNewPw),
                  ),
                  const SizedBox(height: 6),

                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: _confirmPwCtrl,
                    label: 'Confirm new password',
                    show: _showConfirmPw,
                    onToggle: () =>
                        setState(() => _showConfirmPw = !_showConfirmPw),
                  ),
                  if (!_passwordsMatch) ...[
                    const SizedBox(height: 4),
                    const Text(
                      "✗ Passwords don't match",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: _canSubmitPassword ? _onChangePassword : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE8507A),
                        side: BorderSide(
                          color: _canSubmitPassword
                              ? const Color(0xFFE8507A)
                              : const Color(0xFFE5E7EB),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        'Update password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _passwordExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  bool get _canSubmitPassword =>
      _currentPwCtrl.text.isNotEmpty &&
      _newPwCtrl.text.length >= 8 &&
      _passwordsMatch &&
      _confirmPwCtrl.text.isNotEmpty;

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool show,
    required VoidCallback onToggle,
  }) {
    return _buildField(
      controller: controller,
      label: label,
      obscure: !show,
      suffix: IconButton(
        icon: Icon(
          show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 18,
          color: const Color(0xFF9CA3AF),
        ),
        onPressed: onToggle,
      ),
    );
  }

  void _onChangePassword() {
    context.read<ProfileCubit>().changePassword(
          currentPassword: _currentPwCtrl.text,
          newPassword: _newPwCtrl.text,
        );
  }
}
