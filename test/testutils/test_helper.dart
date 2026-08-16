import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void ignoreNetworkImageErrors() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('HTTP request failed')) {
      // skip network image errors during tests
      return;
    }
    FlutterError.presentError(details);
  };
}

Finder findWidgetByText(String text) {
  return find.byWidgetPredicate((widget) => widget is Text && widget.data?.contains(text) == true);
}
