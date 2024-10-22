part of network_plus;

class TokenStorage {
  final LocalStorageService localStorage;
  final StorageProvider provider;

  TokenStorage(this.localStorage, this.provider);

  static const String _kUserTokenKey = "user_token_key";
  static const String _KRefreshToken = "refresh_token_key";

  Future<void> setUserToken(String token) async {
    await localStorage.saveData(StorageData({_kUserTokenKey : token }, provider));
  }

  Future<void> setRefreshToken(String token) async {
    await localStorage.saveData(StorageData({_KRefreshToken : token }, provider));
  }

  Future<String?> getUserToken() async {
    return await localStorage.getData<String>(_kUserTokenKey, provider);
  }

  Future<String?> getRefreshToken() async {
    return await localStorage.getData<String>(_KRefreshToken,provider);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      localStorage.removeData(_KRefreshToken,provider),
      localStorage.removeData(_kUserTokenKey,provider)
    ]);
  }

}
