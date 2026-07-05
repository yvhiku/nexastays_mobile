import 'package:get_it/get_it.dart';

import '../../app/env/env_bootstrap.dart';
import '../../core/network/api_client_names.dart';
import '../../core/network/dio_client.dart';
import '../../core/session/session_manager.dart';
import '../../core/storage/local_storage.dart';
import '../../core/storage/secure_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/create_pin_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

void configureAuthDependencies() {
  if (!getIt.isRegistered<SessionManager>()) {
    getIt.registerLazySingleton<SessionManager>(() => SessionManager());
  }

  if (!getIt.isRegistered<DioClient>(instanceName: ApiClientNames.identity)) {
    getIt.registerLazySingleton<DioClient>(
      () => DioClient(
        sessionManager: getIt<SessionManager>(),
        baseUrl: currentEnv.identityBaseUrl,
      ),
      instanceName: ApiClientNames.identity,
    );
  }

  if (!getIt.isRegistered<DioClient>(instanceName: ApiClientNames.stays)) {
    getIt.registerLazySingleton<DioClient>(
      () => DioClient(
        sessionManager: getIt<SessionManager>(),
        baseUrl: currentEnv.staysBaseUrl,
      ),
      instanceName: ApiClientNames.stays,
    );
  }

  if (!getIt.isRegistered<SecureStorageService>()) {
    getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  }
  if (!getIt.isRegistered<LocalStorage>()) {
    getIt.registerLazySingleton<LocalStorage>(() => LocalStorage());
  }
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        dio: getIt<DioClient>(instanceName: ApiClientNames.identity).dio,
      ),
    );
  }
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        secureStorage: getIt<SecureStorageService>(),
        localStorage: getIt<LocalStorage>(),
        sessionManager: getIt<SessionManager>(),
      ),
    );
  }

  if (!getIt.isRegistered<SendOtpUseCase>()) {
    getIt.registerLazySingleton<SendOtpUseCase>(
      () => SendOtpUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<VerifyOtpUseCase>()) {
    getIt.registerLazySingleton<VerifyOtpUseCase>(
      () => VerifyOtpUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<LoginWithPinUseCase>()) {
    getIt.registerLazySingleton<LoginWithPinUseCase>(
      () => LoginWithPinUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<SavePersonalInfoUseCase>()) {
    getIt.registerLazySingleton<SavePersonalInfoUseCase>(
      () => SavePersonalInfoUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<CompleteKycUseCase>()) {
    getIt.registerLazySingleton<CompleteKycUseCase>(
      () => CompleteKycUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<CreatePinUseCase>()) {
    getIt.registerLazySingleton<CreatePinUseCase>(
      () => CreatePinUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<LogoutUseCase>()) {
    getIt.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        sendOtpUseCase: getIt<SendOtpUseCase>(),
        loginWithPinUseCase: getIt<LoginWithPinUseCase>(),
        verifyOtpUseCase: getIt<VerifyOtpUseCase>(),
        savePersonalInfoUseCase: getIt<SavePersonalInfoUseCase>(),
        completeKycUseCase: getIt<CompleteKycUseCase>(),
        createPinUseCase: getIt<CreatePinUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
        authRepository: getIt<AuthRepository>(),
      ),
    );
  }
}
