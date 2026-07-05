import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/session/session_manager.dart';
import '../../../../../core/utils/fee_calculator.dart';
import '../../../domain/entities/property.dart';
import '../../../domain/entities/fee_breakdown.dart';
import '../../../domain/repositories/property_repository.dart';
import '../../../domain/usecases/get_property_detail_usecase.dart';
import '../../../domain/usecases/get_reviews_usecase.dart';
import 'property_detail_state.dart';

class PropertyDetailCubit extends Cubit<PropertyDetailState> {
  PropertyDetailCubit({
    required this.getPropertyDetailUseCase,
    required this.getReviewsUseCase,
    required this.propertyRepository,
    required this.sessionManager,
  }) : super(const PropertyDetailInitial());

  final GetPropertyDetailUseCase getPropertyDetailUseCase;
  final GetReviewsUseCase getReviewsUseCase;
  final PropertyRepository propertyRepository;
  final SessionManager sessionManager;

  /// Loads the property details, first page of reviews, and saved status in parallel.
  Future<void> loadProperty(String propertyId) async {
    emit(const PropertyDetailLoading());

    // We need the user ID to check if the property is saved
    final userId = sessionManager.userId ?? '';

    // Run all three requests in parallel
    final results = await Future.wait([
      getPropertyDetailUseCase(GetPropertyDetailParams(propertyId: propertyId)),
      getReviewsUseCase(GetReviewsParams(propertyId: propertyId, page: 1)),
      propertyRepository.isPropertySaved(userId: userId, propertyId: propertyId),
    ]);

    final propertyResult = results[0] as dynamic;
    final reviewsResult = results[1] as dynamic;
    final isSavedResult = results[2] as dynamic;

    // If any request fails, emit error
    if (propertyResult.isLeft() || reviewsResult.isLeft() || isSavedResult.isLeft()) {
      String errorMessage = 'Failed to load property details';
      propertyResult.fold(
        (failure) => errorMessage = failure.message,
        (_) {},
      );
      emit(PropertyDetailError(message: errorMessage));
      return;
    }

    // Extract values from Right sides
    final property = propertyResult.getOrElse(() => throw Exception());
    final reviewBundle = reviewsResult.getOrElse(() => throw Exception());
    final isSaved = isSavedResult.getOrElse(() => throw Exception());

    final similarProperties = await _loadSimilarProperties(propertyId);

    // Emit loaded state
    emit(PropertyDetailLoaded(
      property: property,
      reviews: reviewBundle.reviews,
      isSaved: isSaved,
      similarProperties: similarProperties,
      reviewsApiTotal: reviewBundle.apiTotalCount,
      reviewsDistributionPct: reviewBundle.distributionPct.isNotEmpty
          ? reviewBundle.distributionPct
          : null,
      reviewsSummaryAvgRating: reviewBundle.summaryAvgRating,
      isLoadingReviews: false,
      hasMoreReviews:
          reviewBundle.reviews.length < reviewBundle.apiTotalCount,
      reviewPage: 1,
      isVideoPlaying: false,
      contactRevealed: false,
      selectedGuests: 1,
    ));
  }

  Future<List<Property>> _loadSimilarProperties(String propertyId) async {
    final trending = await propertyRepository.getTrendingProperties();
    return trending.fold(
      (_) => <Property>[],
      (properties) => properties
          .where((p) => p.id != propertyId)
          .take(6)
          .toList(),
    );
  }

  /// Loads the next page of reviews.
  Future<void> loadMoreReviews() async {
    final currentState = state;
    if (currentState is! PropertyDetailLoaded ||
        currentState.isLoadingReviews ||
        !currentState.hasMoreReviews) {
      return;
    }

    emit(currentState.copyWith(isLoadingReviews: true));

    final nextPage = currentState.reviewPage + 1;
    final result = await getReviewsUseCase(
      GetReviewsParams(
        propertyId: currentState.property.id,
        page: nextPage,
      ),
    );

    result.fold(
      (failure) {
        // Revert loading state on error
        emit(currentState.copyWith(isLoadingReviews: false));
      },
      (newReviews) {
        final merged = [...currentState.reviews, ...newReviews.reviews];
        emit(currentState.copyWith(
          reviews: merged,
          reviewPage: nextPage,
          hasMoreReviews: merged.length < newReviews.apiTotalCount,
          isLoadingReviews: false,
        ));
      },
    );
  }

  /// Toggles the saved/wishlisted status optimistically.
  Future<void> toggleSave() async {
    final currentState = state;
    if (currentState is! PropertyDetailLoaded) return;

    final userId = sessionManager.userId ?? '';
    if (userId.isEmpty) {
      // User is not logged in, cannot save
      return;
    }

    final wasSaved = currentState.isSaved;
    final propertyId = currentState.property.id;

    // Optimistically update UI
    emit(currentState.copyWith(isSaved: !wasSaved));

    final result = wasSaved
        ? await propertyRepository.unsaveProperty(
            userId: userId, propertyId: propertyId)
        : await propertyRepository.saveProperty(
            userId: userId,
            propertyId: propertyId,
            property: currentState.property,
          );

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        if (state is PropertyDetailLoaded) {
          final s = state as PropertyDetailLoaded;
          emit(s.copyWith(isSaved: wasSaved));
        }
      },
      (_) {
        // Success: optimistic update stands
      },
    );
  }

  /// Toggles the video playing state.
  void toggleVideoPlaying() {
    final currentState = state;
    if (currentState is PropertyDetailLoaded) {
      emit(currentState.copyWith(isVideoPlaying: !currentState.isVideoPlaying));
    }
  }

  /// Selects dates and calculates the generic fee overview.
  void selectDates(DateTime checkIn, DateTime checkOut) {
    final currentState = state;
    if (currentState is! PropertyDetailLoaded) return;

    final nights = checkOut.difference(checkIn).inDays;

    if (nights > 0) {
      final breakdown = FeeCalculator.calculateTotal(
        nightlyPrice: currentState.property.nightlyRate,
        nights: nights,
      );

      final feePreview = FeeBreakdown(
        basePrice: breakdown.subtotal,
        cleaningFee: 0.0, // Hardcoded for preview, real app might fetch this per-property
        serviceFee: breakdown.serviceFee,
        taxes: breakdown.tax,
        total: breakdown.total,
      );

      emit(currentState.copyWith(
        selectedCheckIn: checkIn,
        selectedCheckOut: checkOut,
        feePreview: feePreview,
      ));
    }
  }

  /// Selects the number of guests.
  void selectGuests(int count) {
    final currentState = state;
    if (currentState is PropertyDetailLoaded) {
      emit(currentState.copyWith(selectedGuests: count));
    }
  }

  /// Reveals the host contact info (requires confirmed booking in real app).
  void revealContact() {
    final currentState = state;
    if (currentState is PropertyDetailLoaded) {
      emit(currentState.copyWith(contactRevealed: true));
    }
  }
}
