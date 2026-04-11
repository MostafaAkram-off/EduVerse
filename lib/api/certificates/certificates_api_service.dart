import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class CertificatesApiService {
  CertificatesApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getCertificates({Map<String, dynamic>? query}) =>
      _dio.get(ApiEndpoints.certificates, queryParameters: query);

  Future<Response<dynamic>> getCertificateDetail(String id) =>
      _dio.get(ApiEndpoints.certificateDetail(id));
}
