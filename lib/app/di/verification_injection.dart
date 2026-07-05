import 'package:get_it/get_it.dart';

import '../../core/network/api_client_names.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/local_storage.dart';
import '../../features/identity_verification/data/datasources/verification_remote_datasource.dart';
import '../../features/identity_verification/data/repositories/verification_repository_impl.dart';
import '../../features/identity_verification/domain/repositories/verification_repository.dart';
import '../../features/identity_verification/domain/usecases/submit_selfie_usecase.dart';
import '../../features/identity_verification/domain/usecases/upload_id_usecase.dart';
import '../../features/identity_verification/presentation/bloc/verification_cubit.dart';

final GetIt getIt = GetIt.instance;

void configureVerificationDependencies() {
  if (!getIt.isRegistered<VerificationRemoteDataSource>()) {
    getIt.registerLazySingleton<VerificationRemoteDataSource>(
      () => VerificationRemoteDataSourceImpl(
        dioClient: getIt<DioClient>(instanceName: ApiClientNames.stays),
      ),
    );
  }

  if (!getIt.isRegistered<VerificationRepository>()) {
    getIt.registerLazySingleton<VerificationRepository>(
      () => VerificationRepositoryImpl(
        remoteDataSource: getIt<VerificationRemoteDataSource>(),
        localStorage: getIt<LocalStorage>(),
      ),
    );
  }

  if (!getIt.isRegistered<UploadIdUseCase>()) {
    getIt.registerLazySingleton<UploadIdUseCase>(
      () => UploadIdUseCase(getIt<VerificationRepository>()),
    );
  }
  if (!getIt.isRegistered<SubmitSelfieUseCase>()) {
    getIt.registerLazySingleton<SubmitSelfieUseCase>(
      () => SubmitSelfieUseCase(getIt<VerificationRepository>()),
    );
  }

  if (!getIt.isRegistered<VerificationCubit>()) {
    getIt.registerFactory<VerificationCubit>(
      () => VerificationCubit(
        uploadIdUseCase: getIt<UploadIdUseCase>(),
        submitSelfieUseCase: getIt<SubmitSelfieUseCase>(),
        repository: getIt<VerificationRepository>(),
      ),
    );
  }
}
