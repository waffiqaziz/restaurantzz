import 'package:restaurantzz/core/networking/responses/restaurant_list_response.dart';

sealed class RestaurantListResultState {}

class RestaurantListNoneState extends RestaurantListResultState {}

class RestaurantListLoadingState extends RestaurantListResultState {}

class RestaurantListErrorState extends RestaurantListResultState {
  final String error;

  RestaurantListErrorState(this.error);
}

class RestaurantListLoadedState extends RestaurantListResultState {
  final List<RestaurantListItem> data;

  RestaurantListLoadedState(this.data);
}
