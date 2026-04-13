class BaseResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  const BaseResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return BaseResponse<T>(
      success:    json['success'] as bool? ?? false,
      message:    json['message'] as String? ?? '',
      statusCode: json['statusCode'] as int?,
      data:       json['data'] != null && fromData != null
                      ? fromData(json['data'])
                      : null,
    );
  }
}
