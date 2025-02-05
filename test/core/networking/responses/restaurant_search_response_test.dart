import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_search_response.dart';

void main() {
  group('RestaurantSearchResponse Model Tests', () {
    test('parseCompleteJson_AssignsAllFields', () {
      const jsonData = '''
      {
        "error": false,
        "founded": 2,
        "restaurants": [
          {
            "id": "s1knt6za9kkfw1e867",
            "name": "Kafe Kita",
            "description": "Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,",
            "pictureId": "25",
            "city": "Gorontalo",
            "rating": 4
          },
          {
            "id": "ateyf7m737ekfw1e867",
            "name": "Kafe Cemara",
            "description": "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet.",
            "pictureId": "27",
            "city": "Ternate",
            "rating": 3.6
          }
        ]
      }
      ''';

      final parsedData = jsonDecode(jsonData);
      final response = RestaurantSearchResponse.fromJson(parsedData);

      expect(response.error, false);
      expect(response.founded, 2);
      expect(response.restaurants.first.name, 'Kafe Kita');
      expect(response.restaurants[1].name, 'Kafe Cemara');
    });

    test('parseJsonWithEmptyRestaurants_AssignsEmptyList', () {
      const jsonData = '''
      {
        "error": false,
        "founded": 0,
        "restaurants": []
      }
      ''';

      final parsedData = jsonDecode(jsonData);
      final response = RestaurantSearchResponse.fromJson(parsedData);

      expect(response.restaurants, isEmpty);
    });

    test('parseJsonWithMissingFields_ThrowsError', () {
      const jsonData = '''
      {
        "error": false
      }
      ''';

      final parsedData = jsonDecode(jsonData);

      expect(
        () => RestaurantSearchResponse.fromJson(parsedData),
        throwsA(isA<TypeError>()),
      );
    });

    test('parseJsonWithValidRestaurantList_PopulatesRestaurants', () {
      const jsonData = '''
      {
        "error": false,
        "founded": 2,
        "restaurants": [
          {
            "id": "s1knt6za9kkfw1e867",
            "name": "Kafe Kita",
            "description": "Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,",
            "pictureId": "25",
            "city": "Gorontalo",
            "rating": 4
          },
          {
            "id": "uewq1zg2zlskfw1e867",
            "name": "Kafein",
            "description": "Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,",
            "pictureId": "15",
            "city": "Aceh",
            "rating": 4.6
          }
        ]
      }
      ''';

      final parsedData = jsonDecode(jsonData);
      final response = RestaurantSearchResponse.fromJson(parsedData);

      expect(response.restaurants.length, 2);
      expect(response.restaurants[1].name, 'Kafein');
    });

    test('toJson_ReturnsEquivalentJsonStructure', () {
      final response = RestaurantSearchResponse(
        error: false,
        founded: 1,
        restaurants: [
          Restaurant(
            id: 'testId',
            name: 'Test Cafe',
            description: 'Description',
            pictureId: '15',
            city: 'Test City',
            rating: 4.5,
          )
        ],
      );

      final json = response.toJson();

      expect(json['error'], false);
      expect(json['founded'], 1);
      expect((json['restaurants'] as List).first['name'], 'Test Cafe');
    });
  });
}
