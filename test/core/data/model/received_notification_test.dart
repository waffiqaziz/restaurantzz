import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/data/model/received_notification.dart';

void main() {
  group('ReceivedNotification', () {
    test('initialize_shouldReturnCorrectProperties', () {
      final notification = ReceivedNotification(
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
        payload: 'Test Payload',
      );

      expect(notification.id, 1);
      expect(notification.title, 'Test Title');
      expect(notification.body, 'Test Body');
      expect(notification.payload, 'Test Payload');
    });

    test('initialize_shouldAllowsNullValues', () {
      final notification = ReceivedNotification();

      expect(notification.id, isNull);
      expect(notification.title, isNull);
      expect(notification.body, isNull);
      expect(notification.payload, isNull);
    });

    test('multiple_equalityCheck', () {
      final notification1 = ReceivedNotification(
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
        payload: 'Test Payload',
      );

      final notification2 = ReceivedNotification(
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
        payload: 'Test Payload',
      );

      final notification3 = ReceivedNotification(
        id: 2,
        title: 'Different Title',
        body: 'Different Body',
        payload: 'Different Payload',
      );

      bool areEqual(ReceivedNotification a, ReceivedNotification b) {
        return a.id == b.id &&
            a.title == b.title &&
            a.body == b.body &&
            a.payload == b.payload;
      }

      expect(areEqual(notification1, notification2), isTrue);
      expect(areEqual(notification1, notification3), isFalse);
    });
  });
}
