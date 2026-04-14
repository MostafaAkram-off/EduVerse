import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/features/instructor/data/mock/instructor_mock.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_state.dart';

class InstructorCubit extends Cubit<InstructorState> {
  InstructorCubit() : super(const InstructorInitial());

  Future<void> loadData() async {
    emit(const InstructorLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      emit(InstructorLoaded(
        stats:            InstructorMock.stats,
        courses:          InstructorMock.courses,
        todaySessions:    InstructorMock.todaySessions,
        upcomingSessions: InstructorMock.upcomingSessions,
        students:         InstructorMock.students,
      ));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  void refresh() => loadData();
}
