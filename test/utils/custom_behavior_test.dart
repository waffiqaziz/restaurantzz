import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/utils/custom_behavior.dart';

void main() {
  group('CustomScrollBehavior', () {
    test('dragDevices_ReturnsTouchAndMouseKinds', () {
      final scrollBehavior = CustomScrollBehavior();

      // Assert that the dragDevices set contains touch and mouse kinds
      expect(scrollBehavior.dragDevices,
          containsAll([PointerDeviceKind.touch, PointerDeviceKind.mouse]));
    });
  });
}
