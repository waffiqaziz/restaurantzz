import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/provider/notification/local_notification_provider.dart';

import '../../../testutils/mock.dart';

void main() {
  group('LocalNotificationProvider', () {
    late MockLocalNotificationService mockService;
    late LocalNotificationProvider localNotificationProvider;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockService = MockLocalNotificationService();
      localNotificationProvider = LocalNotificationProvider(mockService);
    });

    test('requestPermissions_shouldUpdatePermissionState', () async {
      when(() => mockService.requestPermissions())
          .thenAnswer((_) async => true);

      await localNotificationProvider.requestPermissions();

      expect(localNotificationProvider.permission, isTrue);
      verify(() => mockService.requestPermissions()).called(1);
    });

    test('showNotification_shouldTriggerNotification', () {
      when(() => mockService.showNotification(
            id: 1,
            title: "New Notification",
            body:
                "This is a new notification with payload rqdv5juczeskfw1e867:list",
            payload: "rqdv5juczeskfw1e867:list",
          )).thenAnswer((_) => Future.value());

      localNotificationProvider.showNotification();

      verify(() => mockService.showNotification(
            id: 1,
            title: "New Notification",
            body:
                "This is a new notification with payload rqdv5juczeskfw1e867:list",
            payload: "rqdv5juczeskfw1e867:list",
          )).called(1);
    });

    test('scheduleDailyElevenAMNotification_shouldScheduleNotification', () {
      when(() => mockService.scheduleDailyElevenAMNotification(
            id: any<int>(named: 'id'),
            channelId: any<String>(named: 'channelId'),
            channelName: any<String>(named: 'channelName'),
          )).thenAnswer((_) => Future.value());

      localNotificationProvider.scheduleDailyElevenAMNotification();

      verify(() => mockService.scheduleDailyElevenAMNotification(
            id: any<int>(named: 'id'),
            channelId: any<String>(named: 'channelId'),
            channelName: any<String>(named: 'channelName'),
          )).called(1);
    });

    test('checkPendingNotificationRequests_shouldUpdatePendingList', () async {
      when(() => mockService.pendingNotificationRequests()).thenAnswer(
        (_) async => [
          PendingNotificationRequest(
              1, 'Test Notification', 'Test Body', 'Payload')
        ],
      );

      bool isNotified = false;
      localNotificationProvider.addListener(() {
        isNotified = true;
      });

      await localNotificationProvider.checkPendingNotificationRequests();

      expect(isNotified, isTrue,
          reason: "Expected notifyListeners to be called.");
      expect(localNotificationProvider.pendingNotificationRequests.length, 1);
      expect(localNotificationProvider.pendingNotificationRequests.first.id,
          equals(1));
      verify(() => mockService.pendingNotificationRequests()).called(1);
    });

    test('cancelNotification_validId_shouldCancelNotification', () async {
      const notificationId = 1;
      when(() => mockService.cancelNotification(notificationId)).thenAnswer(
        (_) async => {},
      );

      await localNotificationProvider.cancelNotification(notificationId);

      verify(() => mockService.cancelNotification(notificationId)).called(1);
    });
  });
}
