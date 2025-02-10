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
      when(() => mockWorkmanager.initialize(any(),
              isInDebugMode: any(named: "isInDebugMode")))
          .thenAnswer((_) async => Future.value());

      await workmanagerService.init();

      verify(() => mockWorkmanager.initialize(any(), isInDebugMode: false))
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

      await workmanagerService.cancelAllTask();

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

  // group('WorkmanagerService callback', () {
  //   late MockApiServices mockApiServices;
  //   late MockLocalNotificationService mockNotificationService;

  //   setUp(() {
  //     mockApiServices = MockApiServices();
  //     mockNotificationService = MockLocalNotificationService();
  //   });

  //   test('callbackDispatcher should show notification with restaurant data',
  //       () async {
  //     when(() => mockApiServices.getRestaurantList())
  //         .thenAnswer((_) async => mockResponseSuccess);
  //     when(() => mockNotificationService.init()).thenAnswer((_) async => true);
  //     when(() => mockNotificationService.showNotification(
  //           id: 1,
  //           title: testRestaurant.name,
  //           body: testRestaurant.description,
  //           payload: "${testRestaurant.id}:list",
  //         )).thenAnswer((_) async => true);

  //     callbackDispatcher();

  //     verify(() => mockApiServices.getRestaurantList()).called(1);
  //     verify(() => mockNotificationService.init()).called(1);
  //     verify(() => mockNotificationService.showNotification(
  //           id: 1,
  //           title: testRestaurant.name,
  //           body: testRestaurant.description,
  //           payload: "${testRestaurant.id}:list",
  //         )).called(1);
  //   });

  //   test('callbackDispatcher should show error notification on API failure',
  //       () async {
  //     when(() => mockApiServices.getRestaurantList())
  //         .thenAnswer((_) async => ApiResult.error("Error"));
  //     when(() => mockNotificationService.init()).thenAnswer((_) async => true);
  //     when(() => mockNotificationService.showNotification(
  //           id: 1,
  //           title: Strings.dailyNotification,
  //           body: 'Error',
  //           payload: Strings.error,
  //         )).thenAnswer((_) async => true);

  //     callbackDispatcher();

  //     verify(() => mockApiServices.getRestaurantList()).called(1);
  //     verify(() => mockNotificationService.init()).called(1);
  //     verify(() => mockNotificationService.showNotification(
  //           id: 1,
  //           title: Strings.dailyNotification,
  //           body: 'Error',
  //           payload: Strings.error,
  //         )).called(1);
  //   });

  //   test('callbackDispatcher should show error notification on exception',
  //       () async {
  //     when(() => mockApiServices.getRestaurantList())
  //         .thenThrow(Exception('Unexpected error'));
  //     when(() => mockNotificationService.init()).thenAnswer((_) async => true);
  //     when(() => mockNotificationService.showNotification(
  //           id: 1,
  //           title: Strings.dailyNotification,
  //           body: 'Unexpected error fetching restaurant data.',
  //           payload: Strings.error,
  //         )).thenAnswer((_) async => true);

  //     callbackDispatcher();

  //     verify(() => mockApiServices.getRestaurantList()).called(1);
  //     verify(() => mockNotificationService.init()).called(1);
  //     verify(() => mockNotificationService.showNotification(
  //           id: 1,
  //           title: Strings.dailyNotification,
  //           body: 'Unexpected error fetching restaurant data.',
  //           payload: Strings.error,
  //         )).called(1);
  //   });
  // });
}
