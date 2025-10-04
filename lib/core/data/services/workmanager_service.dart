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
      // 1. Initialize necessary services
      final apiService = ApiServices(httpClient: http.Client());

      // 2. Fetch fresh data from API
      final restaurants = await apiService.getRestaurantList();

      // 3. Pick a restaurant (random, featured, etc.)
      final restaurant = restaurants.data?.restaurants.first; // or random selection

      // 4. Initialize notification service
      final notificationService = LocalNotificationService();
      await notificationService.init();

      // 5. Show notification with fresh API data
      await notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: "🍽️ Daily Restaurant Recommendation",
        body: "Try ${restaurant?.name} - ${restaurant?.description ?? 'A great place to dine!'}",
        payload: "${restaurant?.id}:list",
      );

      logger.i("✅ Notification shown with fresh data: ${restaurant?.name}");

      return Future.value(true);
    } catch (e) {
      logger.e("❌ WorkManager task failed: $e");
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
