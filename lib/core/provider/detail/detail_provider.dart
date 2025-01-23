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

  bool _isReviewSubmission = false;
  bool get isReviewSubmission => _isReviewSubmission;

  bool _refreshData = false;
  void refresDate() {
    _refreshData = true;
  }

  Future<void> fetchRestaurantDetail(String id) async {
    try {
      // check data is cached/not
      if (_cache.containsKey(id) && _refreshData == false) {
        _resultState = RestaurantDetailLoadedState(_cache[id]!);
        notifyListeners();
        return;
      }

      _resultState = RestaurantDetailLoadingState();
      notifyListeners();

      final result = await _apiServices.getRestaurantDetail(id);

      if (result.data != null) {
        if (result.data!.error) {
          _resultState = RestaurantDetailErrorState(
              result.message ?? "Unknown error occurred", id);
        } else {
          _cache[id] = result.data!.restaurant;

          _resultState = RestaurantDetailLoadedState(result.data!.restaurant);
        }
      } else {
        _resultState = RestaurantDetailErrorState(
            result.message ?? "Unknown error occurred", id);
      }

      notifyListeners();
    } catch (e) {
      _resultState = RestaurantDetailErrorState(
          "An unexpected error occurred: ${e.toString()}", id);
      notifyListeners();
    }

    // reset flag
    Future.delayed(const Duration(milliseconds: 200), () {
      _refreshData = false;
    });
  }

  Future<void> addReview(
    String id,
    String name,
    String review,
  ) async {
    try {
      _isReviewSubmission = true;
      _resultState = RestaurantDetailLoadingState();
      notifyListeners();

      final result = await _apiServices.postReview(id, name, review);

      if (result.data != null && !result.data!.error) {
        if (_cache.containsKey(id)) {
          _cache[id] = _cache[id]!.copyWith(
            customerReviews: result.data!.customerReviews,
          );
          _resultState = RestaurantDetailLoadedState(_cache[id]!);
          notifyListeners();
        }
      } else {
        _resultState = RestaurantDetailErrorState(
          "Failed to submit the review. Please try again.",
          id,
        );
        notifyListeners();
      }

      // reset the flag
      Future.delayed(const Duration(milliseconds: 200), () {
        _isReviewSubmission = false;
      });
    } catch (e) {
      _resultState = RestaurantDetailErrorState(
        "Failed to submit the review. Please try again.",
        id,
      );
      notifyListeners();
    }
  }
}
