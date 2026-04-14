import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class ProfileApiService {
  ProfileApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getProfile() => _dio.get(ApiEndpoints.profile);

  Future<Response<dynamic>> updateProfile(Map<String, dynamic> body) =>
      _dio.put(ApiEndpoints.updateProfile, data: body);
}
