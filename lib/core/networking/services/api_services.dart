import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_list_response.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_review_response.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_search_response.dart';
import 'package:restaurantzz/core/networking/utils/api_utils.dart';

class ApiServices {
  static const String _baseUrl = "https://restaurant-api.dicoding.dev";
  final http.Client httpClient;

  ApiServices({required this.httpClient});

  Future<ApiResult<RestaurantListResponse>> getRestaurantList() async {
    return await safeApiCall(() async {
      final response = await httpClient.get(Uri.parse("$_baseUrl/list"));

      return response.statusCode == 200
          ? RestaurantListResponse.fromJson(jsonDecode(response.body))
          : throw Exception('Failed to load restaurant list. Status code: ${response.statusCode}');
    });
  }

  Future<ApiResult<RestaurantDetailResponse>> getRestaurantDetail(String id) async {
    return await safeApiCall(() async {
      final response = await httpClient.get(Uri.parse("$_baseUrl/detail/$id"));

      return response.statusCode == 200
          ? RestaurantDetailResponse.fromJson(jsonDecode(response.body))
          : throw Exception(
              'Failed to load restaurant detail. Status code: ${response.statusCode}',
            );
    });
  }

  Future<ApiResult<RestaurantSearchResponse>> searchRestaurant(String query) async {
    return await safeApiCall(() async {
      final response = await httpClient.get(Uri.parse("$_baseUrl/search?q=$query"));

      return response.statusCode == 200
          ? RestaurantSearchResponse.fromJson(jsonDecode(response.body))
          : throw Exception(
              'Failed to load restaurant search. Status code: ${response.statusCode}',
            );
    });
  }

  Future<ApiResult<PostReviewResponse>> postReview(String id, String name, String review) async {
    return await safeApiCall(() async {
      final response = await httpClient.post(
        Uri.parse("$_baseUrl/review"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"id": id, "name": name, "review": review}),
      );

      return (response.statusCode == 200 || response.statusCode == 201)
          ? PostReviewResponse.fromJson(jsonDecode(response.body))
          : throw Exception('Review submit failed. Status code: ${response.statusCode}');
    });
  }
}
