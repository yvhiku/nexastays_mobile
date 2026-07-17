import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../app/di/injection.dart';
import '../../../../auth/domain/entities/user.dart';
import '../../../domain/repositories/booking_repository.dart';

/// Builds the primary occupant DTO from the verified account profile.
/// ID number / document upload are omitted — KYC already covers the booker.
Map<String, dynamic> occupantFromVerifiedUser(User user) {
  return {
    'full_name': user.fullName.trim(),
    'is_primary': true,
    if (user.phone.trim().isNotEmpty) 'phone': user.phone.trim(),
    if (user.email != null && user.email!.trim().isNotEmpty)
      'email': user.email!.trim(),
  };
}

/// Guest identity step before booking confirmation.
///
/// - [guestCount] == 1: callers should skip this sheet and use
///   [occupantFromVerifiedUser] directly.
/// - [guestCount] > 1: primary guest is taken from the verified profile;
///   only additional guests must enter name + ID + upload.
Future<List<Map<String, dynamic>>?> showGuestVerificationSheet({
  required BuildContext context,
  required int guestCount,
  String? profileName,
  String? profilePhone,
  String? profileEmail,
}) {
  return showModalBottomSheet<List<Map<String, dynamic>>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _GuestVerificationSheet(
      guestCount: guestCount,
      profileName: profileName,
      profilePhone: profilePhone,
      profileEmail: profileEmail,
    ),
  );
}

class _GuestFormData {
  String fullName;
  String idNumber;
  String? phone;
  String? email;
  String? frontAssetId;
  final bool fromVerifiedProfile;

  _GuestFormData({
    this.fullName = '',
    this.idNumber = '',
    this.phone,
    this.email,
    this.frontAssetId,
    this.fromVerifiedProfile = false,
  });

  Map<String, dynamic> toOccupantDto({required bool isPrimary}) {
    return {
      'full_name': fullName.trim(),
      if (idNumber.trim().isNotEmpty) 'id_number': idNumber.trim(),
      'is_primary': isPrimary,
      if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
      if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      if (frontAssetId != null) 'id_document_front_asset_id': frontAssetId,
    };
  }
}

class _GuestVerificationSheet extends StatefulWidget {
  const _GuestVerificationSheet({
    required this.guestCount,
    this.profileName,
    this.profilePhone,
    this.profileEmail,
  });

  final int guestCount;
  final String? profileName;
  final String? profilePhone;
  final String? profileEmail;

  @override
  State<_GuestVerificationSheet> createState() =>
      _GuestVerificationSheetState();
}

class _GuestVerificationSheetState extends State<_GuestVerificationSheet> {
  late List<_GuestFormData> _guests;
  bool _acknowledged = false;
  bool _submitting = false;
  String? _error;
  String? _uploadingLabel;

  final _bookingRepository = getIt<BookingRepository>();
  final _picker = ImagePicker();

  bool get _primaryFromProfile =>
      (widget.profileName ?? '').trim().length >= 2;

  int get _additionalGuestCount =>
      widget.guestCount > 1 ? widget.guestCount - 1 : 0;

  @override
  void initState() {
    super.initState();
    _guests = List.generate(widget.guestCount, (i) {
      if (i == 0) {
        return _GuestFormData(
          fullName: widget.profileName ?? '',
          phone: widget.profilePhone,
          email: widget.profileEmail,
          fromVerifiedProfile: _primaryFromProfile,
        );
      }
      return _GuestFormData();
    });
  }

  Future<void> _pickAndUpload(int guestIndex) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _uploadingLabel = 'Guest ${guestIndex + 1} ID';
      _error = null;
    });

    final result = await _bookingRepository.uploadOccupantIdDocument(
      filePath: picked.path,
      side: 'front',
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _uploadingLabel = null;
      }),
      (assetId) => setState(() {
        _guests[guestIndex].frontAssetId = assetId;
        _uploadingLabel = null;
      }),
    );
  }

  void _submit() {
    setState(() => _error = null);

    if (_guests.length != widget.guestCount) {
      setState(() => _error = 'Guest count mismatch');
      return;
    }

    for (var i = 0; i < _guests.length; i++) {
      final g = _guests[i];
      final skipId = i == 0 && g.fromVerifiedProfile;

      if (g.fullName.trim().length < 2) {
        setState(() => _error = 'Enter full name for guest ${i + 1}');
        return;
      }

      if (!skipId) {
        if (g.idNumber.trim().isEmpty) {
          setState(() => _error = 'Enter ID number for guest ${i + 1}');
          return;
        }
        if (g.frontAssetId == null) {
          setState(() => _error = 'Upload ID document for guest ${i + 1}');
          return;
        }
      }

      if (i == 0 && !skipId) {
        if ((g.phone ?? '').trim().isEmpty) {
          setState(() => _error = 'Enter phone for primary guest');
          return;
        }
        if ((g.email ?? '').trim().isEmpty) {
          setState(() => _error = 'Enter email for primary guest');
          return;
        }
      }
    }

    if (!_acknowledged) {
      setState(
        () => _error = 'Confirm that all names match official identification',
      );
      return;
    }

    setState(() => _submitting = true);
    final occupants = _guests
        .asMap()
        .entries
        .map((e) => e.value.toOccupantDto(isPrimary: e.key == 0))
        .toList();
    Navigator.of(context).pop(occupants);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final subtitle = _primaryFromProfile && widget.guestCount > 1
        ? 'Your verified identity is used for the primary guest. '
            'Add details and an ID photo for each additional guest.'
        : 'We verify guest identity to keep hosts and guests safe. '
            'Upload a photo of each guest\'s ID.';

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.98,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFFE8507A)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Guest verification',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_primaryFromProfile) _buildVerifiedPrimaryCard(),
                    if (!_primaryFromProfile) _buildGuestCard(0),
                    ...List.generate(
                      _additionalGuestCount,
                      (i) => _buildGuestCard(i + 1),
                    ),
                    CheckboxListTile(
                      value: _acknowledged,
                      onChanged: (v) =>
                          setState(() => _acknowledged = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        _additionalGuestCount > 0
                            ? 'I confirm all names match official identification'
                            : 'I confirm my name matches my official identification',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting || _uploadingLabel != null
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8507A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _submitting
                            ? 'Processing…'
                            : _uploadingLabel != null
                                ? 'Uploading $_uploadingLabel…'
                                : 'Continue to confirm',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVerifiedPrimaryCard() {
    final guest = _guests[0];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user, size: 18, color: Color(0xFF059669)),
              SizedBox(width: 8),
              Text(
                'Primary guest (verified account)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            guest.fullName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          if ((guest.phone ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              guest.phone!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
          if ((guest.email ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              guest.email!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            'Using your verified identity — no ID re-upload needed.',
            style: TextStyle(fontSize: 12, color: Color(0xFF059669)),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestCard(int index) {
    final guest = _guests[index];
    final isPrimary = index == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPrimary ? 'Primary guest' : 'Guest ${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          _field(
            label: 'Full name',
            initial: guest.fullName,
            onChanged: (v) => guest.fullName = v,
          ),
          if (isPrimary) ...[
            const SizedBox(height: 10),
            _field(
              label: 'Phone',
              initial: guest.phone ?? '',
              keyboard: TextInputType.phone,
              onChanged: (v) => guest.phone = v,
            ),
            const SizedBox(height: 10),
            _field(
              label: 'Email',
              initial: guest.email ?? '',
              keyboard: TextInputType.emailAddress,
              onChanged: (v) => guest.email = v,
            ),
          ],
          const SizedBox(height: 10),
          _field(
            label: 'ID number',
            initial: guest.idNumber,
            onChanged: (v) => guest.idNumber = v,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _uploadingLabel != null
                ? null
                : () => _pickAndUpload(index),
            icon: Icon(
              guest.frontAssetId != null ? Icons.check_circle : Icons.upload,
              color: guest.frontAssetId != null
                  ? const Color(0xFF059669)
                  : const Color(0xFFE8507A),
            ),
            label: Text(
              guest.frontAssetId != null ? 'ID uploaded' : 'Upload ID (front)',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: const BorderSide(color: Color(0xFFE8507A)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required String initial,
    required ValueChanged<String> onChanged,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initial,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
