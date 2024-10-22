part of retail_core;

@Deprecated("Work in Progress")
class SecuredStorageProvider  extends LocalStorageService{
  @override
  Future<T?> getData<T>(String key, StorageProvider provider) {
    if(provider == StorageProvider.encryptedSharedPref) {}
    throw UnimplementedError();

  }
  @override
  Future<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<bool> removeData(String key, StorageProvider provider) {
    if(provider == StorageProvider.encryptedSharedPref) {}
    // TODO: implement removeData
    throw UnimplementedError();
  }

  @override
  Future<bool> saveData(StorageData data) {
    if(data.provider == StorageProvider.encryptedSharedPref) {}
    // TODO: implement saveData
    throw UnimplementedError();
  }


}