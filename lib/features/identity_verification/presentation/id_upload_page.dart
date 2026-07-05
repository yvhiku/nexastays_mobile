import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../navigation/app_routes.dart';
import '../domain/entities/verification.dart';
import '../domain/entities/verification.dart';
import 'bloc/verification_cubit.dart';

class IdUploadPage extends StatefulWidget {
  const IdUploadPage({super.key});

  @override
  State<IdUploadPage> createState() => _IdUploadPageState();
}

class _IdUploadPageState extends State<IdUploadPage> {
  IdType? _selectedIdType;
  String? _selectedCountry;

  final List<String> _countries = [
    'DZ Algeria',
    'EG Egypt',
    'FR France',
    'DE Germany',
    'MA Morocco',
    'US United States',
    'UK United Kingdom',
  ];

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Country of Citizenship',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Country...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE8507A)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _countries.length,
                      itemBuilder: (context, index) {
                        final country = _countries[index];
                        final isSelected = _selectedCountry == country;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCountry = country;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            color: isSelected
                                ? const Color(0xFFFFF0F5)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: Text(
                              country,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFFE8507A)
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue =
        _selectedIdType != null && _selectedCountry != null;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Document Icon + Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description,
                        color: Color(0xFFE8507A), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Document Verification',
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
                'Please verify your identity with a government document',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  ),
              ),
              const SizedBox(height: 32),

              // Select Document type
              const Text(
                'Select Document type *',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  ),
              ),
              const SizedBox(height: 16),
              _buildTypeOption(
                type: IdType.passport,
                title: 'Passport',
                subtitle: 'International travel document',
                icon: Icons.flight_takeoff,
              ),
              const SizedBox(height: 12),
              _buildTypeOption(
                type: IdType.cnie,
                title: 'National ID Card',
                subtitle: 'From your country',
                icon: Icons.badge,
              ),
              const SizedBox(height: 12),
              _buildTypeOption(
                type: IdType.drivingLicense,
                title: 'Driver\'s License',
                subtitle: 'Valid government ID',
                icon: Icons.directions_car,
              ),
              const SizedBox(height: 32),

              // Country of Citizenship
              const Text(
                'Country of Citizenship *',
                style: TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _showCountryPicker,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedCountry != null
                          ? const Color(0xFFE8507A)
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _selectedCountry ?? 'Select Country',
                    style: TextStyle(
                      color: _selectedCountry != null
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontWeight: _selectedCountry != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
                    ],
                  ),
                ),
              ),

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
                            context
                                .read<VerificationCubit>()
                                .selectIdType(_selectedIdType!);
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
                      'Continue to verification',
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
    );
  }

  Widget _buildTypeOption({
    required IdType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _selectedIdType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIdType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFE8507A) : const Color(0xFFF3F4F6),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF3B82F6), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFE8507A)
                          : const Color(0xFF1A1A2E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFF6B9D)
                          : const Color(0xFF9CA3AF),
                      fontSize: 11,
                      ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? const Color(0xFFE8507A) : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE8507A)
                      : const Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
