import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/static/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final apiService = ApiServices(httpClient: http.Client());
    final notificationService = LocalNotificationService();
    bool isError = false;

    late String notificationBody;
    late Restaurant restaurantData;

    try {
      if (task == MyWorkmanager.periodic.taskName) {
        final result = await apiService.getRestaurantList();

        if (result.data != null) {
          final restaurants = result.data!.restaurants;
          int randomNumber = Random().nextInt(result.data!.restaurants.length);
          restaurantData = result.data!.restaurants[randomNumber];

          notificationBody = restaurants.isNotEmpty
              ? restaurantData.description
              : "No restaurants available.";
        } else {
          isError = true;
          notificationBody = "${result.message}";
        }
      }
    } catch (error) {
      isError = true;
      notificationBody = "Unexpected error fetching restaurant data.";
    }

    await notificationService.init();

    // show notification based on network result
    if (!isError) {
      await notificationService.showNotification(
        id: 1,
        title: restaurantData.name,
        body: notificationBody,
        payload: "${restaurantData.id}:list",
      );
    } else {
      await notificationService.showNotification(
        id: 1,
        title: Strings.dailyNotification,
        body: notificationBody,
        payload: Strings.error,
      );
    }

    return Future.value(true);
  });
}

class WorkmanagerService {
  final Workmanager _workmanager;

  WorkmanagerService([Workmanager? workmanager])
      : _workmanager = workmanager ??= Workmanager();

  Future<void> init() async {
    await _workmanager.initialize(callbackDispatcher, isInDebugMode: false);
  }

  Future<void> runPeriodicTask() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 11);

    Duration initialDelay = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1)).difference(now)
        : scheduledDate.difference(now);

    await _workmanager.registerPeriodicTask(
      MyWorkmanager.periodic.uniqueName,
      MyWorkmanager.periodic.taskName,
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
      inputData: {
        "task": "Fetch API Data and show notification",
      },
    );
  }

  Future<void> cancelAllTask() async {
    await _workmanager.cancelAll();
  }
}
