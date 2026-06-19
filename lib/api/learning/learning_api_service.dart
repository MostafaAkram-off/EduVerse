import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class LearningApiService {
  LearningApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getMyEnrolledCourses() =>
      _dio.get(ApiEndpoints.myEnrolledCourses);

  Future<Response<dynamic>> getCourseProgress(String courseId) =>
      _dio.get(ApiEndpoints.progressCourse(courseId));

  Future<Response<dynamic>> toggleSessionDone(String sessionId) =>
      _dio.post(ApiEndpoints.toggleSessionDone(sessionId));

  Future<Response<dynamic>> getMyAssignments() =>
      _dio.get(ApiEndpoints.myAssignments);

  Future<Response<dynamic>> getMySubmissions() =>
      _dio.get(ApiEndpoints.mySubmissions);
}
