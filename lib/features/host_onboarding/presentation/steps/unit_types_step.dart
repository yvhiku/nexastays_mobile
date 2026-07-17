import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../listing_wizard/listing_step_config.dart';
import '../bloc/host_onboarding_bloc.dart';
import '../bloc/host_onboarding_event.dart';
import '../bloc/host_onboarding_state.dart';

class UnitTypesStep extends StatefulWidget {
  const UnitTypesStep({
    super.key,
    required this.state,
    required this.bloc,
  });

  final HostOnboardingState state;
  final HostOnboardingBloc bloc;

  @override
  State<UnitTypesStep> createState() => _UnitTypesStepState();
}

class _UnitTypesStepState extends State<UnitTypesStep> {
  late List<ListingUnitDraft> _units;

  @override
  void initState() {
    super.initState();
    _units = List<ListingUnitDraft>.from(widget.state.unitTypes);
  }

  void _emit() {
    widget.bloc.add(HostUnitTypesSaved(unitTypes: _units));
  }

  void _addUnit() {
    final type = widget.state.propertyType ?? 'APARTMENT';
    final model = widget.state.bookingModel ?? 'MULTI_UNIT';
    final kind = defaultUnitKind(type, model);
    setState(() {
      _units = [
        ..._units,
        ListingUnitDraft(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          kind: kind,
          name: '',
          pricingUnit: defaultPricingUnit(kind),
          details: kind == 'HOSTEL_DORM' ? const {'gender': 'MIXED'} : const {},
        ),
      ];
    });
    _emit();
  }

  void _update(int index, ListingUnitDraft unit) {
    setState(() {
      _units = [..._units]..[index] = unit;
    });
    _emit();
  }

  void _remove(int index) {
    setState(() {
      _units = [..._units]..removeAt(index);
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.state.propertyType ?? 'PROPERTY';
    final title = switch (type) {
      'HOSTEL' => 'Add dorms and private rooms',
      'HOTEL' => 'Add hotel room types',
      'RIAD' => 'Add riad room types',
      _ => 'Add bookable units',
    };
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
            'Create categories and quantities, not every individual door.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          if (_units.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                'Add at least one room, dorm, or unit with a valid price.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ..._units.asMap().entries.map(
                (entry) => _UnitEditor(
                  key: ValueKey(entry.value.id),
                  index: entry.key,
                  unit: entry.value,
                  propertyType: widget.state.propertyType ?? 'APARTMENT',
                  bookingModel: widget.state.bookingModel ?? '',
                  onChanged: (unit) => _update(entry.key, unit),
                  onRemove: () => _remove(entry.key),
                ),
              ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addUnit,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                type == 'HOSTEL' ? 'Add bed or room type' : 'Add room type',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE8507A),
                side: const BorderSide(color: Color(0xFFE8507A)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _UnitEditor extends StatelessWidget {
  const _UnitEditor({
    super.key,
    required this.index,
    required this.unit,
    required this.propertyType,
    required this.bookingModel,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final ListingUnitDraft unit;
  final String propertyType;
  final String bookingModel;
  final ValueChanged<ListingUnitDraft> onChanged;
  final VoidCallback onRemove;

  bool get _canChooseHostelKind =>
      propertyType == 'HOSTEL' && bookingModel == 'DORM_AND_PRIVATE';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Type ${index + 1}',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFB91C1C),
                tooltip: 'Remove',
              ),
            ],
          ),
          if (_canChooseHostelKind) ...[
            DropdownButtonFormField<String>(
              initialValue: unit.kind,
              decoration: const InputDecoration(labelText: 'Accommodation'),
              items: const [
                DropdownMenuItem(
                  value: 'HOSTEL_DORM',
                  child: Text('Shared dorm beds'),
                ),
                DropdownMenuItem(
                  value: 'HOSTEL_PRIVATE',
                  child: Text('Private room'),
                ),
              ],
              onChanged: (kind) {
                if (kind == null) return;
                onChanged(
                  unit.copyWith(
                    kind: kind,
                    pricingUnit: defaultPricingUnit(kind),
                    details: kind == 'HOSTEL_DORM' ? {'gender': 'MIXED'} : {},
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
          TextFormField(
            initialValue: unit.name,
            decoration: InputDecoration(
              labelText: 'Name *',
              hintText: unit.kind == 'HOSTEL_DORM'
                  ? '6-bed mixed dorm'
                  : 'Standard double',
            ),
            onChanged: (value) => onChanged(unit.copyWith(name: value)),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: unit.bedConfig,
            decoration: const InputDecoration(
              labelText: 'Bed configuration',
              hintText: '1 queen bed / 6 bunk beds',
            ),
            onChanged: (value) => onChanged(unit.copyWith(bedConfig: value)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  label: 'Quantity *',
                  initial: unit.quantity.toString(),
                  onChanged: (value) => onChanged(
                      unit.copyWith(quantity: int.tryParse(value) ?? 0)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _numberField(
                  label: 'Max guests *',
                  initial: unit.maxGuests.toString(),
                  onChanged: (value) => onChanged(
                    unit.copyWith(maxGuests: int.tryParse(value) ?? 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  label: 'Size (m²)',
                  initial: unit.sizeSqm?.toStringAsFixed(0) ?? '',
                  onChanged: (value) => onChanged(
                    unit.copyWith(sizeSqm: double.tryParse(value)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _numberField(
                  label: unit.pricingUnit == 'BED_NIGHT'
                      ? 'MAD / bed *'
                      : 'MAD / room *',
                  initial: unit.basePrice > 0
                      ? unit.basePrice.toStringAsFixed(0)
                      : '',
                  onChanged: (value) => onChanged(
                    unit.copyWith(basePrice: double.tryParse(value) ?? 0),
                  ),
                ),
              ),
            ],
          ),
          if (unit.kind == 'HOSTEL_DORM') ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: (unit.details['gender'] ?? 'MIXED').toString(),
              decoration: const InputDecoration(labelText: 'Dorm gender'),
              items: const [
                DropdownMenuItem(value: 'MIXED', child: Text('Mixed')),
                DropdownMenuItem(value: 'FEMALE', child: Text('Female only')),
                DropdownMenuItem(value: 'MALE', child: Text('Male only')),
              ],
              onChanged: (value) {
                if (value == null) return;
                onChanged(
                  unit.copyWith(details: {...unit.details, 'gender': value}),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _numberField({
    required String label,
    required String initial,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initial,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }
}
