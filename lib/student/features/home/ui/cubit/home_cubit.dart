import 'package:edu_verse/student/features/courses/data/models/course_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/student/features/mock_data.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());

    // Simulate network delay — replace with real usecase call later
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final enrolled = MockData.courses.where((c) => c.isEnrolled).toList();
      final recommended = MockData.courses.where((c) => !c.isEnrolled).toList();

      emit(HomeLoaded(
        enrolledCourses: enrolled,
        upcomingSessions: MockData.upcomingSessions,
        recommendedCourses: recommended,
        completedCourses: 2,
        totalHours: 42,
      ));
    } catch (e) {
      emit(HomeError('Failed to load home data. Please try again.'));
    }
  }
}