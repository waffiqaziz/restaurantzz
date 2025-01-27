import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/local/local_database_service.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';
import 'package:restaurantzz/core/provider/list/list_provider.dart';
import 'package:restaurantzz/core/provider/main/index_nav_provider.dart';
import 'package:restaurantzz/core/provider/search/search_provider.dart';
import 'package:restaurantzz/core/theme/restaurantzz_theme.dart';
import 'package:restaurantzz/core/theme/util.dart';
import 'package:restaurantzz/feature/detail/screen/detail_screen.dart';
import 'package:restaurantzz/feature/main/screen/main_screen.dart';
import 'package:restaurantzz/static/navigation_route.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => IndexNavProvider(),
        ),
        Provider(
          create: (context) => ApiServices(),
        ),
        ChangeNotifierProvider(
          create: (context) => ListProvider(
            context.read<ApiServices>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DetailProvider(
            context.read<ApiServices>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SearchProvider(
            context.read<ApiServices>(),
          ),
        ),
        Provider(
          create: (context) => LocalDatabaseService(),
        ),
        ChangeNotifierProvider(
          create: (context) => LocalDatabaseProvider(
            context.read<LocalDatabaseService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context);

    RestaurantzzTheme theme = RestaurantzzTheme(textTheme);
    return MaterialApp(
      title: Strings.restaurantzz,
      theme: theme.light(),
      darkTheme: theme.dark(),
      initialRoute: NavigationRoute.mainRoute.name,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const MainScreen());
          case '/detail':
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (_) => DetailScreen(
                restaurantId: args['restaurantId']!,
                heroTag: args['heroTag']!,
              ),
            );
          default:
            return null; // Handle unknown routes if needed
        }
      },
    );
  }
}
