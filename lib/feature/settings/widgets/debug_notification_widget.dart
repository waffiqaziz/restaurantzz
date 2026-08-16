import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/app_config.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/services/workmanager_service.dart';
import 'package:restaurantzz/core/provider/notification/local_notification_provider.dart';

class DebugNotification extends StatelessWidget {
  final AppConfig appConfig;
  const DebugNotification({super.key, required this.appConfig});

  @override
  Widget build(BuildContext context) {
    final localNotificationProvider = context.read<LocalNotificationProvider>();

    return Column(
      children: [
        if (appConfig.showNotificationView(context)) ...[
          const SizedBox(height: 16),
          Text(
            Strings.debugOption,
            style: TextStyle(color: Colors.grey, fontWeight: .bold),
          ),
          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () async {
              await localNotificationProvider.requestPermissions();
            },
            child: Consumer<LocalNotificationProvider>(
              builder: (context, value, child) {
                return Text(
                  "Request permission! (${value.permission})",
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          Text(Strings.noWorkmanager, style: const TextStyle(color: Colors.grey)),
          ElevatedButton(
            onPressed: () {
              localNotificationProvider.showNotification();
            },
            child: Text(Strings.testNotificationNow),
          ),

          ElevatedButton(
            onPressed: () {
              localNotificationProvider.scheduleTestNotification();
            },
            child: Text(Strings.testNotificationTwoMinutes),
          ),

          ElevatedButton(
            onPressed: () {
              localNotificationProvider.scheduleDailyElevenAMNotification();
            },
            child: Text(Strings.testNotificationAtEleven),
          ),

          ElevatedButton(
            onPressed: () {
              localNotificationProvider.cancelAllNotification();
            },
            child: Text(Strings.cancelAllNotification),
          ),

          // button to check pending notifications for debugging
          ElevatedButton(
            onPressed: () async {
              await localNotificationProvider.checkPendingNotificationRequests();
              final count = localNotificationProvider.pendingNotificationRequests.length;
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Pending notifications: $count')));
              }
            },
            child: Text(Strings.checkPendingNotifications),
          ),

          const SizedBox(height: 16),
          Text(Strings.withWorkmanager, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await context.read<WorkmanagerService>().runOneTask();
            },
            child: Text(Strings.testFiveSecondsWorkmanager),
          ),

          const SizedBox(height: 32),
        ] else ...[
          const SizedBox.shrink(),
        ],
      ],
    );
  }
}
