import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_list_response.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_review_response.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_search_response.dart';
import 'package:restaurantzz/core/networking/utils/api_utils.dart';

class ApiServices {
  static const String _baseUrl = "https://restaurant-api.dicoding.dev";

  Future<ApiResult<RestaurantListResponse>> getRestaurantList() async {
    return await safeApiCall(() async {
      final response = await http.get(Uri.parse("$_baseUrl/list"));

      return response.statusCode == 200
          ? RestaurantListResponse.fromJson(jsonDecode(response.body))
          : throw HttpException(
              'Failed to load restaurant list. Status code: ${response.statusCode}',
            );
    });
  }

  Future<ApiResult<RestaurantDetailResponse>> getRestaurantDetail(
    String id,
  ) async {
    return await safeApiCall(() async {
      final response = await http.get(Uri.parse("$_baseUrl/detail/$id"));

      return response.statusCode == 200
          ? RestaurantDetailResponse.fromJson(jsonDecode(response.body))
          : throw Exception(
              'Failed to load restaurant detail. Status code: ${response.statusCode}',
            );
    });
  }

  Future<ApiResult<RestaurantSearchResponse>> searchRestaurant(
    String query,
  ) async {
    return await safeApiCall(() async {
      final response = await http.get(Uri.parse("$_baseUrl/search?q=$query"));

      return response.statusCode == 200
          ? RestaurantSearchResponse.fromJson(jsonDecode(response.body))
          : throw Exception(
              'Failed to load restaurant search. Status code: ${response.statusCode}',
            );
    });
  }

  Future<ApiResult<PostReviewResponse>> postReview(
    String id,
    String name,
    String review,
  ) async {
    return await safeApiCall(() async {
      try {
        final response = await http.post(
          Uri.parse("$_baseUrl/review"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({"id": id, "name": name, "review": review}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return PostReviewResponse.fromJson(jsonDecode(response.body));
        } else {
          throw Exception(
            'Failed submit review. Status code: ${response.statusCode}',
          );
        }
      } catch (e) {
        throw Exception('Failed to post review: $e');
      }
    });
  }
}
