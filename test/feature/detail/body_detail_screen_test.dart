import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/data/local/local_database_service.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
import 'package:restaurantzz/core/provider/detail/favorite_icon_provider.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';
import 'package:restaurantzz/feature/detail/screen/body_detail_screen.dart';
import 'package:restaurantzz/feature/detail/screen/review_form_widget.dart';

void main() {
  group('BodyDetailScreen', () {
    final sampleRestaurantDetailItem = RestaurantDetailItem(
      id: '1',
      name: 'Sample Restaurant',
      description:
          "Lorem ipsum odor amet, consectetuer adipiscing elit. Pellentesque class iaculis sociosqu volutpat conubia. Luctus lacus consequat litora sociosqu curabitur. Ullamcorper at mollis vulputate ullamcorper ultricies quam. Gravida blandit ex viverra dis, lobortis congue odio aliquam lectus. Vehicula potenti luctus lobortis eleifend sit nisi. Risus natoque vehicula dictumst rhoncus inceptos augue vel. Congue fames semper tempus felis fringilla ante quis curae. Ex eu interdum parturient massa facilisi fames magna. Elementum ultricies finibus neque mollis porttitor natoque in suspendisse nunc.",
      city: 'Sample City',
      address: '123 Sample Street',
      pictureId: 'sample_picture',
      categories: [Category(name: 'Italian'), Category(name: 'Fancy')],
      menus: Menu(
        foods: [Category(name: 'Pasta'), Category(name: 'Pizza')],
        drinks: [Category(name: 'Coffee'), Category(name: 'Wine')],
      ),
      rating: 4.5,
      customerReviews: [
        CustomerReview(
            name: 'Gilang',
            review: 'Harganya murah sekali!',
            date: '13 Juli 2019'),
        CustomerReview(
            name: 'Rafli', review: 'reviewnya bagus!', date: '9 Februari 2025'),
      ],
    );

    Widget createWidgetUnderTest() {
      return MultiProvider(
        providers: [
          Provider(
            create: (context) => LocalDatabaseService(),
          ),
          ChangeNotifierProvider(
            create: (context) => LocalDatabaseProvider(
              context.read<LocalDatabaseService>(),
            ),
          ),
          ChangeNotifierProvider(create: (_) => FavoriteIconProvider())
        ],
        child: MaterialApp(
          home: Scaffold(
            body: BodyDetailScreen(
              restaurantDetailItem: sampleRestaurantDetailItem,
              heroTag: 'heroTag1',
            ),
          ),
        ),
      );
    }

    testWidgets('displayRestaurantInformation_correctlyShowsNameRatingAddress',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Sample Restaurant'), findsOneWidget);
      expect(find.textContaining('4.5'), findsOneWidget);
      expect(find.text('123 Sample Street, Sample City'), findsOneWidget);
    });

    testWidgets('renderRestaurantCategories_displaysChips',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Chip), findsNWidgets(2));
      expect(find.text('Italian'), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);
    });

    // TODO: Not yet tested
    // testWidgets('tapReadMore_expandsDescriptionText',
    //     (WidgetTester tester) async {
    //   await tester.pumpWidget(createWidgetUnderTest());

    //   // Find the ReadMoreText widget
    //   final readMoreFinder = find.byType(ReadMoreText);

    //   // Ensure the button is valid and visible
    //   await tester.ensureVisible(readMoreFinder);
    //   await tester.pumpAndSettle();

    //   // Tap the ReadMoreText to expand the description
    //   await tester.tap(readMoreFinder);
    //   await tester.pumpAndSettle();

    //   // Scroll to ensure the expanded text is visible
    //   await tester.drag(
    //     find.byType(SingleChildScrollView).first,
    //     const Offset(0, -500),
    //   );
    //   await tester.pumpAndSettle();

    //   // Verify expanded text is shown
    //   expect(find.textContaining('porttitor natoque in suspendisse nunc.'),
    //       findsOneWidget);
    // });

    testWidgets('displayMenus_showsFoodsAndDrinks',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Foods'), findsOneWidget);
      expect(find.text('Drinks'), findsOneWidget);
      expect(find.text('Pasta'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('renderReviewsWidget_displaysCustomerReviews',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.ensureVisible(find.text('See Reviews'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See Reviews'));

      await tester.drag(
          find.byType(SingleChildScrollView).first, const Offset(0, -700));
      await tester.pumpAndSettle();

      expect(find.text('Gilang'), findsOneWidget);
      expect(find.text('Harganya murah sekali!'), findsOneWidget);
      expect(find.text('Rafli'), findsOneWidget);
    });

    testWidgets('showReviewForm_displaysReviewForm',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ReviewForm), findsOneWidget);
    });
  });
}
