import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:restaurantzz/core/data/services/local_notification_service.dart';

class LocalNotificationProvider extends ChangeNotifier {
  final LocalNotificationService flutterNotificationService;

  LocalNotificationProvider(this.flutterNotificationService);

  int _notificationId = 0;
  bool? _permission = false;
  bool? get permission => _permission;

  List<PendingNotificationRequest> pendingNotificationRequests = [];

  Future<void> requestPermissions() async {
    _permission = await flutterNotificationService.requestPermissions();
    notifyListeners();
  }

  void showNotification() {
    _notificationId += 1;
    final restaurantId = "rqdv5juczeskfw1e867"; // Example ID
    final heroTag = "list"; // Example heroTag
    final payload = "$restaurantId:$heroTag"; // Construct the payload

    flutterNotificationService.showNotification(
      id: _notificationId,
      title: "New Notification",
      body: "This is a new notification with payload $payload",
      payload: payload, // Pass the constructed payload
    );
  }

  void scheduleDailyElevenAMNotification() {
    _notificationId += 1;
    flutterNotificationService.scheduleDailyElevenAMNotification(
      id: _notificationId,
    );
  } 
  
   void scheduleTestNotification() {
    _notificationId += 1;
    flutterNotificationService.scheduleTestNotification(
      id: _notificationId,
    );
  }

  Future<void> checkPendingNotificationRequests() async {
    pendingNotificationRequests =
        await flutterNotificationService.pendingNotificationRequests();
    notifyListeners();
  }

  Future<void> cancelNotification(int id) async {
    await flutterNotificationService.cancelNotification(id);
  }
}
