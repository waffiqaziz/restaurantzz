import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/app_config.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';
import 'package:restaurantzz/feature/settings/widgets/debug_notification_widget.dart';
import 'package:restaurantzz/feature/settings/widgets/notification_widget.dart';
import 'package:restaurantzz/feature/settings/widgets/theme_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefProvider = context.watch<SharedPreferencesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.settings,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              NotificationWidget(appConfig: AppConfig()),
              ThemeWidget(),
              const SizedBox(height: 16),

              // status Message
              Text(prefProvider.message, style: const TextStyle(color: Colors.grey)),
              Divider(height: 20, thickness: 2, indent: 10, endIndent: 10, color: Colors.grey),

              DebugNotification(appConfig: AppConfig()),
            ],
          ),
        ),
      ),
    );
  }
}
