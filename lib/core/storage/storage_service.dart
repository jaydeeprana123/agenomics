import 'package:get_storage/get_storage.dart';

import '../constants/storage_keys.dart';

class StorageService {
  StorageService._();

  static final GetStorage _box = GetStorage();

  static Future<void> init() => GetStorage.init();

  static Future<void> write(String key, dynamic value) => _box.write(key, value);

  static T? read<T>(String key) => _box.read<T>(key);

  static Future<void> remove(String key) => _box.remove(key);

  static Future<void> clear() => _box.erase();

  static String? get token => read<String>(StorageKeys.authToken);

  static String? get refreshToken => read<String>(StorageKeys.refreshToken);

  static Future<void> saveToken(String token) =>
      write(StorageKeys.authToken, token);

  static Future<void> saveRefreshToken(String token) =>
      write(StorageKeys.refreshToken, token);

  static Future<void> saveUser(Map<String, dynamic> user) =>
      write(StorageKeys.userInfo, user);

  static Map<String, dynamic>? get user {
    final data = read(StorageKeys.userInfo);
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  static bool get isLoggedIn =>
      read<bool>(StorageKeys.isLoggedIn) == true && token != null;

  static Future<void> setLoggedIn(bool value) =>
      write(StorageKeys.isLoggedIn, value);

  static Future<void> clearAuth() async {
    await remove(StorageKeys.authToken);
    await remove(StorageKeys.refreshToken);
    await remove(StorageKeys.userInfo);
    await setLoggedIn(false);
  }
}
