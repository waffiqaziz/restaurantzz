import 'package:flutter/material.dart';

void ignoreNetworkImageErrors() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('HTTP request failed')) {
      // skip network image errors during tests
      return;
    }
    FlutterError.presentError(details);
  };
}
