import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class EnrollmentApiService {
  EnrollmentApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> enroll(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.enroll, data: body);

  Future<Response<dynamic>> getPaymentHistory({Map<String, dynamic>? query}) =>
      _dio.get(ApiEndpoints.paymentHistory, queryParameters: query);

  Future<Response<dynamic>> getPaymentReceipt(String paymentId) =>
      _dio.get(ApiEndpoints.paymentReceipt(paymentId));
}
