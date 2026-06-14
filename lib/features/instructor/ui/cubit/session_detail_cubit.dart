import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edu_verse/api/attendance/attendance_api_service.dart';
import 'package:edu_verse/api/instructor/instructor_api_service.dart';
import 'package:edu_verse/features/instructor/data/models/attendance_record.dart';
import 'package:edu_verse/features/instructor/ui/cubit/session_detail_state.dart';

class InstructorSessionDetailCubit extends Cubit<InstructorSessionDetailState> {
  InstructorSessionDetailCubit(this._attendanceApi, this._instructorApi)
      : super(const InstructorSessionDetailInitial());

  final AttendanceApiService _attendanceApi;
  final InstructorApiService _instructorApi;

  Future<void> loadAttendance(String sessionId) async {
    emit(const InstructorSessionDetailLoading());
    try {
      final res = await _attendanceApi.getSessionAttendance(sessionId);
      final raw = res.data;
      final list = raw is List
          ? raw
          : raw is Map
              ? ((raw['data'] ?? raw['attendance'] ?? raw['records'] ?? []) as List)
              : <dynamic>[];
      final records = list
          .map((r) => AttendanceRecord.fromJson(r as Map<String, dynamic>))
          .toList();
      emit(InstructorSessionDetailLoaded(attendance: records));
    } catch (_) {
      emit(const InstructorSessionDetailLoaded(attendance: []));
    }
  }

  Future<void> generateQr(String sessionId) async {
    final current = state;
    if (current is! InstructorSessionDetailLoaded) return;
    emit(current.copyWith(isGeneratingQr: true, qrError: null));
    try {
      final res = await _attendanceApi.createSessionQr(sessionId);
      final raw = res.data;
      String code;
      if (raw is Map) {
        code = (raw['qrCode'] ?? raw['code'] ?? raw['attendanceCode'] ?? raw['data'] ?? '')
            .toString();
      } else {
        code = raw?.toString() ?? '';
      }
      emit(current.copyWith(isGeneratingQr: false, qrCode: code, qrError: null));
    } catch (_) {
      emit(current.copyWith(
        isGeneratingQr: false,
        qrError: 'Failed to generate QR. Please try again.',
      ));
    }
  }

  Future<void> markStudentAttendance(String sessionId, String userId) async {
    final current = state;
    if (current is! InstructorSessionDetailLoaded) return;
    emit(current.copyWith(isMarking: true));
    try {
      await _instructorApi.markStudentAttendance(sessionId, userId);
      // Optimistic update — flip the student to present
      final updated = current.attendance.map((r) {
        if (r.studentId == userId) {
          return AttendanceRecord(
            id: r.id,
            studentId: r.studentId,
            studentName: r.studentName,
            studentEmail: r.studentEmail,
            isPresent: true,
            markedAt: DateTime.now(),
          );
        }
        return r;
      }).toList();
      emit(current.copyWith(attendance: updated, isMarking: false));
    } catch (_) {
      emit(current.copyWith(isMarking: false));
    }
  }
}
