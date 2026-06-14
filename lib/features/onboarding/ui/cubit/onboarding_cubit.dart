import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/features/onboarding/ui/cubit/onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  void setPage(int page) => emit(state.copyWith(currentPage: page));
  void nextPage() => emit(state.copyWith(currentPage: state.currentPage + 1));
}
