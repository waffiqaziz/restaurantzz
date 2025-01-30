import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/static/workmanager.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final apiService = ApiServices();
    final notificationService = LocalNotificationService();

    String notificationBody = "Check the app for the latest update.";
    late Restaurant restaurantData;

    try {
      if (task == MyWorkmanager.periodic.taskName) {
        final result = await apiService.getRestaurantList();

        if (result.data != null ) {
          final restaurants = result.data!.restaurants;
          restaurantData  = result.data!.restaurants[2];
          notificationBody = restaurants.isNotEmpty
              ? "Found ${restaurants.length} restaurants! Check them out."
              : "No restaurants available.";
        } else {
          notificationBody = "API error: ${result.message}";
        }
      }
    } catch (error) {
      print("Error fetching API data: $error");
      notificationBody = "Unexpected error fetching restaurant data.";
    }

    await notificationService.init(); // Ensure notification service is initialized

    await notificationService.showNotification(
      id: 1,
      title: restaurantData.name,
      body: notificationBody,
      payload: "${restaurantData.id}:list",
    );

    return Future.value(true);
  });
}

class WorkmanagerService {
  final Workmanager _workmanager;

  WorkmanagerService([Workmanager? workmanager])
      : _workmanager = workmanager ??= Workmanager();

  Future<void> init() async {
    await _workmanager.initialize(callbackDispatcher, isInDebugMode: true);
  }

  Future<void> runOneOffTask() async {
    await _workmanager.registerOneOffTask(
      MyWorkmanager.oneOff.uniqueName,
      MyWorkmanager.oneOff.taskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      initialDelay: const Duration(seconds: 5),
      inputData: {
        "data": "This is a valid payload from oneoff task workmanager",
      },
    );
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
