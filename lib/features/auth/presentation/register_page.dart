import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../navigation/app_routes.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import 'widgets/country_search_sheet.dart';
import 'widgets/radio_option_card.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  DateTime? _selectedDob;
  bool? _isMoroccan;
  String? _selectedCountry;
  bool _showCountryField = false;
  bool _hasTriedSubmit = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (ctx, child) => Theme(
        data: ThemeData(
          colorScheme: const ColorScheme.light(primary: Color(0xFFE8507A)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _openCountrySheet() async {
    final result = await CountrySearchSheet.show(
      context,
      selected: _selectedCountry,
    );
    if (result != null) {
      setState(() => _selectedCountry = result);
    }
  }

  void _onContinue() {
    setState(() => _hasTriedSubmit = true);

    final nameWords = _fullNameController.text
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    if (nameWords.length < 2 ||
        _selectedDob == null ||
        _isMoroccan == null ||
        _cityController.text.trim().isEmpty ||
        (_isMoroccan == false && _selectedCountry == null)) {
      return;
    }

    context.read<AuthBloc>().add(AuthKycSubmitted(
          fullName: _fullNameController.text.trim(),
          dateOfBirth: _selectedDob!,
          isMoroccan: _isMoroccan!,
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          city: _cityController.text.trim(),
          nationality: _isMoroccan! ? 'MA' : _selectedCountry,
        ));
  }

  // ─── Private helper widgets ─────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B5460),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FocusTextField(controller: controller, hint: hint),
        if (error != null) _buildError(error),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildError(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Color(0xFFDC2626)),
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return Center(
      child: Container(
        width: 100,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1118).withOpacity(0.15),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthError &&
            !state.isOtpError &&
            !state.isPinError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        // Validation errors
        final nameError = _hasTriedSubmit &&
                _fullNameController.text
                        .trim()
                        .split(' ')
                        .where((w) => w.isNotEmpty)
                        .length <
                    2
            ? 'Please enter your full name'
            : null;

        return Scaffold(
          backgroundColor: const Color(0xFFFDFBFC),
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: const Color(0xFFFDFBFC),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Color(0xFF1A1118), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        // Inline header
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF0F3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(Icons.person_outline,
                                    size: 18, color: Color(0xFFE8507A)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1118),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tell us a bit about yourself',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B5460),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Full name
                        _buildLabel('Full name *'),
                        _buildInput(
                          controller: _fullNameController,
                          hint: 'Enter full name as on document',
                          error: nameError,
                        ),

                        _buildLabel('Email'),
                        _buildInput(
                          controller: _emailController,
                          hint: 'name@example.com',
                        ),

                        // Date of birth
                        _buildLabel('Date of Birth *'),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedDob != null
                                    ? const Color(0xFFE8507A)
                                    : const Color(0xFFEDE0E5),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _selectedDob != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(_selectedDob!)
                                  : 'DD/MM/YYYY',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDob != null
                                    ? const Color(0xFF1A1118)
                                    : const Color(0xFF9E8A93),
                              ),
                            ),
                          ),
                        ),
                        if (_hasTriedSubmit && _selectedDob == null) ...[
                          _buildError('Please enter your date of birth'),
                        ],
                        const SizedBox(height: 10),

                        _buildLabel('City *'),
                        _buildInput(
                          controller: _cityController,
                          hint: 'Casablanca',
                          error: _hasTriedSubmit &&
                                  _cityController.text.trim().isEmpty
                              ? 'Please enter your city'
                              : null,
                        ),

                        // Moroccan citizenship question
                        _buildLabel('Are you a Moroccan citizen? *'),

                        RadioOptionCard(
                          label: 'Yes, I am Moroccan',
                          isSelected: _isMoroccan == true,
                          onTap: () => setState(() {
                            _isMoroccan = true;
                            _showCountryField = false;
                            _selectedCountry = null;
                          }),
                        ),

                        RadioOptionCard(
                          label: 'No, I am not Moroccan',
                          isSelected: _isMoroccan == false,
                          onTap: () => setState(() {
                            _isMoroccan = false;
                            _showCountryField = true;
                          }),
                        ),

                        if (_hasTriedSubmit && _isMoroccan == null)
                          _buildError('Please select an option'),

                        // Country field (animated)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          child: _showCountryField
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 10),
                                    _buildLabel('Country of Citizenship *'),
                                    GestureDetector(
                                      onTap: _openCountrySheet,
                                      child: Container(
                                        height: 56,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _selectedCountry != null
                                                ? const Color(0xFFE8507A)
                                                : const Color(0xFFEDE0E5),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _selectedCountry ??
                                                  'Select Country',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: _selectedCountry != null
                                                    ? const Color(0xFF1A1118)
                                                    : const Color(0xFF9E8A93),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 20,
                                              color: Color(0xFF9E8A93),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (_hasTriedSubmit &&
                                        _selectedCountry == null)
                                      _buildError('Please select your country'),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Bottom button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
                  child: GestureDetector(
                    onTap: isLoading ? null : _onContinue,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8507A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                _buildHomeIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Private focus-styled text field ─────────────────────────────────────────

class _FocusTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _FocusTextField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1A1118),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Color(0xFF9E8A93),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEDE0E5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8507A), width: 1.5),
        ),
      ),
    );
  }
}
