import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/model/setting.dart';
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:restaurantzz/core/data/services/workmanager_service.dart';
import 'package:restaurantzz/core/provider/notification/local_notification_provider.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';
import 'package:restaurantzz/feature/settings/screen/settings_screen.dart';

import '../../../testutils/mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(FakeSetting()); // Register the fallback
  });

  group('SettingScreen', () {
    late MockSharedPreferencesProvider mockSharedPreferencesProvider;
    late MockWorkmanagerService mockWorkmanagerService;
    late MockLocalNotificationService mockLocalNotificationService;
    late MockLocalNotificationProvider mockLocalNotificationProvider;

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<SharedPreferencesProvider>.value(
              value: mockSharedPreferencesProvider,
            ),
            Provider<WorkmanagerService>.value(value: mockWorkmanagerService),
            Provider<LocalNotificationService>.value(value: mockLocalNotificationService),
            ChangeNotifierProvider<LocalNotificationProvider>.value(
              value: mockLocalNotificationProvider,
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
    }

    setUp(() {
      mockSharedPreferencesProvider = MockSharedPreferencesProvider();
      mockWorkmanagerService = MockWorkmanagerService();
      mockLocalNotificationService = MockLocalNotificationService();
      mockLocalNotificationProvider = MockLocalNotificationProvider();

      when(
        () => mockSharedPreferencesProvider.setting,
      ).thenReturn(Setting(notificationEnable: true, isDark: false));
      when(
        () => mockSharedPreferencesProvider.message,
      ).thenReturn("Settings initialized successfully");

      when(() => mockLocalNotificationService.init()).thenAnswer((_) async {});
      when(() => mockLocalNotificationService.configureLocalTimeZone()).thenAnswer((_) async {});
      when(() => mockLocalNotificationProvider.requestPermissions()).thenAnswer((_) async {});
    });

    // TODO: Not yet tested for web platform
    // testWidgets('uiElement_shouldDisplayedCorrecltyOnWebPlatform',
    //     (WidgetTester tester) async {
    //   await tester.pumpWidget(createWidgetUnderTest());

    //   // assume this was switch for toggle dark mode
    //   expect(find.byType(Switch), findsOneWidget);
    //   expect(find.text(Strings.settings), findsOneWidget);
    //   expect(find.text(Strings.darkMode), findsOneWidget);
    //   expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    // });

    testWidgets(
      'uiElement_shouldDisplayedOnAndroidPlatform',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // check if there two switch (dark mode and notification switch)
        expect(find.byType(Switch), findsAtLeastNWidgets(2));
        expect(find.text(Strings.settings), findsOneWidget);
        expect(find.text(Strings.darkMode), findsOneWidget);
        expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
        expect(find.text(Strings.enableNotification), findsOneWidget);
        expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );

    testWidgets(
      'uiElement_shouldDisplayedOnIosPlatform',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // check if there two switches (dark mode and notification switch)
        expect(find.byType(Switch), findsAtLeastNWidgets(2));
        expect(find.text(Strings.settings), findsOneWidget);
        expect(find.text(Strings.darkMode), findsOneWidget);
        expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
        expect(find.text(Strings.enableNotification), findsOneWidget);
        expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );

    testWidgets('notificationSwitch_shouldToggleValue', (WidgetTester tester) async {
      when(
        () => mockSharedPreferencesProvider.setting,
      ).thenReturn(Setting(notificationEnable: false, isDark: false));

      await tester.pumpWidget(createWidgetUnderTest());

      final switchFinder = find
          .byWidgetPredicate((widget) => widget is Switch && widget.value == false)
          .first;

      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // verify provider was called to save the updated value
      verify(
        () => mockSharedPreferencesProvider.saveSettingValue(
          any(that: isA<Setting>().having((s) => s.notificationEnable, 'notificationEnable', true)),
        ),
      ).called(1);
    });

    testWidgets('pressDarkModeSwitch_shouldCallsSetThemeFunction', (WidgetTester tester) async {
      when(
        () => mockSharedPreferencesProvider.setting,
      ).thenReturn(Setting(notificationEnable: true, isDark: false));
      when(() => mockSharedPreferencesProvider.setTheme(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      final switchWidget = find.byType(Switch).last;
      await tester.tap(switchWidget);
      await tester.pump();

      verify(() => mockSharedPreferencesProvider.setTheme(true)).called(1);
    });

    testWidgets('pressRequestPermissionButton_shouldCallRequestPermissions', (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      when(() => mockLocalNotificationProvider.permission).thenAnswer((_) => true);
      when(() => mockLocalNotificationProvider.requestPermissions()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      final button = find.byType(ElevatedButton).first;
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pump();

      verify(() => mockLocalNotificationProvider.requestPermissions()).called(1);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('turnOnNotificationSwitch_shouldShowErrorDialog_onException', (
      WidgetTester tester,
    ) async {
      when(
        () => mockSharedPreferencesProvider.saveSettingValue(any()),
      ).thenThrow(Exception("Simulated error"));

      await tester.pumpWidget(createWidgetUnderTest());

      final switchWidget = find.byType(Switch).first;
      expect(switchWidget, findsOneWidget, reason: "Switch not found!");

      await tester.runAsync(() async {
        await tester.tap(switchWidget);
      });
      await tester.pumpAndSettle();

      // expect the alrert dialog show with correct title
      expect(
        find.descendant(of: find.byType(AlertDialog), matching: find.text(Strings.errorOccured)),
        findsOneWidget,
      );
      expect(find.text(Strings.errorNotification), findsOneWidget);
      expect(find.text(Strings.ok), findsOneWidget);

      await tester.tap(find.text(Strings.ok));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    // TODO: Not yet tested for schedule notification
    testWidgets('pressTestShowNotification_shouldCallsCorrectFunction', (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final fakePending = <PendingNotificationRequest>[
        PendingNotificationRequest(1, 'Test', 'Test Body', null),
      ];

      when(
        () => mockSharedPreferencesProvider.setting,
      ).thenReturn(Setting(notificationEnable: false, isDark: false));
      when(() => mockLocalNotificationProvider.showNotification()).thenAnswer((_) async {});
      when(() => mockLocalNotificationProvider.scheduleTestNotification()).thenAnswer((_) async {});
      when(() => mockLocalNotificationProvider.pendingNotificationRequests).thenReturn(fakePending);
      when(
        () => mockLocalNotificationProvider.checkPendingNotificationRequests(),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final buttonFinder = find.text('Test Notification Immediately');
      await tester.tap(buttonFinder);
      await tester.pump();

      verify(() => mockLocalNotificationProvider.showNotification()).called(1);
      debugDefaultTargetPlatformOverride = null;

      final buttonFinder2 = find.text('Test Notification Two Minues');
      await tester.tap(buttonFinder2);
      await tester.pump();

      verify(() => mockLocalNotificationProvider.scheduleTestNotification()).called(1);
      debugDefaultTargetPlatformOverride = null;

      final pendingButton = find.text('Check Pending Notifications');
      await tester.tap(pendingButton);
      await tester.pump();

      verify(() => mockLocalNotificationProvider.checkPendingNotificationRequests()).called(1);
      debugDefaultTargetPlatformOverride = null;
    });

    // TODO: failed test
    // testWidgets('turnOffNotificationSwitch_shouldCancelAllTasks', (WidgetTester tester) async {
    //   when(() => mockWorkmanagerService.cancelAllTask()).thenAnswer((_) async {});
    //   when(
    //     () => mockLocalNotificationProvider.scheduleDailyElevenAMNotification(),
    //   ).thenAnswer((_) async {});

    //   tester.view.physicalSize = const Size(2000, 1920);
    //   tester.view.devicePixelRatio = 1.0;

    //   addTearDown(() {
    //     tester.view.resetPhysicalSize();
    //     tester.view.resetDevicePixelRatio();
    //   });

    //   await tester.pumpWidget(createWidgetUnderTest());
    //   await tester.pumpAndSettle();

    //   if (defaultTargetPlatform == TargetPlatform.android) {
    //     final switchWidget = find.byKey(const Key('notification_switch'));
    //     await tester.tap(switchWidget);
    //     await tester.pumpAndSettle();

    //     await tester.tap(switchWidget);
    //     await tester.pumpAndSettle();

    //     verify(() => mockLocalNotificationProvider.scheduleDailyElevenAMNotification()).called(1);
    //   }
    // });
  });
}
