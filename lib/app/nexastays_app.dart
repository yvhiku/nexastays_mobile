// =============================================================================
// NexaStays App Root
// =============================================================================
// This is the root widget for the NexaStays mobile application.
// It configures Material theming, routing, and localization to match the
// NexaStays web styling and branding guidelines.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'router.dart';
import 'theme.dart';

/// The root application widget for NexaStays.
///
/// Configures [MaterialApp.router] with the app's theme, dark theme,
/// routing, and localization settings.
class NexaStaysApp extends StatefulWidget {
  const NexaStaysApp({super.key});

  @override
  State<NexaStaysApp> createState() => _NexaStaysAppState();
}

class _NexaStaysAppState extends State<NexaStaysApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= AppRouter.createRouter(
      AppRouter.authRefreshListenable(context.read<AuthBloc>()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = _router!;

    return MaterialApp.router(
      title: 'NexaStays',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ── Routing ────────────────────────────────────────────────────────
      routerConfig: router,

      // ── Localization ───────────────────────────────────────────────────
      // TODO: Add localization delegates when l10n is configured.
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      //   AppLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('en'),
      //   Locale('fr'),
      //   Locale('ar'),
      // ],
    );
  }
}
