import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/utils/helper.dart';

void main() {
  group('Helper', () {
    test('formatRating should add .0 to a single-digit rating', () {
      // Test input with a single digit
      final result = Helper.formatRating('9');
      expect(result, '9.0');
    });

    test('formatRating should not modify multi-digit rating', () {
      // Test input with more than one digit
      final result = Helper.formatRating('12');
      expect(result, '12');
    });
  });
}
