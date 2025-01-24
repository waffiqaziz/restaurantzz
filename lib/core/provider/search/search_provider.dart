import 'package:flutter/material.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/states/search_result_state.dart';

class SearchProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  SearchProvider(this._apiServices);

  RestaurantSearchResultState _resultState = RestaurantSearchNoneState();

  RestaurantSearchResultState get resultState => _resultState;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String _lastQuery = "";

  Future<void> fetchRestaurantList(String query) async {
    if (query.isEmpty) {
      clearSearchResults();
      return;
    }

    if (query != _lastQuery) {
      _isSearching = true;
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
      } finally {
        _isSearching = false;
        notifyListeners();
      }
    } // else do nothing
  }

  void clearSearchResults() {
    _isSearching = false;
    _lastQuery = "";
    _resultState = RestaurantSearchNoneState();
    notifyListeners();
  }
}
