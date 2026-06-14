import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class LearningApiService {
  LearningApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getMyEnrolledCourses() =>
      _dio.get(ApiEndpoints.myEnrolledCourses);

  Future<Response<dynamic>> getMyCourseProgress(String courseId) =>
      _dio.get(ApiEndpoints.myCourseProgress(courseId));

  Future<Response<dynamic>> markSessionCompleted(String sessionId) =>
      _dio.post(ApiEndpoints.markSessionCompleted(sessionId));

  Future<Response<dynamic>> getMyAssignments() =>
      _dio.get(ApiEndpoints.myAssignments);

  Future<Response<dynamic>> getMySubmissions() =>
      _dio.get(ApiEndpoints.mySubmissions);
}
