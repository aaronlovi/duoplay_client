enum ResultErrorCode {
  none,
  unknown, // Generic error
  invalidMove,
  gameOver,
  invalidTime,
  invalidState,
}

class Result {
  final bool isSuccess;
  final ResultErrorCode errorCode;
  final List<String> errorParameters;

  Result.success()
    : isSuccess = true,
      errorCode = ResultErrorCode.none,
      errorParameters = const [];

  Result.failure(this.errorCode, {this.errorParameters = const []})
    : isSuccess = false;

  bool get isFailure => !isSuccess;

  @override
  String toString() =>
      isSuccess
          ? 'Result: Success'
          : 'Result: Failure, ErrorCode: $errorCode, Parameters: $errorParameters';

  static Result fromGenericFailure<T>(GenericResult<T> failure) =>
      Result.failure(
        failure.errorCode,
        errorParameters: failure.errorParameters,
      );
}

class GenericResult<T> {
  final bool isSuccess;
  final ResultErrorCode errorCode;
  final List<String> errorParameters;
  final T? value;

  GenericResult.success(this.value)
    : isSuccess = true,
      errorCode = ResultErrorCode.none,
      errorParameters = const [];

  GenericResult.failure(this.errorCode, {this.errorParameters = const []})
    : isSuccess = false,
      value = null;

  GenericResult.fromFailureResult(Result res)
    : isSuccess = false,
      errorCode = res.errorCode,
      errorParameters = res.errorParameters,
      value = null;

  bool get isFailure => !isSuccess;

  @override
  String toString() =>
      isSuccess
          ? 'Result: Success, Data: $value'
          : 'Result: Failure, ErrorCode: $errorCode, Parameters: $errorParameters';
}
