// TODO: When booking is implemented, gate it with KYC - users can only explore
// until identity verification is approved (same as Nexa Pay wallet, Nexa Go ride/food).
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/env/env_bootstrap.dart';
import 'app/di/injection.dart';
import 'app/nexastays_app.dart';
import 'core/config/stays_fee_config.dart';
import 'core/session/session_manager.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'services/push_registration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('[main] Firebase init skipped: $e');
  }

  await bootstrapEnv();
  await StaysFeeConfig.instance.loadFromApi(currentEnv.staysBaseUrl);
  await configureDependencies();

  try {
    await getIt<PushRegistrationService>().initialize();
    if (getIt<SessionManager>().isAuthenticated) {
      unawaited(getIt<PushRegistrationService>().registerIfAuthenticated());
    }
  } catch (e) {
    debugPrint('[main] Push registration init skipped: $e');
  }

  runApp(
    ProviderScope(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => getIt<AuthBloc>(),
          ),
        ],
        child: const NexaStaysApp(),
      ),
    ),
  );
}
