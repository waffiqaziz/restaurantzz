import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';
import 'package:restaurantzz/feature/detail/screen/review_form_widget.dart';

import '../../testutils/mock.dart';

void main() {
  group("ReviewFormWidget", () {
    late MockDetailProvider mockProvider;

    setUp(() {
      mockProvider = MockDetailProvider();
    });

    Widget createWidgetUnderTest() {
      return ChangeNotifierProvider<DetailProvider>.value(
        value: mockProvider,
        child: MaterialApp(
          home: Scaffold(body: ReviewForm(restaurantId: '123')),
        ),
      );
    }

    testWidgets('rendersReviewForm_UIElements', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Add a Review'), findsOneWidget);
      expect(find.text('Your Name'), findsOneWidget);
      expect(find.text('Your Review'), findsOneWidget);
      expect(find.text('Submit Review'), findsOneWidget);
    });

    testWidgets('reviewAndNameEmpty_showsError', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Submit Review'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Review is required'), findsOneWidget);
    });

    testWidgets('emptyReview_showsError', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).first, 'Aziz'); // get name field
      await tester.tap(find.text('Submit Review'));
      await tester.pump();

      expect(find.text('Review is required'), findsOneWidget);
    });

    testWidgets('emptyName_showsError', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).last, 'Good food'); // get review field
      await tester.tap(find.text('Submit Review'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('submitsValidForm_callsAddReview', (WidgetTester tester) async {
      when(() => mockProvider.addReview(any(), any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).first, 'Waffiq');
      await tester.enterText(
        find.byType(TextFormField).last,
        'Great food, not pricey, but very taste',
      );

      await tester.tap(find.text('Submit Review'));
      await tester.pump();

      verify(
        () => mockProvider.addReview('123', 'Waffiq', 'Great food, not pricey, but very taste'),
      ).called(1);
    });

    testWidgets('submitReview_clearTheTextForm', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      when(() => mockProvider.addReview(any(), any(), any())).thenAnswer((_) async {});

      await tester.enterText(find.byType(TextFormField).first, 'Badrul');
      await tester.enterText(find.byType(TextFormField).last, 'GG, nice');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Badrul'), findsNothing);
      expect(find.text('GG, nice'), findsNothing);
    });
  });
}
