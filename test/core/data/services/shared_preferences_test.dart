import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/data/model/setting.dart';
import 'package:restaurantzz/core/data/services/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

// create mock for testing
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late SharedPreferencesService sharedPreferencesService;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    sharedPreferencesService = SharedPreferencesService(mockSharedPreferences);
  });

  group('SharedPreferencesService', () {
    test('saveSettingValue should save the settings', () async {
      final setting = Setting(notificationEnable: true, isDark: false);

      // mock SharedPreferences' setBool methods to return true
      when(() => mockSharedPreferences.setBool(any(), any()))
          .thenAnswer((_) async => true);

      await sharedPreferencesService.saveSettingValue(setting);

      // verify if setBool is called
      verify(() => mockSharedPreferences.setBool(
          SharedPreferencesService.keyNotification, true)).called(1);
      verify(() => mockSharedPreferences.setBool(
          SharedPreferencesService.keyIsDark, false)).called(1);
    });

    test('setTheme should save the dark mode setting', () async {
      when(() => mockSharedPreferences.setBool(any(), any()))
          .thenAnswer((_) async => true);

      await sharedPreferencesService.setTheme(false);

      verify(() => mockSharedPreferences.setBool(
          SharedPreferencesService.keyIsDark, false)).called(1);
    });

    test('getSettingValue should return correct settings', () {
      when(() => mockSharedPreferences
          .getBool(SharedPreferencesService.keyNotification)).thenReturn(true);
      when(() =>
              mockSharedPreferences.getBool(SharedPreferencesService.keyIsDark))
          .thenReturn(false);

      final setting = sharedPreferencesService.getSettingValue();

      expect(setting.notificationEnable, true);
      expect(setting.isDark, false);
    });

    test('isDarkModeSet should return true if key exists', () {
      when(() => mockSharedPreferences
          .containsKey(SharedPreferencesService.keyIsDark)).thenReturn(true);

      final result = sharedPreferencesService.isDarkModeSet();

      expect(result, true);
    });

    test('isDarkModeSet should return false if key does not exist', () {
      when(() => mockSharedPreferences
          .containsKey(SharedPreferencesService.keyIsDark)).thenReturn(false);

      final result = sharedPreferencesService.isDarkModeSet();

      expect(result, false);
    });

    test('saveSettingValue should throw exception when save fails', () async {
      final setting = Setting(notificationEnable: true, isDark: false);

      when(() => mockSharedPreferences.setBool(any(), any())).thenThrow(
          Exception("Shared preferences cannot save the setting value."));

      expect(() => sharedPreferencesService.saveSettingValue(setting),
          throwsA(isA<Exception>()));
    });
  });
}
