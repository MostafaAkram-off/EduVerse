import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class CertificatesApiService {
  CertificatesApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getMyCertificates() =>
      _dio.get(ApiEndpoints.myCertificates);

  Future<Response<dynamic>> generateCertificate(String courseId) =>
      _dio.post(ApiEndpoints.generateCertificate(courseId));

  Future<Response<dynamic>> verifyCertificate(String code) =>
      _dio.get(ApiEndpoints.verifyCertificate(code));

  Future<Response<dynamic>> getUserCertificates(String email) =>
      _dio.get(ApiEndpoints.userCertificates(email));

  Future<Response<dynamic>> getCertificateFile(String courseId, String email) =>
      _dio.get(ApiEndpoints.certificateFile(courseId, email));

  Future<Response<dynamic>> addCertificate(FormData formData) =>
      _dio.post(ApiEndpoints.addCertificate, data: formData);

  Future<Response<List<int>>> downloadCertificate(String certificateId) =>
      _dio.get<List<int>>(
        ApiEndpoints.downloadCertificate(certificateId),
        options: Options(responseType: ResponseType.bytes),
      );
}
