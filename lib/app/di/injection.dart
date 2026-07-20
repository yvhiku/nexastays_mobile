import 'package:get_it/get_it.dart';

import '../../core/network/api_client_names.dart';
import '../../core/network/dio_client.dart';
import '../../core/session/session_manager.dart';
import '../../core/storage/local_storage.dart';
import '../../core/storage/secure_storage.dart';
import '../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/property/data/datasources/property_local_datasource.dart';
import '../../features/property/data/datasources/property_remote_datasource.dart';
import '../../features/property/data/repositories/property_repository_impl.dart';
import '../../features/property/domain/repositories/property_repository.dart'
    as stays_property_repo;
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/home/data/repositories/home_property_repository_impl.dart';
import '../../features/home/domain/repositories/property_repository.dart' as home_repo;
import '../../features/home/domain/usecases/get_properties_usecase.dart' as home_usecase;
import '../../features/search/domain/usecases/search_properties_usecase.dart';
import '../../features/host_dashboard/data/repositories/host_dashboard_repository_impl.dart';
import '../../features/host_dashboard/domain/repositories/host_repository.dart'
    as host_dashboard_repo;
import '../../features/host_onboarding/data/repositories/stays_host_onboarding_repository.dart';
import '../../features/host_onboarding/presentation/bloc/host_onboarding_bloc.dart'
    as onboarding_bloc;
import '../../features/dispute/data/datasources/dispute_remote_datasource.dart';
import '../../features/dispute/data/repositories/dispute_repository_impl.dart';
import '../../features/dispute/domain/repositories/dispute_repository.dart';
import '../../features/dispute/domain/usecases/get_dispute_status_usecase.dart';
import '../../features/dispute/domain/usecases/open_dispute_usecase.dart';
import '../../features/identity_verification/domain/repositories/verification_repository.dart';
import '../../features/wishlist/data/datasources/wishlist_local_datasource.dart';
import '../../features/wishlist/data/repositories/wishlist_repository_impl.dart';
import '../../features/wishlist/domain/repositories/wishlist_repository.dart';
import '../../features/wishlist/domain/usecases/add_to_wishlist_usecase.dart';
import '../../features/wishlist/domain/usecases/remove_from_wishlist_usecase.dart';
import '../../features/messaging/data/datasources/messaging_remote_datasource.dart';
import '../../features/messaging/data/draft/draft_store.dart';
import '../../features/messaging/data/realtime/messaging_realtime_adapter.dart';
import '../../features/messaging/data/repositories/messaging_repository_impl.dart';
import '../../features/messaging/domain/repositories/messaging_repository.dart';
import 'auth_injection.dart';
import 'mock_dependencies.dart';
import 'verification_injection.dart';

final GetIt getIt = GetIt.instance;
bool _isConfigured = false;

Future<void> configureDependencies({
  bool useMocks = false,
}) async {
  if (_isConfigured) return;

  configureAuthDependencies();
  configureVerificationDependencies();
  // Restore JWT + userId from secure storage so users stay logged in across restarts.
  await getIt<SessionManager>().loadSession();
  configureMockDependencies(seedMockAuth: useMocks);

  if (!useMocks) {
    _wireRealStaysApis();
  }

  _isConfigured = true;
}

void _wireRealStaysApis() {
  final staysClient = getIt<DioClient>(instanceName: ApiClientNames.stays);
  final identityClient = getIt<DioClient>(instanceName: ApiClientNames.identity);

  if (!getIt.isRegistered<PropertyLocalDataSource>()) {
    getIt.registerLazySingleton<PropertyLocalDataSource>(
      () => PropertyLocalDataSourceImpl(localStorage: getIt<LocalStorage>()),
    );
  }
  if (!getIt.isRegistered<PropertyRemoteDataSource>()) {
    getIt.registerLazySingleton<PropertyRemoteDataSource>(
      () => PropertyRemoteDataSourceImpl(client: staysClient),
    );
  }

  if (!getIt.isRegistered<BookingRemoteDataSource>()) {
    getIt.registerLazySingleton<BookingRemoteDataSource>(
      () => BookingRemoteDataSourceImpl(client: staysClient),
    );
  }
  if (getIt.isRegistered<BookingRepository>()) {
    getIt.unregister<BookingRepository>();
  }
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(
      remoteDataSource: getIt<BookingRemoteDataSource>(),
      localStorage: getIt<LocalStorage>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );

  // Profile: use real Pay API (/users/me). Mock mode still registers MockProfileRepository above.
  if (getIt.isRegistered<ProfileRepository>()) {
    getIt.unregister<ProfileRepository>();
  }
  if (getIt.isRegistered<UpdateProfileUseCase>()) {
    getIt.unregister<UpdateProfileUseCase>();
  }
  if (!getIt.isRegistered<ProfileRemoteDataSource>()) {
    getIt.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(identityClient),
    );
  }
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
      localStorage: getIt<LocalStorage>(),
      sessionManager: getIt<SessionManager>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<ProfileRepository>()),
  );

  // Home + search: bridge full Stays [PropertyRepository] to home entities.
  if (getIt.isRegistered<home_repo.PropertyRepository>()) {
    getIt.unregister<home_repo.PropertyRepository>();
  }
  getIt.registerLazySingleton<home_repo.PropertyRepository>(
    () => HomePropertyRepositoryImpl(
      propertyRepository: getIt<stays_property_repo.PropertyRepository>(),
    ),
  );
  if (getIt.isRegistered<home_usecase.GetPropertiesUseCase>()) {
    getIt.unregister<home_usecase.GetPropertiesUseCase>();
  }
  getIt.registerLazySingleton<home_usecase.GetPropertiesUseCase>(
    () => home_usecase.GetPropertiesUseCase(getIt<home_repo.PropertyRepository>()),
  );
  if (getIt.isRegistered<SearchPropertiesUseCase>()) {
    getIt.unregister<SearchPropertiesUseCase>();
  }
  getIt.registerLazySingleton<SearchPropertiesUseCase>(
    () => SearchPropertiesUseCase(getIt<home_repo.PropertyRepository>()),
  );

  // Wishlist: device persistence (replaces in-memory mock).
  if (getIt.isRegistered<WishlistLocalDataSource>()) {
    getIt.unregister<WishlistLocalDataSource>();
  }
  getIt.registerLazySingleton<WishlistLocalDataSource>(
    () => WishlistLocalDataSourceImpl(getIt<LocalStorage>()),
  );
  if (getIt.isRegistered<WishlistRepositoryImpl>()) {
    getIt.unregister<WishlistRepositoryImpl>();
  }
  getIt.registerLazySingleton<WishlistRepositoryImpl>(
    () => WishlistRepositoryImpl(
      localDataSource: getIt<WishlistLocalDataSource>(),
      sessionManager: getIt<SessionManager>(),
      propertyRemoteDataSource: getIt<PropertyRemoteDataSource>(),
    ),
  );
  if (getIt.isRegistered<WishlistRepository>()) {
    getIt.unregister<WishlistRepository>();
  }
  getIt.registerLazySingleton<WishlistRepository>(
    () => getIt<WishlistRepositoryImpl>(),
  );
  if (getIt.isRegistered<AddToWishlistUseCase>()) {
    getIt.unregister<AddToWishlistUseCase>();
  }
  getIt.registerLazySingleton<AddToWishlistUseCase>(
    () => AddToWishlistUseCase(getIt<WishlistRepository>()),
  );
  if (getIt.isRegistered<RemoveFromWishlistUseCase>()) {
    getIt.unregister<RemoveFromWishlistUseCase>();
  }
  getIt.registerLazySingleton<RemoveFromWishlistUseCase>(
    () => RemoveFromWishlistUseCase(getIt<WishlistRepository>()),
  );

  // Property repository: save/unsave delegates to on-device wishlist storage.
  if (getIt.isRegistered<stays_property_repo.PropertyRepository>()) {
    getIt.unregister<stays_property_repo.PropertyRepository>();
  }
  getIt.registerLazySingleton<stays_property_repo.PropertyRepository>(
    () => PropertyRepositoryImpl(
      remoteDataSource: getIt<PropertyRemoteDataSource>(),
      localDataSource: getIt<PropertyLocalDataSource>(),
      wishlistRepository: getIt<WishlistRepository>(),
      wishlistRepositoryImpl: getIt<WishlistRepositoryImpl>(),
    ),
  );

  // Disputes: real backend (`/disputes`).
  if (getIt.isRegistered<DisputeRemoteDataSource>()) {
    getIt.unregister<DisputeRemoteDataSource>();
  }
  getIt.registerLazySingleton<DisputeRemoteDataSource>(
    () => DisputeRemoteDataSourceImpl(staysClient),
  );
  if (getIt.isRegistered<DisputeRepositoryImpl>()) {
    getIt.unregister<DisputeRepositoryImpl>();
  }
  getIt.registerLazySingleton<DisputeRepositoryImpl>(
    () => DisputeRepositoryImpl(
      remoteDataSource: getIt<DisputeRemoteDataSource>(),
      localStorage: getIt<LocalStorage>(),
    ),
  );
  if (getIt.isRegistered<DisputeRepository>()) {
    getIt.unregister<DisputeRepository>();
  }
  getIt.registerLazySingleton<DisputeRepository>(
    () => getIt<DisputeRepositoryImpl>(),
  );
  if (getIt.isRegistered<OpenDisputeUseCase>()) {
    getIt.unregister<OpenDisputeUseCase>();
  }
  getIt.registerLazySingleton<OpenDisputeUseCase>(
    () => OpenDisputeUseCase(getIt<DisputeRepository>()),
  );
  if (getIt.isRegistered<GetDisputeStatusUseCase>()) {
    getIt.unregister<GetDisputeStatusUseCase>();
  }
  getIt.registerLazySingleton<GetDisputeStatusUseCase>(
    () => GetDisputeStatusUseCase(getIt<DisputeRepository>()),
  );

  // Host dashboard: `/stays/host/me` + listings + bookings.
  if (getIt.isRegistered<host_dashboard_repo.HostRepository>()) {
    getIt.unregister<host_dashboard_repo.HostRepository>();
  }
  getIt.registerLazySingleton<host_dashboard_repo.HostRepository>(
    () => HostDashboardRepositoryImpl(
      dioClient: staysClient,
      propertyRemote: getIt<PropertyRemoteDataSource>(),
      bookingRepository: getIt<BookingRepository>(),
      bookingRemote: getIt<BookingRemoteDataSource>(),
    ),
  );

  // Host onboarding submit → `POST /stays/host/onboarding` (stays_host_profiles queue).
  if (getIt.isRegistered<onboarding_bloc.HostRepository>()) {
    getIt.unregister<onboarding_bloc.HostRepository>();
  }
  getIt.registerSingleton<onboarding_bloc.HostRepository>(
    StaysHostOnboardingRepository(
      dioClient: staysClient,
      sessionManager: getIt<SessionManager>(),
      localStorage: getIt<LocalStorage>(),
    ),
  );

  // Messaging: real backend (`/messaging/*`).
  if (getIt.isRegistered<MessagingRemoteDataSource>()) {
    getIt.unregister<MessagingRemoteDataSource>();
  }
  getIt.registerLazySingleton<MessagingRemoteDataSource>(
    () => MessagingRemoteDataSourceImpl(staysClient),
  );
  if (getIt.isRegistered<MessagingRepositoryImpl>()) {
    getIt.unregister<MessagingRepositoryImpl>();
  }
  getIt.registerLazySingleton<MessagingRepositoryImpl>(
    () => MessagingRepositoryImpl(
      remoteDataSource: getIt<MessagingRemoteDataSource>(),
      localStorage: getIt<LocalStorage>(),
    ),
  );
  if (getIt.isRegistered<MessagingRepository>()) {
    getIt.unregister<MessagingRepository>();
  }
  getIt.registerLazySingleton<MessagingRepository>(
    () => getIt<MessagingRepositoryImpl>(),
  );
  if (!getIt.isRegistered<MessagingDraftStore>()) {
    getIt.registerLazySingleton<MessagingDraftStore>(
      () => MessagingDraftStore(getIt<LocalStorage>()),
    );
  }
  if (!getIt.isRegistered<MessagingRealtimeAdapter>()) {
    getIt.registerLazySingleton<MessagingRealtimeAdapter>(
      getMessagingRealtimeAdapter,
    );
  }
}
