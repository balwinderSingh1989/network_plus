import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';

enum CacheStorage { MemCache, Hive }

class CacheStorageConfig {
  final String? hiveDirectory;
  //TODO add MemCachce configs
  CacheStorageConfig({this.hiveDirectory});
}

class HttpCacheStorage {
  final CacheStorage storage;
  final CacheStorageConfig? config;

  HttpCacheStorage(this.storage, this.config);

  CacheStore? getResponseCacheStorage() {
    if (storage == CacheStorage.MemCache) {
      return MemCacheStore();
    } else if (storage == CacheStorage.Hive) {
      if (config != null && config!.hiveDirectory != null) {
        return HiveCacheStore(config?.hiveDirectory!);
      } else {
        throw ArgumentError(
            "Hive directory path is required for Hive cache storage.");
      }
    } else {
      throw ArgumentError("Unsupported cache storage type: ${storage}");
    }
  }
}

class CacheOption {
  /// Handles behaviour to request backend.
  final CachePolicy policy;
  /// Overrides any HTTP directive to delete entry past this duration.
  ///
  /// Giving this value to a later request will update the previously
  /// cached response with this directive.
  ///
  /// This allows to postpone the deletion.
  final Duration? maxStale;
  /// The priority of a cached value.
  /// Ease the clean up if needed.
  final CachePriority priority;
  /// Optional method to decrypt/encrypt cache content
  final CacheCipher? cipher;
  const CacheOption({
    this.policy = CachePolicy.request,
    this.maxStale,
    this.priority = CachePriority.normal,
    this.cipher,
  });
}
