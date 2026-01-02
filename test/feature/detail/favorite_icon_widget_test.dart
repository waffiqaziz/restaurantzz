import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/data/local/local_database_service.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:restaurantzz/core/provider/detail/favorite_icon_provider.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';
import 'package:restaurantzz/feature/detail/screen/favorite_icon_widget.dart';

void main() {
  group('FavoriteIconWidget', () {
    final testRestaurant = Restaurant(
      id: 'test_id',
      name: 'Test Restaurant',
      description: '',
      pictureId: '',
      city: '',
      rating: 9,
    );

    Widget createWidgetUnderTest() {
      return MultiProvider(
        providers: [
          Provider(create: (context) => LocalDatabaseService()),
          ChangeNotifierProvider(
            create: (context) => LocalDatabaseProvider(context.read<LocalDatabaseService>()),
          ),
          ChangeNotifierProvider(create: (_) => FavoriteIconProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(body: FavoriteIconWidget(restaurant: testRestaurant)),
        ),
      );
    }

    testWidgets('initialState_showsFavoriteOutlineRoundedIcon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.favorite_outline_rounded), findsOneWidget);
    });

    testWidgets('tappingIcon_ShouldUpdatesTheIconFavorite', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byIcon(Icons.favorite_outline_rounded), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(find.byIcon(Icons.favorite_outline_rounded), findsOneWidget);
    });
  });
}
