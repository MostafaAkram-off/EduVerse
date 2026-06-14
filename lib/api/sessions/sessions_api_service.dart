import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class SessionsApiService {
  SessionsApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getAllSessions(String courseId) =>
      _dio.get(ApiEndpoints.getAllSessions(courseId));
}
