import 'dart:convert';

import 'package:restaurantzz/core/data/model/restaurant.dart';

RestaurantSearchResponse searchRestaurantFromJson(String str) =>
    RestaurantSearchResponse.fromJson(json.decode(str));

String searchRestaurantToJson(RestaurantSearchResponse data) =>
    json.encode(data.toJson());

class RestaurantSearchResponse {
  bool error;
  int founded;
  List<Restaurant> restaurants;

  RestaurantSearchResponse({
    required this.error,
    required this.founded,
    required this.restaurants,
  });

  factory RestaurantSearchResponse.fromJson(Map<String, dynamic> json) =>
      RestaurantSearchResponse(
        error: json["error"],
        founded: json["founded"],
        restaurants: List<Restaurant>.from(
            json["restaurants"].map((x) => Restaurant.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "founded": founded,
        "restaurants": List<dynamic>.from(restaurants.map((x) => x.toJson())),
      };
}
