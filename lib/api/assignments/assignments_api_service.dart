import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class AssignmentsApiService {
  AssignmentsApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getAllAssignments(String courseId) =>
      _dio.get(ApiEndpoints.getAllAssignments(courseId));

  Future<Response<dynamic>> getAssignmentsBySession(String sessionId) =>
      _dio.get(ApiEndpoints.getAssignmentsBySession(sessionId));

  Future<Response<dynamic>> submitAssignment(FormData formData) =>
      _dio.post(ApiEndpoints.submitAssignment, data: formData);

  Future<Response<dynamic>> submitAssignmentById(
    String assignmentId,
    FormData formData,
  ) =>
      _dio.post(ApiEndpoints.submitAssignmentById(assignmentId), data: formData);

  Future<Response<dynamic>> getMySubmissions() =>
      _dio.get(ApiEndpoints.mySubmissions);

  Future<Response<dynamic>> getMySubmission(String id) =>
      _dio.get(ApiEndpoints.mySubmission(id));

  Future<Response<dynamic>> getUserSubmissions(String email) =>
      _dio.get(ApiEndpoints.userSubmissions(email));

  Future<Response<dynamic>> getSubmission(String assignmentId, String email) =>
      _dio.get(ApiEndpoints.submission(assignmentId, email));

  Future<Response<dynamic>> getAssignmentSubmissions(String assignmentId) =>
      _dio.get(ApiEndpoints.assignmentSubmissions(assignmentId));
}
