sealed class ForgotPasswordState {
  const ForgotPasswordState();
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordCodeSent extends ForgotPasswordState {
  const ForgotPasswordCodeSent(this.email);
  final String email;
}

class ForgotPasswordCodeVerified extends ForgotPasswordState {
  const ForgotPasswordCodeVerified({required this.email, required this.code});
  final String email;
  final String code;
}

class ForgotPasswordReset extends ForgotPasswordState {
  const ForgotPasswordReset();
}

class ForgotPasswordError extends ForgotPasswordState {
  const ForgotPasswordError(this.message);
  final String message;
}
