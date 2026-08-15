import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/model/setting.dart';
import 'package:restaurantzz/core/data/services/workmanager_service.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';
import 'package:restaurantzz/feature/settings/widgets/notification_widget.dart';

import '../../../testutils/mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(Setting(isDark: true, notificationEnable: false));
  });

  group('DebugNotification', () {
    late MockWorkmanagerService mockWorkmanagerService;
    late MockSharedPreferencesProvider mocSharedPreferencesProvider;

    final mockAppConfig = MockAppConfig();

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              Provider<WorkmanagerService>.value(value: mockWorkmanagerService),
              ChangeNotifierProvider<SharedPreferencesProvider>.value(
                value: mocSharedPreferencesProvider,
              ),
            ],
            child: NotificationWidget(appConfig: mockAppConfig),
          ),
        ),
      );
    }

    setUp(() {
      mockWorkmanagerService = MockWorkmanagerService();
      mocSharedPreferencesProvider = MockSharedPreferencesProvider();

      when(() => mockWorkmanagerService.runPeriodicTask()).thenAnswer((_) async {});
      when(() => mockWorkmanagerService.cancelAllTask()).thenAnswer((_) async {});
      when(() => mocSharedPreferencesProvider.saveSettingValue(any())).thenAnswer((_) async {});
      when(
        () => mocSharedPreferencesProvider.setting,
      ).thenReturn(Setting(isDark: true, notificationEnable: false));

      when(() => mockAppConfig.showNotificationView(any())).thenReturn(true);
    });

    testWidgets('enabling notification starts periodic task', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final switchFinder = find.byKey(const Key('notification_switch'));

      await tester.tap(switchFinder);
      await tester.pump();

      verify(() => mockWorkmanagerService.runPeriodicTask()).called(1);
    });

    testWidgets('disabling notification cancels task', (WidgetTester tester) async {
      when(
        () => mocSharedPreferencesProvider.setting,
      ).thenReturn(Setting(isDark: true, notificationEnable: true));

      await tester.pumpWidget(createWidgetUnderTest());

      final switchFinder = find.byKey(const Key('notification_switch'));

      await tester.tap(switchFinder);
      await tester.pump();

      verify(() => mockWorkmanagerService.cancelAllTask()).called(1);
    });

    testWidgets('shows error dialog when enabling notification fails', (WidgetTester tester) async {
      when(
        () => mockWorkmanagerService.runPeriodicTask(),
      ).thenThrow(Exception('Failed to start WorkManager'));

      await tester.pumpWidget(createWidgetUnderTest());

      final switchFinder = find.byKey(const Key('notification_switch'));

      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(Strings.errorOccured), findsOneWidget);
      expect(find.text(Strings.errorNotification), findsOneWidget);
      expect(find.text(Strings.ok), findsOneWidget);
    });

    testWidgets('platform is website shows nothing', (WidgetTester tester) async {
      when(() => mockAppConfig.showNotificationView(any())).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byKey(const Key('notification_switch')), findsNothing);
      expect(find.byIcon(Icons.notifications_active_rounded), findsNothing);
      expect(find.text(Strings.enableNotification), findsNothing);
    });
  });
}
