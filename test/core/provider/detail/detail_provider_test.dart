import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/states/detail_result_state.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';

import '../../../testutils/mock.dart';

class UriFake extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(UriFake());
  });
  
  group('DetailProvider', () {
    late DetailProvider detailProvider;
    late MockHttpClient mockHttpClient;
    late ApiServices apiServices;
    final mockDetailRestaurantResponseData = {
      "error": false,
      "message": "success",
      "restaurant": {
        "id": "zvf11c0sukfw1e867",
        "name": "Gigitan Cepat",
        "description": "Desciption",
        "city": "Bali",
        "address": "Jln. Belimbing Timur no 27",
        "pictureId": "38",
        "categories": [
          {"name": "Italia"},
          {"name": "Sop"}
        ],
        "menus": {
          "foods": [
            {"name": "Tumis leek"},
            {"name": "Paket rosemary"},
            {"name": "roket penne"},
            {"name": "Daging Sapi"},
            {"name": "Napolitana"},
            {"name": "Salad lengkeng"},
            {"name": "Matzo farfel"},
            {"name": "Kari kacang dan telur"},
            {"name": "Sosis squash dan mint"},
            {"name": "Kari terong"}
          ],
          "drinks": [
            {"name": "Jus apel"},
            {"name": "Air"},
            {"name": "Teh manis"},
            {"name": "Jus mangga"},
            {"name": "Es teh"},
            {"name": "Jus alpukat"},
            {"name": "Jus tomat"}
          ]
        },
        "rating": 4,
        "customerReviews": [
          {
            "name": "Arif",
            "review": "Saya sangat suka menu malamnya!",
            "date": "13 November 2019"
          },
          {
            "name": "Gilang",
            "review": "Harganya murah sekali!",
            "date": "13 Juli 2019"
          }
        ]
      }
    };
    final mockReviewResponseData = {
      "error": false,
      "message": "success",
      "customerReviews": [
        {
          "name": "Ahmad",
          "review": "Tidak rekomendasi untuk pelajar!",
          "date": "13 November 2019"
        },
        {
          "name": "Yosua",
          "review": "Tidak rekomendasi untuk pelajar",
          "date": "7 Februari 2025"
        },
        {
          "name": "steven",
          "review": "haii aku steven",
          "date": "7 Februari 2025"
        },
        {"name": "joni", "review": "enak bangett", "date": "7 Februari 2025"},
        {"name": "dorrr", "review": "yahahaahah", "date": "7 Februari 2025"},
        {"name": "ggg", "review": "ggg", "date": "7 Februari 2025"},
        {
          "name": "Postman Reviewer",
          "review": "refresh should shows this review2",
          "date": "7 Februari 2025"
        }
      ]
    };

    setUp(() {
      mockHttpClient = MockHttpClient();
      apiServices = ApiServices(httpClient: mockHttpClient);
      detailProvider = DetailProvider(apiServices);
    });

    tearDown(() {
      detailProvider.dispose();
      reset(mockHttpClient);
    });

    test('initialState_shouldBeNoneState', () {
      expect(detailProvider.resultState, isA<RestaurantDetailNoneState>());
    });

    test(
        'fetchRestaurantDetail_refreshTrue_shouldNotifyListenersWithoutClearingContent',
        () async {
      when(() => mockHttpClient.get(Uri.parse(
              "https://restaurant-api.dicoding.dev/detail/zvf11c0sukfw1e867")))
          .thenAnswer((_) async {
        return http.Response(jsonEncode(mockDetailRestaurantResponseData), 200);
      });

      // initial fetch
      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867");

      bool listenerNotified = false;
      detailProvider.addListener(() {
        listenerNotified = true;
      });

      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867",
          refresh: true);

      expect(listenerNotified, isTrue);
      expect(detailProvider.cachedData?.id, "zvf11c0sukfw1e867");
      expect(detailProvider.resultState, isA<RestaurantDetailLoadedState>());
    });

    test(
        'fetchRestaurantDetail_refreshFalseWithCachedData_shouldReturnCachedDataAndNotifyListeners',
        () async {
      when(() => mockHttpClient.get(Uri.parse(
              "https://restaurant-api.dicoding.dev/detail/zvf11c0sukfw1e867")))
          .thenAnswer((_) async {
        return http.Response(jsonEncode(mockDetailRestaurantResponseData), 200);
      });

      // fetch to save it on the cache
      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867");

      bool listenerNotified = false;
      detailProvider.addListener(() {
        listenerNotified = true;
      });

      // reset to verify no API call
      clearInteractions(mockHttpClient);

      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867",
          refresh: false);

      expect(listenerNotified, isTrue);
      expect(detailProvider.resultState, isA<RestaurantDetailLoadedState>());
      expect(detailProvider.cachedData?.id, "zvf11c0sukfw1e867");

      verifyNever(() => mockHttpClient.get(any()));
    });

    test('fetchRestaurantDetail_shouldNotifyLoadingThenReturnListOnSuccess',
        () async {
      when(() => mockHttpClient.get(Uri.parse(
              "https://restaurant-api.dicoding.dev/detail/zvf11c0sukfw1e867")))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return http.Response(jsonEncode(mockDetailRestaurantResponseData), 200);
      });
      bool loadingStateObserved = false; // loading flag

      // get the loading state
      detailProvider.addListener(() {
        if (detailProvider.resultState is RestaurantDetailLoadingState) {
          loadingStateObserved = true;
        }
      });

      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867");

      // assert loading state was observed
      expect(loadingStateObserved, isTrue);

      // assert loaded state after API completes
      expect(detailProvider.resultState, isA<RestaurantDetailLoadedState>());
      final state = detailProvider.resultState as RestaurantDetailLoadedState;
      expect(state.data.name, "Gigitan Cepat");
      expect(state.data.city, "Bali");
      expect(state.data.address, "Jln. Belimbing Timur no 27");
      expect(state.data.categories.first.name, "Italia");
    });

    test('cachedData_shouldReturnValueCorrectly', () async {
      when(() => mockHttpClient.get(Uri.parse(
              "https://restaurant-api.dicoding.dev/detail/zvf11c0sukfw1e867")))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return http.Response(jsonEncode(mockDetailRestaurantResponseData), 200);
      });

      // initial should null
      expect(detailProvider.cachedData, null);
      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867");

      expect(
          detailProvider.cachedData?.toJson(),
          RestaurantDetailResponse.fromJson(mockDetailRestaurantResponseData)
              .restaurant
              .toJson());

      // assert loaded state after API completes
      expect(detailProvider.resultState, isA<RestaurantDetailLoadedState>());
    });

    test('fetchRestaurantDetail_shouldReturnErrorOnFailure', () async {
      when(() => mockHttpClient.get(Uri.parse(
              "https://restaurant-api.dicoding.dev/detail/zvf11c0sukfw1e867")))
          .thenAnswer((_) async =>
              http.Response('{"message": "Internal Server Error"}', 500));

      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867");

      expect(detailProvider.resultState, isA<RestaurantDetailErrorState>());
      final state = detailProvider.resultState as RestaurantDetailErrorState;
      expect(
          state.error,
          contains(
              'An unexpected error occurred: Exception: Failed to load restaurant detail. Status code: 500. Please try again.'));
    });

    test('fetchRestaurantDetail_shouldReturnErrorWhenErrorTrue', () async {
      final mockResponseData = {
        "error": true,
        "message": "Server Error",
        "restaurant": {}
      };

      when(() => mockHttpClient.get(Uri.parse(
              "https://restaurant-api.dicoding.dev/detail/zvf11c0sukfw1e867")))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return http.Response(jsonEncode(mockResponseData), 200);
      });

      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867");

      expect(detailProvider.resultState, isA<RestaurantDetailErrorState>());
      final state = detailProvider.resultState as RestaurantDetailErrorState;
      expect(state.error, contains('Server Error'));
    });

    test('fetchRestaurantDetail_shouldReturnErrorWhenErrorTrue', () async {
      when(() => mockHttpClient.get(Uri.parse(
              "https://restaurant-api.dicoding.dev/detail/zvf11c0sukfw1e867")))
          .thenThrow(Exception("Unexpected error"));

      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867");

      expect(detailProvider.resultState, isA<RestaurantDetailErrorState>());
      final state = detailProvider.resultState as RestaurantDetailErrorState;
      expect(
          state.error,
          contains(
              'An unexpected error occurred: Exception: Unexpected error. Please try again.'));
    });

    test('addReview_shouldReturnReviewCorrectly', () async {
      when(() => mockHttpClient.get(Uri.parse(
              "https://restaurant-api.dicoding.dev/detail/zvf11c0sukfw1e867")))
          .thenAnswer((_) async {
        return http.Response(jsonEncode(mockDetailRestaurantResponseData), 200);
      });

      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867");

      expect(detailProvider.resultState, isA<RestaurantDetailLoadedState>());

      when(() => mockHttpClient.post(
            Uri.parse("https://restaurant-api.dicoding.dev/review"),
            headers: {'Content-Type': 'application/json'},
            body: any(named: 'body'),
          )).thenAnswer((_) async {
        return http.Response(jsonEncode(mockReviewResponseData), 201);
      });

      await detailProvider.addReview("zvf11c0sukfw1e867", "name", "review");
      expect(detailProvider.resultState, isA<RestaurantDetailLoadedState>());

      // assert loaded state after API completes
      final state = detailProvider.resultState as RestaurantDetailLoadedState;
      expect(state.data.customerReviews.first.name, "Ahmad");
      expect(state.data.customerReviews.first.review,
          "Tidak rekomendasi untuk pelajar!");
      expect(state.data.customerReviews.first.date, "13 November 2019");
    });

    test('addReview_shouldReturnErrorWhenApiFails', () async {
      when(() => mockHttpClient.post(
            Uri.parse("https://restaurant-api.dicoding.dev/review"),
            body: any(named: 'body'),
          )).thenAnswer((_) async {
        return http.Response('{"error": true, "message": "Failed"}', 400);
      });

      await detailProvider.addReview("zvf11c0sukfw1e867", "name", "review");

      // Assert the error message is set
      expect(detailProvider.reviewSubmissionError,
          "Failed to submit the review. Please try again.");
    });

    test('addReview_shouldCompleteSubmissionFlag', () async {
      when(() => mockHttpClient.post(
            Uri.parse("https://restaurant-api.dicoding.dev/review"),
            body: any(named: 'body'),
          )).thenAnswer((_) async {
        return http.Response(jsonEncode(mockDetailRestaurantResponseData), 200);
      });

      await detailProvider.addReview("id", "name", "review");

      expect(detailProvider.isReviewSubmissionComplete, isTrue);
    });

    test('resetReviewSubmissionState_shouldResetFlag', () async {
      when(() => mockHttpClient.get(Uri.parse(
              "https://restaurant-api.dicoding.dev/detail/zvf11c0sukfw1e867")))
          .thenAnswer((_) async {
        return http.Response(jsonEncode(mockDetailRestaurantResponseData), 200);
      });

      // trigger fetch detail
      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867");
      expect(detailProvider.resultState, isA<RestaurantDetailLoadedState>());

      when(() => mockHttpClient.post(
            Uri.parse("https://restaurant-api.dicoding.dev/review"),
            headers: {'Content-Type': 'application/json'},
            body: any(named: 'body'),
          )).thenAnswer((_) async {
        return http.Response(jsonEncode(mockReviewResponseData), 201);
      });

      // initial value
      expect(detailProvider.isReviewSubmissionComplete, false);
      expect(detailProvider.reviewSubmissionError, null);

      // trigger add review success
      await detailProvider.addReview("zvf11c0sukfw1e867", "name", "review");
      expect(detailProvider.resultState, isA<RestaurantDetailLoadedState>());
      expect(detailProvider.isReviewSubmissionComplete, true);
      expect(detailProvider.reviewSubmissionError, null);

      // reset flag
      detailProvider.resetReviewSubmissionState();
      expect(detailProvider.isReviewSubmissionComplete, false);
      expect(detailProvider.reviewSubmissionError, null);

      when(() => mockHttpClient.post(
            Uri.parse("https://restaurant-api.dicoding.dev/review"),
            headers: {'Content-Type': 'application/json'},
            body: any(named: 'body'),
          )).thenAnswer((_) async {
        return http.Response('{"error": true, "message": "Failed"}', 400);
      });

      // trigger add review failed
      await detailProvider.addReview("zvf11c0sukfw1e867", "name", "review");
      expect(detailProvider.isReviewSubmissionComplete, true);
      expect(detailProvider.reviewSubmissionError,
          "Failed to submit the review. Please try again.");

      // reset flag
      detailProvider.resetReviewSubmissionState();
      expect(detailProvider.isReviewSubmissionComplete, false);
      expect(detailProvider.reviewSubmissionError, null);
    });
  });

  group('DetailProvider Catch', () {
    late DetailProvider detailProvider;
    late MockApiServices mockApiServices;

    setUp(() {
      mockApiServices = MockApiServices();
      detailProvider = DetailProvider(mockApiServices);
    });

    test('addReview_shouldHandleExceptionAndSetErrorMessage', () async {
      when(() => mockApiServices.postReview(any(), any(), any()))
          .thenThrow(Exception("Network error"));

      await detailProvider.addReview("zvf11c0sukfw1e867", "name", "review");

      // Assert that the catch block set the appropriate error message
      expect(detailProvider.reviewSubmissionError,
          "Failed to submit the review. Please try again.");
      expect(detailProvider.resultState,
          isNot(isA<RestaurantDetailLoadedState>()));
    });

    test('fetchRestaurantDetail_shouldHandleExceptionAndSetErrorMessage',
        () async {
      when(() => mockApiServices.getRestaurantDetail(any()))
          .thenThrow(Exception("Network error"));
      await detailProvider.fetchRestaurantDetail("zvf11c0sukfw1e867");

      expect(detailProvider.resultState, isA<RestaurantDetailErrorState>());
      final state = detailProvider.resultState as RestaurantDetailErrorState;
      expect(state.error,
          contains('An unexpected error occurred: Exception: Network error'));
    });
  });
}
