import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/model/setting.dart';
import 'package:restaurantzz/core/data/services/workmanager_service.dart';
import 'package:restaurantzz/core/provider/notification/local_notification_provider.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';
import 'package:restaurantzz/core/utils/logger.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget buildSwitchNotification(
    BuildContext context,
    SharedPreferencesProvider provider,
  ) {
    final localNotificationProvider = context.read<LocalNotificationProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.notifications_active_rounded),
            const SizedBox(width: 8),
            Text(
              Strings.enableNotification,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        Switch(
          value: provider.setting?.notificationEnable ?? true,
          onChanged: (bool value) async {
            try {
              final updatedSetting = Setting(
                notificationEnable: value,
                isDark: provider.setting?.isDark ?? false,
              );
              provider.saveSettingValue(updatedSetting);

              if (value) {
                // Start WorkManager for daily API fetching + notification
                await _scheduleDailyElevenAMNotificationWithWorkManager();
                localNotificationProvider.scheduleDailyElevenAMNotification();
                logger.i(
                    "✅ Daily notifications enabled - WorkManager will handle API + notifications at 11 AM");
              } else {
                // Stop everything
                _cancelAllTaskInBackground();

                logger.i("❌ Daily notifications disabled");
              }
            } catch (e) {
              if (!context.mounted) {
                return;
              }

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(Strings.errorOccured),
                    content: Text(Strings.errorNotification),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(Strings.ok),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SharedPreferencesProvider>();
    final localNotificationProvider = context.read<LocalNotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.settings,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // notification switch for mobile only
            if (!kIsWeb &&
                (Theme.of(context).platform == TargetPlatform.iOS ||
                    Theme.of(context).platform == TargetPlatform.android))
              buildSwitchNotification(context, provider),

            // dark mode switch (shown on all platforms)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.dark_mode_rounded),
                    const SizedBox(width: 8),
                    Text(
                      Strings.darkMode,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                Switch(
                  value: provider.setting?.isDark ?? false,
                  onChanged: (bool value) {
                    provider.setTheme(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // status Message
            Text(
              provider.message,
              style: const TextStyle(color: Colors.grey),
            ),

            if (!kIsWeb &&
                (Theme.of(context).platform == TargetPlatform.iOS ||
                    Theme.of(context).platform == TargetPlatform.android))
              ElevatedButton(
                onPressed: () async {
                  await _requestPermission();
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

            ElevatedButton(
              onPressed: () {
                localNotificationProvider.showNotification();
              },
              child: Text('Test Notification Immediately'),
            ),

            ElevatedButton(
              onPressed: () {
                localNotificationProvider.scheduleTestNotification();
              },
              child: Text('Test Notification Two Minues'),
            ),

            // button to check pending notifications for debugging
            ElevatedButton(
              onPressed: () async {
                await localNotificationProvider
                    .checkPendingNotificationRequests();
                final count = localNotificationProvider
                    .pendingNotificationRequests.length;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pending notifications: $count')),
                );
              },
              child: Text('Check Pending Notifications'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    context.read<LocalNotificationProvider>().requestPermissions();
  }

  void _cancelAllTaskInBackground() async {
    context.read<WorkmanagerService>().cancelAllTask();
  }

  Future<void> _scheduleDailyElevenAMNotificationWithWorkManager() async {
    context.read<WorkmanagerService>().runPeriodicTask();
  }
}
