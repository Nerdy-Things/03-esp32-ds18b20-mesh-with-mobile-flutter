import 'package:shared_preferences/shared_preferences.dart';

class PreferenceRepository {

  Future<void> saveData(PreferenceKey key, String keyPostfix, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key.name + keyPostfix, value);
  }

// Retrieve data from preferences
  Future<String?> loadData(PreferenceKey key, String keyPostfix) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key.name + keyPostfix);
  }
}

enum PreferenceKey {
  deviceId,
}