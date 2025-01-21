import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/states/detail_result_state.dart';

class DetailProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  // simple cache to store fetched restaurant details
  final Map<String, RestaurantDetailItem> _cache = {};

  DetailProvider(this._apiServices);

  RestaurantDetailResultState _resultState = RestaurantDetailNoneState();

  RestaurantDetailResultState get resultState => _resultState;

  Future<void> fetchRestaurantDetail(String id) async {
    // check data is cached/not
    if (_cache.containsKey(id)) {
      _resultState = RestaurantDetailLoadedState(_cache[id]!);
      notifyListeners();
      return;
    }

    try {
      _resultState = RestaurantDetailLoadingState();
      notifyListeners();

      final result = await _apiServices.getRestaurantDetail(id);

      if (result.error) {
        _resultState = RestaurantDetailErrorState(result.message);
        notifyListeners();
      } else {
        _cache[id] = result.restaurant;

        _resultState = RestaurantDetailLoadedState(result.restaurant);
        notifyListeners();
      }
    } on Exception catch (e) {
      _resultState = RestaurantDetailErrorState(e.toString());
      notifyListeners();
    }
  }
}