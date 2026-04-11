import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class SessionsApiService {
  SessionsApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getSessions({Map<String, dynamic>? query}) =>
      _dio.get(ApiEndpoints.sessions, queryParameters: query);

  Future<Response<dynamic>> getSessionDetail(int id) =>
      _dio.get(ApiEndpoints.sessionDetail(id));
}
