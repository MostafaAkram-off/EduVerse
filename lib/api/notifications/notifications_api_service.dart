import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class NotificationsApiService {
  NotificationsApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getNotifications({Map<String, dynamic>? query}) =>
      _dio.get(ApiEndpoints.notifications, queryParameters: query);

  Future<Response<dynamic>> markRead(int id) =>
      _dio.patch(ApiEndpoints.notificationRead(id));
}
