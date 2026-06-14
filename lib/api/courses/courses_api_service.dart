import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class CoursesApiService {
  CoursesApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getAllCourses({Map<String, dynamic>? query}) =>
      _dio.get(ApiEndpoints.getAllCourses, queryParameters: query);

  Future<Response<dynamic>> getCourseById(String id) =>
      _dio.get(ApiEndpoints.getCourseById(id));

  Future<Response<dynamic>> getAllSessions(String courseId) =>
      _dio.get(ApiEndpoints.getAllSessions(courseId));

  Future<Response<dynamic>> getAllAssignments(String courseId) =>
      _dio.get(ApiEndpoints.getAllAssignments(courseId));

  Future<Response<dynamic>> getAssignmentsBySession(String sessionId) =>
      _dio.get(ApiEndpoints.getAssignmentsBySession(sessionId));

  Future<Response<dynamic>> searchCourses(String query) =>
      _dio.get(ApiEndpoints.searchCourses(query));

  Future<Response<dynamic>> getCoursesByCategory(String categoryId) =>
      _dio.get(ApiEndpoints.getCoursesByCategory(categoryId));

  Future<Response<dynamic>> addRating({
    required String courseId,
    required int ratingValue,
  }) =>
      _dio.post(ApiEndpoints.addRating,
          data: {'courseId': courseId, 'ratingValue': ratingValue});
}
