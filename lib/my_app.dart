import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';
import 'package:restaurantzz/core/theme/restaurantzz_theme.dart';
import 'package:restaurantzz/core/theme/util.dart';
import 'package:restaurantzz/feature/detail/screen/detail_screen.dart';
import 'package:restaurantzz/feature/main/screen/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  final String? initialPayload;

  const MyApp({super.key, required this.prefs, this.initialPayload});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // prevent GLobalKey error
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialPayload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handlePayload(widget.initialPayload!);
      });
    }
  }

  void handlePayload(String payload) {
    List<String> parts = payload.split(":");
    if (parts.length == 2) {
      // ensure MainScreen is the root of the navigation stack
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/',
        (Route<dynamic> route) => false, // remove all existing routes
      );

      // navigate to the [DetailScreen]
      _navigatorKey.currentState?.pushNamed(
        '/detail',
        arguments: {'restaurantId': parts[0], 'heroTag': parts[1]},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context);
    RestaurantzzTheme theme = RestaurantzzTheme(textTheme);

    return Consumer<SharedPreferencesProvider>(
      builder: (context, provider, child) {
        final isDarkMode = provider.setting?.isDark ?? false;

        return MaterialApp(
          key: ValueKey('MyAppKey'),
          navigatorKey: _navigatorKey,
          title: Strings.restaurantzz,
          theme: theme.light(),
          darkTheme: theme.dark(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => const MainScreen());
              case '/detail':
                final args = settings.arguments as Map<String, String>;
                return MaterialPageRoute(
                  builder: (_) =>
                      DetailScreen(restaurantId: args['restaurantId']!, heroTag: args['heroTag']!),
                );
              default:
                return null;
            }
          },
        );
      },
    );
  }
}
