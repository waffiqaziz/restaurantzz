import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_list_response.dart';
import 'dart:convert';

void main() {
  group('RestaurantListResponse Model Tests', () {
    test('parseJsonWithValidData_ReturnsCorrectObject', () {
      const jsonString = '''
        {
          "error": false,
          "message": "success",
          "count": 2,
          "restaurants": [
            {
              "id": "rqdv5juczeskfw1e867",
              "name": "Melting Pot",
              "description": "Lorem ipsum",
              "pictureId": "14",
              "city": "Medan",
              "rating": 4.2
            },
            {
              "id": "s1knt6za9kkfw1e867",
              "name": "Kafe Kita",
              "description": "Quisque rutrum",
              "pictureId": "25",
              "city": "Gorontalo",
              "rating": 4.0
            }
          ]
        }
      ''';

      final jsonData = jsonDecode(jsonString);
      final response = RestaurantListResponse.fromJson(jsonData);

      expect(response.error, false);
      expect(response.message, 'success');
      expect(response.count, 2);
      expect(response.restaurants.length, 2);
      expect(response.restaurants[0].name, 'Melting Pot');
    });

    test('parseJsonWithEmptyRestaurants_ReturnsEmptyList', () {
      const jsonString = '''
        {
          "error": false,
          "message": "success",
          "count": 0,
          "restaurants": []
        }
      ''';

      final jsonData = jsonDecode(jsonString);
      final response = RestaurantListResponse.fromJson(jsonData);

      expect(response.error, false);
      expect(response.restaurants.isEmpty, true);
    });

    test('parseJsonWithMissingField_NotError', () {
      const jsonString = '''
      {
        "error": false,
        "message": "success",
        "count": 1
      }
      ''';

      final jsonData = jsonDecode(jsonString);
      expect(
        () => RestaurantListResponse.fromJson(jsonData),
        throwsA(isA<NoSuchMethodError>()),
      );
    });

    test('serializeObjectToJson_ReturnsExpectedJson', () {
      final restaurants = [
        Restaurant(
          id: "rqdv5juczeskfw1e867",
          name: "Melting Pot",
          description: "Lorem ipsum",
          pictureId: "14",
          city: "Medan",
          rating: 4.2,
        )
      ];

      final response = RestaurantListResponse(
        error: false,
        message: "success",
        count: 1,
        restaurants: restaurants,
      );

      final json = response.toJson();
      expect(json['error'], false);
      expect(json['message'], "success");
      expect(json['count'], 1);
      expect(json['restaurants'].length, 1);
      expect(json['restaurants'][0]['name'], "Melting Pot");
    });
  });
}
