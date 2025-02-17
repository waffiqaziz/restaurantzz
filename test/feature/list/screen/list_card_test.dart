import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:restaurantzz/core/common/constants.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:restaurantzz/feature/list/screen/list_card.dart';

void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
  group('RestaurantCard', () {
    final restaurant = Restaurant(
      id: 'rqdv5juczeskfw1e867',
      name: 'Test Restaurant',
      description: 'Description',
      pictureId: '14',
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

    testWidgets("textRestaurantName_shouldDisplayed",
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      expect(find.text('Test Restaurant'), findsOneWidget);
    });

    testWidgets("textRating_shouldDisplayed", (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      expect(find.text('(4.5/5.0)'), findsOneWidget);
    });

    testWidgets("textCity_shouldDisplayed", (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      expect(find.text('Test City'), findsOneWidget);
    });

    testWidgets("imagePlaceholder_shouldShownWhenOnInitial",
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets("hover_shouldTriggerOnHoverCallback",
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      // Move mouse over the widget
      await gesture.moveTo(tester.getCenter(find.byType(InkWell)));
      await tester.pumpAndSettle();
    });

    testWidgets("imageNetwork_shouldDisplay", (WidgetTester tester) async {
      await mockNetworkImagesFor(() => tester.pumpWidget(widget));
      await tester.pump();

      final imageNetworkFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is NetworkImage &&
            (widget.image as NetworkImage).url ==
                Constants.imageURLSmallResolution + restaurant.pictureId,
      );

      expect(imageNetworkFinder, findsOneWidget);
    });

    // TODO: Not yet fixed to test image placeholder
    // testWidgets("imagePlaceholder_shouldBeDisplayedWhenLoading",
    //     (WidgetTester tester) async {
    //   await mockNetworkImagesFor(() => tester.pumpWidget(widget));
    //   await tester.pump();

    //   final placeholderFinder = find.byWidgetPredicate(
    //     (widget) =>
    //         widget is Image &&
    //         widget.image is AssetImage &&
    //         (widget.image as AssetImage).assetName == 'images/placeholder.webp',
    //   );

    //   expect(placeholderFinder, findsOneWidget);
    // });

    testWidgets("tap_shouldTriggerOnTapFunction", (WidgetTester tester) async {
      await tester.pumpWidget(widget);
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets("heroTag_shouldExistsWithCorrectTag",
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
