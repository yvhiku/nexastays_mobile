import 'package:equatable/equatable.dart';

import '../../domain/entities/dispute.dart';

// =============================================================================
// Dispute States
// =============================================================================

/// Base state for the dispute feature.
sealed class DisputeState extends Equatable {
  const DisputeState();

  @override
  List<Object?> get props => [];
}

/// Initial state — nothing loaded yet.
final class DisputeInitial extends DisputeState {
  const DisputeInitial();
}

/// Form is ready for user input.
final class DisputeFormReady extends DisputeState {
  const DisputeFormReady({
    required this.bookingId,
    required this.propertyId,
    this.selectedType,
    this.description = '',
    this.evidencePaths = const [],
  });

  final String bookingId;
  final String propertyId;
  final DisputeType? selectedType;
  final String description;
  final List<String> evidencePaths;

  /// The form is valid when a type is selected and the description
  /// is at least 20 characters long.
  bool get isValid => selectedType != null && description.length >= 20;

  DisputeFormReady copyWith({
    String? bookingId,
    String? propertyId,
    DisputeType? selectedType,
    String? description,
    List<String>? evidencePaths,
  }) {
    return DisputeFormReady(
      bookingId: bookingId ?? this.bookingId,
      propertyId: propertyId ?? this.propertyId,
      selectedType: selectedType ?? this.selectedType,
      description: description ?? this.description,
      evidencePaths: evidencePaths ?? this.evidencePaths,
    );
  }

  @override
  List<Object?> get props => [
        bookingId,
        propertyId,
        selectedType,
        description,
        evidencePaths,
      ];
}

/// Evidence files are being uploaded.
final class DisputeEvidenceUploading extends DisputeState {
  const DisputeEvidenceUploading({
    required this.uploadProgress,
    required this.uploadedCount,
    required this.totalCount,
  });

  /// 0.0 → 1.0 progress fraction.
  final double uploadProgress;
  final int uploadedCount;
  final int totalCount;

  @override
  List<Object?> get props => [uploadProgress, uploadedCount, totalCount];
}

/// Dispute is being submitted to the server.
final class DisputeSubmitting extends DisputeState {
  const DisputeSubmitting();
}

/// Dispute was successfully submitted.
final class DisputeSubmitted extends DisputeState {
  const DisputeSubmitted({required this.dispute});

  final Dispute dispute;

  @override
  List<Object?> get props => [dispute];
}

/// Loaded an existing dispute (status page / timeline view).
final class DisputeLoaded extends DisputeState {
  const DisputeLoaded({required this.dispute});

  final Dispute dispute;

  @override
  List<Object?> get props => [dispute];
}

/// Additional evidence is being added to an existing dispute.
final class DisputeAddingEvidence extends DisputeState {
  const DisputeAddingEvidence();
}

/// An error occurred.
final class DisputeError extends DisputeState {
  const DisputeError({
    required this.message,
    this.isValidationError = false,
  });

  final String message;

  /// If `true`, show inline below the field; otherwise show as SnackBar.
  final bool isValidationError;

  @override
  List<Object?> get props => [message, isValidationError];
}

/// Dispute is being closed by the guest.
final class DisputeClosing extends DisputeState {
  const DisputeClosing();
}

/// Dispute was successfully closed.
final class DisputeClosed extends DisputeState {
  const DisputeClosed({required this.disputeId});

  final String disputeId;

  @override
  List<Object?> get props => [disputeId];
}

// =============================================================================
// Upload Status Enum
// =============================================================================

enum DisputeUploadStatus { queued, uploading, done }
