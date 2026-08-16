import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:restaurantzz/core/data/services/workmanager_service.dart';
import 'package:restaurantzz/core/provider/notification/local_notification_provider.dart';
import 'package:restaurantzz/feature/settings/widgets/debug_notification_widget.dart';

import '../../../testutils/mock.dart';
import '../../../testutils/test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
  });

  group('DebugNotification', () {
    late MockWorkmanagerService mockWorkmanagerService;
    late MockLocalNotificationService mockLocalNotificationService;
    late MockLocalNotificationProvider mockLocalNotificationProvider;
    final mockAppConfig = MockAppConfig();

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: MultiProvider(
            providers: [
              Provider<WorkmanagerService>.value(value: mockWorkmanagerService),
              Provider<LocalNotificationService>.value(value: mockLocalNotificationService),
              ChangeNotifierProvider<LocalNotificationProvider>.value(
                value: mockLocalNotificationProvider,
              ),
            ],
            child: DebugNotification(appConfig: mockAppConfig),
          ),
        ),
      );
    }

    setUp(() {
      mockWorkmanagerService = MockWorkmanagerService();
      mockLocalNotificationService = MockLocalNotificationService();
      mockLocalNotificationProvider = MockLocalNotificationProvider();

      when(() => mockWorkmanagerService.runOneTask()).thenAnswer((_) async {});
      when(() => mockLocalNotificationService.init()).thenAnswer((_) async {});
      when(() => mockLocalNotificationService.requestPermissions()).thenAnswer((_) async {
        return true;
      });
      when(() => mockLocalNotificationService.configureLocalTimeZone()).thenAnswer((_) async {});
      when(
        () => mockLocalNotificationProvider.checkPendingNotificationRequests(),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalNotificationProvider.pendingNotificationRequests,
      ).thenReturn(<PendingNotificationRequest>[]);
      when(() => mockLocalNotificationProvider.requestPermissions()).thenAnswer((_) async {});
      when(() => mockLocalNotificationProvider.cancelAllNotification()).thenAnswer((_) async {});
      when(
        () => mockLocalNotificationProvider.checkPendingNotificationRequests(),
      ).thenAnswer((_) async {});
      when(() => mockAppConfig.showNotificationView(any())).thenReturn(true);
    });

    testWidgets('request permission calls requestPermissions', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final button = findWidgetByText('Request permission!');
      await tester.tap(button);
      await tester.pump();

      verify(() => mockLocalNotificationProvider.requestPermissions()).called(1);
    });

    testWidgets('test notification now calls showNotification', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final button = findWidgetByText(Strings.testNotificationNow);
      await tester.tap(button);
      await tester.pump();

      verify(() => mockLocalNotificationProvider.showNotification()).called(1);
    });

    testWidgets('test notification two minutes calls scheduleTestNotification', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final button = findWidgetByText(Strings.testNotificationTwoMinutes);
      await tester.tap(button);
      await tester.pump();

      verify(() => mockLocalNotificationProvider.scheduleTestNotification()).called(1);
    });

    testWidgets('test notification at eleven calls scheduleDailyElevenAMNotification', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final button = findWidgetByText(Strings.testNotificationAtEleven);
      await tester.tap(button);
      await tester.pump();

      verify(() => mockLocalNotificationProvider.scheduleDailyElevenAMNotification()).called(1);
    });

    testWidgets('cancel all notification calls cancelAllNotification', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final button = findWidgetByText(Strings.cancelAllNotification);
      await tester.tap(button);
      await tester.pump();

      verify(() => mockLocalNotificationProvider.cancelAllNotification()).called(1);
    });

    testWidgets('check pending notifications calls pendingNotificationRequests', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final button = findWidgetByText(Strings.checkPendingNotifications);
      await tester.tap(button);
      await tester.pump();

      verify(() => mockLocalNotificationProvider.pendingNotificationRequests).called(1);
    });

    testWidgets('test five second task calls runOneTask', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final button = findWidgetByText(Strings.testFiveSecondsWorkmanager);
      await tester.tap(button);
      await tester.pump();

      verify(() => mockWorkmanagerService.runOneTask()).called(1);
    });

    testWidgets('platform is website shows nothing', (WidgetTester tester) async {
      when(() => mockAppConfig.showNotificationView(any())).thenReturn(false);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.text(Strings.debugOption), findsNothing);
      expect(find.text(Strings.noWorkmanager), findsNothing);
      expect(find.text(Strings.withWorkmanager), findsNothing);
    });
  });
}
