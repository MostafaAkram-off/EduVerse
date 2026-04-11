import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class CoursesApiService {
  CoursesApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getCourses({Map<String, dynamic>? query}) =>
      _dio.get(ApiEndpoints.courses, queryParameters: query);

  Future<Response<dynamic>> getCourseDetail(int id) =>
      _dio.get(ApiEndpoints.courseDetail(id));
}
