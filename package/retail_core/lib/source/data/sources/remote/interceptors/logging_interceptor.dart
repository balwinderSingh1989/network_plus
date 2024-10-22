part of retail_core;

///LogInterceptor should be the last to add since the interceptors are FIFO.
class LogInterceptor extends Interceptor {

  LogInterceptor();


  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Log.d(
        'LogInterceptor REQUEST[${options.method}] => PATH: ${options.path} \n \n');
    Log.d('LogInterceptor  ${options.headers}] => PARAMS: ${options.data}');
    Log.d('LogInterceptor CURL  ${generateCurl(options)}');
    
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
      Log.d("LogInterceptor RESPONSE[${response
          .statusCode}] => PATH: ${response.requestOptions.path}'");
      Log.i(
          "LogInterceptor RESPONSE DATA[${response.data}] => PATH: ${response
              .requestOptions.path}'");
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Log.e(
        'LogInterceptor ERROR[${err.response?.statusCode}]  ERR Response[${err.response}] => PATH: ${err.requestOptions.path}');
    return super.onError(err, handler);
  }
}