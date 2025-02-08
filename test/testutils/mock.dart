import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockApiServices extends Mock implements ApiServices {}

class MockLocalDatabaseProvider extends Mock implements LocalDatabaseProvider {}
