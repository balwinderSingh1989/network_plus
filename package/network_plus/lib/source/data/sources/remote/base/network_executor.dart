// Network executor with generic types
part of network_plus;

enum METHOD_TYPE { POST, GET, DELETE, PUT, PATCH }

class NetworkExecutor<T extends BaseResponseModel> {
  final ApiClient _apiClient;

  NetworkExecutor(this._apiClient);

  //TODO need to check why we have to pass K and T explicitly in dart with Generic
  //T is backend response
  //K is UIModel
  Future<Result<K>> execute<M extends Mapper<T,K> ,T extends BaseResponseModel,  K>({
    required String urlPath,
    required METHOD_TYPE method,
    required BaseRequestModel params,
    String? id,
    required M mapper,
    bool isJsonEncode = false,
    Map<String, dynamic>? headers,
    required T dataResponseType,
    CachePolicy? cachePolicy = null,
    RetryPolicy? retryPolicy = null,
  }) async {
    try {
      // Instead of directly modifying Dio's headers, consider a new map
      final requestOptions = Options(
        headers: headers != null && headers.isNotEmpty
            ? {..._apiClient._dio.options.headers, ...headers}
            : _apiClient._dio.options.headers,
      );

      final response = await _apiClient.sendRequest(urlPath, method, params, id: id, isJsonEncode: isJsonEncode, cachePolicy : cachePolicy , options: requestOptions);

      //final data = await NetworkDecoder.shared.decode<T>(response: response , responseType : dataResponseType );

      final data = await NetworkDecoderX.shared.decode<T, M, K>(
        response: response,
        responseType: dataResponseType,
        mapper: mapper,
      );
      //TODO mapper.mapFrom can be moved to decode above.
      return Result.success(data);
      
    } catch (error) {
        Log.e('NetworkExecutor with network request ${error}');

      if (error is DioException) {

        Log.e('NetworkExecutor error with network response ${error.response} and error $error ');

        if(error is TimeOutException || error is NoInternetConnectionException)
          return Result.failure(NetworkError.connectivity(message: error is TimeOutException ? "Request timeout occured" : error.message));
        else if(error is UnKnownError) {
          Log.e('NetworkExecutor error UnKnownError');

          return Result.failure(NetworkError.type(error: error.toString()));
        } else {
          if ( (retryPolicy?.retrialCount ?? 0) > 0) {
            await Future.delayed(retryPolicy?.retryDelay ?? Duration(seconds: 1));
            return execute<M, T, K>(
              urlPath: urlPath,
              method: method,
              params: params,
              id: id,
              mapper: mapper,
              isJsonEncode: isJsonEncode,
              headers: headers,
              dataResponseType: dataResponseType,
              cachePolicy: cachePolicy,
              retryPolicy: RetryPolicy(
                retrialCount: (retryPolicy?.retrialCount ?? 0 ) - 1,
                retryDelay: retryPolicy?.retryDelay ?? Duration(seconds: 1),
              ),
            );
          } else {
            return Result.failure(NetworkError.request(error: error));
          }
        }
      } else if (error is TypeError) {
        return Result.failure(NetworkError.type(error: error.toString()));
      } else {
        return Result.failure(NetworkError.type(error: error.toString()));
      }
    }
  }
}