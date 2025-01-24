import 'package:flutter/material.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/states/search_result_state.dart';

class SearchProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  SearchProvider(this._apiServices);

  RestaurantSearchResultState _resultState = RestaurantSearchNoneState();

  RestaurantSearchResultState get resultState => _resultState;

  bool _isClearVisible = false; // Tracks the visibility of the clear button
  bool get isClearVisible => _isClearVisible;

  void updateClearButton(String query) {
    _isClearVisible = query.isNotEmpty;
    notifyListeners();
  }

  String _lastQuery = "";

  Future<void> fetchRestaurantList(String query) async {
    if (query.isEmpty) {
      return;
    }

    if (query != _lastQuery) {
      _lastQuery = query;
      notifyListeners();

      try {
        // avoid multiple trigger loading
        if (_resultState is RestaurantSearchLoadingState || query.isEmpty) {
          return;
        }

        _resultState = RestaurantSearchLoadingState();
        notifyListeners();

        final result = await _apiServices.searchRestaurant(query);

        if (result.data != null) {
          if (result.data!.founded == 0) {
            _resultState = RestaurantSearchNotFoundState();
          } else if (result.data!.error) {
            _resultState = RestaurantSearchErrorState("Please try again later");
          } else {
            _resultState =
                RestaurantSearchLoadedState(result.data!.restaurants);
          }
        } else {
          _resultState = RestaurantSearchErrorState(
            result.message ?? "Unknown error occurred",
          );
        }
        notifyListeners();
      } catch (e) {
        _resultState = RestaurantSearchErrorState(
          "An unexpected error occurred: ${e.toString()}",
        );
        notifyListeners();
      }
    }
  }

  void clearSearchResults() {
    _lastQuery = "";
    _resultState = RestaurantSearchNoneState();
    notifyListeners();
  }
}
