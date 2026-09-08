import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../testutils/mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();

  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroid;
  late MockIOSFlutterLocalNotificationsPlugin mockIOS;
  late LocalNotificationService service;

  setUpAll(() {
    registerFallbackValue(
      const InitializationSettings(android: AndroidInitializationSettings('app_icon')),
    );
    registerFallbackValue(
      const NotificationDetails(android: AndroidNotificationDetails('id', 'name')),
    );
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(DateTimeComponents.time);
  });

  setUp(() {
    final mockTimezoneProvider = MockTimezoneProvider();
    when(() => mockTimezoneProvider.getLocalTimezone()).thenAnswer((_) async => 'UTC');

    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroid = MockAndroidFlutterLocalNotificationsPlugin();
    mockIOS = MockIOSFlutterLocalNotificationsPlugin();
    service = LocalNotificationService(
      plugin: mockPlugin,
      androidImplementation: mockAndroid,
      iosImplementation: mockIOS,
      timezoneProvider: mockTimezoneProvider,
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('init', () {
    test('init_whenCalled_initializesPluginWithSettings', () async {
      when(
        () => mockPlugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
        ),
      ).thenAnswer((_) async => true);

      await service.init();

      verify(
        () => mockPlugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'),
        ),
      ).called(1);
    });
  });

  group('requestPermissions', () {
    test('requestPermissions_whenPlatformIsIOS_requestsIosPermissionsAndReturnsResult', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      when(() => mockIOS.requestPermissions(alert: true, badge: true, sound: true))
          .thenAnswer((_) async => true);

      final result = await service.requestPermissions();

      expect(result, true);
      verify(() => mockIOS.requestPermissions(alert: true, badge: true, sound: true)).called(1);
    });

    test('requestPermissions_whenAndroidAlreadyGranted_returnsTrueWithoutRequestingNotificationPermission', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      when(() => mockAndroid.areNotificationsEnabled()).thenAnswer((_) async => true);
      when(() => mockAndroid.requestExactAlarmsPermission()).thenAnswer((_) async => true);

      final result = await service.requestPermissions();

      expect(result, true);
      verifyNever(() => mockAndroid.requestNotificationsPermission());
    });

    test(
      'requestPermissions_whenAndroidNotGrantedAndAlarmGranted_requestsPermissionAndReturnsTrue',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        when(() => mockAndroid.areNotificationsEnabled()).thenAnswer((_) async => false);
        when(() => mockAndroid.requestExactAlarmsPermission()).thenAnswer((_) async => true);
        when(() => mockAndroid.requestNotificationsPermission()).thenAnswer((_) async => true);

        final result = await service.requestPermissions();

        expect(result, true);
        verify(() => mockAndroid.requestNotificationsPermission()).called(1);
      },
    );

    test('requestPermissions_whenAndroidNotGrantedAndRequestFails_returnsFalse', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      when(() => mockAndroid.areNotificationsEnabled()).thenAnswer((_) async => false);
      when(() => mockAndroid.requestExactAlarmsPermission()).thenAnswer((_) async => true);
      when(() => mockAndroid.requestNotificationsPermission()).thenAnswer((_) async => false);

      final result = await service.requestPermissions();

      expect(result, false);
    });

    test('requestPermissions_whenPlatformIsUnsupported_returnsFalse', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      final result = await service.requestPermissions();

      expect(result, false);
    });
  });

  group('showNotification', () {
    test('showNotification_whenCalled_callsPluginShowWithGivenParams', () async {
      when(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) async {});

      await service.showNotification(
        id: 1,
        title: 'Test Restaurant',
        body: 'Great food!',
        payload: '1:list',
      );

      verify(
        () => mockPlugin.show(
          id: 1,
          title: 'Test Restaurant',
          body: 'Great food!',
          notificationDetails: any(named: 'notificationDetails'),
          payload: '1:list',
        ),
      ).called(1);
    });
  });

  group('nextInstanceOfElevenAM', () {
    test('nextInstanceOfElevenAM_whenCalled_returnsTimeSetToElevenAM', () {
      final result = service.nextInstanceOfElevenAM();

      expect(result.hour, 11);
      expect(result.minute, 0);
    });

    test('nextInstanceOfElevenAM_whenCalled_returnsTimeAfterNow', () {
      final result = service.nextInstanceOfElevenAM();

      expect(result.isAfter(tz.TZDateTime.now(tz.local)), true);
    });
  });

  group('scheduleTestNotification', () {
    test('scheduleTestNotification_whenCalled_schedulesWithCorrectTitleAndPayload', () async {
      when(
        () => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) async {});

      await service.scheduleTestNotification(id: 5);

      verify(
        () => mockPlugin.zonedSchedule(
          id: 5,
          title: 'Test Scheduled Notification',
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'test:scheduled',
        ),
      ).called(1);
    });
  });

  group('scheduleDailyElevenAMNotification', () {
    test('scheduleDailyElevenAMNotification_whenCalled_schedulesWithTimeMatchComponent', () async {
      when(
        () => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).thenAnswer((_) async {});

      await service.scheduleDailyElevenAMNotification(id: 3);

      verify(
        () => mockPlugin.zonedSchedule(
          id: 3,
          title: 'Daily scheduled notification title',
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        ),
      ).called(1);
    });
  });

  group('pendingNotificationRequests', () {
    test('pendingNotificationRequests_whenCalled_returnsListFromPlugin', () async {
      when(
        () => mockPlugin.pendingNotificationRequests(),
      ).thenAnswer((_) async => [const PendingNotificationRequest(1, 'title', 'body', 'payload')]);

      final result = await service.pendingNotificationRequests();

      expect(result.length, 1);
      expect(result.first.id, 1);
    });

    test('pendingNotificationRequests_whenNoneScheduled_returnsEmptyList', () async {
      when(() => mockPlugin.pendingNotificationRequests()).thenAnswer((_) async => []);

      final result = await service.pendingNotificationRequests();

      expect(result, isEmpty);
    });
  });

  group('cancelNotification', () {
    test('cancelNotification_whenCalledWithId_callsPluginCancelWithSameId', () async {
      when(() => mockPlugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});

      await service.cancelNotification(7);

      verify(() => mockPlugin.cancel(id: 7)).called(1);
    });
  });

  group('cancelAllNotification', () {
    test('cancelAllNotification_whenCalled_callsPluginCancelAll', () async {
      when(() => mockPlugin.cancelAll()).thenAnswer((_) async {});

      await service.cancelAllNotification();

      verify(() => mockPlugin.cancelAll()).called(1);
    });
  });
}
