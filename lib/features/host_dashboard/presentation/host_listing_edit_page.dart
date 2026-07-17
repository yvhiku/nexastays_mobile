import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/di/injection.dart';
import '../../host_onboarding/presentation/widgets/host_location_map_picker.dart';
import '../domain/repositories/host_repository.dart';

class HostListingEditPage extends StatefulWidget {
  const HostListingEditPage({
    super.key,
    required this.listingId,
    this.section,
  });

  final String listingId;
  final String? section;

  @override
  State<HostListingEditPage> createState() => _HostListingEditPageState();
}

class _HostListingEditPageState extends State<HostListingEditPage> {
  final _hostRepo = getIt<HostRepository>();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _neighborhoodCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _basePriceCtrl;
  late final TextEditingController _weekendPriceCtrl;
  late final TextEditingController _cleaningFeeCtrl;
  late final TextEditingController _maxGuestsCtrl;
  late final TextEditingController _checkInCtrl;
  late final TextEditingController _checkOutCtrl;
  late final TextEditingController _accessCtrl;

  bool _petsAllowed = false;
  bool _smokingAllowed = false;
  double? _geoLat;
  double? _geoLng;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _neighborhoodCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _basePriceCtrl = TextEditingController();
    _weekendPriceCtrl = TextEditingController();
    _cleaningFeeCtrl = TextEditingController();
    _maxGuestsCtrl = TextEditingController();
    _checkInCtrl = TextEditingController();
    _checkOutCtrl = TextEditingController();
    _accessCtrl = TextEditingController();
    _cityCtrl.addListener(() => setState(() {}));
    _neighborhoodCtrl.addListener(() => setState(() {}));
    _addressCtrl.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _cityCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _addressCtrl.dispose();
    _basePriceCtrl.dispose();
    _weekendPriceCtrl.dispose();
    _cleaningFeeCtrl.dispose();
    _maxGuestsCtrl.dispose();
    _checkInCtrl.dispose();
    _checkOutCtrl.dispose();
    _accessCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _hostRepo.getListingForEdit(widget.listingId);
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (listing) {
        _titleCtrl.text = listing.title;
        _descriptionCtrl.text = listing.description;
        _cityCtrl.text = listing.city;
        _neighborhoodCtrl.text = listing.neighborhood;
        _addressCtrl.text = listing.address;
        _basePriceCtrl.text = listing.basePrice.toStringAsFixed(0);
        _weekendPriceCtrl.text = listing.weekendPrice > 0
            ? listing.weekendPrice.toStringAsFixed(0)
            : '';
        _cleaningFeeCtrl.text = listing.cleaningFee.toStringAsFixed(0);
        _maxGuestsCtrl.text = listing.maxGuests.toString();
        _checkInCtrl.text = _trimTime(listing.checkInTime);
        _checkOutCtrl.text = _trimTime(listing.checkOutTime);
        _accessCtrl.text = listing.accessInstructions;
        _petsAllowed = listing.petsPolicy != 'NO';
        _smokingAllowed = listing.smokingPolicy == 'ALLOWED';
        _geoLat = listing.geoLat;
        _geoLng = listing.geoLng;
        setState(() => _loading = false);
      },
    );
  }

  String _trimTime(String value) {
    final parts = value.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return value;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await _hostRepo.updateListing(
      listingId: widget.listingId,
      title: _titleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      neighborhood: _neighborhoodCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      basePrice: double.tryParse(_basePriceCtrl.text.trim()),
      weekendPrice: double.tryParse(_weekendPriceCtrl.text.trim()),
      cleaningFee: double.tryParse(_cleaningFeeCtrl.text.trim()),
      maxGuests: int.tryParse(_maxGuestsCtrl.text.trim()),
      checkInTime: _checkInCtrl.text.trim(),
      checkOutTime: _checkOutCtrl.text.trim(),
      petsPolicy: _petsAllowed ? 'ALLOWED' : 'NO',
      smokingPolicy: _smokingAllowed ? 'ALLOWED' : 'NOT_ALLOWED',
      accessInstructions: _accessCtrl.text.trim(),
      geoLat: _geoLat,
      geoLng: _geoLng,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Listing updated', style: GoogleFonts.dmSans()),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        context.pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.section?.toLowerCase();
    final title = switch (section) {
      'pricing' => 'Pricing & Discounts',
      'rules' => 'House Rules',
      _ => 'Edit Listing',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_loading && _error == null)
            TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE8507A),
                      ),
                    ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8507A)),
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8507A),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (section == null || section == 'pricing') ...[
                      _sectionTitle('Pricing'),
                      _field('Nightly rate (MAD)', _basePriceCtrl,
                          keyboardType: TextInputType.number),
                      _field('Weekend rate (MAD)', _weekendPriceCtrl,
                          keyboardType: TextInputType.number),
                      _field('Cleaning fee (MAD)', _cleaningFeeCtrl,
                          keyboardType: TextInputType.number),
                      const SizedBox(height: 24),
                    ],
                    if (section == null || section == 'rules') ...[
                      _sectionTitle('House rules'),
                      _field('Check-in from', _checkInCtrl),
                      _field('Check-out before', _checkOutCtrl),
                      _field('Max guests', _maxGuestsCtrl,
                          keyboardType: TextInputType.number),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Pets allowed',
                            style: GoogleFonts.dmSans()),
                        value: _petsAllowed,
                        activeColor: const Color(0xFFE8507A),
                        onChanged: (v) => setState(() => _petsAllowed = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Smoking allowed',
                            style: GoogleFonts.dmSans()),
                        value: _smokingAllowed,
                        activeColor: const Color(0xFFE8507A),
                        onChanged: (v) => setState(() => _smokingAllowed = v),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (section == null) ...[
                      _sectionTitle('Property details'),
                      _field('Title', _titleCtrl),
                      _field('City', _cityCtrl),
                      _field('Neighborhood', _neighborhoodCtrl),
                      _field('Full address', _addressCtrl, maxLines: 2),
                      const SizedBox(height: 8),
                      HostLocationMapPicker(
                        city: _cityCtrl.text,
                        neighborhood: _neighborhoodCtrl.text,
                        address: _addressCtrl.text,
                        latitude: _geoLat,
                        longitude: _geoLng,
                        onCoordinatesChanged: (pin) {
                          setState(() {
                            _geoLat = pin.latitude;
                            _geoLng = pin.longitude;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _field('Description', _descriptionCtrl, maxLines: 4),
                      _field('Access instructions', _accessCtrl, maxLines: 3),
                    ],
                  ],
                ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: GoogleFonts.dmSans(fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                borderSide:
                    const BorderSide(color: Color(0xFFE8507A), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
