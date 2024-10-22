part of retail_core;

class SharedPrefStorageProvider extends LocalStorageService {
  //static AppLocalStorageSharePref? _instance;
  static SharedPreferences? _preferences;

  SharedPrefStorageProvider();

  @override
  Future<T?> getData<T>(String key , StorageProvider provider) async {
    if (provider != StorageProvider.sharedPref){
      return null;
    }
    if (_preferences == null) await _initPreferencesIfNeeded();
    if (T == String) {
      return _preferences!.getString(key) as T?;
    }
    if (T == bool) {
      return _preferences!.getBool(key) as T?;
    }
    if (T == int) {
      return _preferences!.getInt(key) as T?;
    }
    if (T == double) {
      return _preferences!.getDouble(key) as T?;
    }
    if (T == List<String>) {
      return _preferences!.getStringList(key) as T?;
    }
    return null;
  }

  @override
  Future<bool> removeData(String key,StorageProvider provider) async {
    if (provider != StorageProvider.sharedPref) return false;
    if (_preferences == null) await _initPreferencesIfNeeded();
    return _preferences!.remove(key);
  }

  /// save data to shared Prefs this fun will check value and if its String it saves
  /// as String and you can pass any data type whithout any hussel.
  /// except for list
  @override
  Future<bool> saveData(StorageData keyValue) async {
     //This storage is not not secured storage
    if (keyValue.provider != StorageProvider.sharedPref) return false;
    if (_preferences == null) await _initPreferencesIfNeeded();

    if (keyValue.data == null) {
      throw Exception('Metadata cannot be null');
    }
    // Iterate over the entries of the metadata map
    keyValue.data.forEach((key, value) {
      if (value is String) {
        _preferences!.setString(key, value);
      } else if (value is bool) {
        _preferences!.setBool(key, value);
      } else if (value is int) {
        _preferences!.setInt(key, value);
      } else if (value is double) {
        _preferences!.setDouble(key, value);
      } else if (value is List<String>) {
        _preferences!.setStringList(key, value);
      } else {
        throw Exception('Unsupported value type');
      }
    });

    return true;
  }

  @override
  Future<void> init() async {
    _initPreferencesIfNeeded();
  }

  Future<void> _initPreferencesIfNeeded() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  /// so thats all
}
