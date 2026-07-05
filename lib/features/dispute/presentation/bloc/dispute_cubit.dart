import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/session/session_manager.dart';
import '../../data/repositories/dispute_repository_impl.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/usecases/get_dispute_status_usecase.dart';
import '../../domain/usecases/open_dispute_usecase.dart';
import 'dispute_state.dart';

// =============================================================================
// Dispute Cubit
// =============================================================================

class DisputeCubit extends Cubit<DisputeState> {
  DisputeCubit({
    required this.openDisputeUseCase,
    required this.getDisputeStatusUseCase,
    required this.disputeRepository,
    required this.sessionManager,
  }) : super(const DisputeInitial());

  final OpenDisputeUseCase openDisputeUseCase;
  final GetDisputeStatusUseCase getDisputeStatusUseCase;
  final DisputeRepositoryImpl disputeRepository;
  final SessionManager sessionManager;

  StreamSubscription<double>? _uploadSub;

  // ── Form setup ───────────────────────────────────────────────────────

  void initForm(String bookingId, String propertyId) {
    emit(DisputeFormReady(
      bookingId: bookingId,
      propertyId: propertyId,
    ));
  }

  // ── Form updates ─────────────────────────────────────────────────────

  void selectType(DisputeType type) {
    final s = state;
    if (s is! DisputeFormReady) return;
    emit(s.copyWith(selectedType: type));
  }

  void updateDescription(String text) {
    final s = state;
    if (s is! DisputeFormReady) return;
    emit(s.copyWith(description: text));
  }

  void addEvidence(String filePath) {
    final s = state;
    if (s is! DisputeFormReady) return;
    if (s.evidencePaths.length >= 5) return; // max 5 files
    emit(s.copyWith(evidencePaths: [...s.evidencePaths, filePath]));
  }

  void removeEvidence(String filePath) {
    final s = state;
    if (s is! DisputeFormReady) return;
    emit(s.copyWith(
      evidencePaths: s.evidencePaths.where((p) => p != filePath).toList(),
    ));
  }

  // ── Submit ───────────────────────────────────────────────────────────

  Future<void> submitDispute() async {
    final s = state;
    if (s is! DisputeFormReady || !s.isValid) return;

    final guestId = sessionManager.userId!;

    // Start upload progress tracking if evidence is attached.
    if (s.evidencePaths.isNotEmpty) {
      emit(DisputeEvidenceUploading(
        uploadProgress: 0,
        uploadedCount: 0,
        totalCount: s.evidencePaths.length,
      ));

      _uploadSub = disputeRepository.uploadProgressStream.listen(
        (progress) {
          if (!isClosed) {
            emit(DisputeEvidenceUploading(
              uploadProgress: progress,
              uploadedCount: (progress * s.evidencePaths.length).floor(),
              totalCount: s.evidencePaths.length,
            ));
          }
        },
      );
    }

    emit(const DisputeSubmitting());

    final result = await openDisputeUseCase(OpenDisputeParams(
      bookingId: s.bookingId,
      propertyId: s.propertyId,
      guestId: guestId,
      type: s.selectedType!,
      description: s.description,
      evidencePaths: s.evidencePaths,
    ));

    await _uploadSub?.cancel();
    _uploadSub = null;

    result.fold(
      (failure) {
        final isValidation = failure is ValidationFailure;
        emit(DisputeError(
          message: failure.message,
          isValidationError: isValidation,
        ));
      },
      (dispute) => emit(DisputeSubmitted(dispute: dispute)),
    );
  }

  // ── Load status ──────────────────────────────────────────────────────

  Future<void> loadDisputeStatus({
    String? disputeId,
    String? bookingId,
  }) async {
    emit(const DisputeInitial());

    final result = await getDisputeStatusUseCase(GetDisputeParams(
      disputeId: disputeId,
      bookingId: bookingId,
    ));

    result.fold(
      (failure) => emit(DisputeError(
        message: failure.message,
        isValidationError: false,
      )),
      (dispute) => emit(DisputeLoaded(dispute: dispute)),
    );
  }

  // ── Add more evidence ────────────────────────────────────────────────

  Future<void> addMoreEvidence(
    String disputeId,
    List<String> paths,
  ) async {
    final s = state;
    if (s is! DisputeLoaded || !s.dispute.canAddEvidence) return;

    emit(const DisputeAddingEvidence());

    final result = await disputeRepository.addEvidence(
      disputeId: disputeId,
      newEvidencePaths: paths,
    );

    result.fold(
      (failure) => emit(DisputeError(
        message: failure.message,
        isValidationError: false,
      )),
      (dispute) => emit(DisputeLoaded(dispute: dispute)),
    );
  }

  // ── Close dispute ────────────────────────────────────────────────────

  Future<void> closeDispute(String disputeId) async {
    emit(const DisputeClosing());

    final result = await disputeRepository.closeDispute(disputeId);

    result.fold(
      (failure) => emit(DisputeError(
        message: failure.message,
        isValidationError: false,
      )),
      (_) => emit(DisputeClosed(disputeId: disputeId)),
    );
  }

  // ── Cleanup ──────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _uploadSub?.cancel();
    return super.close();
  }
}
