part of network_plus;

abstract class LocalStorageService {
  Future<void> init();
  Future<bool> saveData(StorageData data);
  Future<T?> getData<T>(String key , StorageProvider provider);
  Future<bool> removeData(String key , StorageProvider provider);
}
