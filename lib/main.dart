// TODO: When booking is implemented, gate it with KYC - users can only explore
// until identity verification is approved (same as Nexa Pay wallet, Nexa Go ride/food).
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/env/env_bootstrap.dart';
import 'app/di/injection.dart';
import 'app/nexastays_app.dart';
import 'core/config/stays_fee_config.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services before app starts
  // await Firebase.initializeApp();
  // await Analytics.init();
  await bootstrapEnv();
  await StaysFeeConfig.instance.loadFromApi(currentEnv.staysBaseUrl);
  await configureDependencies();

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
