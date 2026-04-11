import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class AssignmentsApiService {
  AssignmentsApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getAssignments({Map<String, dynamic>? query}) =>
      _dio.get(ApiEndpoints.assignments, queryParameters: query);

  /// Use [FormData] when uploading files.
  Future<Response<dynamic>> submitAssignment(
    int assignmentId,
    dynamic data,
  ) =>
      _dio.post(ApiEndpoints.submitAssignment(assignmentId), data: data);
}
