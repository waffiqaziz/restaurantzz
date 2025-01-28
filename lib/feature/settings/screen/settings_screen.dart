import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/model/setting.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SharedPreferencesProvider>();

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
            // notification switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                  onChanged: (bool value) {
                    final updatedSetting = Setting(
                      notificationEnable: value,
                      isDark: provider.setting?.isDark ?? false,
                    );
                    provider.saveSettingValue(updatedSetting);
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),

            // dark mode switch
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

            // Status Message
            Text(
              provider.message,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
