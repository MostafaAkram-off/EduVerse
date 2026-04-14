import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class AttendanceApiService {
  AttendanceApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> scanQr(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.attendanceScan, data: body);
}
