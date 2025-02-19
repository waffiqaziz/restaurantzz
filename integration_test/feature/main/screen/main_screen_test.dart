import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/app_root.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/local/local_database_service.dart';
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:restaurantzz/core/data/services/shared_preferences.dart';
import 'package:restaurantzz/core/data/services/workmanager_service.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';
import 'package:restaurantzz/core/provider/list/list_provider.dart';
import 'package:restaurantzz/core/provider/main/index_nav_provider.dart';
import 'package:restaurantzz/core/provider/notification/local_notification_provider.dart';
import 'package:restaurantzz/core/provider/payload/payload_provider.dart';
import 'package:restaurantzz/core/provider/search/search_provider.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';
import 'package:restaurantzz/feature/detail/screen/detail_screen.dart';
import 'package:restaurantzz/feature/favorite/screen/favorite_screen.dart';
import 'package:restaurantzz/feature/list/screen/list_card.dart';
import 'package:restaurantzz/feature/list/screen/list_screen.dart';
import 'package:restaurantzz/feature/main/screen/main_screen.dart';
import 'package:restaurantzz/feature/search/screen/search_screen.dart';
import 'package:restaurantzz/feature/settings/screen/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late IndexNavProvider indexNavProvider;

  Widget createWidgetUnderTest(SharedPreferences prefs) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<IndexNavProvider>(
          create: (_) => indexNavProvider,
        ),
        ChangeNotifierProvider<ListProvider>(
          create: (_) => ListProvider(
            ApiServices(
              httpClient: http.Client(),
            ),
          ), // Provide your real or mock ListProvider here
        ),
        ChangeNotifierProvider(
          create: (context) => SearchProvider(ApiServices(
            httpClient: http.Client(),
          )),
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
            payload: "initialPayload",
          ),
        ),
        Provider(
          create: (context) => WorkmanagerService()..init(),
        ),
      ],
      child: const MaterialApp(
        home: MainScreen(),
      ),
    );
  }

  group('MainScreen Navigation', () {
    setUp(() {
      indexNavProvider = IndexNavProvider();
    });

    testWidgets('bottomNavigation_shouldNavigatesAndDisplaysCorrectScreens',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(createWidgetUnderTest(prefs));

      await tester.pumpAndSettle();

      // initial ListScreen content
      expect(find.byType(ListScreen), findsOneWidget);

      // tap search icon and verify SearchScreen
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);

      // tap favorite icon and verify FavoriteScreen
      await tester.tap(find.byIcon(Icons.favorite_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(FavoriteScreen), findsOneWidget);

      // tap settings icon and verify SettingsScreen
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('ListScreen', () {
    testWidgets('allWidget_shouldShow', (WidgetTester tester) async {
      final preference = await SharedPreferences.getInstance();

      await tester.pumpWidget(AppRoot(prefs: preference, initialPayload: ""));
      await tester.pumpAndSettle();

      // initial ListScreen content
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.image(AssetImage('images/github-mark.png')), findsOneWidget);
      expect(find.byType(ListScreen), findsOneWidget);
      expect(find.text(Strings.ourRecommendation), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(RestaurantCard), findsWidgets);
    });

    testWidgets('tapCard_navigateToDetailScreen', (WidgetTester tester) async {
      final preference = await SharedPreferences.getInstance();

      await tester.pumpWidget(AppRoot(prefs: preference, initialPayload: ""));
      await tester.pumpAndSettle();

      // initial ListScreen content
      expect(find.byType(ListScreen), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(RestaurantCard), findsWidgets);
      await tester.tap(find.byType(RestaurantCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsOneWidget);
    });

    testWidgets('gitHubIconButton_shouldVisibleAndTappable',
        (WidgetTester tester) async {
      final preference = await SharedPreferences.getInstance();

      await tester.pumpWidget(AppRoot(prefs: preference, initialPayload: ""));
      await tester.pumpAndSettle();

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.image(AssetImage('images/github-mark.png')), findsOneWidget);
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
    });
  });
}
