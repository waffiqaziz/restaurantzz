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
      when(() => mockWorkmanager.initialize(any())).thenAnswer((_) async => Future.value());

      workmanagerService.init();

      verify(() => mockWorkmanager.initialize(any())).called(1);
    });

    test('runPeriodicTask_registersPeriodicTaskCorrectly', () async {
      when(
        () => mockWorkmanager.registerPeriodicTask(
          any(),
          any(),
          constraints: any(named: "constraints"),
          frequency: any(named: "frequency"),
          initialDelay: any(named: "initialDelay"),
          inputData: any(named: "inputData"),
        ),
      ).thenAnswer((_) async => Future.value());

      await workmanagerService.runPeriodicTask();

      verify(
        () => mockWorkmanager.registerPeriodicTask(
          any(),
          any(),
          constraints: any(named: "constraints"),
          frequency: any(named: "frequency"),
          initialDelay: any(named: "initialDelay"),
          inputData: any(named: "inputData"),
        ),
      ).called(1);
    });

    test('runOneTask_registerOneOffTaskCorrectly', () async {
      when(
        () => mockWorkmanager.registerOneOffTask(
          any(),
          any(),
          constraints: any(named: "constraints"),
          initialDelay: any(named: "initialDelay"),
          inputData: any(named: "inputData"),
        ),
      ).thenAnswer((_) async => Future.value());

      await workmanagerService.runOneTask();

      verify(
        () => mockWorkmanager.registerOneOffTask(
          any(),
          any(),
          constraints: any(named: "constraints"),
          initialDelay: any(named: "initialDelay"),
          inputData: any(named: "inputData"),
        ),
      ).called(1);
    });

    test('cancelAllTask_cancelsTasksCorrectly', () async {
      when(() => mockWorkmanager.cancelAll()).thenAnswer((_) async => Future.value());

      workmanagerService.cancelAllTask();

      verify(() => mockWorkmanager.cancelAll()).called(1);
    });

    test('callbackDispatcher_handlesSuccessNotification', () async {
      when(() => mockApiServices.getRestaurantList()).thenAnswer((_) async => mockResponseSuccess);
      when(() => mockNotificationService.init()).thenAnswer((_) async => Future.value());
      when(
        () => mockNotificationService.showNotification(
          id: 1,
          title: any(named: "title"),
          body: any(named: "body"),
          payload: any(named: "payload"),
        ),
      ).thenAnswer((_) async => Future.value());

      await mockNotificationService.init();
      await mockNotificationService.showNotification(
        id: 1,
        title: 'Test Restaurant',
        body: 'description',
        payload: '1:list',
      );

      verify(() => mockNotificationService.init()).called(1);
      verify(
        () => mockNotificationService.showNotification(
          id: 1,
          title: 'Test Restaurant',
          body: 'description',
          payload: '1:list',
        ),
      ).called(1);
    });

    test('callbackDispatcher_handlesFailureNotification', () async {
      when(() => mockApiServices.getRestaurantList()).thenThrow(Exception("API error"));
      when(() => mockNotificationService.init()).thenAnswer((_) async => Future.value());
      when(
        () => mockNotificationService.showNotification(
          id: 1,
          title: any(named: "title"),
          body: any(named: "body"),
          payload: any(named: "payload"),
        ),
      ).thenAnswer((_) async => Future.value());

      await mockNotificationService.init();
      await mockNotificationService.showNotification(
        id: 1,
        title: Strings.dailyNotification,
        body: "Unexpected error fetching restaurant data.",
        payload: Strings.error,
      );

      verify(() => mockNotificationService.init()).called(1);
      verify(
        () => mockNotificationService.showNotification(
          id: 1,
          title: Strings.dailyNotification,
          body: "Unexpected error fetching restaurant data.",
          payload: Strings.error,
        ),
      ).called(1);
    });
  });

  group('runDailyRestaurantTask', () {
    late MockApiServices apiService;
    late MockLocalNotificationService notificationService;

    final mockRestaurant = Restaurant(
      id: "1",
      name: "Test Restaurant",
      description: "Great food!",
      pictureId: '',
      city: 'Test City',
      rating: 9,
    );

    setUp(() {
      apiService = MockApiServices();
      notificationService = MockLocalNotificationService();
      when(() => notificationService.init()).thenAnswer((_) async {});
      when(
        () => notificationService.showNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) async {});
    });

    test('restairant_onSuccess_returnsTrueAndShowsNotification ', () async {
      when(() => apiService.getRestaurantList()).thenAnswer(
        (_) async => ApiResult.success(
          RestaurantListResponse(
            error: false,
            message: "Success",
            count: 1,
            restaurants: [mockRestaurant],
          ),
        ),
      );

      final result = await runDailyRestaurantTask(
        apiService: apiService,
        notificationService: notificationService,
      );

      expect(result, true);
      verify(() => notificationService.init()).called(1);
      verify(
        () => notificationService.showNotification(
          id: any(named: 'id'),
          title: "Daily Restaurant Recommendation",
          body: "Try Test Restaurant - Great food!",
          payload: "1:list",
        ),
      ).called(1);
    });

    test('restaurantList_isEmpty_returnsFalse', () async {
      when(() => apiService.getRestaurantList()).thenAnswer(
        (_) async => ApiResult.success(
          RestaurantListResponse(error: true, message: 'not found', count: 0, restaurants: []),
        ),
      );

      final result = await runDailyRestaurantTask(
        apiService: apiService,
        notificationService: notificationService,
      );

      expect(result, false);
      verifyNever(
        () => notificationService.showNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
        ),
      );
    });

    test('apiErrors_returnsFalse', () async {
      when(() => apiService.getRestaurantList())
          .thenAnswer((_) async => ApiResult.error('Failed to fetch data'));

      final result = await runDailyRestaurantTask(
        apiService: apiService,
        notificationService: notificationService,
      );

      expect(result, false);
      verifyNever(
        () => notificationService.showNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          payload: any(named: 'payload'),
        ),
      );
    });

    test('apiThrows_returnsFalse', () async {
      when(() => apiService.getRestaurantList()).thenThrow(Exception("Unexpected Error"));

      final result = await runDailyRestaurantTask(
        apiService: apiService,
        notificationService: notificationService,
      );

      expect(result, false);
    });
  });
}
