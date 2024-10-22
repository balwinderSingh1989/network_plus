part of retail_core;

class BadRequestException extends DioException {
  BadRequestException(RequestOptions r, Response? rs) : super(requestOptions: r , response : rs);

  @override
  String toString() {
    return  this.response.toString();
  }
}

class InternalServerErrorException extends DioException {
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Unknown error occurred, please try again later.';
  }
}

class ConflictException extends DioException {
  ConflictException(RequestOptions r, Response? rs) : super(requestOptions: r , response : rs);

  @override
  String toString() {
    return this.response.toString();
  }
}

class UnauthorizedException extends DioException {
  UnauthorizedException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'ACCESS_DENIED';
  }
}

class NotFoundException extends DioException {
  NotFoundException(RequestOptions r , Response? rs) : super(requestOptions: r, response: rs);

  @override
  String toString() {
    return this.response.toString();
  }
}

class NoInternetConnectionException extends DioException {
  NoInternetConnectionException(RequestOptions r, Response? rs) : super(requestOptions: r, response: rs);

  @override
  String toString() {
    return ErrorCodes.NO_INTERNET;
  }
}


class UnKnownError extends DioException {
  UnKnownError(RequestOptions r,  Response? rs) : super(requestOptions: r , response: rs);

  @override
  String toString() {
    return  'Unknown error occurred, please try again.';
  }
}

class TimeOutException extends DioException {
  TimeOutException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return ErrorCodes.TIME_OUT;
  }
}

class ErrorCodes{

  static const  ACCESS_DENIED = "ACCESS_DENIED" ;
  static const  NOT_FOUND = "NOT_FOUND" ;
  static const  NO_INTERNET = "NO_INTERNET" ;
  static const  TIME_OUT = "RESPONSE_TIME_OUT" ;

}