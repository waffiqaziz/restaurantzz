import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/data/local/local_database_service.dart';
import 'package:restaurantzz/core/data/model/setting.dart';
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:restaurantzz/core/data/services/shared_preferences.dart';
import 'package:restaurantzz/core/data/services/workmanager_service.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/provider/detail/detail_provider.dart';
import 'package:restaurantzz/core/provider/detail/favorite_icon_provider.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';
import 'package:restaurantzz/core/provider/notification/local_notification_provider.dart';
import 'package:restaurantzz/core/provider/setting/shared_preferences_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workmanager/workmanager.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockApiServices extends Mock implements ApiServices {}

class MockLocalDatabaseProvider extends Mock implements LocalDatabaseProvider {}

class MockDetailProvider extends Mock implements DetailProvider {}

class MockSharedPreferencesProvider extends Mock
    implements SharedPreferencesProvider {}

class MockLocalNotificationProvider extends Mock
    implements LocalNotificationProvider {}

class MockLocalDatabaseService extends Mock implements LocalDatabaseService {}

class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

class MockWorkmanager extends Mock implements Workmanager {}

class MockDatabaseFactory extends Mock implements DatabaseFactory {}

class MockSharedPreferencesService extends Mock
    implements SharedPreferencesService {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockWorkmanagerService extends Mock implements WorkmanagerService {}

class FakeSetting extends Fake implements Setting {}

class MockFavoriteIconProvider extends Mock implements FavoriteIconProvider {}

class FakeUri extends Fake implements Uri {}
