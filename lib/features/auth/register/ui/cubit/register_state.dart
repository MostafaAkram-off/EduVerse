sealed class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess(this.email);
  final String email;
}

class RegisterVerifying extends RegisterState {
  const RegisterVerifying();
}

class RegisterVerified extends RegisterState {
  const RegisterVerified();
}

class RegisterResending extends RegisterState {
  const RegisterResending();
}

class RegisterError extends RegisterState {
  const RegisterError(this.message);
  final String message;
}
