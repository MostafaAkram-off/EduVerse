class RegisterResponse {
  final String message;
  final String? email;

  const RegisterResponse({required this.message, this.email});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] as String? ?? '',
      email: json['email'] as String?,
    );
  }
}
