import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class ProfileApiService {
  ProfileApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getProfile() =>
      _dio.get(ApiEndpoints.getProfile);

  Future<Response<dynamic>> getUser() =>
      _dio.get(ApiEndpoints.getUser);

  Future<Response<dynamic>> updateProfile(FormData formData) =>
      _dio.put(ApiEndpoints.updateProfile, data: formData);

  Future<Response<dynamic>> changePassword(Map<String, dynamic> body) =>
      _dio.post(ApiEndpoints.changePassword, data: body);

  Future<Response<dynamic>> uploadProfilePicture(FormData formData) =>
      _dio.post(ApiEndpoints.uploadProfilePicture, data: formData);
}
