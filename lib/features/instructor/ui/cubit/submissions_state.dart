import 'package:edu_verse/features/instructor/data/models/submission_model.dart';

abstract class InstructorSubmissionsState {
  const InstructorSubmissionsState();
}

class InstructorSubmissionsInitial extends InstructorSubmissionsState {
  const InstructorSubmissionsInitial();
}

class InstructorSubmissionsLoading extends InstructorSubmissionsState {
  const InstructorSubmissionsLoading();
}

class InstructorSubmissionsLoaded extends InstructorSubmissionsState {
  const InstructorSubmissionsLoaded({
    required this.submissions,
    this.isGrading = false,
  });

  final List<SubmissionModel> submissions;
  final bool isGrading;

  InstructorSubmissionsLoaded copyWith({
    List<SubmissionModel>? submissions,
    bool? isGrading,
  }) =>
      InstructorSubmissionsLoaded(
        submissions: submissions ?? this.submissions,
        isGrading: isGrading ?? this.isGrading,
      );
}

class InstructorSubmissionsError extends InstructorSubmissionsState {
  const InstructorSubmissionsError(this.message);
  final String message;
}
