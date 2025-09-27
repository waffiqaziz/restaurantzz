import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("🔄 WorkManager task started: $task");
    
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
      
      debugPrint("✅ Notification shown with fresh data: ${restaurant?.name}");
          
      return Future.value(true);
    } catch (e) {
      debugPrint("❌ WorkManager task failed: $e");
      return Future.value(false);
    }
  });
}

class WorkmanagerService {
  void init() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }

  Future<void> runPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      "daily-restaurant-notification",
      "fetchAndShowNotification",
      frequency: Duration(days: 1), // Run daily
      initialDelay: Duration(minutes: 1), // Start in 1 minute for testing
    );
    
    debugPrint("🔄 WorkManager periodic task registered");
  }

  void cancelAllTask() {
    Workmanager().cancelAll();
    debugPrint("❌ All WorkManager tasks cancelled");
  }
}
