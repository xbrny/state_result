class StateResult<T> {
  final _ResultStatus status;
  final String message;
  final T data;

  StateResult({
    this.status,
    this.message,
    this.data,
  });

  factory StateResult.loading() => StateResult(status: _ResultStatus.loading);

  factory StateResult.idle() => StateResult(status: _ResultStatus.idle);

  factory StateResult.failure(String message) => StateResult(
        status: _ResultStatus.failure,
        message: message.toString(),
      );

  factory StateResult.success(T data) => StateResult(
        status: _ResultStatus.success,
        data: data,
      );

  @override
  String toString() {
    return 'Result{status: $status, message: $message, data: $data}';
  }

  StateResult copyWith({
    _ResultStatus status,
    String message,
    T data,
  }) {
    return new StateResult(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  bool get isLoading => status == _ResultStatus.loading;

  bool get isSuccess => status == _ResultStatus.success;

  bool get isFailure => status == _ResultStatus.failure;

  bool get isIdle => status == _ResultStatus.idle;
}

enum _ResultStatus {
  loading,
  failure,
  success,
  idle,
}
