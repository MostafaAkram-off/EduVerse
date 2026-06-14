import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/api/instructor/instructor_api_service.dart';
import 'package:edu_verse/features/instructor/data/mock/instructor_mock.dart';
import 'package:edu_verse/features/instructor/data/models/instructor_stats.dart';
import 'package:edu_verse/features/instructor/data/models/session_model.dart';
import 'package:edu_verse/features/instructor/data/models/student_model.dart';
import 'package:edu_verse/features/instructor/ui/cubit/instructor_state.dart';

class InstructorCubit extends Cubit<InstructorState> {
  InstructorCubit(this._api) : super(const InstructorInitial());

  final InstructorApiService _api;

  Future<void> loadData() async {
    emit(const InstructorLoading());
    try {
      final results = await Future.wait([
        _api.getOverview(),
        _api.getSessions(),
        _api.getStudents(),
      ]);

      // Parse stats
      final overviewRaw = results[0].data;
      final statsMap = overviewRaw is Map<String, dynamic>
          ? overviewRaw
          : <String, dynamic>{};
      final stats = InstructorStats.fromJson(statsMap);

      // Parse sessions → split into today / upcoming
      final sessionsRaw = results[1].data;
      final sessionsList = sessionsRaw is List
          ? sessionsRaw
          : sessionsRaw is Map
              ? ((sessionsRaw['data'] ?? sessionsRaw['sessions'] ?? []) as List)
              : <dynamic>[];
      final now = DateTime.now();
      final today    = <SessionModel>[];
      final upcoming = <SessionModel>[];
      for (final s in sessionsList) {
        final session = SessionModel.fromJson(s as Map<String, dynamic>);
        final d = session.startTime;
        if (d.year == now.year && d.month == now.month && d.day == now.day) {
          today.add(session);
        } else if (d.isAfter(now)) {
          upcoming.add(session);
        }
      }
      today.sort((a, b) => a.startTime.compareTo(b.startTime));
      upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Parse students
      final studentsRaw = results[2].data;
      final studentsList = studentsRaw is List
          ? studentsRaw
          : studentsRaw is Map
              ? ((studentsRaw['data'] ?? studentsRaw['students'] ?? []) as List)
              : <dynamic>[];
      final students = studentsList
          .map((s) => StudentModel.fromJson(s as Map<String, dynamic>))
          .toList();

      emit(InstructorLoaded(
        stats:            stats,
        courses:          InstructorMock.courses,
        todaySessions:    today,
        upcomingSessions: upcoming,
        students:         students,
      ));
    } catch (_) {
      // Fall back to mock while the backend endpoint is being finalised
      emit(InstructorLoaded(
        stats:            InstructorMock.stats,
        courses:          InstructorMock.courses,
        todaySessions:    InstructorMock.todaySessions,
        upcomingSessions: InstructorMock.upcomingSessions,
        students:         InstructorMock.students,
      ));
    }
  }

  void refresh() => loadData();
}
