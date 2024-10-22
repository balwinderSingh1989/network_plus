// Custom exception types for network and type errors
part of retail_core;

class NetworkError {
  final String? message;
  final Response? errResponse;
  final ErrorType type;
  final DioException? error;
  final String? errorCode;

  NetworkError.connectivity({required this.message}) : type = ErrorType.connectivity , error = null , errResponse = null,errorCode = null;
  NetworkError.request({required DioException error}) : type = ErrorType.request , message = error.message , error = error , errResponse = error.response , errorCode = null;
  NetworkError.type({required String error , String? errorCode}) : type = ErrorType.type, message = error , error = null , errResponse  = null, errorCode = errorCode;
}

enum ErrorType {
  connectivity,
  request,
  type,
}