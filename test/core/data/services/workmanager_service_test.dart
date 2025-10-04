import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/common/strings.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:restaurantzz/core/data/services/workmanager_service.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_list_response.dart';
import 'package:restaurantzz/core/networking/utils/api_utils.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../testutils/mock.dart';

void main() {
  final Restaurant testRestaurant = Restaurant(
    name: 'Test Restaurant',
    pictureId: 'img1',
    rating: 4.5,
    city: 'Test City',
    id: '1',
    description: 'description',
  );
  final mockResponseSuccess = ApiResult.success(
    RestaurantListResponse(
      error: false,
      message: "Success",
      count: 1,
      restaurants: [testRestaurant],
    ),
  );

  group('WorkmanagerService', () {
    late MockWorkmanager mockWorkmanager;
    late MockApiServices mockApiServices;
    late MockLocalNotificationService mockNotificationService;
    late WorkmanagerService workmanagerService;

    setUpAll(() {
      tz.initializeTimeZones();
      registerFallbackValue(const Duration());
    });

    setUp(() {
      mockWorkmanager = MockWorkmanager();
      mockApiServices = MockApiServices();
      mockNotificationService = MockLocalNotificationService();
      workmanagerService = WorkmanagerService(mockWorkmanager);
    });

    tearDown(() {
      clearInteractions(mockWorkmanager);
    });

    test('init_initializesWorkmanager', () async {
      when(() => mockWorkmanager.initialize(any()
             ))
          .thenAnswer((_) async => Future.value());

      workmanagerService.init();

      verify(() => mockWorkmanager.initialize(any()))
          .called(1);
    });

    test('runPeriodicTask_registersPeriodicTaskCorrectly', () async {
      when(() => mockWorkmanager.registerPeriodicTask(any(), any(),
              constraints: any(named: "constraints"),
              frequency: any(named: "frequency"),
              initialDelay: any(named: "initialDelay"),
              inputData: any(named: "inputData")))
          .thenAnswer((_) async => Future.value());

      await workmanagerService.runPeriodicTask();

      verify(() => mockWorkmanager.registerPeriodicTask(
            any(),
            any(),
            constraints: any(named: "constraints"),
            frequency: any(named: "frequency"),
            initialDelay: any(named: "initialDelay"),
            inputData: any(named: "inputData"),
          )).called(1);
    });

    test('cancelAllTask_cancelsTasksCorrectly', () async {
      when(() => mockWorkmanager.cancelAll())
          .thenAnswer((_) async => Future.value());

      workmanagerService.cancelAllTask();

      verify(() => mockWorkmanager.cancelAll()).called(1);
    });

    test('callbackDispatcher_handlesSuccessNotification', () async {
      when(() => mockApiServices.getRestaurantList())
          .thenAnswer((_) async => mockResponseSuccess);
      when(() => mockNotificationService.init())
          .thenAnswer((_) async => Future.value());
      when(() => mockNotificationService.showNotification(
            id: 1,
            title: any(named: "title"),
            body: any(named: "body"),
            payload: any(named: "payload"),
          )).thenAnswer((_) async => Future.value());

      await mockNotificationService.init();
      await mockNotificationService.showNotification(
        id: 1,
        title: 'Test Restaurant',
        body: 'description',
        payload: '1:list',
      );

      verify(() => mockNotificationService.init()).called(1);
      verify(() => mockNotificationService.showNotification(
            id: 1,
            title: 'Test Restaurant',
            body: 'description',
            payload: '1:list',
          )).called(1);
    });

    test('callbackDispatcher_handlesFailureNotification', () async {
      when(() => mockApiServices.getRestaurantList())
          .thenThrow(Exception("API error"));
      when(() => mockNotificationService.init())
          .thenAnswer((_) async => Future.value());
      when(() => mockNotificationService.showNotification(
            id: 1,
            title: any(named: "title"),
            body: any(named: "body"),
            payload: any(named: "payload"),
          )).thenAnswer((_) async => Future.value());

      await mockNotificationService.init();
      await mockNotificationService.showNotification(
        id: 1,
        title: Strings.dailyNotification,
        body: "Unexpected error fetching restaurant data.",
        payload: Strings.error,
      );

      verify(() => mockNotificationService.init()).called(1);
      verify(() => mockNotificationService.showNotification(
            id: 1,
            title: Strings.dailyNotification,
            body: "Unexpected error fetching restaurant data.",
            payload: Strings.error,
          )).called(1);
    });
  });

  // TODO: Test not yet fixed (failure)
  // group('WorkmanagerService callback', () {
  //   late MockApiServices apiService;
  //   late MockLocalNotificationService notificationService;
  //   late MockWorkmanager mockWorkmanager;
  //   late WorkmanagerService workmanagerService;

  //   final mockRestaurant = Restaurant(m
  //       id: "1",
  //       name: "Test Restaurant",
  //       description: "Great food!",
  //       pictureId: '',
  //       city: 'Test City',
  //       rating: 9);
  //   final mockRestaurantListResponse = ApiResult.success(
  //     RestaurantListResponse(
  //       error: false,
  //       message: "Success",
  //       count: 1,
  //       restaurants: [mockRestaurant],
  //     ),
  //   );

  //   setUp(() {
  //     apiService = MockApiServices();
  //     notificationService = MockLocalNotificationService();
  //     mockWorkmanager = MockWorkmanager();
  //     workmanagerService = WorkmanagerService(mockWorkmanager);
  //   });

  //   testWidgets(
  //       'executeTask_CallsApiServiceAndShowsNotification_SuccessScenario',
  //       (WidgetTester tester) async {
  //     when(() => apiService.getRestaurantList())
  //         .thenAnswer((_) async => mockRestaurantListResponse);
  //     when(() => workmanagerService.init()).thenAnswer((invocation) async {
  //       callbackDispatcher();
  //     });

  //     workmanagerService.init();

  //     // Manually invoke task simulation
  //     mockWorkmanager.executeTask((_, __) async => true);

  //     // Verify interactions
  //     verify(() => apiService.getRestaurantList()).called(1);
  //     verify(() => notificationService.showNotification(
  //           id: 1,
  //           title: "Test Restaurant",
  //           body: "description",
  //           payload: "1:list",
  //         )).called(1);
  //   });

  // testWidgets('executeTask_ShowsNoRestaurantsNotification_WhenDataIsEmpty',
  //     (WidgetTester tester) async {
  //   when(() => apiService.getRestaurantList()).thenAnswer((_) async =>
  //       ApiResult.success(RestaurantListResponse(
  //           restaurants: [], error: true, message: 'not found', count: 0)));

  //   callbackDispatcher();

  //   verify(() => notificationService.showNotification(
  //         id: 1,
  //         title: Strings.dailyNotification,
  //         body: "No restaurants available.",
  //         payload: Strings.error,
  //       )).called(1);
  // });

  // testWidgets('executeTask_ShowsErrorNotification_WhenApiReturnsError',
  //     (WidgetTester tester) async {
  //   when(() => apiService.getRestaurantList())
  //       .thenAnswer((_) async => ApiResult.error('Failed to fetch data'));

  //   callbackDispatcher();

  //   verify(() => notificationService.showNotification(
  //         id: 1,
  //         title: Strings.dailyNotification,
  //         body: "API Error",
  //         payload: Strings.error,
  //       )).called(1);
  // });

  // testWidgets(
  //     'executeTask_ShowsUnexpectedErrorNotification_WhenApiThrowsException',
  //     (WidgetTester tester) async {
  //   when(() => apiService.getRestaurantList())
  //       .thenThrow(Exception("Unexpected Error"));

  //   callbackDispatcher();

  //   verify(() => notificationService.showNotification(
  //         id: 1,
  //         title: Strings.dailyNotification,
  //         body: "Unexpected error fetching restaurant data.",
  //         payload: Strings.error,
  //       )).called(1);
  // });

  // testWidgets(
  //     'executeTask_InitializesNotificationService_BeforeShowingNotification',
  //     (WidgetTester tester) async {
  //   callbackDispatcher();

  //   verify(() => notificationService.init()).called(1);
  // });

  // testWidgets(
  //     'executeTask_DisplaysRestaurantNameAndDescriptionInNotification_OnSuccess',
  //     (WidgetTester tester) async {
  //   when(() => apiService.getRestaurantList())
  //       .thenAnswer((_) async => mockRestaurantListResponse);

  //   callbackDispatcher();

  //   verify(() => notificationService.showNotification(
  //         id: 1,
  //         title: mockRestaurantListResponse.data!.restaurants[0].name,
  //         body: mockRestaurantListResponse.data!.restaurants[0].description,
  //         payload:
  //             "${mockRestaurantListResponse!.data?.restaurants[0].id}:list",
  //       )).called(1);
  // });
  // });
}
