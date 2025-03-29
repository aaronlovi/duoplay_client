import 'package:duoplay/models/unit.dart';

enum ResultErrorCode {
  none,
  unknown, // Generic error
  invalidMove,
  gameOver,
}

class Result<T> {
  final bool isSuccess;
  final ResultErrorCode errorCode;
  final List<String> errorParameters;
  final T? data;

  Result.success(this.data)
    : isSuccess = true,
      errorCode = ResultErrorCode.none,
      errorParameters = const [];

  Result.failure(this.errorCode, {this.errorParameters = const []})
    : isSuccess = false,
      data = null;

  bool get isFailure => !isSuccess;

  @override
  String toString() =>
      isSuccess
          ? 'Result: Success, Data: $data'
          : 'Result: Failure, ErrorCode: $errorCode, Parameters: $errorParameters';

  static Result<Unit> fromFailure<T>(Result<T> failure) => Result<Unit>.failure(
    failure.errorCode,
    errorParameters: failure.errorParameters,
  );
}
