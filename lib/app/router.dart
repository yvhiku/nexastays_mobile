// =============================================================================
// NexaStays App Router
// =============================================================================
// Centralised routing configuration using go_router.
// All named routes are defined here with placeholder widgets for pages
// that have not yet been implemented.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design_system/tokens/colors.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/home/presentation/home_page.dart';
import '../features/search/presentation/search_page.dart';
import '../features/property/presentation/listings/listings_page.dart';
import '../features/host_dashboard/presentation/host_dashboard_page.dart';
import '../features/host_dashboard/presentation/host_calendar_page.dart';
import '../features/host_dashboard/presentation/host_insights_page.dart';
import '../features/host_dashboard/presentation/host_reviews_page.dart';
import '../features/host_dashboard/presentation/host_listing_edit_page.dart';
import '../features/host_dashboard/presentation/host_property_manage_page.dart';
import '../features/host_onboarding/presentation/host_register_page.dart';
import '../features/host_onboarding/presentation/bloc/host_onboarding_state.dart';

import '../features/home/presentation/bloc/home_cubit.dart';
import '../features/search/presentation/bloc/search_bloc.dart';
import '../features/host_dashboard/presentation/bloc/host_dashboard_cubit.dart';
import '../features/host_dashboard/presentation/bloc/host_property_manage_cubit.dart';
import '../features/host_onboarding/presentation/bloc/host_onboarding_bloc.dart';
import '../features/property/presentation/listings/bloc/listings_bloc.dart';
import '../features/property/presentation/detail/property_detail_page.dart';
import '../features/property/presentation/detail/bloc/property_detail_cubit.dart';
import '../features/booking/presentation/create/booking_page.dart';
import '../features/booking/presentation/create/confirm_booking_page.dart';
import '../features/booking/presentation/create/booking_success_page.dart';
import '../features/booking/presentation/create/bloc/booking_bloc.dart';
import '../features/booking/presentation/list/bookings_page.dart';
import '../features/booking/presentation/list/bloc/bookings_cubit.dart';
import '../features/booking/presentation/list/booking_detail_page.dart';
import '../features/booking/presentation/checkout/booking_checkout_page.dart';
import '../features/booking/domain/entities/booking.dart';

import '../features/auth/presentation/create_pin_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/auth/presentation/verify_phone_page.dart';
import '../features/identity_verification/presentation/bloc/verification_cubit.dart';
import '../features/identity_verification/presentation/id_upload_page.dart';
import '../features/identity_verification/presentation/selfie_page.dart';
import '../features/identity_verification/presentation/document_type_page.dart';
import '../features/identity_verification/presentation/id_capture_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../features/welcome/presentation/welcome_page.dart';
import '../features/main/presentation/main_shell_page.dart';
import 'di/injection.dart';

import '../features/profile/presentation/profile_page.dart';
import '../features/profile/presentation/edit_profile_page.dart';
import '../features/profile/presentation/settings_page.dart';
import '../features/profile/presentation/help_page.dart';
import '../features/profile/presentation/about_page.dart';
import '../features/profile/presentation/contact_page.dart';
import '../features/profile/presentation/contact_form_page.dart';
import '../features/profile/presentation/bloc/profile_cubit.dart';
import '../features/profile/presentation/verification_status_page.dart';
import '../features/wishlist/presentation/wishlist_page.dart';
import '../features/wishlist/presentation/bloc/wishlist_cubit.dart';
import '../features/dispute/presentation/open_dispute_page.dart';
import '../features/dispute/presentation/dispute_status_page.dart';
import '../features/dispute/presentation/bloc/dispute_cubit.dart';
import '../features/messaging/presentation/inbox/inbox_page.dart';
import '../features/messaging/presentation/inbox/inbox_cubit.dart';
import '../features/messaging/presentation/conversation/conversation_page.dart';
import '../features/messaging/presentation/conversation/conversation_cubit.dart';

import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../navigation/app_routes.dart';

// ─── GUARDS CONFIGURATION ──────────────────────────────────────────

const _publicRoutes = <String>{
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.verifyPhone,
  AppRoutes.createPin,
  AppRoutes.verifyId,
  AppRoutes.idCapture,
  AppRoutes.selfieCapture,
  AppRoutes.verificationStatus,
  '/welcome',
};

const _verificationRequiredRoutes = <String>{
  // AppRoutes.booking,        // Bypassed for testing
  // AppRoutes.confirmBooking, // Bypassed for testing
  AppRoutes.hostRegister,
};

// ─── TRANSITION HELPERS ──────────────────────────────────────────────

CustomTransitionPage<T> _buildPageWithTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  required RouteTransitionType transitionType,
}) {
  Duration duration;
  Curve curve;
  Offset? beginOffset;

  switch (transitionType) {
    case RouteTransitionType.fade:
      duration = const Duration(milliseconds: 200);
      curve = Curves.easeIn;
      break;
    case RouteTransitionType.slideRightToLeft:
      duration = const Duration(milliseconds: 250);
      curve = Curves.easeInOut;
      beginOffset = const Offset(1, 0);
      break;
    case RouteTransitionType.slideBottomToTop:
      duration = const Duration(milliseconds: 300);
      curve = Curves.easeOut;
      beginOffset = const Offset(0, 1);
      break;
  }

  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (transitionType == RouteTransitionType.fade) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: curve),
          child: child,
        );
      } else {
        return SlideTransition(
          position: Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: curve)),
          child: child,
        );
      }
    },
    transitionDuration: duration,
  );
}

enum RouteTransitionType { fade, slideRightToLeft, slideBottomToTop }

ProfileCubit _createProfileCubit(BuildContext context) {
  return ProfileCubit(
    updateProfileUseCase: getIt(),
    profileRepository: getIt(),
    wishlistRepository: getIt(),
    bookingRepository: getIt(),
    verificationRepository: getIt(),
    sessionManager: getIt(),
    localStorage: getIt(),
    // Must use the app-level AuthBloc so router redirects are in sync.
    authBloc: context.read<AuthBloc>(),
  );
}

/// Exposes the application's [GoRouter] instance.
class AppRouter {
  AppRouter._();

  /// [refreshListenable] should notify when [AuthBloc] emits so redirects
  /// re-evaluate after cached session restore (e.g. user was [AuthInitial]).
  static GoRouter createRouter(Listenable refreshListenable) {
    return GoRouter(
      refreshListenable: refreshListenable,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,

      // ─── GLOBAL REDIRECT (GUARDS) ────────────────────────────────────
      redirect: (BuildContext context, GoRouterState state) {
        final authState = context.read<AuthBloc>().state;
        final isAuthenticated = authState is AuthAuthenticated;
        final targetPath = state.matchedLocation;

        // GUARD 1 — Unauthenticated:
        if (!isAuthenticated && !_publicRoutes.contains(targetPath)) {
          return AppRoutes.login;
        }

        // GUARD 2 — Already authenticated:
        if (isAuthenticated &&
            (targetPath == AppRoutes.login || targetPath == AppRoutes.register)) {
          return AppRoutes.home;
        }

        // GUARD 2b — Logged-in users should not see first-run marketing screens:
        if (isAuthenticated &&
            (targetPath == AppRoutes.onboarding || targetPath == '/welcome')) {
          return AppRoutes.home;
        }

        // GUARD 3 & 4 — Unverified user trying to book/host:
        if (authState is AuthAuthenticated) {
          final user = authState.user;
          final isVerified = user.isVerified;
          if (!isVerified && _verificationRequiredRoutes.contains(targetPath)) {
            return AppRoutes.verifyId;
          }
        }

        return null;
      },

      // ─── ROUTE TREE ──────────────────────────────────────────────────
      routes: <RouteBase>[
      // ─── PUBLIC ROUTES ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SplashPage(),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const WelcomePage(),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const OnboardingPage(),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginPage(),
          transitionType: RouteTransitionType.slideRightToLeft,
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const RegisterPage(),
          transitionType: RouteTransitionType.slideRightToLeft,
        ),
      ),
      GoRoute(
        path: AppRoutes.verifyPhone,
        name: 'verifyPhone',
        pageBuilder: (context, state) {
          final phone = state.extra as String? ?? '';
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: VerifyPhonePage(phone: phone),
            transitionType: RouteTransitionType.slideRightToLeft,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createPin,
        name: 'createPin',
        pageBuilder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          String userId = '';
          if (authState is AuthAuthenticated) {
            userId = authState.user.id;
          } else if (authState is AuthPersonalInfoSaved) {
            userId = authState.user.id;
          } else if (authState is AuthOtpVerified) {
            userId = authState.user.id;
          }

          return _buildPageWithTransition(
            context: context,
            state: state,
            child: CreatePinPage(userId: userId),
            transitionType: RouteTransitionType.slideRightToLeft,
          );
        },
      ),

      // ─── IDENTITY VERIFICATION ──────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => BlocProvider<VerificationCubit>(
          create: (ctx) {
            final cubit = getIt<VerificationCubit>();
            final authState = ctx.read<AuthBloc>().state;
            String? userId;
            if (authState is AuthAuthenticated) {
              userId = authState.user.id;
            } else if (authState is AuthPersonalInfoSaved) {
              userId = authState.user.id;
            } else if (authState is AuthOtpVerified) {
              userId = authState.user.id;
            }
            if (userId != null) {
              cubit.initialize(userId);
            }
            return cubit;
          },
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.verifyId,
            name: 'verifyId',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const IdUploadPage(),
              transitionType: RouteTransitionType.slideRightToLeft,
            ),
          ),
          GoRoute(
            path: AppRoutes.selfieCapture,
            name: 'selfieCapture',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const SelfiePage(),
              transitionType: RouteTransitionType.fade,
            ),
          ),
          GoRoute(
            path: '/document-type',
            name: 'documentType',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const DocumentTypePage(),
              transitionType: RouteTransitionType.slideRightToLeft,
            ),
          ),
          GoRoute(
            path: AppRoutes.idCapture,
            name: 'idCapture',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const IdCapturePage(),
              transitionType: RouteTransitionType.slideRightToLeft,
            ),
          ),
        ],
      ),

      // ─── MAIN APP (BOTTOM NAV SHELL) ────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) => _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<HomeCubit>(
                        create: (_) => getIt<HomeCubit>(),
                      ),
                      BlocProvider<InboxCubit>.value(
                        value: getIt<InboxCubit>()..loadUnreadCount(),
                      ),
                    ],
                    child: const HomePage(),
                  ),
                  transitionType: RouteTransitionType.fade,
                ),
              ),
            ],
          ),
          // Branch 1: Explore
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                name: 'explore',
                pageBuilder: (context, state) => _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: BlocProvider<SearchBloc>(
                    create: (_) => getIt<SearchBloc>(),
                    child: const SearchPage(),
                  ),
                  transitionType: RouteTransitionType.fade,
                ),
              ),
            ],
          ),
          // Branch 2: Saved
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.saved,
                name: 'saved',
                pageBuilder: (context, state) => _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: BlocProvider<WishlistCubit>.value(
                    value: getIt<WishlistCubit>(),
                    child: const WishlistPage(),
                  ),
                  transitionType: RouteTransitionType.fade,
                ),
              ),
            ],
          ),
          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) => _buildPageWithTransition(
                  context: context,
                  state: state,
                  child: BlocProvider<ProfileCubit>(
                    create: (_) => _createProfileCubit(context)..loadProfile(),
                    child: const ProfilePage(),
                  ),
                  transitionType: RouteTransitionType.fade,
                ),
              ),
            ],
          ),
        ],
      ),

      // ─── SEARCH & LISTINGS ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.listings,
        name: 'listings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider<ListingsBloc>(
            create: (_) => getIt<ListingsBloc>(),
            child: const ListingsPage(),
          ),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.propertyDetailLegacy,
        redirect: (context, state) {
          final extra = state.extra;
          if (extra is String && extra.isNotEmpty) {
            return AppRoutes.propertyDetailOf(extra);
          }
          return AppRoutes.explore;
        },
      ),
      GoRoute(
        path: AppRoutes.propertyDetail,
        name: 'propertyDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider<PropertyDetailCubit>(
              create: (_) => getIt<PropertyDetailCubit>()..loadProperty(id),
              child: PropertyDetailPage(propertyId: id),
            ),
            transitionType: RouteTransitionType.fade,
          );
        },
      ),

      // ─── BOOKING FLOW ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.booking,
        name: 'booking',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider<BookingBloc>(
              create: (_) => getIt<BookingBloc>(),
              child: BookingPage(
                propertyId: args?['propertyId'] as String? ?? '',
                checkIn: args?['checkIn'] as DateTime?,
                checkOut: args?['checkOut'] as DateTime?,
                guests: args?['guests'] as int?,
              ),
            ),
            transitionType: RouteTransitionType.slideBottomToTop,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.confirmBooking,
        name: 'confirmBooking',
        pageBuilder: (context, state) {
          final bloc = state.extra as BookingBloc;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider<BookingBloc>.value(
              value: bloc,
              child: const ConfirmBookingPage(),
            ),
            transitionType: RouteTransitionType.slideBottomToTop,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookingSuccess,
        name: 'bookingSuccess',
        pageBuilder: (context, state) {
          final booking = state.extra as Booking?;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: booking != null
                ? BookingSuccessPage(booking: booking)
                : const _PlaceholderPage(title: 'Booking Success'),
            transitionType: RouteTransitionType.slideBottomToTop,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myBookings,
        name: 'myBookings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider<BookingsCubit>(
            create: (_) => getIt<BookingsCubit>()..loadBookings(),
            child: const BookingsPage(),
          ),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.bookingDetail,
        name: 'bookingDetail',
        pageBuilder: (context, state) {
          final booking = state.extra as Booking?;
          final id = state.pathParameters['id']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: booking != null
                ? BookingDetailPage(booking: booking)
                : _PlaceholderPage(title: 'Booking Detail', subtitle: id),
            transitionType: RouteTransitionType.fade,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.bookingCheckout,
        name: 'bookingCheckout',
        pageBuilder: (context, state) {
          final booking = state.extra as Booking?;
          final id = state.pathParameters['id']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: booking != null
                ? BookingCheckoutPage(booking: booking)
                : _PlaceholderPage(title: 'Checkout', subtitle: id),
            transitionType: RouteTransitionType.slideBottomToTop,
          );
        },
      ),

      // ─── DISPUTE ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.openDispute,
        name: 'openDispute',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider<DisputeCubit>(
              create: (_) => getIt<DisputeCubit>(),
              child: OpenDisputePage(
                bookingId: args['bookingId'] as String? ?? '',
                propertyId: args['propertyId'] as String? ?? '',
              ),
            ),
            transitionType: RouteTransitionType.fade,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.disputeStatus,
        name: 'disputeStatus',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider<DisputeCubit>(
              create: (_) => getIt<DisputeCubit>(),
              child: DisputeStatusPage(
                disputeId: args['disputeId'] as String?,
                bookingId: args['bookingId'] as String?,
              ),
            ),
            transitionType: RouteTransitionType.fade,
          );
        },
      ),

      // ─── MESSAGING ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.inbox,
        name: 'inbox',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider<InboxCubit>.value(
            value: getIt<InboxCubit>()..loadConversations(),
            child: const InboxPage(),
          ),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.conversation,
        name: 'conversation',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final args = state.extra as Map<String, dynamic>? ?? {};
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider<ConversationCubit>(
              create: (_) => getIt<ConversationCubit>(),
              child: ConversationPage(
                conversationId: id,
                conversationVersion: args['conversationVersion'] as int?,
                lastMessageId: args['lastMessageId'] as String?,
              ),
            ),
            transitionType: RouteTransitionType.slideRightToLeft,
          );
        },
      ),

      // ─── HOST FEATURES ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.hostRegister,
        name: 'hostRegister',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider<HostOnboardingBloc>(
            create: (_) => HostOnboardingBloc(
              hostRepository: getIt<HostRepository>(),
              flow: HostOnboardingFlow.hostApplication,
            ),
            child: const HostRegisterPage(),
          ),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.hostListProperty,
        name: 'hostListProperty',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider<HostOnboardingBloc>(
            create: (_) => HostOnboardingBloc(
              hostRepository: getIt<HostRepository>(),
              flow: HostOnboardingFlow.listingForApproval,
            ),
            child: const HostRegisterPage(),
          ),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.hostDashboard,
        name: 'hostDashboard',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider<HostDashboardCubit>(
            create: (_) => getIt<HostDashboardCubit>(),
            child: const HostDashboardPage(),
          ),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.hostCalendar,
        name: 'hostCalendar',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const HostCalendarPage(),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.hostInsights,
        name: 'hostInsights',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider<HostDashboardCubit>(
            create: (_) => getIt<HostDashboardCubit>(),
            child: const HostInsightsPage(),
          ),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.hostReviews,
        name: 'hostReviews',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const HostReviewsPage(),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.hostListingEdit,
        name: 'hostListingEdit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final section = state.uri.queryParameters['section'];
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: HostListingEditPage(
              listingId: id,
              section: section,
            ),
            transitionType: RouteTransitionType.fade,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.hostPropertyManage,
        name: 'hostPropertyManage',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider<HostPropertyManageCubit>(
              create: (_) => getIt<HostPropertyManageCubit>(),
              child: HostPropertyManagePage(propertyId: id),
            ),
            transitionType: RouteTransitionType.fade,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.videoRecord,
        name: 'videoRecord',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const _PlaceholderPage(title: 'Record Walkthrough'),
          transitionType: RouteTransitionType.fade,
        ),
      ),

      // ─── PROFILE & SETTINGS ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider<ProfileCubit>(
            create: (_) => _createProfileCubit(context)..loadProfile(),
            child: const EditProfilePage(),
          ),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider<ProfileCubit>(
            create: (_) => _createProfileCubit(context)..loadProfile(),
            child: const SettingsPage(),
          ),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.help,
        name: 'help',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const HelpPage(),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const AboutPage(),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.contact,
        name: 'contact',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ContactPage(),
          transitionType: RouteTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.contactForm,
        name: 'contactForm',
        pageBuilder: (context, state) {
          final reason = state.extra as String?;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: ContactFormPage(reason: reason),
            transitionType: RouteTransitionType.slideRightToLeft,
          );
        },
      ),

      // ─── VERIFICATION STATUS (Profile read-only) ─────────────────────
      GoRoute(
        path: AppRoutes.verificationStatus,
        name: 'verificationStatusProfile',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider<ProfileCubit>(
            create: (_) => _createProfileCubit(context)..loadProfile(),
            child: const VerificationStatusPage(),
          ),
          transitionType: RouteTransitionType.slideRightToLeft,
        ),
      ),
    ],
    );
  }

  /// Notifies [GoRouter] when auth state changes so [redirect] runs again.
  static Listenable authRefreshListenable(AuthBloc authBloc) {
    return _AuthBlocRefreshNotifier(authBloc);
  }
}

/// Listens to [AuthBloc.stream] and notifies [GoRouter] so redirects re-run.
class _AuthBlocRefreshNotifier extends ChangeNotifier {
  _AuthBlocRefreshNotifier(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// =============================================================================
// Reusable placeholder page widget
// =============================================================================

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFE8507A),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: DSColors.ink,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: DSColors.ink4,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Coming soon',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: DSColors.ink4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
