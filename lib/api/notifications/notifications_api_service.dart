import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class NotificationsApiService {
  NotificationsApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getMyNotifications() =>
      _dio.get(ApiEndpoints.myNotifications);

  Future<Response<dynamic>> markAsRead(String id) =>
      _dio.post(ApiEndpoints.markNotificationRead(id));
}
