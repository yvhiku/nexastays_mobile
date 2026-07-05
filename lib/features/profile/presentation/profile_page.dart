import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../navigation/app_routes.dart';
import '../../../core/utils/open_external_url.dart';
import 'widgets/profile_photo_avatar.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../auth/domain/entities/user.dart';
import '../../identity_verification/domain/entities/verification.dart';
import 'bloc/profile_cubit.dart';
import 'bloc/profile_state.dart';

// =============================================================================
// Profile Page
// =============================================================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr is AuthUnauthenticated && prev is! AuthUnauthenticated,
      listener: (context, state) {
        if (!context.mounted) return;
        context.go(AppRoutes.login);
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: _onStateChange,
        builder: (context, state) {
          if (state is ProfileLoading) return _buildShimmer();
          if (state is ProfileDeleting) return _buildDeleting();
          if (state is ProfileLoaded) return _buildLoaded(context, state);
          if (state is ProfileError && state.currentUser != null) {
            // Show profile with error SnackBar.
            return _buildLoadedFromUser(context, state.currentUser!);
          }
          if (state is ProfileError) return _buildError(context, state.message);
          return _buildShimmer();
        },
      ),
    ),
    );
  }

  void _onStateChange(BuildContext context, ProfileState state) {
    if (state is ProfileUpdateSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated ✓',
              style: TextStyle(fontSize: 13)),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (state is PasswordChangeSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed ✓',
              style: TextStyle(fontSize: 13)),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (state is ProfileError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message,
              style: const TextStyle(fontSize: 13)),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ── Loaded (from ProfileLoaded state) ────────────────────────────────

  Widget _buildLoaded(BuildContext context, ProfileLoaded state) {
    return _buildBody(
      context,
      user: state.user,
      totalBookings: state.totalBookings,
      savedCount: state.savedPropertiesCount,
      verificationStatus: state.verificationStatus,
      isHost: state.user.isHost,
      profilePhotoRevision: state.profilePhotoRevision,
    );
  }

  Widget _buildLoadedFromUser(BuildContext context, User user) {
    return _buildBody(
      context,
      user: user,
      totalBookings: 0,
      savedCount: 0,
      verificationStatus: VerificationStatus.notStarted,
      isHost: user.isHost,
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required User user,
    required int totalBookings,
    required int savedCount,
    required VerificationStatus verificationStatus,
    required bool isHost,
    int profilePhotoRevision = 0,
  }) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Custom app bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push(AppRoutes.settings),
                    icon: const Icon(Icons.settings_outlined,
                        color: Color(0xFF374151), size: 22),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Header card ──────────────────────────────────
                  _buildHeaderCard(
                    context,
                    user,
                    profilePhotoRevision: profilePhotoRevision,
                  ),
                  const SizedBox(height: 16),

                  // ── Stats row ────────────────────────────────────
                  _buildStatsRow(
                    totalBookings: totalBookings,
                    savedCount: savedCount,
                    verificationStatus: verificationStatus,
                  ),

                  // ── My Activity ──────────────────────────────────
                  const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      'My Activity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'My Bookings',
                    subtitle: 'View all your trips',
                    onTap: () => context.push(AppRoutes.myBookings),
                  ),
                  _buildActionCard(
                    icon: Icons.favorite_outline_rounded,
                    label: 'Saved Stays',
                    subtitle: '$savedCount properties saved',
                    onTap: () => context.go(AppRoutes.saved),
                  ),
                  _buildActionCard(
                    icon: Icons.badge_outlined,
                    label: 'Verification',
                    subtitle: _verificationSubtitle(verificationStatus),
                    onTap: () => context.push(AppRoutes.verificationStatus),
                  ),
                  _buildActionCard(
                    icon: Icons.home_work_outlined,
                    label: 'Host Dashboard',
                    subtitle: 'Manage your listings',
                    onTap: () => context.push(AppRoutes.hostDashboard),
                  ),
                  _buildActionCard(
                    icon: Icons.rocket_launch_outlined,
                    label: 'Become a Host',
                    subtitle: 'List your property',
                    onTap: () => context.push(AppRoutes.hostRegister),
                  ),

                  // ── Settings & Support ───────────────────────────
                  const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      'Settings & Support',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    subtitle: 'Notifications, language, privacy',
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  _buildActionCard(
                    icon: Icons.info_outline_rounded,
                    label: 'About Nexa Stays',
                    subtitle: 'Our mission & trust',
                    onTap: () => context.push(AppRoutes.about),
                  ),
                  _buildActionCard(
                    icon: Icons.help_outline_rounded,
                    label: 'Contact Us',
                    subtitle: 'Help, support, partnerships',
                    onTap: () => context.push(AppRoutes.contact),
                  ),
                  _buildActionCard(
                    icon: Icons.lock_outline_rounded,
                    label: 'Privacy Policy',
                    subtitle: null,
                    onTap: () => launchUrl(
                      Uri.parse('https://nexastays.ma/privacy'),
                    ),
                  ),
                  _buildActionCard(
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    subtitle: null,
                    onTap: () => openExternalUrl(context, NexaLegalUrls.termsEn),
                  ),

                  // ── Logout ───────────────────────────────────────
                  const SizedBox(height: 24),
                  _buildLogoutButton(context),
                  const SizedBox(height: 16),

                  // ── Delete account ───────────────────────────────
                  _buildDeleteAccountButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header card ──────────────────────────────────────────────────────

  Widget _buildHeaderCard(
    BuildContext context,
    User user, {
    int profilePhotoRevision = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8507A), Color(0xFFFF6B9D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar.
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ProfilePhotoAvatar(
                  profilePhotoUrl: user.profilePhotoUrl,
                  radius: 32,
                  cacheRevision: profilePhotoRevision,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  fallback: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Name, phone, email.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    if (user.email != null && user.email!.isNotEmpty)
                      Text(
                        user.email!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),

                    // Verification badge.
                    GestureDetector(
                      onTap: user.isVerified
                          ? null
                          : () => context.push(AppRoutes.verifyId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(user.isVerified ? 0.2 : 0.15),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          user.isVerified
                              ? '✓ Verified Member'
                              : '⚠ Not verified',
                          style: TextStyle(
                            fontWeight: user.isVerified
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Edit Profile button.
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: () => context.push(AppRoutes.editProfile),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ────────────────────────────────────────────────────────

  Widget _buildStatsRow({
    required int totalBookings,
    required int savedCount,
    required VerificationStatus verificationStatus,
  }) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '$totalBookings',
            label: 'Bookings',
            valueColor: const Color(0xFFE8507A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '$savedCount',
            label: 'Saved',
            valueColor: const Color(0xFFE8507A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: _buildVerificationStat(verificationStatus)),
      ],
    );
  }

  Widget _buildVerificationStat(VerificationStatus status) {
    final (icon, label, color) = switch (status) {
      VerificationStatus.approved => ('✓', 'Verified', const Color(0xFF16A34A)),
      VerificationStatus.pending || VerificationStatus.submitted => (
          '⏳',
          'Pending',
          const Color(0xFFD97706)
        ),
      _ => ('?', 'Unverified', const Color(0xFF9CA3AF)),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(icon,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              )),
        ],
      ),
    );
  }

  String _verificationSubtitle(VerificationStatus status) => switch (status) {
        VerificationStatus.approved => 'Identity verified',
        VerificationStatus.pending ||
        VerificationStatus.submitted =>
          'Verification pending',
        VerificationStatus.rejected => 'Verification rejected',
        _ => 'Not yet verified',
      };

  // ── Action card ──────────────────────────────────────────────────────

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    String? subtitle,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ],
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

  // ── Logout button ────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out?',
            style:
                TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("You'll need to sign in again.",
            style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileCubit>().logout();
            },
            child: const Text('Sign Out',
                style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }

  // ── Delete account button ────────────────────────────────────────────

  Widget _buildDeleteAccountButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => _showDeleteDialog(context),
        child: const Text(
          'Delete account',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete account?',
            style:
                TextStyle(fontWeight: FontWeight.bold)),
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

  // ── Shimmer skeleton ─────────────────────────────────────────────────

  Widget _buildShimmer() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // App bar placeholder.
              const SizedBox(height: 20),
              // Header card skeleton.
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 16),
              // Stats row skeleton.
              Row(
                children: List.generate(
                  3,
                  (_) => Expanded(
                    child: Container(
                      height: 70,
                      margin: EdgeInsets.only(right: _ < 2 ? 10 : 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Action rows skeleton.
              ...List.generate(
                5,
                (_) => Container(
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Deleting overlay ─────────────────────────────────────────────────

  Widget _buildDeleting() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
          ),
          SizedBox(height: 16),
          Text(
            'Deleting your account...',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<ProfileCubit>().loadProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8507A),
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Stat Card
// =============================================================================

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
