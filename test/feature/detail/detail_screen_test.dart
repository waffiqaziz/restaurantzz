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
import 'package:restaurantzz/core/provider/detail/detail_view_state.dart';
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
    when(
      () => mockDetailProvider.viewStateOf('123'),
    ).thenReturn(DetailViewState(resultState: RestaurantDetailLoadingState()));
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        Provider<ApiServices>.value(value: mockApiServices),
        ChangeNotifierProvider<LocalDatabaseProvider>.value(value: mockLocalDatabaseProvider),
        ChangeNotifierProvider<DetailProvider>.value(value: mockDetailProvider),
        Provider<LocalDatabaseService>.value(value: mockLocalDatabaseService),
        ChangeNotifierProvider<LocalDatabaseProvider>.value(value: mockLocalDatabaseProvider),
        ChangeNotifierProvider<FavoriteIconProvider>.value(value: mockFavoriteIconProvider),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: DetailScreen(restaurantId: '123', heroTag: '123:list'),
        ),
      ),
    );
  }

  testWidgets('fetchRestaurantDetail_calledOnDetailScreenInitial', (tester) async {
    when(() => mockDetailProvider.fetchRestaurantDetail(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    verify(() => mockDetailProvider.fetchRestaurantDetail('123')).called(1);
  });

  testWidgets('renderBodyDetailScreen_displaysHeroImage', (WidgetTester tester) async {
    when(() => mockDetailProvider.fetchRestaurantDetail(any())).thenAnswer((_) async {});
    when(() => mockLocalDatabaseProvider.loadRestaurantById(any())).thenAnswer((_) async {});
    when(() => mockLocalDatabaseProvider.checkItemBookmark(any())).thenReturn(false);
    when(() => mockFavoriteIconProvider.isFavorite).thenReturn(false);
    when(
      () => mockFavoriteIconProvider.loadFavoriteState(mockLocalDatabaseProvider, any()),
    ).thenAnswer((_) async {});
    when(
      () => mockDetailProvider.viewStateOf('123'),
    ).thenReturn(DetailViewState(resultState: RestaurantDetailLoadedState(mockData)));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(Hero), findsOneWidget);

    // simulate tap
    final backButton = find.byKey(const Key('back_button'));
    await tester.tap(backButton);
  });

  testWidgets('loadingIndicator_showWhenStateIsLoading', (WidgetTester tester) async {
    when(() => mockDetailProvider.fetchRestaurantDetail(any())).thenAnswer((_) async {});
    when(
      () => mockDetailProvider.viewStateOf('123'),
    ).thenReturn(DetailViewState(resultState: RestaurantDetailLoadingState()));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('errorMessage_showWhenStateIsError', (tester) async {
    when(() => mockDetailProvider.viewStateOf('123')).thenReturn(
      DetailViewState(resultState: RestaurantDetailErrorState('Something went wrong', '123')),
    );

    when(() => mockDetailProvider.fetchRestaurantDetail(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Something went wrong'), findsOneWidget);
  });

  testWidgets('showRestaurantDetails_whenStateIsLoaded', (WidgetTester tester) async {
    when(() => mockDetailProvider.fetchRestaurantDetail(any())).thenAnswer((_) async {});
    when(() => mockLocalDatabaseProvider.loadRestaurantById(any())).thenAnswer((_) async {});
    when(() => mockLocalDatabaseProvider.checkItemBookmark(any())).thenReturn(false);
    when(() => mockFavoriteIconProvider.isFavorite).thenReturn(false);
    when(
      () => mockFavoriteIconProvider.loadFavoriteState(mockLocalDatabaseProvider, any()),
    ).thenAnswer((_) async {});

    when(
      () => mockDetailProvider.viewStateOf('123'),
    ).thenReturn(DetailViewState(resultState: RestaurantDetailLoadedState(mockData)));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Test Restaurant'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
  });

  testWidgets('pullToRefresh_callsRefreshFunction', (WidgetTester tester) async {
    when(
      () => mockDetailProvider.fetchRestaurantDetail(any(), refresh: any(named: 'refresh')),
    ).thenAnswer((_) async {});
    when(() => mockLocalDatabaseProvider.loadRestaurantById(any())).thenAnswer((_) async {});
    when(() => mockLocalDatabaseProvider.checkItemBookmark(any())).thenReturn(false);
    when(() => mockFavoriteIconProvider.isFavorite).thenReturn(false);
    when(
      () => mockFavoriteIconProvider.loadFavoriteState(mockLocalDatabaseProvider, any()),
    ).thenAnswer((_) async {});

    when(
      () => mockDetailProvider.viewStateOf('123'),
    ).thenReturn(DetailViewState(resultState: RestaurantDetailLoadedState(mockData)));

    await tester.pumpWidget(createWidgetUnderTest());

    final refreshListFinder = find.byKey(const Key('detail_refresh_list'));
    expect(refreshListFinder, findsOneWidget);

    expect(refreshListFinder, findsOneWidget);

    await tester.drag(refreshListFinder, const Offset(0, 300));
    await tester.pumpAndSettle();

    verify(() => mockDetailProvider.fetchRestaurantDetail(any())).called(1);
  });

  testWidgets('showSnackbarWithErrorMessage_whenReviewSubmissionFails', (
    WidgetTester tester,
  ) async {
    when(
      () => mockFavoriteIconProvider.loadFavoriteState(mockLocalDatabaseProvider, any()),
    ).thenAnswer((_) async {});
    when(() => mockFavoriteIconProvider.isFavorite).thenReturn(false);
    when(() => mockDetailProvider.fetchRestaurantDetail(any())).thenAnswer((_) async {});
    when(() => mockDetailProvider.viewStateOf('123')).thenReturn(
      DetailViewState(
        resultState: RestaurantDetailLoadedState(mockData),
        reviewCompleted: true,
        reviewError: 'Failed to submit review',
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text("Failed to submit review"), findsOneWidget);
    verify(() => mockDetailProvider.resetReviewSubmissionState('123')).called(1);
  });

  testWidgets('showSnackbarWithSuccessMessage_whenReviewSubmissionSucceeds', (
    WidgetTester tester,
  ) async {
    when(
      () => mockFavoriteIconProvider.loadFavoriteState(mockLocalDatabaseProvider, any()),
    ).thenAnswer((_) async {});
    when(() => mockFavoriteIconProvider.isFavorite).thenReturn(false);
    when(() => mockDetailProvider.fetchRestaurantDetail(any())).thenAnswer((_) async {});
    when(() => mockDetailProvider.viewStateOf('123')).thenReturn(
      DetailViewState(
        resultState: RestaurantDetailLoadedState(mockData),
        reviewCompleted: true,
        reviewError: null,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text(Strings.submitReviewSuccess), findsOneWidget);
    verify(() => mockDetailProvider.resetReviewSubmissionState('123')).called(1);
  });

  testWidgets('showLoadingOverlay_whenReviewSubmissionIsInProgress_alsoWhenStateIsLoaded', (
    WidgetTester tester,
  ) async {
    when(() => mockDetailProvider.fetchRestaurantDetail(any())).thenAnswer((_) async {});
    when(() => mockDetailProvider.viewStateOf('123')).thenReturn(
      DetailViewState(resultState: RestaurantDetailLoadedState(mockData), isSubmittingReview: true),
    );
    when(() => mockFavoriteIconProvider.isFavorite).thenReturn(false);
    when(
      () => mockFavoriteIconProvider.loadFavoriteState(mockLocalDatabaseProvider, any()),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Container && widget.color == Colors.black.withValues(alpha: 0.3),
      ),
      findsOneWidget,
    );
  });

  testWidgets('retryButton_callsFetchRestaurantDetailOnPressed', (WidgetTester tester) async {
    when(() => mockDetailProvider.viewStateOf('123')).thenReturn(
      DetailViewState(resultState: RestaurantDetailErrorState('Error loading details', '123')),
    );
    when(() => mockDetailProvider.fetchRestaurantDetail(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text(Strings.retry), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // called two times: once on initial load and once on retry button press
    verify(() => mockDetailProvider.fetchRestaurantDetail('123')).called(2);
  });
}
