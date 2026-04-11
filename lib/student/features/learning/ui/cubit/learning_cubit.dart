import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/enrolled_course_model.dart';
import 'package:edu_verse/student/features/mock_data.dart';

part 'learning_state.dart';

class LearningCubit extends Cubit<LearningState> {
  LearningCubit() : super(LearningInitial());

  Future<void> loadLearning() async {
    emit(LearningLoading());

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final all = MockData.enrolledCourses;

      // A course is "completed" when progress is 100%
      final inProgress =
          all.where((e) => e.course.progressPercent < 100).toList();
      final completed =
          all.where((e) => e.course.progressPercent == 100).toList();

      emit(LearningLoaded(
        inProgress: inProgress,
        completed: completed,
        activeTab: LearningTab.inProgress,
      ));
    } catch (e) {
      emit(LearningError('Failed to load your courses. Please try again.'));
    }
  }

  void switchTab(LearningTab tab) {
    if (state is LearningLoaded) {
      emit((state as LearningLoaded).copyWith(activeTab: tab));
    }
  }
}
