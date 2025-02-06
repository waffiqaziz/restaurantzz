import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/data/model/setting.dart';
import 'package:restaurantzz/core/provider/notification/local_notification_provider.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';
import 'package:restaurantzz/feature/settings/screen/settings_screen.dart';

class MockSharedPreferencesProvider extends Mock
    implements SharedPreferencesProvider {}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockLocalNotificationProvider extends Mock
    implements LocalNotificationProvider {}

void main() {
  late MockSharedPreferencesProvider mockProvider;

  setUp(() {
    mockProvider = MockSharedPreferencesProvider();

    when(() => mockProvider.setting)
        .thenReturn(Setting(notificationEnable: true, isDark: false));
    when(() => mockProvider.message)
        .thenReturn("Settings initialized successfully");
  });


  testWidgets('SettingsScreen displays theme switch button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SharedPreferencesProvider>.value(
          value: mockProvider,
          child: SettingsScreen(),
        ),
      ),
    );

    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('Toggling dark mode switch calls setTheme',
      (WidgetTester tester) async {
    when(() => mockProvider.setting)
        .thenReturn(Setting(notificationEnable: true, isDark: false));
    when(() => mockProvider.setTheme(any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<SharedPreferencesProvider>.value(
          value: mockProvider,
          child: SettingsScreen(),
        ),
      ),
    );

    final switchWidget = find.byType(Switch).last;

    // trigger switch
    await tester.tap(switchWidget);
    await tester.pump();

    // verify setTheme is called with the correct value
    verify(() => mockProvider.setTheme(true)).called(1);
  });
}
