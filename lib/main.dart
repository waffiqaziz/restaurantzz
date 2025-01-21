import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';
import 'package:restaurantzz/core/provider/list/list_provider.dart';
import 'package:restaurantzz/core/theme/restaurantzz_theme.dart';
import 'package:restaurantzz/core/theme/util.dart';
import 'package:restaurantzz/feature/detail/screen/detail_screen.dart';
import 'package:restaurantzz/feature/list/screen/list_screen.dart';
import 'package:restaurantzz/static/navigation_route.dart';

void main() {
  runApp(MultiProvider(providers: [
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
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // get platform theme mode
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme =
        createTextTheme(context, "Nunito Sans", "Nunito Sans");

    RestaurantzzTheme theme = RestaurantzzTheme(textTheme);
    return MaterialApp(
      title: Strings.restaurantzz,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      initialRoute: NavigationRoute.mainRoute.name,
      routes: {
        NavigationRoute.mainRoute.name: (context) => const ListScreen(),
        NavigationRoute.detailRoute.name: (context) => DetailScreen(
              restaurantId: ModalRoute.of(context)?.settings.arguments as String,
            ),
      },
    );
  }
}
