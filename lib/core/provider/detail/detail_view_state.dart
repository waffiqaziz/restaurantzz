import 'package:restaurantzz/core/networking/states/detail_result_state.dart';

/// Represents the UI state for the restaurant detail screen.
///
/// This state manages:
/// - The restaurant detail data result
/// - Review submission lifecycle (loading, success, error)
class DetailViewState {
  static const _unset = Object();

  final RestaurantDetailResultState resultState;
  final bool isSubmittingReview;
  final bool reviewCompleted;
  final String? reviewError;

  DetailViewState({
    required this.resultState,
    this.isSubmittingReview = false,
    this.reviewCompleted = false,
    this.reviewError,
  });

  DetailViewState copyWith({
    RestaurantDetailResultState? resultState,
    bool? isSubmittingReview,
    bool? reviewCompleted,
    Object? reviewError = _unset,
  }) {
    return DetailViewState(
      resultState: resultState ?? this.resultState,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      reviewCompleted: reviewCompleted ?? this.reviewCompleted,
      reviewError: reviewError == _unset ? this.reviewError : reviewError as String?,
    );
  }
}
