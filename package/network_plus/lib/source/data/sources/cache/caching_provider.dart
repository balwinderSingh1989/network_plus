import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';

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
    if (storage == null || storage == CacheStorage.MemCache) {
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
