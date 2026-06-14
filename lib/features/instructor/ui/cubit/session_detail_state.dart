import 'package:edu_verse/features/instructor/data/models/attendance_record.dart';

abstract class InstructorSessionDetailState {
  const InstructorSessionDetailState();
}

class InstructorSessionDetailInitial extends InstructorSessionDetailState {
  const InstructorSessionDetailInitial();
}

class InstructorSessionDetailLoading extends InstructorSessionDetailState {
  const InstructorSessionDetailLoading();
}

class InstructorSessionDetailLoaded extends InstructorSessionDetailState {
  const InstructorSessionDetailLoaded({
    required this.attendance,
    this.qrCode,
    this.isGeneratingQr = false,
    this.isMarking = false,
    this.qrError,
  });

  final List<AttendanceRecord> attendance;
  final String? qrCode;
  final bool isGeneratingQr;
  final bool isMarking;
  final String? qrError;

  static const _keep = Object();

  InstructorSessionDetailLoaded copyWith({
    List<AttendanceRecord>? attendance,
    String? qrCode,
    bool? isGeneratingQr,
    bool? isMarking,
    Object? qrError = _keep,
  }) =>
      InstructorSessionDetailLoaded(
        attendance: attendance ?? this.attendance,
        qrCode: qrCode ?? this.qrCode,
        isGeneratingQr: isGeneratingQr ?? this.isGeneratingQr,
        isMarking: isMarking ?? this.isMarking,
        qrError: identical(qrError, _keep) ? this.qrError : qrError as String?,
      );
}

class InstructorSessionDetailError extends InstructorSessionDetailState {
  const InstructorSessionDetailError(this.message);
  final String message;
}
