import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/create_pin_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final LoginWithPinUseCase loginWithPinUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final SavePersonalInfoUseCase savePersonalInfoUseCase;
  final CompleteKycUseCase completeKycUseCase;
  final CreatePinUseCase createPinUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.loginWithPinUseCase,
    required this.verifyOtpUseCase,
    required this.savePersonalInfoUseCase,
    required this.completeKycUseCase,
    required this.createPinUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<AuthCheckCachedUser>(_onCheckCachedUser);
    on<AuthPhoneSubmitted>(_onPhoneSubmitted);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthOtpResendRequested>(_onOtpResend);
    on<AuthPersonalInfoSubmitted>(_onPersonalInfo);
    on<AuthKycSubmitted>(_onKycSubmitted);
    on<AuthPinCreated>(_onPinCreated);
    on<AuthPinLoginRequested>(_onPinLogin);
    on<AuthLogoutRequested>(_onLogout);

    // Auto-check for cached user on creation
    add(const AuthCheckCachedUser());
  }

  Future<void> _onCheckCachedUser(
    AuthCheckCachedUser event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.getCachedUser();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) {
        if (user == null) {
          emit(const AuthUnauthenticated());
        } else if (user.isKycApproved) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthOtpVerified(user: user, isNewUser: true));
        }
      },
    );
  }

  Future<void> _onPhoneSubmitted(
    AuthPhoneSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (!event.agreedToTerms) {
      emit(const AuthError(message: 'Please agree to the Terms of Service'));
      return;
    }

    emit(const AuthLoading());

    final result = await sendOtpUseCase(SendOtpParams(phone: event.phone));

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthOtpSent(phone: event.phone, resendCountdown: 29)),
    );
  }

  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await verifyOtpUseCase(VerifyOtpParams(
      phone: event.phone,
      otp: event.otp,
    ));

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(AuthError(message: failure.message, isOtpError: true));
        } else {
          emit(AuthError(message: failure.message));
        }
      },
      (user) {
        if (user.isKycApproved) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthOtpVerified(user: user, isNewUser: true));
        }
      },
    );
  }

  Future<void> _onOtpResend(
    AuthOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthResending());

    final result = await authRepository.resendOtp(event.phone);

    result.fold(
      (failure) => emit(AuthOtpSent(phone: event.phone, resendCountdown: 29)),
      (_) => emit(AuthOtpSent(phone: event.phone, resendCountdown: 29)),
    );
  }

  Future<void> _onPersonalInfo(
    AuthPersonalInfoSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await savePersonalInfoUseCase(SavePersonalInfoParams(
      userId: event.userId,
      fullName: event.fullName,
      dateOfBirth: event.dateOfBirth,
      isMoroccan: event.isMoroccan,
      email: event.email,
      city: event.city,
      nationality: event.nationality,
      countryOfCitizenship: event.countryOfCitizenship,
    ));

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthPersonalInfoSaved(user: user)),
    );
  }

  Future<void> _onKycSubmitted(
    AuthKycSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await completeKycUseCase(CompleteKycParams(
      fullName: event.fullName,
      dateOfBirth: event.dateOfBirth,
      isMoroccan: event.isMoroccan,
      email: event.email,
      city: event.city,
      nationality: event.nationality,
    ));

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onPinCreated(
    AuthPinCreated event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await createPinUseCase(CreatePinParams(
      userId: event.userId,
      pin: event.pin,
      confirmPin: event.confirmPin,
    ));

    await result.fold(
      (failure) async {
        if (failure is ValidationFailure) {
          emit(AuthError(message: failure.message, isPinError: true));
        } else {
          emit(AuthError(message: failure.message));
        }
      },
      (_) async {
        final cachedResult = await authRepository.getCachedUser();
        final user = cachedResult.fold((_) => null, (u) => u);

        if (user != null) {
          emit(AuthPinSuccess(user: user));
          emit(AuthAuthenticated(user: user));
        }
      },
    );
  }

  Future<void> _onPinLogin(
    AuthPinLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginWithPinUseCase(LoginWithPinParams(
      phone: event.phone,
      pin: event.pin,
    ));

    result.fold(
      (failure) => emit(AuthError(message: failure.message, isPinError: true)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUseCase(NoParams());
    emit(const AuthUnauthenticated());
  }
}
