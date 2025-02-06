import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/utils/helper.dart';

void main() {
  group('FormatRating', () {
    test('shouldHandleSingleDigitCorrectly', () {
      // Test input with a single digit
      final result = Helper.formatRating('9');
      expect(result, '9.0');
    });

    test('shouldHandleDoubleDigitCorrectly', () {
      // Test input with more than one digit
      final result = Helper.formatRating('12');
      expect(result, '12');
    });
  });
}
