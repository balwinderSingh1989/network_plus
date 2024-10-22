part of retail_core;

/// A custom interceptor for handling token refresh and request retries.
/// This should be the first interceptor added to DIO as interceptors are executed in  FIFO
class AuthTokenInterceptor extends Interceptor {
  final Dio dio;
  final String refreshTokenKey;
  final String accessTokenKey;
  final String refreshTokenUrl;
  Completer<void>? _completer;
  TokenStorage tokenStorage;

  List<Map<dynamic, dynamic>> failedRequests = [];

  /// Constructs a new instance of [AuthTokenInterceptor].
  ///
  /// [dio]: The Dio client instance.
  /// [refreshTokenKey]: The key to access the refresh token.
  /// [refreshTokenUrl]: The URL for refreshing the access token.
  AuthTokenInterceptor(this.dio, this.refreshTokenKey, this.accessTokenKey, this.refreshTokenUrl , this.tokenStorage);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {

    // Log.i(
    //     'Network : TokenInterceptor REQUEST[${options.method}] => PATH: ${options.path}');
    String? token = await tokenStorage.getUserToken();

    if (token != null && token.isNotEmpty) {
      Log.i('Network : TokenInterceptor token is  $token');
      options.headers['Authorization'] = 'Bearer $token';
    }
    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {

    if (err.response?.statusCode == 401 && refreshTokenUrl.isNotEmpty) {

      Log.e("Network TokenInterceptor: token expired");

      if (_completer == null) {

        Log.e("ACCESS TOKEN EXPIRED, GETTING NEW TOKEN PAIR");
        _completer = Completer<void>();

        await refreshToken(err, handler);

        _completer!.complete();
        _completer = null;

      } else {
        ///Refresh token in progess , add all incoming calls to request Queue
        Log.e("ADDING ERROR REQUEST TO FAILED QUEUE");
        failedRequests.add({'err': err, 'handler': handler});
      }
    } else {

      /// some other error that isnt related to token expiry, pass this to next interceptor
      return super.onError(err, handler);
    }
  }


  /// Performs the token refresh operation.
  /// [err]: The Dio error that triggered the token refresh.
  /// [handler]: The error interceptor handler.
  Future<void> refreshToken(
      DioException err, ErrorInterceptorHandler handler) async {

    //to avoid DeadLock using new DIO instanace https://github.com/cfug/dio/issues/1612
    Dio tokenDio = Dio(dio.options);
    tokenDio.interceptors.add(ErrorInterceptors(tokenDio));
    tokenDio.interceptors.add(LogInterceptor());

    String? userToken = await tokenStorage.getUserToken();
    String? refreshToKen = await tokenStorage.getRefreshToken();

    Log.i("CALLING REFRESH TOKEN API");

    Response? refreshResponse = null;
    try {
      try {
        refreshResponse = await tokenDio.post(refreshTokenUrl,
            options: Options(headers: {'Authorization': 'Bearer $userToken'}),
            data: jsonEncode({this.refreshTokenKey : refreshToKen}));
      } on DioException catch (e) {
        /// This will return a error handled from [ErrorInterceptors]
        Log.e("REFRESH TOKEN FAILED FAILED received + $e");
        /// calling site should logout the user
        tokenStorage.clearTokens();
      }

      Log.i(
          "REFRESH TOKEN RESPONSE STATUS  ${refreshResponse?.statusCode}");

      if (refreshResponse?.statusCode == 200 ||
          refreshResponse?.statusCode == 201) {
        ///TODO : "access_token" this key names shouild be set up calling site
        ///
        userToken = refreshResponse?.data[this.accessTokenKey];
        refreshToKen = refreshResponse?.data[refreshTokenKey];

        // parse data based on your JSON structure
        await tokenStorage.setUserToken(userToken.orEmpty()); // save to local storage
        await tokenStorage.setRefreshToken(
            refreshToKen.orEmpty()); // save to local storage

        Log.i(
            "Network TokenInterceptor refreshed successfully ${refreshResponse
                ?.statusCode}  \n new token $userToken");

        /// Update the request header with the new access token
        err.requestOptions.headers['Authorization'] = 'Bearer ${userToken.orEmpty()}';
      } else if (refreshResponse?.statusCode == 401 ||
          refreshResponse?.statusCode == 403) {

        /// it means your refresh token no longer valid now, it may be revoked by the backend
        tokenStorage.clearTokens();

        Log.e(
            "Network TokenInterceptor refresh token no longer valid now ${refreshResponse
                ?.statusCode}");

        /// Complete the request with a error directly! Other error interceptor(s) will not be executed.
        // return handler.next(err);
      } else {
        Log.i(
            "Network  refresh token else case with status code ${refreshResponse
                ?.statusCode}");
      }
    }
    catch(error)
    {
      Log.e("Network  caught some exception status $error");
    }

    /// Repeat the request with the updated header
    /// Complete the request with Response object and other error interceptor(s) will not be executed.
    /// This will be considered a successful request!
    ///
    Log.i(
        "Network  refresh resolving now with ${err.requestOptions.data}");

    Log.i("Network  retrying status");

    failedRequests.add({'err': err, 'handler': handler});

    Log.i("RETRYING TOTAL OF ${failedRequests.length} FAILED REQUEST(s)");
    return retryRequests(tokenDio,userToken.orEmpty())
        .ignore();
  }

  /// Retries failed requests with the updated access token.
  ///
  /// [retryDio]: The Dio client instance for retrying requests.
  /// [token]: The updated access token.
  Future<void> retryRequests(Dio retryDio, String token) async {

    for (var i = 0; i < failedRequests.length; i++) {
      Log.i(
          'RETRYING[$i] => PATH: ${failedRequests[i]['err'].requestOptions.path}');
      RequestOptions requestOptions =
      failedRequests[i]['err'].requestOptions as RequestOptions;

      requestOptions.headers = {
        'Authorization': 'Bearer $token',
      };
      await retryDio.fetch(requestOptions).then(
        failedRequests[i]['handler'].resolve,
        onError: (error) =>
            failedRequests[i]['handler'].reject(error as DioException),
      );
    }
    failedRequests = [];
  }
}