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

  bool _isReviewSubmissionComplete = false;
  bool get isReviewSubmissionComplete => _isReviewSubmissionComplete;

  String? _reviewSubmissionError;
  String? get reviewSubmissionError => _reviewSubmissionError;

  // for testing purposes
  RestaurantDetailItem? get cachedData {
    if (_resultState is RestaurantDetailLoadedState) {
      return (_resultState as RestaurantDetailLoadedState).data;
    } else {
      return null;
    }
  }

  Future<void> fetchRestaurantDetail(String id, {bool refresh = false}) async {
    try {
      if (refresh) {
        notifyListeners(); // notify for refresh without clearing content
      } else {
        if (_cache.containsKey(id) && refresh == false) {
          _resultState = RestaurantDetailLoadedState(_cache[id]!);
          notifyListeners();
          return;
        }
        // show circular loading state only for non-refresh operations
        _resultState = RestaurantDetailLoadingState();
        notifyListeners();
      }

      final result = await _apiServices.getRestaurantDetail(id);

      if (result.data != null) {
        if (result.data!.error) {
          _resultState = RestaurantDetailErrorState(
              result.message ??
                  result.data?.message ??
                  "Unknown error occurred",
              id);
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
  }

  Future<void> addReview(String id, String name, String review) async {
    try {
      _isReviewSubmission = true;
      _reviewSubmissionError = null;
      notifyListeners();

      final result = await _apiServices.postReview(id, name, review);

      if (result.data != null && !result.data!.error) {
        if (_cache.containsKey(id)) {
          _cache[id] = _cache[id]!.copyWith(
            customerReviews: result.data!.customerReviews,
          );
          _resultState = RestaurantDetailLoadedState(_cache[id]!);
        }
      } else {
        _reviewSubmissionError =
            "Failed to submit the review. Please try again.";
      }
      notifyListeners();
    } catch (e) {
      _reviewSubmissionError = "Failed to submit the review. Please try again.";
    } finally {
      _isReviewSubmission = false;
      _isReviewSubmissionComplete = true;
      notifyListeners();
    }
  }

  void resetReviewSubmissionState() {
    _isReviewSubmissionComplete = false;
    _reviewSubmissionError = null;
    notifyListeners();
  }
}
