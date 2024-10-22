part of network_plus;

class ErrorInterceptors extends Interceptor {
  final Dio dio;

  ErrorInterceptors(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log.e('ErrorInterceptors : inside onError with error type ${err.type} code ${err.response} with error ${err.response}');
    switch (err.type) {
      case  DioExceptionType.connectionTimeout:
      case  DioExceptionType.connectionError:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeOutException(err.requestOptions);
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            Log.e('ErrorInterceptors : inside 400 with error type ${err.type} code ${err.response} with error ${err.response}');
            throw BadRequestException(err.requestOptions, err.response);
          case 401:
            throw UnauthorizedException(err.requestOptions);
          case 404:
            throw NotFoundException(err.requestOptions, err.response);
          case 409:
            throw ConflictException(err.requestOptions , err.response);
          case 500:
            throw InternalServerErrorException(err.requestOptions);
        }
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.unknown:
        throw UnKnownError(err.requestOptions ,  err.response);
      case DioExceptionType.badCertificate:
        throw NoInternetConnectionException(err.requestOptions ,  err.response);
    }

    return handler.next(err);
  }
}