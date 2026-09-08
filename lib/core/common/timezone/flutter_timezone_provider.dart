import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:restaurantzz/core/common/timezone/timezone_proider.dart';

class FlutterTimezoneProvider implements TimezoneProvider {
  @override
  Future<String> getLocalTimezone() async {
    final result = await FlutterTimezone.getLocalTimezone();
    return result.identifier;
  }
}
