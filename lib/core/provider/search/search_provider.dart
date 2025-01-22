import 'package:flutter/material.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/states/search_result_state.dart';

class SearchProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  SearchProvider(this._apiServices);

  RestaurantSearchResultState _resultState = RestaurantSearchNoneState();

  RestaurantSearchResultState get resultState => _resultState;

  Future<void> fetchRestaurantList(String query) async {
    // avoid multiple trigger loading
    if (_resultState is RestaurantSearchLoadingState || query.isEmpty) {
      return;
    }

    try {
      _resultState = RestaurantSearchLoadingState();
      notifyListeners();

      final result = await _apiServices.searchRestaurant(query);
      if (result.founded == 0) {
        _resultState = RestaurantSearchNotFoundState();
        notifyListeners();
      } else if (result.error) {
        _resultState = RestaurantSearchErrorState("Error");
        notifyListeners();
      } else {
        _resultState = RestaurantSearchLoadedState(result.restaurants);
        notifyListeners();
      }
    } on Exception catch (e) {
      _resultState = RestaurantSearchErrorState(e.toString());
      notifyListeners();
    }
    print("State: ${_resultState.runtimeType}");
  }

  void clearSearchResults() {
    _resultState = RestaurantSearchNoneState();
    notifyListeners();
  }
}
