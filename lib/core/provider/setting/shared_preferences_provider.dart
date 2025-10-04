import 'package:flutter/widgets.dart';
import 'package:restaurantzz/core/data/model/setting.dart';
import 'package:restaurantzz/core/data/services/shared_preferences.dart';

class SharedPreferencesProvider extends ChangeNotifier {
  final SharedPreferencesService _service;

  String _message = "";
  String get message => _message;

  Setting? _setting;
  Setting? get setting => _setting;

  SharedPreferencesProvider(this._service) {
    _initializeSettings();
  }

  void _initializeSettings() {
    try {
      final savedSetting = _service.getSettingValue();

      final isDarkSystem =
          WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
      _setting = Setting(
        notificationEnable: savedSetting.notificationEnable,
        isDark: _service.isDarkModeSet() ? savedSetting.isDark : isDarkSystem,
      );
      _message = "Settings initialized successfully";
    } catch (e) {
      _message = "Failed to initialize settings";
    }
    notifyListeners();
  }

  Future<void> saveSettingValue(Setting value) async {
    try {
      await _service.saveSettingValue(value);
      _setting = value;
      _message = "Your data is saved";
    } catch (e) {
      _message = "Failed to save your data";
    }
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    try {
      await _service.setTheme(isDark);
      _setting = Setting(notificationEnable: _setting!.notificationEnable, isDark: isDark);
      _message = "Theme successfully updated.";
    } catch (e) {
      _message = "Failed to update theme. Please try again.";
    }
    notifyListeners();
  }

  void getSettingValue() {
    try {
      _setting = _service.getSettingValue();
      _message = "Data successfully retrieved";
    } catch (e) {
      _message = "Failed to get your data";
    }
    notifyListeners();
  }
}
