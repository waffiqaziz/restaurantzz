import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/utils/logger.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return runDailyRestaurantTask(
      apiService: ApiServices(httpClient: http.Client()),
      notificationService: LocalNotificationService(),
    );
  });
}

@visibleForTesting
Future<bool> runDailyRestaurantTask({
  required ApiServices apiService,
  required LocalNotificationService notificationService,
}) async {
  logger.i("WorkManager task started");

  try {
    final restaurants = await apiService.getRestaurantList();
    final restaurantList = restaurants.data?.restaurants;

    if (restaurantList != null && restaurantList.isNotEmpty) {
      final randomRestaurant = restaurantList[Random().nextInt(restaurantList.length)];

      await notificationService.init();
      await notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: "Daily Restaurant Recommendation",
        body: "Try ${randomRestaurant.name} - ${randomRestaurant.description}",
        payload: "${randomRestaurant.id}:list",
      );

      logger.i("Notification shown: ${randomRestaurant.name}");
      return true;
    } else {
      return false;
    }
  } catch (e) {
    logger.e("WorkManager task failed: $e");
    return false;
  }
}

class WorkmanagerService {
  final Workmanager _workmanager;
  WorkmanagerService(this._workmanager);

  void init() {
    _workmanager.initialize(callbackDispatcher);
  }

  Future<void> runPeriodicTask() async {
    final scheduledDate = LocalNotificationService().nextInstanceOfElevenAM();
    final now = tz.TZDateTime.now(tz.local);
    final initialDelay = scheduledDate.difference(now);

    await _workmanager.registerPeriodicTask(
      "daily-restaurant-notification",
      "fetchAndShowNotification",
      frequency: Duration(hours: 24), // Run daily
      initialDelay: initialDelay,
    );

    logger.i('WorkManager periodic task registered');
  }

  Future<void> runOneTask() async {
    await _workmanager.registerOneOffTask(
      "daily-restaurant-notification",
      "fetchAndShowNotification",
      initialDelay: Duration(seconds: 5), // Start in 5 second for testing
    );

    logger.i("WorkManager one task registered");
  }

  void cancelAllTask() {
    _workmanager.cancelAll();
    logger.i("All WorkManager tasks cancelled");
  }
}
