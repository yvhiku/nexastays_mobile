import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// Contact Form Page
// =============================================================================

class ContactFormPage extends StatefulWidget {
  const ContactFormPage({super.key, this.reason});

  final String? reason;

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  late final TextEditingController _reasonController;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.reason ?? 'Support');
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    // Scaffold UI logic for submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message sent successfully!'),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    context.pop();
  }

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Title ─────────────────────────────────────────────────────
            Text(
              'Send us a message',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),

            // ── Subtitle ──────────────────────────────────────────────────
            Text(
              "We'll get back to you as soon as possible.",
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),

            // ── Form Fields ───────────────────────────────────────────────
            _FormFieldLabel(text: 'Reason *'),
            _CustomTextField(
              controller: _reasonController,
              hintText: 'Support',
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormFieldLabel(text: 'Full Name *'),
                      _CustomTextField(
                        controller: _nameController,
                        hintText: 'Ahmed',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormFieldLabel(text: 'Phone *'),
                      _CustomTextField(
                        controller: _phoneController,
                        hintText: '+212',
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormFieldLabel(text: 'Email *'),
                      _CustomTextField(
                        controller: _emailController,
                        hintText: 'you@email.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormFieldLabel(text: 'City'),
                      _CustomTextField(
                        controller: _cityController,
                        hintText: 'Optional',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _FormFieldLabel(text: 'Message *'),
            _CustomTextField(
              controller: _messageController,
              hintText: 'How can we help?',
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // ── Submit Button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8507A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Send Message',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Disclaimer ────────────────────────────────────────────────
            Center(
              child: Text(
                'Your details are used only to respond to your request.',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Form Helpers
// ═════════════════════════════════════════════════════════════════════════════

class _FormFieldLabel extends StatelessWidget {
  const _FormFieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        color: const Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: const Color(0xFF9CA3AF),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
          borderSide: const BorderSide(color: Color(0xFFE8507A)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
