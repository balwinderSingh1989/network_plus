part of network_plus;

// Encapsulate Dio client in separate class
class ApiClient {
  late final CacheOptions _cacheOptions;
  late final Dio _dio;

  ApiClient(this._dio, this._cacheOptions);

  // Function to determine param type and build accordingly
  Map<String, dynamic> buildParams(dynamic params) {
    if (params is BaseRequestModel) {
      // Use toJson() method if provided, or throw error if not
      if (params.buildParams() == null) {
        return {};
      } else {
        //TODO null safety
        return params.buildParams()!;
      }
    } else {
      // Handle other types as needed (e.g., throw error, convert to specific format)
      throw TypeError();
    }
  }

  // Send request with generic type for response model
  // Send request with generic type for response model
  Future<Response> sendRequest(String path,
      METHOD_TYPE method,
      BaseRequestModel params, {
        String? id,
        Options? options,
        bool isJsonEncode = false, CachePolicy? cachePolicy = null
      }) async {
    final requestParams = buildParams(params);
    switch (method) {
      case METHOD_TYPE.POST:
        return await _dio.post(path, data: jsonEncode(requestParams) , options: options );
      case METHOD_TYPE.DELETE:
        if (isJsonEncode) {
          return await _dio.delete(path, data: jsonEncode(requestParams) , options: options);
        } else {
          _addQueryParameters(_dio, requestParams);
          return await _dio.delete(path , options: options);
        }
      case METHOD_TYPE.PUT:
        if (isJsonEncode) {
          return await _dio.put(
              path + (id != null && id.isNotEmpty ? '/$id' : ''),
              data: jsonEncode(requestParams), options: options);
        } else {
          _addQueryParameters(_dio, requestParams);
          return await _dio.put(
              path + (id != null && id.isNotEmpty ? '/$id' : ''), options: options);
        }
      case METHOD_TYPE.GET:
        _addQueryParameters(_dio, requestParams);

        if (cachePolicy != null) {

          // Merge cache options with custom headers
          final cacheOptionsWithHeaders = _cacheOptions
              .copyWith(policy: cachePolicy)
              .toOptions();

          if (options?.headers != null) {
            cacheOptionsWithHeaders.headers = {
              ...cacheOptionsWithHeaders.headers ?? {},
              ...options!.headers ?? {}
            };
          }

          return await _dio.get(
              path, options: cacheOptionsWithHeaders);
        }
        else{
          return await _dio.get(
              path,options: options);
        }
      case METHOD_TYPE.PATCH:
        return await _dio.patch(path, data: jsonEncode(requestParams), options: options);
    }
  }

  // Helper method for adding query parameters
  void _addQueryParameters(Dio dio, Map<String, dynamic> params) {
    dio.options.queryParameters = params;
  }
}
