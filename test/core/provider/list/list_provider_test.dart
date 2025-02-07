import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/networking/services/api_services.dart';
import 'package:restaurantzz/core/networking/states/list_result_state.dart';
import 'package:restaurantzz/core/provider/list/list_provider.dart';

import '../../../testutils/mock_client.dart';

void main() {
  group('ListProvider', () {
    late ListProvider listProvider;
    late MockHttpClient mockHttpClient;
    late ApiServices apiServices;

    setUp(() {
      mockHttpClient = MockHttpClient();
      apiServices = ApiServices(httpClient: mockHttpClient);
      listProvider = ListProvider(apiServices);
    });

    test('initialState_shouldBeNoneState', () {
      expect(listProvider.resultState, isA<RestaurantListNoneState>());
    });

    test('fetchRestaurantList_shouldNotifyLoadingThenReturnListOnSuccess',
        () async {
      final mockResponseData = {
        "error": false,
        "message": "success",
        "count": 4,
        "restaurants": [
          {
            "id": "rqdv5juczeskfw1e867",
            "name": "Melting Pot",
            "description":
                "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet.",
            "pictureId": "14",
            "city": "Medan",
            "rating": 4.2
          },
          {
            "id": "s1knt6za9kkfw1e867",
            "name": "Kafe Kita",
            "description":
                "Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,",
            "pictureId": "25",
            "city": "Gorontalo",
            "rating": 4
          },
          {
            "id": "w9pga3s2tubkfw1e867",
            "name": "Bring Your Phone Cafe",
            "description":
                "Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,",
            "pictureId": "03",
            "city": "Surabaya",
            "rating": 4.2
          },
          {
            "id": "uewq1zg2zlskfw1e867",
            "name": "Kafein",
            "description":
                "Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,",
            "pictureId": "15",
            "city": "Aceh",
            "rating": 4.6
          }
        ]
      };

      when(() => mockHttpClient
              .get(Uri.parse("https://restaurant-api.dicoding.dev/list")))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return http.Response(jsonEncode(mockResponseData), 200);
      });
      bool loadingStateObserved = false; // loading flag

      // get the loading state
      listProvider.addListener(() {
        if (listProvider.resultState is RestaurantListLoadingState) {
          loadingStateObserved = true;
        }
      });

      await listProvider.fetchRestaurantList();

      // assert loading state was observed
      expect(loadingStateObserved, isTrue);

      // Assert loaded state after API completes
      expect(listProvider.resultState, isA<RestaurantListLoadedState>());
      final state = listProvider.resultState as RestaurantListLoadedState;
      expect(state.data.length, 4);
      expect(state.data.first.name, "Melting Pot");
      expect(state.data[1].name, "Kafe Kita");
      expect(state.data[2].name, "Bring Your Phone Cafe");
      expect(state.data[3].name, "Kafein");
    });

    test('fetchRestaurantList_shouldReturnErrorWhenErrorTrue', () async {
      final mockResponseData = {
        "error": true,
        "message": "Server Error",
        "count": 0,
        "restaurants": []
      };

      when(() => mockHttpClient
              .get(Uri.parse("https://restaurant-api.dicoding.dev/list")))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return http.Response(jsonEncode(mockResponseData), 200);
      });
      await listProvider.fetchRestaurantList();

      expect(listProvider.resultState, isA<RestaurantListErrorState>());
      final state = listProvider.resultState as RestaurantListErrorState;
      expect(state.error, contains('Server Error'));
    });

    test('fetchRestaurantList_shouldReturnErrorOnFailure', () async {
      when(() => mockHttpClient
              .get(Uri.parse("https://restaurant-api.dicoding.dev/list")))
          .thenAnswer((_) async =>
              http.Response('{"message": "Internal Server Error"}', 500));

      await listProvider.fetchRestaurantList();

      expect(listProvider.resultState, isA<RestaurantListErrorState>());
      final state = listProvider.resultState as RestaurantListErrorState;
      expect(state.error, contains('Failed to load restaurant list'));
    });
  });
}
