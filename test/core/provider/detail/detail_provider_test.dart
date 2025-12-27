import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/states/detail_result_state.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';

import '../../../testutils/mock.dart';

class UriFake extends Fake implements Uri {}

void main() {
  const id = "zvf11c0sukfw1e867";

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
          {"name": "Sop"},
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
            {"name": "Kari terong"},
          ],
          "drinks": [
            {"name": "Jus apel"},
            {"name": "Air"},
            {"name": "Teh manis"},
            {"name": "Jus mangga"},
            {"name": "Es teh"},
            {"name": "Jus alpukat"},
            {"name": "Jus tomat"},
          ],
        },
        "rating": 4,
        "customerReviews": [
          {"name": "Arif", "review": "Saya sangat suka menu malamnya!", "date": "13 November 2019"},
          {"name": "Gilang", "review": "Harganya murah sekali!", "date": "13 Juli 2019"},
        ],
      },
    };
    final mockReviewResponseData = {
      "error": false,
      "message": "success",
      "customerReviews": [
        {"name": "Ahmad", "review": "Tidak rekomendasi untuk pelajar!", "date": "13 November 2019"},
        {"name": "Yosua", "review": "Tidak rekomendasi untuk pelajar", "date": "7 Februari 2025"},
        {"name": "steven", "review": "haii aku steven", "date": "7 Februari 2025"},
        {"name": "joni", "review": "enak bangett", "date": "7 Februari 2025"},
        {"name": "dorrr", "review": "yahahaahah", "date": "7 Februari 2025"},
        {"name": "ggg", "review": "ggg", "date": "7 Februari 2025"},
        {
          "name": "Postman Reviewer",
          "review": "refresh should shows this review2",
          "date": "7 Februari 2025",
        },
      ],
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
      final state = detailProvider.viewStateOf("id");
      expect(state.resultState, isA<RestaurantDetailNoneState>());
    });

    test('fetchRestaurantDetail_shouldReturnLoadedState', () async {
      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockDetailRestaurantResponseData), 200));

      await detailProvider.fetchRestaurantDetail(id);

      final state = detailProvider.viewStateOf(id);
      expect(state.resultState, isA<RestaurantDetailLoadedState>());

      final loaded = state.resultState as RestaurantDetailLoadedState;
      expect(loaded.data.name, "Gigitan Cepat");
    });

    test('cachedData_shouldReturnValueCorrectly', () async {
      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockDetailRestaurantResponseData), 200));

      expect(detailProvider.cachedData(id), null);

      await detailProvider.fetchRestaurantDetail(id);

      expect(detailProvider.cachedData(id)?.id, id);
    });

    test('fetchRestaurantDetail_shouldReturnErrorOnFailure', () async {
      when(() => mockHttpClient.get(any())).thenAnswer((_) async => http.Response("{}", 500));

      await detailProvider.fetchRestaurantDetail(id);

      final state = detailProvider.viewStateOf(id);
      expect(state.resultState, isA<RestaurantDetailErrorState>());
    });

    test('addReview_shouldUpdateCustomerReviews', () async {
      when(
        () => mockHttpClient.get(any()),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockDetailRestaurantResponseData), 200));

      await detailProvider.fetchRestaurantDetail(id);

      when(
        () => mockHttpClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(mockReviewResponseData), 201));

      await detailProvider.addReview(id, "name", "review");

      final state = detailProvider.viewStateOf(id);
      expect(state.reviewCompleted, true);
      expect(state.reviewError, null);

      final loaded = state.resultState as RestaurantDetailLoadedState;
      expect(loaded.data.customerReviews.first.name, "Ahmad");
    });

    test('addReview_shouldSetErrorWhenApiFails', () async {
      when(
        () => mockHttpClient.post(any(), body: any(named: 'body')),
      ).thenAnswer((_) async => http.Response('{"error": true}', 400));

      await detailProvider.addReview(id, "name", "review");

      final state = detailProvider.viewStateOf(id);
      expect(state.reviewCompleted, true);
      expect(state.reviewError, "Failed to submit review");
    });

    test('resetReviewSubmissionState_shouldResetFlags', () async {
      when(
        () => mockHttpClient.post(any(), body: any(named: 'body')),
      ).thenAnswer((_) async => http.Response('{"error": true}', 400));

      await detailProvider.addReview(id, "name", "review");

      var state = detailProvider.viewStateOf(id);
      expect(state.reviewCompleted, true);
      expect(state.reviewError, isNotNull);

      detailProvider.resetReviewSubmissionState(id);

      state = detailProvider.viewStateOf(id);
      expect(state.reviewCompleted, false);
      expect(state.reviewError, null);
    });
  });
}
