// ─── NEXASTAYS IDENTITY VERIFICATION — SYNC CONTRACT ─────────────────────
// Design tokens:
//   Primary       : Color(0xFFE8507A)
//   Success       : Color(0xFF16A34A)  bg: Color(0xFFF0FDF4)
//   Error         : Color(0xFFDC2626)  bg: Color(0xFFFEF2F2)
//   Warning       : Color(0xFFD97706)  bg: Color(0xFFFFFBEB)
//   Upload dashed : dashed border Color(0xFFE8507A), bg Color(0xFFFFF0F5)
//
// Cubit contract : VerificationCubit → VerificationState
//   (lib/features/identity_verification/presentation/bloc/)
//
// Entities       : Verification, IdType, VerificationStatus
//   (lib/features/identity_verification/domain/entities/verification.dart)
//
// Repository     : VerificationRepository (domain) → VerificationRepositoryImpl (data)
// UseCases       : UploadIdUseCase, SubmitSelfieUseCase
//
// Upload stream  : repository.uploadProgressStream → Stream<UploadProgressEvent>
//   UploadProgressEvent { String fileName, double progress, bool isDone }
//
// Navigation routes (app/router.dart):
//   /verify-id           → IdUploadPage       (step 3)
//   /selfie-capture      → SelfiePage         (camera, returns path)
//   /verification-status → VerificationStatusPage (step 4)
//
// Stepper (shared widget from auth feature):
//   StepIndicator(currentStep: 3) on IdUploadPage
//   StepIndicator(currentStep: 4) on VerificationStatusPage
//
// User userId sourced from: AuthBloc → AuthAuthenticated state → user.id
//
// After VerificationApproved:
//   Update cached User.isVerified = true via AuthBloc or SessionManager
// ─────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/verification_remote_datasource.dart';
import '../../domain/entities/verification.dart';
import '../../domain/repositories/verification_repository.dart';
import '../../domain/usecases/submit_selfie_usecase.dart';
import '../../domain/usecases/upload_id_usecase.dart';
import 'verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  final UploadIdUseCase uploadIdUseCase;
  final SubmitSelfieUseCase submitSelfieUseCase;
  final VerificationRepository repository;

  StreamSubscription<UploadProgressEvent>? _progressSubscription;

  VerificationCubit({
    required this.uploadIdUseCase,
    required this.submitSelfieUseCase,
    required this.repository,
  }) : super(const VerificationInitial());

  // ── Initialize ──────────────────────────────────────────────────────

  Future<void> initialize(String userId) async {
    emit(const VerificationLoading());

    final result = await repository.getVerificationStatus(userId: userId);

    result.fold(
      (failure) => emit(const VerificationFormReady(
        selectedIdType: IdType.cnie,
      )),
      (verification) {
        switch (verification.status) {
          case VerificationStatus.approved:
            emit(VerificationApproved(verification: verification));
          case VerificationStatus.rejected:
            emit(VerificationRejected(
              reasons: verification.rejectionReasons,
              attemptsRemaining: verification.attemptsRemaining,
            ));
          case VerificationStatus.submitted:
          case VerificationStatus.pending:
            emit(const VerificationSubmitted());
          case VerificationStatus.notStarted:
            emit(const VerificationFormReady(
              selectedIdType: IdType.cnie,
            ));
        }
      },
    );
  }

  // ── Form field updates ──────────────────────────────────────────────

  void selectIdType(IdType type) {
    final current = state;
    if (current is VerificationFormReady) {
      emit(VerificationFormReady(
        selectedIdType: type,
        idNumber: current.idNumber,
        idFrontPath: current.idFrontPath,
        idBackPath: current.idBackPath,
        profilePhotoPath: current.profilePhotoPath,
      ));
    } else {
      emit(VerificationFormReady(selectedIdType: type));
    }
  }

  void updateIdNumber(String value) {
    final current = state;
    if (current is VerificationFormReady) {
      emit(VerificationFormReady(
        selectedIdType: current.selectedIdType,
        idNumber: value,
        idFrontPath: current.idFrontPath,
        idBackPath: current.idBackPath,
        profilePhotoPath: current.profilePhotoPath,
      ));
    } else {
      emit(VerificationFormReady(selectedIdType: IdType.cnie, idNumber: value));
    }
  }

  void pickIdFront(String filePath) {
    final current = state;
    if (current is VerificationFormReady) {
      emit(VerificationFormReady(
        selectedIdType: current.selectedIdType,
        idNumber: current.idNumber,
        idFrontPath: filePath,
        idBackPath: current.idBackPath,
        profilePhotoPath: current.profilePhotoPath,
      ));
    } else {
      emit(VerificationFormReady(
          selectedIdType: IdType.cnie, idFrontPath: filePath));
    }
  }

  void pickIdBack(String filePath) {
    final current = state;
    if (current is VerificationFormReady) {
      emit(VerificationFormReady(
        selectedIdType: current.selectedIdType,
        idNumber: current.idNumber,
        idFrontPath: current.idFrontPath,
        idBackPath: filePath,
        profilePhotoPath: current.profilePhotoPath,
      ));
    } else {
      emit(VerificationFormReady(
          selectedIdType: IdType.cnie, idBackPath: filePath));
    }
  }

  void pickProfilePhoto(String filePath) {
    final current = state;
    if (current is VerificationFormReady) {
      emit(VerificationFormReady(
        selectedIdType: current.selectedIdType,
        idNumber: current.idNumber,
        idFrontPath: current.idFrontPath,
        idBackPath: current.idBackPath,
        profilePhotoPath: filePath,
      ));
    } else {
      emit(VerificationFormReady(
          selectedIdType: IdType.cnie, profilePhotoPath: filePath));
    }
  }

  // ── Submit verification ─────────────────────────────────────────────

  Future<void> submitVerification(String userId) async {
    final current = state;
    if (current is! VerificationFormReady || !current.allFilesReady) {
      emit(const VerificationError(
          message: 'Please complete all fields before submitting'));
      return;
    }

    // Start uploading state
    emit(const VerificationUploading());

    // Listen to progress
    _progressSubscription?.cancel();
    _progressSubscription = repository.uploadProgressStream.listen((event) {
      final currentState = state;
      if (currentState is VerificationUploading) {
        UploadFileStatus idFront = currentState.idFront;
        UploadFileStatus idBack = currentState.idBack;
        UploadFileStatus profilePhoto = currentState.profilePhoto;
        double profileProgress = currentState.profilePhotoProgress;

        if (event.fileName == 'id_document') {
          idFront =
              event.isDone ? UploadFileStatus.done : UploadFileStatus.uploading;
          if (event.isDone) idBack = UploadFileStatus.done;
        } else if (event.fileName == 'profile_photo') {
          profilePhoto =
              event.isDone ? UploadFileStatus.done : UploadFileStatus.uploading;
          profileProgress = event.progress;
        }

        emit(VerificationUploading(
          idFront: idFront,
          idBack: idBack,
          profilePhoto: profilePhoto,
          encrypting: currentState.encrypting,
          profilePhotoProgress: profileProgress,
        ));
      }
    });

    // Step 1: Upload ID
    final uploadResult = await uploadIdUseCase(UploadIdParams(
      userId: userId,
      idType: current.selectedIdType,
      idNumber: current.idNumber,
      idFrontPath: current.idFrontPath!,
      idBackPath: current.idBackPath!,
    ));

    if (uploadResult.isLeft()) {
      _progressSubscription?.cancel();
      uploadResult.fold(
        (failure) => emit(VerificationError(message: failure.message)),
        (_) {},
      );
      return;
    }

    // Step 2: Upload selfie + submit
    final selfieResult = await submitSelfieUseCase(SubmitSelfieParams(
      userId: userId,
      profilePhotoPath: current.profilePhotoPath!,
    ));

    _progressSubscription?.cancel();

    selfieResult.fold(
      (failure) => emit(VerificationError(message: failure.message)),
      (_) => emit(const VerificationSubmitted()),
    );
  }

  // ── Check status ────────────────────────────────────────────────────

  Future<void> checkStatus(String userId) async {
    final result = await repository.getVerificationStatus(userId: userId);

    result.fold(
      (failure) => emit(VerificationError(message: failure.message)),
      (verification) {
        switch (verification.status) {
          case VerificationStatus.approved:
            emit(VerificationApproved(verification: verification));
          case VerificationStatus.rejected:
            emit(VerificationRejected(
              reasons: verification.rejectionReasons,
              attemptsRemaining: verification.attemptsRemaining,
            ));
          case VerificationStatus.submitted:
          case VerificationStatus.pending:
            emit(const VerificationSubmitted());
          case VerificationStatus.notStarted:
            emit(const VerificationFormReady(selectedIdType: IdType.cnie));
        }
      },
    );
  }

  // ── Resubmit ────────────────────────────────────────────────────────

  Future<void> resubmit(
    String userId,
    String idFront,
    String idBack,
    String photo,
  ) async {
    emit(const VerificationUploading());

    final result = await repository.resubmitVerification(
      userId: userId,
      idFrontPath: idFront,
      idBackPath: idBack,
      profilePhotoPath: photo,
    );

    result.fold(
      (failure) => emit(VerificationError(message: failure.message)),
      (_) => emit(const VerificationSubmitted()),
    );
  }

  // ── Cleanup ─────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}
