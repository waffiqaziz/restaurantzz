import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:restaurantzz/feature/list/screen/list_card.dart';

void main() {
  group('RestaurantCard widget', () {
    final restaurant = Restaurant(
      id: 'Restaurand ID',
      name: 'Test Restaurant',
      description: 'Description',
      pictureId: 'test_image_id',
      rating: 4.5,
      city: 'Test City',
    );
    bool tapped = false;
    late Widget widget;

    setUp(() {
      widget = MaterialApp(
        home: Scaffold(
          body: RestaurantCard(
            restaurant: restaurant,
            onTap: () {
              tapped = true;
            },
            heroTag: 'test_tag',
          ),
        ),
      );
    });

    testWidgets("text restaurant name is displayed",
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      expect(find.text('Test Restaurant'), findsOneWidget);
    });

    testWidgets("text rating is displayed", (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      expect(find.text('(4.5/5.0)'), findsOneWidget);
    });

    testWidgets("text city is displayed", (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      expect(find.text('Test City'), findsOneWidget);
    });

    testWidgets("image placeholder is shown initially",
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets("simulate a tap and verify the onTap function is triggered",
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets("hero widget exists with the correct tag",
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Hero && widget.tag == "${restaurant.pictureId}_test_tag"),
        findsOneWidget,
      );
    });
  });
}
