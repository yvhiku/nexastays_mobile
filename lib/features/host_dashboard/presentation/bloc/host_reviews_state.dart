import 'package:equatable/equatable.dart';

import '../../data/models/host_reviews_payload.dart';

sealed class HostReviewsState extends Equatable {
  const HostReviewsState();

  @override
  List<Object?> get props => [];
}

class HostReviewsInitial extends HostReviewsState {
  const HostReviewsInitial();
}

class HostReviewsLoading extends HostReviewsState {
  const HostReviewsLoading();
}

class HostReviewsLoaded extends HostReviewsState {
  const HostReviewsLoaded({
    required this.payload,
    this.isLoadingMore = false,
  });

  final HostReviewsPayload payload;
  final bool isLoadingMore;

  HostReviewsLoaded copyWith({
    HostReviewsPayload? payload,
    bool? isLoadingMore,
  }) {
    return HostReviewsLoaded(
      payload: payload ?? this.payload,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [payload, isLoadingMore];
}

class HostReviewsError extends HostReviewsState {
  const HostReviewsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
