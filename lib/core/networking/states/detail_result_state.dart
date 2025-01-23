import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';

sealed class RestaurantDetailResultState {}

class RestaurantDetailNoneState extends RestaurantDetailResultState {}

class RestaurantDetailLoadingState extends RestaurantDetailResultState {}

class RestaurantDetailErrorState extends RestaurantDetailResultState {
  final String error;
  final String restaurantId;

  RestaurantDetailErrorState(this.error, this.restaurantId);
}

class RestaurantDetailLoadedState extends RestaurantDetailResultState {
  final RestaurantDetailItem data;

  RestaurantDetailLoadedState(this.data);
}
