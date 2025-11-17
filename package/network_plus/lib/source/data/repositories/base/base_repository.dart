part of network_plus;


abstract class BaseRepository<T extends BaseResponseModel<dynamic>> {
  final NetworkExecutor _networkExecutor;

  BaseRepository(this._networkExecutor );

  Future<Result<K>> execute<M extends Mapper<T, K> ,T extends BaseResponseModel, K >({
    required M mapper,
    required String urlPath,
    required METHOD_TYPE method,
    required BaseRequestModel params,
    String? id,
    required T responseType,
    bool isJsonEncode = false,
    Map<String , dynamic>? headers,
    CacheOption? cacheOption = null,
    RetryPolicy? retryPolicy = null
  }) async {
      final result = await _networkExecutor.execute<M, T, K>(
        urlPath: urlPath,
        method: method,
        params: params,
        id: id,
        headers: headers,
        dataResponseType: responseType,
        isJsonEncode: isJsonEncode,
        mapper: mapper,
        cacheOption: cacheOption,
        retryPolicy: retryPolicy
      );
      return result;
  }
}
