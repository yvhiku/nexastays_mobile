import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../navigation/app_routes.dart';
import '../domain/entities/verification.dart';
import 'bloc/verification_cubit.dart';

class DocumentTypePage extends StatefulWidget {
  const DocumentTypePage({super.key});

  @override
  State<DocumentTypePage> createState() => _DocumentTypePageState();
}

class _DocumentTypePageState extends State<DocumentTypePage> {
  IdType? _selectedType;
  String? _selectedCountry;

  static const Color _primary = Color(0xFFE8507A);
  static const Color _bg = Colors.white;
  static const Color _ps = Color(0xFFFFF0F5);
  static const Color _textPrimary = Color(0xFF1A1A2E);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);

  final List<String> _countries = [
    'dz Algeria',
    'EG Egypt',
    'FR France',
    'DE Germany',
    'MA Morocco',
    'ES Spain',
    'GB United Kingdom',
    'US United States',
  ];

  void _showCountryDropdown() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search Country...',
                  hintStyle: GoogleFonts.dmSans(color: _textSecondary, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final c = _countries[index];
                    final isSelected = c == _selectedCountry;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedCountry = c);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? _ps : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c,
                          style: GoogleFonts.dmSans(
                            color: isSelected ? _primary : _textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocOption({
    required IdType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _ps : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? _primary : _border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _primary : _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: isSelected ? _primary.withOpacity(0.7) : _textSecondary,
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
                border: Border.all(
                  color: isSelected ? _primary : _border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: _ps, borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.center,
                          child: const Icon(Icons.description_outlined, color: _primary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text('Document Verification', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: _textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Please verify your identity with a government document', style: GoogleFonts.dmSans(fontSize: 12, color: _textSecondary)),
                    
                    const SizedBox(height: 32),
                    
                    Text('Select Document type *', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: _textPrimary)),
                    const SizedBox(height: 12),
                    
                    _buildDocOption(
                      type: IdType.passport,
                      title: 'Passport',
                      subtitle: 'International travel document',
                      icon: Icons.flight,
                    ),
                    _buildDocOption(
                      type: IdType.cnie,
                      title: 'National ID Card',
                      subtitle: 'From your country',
                      icon: Icons.badge,
                    ),
                    _buildDocOption(
                      type: IdType.drivingLicense,
                      title: 'Driver\'s License',
                      subtitle: 'Valid government ID',
                      icon: Icons.directions_car,
                    ),
                    
                    const SizedBox(height: 24),
                    Text('Country of Citizenship *', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: _textPrimary)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showCountryDropdown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: _selectedCountry != null ? _primary : _border, width: 1.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedCountry ?? 'Select Country',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: _selectedCountry != null ? _textPrimary : _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedType != null && _selectedCountry != null)
                      ? () {
                          // Save selection to cubit
                          context.read<VerificationCubit>().selectIdType(_selectedType!);
                          // Navigate to capture page
                          context.push(AppRoutes.idCapture);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    disabledBackgroundColor: _primary.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  ),
                  child: Text(
                    'Continue to verification',
                    style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
