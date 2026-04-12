class BaseResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;

  const BaseResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      statusCode: json['status_code'] as int?,
    );
  }

  bool get hasData => data != null;

  @override
  String toString() =>
      'BaseResponse(success: $success, message: $message, data: $data)';
}