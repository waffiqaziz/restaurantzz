import 'dart:convert';

RestaurantListResponse restaurantResultFromJson(String str) =>
    RestaurantListResponse.fromJson(json.decode(str));

String restaurantResultToJson(RestaurantListResponse data) =>
    json.encode(data.toJson());

class RestaurantListResponse {
  bool error;
  String message;
  int count;
  List<RestaurantListItem> restaurants;

  RestaurantListResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.restaurants,
  });

  factory RestaurantListResponse.fromJson(Map<String, dynamic> json) =>
      RestaurantListResponse(
        error: json["error"],
        message: json["message"],
        count: json["count"],
        restaurants: List<RestaurantListItem>.from(
            json["restaurants"].map((x) => RestaurantListItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "count": count,
        "restaurants": List<dynamic>.from(restaurants.map((x) => x.toJson())),
      };
}

class RestaurantListItem {
  String id;
  String name;
  String description;
  String pictureId;
  String city;
  double rating;

  RestaurantListItem({
    required this.id,
    required this.name,
    required this.description,
    required this.pictureId,
    required this.city,
    required this.rating,
  });

  factory RestaurantListItem.fromJson(Map<String, dynamic> json) =>
      RestaurantListItem(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        pictureId: json["pictureId"],
        city: json["city"],
        rating: json["rating"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "pictureId": pictureId,
        "city": city,
        "rating": rating,
      };
}
