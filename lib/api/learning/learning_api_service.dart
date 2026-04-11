import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

/// Student "My Learning" / classroom aggregate endpoints.
class LearningApiService {
  LearningApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getMyCourses({Map<String, dynamic>? query}) =>
      _dio.get(ApiEndpoints.myCourses, queryParameters: query);

  Future<Response<dynamic>> getClassroom(int courseId) =>
      _dio.get(ApiEndpoints.classroom(courseId));
}
