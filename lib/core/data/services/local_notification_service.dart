import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:restaurantzz/core/data/model/received_notification.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

class LocalNotificationService {
  Future<void> init() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      'app_icon',
    );
    const initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        final payload = notificationResponse.payload;
        if (payload != null && payload.isNotEmpty) {
          selectNotificationStream.add(payload);
        }
      },
    );
  }

  Future<bool> _isAndroidPermissionGranted() async {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;
  }

  Future<bool> _requestAndroidNotificationsPermission() async {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false;
  }

  Future<bool> _requestExactAlarmsPermission() async {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestExactAlarmsPermission() ??
        false;
  }

  Future<bool?> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iOSImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final result = await iOSImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('iOS notification permissions granted: $result');
      return result;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final notificationEnabled = await _isAndroidPermissionGranted();
      final requestAlarmEnabled = await _requestExactAlarmsPermission();

      debugPrint('Android notification enabled: $notificationEnabled');
      debugPrint('Android exact alarm enabled: $requestAlarmEnabled');

      if (!notificationEnabled) {
        final requestNotificationsPermission =
            await _requestAndroidNotificationsPermission();
        debugPrint(
            'Requested notification permission: $requestNotificationsPermission');
        return requestNotificationsPermission && requestAlarmEnabled;
      }
      return notificationEnabled && requestAlarmEnabled;
    } else {
      return false;
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    String channelId = "1",
    String channelName = "Simple Notification",
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      playSound: true,
      enableVibration: true,
    );
    final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      sound: 'slow_spring_board.aiff',
      presentSound: true,
    );
    final notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    debugPrint('Configured timezone: $timeZoneName');
    debugPrint('Current local time: ${tz.TZDateTime.now(tz.local)}');
  }

  tz.TZDateTime _nextInstanceOfCustomTime(
      {int hour = 11, int minute = 0, int? testMinutesFromNow}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    if (testMinutesFromNow != null) {
      final testTime = now.add(Duration(minutes: testMinutesFromNow));
      debugPrint(
          'TEST MODE: Scheduling notification for $testMinutesFromNow minutes from now: $testTime');
      return testTime;
    }

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // If it's already past the target time today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('Current time: $now');
    debugPrint('Scheduled time: $scheduledDate');
    debugPrint('Time until notification: ${scheduledDate.difference(now)}');

    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfElevenAM() {
    return _nextInstanceOfCustomTime(hour: 11, minute: 0);
  }

  Future<void> scheduleTestNotification({required int id}) async {
    await configureLocalTimeZone();

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'test_notification',
      'Test Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Test Notification',
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      playSound: true,
      enableVibration: true,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      sound: 'slow_spring_board.aiff',
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final testTime = _nextInstanceOfCustomTime(testMinutesFromNow: 2);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Test Scheduled Notification',
      'This is a test notification scheduled for 2 minutes from now',
      testTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      payload: 'test:scheduled',
    );

    print('Test notification scheduled for: $testTime');
  }

  Future<void> scheduleDailyElevenAMNotification({
    required int id,
    String channelId = "3",
    String channelName = "Schedule Notification",
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final datetimeSchedule = _nextInstanceOfElevenAM();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Daily scheduled notification title',
      'This is a body of daily scheduled notification',
      datetimeSchedule,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotificationRequests;
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
