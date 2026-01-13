import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';

import '../../../testutils/mock.dart';

void main() {
  group("LocalDatabaseProvider", () {
    late LocalDatabaseProvider provider;
    late MockLocalDatabaseService mockService;
    final testRestaurant = Restaurant(
      id: '1',
      name: 'Test Restaurant',
      description: 'Test Description',
      pictureId: 'Test Picture ID',
      city: 'Test City',
      rating: 9,
    );

    setUp(() {
      mockService = MockLocalDatabaseService();
      provider = LocalDatabaseProvider(mockService);
    });

    test('saveRestaurant_successUpdatesMessageAndNotifiesListeners', () async {
      when(() => mockService.insertItem(testRestaurant)).thenAnswer((_) async => 1);

      await provider.saveRestaurant(testRestaurant);

      expect(provider.message, "Your data is saved");
      verify(() => mockService.insertItem(testRestaurant)).called(1);
    });

    test('saveRestaurant_failureUpdatesMessageAndNotifiesListeners', () async {
      when(() => mockService.insertItem(testRestaurant)).thenThrow(Exception());

      await provider.saveRestaurant(testRestaurant);

      expect(provider.message, "Failed to save your data");
    });

    test('saveRestaurant_errorUpdatesMessageAndNotifiesListeners', () async {
      when(() => mockService.insertItem(testRestaurant)).thenAnswer((_) async => 0);

      await provider.saveRestaurant(testRestaurant);

      expect(provider.message, "Failed to save your data");
    });

    test('loadAllRestaurant_successLoadsDataAndNotifiesListeners', () async {
      final restaurants = [testRestaurant];

      when(() => mockService.getAllItems()).thenAnswer((_) async => restaurants);

      await provider.loadAllRestaurant();

      expect(provider.restaurantList, restaurants);
      expect(provider.message, "All of your data is loaded");
    });

    test('loadAllRestaurant_failureUpdatesMessageAndNotifiesListeners', () async {
      when(() => mockService.getAllItems()).thenThrow(Exception());

      await provider.loadAllRestaurant();

      expect(provider.message, "Failed to load your all data");
    });

    test('loadRestaurantById_successLoadsRestaurantAndNotifiesListeners', () async {
      when(() => mockService.getItemById('1')).thenAnswer((_) async => testRestaurant);

      await provider.loadRestaurantById('1');

      expect(provider.restaurant, testRestaurant);
      expect(provider.message, "Your data is loaded");
    });

    test('loadRestaurantById_failureUpdatesMessageAndNotifiesListeners', () async {
      when(() => mockService.getItemById('1')).thenThrow(Exception());

      await provider.loadRestaurantById('1');

      expect(provider.message, "Failed to load your data");
    });

    test('removeRestaurantById_successUpdatesMessageAndNotifiesListeners', () async {
      when(() => mockService.removeItem('1')).thenAnswer((_) async => 1);

      await provider.removeRestaurantById('1');

      expect(provider.message, "Your data is removed");
      verify(() => mockService.removeItem('1')).called(1);
    });

    test('removeRestaurantById_failureUpdatesMessageAndNotifiesListeners', () async {
      when(() => mockService.removeItem('1')).thenThrow(Exception());

      await provider.removeRestaurantById('1');

      expect(provider.message, "Failed to remove your data");
    });

    test('checkItemBookmark_withMatchingIdReturnsTrue', () async {
      when(() => mockService.getItemById('1')).thenAnswer((_) async => testRestaurant);

      await provider.loadRestaurantById('1');

      final result = provider.checkItemBookmark('1');

      expect(result, true);
    });

    test('checkItemBookmark_withNonMatchingIdReturnsFalse', () {
      final result = provider.checkItemBookmark('2');

      expect(result, false);
    });
  });
}
