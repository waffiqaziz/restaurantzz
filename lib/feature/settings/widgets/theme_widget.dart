import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';

class ThemeWidget extends StatelessWidget {
  const ThemeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final prefProvider = context.watch<SharedPreferencesProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.dark_mode_rounded),
            const SizedBox(width: 8),
            Text(Strings.darkMode, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        Switch(
          value: prefProvider.setting?.isDark ?? false,
          onChanged: (bool value) {
            prefProvider.setTheme(value);
          },
        ),
      ],
    );
  }
}
