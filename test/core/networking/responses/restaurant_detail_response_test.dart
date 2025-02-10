import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';

void main() {
  group('RestaurantDetailResponse Model Tests', () {
    const validJsonString = '''
      {
        "error": false,
        "message": "success",
        "restaurant": {
          "id": "rqdv5juczeskfw1e867",
          "name": "Melting Pot",
          "description": "Lorem ipsum...",
          "city": "Medan",
          "address": "Jln. Pandeglang no 19",
          "pictureId": "14",
          "categories": [{"name": "Italia"}, {"name": "Modern"}],
          "menus": {
            "foods": [{"name": "Paket rosemary"}],
            "drinks": [{"name": "Es krim"}]
          },
          "rating": 4.2,
          "customerReviews": [{"name": "Ahmad", "review": "Tidak rekomendasi", "date": "13 November 2019"}]
        }
      }
    ''';

    test('parseValidJson_ReturnsValidModel', () {
      final jsonData = jsonDecode(validJsonString);
      final response = RestaurantDetailResponse.fromJson(jsonData);

      expect(response.error, false);
      expect(response.message, "success");
      expect(response.restaurant.id, "rqdv5juczeskfw1e867");
      expect(response.restaurant.menus.foods.first.name, "Paket rosemary");
    });

    test('parseJsonWithMissingFields_AssignsDefaults', () {
      const jsonWithMissingFields = '''
        {
          "error": false,
          "message": "success",
          "restaurant": {
            "id": "testId",
            "name": "Test Restaurant",
            "description": "Sample",
            "city": "Test City",
            "address": "Test Address",
            "pictureId": "1",
            "rating": 4.0
          }
        }
      ''';

      final jsonData = jsonDecode(jsonWithMissingFields);
      final response = RestaurantDetailResponse.fromJson(jsonData);

      expect(response.restaurant.categories, isEmpty);
      expect(response.restaurant.menus.foods, isEmpty);
      expect(response.restaurant.menus.drinks, isEmpty);
      expect(response.restaurant.customerReviews, isEmpty);
    });

    test('parseJsonWithoutRestaurant_AssignsDefaultValues', () {
      const jsonWithoutRestaurant = '''
        {
          "error": false,
          "message": "success"
        }
      ''';
      final jsonData = jsonDecode(jsonWithoutRestaurant);

      expect(
          () => RestaurantDetailResponse.fromJson(jsonData), returnsNormally);
    });

    test('parseJsonWithInvalidTypes_ThrowsTypeError', () {
      const invalidTypeJson = '''
        {
          "error": false,
          "message": "success",
          "restaurant": {
            "id": 123,
            "name": "Test Restaurant",
            "description": 456,
            "city": "Test City",
            "address": "Test Address",
            "pictureId": "1",
            "categories": "wrongType",
            "menus": {"foods": "wrongType", "drinks": []},
            "rating": "NaN",
            "customerReviews": []
          }
        }
      ''';

      final jsonData = jsonDecode(invalidTypeJson);

      expect(
        () => RestaurantDetailResponse.fromJson(jsonData),
        throwsA(isA<TypeError>()),
      );
    });

    test('toJson_ReturnsValidJsonRepresentation', () {
      final response = RestaurantDetailResponse(
        error: false,
        message: "success",
        restaurant: RestaurantDetailItem(
          id: "testId",
          name: "Test Restaurant",
          description: "Sample",
          city: "Test City",
          address: "Test Address",
          pictureId: "1",
          categories: [],
          menus: Menu(foods: [], drinks: []),
          rating: 4.0,
          customerReviews: [],
        ),
      );

      final json = response.toJson();
      expect(json, {
        "error": false,
        "message": "success",
        "restaurant": {
          "id": "testId",
          "name": "Test Restaurant",
          "description": "Sample",
          "city": "Test City",
          "address": "Test Address",
          "pictureId": "1",
          "categories": [],
          "menus": {"foods": [], "drinks": []},
          "rating": 4.0,
          "customerReviews": []
        }
      });
    });

    test('copyWith_WithNullCustomerReviews_ReturnsSameCustomerReviews', () {
      final initialResponse = RestaurantDetailItem(
        id: "testId",
        name: "Test Restaurant",
        description: "Sample",
        city: "Test City",
        address: "Test Address",
        pictureId: "1",
        categories: [],
        menus: Menu(foods: [], drinks: []),
        rating: 4.0,
        customerReviews: [
          CustomerReview(name: "John", review: "Great!", date: "2025-02-10")
        ],
      );

      final updatedResponse = initialResponse.copyWith(customerReviews: null);

      expect(updatedResponse.customerReviews, initialResponse.customerReviews);
    });
  });
}
