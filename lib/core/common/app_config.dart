import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConfig {
  bool showNotificationView(BuildContext context) {
    return !kIsWeb &&
        (Theme.of(context).platform == TargetPlatform.iOS ||
            Theme.of(context).platform == TargetPlatform.android);
  }
}
