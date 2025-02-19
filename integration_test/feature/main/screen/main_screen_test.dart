import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:restaurantzz/app_root.dart';
import 'package:restaurantzz/feature/favorite/screen/favorite_screen.dart';
import 'package:restaurantzz/feature/list/screen/list_screen.dart';
import 'package:restaurantzz/feature/search/screen/search_screen.dart';
import 'package:restaurantzz/feature/settings/screen/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MainScreen Navigation', () {
    testWidgets('bottomNavigation_shouldNavigatesAndDisplaysCorrectScreens',
        (WidgetTester tester) async {
      final preference = await SharedPreferences.getInstance();

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
