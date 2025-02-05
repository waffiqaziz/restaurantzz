import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_list_response.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';

void main() {
  late ApiServices apiServices;

  group('getRestaurantList', () {
    test('returnSuccess_WhenResponseIs200', () async {
      apiServices = ApiServices(
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode({
              "error": false,
              "message": "success",
              "count": 1,
              "restaurants": [
                {
                  "id": "ygewwl55ktckfw1e867",
                  "name": "Istana Emas",
                  "description":
                      "Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,",
                  "pictureId": "05",
                  "city": "Balikpapan",
                  "rating": 4.5
                }
              ]
            }),
            200,
          );
        }),
      );

      final result = await apiServices.getRestaurantList();
      expect(result.data, isA<RestaurantListResponse>());
      expect(result.data!.restaurants.first.name, 'Istana Emas');
      expect(result.message, isNull);
    });

    test('returnError_WhenResponseIs404', () async {
      apiServices = ApiServices(
        httpClient: MockClient((request) async {
          return http.Response('Not found', 404);
        }),
      );

      final result = await apiServices.getRestaurantList();

      expect(result.data, isNull);
      expect(
        result.message,
        contains('Failed to load restaurant list. Status code: 404.'),
      );
    });

    test('returnError_ForHttpException', () async {
      apiServices = ApiServices(
        httpClient: MockClient((request) async {
          throw HttpException('HTTP error');
        }),
      );

      final result = await apiServices.getRestaurantList();

      expect(result.data, isNull);
      expect(result.message, "An HTTP error occurred. Please try again.");
    });
  });

  group('getRestaurantDetail', () {
    test('returnSuccess_WhenResponseIs200', () async {
      apiServices = ApiServices(
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode({
              "error": false,
              "message": "success",
              "restaurant": {
                "id": "fnfn8mytkpmkfw1e867",
                "name": "Makan mudah",
                "description":
                    "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure.",
                "city": "Medan",
                "address": "Jln. Pandeglang no 19",
                "pictureId": "22",
                "categories": [
                  {"name": "Jawa"}
                ],
                "menus": {
                  "foods": [
                    {"name": "Kari kacang dan telur"},
                    {"name": "Toastie salmon"},
                    {"name": "Matzo farfel"},
                    {"name": "Napolitana"},
                    {"name": "Salad yuzu"},
                    {"name": "Sosis squash dan mint"},
                    {"name": "Daging Sapi"}
                  ],
                  "drinks": [
                    {"name": "Minuman soda"},
                    {"name": "Jus apel"},
                    {"name": "Air"},
                    {"name": "Jus jeruk"},
                    {"name": "Es krim"},
                    {"name": "Es teh"},
                    {"name": "Jus tomat"},
                    {"name": "Coklat panas"}
                  ]
                },
                "rating": 3.7,
                "customerReviews": [
                  {
                    "name": "Gilang",
                    "review": "Harganya murah sekali!",
                    "date": "14 Agustus 2018"
                  },
                  {
                    "name": "string",
                    "review": "string",
                    "date": "4 Februari 2025"
                  },
                  {
                    "name": "Rizal",
                    "review": "Mantap",
                    "date": "4 Februari 2025"
                  },
                  {
                    "name": "Yasmin",
                    "review": "Enak Sekali!",
                    "date": "4 Februari 2025"
                  },
                  {
                    "name": "Jessica",
                    "review": "Good",
                    "date": "4 Februari 2025"
                  }
                ]
              }
            }),
            200,
          );
        }),
      );

      final result =
          await apiServices.getRestaurantDetail("fnfn8mytkpmkfw1e867");

      expect(result.data, isNotNull);
      expect(result.data!.restaurant.name, "Makan mudah");
      expect(result.message, isNull);
    });

    test('returnError_WhenResponseIs404', () async {
      apiServices = ApiServices(
        httpClient: MockClient((request) async {
          return http.Response('Not found', 404);
        }),
      );

      final result = await apiServices.getRestaurantDetail("testId");

      expect(result.data, isNull);
      expect(
        result.message,
        contains('Failed to load restaurant detail. Status code: 404'),
      );
    });
  });

  group('searchRestaurant', () {
    test('returnSuccess_WhenResponseIs200', () async {
      apiServices = ApiServices(
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode({
              "error": false,
              "founded": 1,
              "restaurants": [
                {
                  "id": "testId",
                  "name": "Search Test Restaurant",
                  "description": "A search test description",
                  "city": "Search City",
                  "pictureId": "2",
                  "rating": 4.2
                }
              ]
            }),
            200,
          );
        }),
      );

      final result = await apiServices.searchRestaurant("test");

      expect(result.data, isNotNull);
      expect(result.data!.restaurants.first.name, "Search Test Restaurant");
      expect(result.message, isNull);
    });

    test('returnError_WhenResponseIs400', () async {
      apiServices = ApiServices(
        httpClient: MockClient((request) async {
          return http.Response('Bad request', 400);
        }),
      );

      final result = await apiServices.searchRestaurant("test");

      expect(result.data, isNull);
      expect(
        result.message,
        contains('Failed to load restaurant search. Status code: 400'),
      );
    });
  });

  group('postReview', () {
    test('returnSuccess_WhenResponseIs201', () async {
      apiServices = ApiServices(
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode({
              "error": false,
              "message": "success",
              "customerReviews": [
                {
                  "name": "Test User",
                  "review": "Great place!",
                  "date": "4 February 2025"
                }
              ]
            }),
            201,
          );
        }),
      );

      final result = await apiServices.postReview(
        "testId",
        "Test User",
        "Great place!",
      );

      expect(result.data, isNotNull);
      expect(result.data!.customerReviews.first.review, "Great place!");
      expect(result.message, isNull);
    });

    test('returnError_WhenResponseIs500', () async {
      apiServices = ApiServices(
        httpClient: MockClient((request) async {
          return http.Response('Internal Server Error', 500);
        }),
      );

      final result = await apiServices.postReview(
        "testId",
        "Test User",
        "Great place!",
      );

      expect(result.data, isNull);
      expect(
        result.message,
        contains('Review submit failed. Status code: 500'),
      );
    });
  });
}
