// =============================================================================
// NexaStays Onboarding Cubit
// =============================================================================
// Manages onboarding page navigation state via flutter_bloc.
// =============================================================================

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'onboarding_state.dart';

/// Cubit that drives the onboarding page-view navigation.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingState.initial());

  /// Total number of onboarding pages.
  static const int totalPages = 3;

  // ── Page tracking ──────────────────────────────────────────────────

  /// Called whenever the [PageView] page changes.
  ///
  /// Updates [OnboardingState.currentPage] and sets
  /// [OnboardingState.isLastPage] when the user reaches the final page.
  void updatePage(int index) {
    emit(state.copyWith(
      currentPage: index,
      isLastPage: index == totalPages - 1,
    ));
  }

  // ── Navigation actions ─────────────────────────────────────────────

  /// Advances to the next page, or triggers onboarding completion
  /// if already on the last page.
  void nextPage(PageController controller) {
    if (!state.isLastPage) {
      controller.animateToPage(
        state.currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // TODO: Mark onboarding as complete and navigate to login / home.
    }
  }

  /// Skips directly to the last onboarding page.
  void skip(PageController controller) {
    controller.animateToPage(
      totalPages - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
