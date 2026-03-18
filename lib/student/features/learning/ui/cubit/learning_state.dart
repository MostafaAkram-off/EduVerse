part of 'learning_cubit.dart';

abstract class LearningState {}

class LearningInitial extends LearningState {}

class LearningLoading extends LearningState {}

class LearningLoaded extends LearningState {
  final List<EnrolledCourseModel> inProgress;
  final List<EnrolledCourseModel> completed;
  final LearningTab activeTab;

  LearningLoaded({
    required this.inProgress,
    required this.completed,
    required this.activeTab,
  });

  LearningLoaded copyWith({LearningTab? activeTab}) {
    return LearningLoaded(
      inProgress: inProgress,
      completed: completed,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class LearningError extends LearningState {
  final String message;
  LearningError(this.message);
}

enum LearningTab { inProgress, completed }