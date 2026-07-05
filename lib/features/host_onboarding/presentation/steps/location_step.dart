import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../search/presentation/widgets/city_selector.dart';
import '../bloc/host_onboarding_bloc.dart';
import '../bloc/host_onboarding_event.dart';
import '../bloc/host_onboarding_state.dart';

class LocationStep extends StatefulWidget {
  const LocationStep({
    super.key,
    required this.state,
    required this.bloc,
  });

  final HostOnboardingState state;
  final HostOnboardingBloc bloc;

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.propertyName);
    _cityController = TextEditingController(text: widget.state.city);
    _neighborhoodController =
        TextEditingController(text: widget.state.neighborhood);
    _addressController = TextEditingController(text: widget.state.exactAddress);

    // Add listeners to dispatch events
    _nameController.addListener(_dispatchBasicsSaved);
    _cityController.addListener(_dispatchBasicsSaved);
    _neighborhoodController.addListener(_dispatchBasicsSaved);
    _addressController.addListener(_dispatchBasicsSaved);
  }

  @override
  void dispose() {
    _nameController.removeListener(_dispatchBasicsSaved);
    _cityController.removeListener(_dispatchBasicsSaved);
    _neighborhoodController.removeListener(_dispatchBasicsSaved);
    _addressController.removeListener(_dispatchBasicsSaved);
    _nameController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _dispatchBasicsSaved() {
    widget.bloc.add(
      HostBasicsSaved(
        propertyName: _nameController.text.trim(),
        city: _cityController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        exactAddress: _addressController.text.trim(),
        beds: widget.state.beds,
        bathrooms: widget.state.bathrooms,
      ),
    );
  }

  void _updateBeds(int beds) {
    widget.bloc.add(
      HostBasicsSaved(
        propertyName: _nameController.text.trim(),
        city: _cityController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        exactAddress: _addressController.text.trim(),
        beds: beds,
        bathrooms: widget.state.bathrooms,
      ),
    );
  }

  void _updateBathrooms(int bathrooms) {
    widget.bloc.add(
      HostBasicsSaved(
        propertyName: _nameController.text.trim(),
        city: _cityController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        exactAddress: _addressController.text.trim(),
        beds: widget.state.beds,
        bathrooms: bathrooms,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property basics',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell guests exactly what they\'re booking.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),

          // Fields
          _buildInputField(
            label: 'Property Name *',
            hint: 'e.g. Golden Medina Courtyard',
            controller: _nameController,
          ),
          const SizedBox(height: 14),

          // City selector field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'City *',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  // Hide keyboard
                  FocusScope.of(context).unfocus();
                  final selectedCity = await CitySelector.show(
                    context,
                    current: _cityController.text,
                  );
                  if (selectedCity != null) {
                    _cityController.text = selectedCity;
                  }
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _cityController.text.isEmpty
                        ? 'e.g. Marrakech'
                        : _cityController.text,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: _cityController.text.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildInputField(
            label: 'Neighborhood *',
            hint: 'e.g. Medina',
            controller: _neighborhoodController,
          ),
          const SizedBox(height: 14),

          _buildInputField(
            label: 'Exact Address *',
            hint: 'Street, building, floor',
            controller: _addressController,
            activeColor: const Color(0xFFE8507A),
          ),
          const SizedBox(height: 12),

          // Privacy Info Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: const Border(
                left: BorderSide(color: Color(0xFFF59E0B), width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Exact address shown only after booking confirmed.',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Steppers (Beds / Bathrooms)
          Row(
            children: [
              Expanded(
                child: _buildStepper(
                  label: 'Beds',
                  value: widget.state.beds,
                  onChanged: _updateBeds,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStepper(
                  label: 'Bathrooms',
                  value: widget.state.bathrooms,
                  onChanged: _updateBathrooms,
                ),
              ),
            ],
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
    Color? activeColor,
  }) {
    return Column(
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
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: const Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
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
              borderSide:
                  BorderSide(color: activeColor ?? const Color(0xFF1A1A2E), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepperButton(
                icon: Icons.remove,
                onTap: value > 1 ? () => onChanged(value - 1) : null,
              ),
              Text(
                '$value',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              _buildStepperButton(
                icon: Icons.add,
                onTap: value < 20 ? () => onChanged(value + 1) : null, // Arbitrary max
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final bool isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isEnabled ? const Color(0xFFE5E7EB) : Colors.transparent,
          ),
          color: isEnabled ? Colors.white : const Color(0xFFF3F4F6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? const Color(0xFF1A1A2E) : const Color(0xFFD1D5DB),
        ),
      ),
    );
  }
}
