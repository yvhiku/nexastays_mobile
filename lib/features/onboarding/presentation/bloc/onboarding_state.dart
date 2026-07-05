// =============================================================================
// NexaStays Onboarding State
// =============================================================================

class OnboardingState {
  const OnboardingState({
    required this.currentPage,
    required this.isLastPage,
  });

  final int currentPage;
  final bool isLastPage;

  factory OnboardingState.initial() {
    return const OnboardingState(
      currentPage: 0,
      isLastPage: false,
    );
  }

  OnboardingState copyWith({
    int? currentPage,
    bool? isLastPage,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}
