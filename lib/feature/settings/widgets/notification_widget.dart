import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/app_config.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/model/setting.dart';
import 'package:restaurantzz/core/data/services/workmanager_service.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';
import 'package:restaurantzz/core/utils/logger.dart';

class NotificationWidget extends StatelessWidget {
  final AppConfig appConfig;
  const NotificationWidget({super.key, required this.appConfig});

  @override
  Widget build(BuildContext context) {
    final prefProvider = context.watch<SharedPreferencesProvider>();

    return Row(
      children: [
        if (appConfig.showNotificationView(context)) ...[
          const Icon(Icons.notifications_active_rounded),
          const SizedBox(width: 8),
          Expanded(
            child: Text(Strings.enableNotification, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 8),
          Switch(
            key: const Key('notification_switch'),
            value: prefProvider.setting?.notificationEnable ?? true,
            onChanged: (bool value) async {
              try {
                final updatedSetting = Setting(
                  notificationEnable: value,
                  isDark: prefProvider.setting?.isDark ?? false,
                );

                prefProvider.saveSettingValue(updatedSetting);

                if (value) {
                  // Start WorkManager for daily API fetching + notification
                  await context.read<WorkmanagerService>().runPeriodicTask();
                  logger.i(
                    "Daily notifications enabled - WorkManager will handle API + notifications at 11 AM",
                  );
                } else {
                  context.read<WorkmanagerService>().cancelAllTask();

                  logger.i("Daily notifications disabled");
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
        ] else ...[
          const SizedBox.shrink(),
        ],
      ],
    );
  }
}
