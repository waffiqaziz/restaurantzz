import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:restaurantzz/app_root.dart';
import 'package:restaurantzz/feature/favorite/screen/favorite_screen.dart';
import 'package:restaurantzz/feature/list/screen/list_screen.dart';
import 'package:restaurantzz/feature/search/screen/search_screen.dart';
import 'package:restaurantzz/feature/settings/screen/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MainScreen Navigation', () {
    testWidgets('bottomNavigation_shouldNavigatesAndDisplaysCorrectScreens',
        (WidgetTester tester) async {
      final preference = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MultiProvider(
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
              create: (context) => WorkmanagerService(Workmanager())..init(),
            ),
          ],
          child: const MaterialApp(
            home: MainScreen(),
          ),
        ),
      );
      await tester.pumpWidget(AppRoot(prefs: preference, initialPayload: ""));

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
}
