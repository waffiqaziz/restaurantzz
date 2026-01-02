import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/states/detail_result_state.dart';
import 'package:restaurantzz/core/provider/detail/detail_view_state.dart';

class DetailProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  // cache
  final Map<String, RestaurantDetailItem> _cache = {};

  // view states (per restaurant)
  final Map<String, DetailViewState> _viewStates = {};

  DetailProvider(this._apiServices);

  DetailViewState viewStateOf(String id) {
    return _viewStates[id] ?? DetailViewState(resultState: RestaurantDetailNoneState());
  }

  RestaurantDetailItem? cachedData(String id) => _cache[id];

  Future<void> fetchRestaurantDetail(String id, {bool refresh = false}) async {
    final currentState = viewStateOf(id);

    // Use cache if available and not refreshing
    if (!refresh && _cache.containsKey(id)) {
      _viewStates[id] = currentState.copyWith(
        resultState: RestaurantDetailLoadedState(_cache[id]!),
      );
      notifyListeners();
      return;
    }

    _viewStates[id] = currentState.copyWith(resultState: RestaurantDetailLoadingState());
    notifyListeners();

    try {
      final result = await _apiServices.getRestaurantDetail(id);

      if (result.data != null && !result.data!.error) {
        final restaurant = result.data!.restaurant;
        _cache[id] = restaurant;

        _viewStates[id] = currentState.copyWith(
          resultState: RestaurantDetailLoadedState(restaurant),
        );
      } else {
        _viewStates[id] = currentState.copyWith(
          resultState: RestaurantDetailErrorState(result.message ?? "Failed to load detail", id),
        );
      }
    } catch (e) {
      _viewStates[id] = currentState.copyWith(
        resultState: RestaurantDetailErrorState("Unexpected error: ${e.toString()}", id),
      );
    }

    notifyListeners();
  }

  Future<void> addReview(String id, String name, String review) async {
    _viewStates[id] = viewStateOf(
      id,
    ).copyWith(isSubmittingReview: true, reviewCompleted: false, reviewError: null);
    notifyListeners();

    try {
      final result = await _apiServices.postReview(id, name, review);

      if (result.data != null && !result.data!.error) {
        if (_cache.containsKey(id)) {
          _cache[id] = _cache[id]!.copyWith(customerReviews: result.data!.customerReviews);

          _viewStates[id] = viewStateOf(
            id,
          ).copyWith(resultState: RestaurantDetailLoadedState(_cache[id]!), reviewCompleted: true);
        }
      } else {
        _viewStates[id] = viewStateOf(
          id,
        ).copyWith(reviewCompleted: true, reviewError: "Failed to submit review");
      }
    } catch (_) {
      _viewStates[id] = viewStateOf(
        id,
      ).copyWith(reviewCompleted: true, reviewError: "Failed to submit review");
    } finally {
      _viewStates[id] = viewStateOf(id).copyWith(isSubmittingReview: false);
      notifyListeners();
    }
  }

  void resetReviewSubmissionState(String id) {
    final currentState = viewStateOf(id);

    _viewStates[id] = currentState.copyWith(reviewCompleted: false, reviewError: null);
    notifyListeners();
  }
}
