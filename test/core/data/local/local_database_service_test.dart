import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/data/local/local_database_service.dart';
import 'package:restaurantzz/core/data/model/restaurant.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late LocalDatabaseService databaseService;
  final testRestaurant = Restaurant(
    id: '1',
    name: 'Test Restaurant',
    description: 'Description',
    pictureId: '1',
    city: 'Test City',
    rating: 4.5,
  );

  setUp(() async {
    sqfliteFfiInit();
    databaseService = LocalDatabaseService();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await databaseService.clearDatabase();
  });

  test('insertItem_SavesDataCorrectly', () async {
    final resultId = await databaseService.insertItem(testRestaurant);
    expect(resultId, 1);
  });

  test('getAllItems_ReturnsInsertedItems', () async {
    await databaseService.insertItem(testRestaurant);
    final restaurants = await databaseService.getAllItems();
    expect(restaurants.length, 1);
    expect(restaurants.first.name, testRestaurant.name);
  });

  test('getItemById_ReturnsCorrectItem', () async {
    await databaseService.insertItem(testRestaurant);
    final restaurant = await databaseService.getItemById('1');
    expect(restaurant.name, testRestaurant.name);
  });

  test('removeItem_DeletesCorrectItem', () async {
    await databaseService.insertItem(testRestaurant);
    final deleteCount = await databaseService.removeItem('1');
    expect(deleteCount, 1);

    final remainingItems = await databaseService.getAllItems();
    expect(remainingItems.isEmpty, true);
  });

  test('initializeDb_CreatesTableWhenMissing', () async {
    final db = await databaseService.database;
    final tables =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");

    expect(tables.any((table) => table["name"] == "restaurant"), true);
  });

  test('insertItem_StoresValidDataSuccessfully', () async {
    final insertedId = await databaseService.insertItem(testRestaurant);

    expect(insertedId, isNonZero);
  });

  test('getAllItems_ReturnsListOfRestaurantsWhenDataExists', () async {
    final restaurant1 = Restaurant(
        id: '1',
        name: 'Restaurant One',
        description: 'Desc 1',
        pictureId: '1',
        city: 'City 1',
        rating: 4.2);
    final restaurant2 = Restaurant(
        id: '2',
        name: 'Restaurant Two',
        description: 'Desc 2',
        pictureId: '2',
        city: 'City 2',
        rating: 3.8);

    await databaseService.insertItem(restaurant1);
    await databaseService.insertItem(restaurant2);

    final allRestaurants = await databaseService.getAllItems();

    expect(allRestaurants.length, 2);
    expect(allRestaurants.map((e) => e.name),
        containsAll(['Restaurant One', 'Restaurant Two']));
  });

  test('getItemById_ReturnsCorrectItemWhenExists', () async {
    await databaseService.insertItem(testRestaurant);
    final fetchedItem = await databaseService.getItemById('1');

    expect(fetchedItem.name, 'Test Restaurant');
  });

  test('getItemById_ThrowsWhenItemDoesNotExist', () async {
    expect(() => databaseService.getItemById('999'), throwsException);
  });

  test('removeItem_SuccessfullyDeletesExistingItem', () async {
    await databaseService.insertItem(testRestaurant);
    final deletedRows = await databaseService.removeItem('1');

    expect(deletedRows, 1);

    final remainingItems = await databaseService.getAllItems();
    expect(remainingItems.isEmpty, true);
  });

  test('removeItem_NoErrorWhenDeletingNonExistentItem', () async {
    final deletedRows = await databaseService.removeItem('nonexistent');
    expect(deletedRows, 0);
  });

  test('insertItem_ReplacesDuplicateItemWithSameId', () async {
    final restaurant1 = Restaurant(
        id: '1',
        name: 'Initial Name',
        description: 'Desc 1',
        pictureId: '1',
        city: 'City 1',
        rating: 4.2);
    final restaurant2 = Restaurant(
        id: '1',
        name: 'Updated Name',
        description: 'Desc 2',
        pictureId: '2',
        city: 'City 2',
        rating: 5.0);

    await databaseService.insertItem(restaurant1);
    await databaseService.insertItem(restaurant2);

    final fetchedItem = await databaseService.getItemById('1');
    expect(fetchedItem.name, 'Updated Name');
  });
}
