// Generic Result type with custom error
part of network_plus;

class Result<T> {
  final bool isSuccess;
  final T? data;
  final NetworkError? error;

  const Result.success(T this.data) : isSuccess = true, error = null;
  const Result.failure(this.error) : isSuccess = false, data = null;
}

