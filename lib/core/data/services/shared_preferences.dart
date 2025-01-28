import 'package:restaurantzz/core/data/model/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final SharedPreferences _preferences;

  SharedPreferencesService(this._preferences);

  static const String keyNotification = "RESTAURANTZZ_NOTIFICATION";
  static const String keyIsDark = "RESTAURANTZZ_DARK_MODE";

  Future<void> saveSettingValue(Setting setting) async {
    try {
      await _preferences.setBool(keyNotification, setting.notificationEnable);
      await _preferences.setBool(keyIsDark, setting.isDark);
    } catch (e) {
      throw Exception("Shared preferences cannot save the setting value.");
    }
  }

  Future<void> setTheme(bool isDark) async {
    try {
      await _preferences.setBool(keyIsDark, isDark);
    } catch (e) {
      throw Exception("Failed setting theme.");
    }
  }

  Setting getSettingValue() {
    return Setting(
      notificationEnable: _preferences.getBool(keyNotification) ?? false,
      isDark: _preferences.getBool(keyIsDark) ?? true,
    );
  }

  bool isDarkModeSet() {
    return _preferences.containsKey(keyIsDark);
  }
}
