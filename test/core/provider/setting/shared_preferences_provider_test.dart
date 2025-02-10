import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/data/model/setting.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';

import '../../../testutils/mock.dart';

class FakeSetting extends Fake implements Setting {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSetting());
  });

  group('SharedPreferencesProvider', () {
    late SharedPreferencesProvider sharedPreferencesProvider;
    late MockSharedPreferencesService mockService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockService = MockSharedPreferencesService();
      sharedPreferencesProvider = SharedPreferencesProvider(mockService);
    });

    tearDown(() {
      sharedPreferencesProvider.dispose();
      reset(mockService);
    });

    test(
        'initializeSettings_validSavedSetting_shouldLoadSettingAndNotifyListeners',
        () {
      final savedSetting = Setting(notificationEnable: true, isDark: false);
      when(mockService.getSettingValue).thenReturn(savedSetting);
      when(() => mockService.isDarkModeSet()).thenReturn(true);

      bool listenerCalled = false;
      sharedPreferencesProvider.addListener(() => listenerCalled = true);

      sharedPreferencesProvider.getSettingValue();

      expect(sharedPreferencesProvider.setting, savedSetting);
      expect(listenerCalled, isTrue);
      expect(sharedPreferencesProvider.message, "Data successfully retrieved");
    });

    test('initializeSettings_noSavedSetting_shouldUseSystemTheme', () {
      TestWidgetsFlutterBinding.ensureInitialized();

      when(() => mockService.getSettingValue()).thenReturn(
        Setting(notificationEnable: false, isDark: true),
      );
      when(() => mockService.isDarkModeSet()).thenReturn(false);

      TestWidgetsFlutterBinding.instance.platformDispatcher
          .platformBrightnessTestValue = Brightness.light;

      // create provider after set the brightness
      sharedPreferencesProvider = SharedPreferencesProvider(mockService);

      expect(sharedPreferencesProvider.setting?.isDark, isFalse);
    });

    test('saveSettingValue_validData_shouldSaveSettingAndUpdateMessage',
        () async {
      final setting = Setting(notificationEnable: true, isDark: false);
      when(() => mockService.saveSettingValue(any()))
          .thenAnswer((_) async => true);

      await sharedPreferencesProvider.saveSettingValue(setting);

      expect(sharedPreferencesProvider.setting, setting);
      expect(sharedPreferencesProvider.message, "Your data is saved");
    });

    test('saveSettingValue_error_shouldShowErrorMessage', () async {
      final setting = Setting(notificationEnable: false, isDark: true);
      when(() => mockService.saveSettingValue(any())).thenThrow(Exception());

      await sharedPreferencesProvider.saveSettingValue(setting);

      expect(sharedPreferencesProvider.message, "Failed to save your data");
    });

    test('setTheme_validDarkMode_shouldSaveThemeAndUpdateMessage', () async {
      final setting = Setting(notificationEnable: true, isDark: false);
      when(() => mockService.setTheme(true)).thenAnswer((_) async => true);
      when(() => mockService.saveSettingValue(any()))
          .thenAnswer((_) async => true);
      when(() => mockService.getSettingValue())
          .thenReturn(Setting(notificationEnable: false, isDark: false));

      // init save setting
      await sharedPreferencesProvider.saveSettingValue(setting);

      await sharedPreferencesProvider.setTheme(true);

      expect(sharedPreferencesProvider.setting?.isDark, isTrue);
      expect(sharedPreferencesProvider.message, "Theme successfully updated.");
    });

    test('setTheme_error_shouldShowErrorMessage', () async {
      when(() => mockService.setTheme(any())).thenThrow(Exception());

      await sharedPreferencesProvider.setTheme(false);

      expect(sharedPreferencesProvider.message,
          "Failed to update theme. Please try again.");
    });

    test('getSettingValue_validData_shouldRetrieveSettingAndUpdateMessage', () {
      final savedSetting = Setting(notificationEnable: true, isDark: true);
      when(() => mockService.getSettingValue()).thenReturn(savedSetting);

      sharedPreferencesProvider.getSettingValue();

      expect(sharedPreferencesProvider.setting, savedSetting);
      expect(sharedPreferencesProvider.message, "Data successfully retrieved");
    });

    test('getSettingValue_error_shouldShowErrorMessage', () {
      when(() => mockService.getSettingValue()).thenThrow(Exception());

      sharedPreferencesProvider.getSettingValue();

      expect(sharedPreferencesProvider.message, "Failed to get your data");
    });
  });
}
