# Flutter Core Network Package

A powerful network package for Flutter built on top of DIO, designed to streamline API development with features like caching, logging, token authentication, and local data storage management.

## Features

- **DIO Wrapper**: Simplifies HTTP requests and responses.
- **Caching**: Efficiently cache API responses to improve performance and reduce network usage.
- **Logging**: Generate cURL commands for easy debugging and log network requests using `Log.d` and `Log.i`.
- **Token Authentication**: Manage access and refresh tokens seamlessly.
- **Retry Policies**: Automatically retry failed requests based on customizable policies.
- **Base Models**: Utilize abstract base models for request and response handling.
- **Local Storage Management**: Manage app-specific data storage.

## Installation

Add the package to your `pubspec.yaml`:


dependencies:
  network_plus: ^0.0.1

pub.dev
https://pub.dev/packages/network_plus/install

##  Getting Started

### Setup

To use this package, configure dependency injection and initialize the core configuration. Below is an example setup:

```dart

// Setup Core DI
coreDILocator.registerLazySingleton<CoreConfiguration>(() => CoreConfiguration(
  baseUrl: coreDILocator<AppEnvironment>().brandConfig.url.orEmpty(),
  timeout: 120000,
  connectTimeout: 120000,
  cachePolicy: coreDILocator<AppEnvironment>().env == EnvironmentType.prod || 
              coreDILocator<AppEnvironment>().env == EnvironmentType.dev
              ? CachePolicy.request
              : CachePolicy.noCache,
  refreshTokenUrl: authUrl,
  refreshTokenKey: "refresh_token",
  accessTokenKey: "access_token",
  securityContext: _securityContext,
  additionalHeaders: {
    //add headers here
    "locale": "en",
    "unique-reference-code": "GUID",

  },
  storageProviderForToken: StorageProvider.sharedPref,
  loggerConfig: const LoggerConfig(
    shouldShowLogs: kDebugMode,
    logLevel: LogsLevel.trace,
    lineLength: 1000,
  )
));





// Retrieve the CoreConfiguration instance
final core = coreDILocator<CoreConfiguration>();

// Call setup to register network-related dependencies
core.setup();

```

## Creating a Custom Repository


You can extend the BaseRepository class to create your own repository. Here’s an example:

```dart

class MyCustomRepository extends BaseRepository<GlobalMasterConfigData> {
  MyCustomRepository(NetworkExecutor networkExecutor) : super(networkExecutor);

  Future<Result<MyUiModel>> fetchData() async {
    final additionalHeaders = {
      'Authorization': 'Bearer your_token',
    };

    return await execute<MyMapper, GlobalMasterConfigData, MyUiModel>(
      urlPath: '/api/data',
      method: METHOD_TYPE.GET,
      params: EmptyRequest(),
      mapper: MyMapper(),
      responseType: GlobalMasterConfigData(),
      headers: additionalHeaders,
      cachePolicy: CachePolicy.cacheFirst,
      retryPolicy: RetryPolicy(retrialCount: 3, retryDelay: Duration(seconds: 2)),
    );
  }
}

```
## Advanced Features

### API Caching
The package supports caching to enhance performance. You can specify cache behavior when calling the execute method.

### Updating Headers
Customize request headers by passing a map of additional headers in the execute method.

### Retry Policies
Built-in support for retry policies allows you to define how many times to retry a request and the delay between attempts.



### Logging
Configure logging behavior with LoggerConfig, allowing you to track requests and responses easily:

dart
Copy code
loggerConfig: const LoggerConfig(
  shouldShowLogs: kDebugMode,
  logLevel: LogsLevel.trace,
  lineLength: 1000,
)

##### Use Log.d, Log.i, and Log.e to log messages at different levels.


### Local Storage Setup
You can manage local data storage by creating your own AppDataStorage class. Here’s a simple example of how you could implement it:

set this up in ur locator.

```dart

  coreDILocator.registerLazySingleton<LocalStorageService>(() {
    final storageManager = LocalStorageManager();
    storageManager.addService(SharedPrefStorageProvider());
    storageManager.init();
    return storageManager;
  });


  /// Sets up local storage dependency using GetIt.
    coreDILocator.registerLazySingleton<AppDataStorage>(
          () => AppDataStorage(coreDILocator<LocalStorageService>() ,StorageProvider.sharedPref),
    );

Create you class for storege like AppDataStorage.

class AppDataStorage {
  final LocalStorageService localStorage;
  final StorageProvider provider;

  AppDataStorage(this.localStorage, this.provider);



  Future<void> saveMyAppData(String key, dynamic value) async {
    await localStorage.saveData(StorageData({key: value}, provider));
  }

  Future<T?> getValueByKey<T>(String key) async {
    return await localStorage.getData<T>(key, provider);
  }

  Future<void> clearValue(String key) async {
    await localStorage.removeData(key, provider);
  }

 
}

```
Contributing
Contributions are welcome! Please submit a pull request or open an issue if you encounter any problems or have suggestions for improvement.


```yaml
