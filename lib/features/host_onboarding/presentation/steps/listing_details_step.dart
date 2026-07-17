import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/host_onboarding_bloc.dart';
import '../bloc/host_onboarding_event.dart';
import '../bloc/host_onboarding_state.dart';

class ListingDetailsStep extends StatefulWidget {
  const ListingDetailsStep({
    super.key,
    required this.state,
    required this.bloc,
  });

  final HostOnboardingState state;
  final HostOnboardingBloc bloc;

  @override
  State<ListingDetailsStep> createState() => _ListingDetailsStepState();
}

class _ListingDetailsStepState extends State<ListingDetailsStep> {
  late final TextEditingController _description;
  late final TextEditingController _maxGuests;
  late final TextEditingController _beds;
  late final TextEditingController _bathrooms;
  late final TextEditingController _size;
  late final TextEditingController _totalRooms;
  late Map<String, Object?> _details;

  @override
  void initState() {
    super.initState();
    _description = TextEditingController(text: widget.state.description ?? '');
    _maxGuests = TextEditingController(text: '${widget.state.maxGuests}');
    _beds = TextEditingController(text: '${widget.state.beds}');
    _bathrooms = TextEditingController(text: '${widget.state.bathrooms}');
    _size = TextEditingController(
      text: widget.state.sizeSqm?.toStringAsFixed(0) ?? '',
    );
    _details = Map<String, Object?>.from(widget.state.propertyDetails);
    _totalRooms = TextEditingController(
      text: (_details['total_rooms'] ?? '').toString(),
    );
    for (final controller in [
      _description,
      _maxGuests,
      _beds,
      _bathrooms,
      _size,
      _totalRooms,
    ]) {
      controller.addListener(_save);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _save());
  }

  @override
  void dispose() {
    for (final controller in [
      _description,
      _maxGuests,
      _beds,
      _bathrooms,
      _size,
      _totalRooms,
    ]) {
      controller.removeListener(_save);
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    widget.bloc.add(
      HostListingDetailsSaved(
        description: _description.text.trim(),
        maxGuests: int.tryParse(_maxGuests.text) ?? 0,
        beds: int.tryParse(_beds.text) ?? 0,
        bathrooms: int.tryParse(_bathrooms.text) ?? 0,
        sizeSqm: double.tryParse(_size.text),
        propertyDetails: _details,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.state.propertyType ?? 'APARTMENT';
    final title = switch (type) {
      'HOTEL' => 'Tell us about your hotel',
      'HOSTEL' => 'Tell us about your hostel',
      'VILLA' => 'Describe the villa layout',
      'RIAD' => 'Tell us about your riad',
      _ => 'Describe the apartment',
    };
    final features = _featuresFor(type);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These details are specific to ${type.toLowerCase()} stays.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          _field(
            'Description *',
            _description,
            hint: 'What makes this stay special? (20 characters minimum)',
            maxLines: 4,
          ),
          Row(
            children: [
              Expanded(child: _numberField('Max guests *', _maxGuests)),
              const SizedBox(width: 12),
              Expanded(child: _numberField('Size (m²)', _size)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  type == 'HOSTEL' ? 'Sleeping areas *' : 'Beds *',
                  _beds,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _numberField('Bathrooms *', _bathrooms)),
            ],
          ),
          if (type == 'HOTEL' || type == 'HOSTEL') ...[
            const SizedBox(height: 14),
            _numberField(
              type == 'HOTEL' ? 'Total rooms' : 'Total rooms and dorms',
              _totalRooms,
              onChanged: (value) {
                _details['total_rooms'] = int.tryParse(value) ?? 0;
                _save();
              },
            ),
          ],
          if (features.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(
              type == 'VILLA' ? 'Outdoor spaces' : 'Property features',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features.map((feature) {
                final selected = _details[feature.key] == true;
                return FilterChip(
                  selected: selected,
                  label: Text(feature.label),
                  onSelected: (value) {
                    setState(() => _details[feature.key] = value);
                    _save();
                  },
                  selectedColor: const Color(0xFFFFE4ED),
                  checkmarkColor: const Color(0xFFE8507A),
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFFE8507A)
                        : const Color(0xFFE5E7EB),
                  ),
                  labelStyle: GoogleFonts.dmSans(fontSize: 12),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _numberField(
    String label,
    TextEditingController controller, {
    ValueChanged<String>? onChanged,
  }) {
    return _field(
      label,
      controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
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
          const SizedBox(height: 7),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  const _Feature(this.key, this.label);
  final String key;
  final String label;
}

List<_Feature> _featuresFor(String type) => switch (type) {
      'VILLA' => const [
          _Feature('garden', 'Garden'),
          _Feature('pool', 'Pool'),
          _Feature('terrace', 'Terrace'),
          _Feature('parking', 'Parking'),
          _Feature('barbecue', 'Barbecue'),
          _Feature('gated', 'Gated'),
        ],
      'RIAD' => const [
          _Feature('courtyard', 'Courtyard'),
          _Feature('rooftop', 'Rooftop'),
          _Feature('breakfast', 'Breakfast'),
          _Feature('hammam', 'Hammam'),
        ],
      'HOTEL' => const [
          _Feature('reception', 'Reception'),
          _Feature('breakfast', 'Breakfast'),
          _Feature('laundry', 'Laundry'),
          _Feature('parking', 'Parking'),
        ],
      'HOSTEL' => const [
          _Feature('lockers', 'Lockers'),
          _Feature('shared_kitchen', 'Shared kitchen'),
          _Feature('lounge', 'Lounge'),
          _Feature('coworking', 'Coworking'),
          _Feature('laundry', 'Laundry'),
        ],
      _ => const [],
    };
