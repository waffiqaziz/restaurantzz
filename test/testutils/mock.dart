import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/data/services/local_notification_service.dart';
import 'package:restaurantzz/core/data/services/shared_preferences.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workmanager/workmanager.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockApiServices extends Mock implements ApiServices {}

class MockLocalDatabaseProvider extends Mock implements LocalDatabaseProvider {}

class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

class MockWorkmanager extends Mock implements Workmanager {}

class MockDatabaseFactory extends Mock implements DatabaseFactory {}

class MockSharedPreferencesService extends Mock
    implements SharedPreferencesService {}
