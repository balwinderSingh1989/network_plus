# Network Plus - Advance DIO - Network, caching and lot more.

A powerful network package for Flutter built on top of DIO, designed to streamline API development with features like caching, logging, token authentication, and local data storage management.

---

## Features

- **DIO Wrapper**: Simplifies HTTP requests and responses.
- **Caching**: Efficiently cache API responses to improve performance and reduce network usage.
- **Logging**: Generate cURL commands for easy debugging and log network requests using `Log.d` and `Log.i`.
- **Token Authentication**: Manage access and refresh tokens seamlessly.
- **Retry Policies**: Automatically retry failed requests based on customizable policies.
- **Base Models**: Utilize abstract base models for request and response handling.
- **Local Storage Management**: Manage app-specific data storage.
- **Dependency Injection**: Uses GetIt for easy dependency management.
- **Customizable Headers**: Add or update headers for requests.
- **Security Context**: Support for custom security context and allowed hosts.

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  network_plus: ^0.0.2
```

Then run:

```sh
flutter pub get
```

---

## Getting Started

### 1. Setup Dependency Injection

Register and configure the core dependencies using `GetIt`:

```dart
import 'package:retail_core/retail_core.dart';

coreDILocator.registerLazySingleton<CoreConfiguration>(() => CoreConfiguration(
  baseUrl: "https://api.example.com",
  timeout: 120000,
  connectTimeout: 120000,
  cachePolicy: CachePolicy.request,
  refreshTokenUrl: "https://api.example.com/auth/refresh",
  refreshTokenKey: "refresh_token",
  accessTokenKey: "access_token",
  securityContext: null, // Optionally provide SecurityContextConfig
  additionalHeaders: {
    "locale": "en",
    "unique-reference-code": "GUID",
  },
  storageProviderForToken: StorageProvider.sharedPref,
  loggerConfig: const LoggerConfig(
    shouldShowLogs: true,
    logLevel: LogsLevel.trace,
    lineLength: 1000,
  ),
));

// Call setup to register network-related dependencies
coreDILocator<CoreConfiguration>().setup();
```

### 2. Creating a Custom Repository

Extend the `BaseRepository` to create your own repository for API calls:

```dart
class MyCustomRepository extends BaseRepository<MyResponseClass> {
  MyCustomRepository(NetworkExecutor networkExecutor) : super(networkExecutor);

  Future<Result<MyUiModel>> fetchData() async {
    return await execute<MyMapper, MyResponseClass, MyUiModel>(
      urlPath: '/api/data',
      method: METHOD_TYPE.GET,
      params: EmptyRequest(),
      mapper: MyMapper(),
      responseType: MyResponseClass(),
      cachePolicy: CachePolicy.cacheFirst,
      retryPolicy: RetryPolicy(retrialCount: 3, retryDelay: Duration(seconds: 2)),
    );
  }
}
```

### 3. Local Storage Setup

You can manage local data storage by creating your own storage class:

```dart
coreDILocator.registerLazySingleton<LocalStorageService>(() {
  final storageManager = LocalStorageManager();
  storageManager.addService(SharedPrefStorageProvider());
  storageManager.init();
  return storageManager;
});

coreDILocator.registerLazySingleton<AppDataStorage>(
  () => AppDataStorage(coreDILocator<LocalStorageService>(), StorageProvider.sharedPref),
);

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

---

## Usage Example

Below is a real-world example of how to implement a repository using `retail_core` for network operations in a Flutter app. This pattern allows you to easily manage API calls, handle mock data, and map responses to your domain models.

```dart
import 'package:retail_core/retail_core.dart';
import 'package:mns_retail_app/data/repositories/checkout/request/billing/update_billing_address_request.dart';
import 'package:mns_retail_app/domain/entity/checkout/checkout_model.dart';
import 'package:mns_retail_app/domain/repositories/checkout/checkout_mapper.dart';

class CheckoutRepositoryImpl extends BaseRepository<CheckoutResponse> {
  final checkoutMapper = coreDILocator<CheckoutMapper>();

  CheckoutRepositoryImpl(NetworkExecutor networkExecutor) : super(networkExecutor);

  // Fetch checkout details
  Future<Result<CheckoutModel>> fetchCheckout(String cartId) async {
    return await execute(
      urlPath: "checkout/guest/v1/orders?cartId=$cartId",
      method: METHOD_TYPE.POST,
      params: EmptyRequest(),
      mapper: checkoutMapper,
      responseType: CheckoutResponse(),
    );
  }

  // Update billing address
  Future<Result<CheckoutModel>> updateBillingAddress(String orderId, UpdateCheckoutAddressModel updateBillingAddressModel) async {
    return await execute(
      urlPath: "checkout/guest/v1/orders/$orderId/billinginfo",
      method: METHOD_TYPE.PUT,
      params: UpdateAddressRequest(addAddressModel: updateBillingAddressModel),
      isJsonEncode: true,
      mapper: checkoutMapper,
      responseType: CheckoutResponse(),
    );
  }
}
```

### Using the Repository

```dart
final checkoutRepo = CheckoutRepositoryImpl(coreDILocator<NetworkExecutor>());

// Fetch checkout
final result = await checkoutRepo.fetchCheckout('your-cart-id');
result.when(
  success: (data) => print('Checkout data: $data'),
  error: (error) => print('Error: $error'),
);

// Update billing address
final updateResult = await checkoutRepo.updateBillingAddress('order-id', yourUpdateModel);
updateResult.when(
  success: (data) => print('Updated checkout: $data'),
  error: (error) => print('Update error: $error'),
);
```

This approach leverages `retail_core`'s `execute` method for all network operations, ensuring consistent error handling, response mapping, and support for features like caching and retry policies.

---

## Understanding Mappers

**Mappers** are responsible for converting raw API response data (usually JSON) into your app’s domain models. This separation ensures that your UI and business logic work with clean, predictable data structures, regardless of how the backend formats its responses.

A typical mapper implements a method like `mapFrom`, which takes a response object and returns a domain model:

```dart
class CheckoutMapper {
  CheckoutModel mapFrom(CheckoutResponse response) {
    // Convert API response to domain model
    return CheckoutModel(
      id: response.id,
      items: response.items.map((item) => ItemModel.fromJson(item)).toList(),
      // ...other fields
    );
  }
}
```

When using `retail_core`, you pass your mapper to the `execute` method. The package will automatically use it to transform the API response before returning it to your repository or UI layer.

---

## Understanding Result

The **Result** class is a wrapper that represents the outcome of an operation—either a success with data, or a failure with an error. This pattern makes error handling explicit and consistent throughout your codebase.

A typical `Result` usage looks like this:

```dart
final result = await checkoutRepo.fetchCheckout('cart-id');

result.when(
  success: (data) {
    // Handle the successful data
    print('Checkout: $data');
  },
  error: (error) {
    // Handle the error
    print('Error: $error');
  },
);
```

This approach avoids exceptions bubbling up and makes it easy to handle both success and failure cases in a unified way.

---

**Summary:**  
- **Mappers** convert API responses to your app’s models.
- **Result** wraps the outcome of operations, making error handling simple and robust.

For more details, see the example repository and usage patterns above.

---

## Advanced Features

- **API Caching**: Specify cache behavior with `CachePolicy` when calling `execute`.
- **Updating Headers**: Customize request headers via `additionalHeaders` or directly on the `Dio` instance.
- **Retry Policies**: Use `RetryPolicy` to define retry logic for requests.
- **Logging**: Configure logging with `LoggerConfig` and use `Log.d`, `Log.i`, `Log.e` for messages.
- **Security Context**: Restrict allowed hosts and provide custom security context for requests.

---

## Contributing

Contributions are welcome! Please submit a pull request or open an issue if you encounter any problems or have suggestions for improvement.

---

## License

[MIT](LICENSE)
