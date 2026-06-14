import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class EnrollmentApiService {
  EnrollmentApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> enroll(String courseId) =>
      _dio.post(ApiEndpoints.enroll(courseId));

  Future<Response<dynamic>> payment(String courseId, String method) =>
      _dio.post(ApiEndpoints.payment(courseId, method));

  Future<Response<dynamic>> getMyEnrolledCourses() =>
      _dio.get(ApiEndpoints.myEnrolledCourses);

  Future<Response<dynamic>> getMyEnrollment(String courseId) =>
      _dio.get(ApiEndpoints.myEnrollment(courseId));

  Future<Response<dynamic>> getMyPayments() =>
      _dio.get(ApiEndpoints.myPayments);

  Future<Response<dynamic>> getEnrolledUsers(String courseId) =>
      _dio.get(ApiEndpoints.enrolledUsers(courseId));

  Future<Response<dynamic>> getEnrollmentData(String courseId, String email) =>
      _dio.get(ApiEndpoints.enrollmentData(courseId, email));
}
