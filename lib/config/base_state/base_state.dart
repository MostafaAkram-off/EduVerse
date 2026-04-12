abstract class BaseState {
  const BaseState();
}

class BaseInitial extends BaseState {
  const BaseInitial();
}

class BaseLoading extends BaseState {
  const BaseLoading();
}

class BaseSuccess<T> extends BaseState {
  final T data;
  const BaseSuccess(this.data);
}

class BaseError extends BaseState {
  final String message;
  const BaseError(this.message);
}