import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../navigation/app_routes.dart';
import '../../../core/utils/open_external_url.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import 'bloc/profile_cubit.dart';
import 'bloc/profile_state.dart';

// =============================================================================
// Settings Page
// =============================================================================

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              curr is AuthUnauthenticated && prev is! AuthUnauthenticated,
          listener: (context, state) {
            if (!context.mounted) return;
            context.go(AppRoutes.login);
          },
        ),
      ],
      child: Scaffold(
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
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1A1A2E),
            ),
          ),
          centerTitle: false,
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final prefs = state is ProfileLoaded
                ? state.notificationPreferences
                : <String, bool>{};
            final lang = state is ProfileLoaded ? state.languageCode : 'en';

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
              // ── Notifications ──────────────────────────────────
              _sectionLabel('Notifications'),
              _notifSwitch(
                context,
                prefs: prefs,
                key: 'booking_confirmed',
                title: 'Booking confirmations',
                subtitle: 'Get notified when a booking is confirmed',
              ),
              _notifSwitch(
                context,
                prefs: prefs,
                key: 'new_messages',
                title: 'New messages',
                subtitle: 'Alerts for messages from hosts',
              ),
              _notifSwitch(
                context,
                prefs: prefs,
                key: 'booking_reminders',
                title: 'Booking reminders',
                subtitle: 'Reminder 24h before check-in',
              ),
              _notifSwitch(
                context,
                prefs: prefs,
                key: 'promotions',
                title: 'Promotional offers',
                subtitle: 'Deals and special offers from Nexa',
              ),
              _notifSwitch(
                context,
                prefs: prefs,
                key: 'dispute_updates',
                title: 'Dispute updates',
                subtitle: 'Status changes on open disputes',
              ),

              // ── Language ───────────────────────────────────────
              _sectionLabel('Language'),
              _languageOption(context,
                  flag: '🇬🇧', name: 'English', code: 'en', current: lang),
              _languageOption(context,
                  flag: '🇲🇦', name: 'العربية', code: 'ar', current: lang),
              _languageOption(context,
                  flag: '🇫🇷', name: 'Français', code: 'fr', current: lang),

              // ── Privacy & Security ─────────────────────────────
              _sectionLabel('Privacy & Security'),
              _actionRow(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                onTap: () {
                  // Navigate to edit profile password section.
                  _showChangePasswordSheet(context);
                },
              ),
              _actionRow(
                icon: Icons.delete_outline_rounded,
                label: 'Delete Account',
                onTap: () => _showDeleteDialog(context),
              ),
              _actionRow(
                icon: Icons.policy_outlined,
                label: 'Privacy Policy',
                onTap: () =>
                    launchUrl(Uri.parse('https://nexastays.ma/privacy')),
              ),
              _actionRow(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () => openExternalUrl(context, NexaLegalUrls.termsEn),
              ),
              _actionRow(
                icon: Icons.cookie_outlined,
                label: 'Cookie Preferences',
                onTap: () =>
                    launchUrl(Uri.parse('https://nexastays.ma/cookies')),
              ),

              // ── About ─────────────────────────────────────────
              _sectionLabel('About'),
              _infoRow('App version', '1.0.0 (beta)'),
              _infoRow('Build', '2026.03'),

              const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  // ── Notification switch ──────────────────────────────────────────────

  Widget _notifSwitch(
    BuildContext context, {
    required Map<String, bool> prefs,
    required String key,
    required String title,
    required String subtitle,
  }) {
    final value = prefs[key] ?? true;
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF3F4F6), width: 0.5),
        ),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: (v) =>
            context.read<ProfileCubit>().updateNotificationPref(key, v),
        activeColor: const Color(0xFFE8507A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF1A1A2E),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  // ── Language option ──────────────────────────────────────────────────

  Widget _languageOption(
    BuildContext context, {
    required String flag,
    required String name,
    required String code,
    required String current,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Color(0xFF1A1A2E),
        ),
      ),
      trailing: Radio<String>(
        value: code,
        groupValue: current,
        activeColor: const Color(0xFFE8507A),
        onChanged: (v) {
          if (v != null) context.read<ProfileCubit>().updateLanguage(v);
        },
      ),
      onTap: () => context.read<ProfileCubit>().updateLanguage(code),
    );
  }

  // ── Action row ───────────────────────────────────────────────────────

  Widget _actionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: const Color(0xFFE8507A), size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: Color(0xFFD1D5DB), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Info row ─────────────────────────────────────────────────────────

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1A1A2E),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // ── Change Password Bottom Sheet ─────────────────────────────────────

  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),
            _passwordField(currentCtrl, 'Current password'),
            const SizedBox(height: 12),
            _passwordField(newCtrl, 'New password'),
            const SizedBox(height: 12),
            _passwordField(confirmCtrl, 'Confirm new password'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (newCtrl.text != confirmCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Passwords do not match'),
                        backgroundColor: const Color(0xFFDC2626),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  context.read<ProfileCubit>().changePassword(
                        currentPassword: currentCtrl.text,
                        newPassword: newCtrl.text,
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8507A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF9CA3AF),
        ),
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
          borderSide: const BorderSide(color: Color(0xFFE8507A)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  // ── Delete Dialog ────────────────────────────────────────────────────

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete account?',
          style: TextStyle(
              fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This action is permanent. All your data will be deleted.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileCubit>().deleteAccount();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
