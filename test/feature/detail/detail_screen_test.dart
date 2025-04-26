import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/local/local_database_service.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/states/detail_result_state.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';
import 'package:restaurantzz/core/provider/detail/favorite_icon_provider.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';
import 'package:restaurantzz/feature/detail/screen/detail_screen.dart';

import '../../testutils/mock.dart';

void main() {
  late MockApiServices mockApiServices;
  late MockDetailProvider mockDetailProvider;
  late MockLocalDatabaseProvider mockLocalDatabaseProvider;
  late MockLocalDatabaseService mockLocalDatabaseService;
  late MockFavoriteIconProvider mockFavoriteIconProvider;

  final mockData = RestaurantDetailItem(
    id: '123',
    name: 'Test Restaurant',
    description: 'Test Description',
    city: 'Test City',
    address: 'Test Address',
    pictureId: 'test.jpg',
    categories: [],
    menus: Menu(drinks: [], foods: []),
    rating: 4.5,
    customerReviews: [],
  );

  setUp(() {
    mockApiServices = MockApiServices();
    mockDetailProvider = MockDetailProvider();
    mockLocalDatabaseProvider = MockLocalDatabaseProvider();
    mockLocalDatabaseService = MockLocalDatabaseService();
    mockFavoriteIconProvider = MockFavoriteIconProvider();

    // ensure all not null
    when(() => mockDetailProvider.isReviewSubmissionComplete).thenReturn(false);
    when(() => mockDetailProvider.isReviewSubmission).thenReturn(false);
    when(() => mockDetailProvider.reviewSubmissionError).thenReturn(null);
    when(() => mockDetailProvider.resultState)
        .thenReturn(RestaurantDetailLoadingState());
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        Provider<ApiServices>.value(
          value: mockApiServices,
        ),
        ChangeNotifierProvider<LocalDatabaseProvider>.value(
          value: mockLocalDatabaseProvider,
        ),
        ChangeNotifierProvider<DetailProvider>.value(
          value: mockDetailProvider,
        ),
        Provider<LocalDatabaseService>.value(
          value: mockLocalDatabaseService,
        ),
        ChangeNotifierProvider<LocalDatabaseProvider>.value(
          value: mockLocalDatabaseProvider,
        ),
        ChangeNotifierProvider<FavoriteIconProvider>.value(
          value: mockFavoriteIconProvider,
        )
      ],
      child: MaterialApp(
        home: Scaffold(
          body: DetailScreen(
            restaurantId: '123',
            heroTag: '123:list',
          ),
        ),
      ),
    );
  }

  testWidgets('fetchRestaurantDetail_calledOnDetailScreenInitial',
      (WidgetTester tester) async {
    when(() => mockDetailProvider.resultState)
        .thenReturn(RestaurantDetailLoadingState());
    when(() => mockDetailProvider.fetchRestaurantDetail(any()))
        .thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    verify(() => mockDetailProvider.fetchRestaurantDetail('123')).called(1);
  });

  testWidgets('renderBodyDetailScreen_displaysHeroImage',
      (WidgetTester tester) async {
    when(() => mockDetailProvider.fetchRestaurantDetail(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDatabaseProvider.loadRestaurantById(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDatabaseProvider.checkItemBookmark(any()))
        .thenReturn(false);
    when(() => mockFavoriteIconProvider.isFavorite).thenReturn(false);
    when(() => mockFavoriteIconProvider.loadFavoriteState(
        mockLocalDatabaseProvider, any())).thenAnswer((_) async {});

    when(() => mockDetailProvider.resultState)
        .thenReturn(RestaurantDetailLoadedState(mockData));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(Hero), findsOneWidget);
  });

  testWidgets('loadingIndicator_showWhenStateIsLoading',
      (WidgetTester tester) async {
    when(() => mockDetailProvider.fetchRestaurantDetail(any()))
        .thenAnswer((_) async {});
    when(() => mockDetailProvider.resultState)
        .thenReturn(RestaurantDetailLoadingState());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('errorMessage_showWhenStateIsError', (WidgetTester tester) async {
    when(() => mockDetailProvider.fetchRestaurantDetail(any()))
        .thenAnswer((_) async {});
    when(() => mockDetailProvider.resultState)
        .thenReturn(RestaurantDetailErrorState('Something went wrong', '123'));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('showRestaurantDetails_whenStateIsLoaded',
      (WidgetTester tester) async {
    when(() => mockDetailProvider.fetchRestaurantDetail(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDatabaseProvider.loadRestaurantById(any()))
        .thenAnswer((_) async {});
    when(() => mockLocalDatabaseProvider.checkItemBookmark(any()))
        .thenReturn(false);
    when(() => mockFavoriteIconProvider.isFavorite).thenReturn(false);
    when(() => mockFavoriteIconProvider.loadFavoriteState(
        mockLocalDatabaseProvider, any())).thenAnswer((_) async {});

    when(() => mockDetailProvider.resultState)
        .thenReturn(RestaurantDetailLoadedState(mockData));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Test Restaurant'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
  });

  testWidgets('showSnackbarWithErrorMessage_whenReviewSubmissionFails',
      (WidgetTester tester) async {
    when(() => mockDetailProvider.fetchRestaurantDetail(any()))
        .thenAnswer((_) async {});
    when(() => mockDetailProvider.isReviewSubmissionComplete).thenReturn(true);
    when(() => mockDetailProvider.reviewSubmissionError)
        .thenReturn("Failed to submit review");

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text("Failed to submit review"), findsOneWidget);
    verify(() => mockDetailProvider.resetReviewSubmissionState()).called(1);
  });

  testWidgets('showSnackbarWithSuccessMessage_whenReviewSubmissionSucceeds',
      (WidgetTester tester) async {
    when(() => mockDetailProvider.fetchRestaurantDetail(any()))
        .thenAnswer((_) async {});
    when(() => mockDetailProvider.isReviewSubmissionComplete).thenReturn(true);
    when(() => mockDetailProvider.reviewSubmissionError).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text(Strings.submitReviewSuccess), findsOneWidget);
    verify(() => mockDetailProvider.resetReviewSubmissionState()).called(1);
  });

  testWidgets(
      'showLoadingOverlay_whenReviewSubmissionIsInProgress_alsoWhenStateIsLoaded',
      (WidgetTester tester) async {
    when(() => mockDetailProvider.isReviewSubmission).thenReturn(true);
    when(() => mockDetailProvider.fetchRestaurantDetail(any()))
        .thenAnswer((_) async {});
    when(() => mockDetailProvider.resultState)
        .thenReturn(RestaurantDetailLoadedState(mockData));
    when(() => mockFavoriteIconProvider.isFavorite).thenReturn(false);
    when(() => mockFavoriteIconProvider.loadFavoriteState(
        mockLocalDatabaseProvider, any())).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Container &&
            widget.color == Colors.black.withValues(alpha: 0.3)),
        findsOneWidget);
  });

  testWidgets('retryButton_callsFetchRestaurantDetailOnPressed',
      (WidgetTester tester) async {
    when(() => mockDetailProvider.resultState)
        .thenReturn(RestaurantDetailErrorState('Error loading details', '123'));
    when(() => mockDetailProvider.fetchRestaurantDetail(any()))
        .thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text(Strings.retry), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // called two times: once on initial load and once on retry button press
    verify(() => mockDetailProvider.fetchRestaurantDetail('123')).called(2);
  });

  // TODO: Not yet tested press to close the detail screen
  // testWidgets('iconButton_navigatesBackOnPressed', (WidgetTester tester) async {
  //   when(() => mockDetailProvider.isReviewSubmission).thenReturn(true);
  //   when(() => mockDetailProvider.fetchRestaurantDetail(any()))
  //       .thenAnswer((_) async {});
  //   when(() => mockDetailProvider.resultState)
  //       .thenReturn(RestaurantDetailLoadedState(mockData));
  //   when(() => mockFavoriteIconProvider.isFavorite).thenReturn(false);
  //   when(() => mockFavoriteIconProvider.loadFavoriteState(
  //       mockLocalDatabaseProvider, any())).thenAnswer((_) async {});
  //   await tester.pumpWidget(createWidgetUnderTest());
  //   await tester.pumpAndSettle();

  //   await tester.tap(find.byType(CircleAvatar).first);
  //   await tester.pumpAndSettle();

  //   expect(find.byType(DetailScreen), findsNothing);
  // });

  // TODO: Not yet tested pull to refresh detail screen
  // testWidgets('refreshRestaurantDetails_whenPulledToRefresh',
  //     (WidgetTester tester) async {
  //   // Stub `fetchRestaurantDetail`
  //   when(() => mockDetailProvider.fetchRestaurantDetail(any(),
  //       refresh: any(named: 'refresh'))).thenAnswer((_) async {
  //     // Simulate Loading State
  //     when(() => mockDetailProvider.resultState)
  //         .thenReturn(RestaurantDetailLoadingState());
  //     mockDetailProvider.notifyListeners(); // Notify UI of loading

  //     // Simulate Loaded State after delay
  //     when(() => mockDetailProvider.resultState).thenReturn(
  //       RestaurantDetailLoadedState(
  //         RestaurantDetailItem(
  //           id: '123',
  //           name: 'Test Restaurant',
  //           description: '',
  //           city: '',
  //           address: '',
  //           pictureId: '',
  //           categories: [],
  //           menus: Menu(foods: [], drinks: []),
  //           rating: 9,
  //           customerReviews: [],
  //         ),
  //       ),
  //     );
  //     mockDetailProvider.notifyListeners(); // Notify UI of new data
  //   });

  //   await tester.pumpWidget(createWidgetUnderTest());

  //   // Simulate pull-to-refresh
  //   await tester.drag(find.byType(ListView), const Offset(0, 300));
  //   await tester.pump(); // Start refresh animation
  //   await tester.pumpAndSettle(); // Wait for UI to settle

  //   // Verify `fetchRestaurantDetail` was called with `refresh: true`
  //   verify(() => mockDetailProvider.fetchRestaurantDetail('123', refresh: true))
  //       .called(1);
  // });

  // testWidgets('showLoadingOverlay_whenReviewSubmissionIsInProgress',
  //     (WidgetTester tester) async {
  //   when(() => mockDetailProvider.isReviewSubmission).thenReturn(true);

  //   await tester.pumpWidget(createWidgetUnderTest());
  //   await tester.pump();

  //   expect(find.byType(CircularProgressIndicator), findsOneWidget);
  //   expect(find.byType(Container), findsWidgets);
  // });
}
