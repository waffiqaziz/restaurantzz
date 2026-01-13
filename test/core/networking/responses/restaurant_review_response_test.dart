import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_detail_response.dart';
import 'package:restaurantzz/core/networking/responses/restaurant_review_response.dart';

void main() {
  group('PostReviewResponse Model Tests', () {
    test('parseCompleteJson_AssignsAllFields', () {
      const jsonResponse = '''
      {
        "error": false,
        "message": "success",
        "customerReviews": [
          {
            "name": "Ahmad",
            "review": "Tidak rekomendasi untuk pelajar!",
            "date": "13 November 2019"
          }
        ]
      }
      ''';
      final jsonData = jsonDecode(jsonResponse);
      final response = PostReviewResponse.fromJson(jsonData);

      expect(response.error, false);
      expect(response.message, 'success');
      expect(response.customerReviews.length, 1);
      expect(response.customerReviews.first.name, 'Ahmad');
    });

    test('parseJsonWithEmptyCustomerReviews_AssignsEmptyList', () {
      const jsonResponse = '''
      {
        "error": false,
        "message": "success",
        "customerReviews": []
      }
      ''';
      final jsonData = jsonDecode(jsonResponse);
      final response = PostReviewResponse.fromJson(jsonData);

      expect(response.customerReviews, isEmpty);
    });

    test('parseJsonWithMissingFields_ThrowsError', () {
      const jsonResponse = '''
      {
        "error": false
      }
      ''';
      final jsonData = jsonDecode(jsonResponse);

      expect(() => PostReviewResponse.fromJson(jsonData), throwsA(isA<TypeError>()));
    });

    test('parseJsonWithValidCustomerReviews_PopulatesList', () {
      const jsonResponse = '''
      {
        "error": false,
        "message": "success",
        "customerReviews": [
          {
            "name": "Guest",
            "review": "test review",
            "date": "4 February 2025"
          },
          {
            "name": "User2",
            "review": "test multiple",
            "date": "4 February 2025"
          }
        ]
      }
      ''';
      final jsonData = jsonDecode(jsonResponse);
      final response = PostReviewResponse.fromJson(jsonData);

      expect(response.customerReviews.length, 2);
      expect(response.customerReviews[0].name, 'Guest');
      expect(response.customerReviews[1].review, 'test multiple');
    });

    test('toJson_ReturnsEquivalentJsonStructure', () {
      final reviewList = [
        CustomerReview(name: "Guest", review: "Nice", date: "4 February 2025"),
        CustomerReview(name: "Kevin", review: "Delicious", date: "4 February 2025"),
      ];
      final response = PostReviewResponse(
        error: false,
        message: 'success',
        customerReviews: reviewList,
      );

      final jsonResult = response.toJson();

      expect(jsonResult["error"], false);
      expect(jsonResult["message"], 'success');
      expect(jsonResult["customerReviews"].length, 2);
      expect(jsonResult["customerReviews"][0]["name"], "Guest");
    });
  });
}
