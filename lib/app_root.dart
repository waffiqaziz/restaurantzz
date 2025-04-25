import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/data/local/local_database_service.dart';
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:restaurantzz/core/data/services/shared_preferences.dart';
import 'package:restaurantzz/core/data/services/workmanager_service.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';
import 'package:restaurantzz/core/provider/detail/favorite_icon_provider.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';
import 'package:restaurantzz/core/provider/list/list_provider.dart';
import 'package:restaurantzz/core/provider/main/index_nav_provider.dart';
import 'package:restaurantzz/core/provider/notification/local_notification_provider.dart';
import 'package:restaurantzz/core/provider/payload/payload_provider.dart';
import 'package:restaurantzz/core/provider/search/search_provider.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';
import 'package:restaurantzz/my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRoot extends StatelessWidget {
  final SharedPreferences prefs;
  final String? initialPayload;

  const AppRoot({super.key, required this.prefs, this.initialPayload});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => IndexNavProvider(),
        ),
        Provider(
          create: (context) => ApiServices(httpClient: http.Client()),
        ),
        ChangeNotifierProvider(create: (context) => FavoriteIconProvider()),
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
        Provider(
          create: (context) => SharedPreferencesService(prefs),
        ),
        ChangeNotifierProvider(
          create: (context) => SharedPreferencesProvider(
            context.read<SharedPreferencesService>(),
          ),
        ),
        Provider(
          create: (context) => LocalNotificationService()
            ..init()
            ..configureLocalTimeZone(),
        ),
        ChangeNotifierProvider(
          create: (context) => LocalNotificationProvider(
            context.read<LocalNotificationService>(),
          )..requestPermissions(),
        ),
        ChangeNotifierProvider(
          create: (context) => PayloadProvider(
            payload: initialPayload,
          ),
        ),
        Provider(
          create: (context) => WorkmanagerService()..init(),
        ),
      ],
      child: MyApp(
        prefs: prefs,
        initialPayload: initialPayload,
      ),
    );
  }
}
