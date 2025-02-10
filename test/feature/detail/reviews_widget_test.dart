import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
import 'package:restaurantzz/feature/detail/screen/reviews_widget.dart';

import '../../testutils/test_helper.dart';

void main() {
  group('ReviewsWidget', () {
    final sampleReviews = [
      CustomerReview(
          name: 'Arif',
          review: 'Saya sangat suka menu malamnya!',
          date: '13 November 2019'),
      CustomerReview(
          name: 'Gilang',
          review: 'Harganya murah sekali!',
          date: '13 Juli 2019'),
    ];

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: ReviewsWidget(customerReviews: sampleReviews),
        ),
      );
    }

    testWidgets('renderReviewsWidget_showsReviewSection',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Reviews'), findsOneWidget);
    });

    testWidgets('tapSeeReviews_expandsAndDisplaysCustomerReviews',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final seeReviewsFinder = find.text('See Reviews');
      expect(seeReviewsFinder, findsOneWidget);

      await tester.tap(seeReviewsFinder);
      await tester.pumpAndSettle();

      expect(find.text('Arif'), findsOneWidget);
      expect(find.text('Gilang'), findsOneWidget);
    });

    testWidgets('renderCustomerReview_showsNameDateAndReview',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('See Reviews'));
      await tester.pumpAndSettle();

      expect(find.text('Arif'), findsOneWidget);
      expect(find.text('13 November 2019'), findsOneWidget);
      expect(find.text('Saya sangat suka menu malamnya!'), findsOneWidget);
    });

    testWidgets('tapReadMore_expandsTextAndDisplaysFullReview',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReviewsWidget(customerReviews: [
            CustomerReview(
                name: 'Gilang',
                review:
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                date: '14 Agustus 2018')
          ]),
        ),
      ));

      await tester.tap(find.text('See Reviews'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Lorem Ipsum is simply dummy text'),
          findsOneWidget);
    });

    testWidgets('tapShowLess_collapsesTextToOriginalState',
        (WidgetTester tester) async {
      ignoreNetworkImageErrors();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ReviewsWidget(customerReviews: [
            CustomerReview(
                name: 'Gilang',
                review:
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                date: '14 Agustus 2018')
          ]),
        ),
      ));

      await tester.tap(find.text('See Reviews'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('See Reviews'));
      await tester.pumpAndSettle();

      final showLessFinder = find.text('See Reviews');
      expect(showLessFinder, findsOneWidget);

      await tester.tap(showLessFinder);
      await tester.pumpAndSettle();

      expect(find.text('See Reviews'), findsOneWidget);
    });
  });
}
