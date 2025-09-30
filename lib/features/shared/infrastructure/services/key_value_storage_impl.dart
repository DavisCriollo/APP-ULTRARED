import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultrared/features/shared/infrastructure/services/key_value_storage.dart';

class KeyValueStorageImpl implements KeyValueStorage {
  Future<SharedPreferences> getSharedPrefs() async =>
      await SharedPreferences.getInstance();

  @override
  Future<T?> getValue<T>(String key) async {
    final prefs = await getSharedPrefs();
    switch (T) {
      case const (int):
        return prefs.getInt(
          key,
        ) as T?;

      case const (String):
        return prefs.getString(
          key,
        ) as T?;

      default:
        throw UnimplementedError(
            'Get no implemented for type ${T.runtimeType}');
    }
  }

  @override
  Future<bool> removeKey(String key) async {
    final prefs = await getSharedPrefs();
    return await prefs.remove(key);
  }

  @override
  Future<void> setKeyValue<T>(String key, T value) async {
    final prefs = await getSharedPrefs();
    switch (T) {
      case const (int):
        prefs.setInt(key, value as int);
        break;
      case const (String):
        prefs.setString(key, value as String);
        break;
      default:
        throw UnimplementedError(
            'Set no implemented for type ${T.runtimeType}');
    }
  }
}
