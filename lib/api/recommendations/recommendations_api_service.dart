import 'package:dio/dio.dart';
import 'package:edu_verse/core/constants/api_endpoints.dart';

class RecommendationsApiService {
  RecommendationsApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getForMe() =>
      _dio.get(ApiEndpoints.recommendationsForMe);

  Future<Response<dynamic>> getTrending() =>
      _dio.get(ApiEndpoints.recommendationsTrending);

  Future<Response<dynamic>> getSimilar(String courseId) =>
      _dio.get(ApiEndpoints.recommendationsSimilar(courseId));
}
