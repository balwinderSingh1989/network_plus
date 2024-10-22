part of network_plus;


class LocalStorageManager implements LocalStorageService {

  final List<LocalStorageService> _services = [];

  @override
  Future<void> init() async{
    _services.forEach((service) => service.init());
  }


  @override
  Future<T?> getData<T>(String key, StorageProvider provider) async {
    List<Future<T?>> futures = _services.map((service) => service.getData<T>(key, provider)).toList();
    // Use Future.wait to wait for all service operations to complete
    List<T?> results = await Future.wait(futures);
    // Find and return the first non-null result, or return null if all results are null
    for (T? result in results) {
      if (result != null) {
        return result;
      }
    }
    // Return null if no non-null result was found
    return null;
  }

  @override
  Future<bool> removeData(String key ,StorageProvider provider) async{
    // Use Future.wait to wait for all service operations to complete
    await Future.wait(_services.map((service) => service.removeData(key, provider)));
    // Return true if all removal operations were successful
    return true;

  }

  @override
  Future<bool> saveData(StorageData data) async{
    // Use Future.wait to wait for all service operations to complete
    await Future.wait(_services.map((service) => service.saveData(data)));

    // Return true if all save operations were successful
    return true;
  }

  void addService(LocalStorageService service) {
    _services.add(service);
  }


}