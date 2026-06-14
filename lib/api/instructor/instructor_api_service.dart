import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class InstructorApiService {
  InstructorApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getOverview() =>
      _dio.get(ApiEndpoints.instructorOverview);

  Future<Response<dynamic>> getSessions() =>
      _dio.get(ApiEndpoints.instructorSessions);

  Future<Response<dynamic>> getStudents() =>
      _dio.get(ApiEndpoints.instructorStudents);

  Future<Response<dynamic>> getSubmissions() =>
      _dio.get(ApiEndpoints.instructorSubmissions);

  Future<Response<dynamic>> getSubmission(
    String assignmentId,
    String studentId,
  ) =>
      _dio.get(ApiEndpoints.instructorSubmission(assignmentId, studentId));

  Future<Response<dynamic>> gradeSubmission(
    String assignmentId,
    String studentId,
    Map<String, dynamic> body,
  ) =>
      _dio.post(
        ApiEndpoints.gradeSubmission(assignmentId, studentId),
        data: body,
      );

  Future<Response<dynamic>> createAssignment(FormData data) =>
      _dio.post(ApiEndpoints.addAssignment, data: data);

  Future<Response<dynamic>> addSession(FormData data) =>
      _dio.post(ApiEndpoints.addSession, data: data);

  Future<Response<dynamic>> markStudentAttendance(
    String sessionId,
    String userId,
  ) =>
      _dio.post(ApiEndpoints.instructorMark(sessionId, userId));

  Future<Response<dynamic>> deleteSession(String id) =>
      _dio.delete(ApiEndpoints.deleteSession(id));

  Future<Response<dynamic>> deleteAssignment(String id) =>
      _dio.delete(ApiEndpoints.deleteAssignment(id));
}
