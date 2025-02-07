import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/states/detail_result_state.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';

import '../../../testutils/mock_client.dart';

void main() {
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

    setUp(() {
      mockHttpClient = MockHttpClient();
      apiServices = ApiServices(httpClient: mockHttpClient);
      detailProvider = DetailProvider(apiServices);
    });

    test('initialState_shouldBeNoneState', () {
      expect(detailProvider.resultState, isA<RestaurantDetailNoneState>());
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

    test('addReview_shouldReturnReviewCorrectly', () async {
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

      // assert loaded state after API completes
      expect(detailProvider.resultState, isA<RestaurantDetailLoadedState>());
      final state = detailProvider.resultState as RestaurantDetailLoadedState;

      print(json.encode(state.data.customerReviews));

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
  });
}
