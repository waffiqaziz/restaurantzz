import 'package:flutter/widgets.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/states/list_result_state.dart';

class ListProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  ListProvider(this._apiServices);

  RestaurantListResultState _resultState = RestaurantListNoneState();

  RestaurantListResultState get resultState => _resultState;

  Future<void> fetchRestaurantList() async {
    try {
      _resultState = RestaurantListLoadingState();
      notifyListeners();

      final result = await _apiServices.getRestaurantList();

      if (result.data != null) {
        if (result.data!.error) {
          _resultState = RestaurantListErrorState(
            result.message ?? result.data?.message ?? "Unknown error occurred",
          );
        } else {
          _resultState = RestaurantListLoadedState(result.data!.restaurants);
        }
      } else {
        _resultState = RestaurantListErrorState(
          result.message ?? "Unknown error occurred",
        );
      }

      notifyListeners();
    } catch (e, _) {
      if (e is TypeError) {
        _resultState = RestaurantListErrorState(
          "Unexpected response type from the server. Please contact support.",
        );
      } else {
        _resultState = RestaurantListErrorState(
          "An unexpected error occurred: ${e.toString()}",
        );
      }
      notifyListeners();
    }
  }
}
