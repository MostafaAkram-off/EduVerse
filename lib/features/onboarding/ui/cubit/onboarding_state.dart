class OnboardingState {
  const OnboardingState({this.currentPage = 0});
  final int currentPage;
  OnboardingState copyWith({int? currentPage}) =>
      OnboardingState(currentPage: currentPage ?? this.currentPage);
}
