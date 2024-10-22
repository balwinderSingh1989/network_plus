part of network_plus;

// Global instance of GetIt for dependency injection
final coreDILocator = GetIt.instance;

/// Class responsible for configuring core functionalities of the application.
class CoreConfiguration {
  final String baseUrl; // Base URL for API requests
  final Map<String, String> additionalHeaders; // Additional headers for API requests
  final int timeout; // Timeout duration for API requests
  final int connectTimeout; // Connection timeout duration for API requests
  final String? refreshTokenUrl; // URL for refreshing access tokens
  final String refreshTokenKey; // Key for the refresh token in the token storage
  final String accessTokenKey; // Key for the access token in the token storage
  final StorageProvider storageProviderForToken; // Key for the storage provider
  final HttpCacheStorage? cacheStorage;
  final CachePolicy? cachePolicy;
  final LoggerConfig? loggerConfig;
  final SecurityContext? securityContext;

  /// Constructor for CoreConfiguration.
  CoreConfiguration({
    required this.baseUrl,
    this.storageProviderForToken = StorageProvider.sharedPref,
    this.refreshTokenKey = "refresh_token",
    this.cachePolicy,
    this.accessTokenKey = "access_token",
    this.refreshTokenUrl,
    HttpCacheStorage? cacheStorage, // Make cacheStorage nullable
    this.additionalHeaders = const {}, // Default empty map for additional headers
    this.timeout = 10000, // Default timeout of 10 seconds
    this.connectTimeout = 6000, // Default connect timeout of 6 seconds
    this.loggerConfig, // logger configuration
    this.securityContext, // logger configuration
  }) : this.cacheStorage = cacheStorage ?? HttpCacheStorage(CacheStorage.MemCache,null);

  /// Method to perform setup for core functionalities.
  void setup() {
    // Register network-related dependencies
    coreDILocator.registerLazySingleton<CacheOptions>(() => _cacheOptionDefault(cacheStorage));
    coreDILocator.registerLazySingleton<Dio>(() => _getDioClient());
    coreDILocator.registerLazySingleton<ApiClient>(() => ApiClient(coreDILocator<Dio>() , coreDILocator<CacheOptions>() ));
    coreDILocator.registerLazySingleton<NetworkExecutor>(
            () => NetworkExecutor(coreDILocator<ApiClient>()));
    Log.init(loggerConfig ??
        const LoggerConfig()); // Pass default logger configs if it's null
  }

  Map<String, dynamic> get headers
  {
    return  coreDILocator<Dio>().options.headers;
  }

  /// Configures and returns an instance of Dio HTTP client.
  Dio _getDioClient() {
    Dio _client = Dio();
    _client.options.baseUrl = baseUrl;
    _client.options.sendTimeout = Duration(milliseconds: timeout);
    _client.options.receiveTimeout =Duration(milliseconds:  timeout);
    _client.options.connectTimeout = Duration(milliseconds: timeout );
    _client.options.headers['content-Type'] = 'application/json';
    _client.options.headers.addAll(additionalHeaders);
    /// Override idealTiemout of socket connection to 15 to resusus existing socket connection to
    /// improve APi response time.
    /// TBD : Check below for more details
    /// https://stackoverflow.com/questions/75731811/reducing-connection-wait-time-for-apis-in-flutter
    /// https://stackoverflow.com/questions/69136187/why-my-flutter-http-network-calls-are-slow/69268170#69268170
    // _client.httpClientAdapter = Http2Adapter(ConnectionManager(idleTimeout:  Duration(seconds:  15)));
    (_client.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () =>
    HttpClient(context: securityContext)
      ..idleTimeout = Duration(seconds: 15)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    //Token storage is required for authenticator interceptor
    _setupTokenStorage();

    // Register interceptors for authentication, error handling, and logging
    //DO NOT change the order of interceptors as they work in FIFO
    _client.interceptors.addAll({
      AuthTokenInterceptor(
        _client,
        refreshTokenKey,
        accessTokenKey,
        refreshTokenUrl.orEmpty(), // Empty string if refreshTokenUrl is null
        coreDILocator<TokenStorage>(),
      ),
      DioCacheInterceptor(options: _cacheOptionDefault(cacheStorage)),
      ErrorInterceptors(_client),
      LogInterceptor(),
    });

    return _client;
  }



  CacheOptions _cacheOptionDefault(HttpCacheStorage? cacheStorage) {


   return CacheOptions(
      // A default store is required for interceptor.
      /// TBD change with Hive
      store: cacheStorage?.getResponseCacheStorage(),

      // All subsequent fields are optional.
      // Default.
      policy: cachePolicy ?? CachePolicy.request,
      // Returns a cached response on error but for statuses 401 & 403.
      // Also allows to return a cached response on network errors (e.g. offline usage).
      // Defaults to [null].
      hitCacheOnErrorExcept: [401, 403],
      // Overrides any HTTP directive to delete entry past this duration.
      // Useful only when origin server has no cache config or custom behaviour is desired.
      // Defaults to [null].
      maxStale: const Duration(days: 7),
      // Default. Allows 3 cache sets and ease cleanup.
      priority: CachePriority.normal,
      // Default. Body and headers encryption with your own algorithm.
      cipher: null,
      // Default. Key builder to retrieve requests.
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      // Default. Allows to cache POST requests.
      // Overriding [keyBuilder] is strongly recommended when [true].
      allowPostMethod: false,
    );
  }



  /// Sets up token storage dependency using GetIt.
  void _setupTokenStorage() {
    coreDILocator.registerLazySingleton<TokenStorage>(
          () => TokenStorage(coreDILocator<LocalStorageService>() ,storageProviderForToken),
    );
  }
}

