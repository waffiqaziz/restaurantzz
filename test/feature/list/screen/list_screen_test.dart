import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_list_response.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/utils/api_utils.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';
import 'package:restaurantzz/core/provider/list/list_provider.dart';
import 'package:restaurantzz/feature/detail/screen/detail_screen.dart';
import 'package:restaurantzz/feature/list/screen/list_screen.dart';
import 'package:restaurantzz/static/navigation_route.dart';

import '../../../testutils/mock.dart';
import '../../../testutils/test_helper.dart';

void main() {
  group('ListScreen', () {
    final mockResponse = ApiResult.success(
      RestaurantListResponse(
        error: false,
        message: "Success",
        count: 1,
        restaurants: [
          Restaurant(
            name: 'Test Restaurant',
            pictureId: 'img1',
            rating: 4.5,
            city: 'Test City',
            id: '1',
            description: 'description',
          ),
        ],
      ),
    );

    final mockResponseMany = ApiResult.success(
      RestaurantListResponse(
        error: false,
        message: "Success",
        count: 99,
        restaurants: List.generate(
          99,
          (index) => Restaurant(
            name: 'Test Restaurant ${index + 1}',
            pictureId: 'img${index + 1}',
            rating: 4.5,
            city: 'Test City ${index + 1}',
            id: '${index + 1}',
            description: 'description ${index + 1}',
          ),
        ),
      ),
    );

    late ListProvider listProvider;
    late MockApiServices mockApiServices;

    setUp(() {
      mockApiServices = MockApiServices();
      listProvider = ListProvider(mockApiServices);
    });

    // helper to create the widget
    Widget createTestWidget(Widget child) {
      return ChangeNotifierProvider<ListProvider>.value(
        value: listProvider,
        child: MaterialApp(
          home: child,
          onGenerateRoute: (settings) {
            if (settings.name == NavigationRoute.detailRoute.name) {
              final arguments = settings.arguments as Map<String, String>;
              return MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) =>
                      DetailProvider(ApiServices(httpClient: http.Client())),
                  child: DetailScreen(
                    restaurantId: arguments['restaurantId']!,
                    heroTag: arguments['heroTag']!,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      );
    }

    testWidgets('loadingIndicator_shouldShowsWhenInitialScreen',
        (WidgetTester tester) async {
      when(() => mockApiServices.getRestaurantList()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return mockResponse;
      });

      await tester.pumpWidget(createTestWidget(const ListScreen()));

      // trigger a frame to show the loading state
      await tester.pump();

      // checks loading shows up/not.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // pump out the remaining frames
      await tester.pumpAndSettle();
    });

    testWidgets('scrollingUntilLastItem_shouldShowsTheLastItem',
        (WidgetTester tester) async {
      when(() => mockApiServices.getRestaurantList())
          .thenAnswer((_) async => mockResponseMany);

      await tester.pumpWidget(createTestWidget(const ListScreen()));
      await tester.pumpAndSettle();

      // initial item check
      expect(find.text('Test Restaurant 1'), findsOneWidget);

      // check restaurant 99 rendered or not
      expect(find.text('Test Restaurant 99'), findsNothing);

      // perform scroll to reveal the last item
      await tester.drag(find.byType(ListView), const Offset(0, -9000));

      await tester.pumpAndSettle();

      expect(find.text('Test Restaurant 99'), findsOneWidget);
    });

    testWidgets('dataSuccessfullyVetched_shouldDisplaysRestaurantList',
        (WidgetTester tester) async {
      when(() => mockApiServices.getRestaurantList())
          .thenAnswer((_) async => mockResponse);

      await tester.pumpWidget(createTestWidget(const ListScreen()));
      listProvider.fetchRestaurantList();
      await tester.pumpAndSettle();

      expect(find.text('Test Restaurant'), findsOneWidget);
      expect(find.text('(4.5/5.0)'), findsOneWidget);
    });

    testWidgets('fetchingDataFails_shuoldDisplaysErrorMessage',
        (WidgetTester tester) async {
      when(() => mockApiServices.getRestaurantList())
          .thenAnswer((_) async => ApiResult.error('Failed to fetch data'));

      await tester.pumpWidget(createTestWidget(const ListScreen()));
      listProvider.fetchRestaurantList();
      await tester.pumpAndSettle();

      // Assert error message is displayed
      expect(find.text('Failed to fetch data'), findsOneWidget);
    });

    testWidgets('pullToRefresh_shouldTriggersFetchRestaurantList()',
        (WidgetTester tester) async {
      when(() => mockApiServices.getRestaurantList())
          .thenAnswer((_) async => mockResponse);

      await tester.pumpWidget(createTestWidget(const ListScreen()));
      await tester.pumpAndSettle(); // wait untill initial load complete

      // trigger pull-to-refresh
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();

      // verivy API call triggered twice: one for initially, and one for pull-to-refresh
      verify(() => mockApiServices.getRestaurantList()).called(2);
    });

    testWidgets('tappingOnItem_shouldNavigateToDetailScreen',
        (WidgetTester tester) async {
      ignoreNetworkImageErrors(); // disable unrelated error because this test case to test navigation
      when(() => mockApiServices.getRestaurantList())
          .thenAnswer((_) async => mockResponse);

      await tester.pumpWidget(createTestWidget(const ListScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Restaurant'));
      await tester.pumpAndSettle();

      // Check if the DetailScreen is displayed
      expect(find.byType(DetailScreen), findsOneWidget);
    });
  });
}
