import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';

class PostReviewResponse {
  bool error;
  String message;
  List<CustomerReview> customerReviews;

  PostReviewResponse({required this.error, required this.message, required this.customerReviews});

  factory PostReviewResponse.fromJson(Map<String, dynamic> json) => PostReviewResponse(
    error: json["error"],
    message: json["message"],
    customerReviews: List<CustomerReview>.from(
      json["customerReviews"].map((x) => CustomerReview.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "customerReviews": List<dynamic>.from(customerReviews.map((x) => x.toJson())),
  };
}
