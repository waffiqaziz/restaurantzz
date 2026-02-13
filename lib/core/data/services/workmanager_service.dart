import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/utils/logger.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    logger.i("🔄 WorkManager task started: $task");

    try {
      // get resto data
      final apiService = ApiServices(httpClient: http.Client());
      final restaurants = await apiService.getRestaurantList();
      final restaurantList = restaurants.data?.restaurants;

      // show notification only if data is ready
      if (restaurantList != null && restaurantList.isNotEmpty) {
        final randomRestaurant = restaurantList[Random().nextInt(restaurantList.length)];

        final notificationService = LocalNotificationService();
        await notificationService.init();
        await notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: "Daily Restaurant Recommendation",
          body:
              "Try ${randomRestaurant.name} - ${randomRestaurant.description}",
          payload: "${randomRestaurant.id}:list",
        );

        logger.i("Notification shown with fresh data: ${randomRestaurant.name}");

        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } catch (e) {
      logger.e("WorkManager task failed: $e");
      return Future.value(false);
    }
  });
}

class WorkmanagerService {
  final Workmanager _workmanager;
  WorkmanagerService(this._workmanager);

  void init() {
    _workmanager.initialize(callbackDispatcher);
  }

  Future<void> runPeriodicTask() async {
    await _workmanager.registerPeriodicTask(
      "daily-restaurant-notification",
      "fetchAndShowNotification",
      frequency: Duration(days: 1), // Run daily
      initialDelay: Duration(minutes: 1), // Start in 1 minute for testing
    );

    logger.i("🔄 WorkManager periodic task registered");
  }

  void cancelAllTask() {
    _workmanager.cancelAll();
    logger.i("❌ All WorkManager tasks cancelled");
  }
}
