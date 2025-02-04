import 'package:flutter/material.dart';
import 'package:restaurantzz/app_root.dart';
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  runApp(
    AppRoot(
      prefs: prefs,
      initialPayload:
          notificationAppLaunchDetails?.notificationResponse?.payload,
    ),
  );
}
