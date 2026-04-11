/// Generic API envelope. Adjust [fromJsonT] when your backend shape is known.
class BaseResponse<T> {
  const BaseResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.raw,
  });

  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final Object? raw;

  /// Common patterns: `{ "success": true, "data": ... }` or `{ "message": "" }`
  factory BaseResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Object? json)? fromJsonT,
    bool? success,
    String? dataKey,
  }) {
    final bool resolvedSuccess;
    if (success != null) {
      resolvedSuccess = success;
    } else if (json.containsKey('success')) {
      resolvedSuccess = json['success'] as bool? ?? false;
    } else {
      resolvedSuccess =
          json['status'] == 'ok' || json['code'] == 200;
    }
    final msg = json['message'] as String? ??
        json['error'] as String? ??
        json['msg'] as String?;
    final key = dataKey ?? 'data';
    final payload = json.containsKey(key) ? json[key] : json;
    return BaseResponse<T>(
      success: resolvedSuccess,
      message: msg,
      data: fromJsonT != null ? fromJsonT(payload) : payload as T?,
      statusCode: json['code'] as int?,
      raw: json,
    );
  }

  factory BaseResponse.failure(String message, {int? statusCode, Object? raw}) {
    return BaseResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      raw: raw,
    );
  }

  factory BaseResponse.ok(T data, {String? message, int? statusCode}) {
    return BaseResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }
}
