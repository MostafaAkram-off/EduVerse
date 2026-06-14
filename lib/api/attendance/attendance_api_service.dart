import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class AttendanceApiService {
  AttendanceApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> markAttendance(
    String sessionId,
    String attendanceCode,
  ) =>
      _dio.post(
        ApiEndpoints.markAttendance(sessionId),
        data: {'attendanceCode': attendanceCode},
      );

  Future<Response<dynamic>> getSessionAttendance(String sessionId) =>
      _dio.get(ApiEndpoints.sessionAttendance(sessionId));

  Future<Response<dynamic>> createSessionQr(String sessionId) =>
      _dio.post(ApiEndpoints.createSessionQr(sessionId));
}
