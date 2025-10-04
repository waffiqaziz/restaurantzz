import 'package:flutter/widgets.dart';
import 'package:restaurantzz/core/provider/favorite/local_database_provider.dart';

class FavoriteIconProvider extends ChangeNotifier {
  bool _isFavorite = false;

  bool get isFavorite => _isFavorite;

  Future<void> loadFavoriteState(
    LocalDatabaseProvider databaseProvider,
    String restaurantId,
  ) async {
    await databaseProvider.loadRestaurantById(restaurantId);
    _isFavorite = databaseProvider.checkItemBookmark(restaurantId);
    notifyListeners();
  }

  set isFavorite(bool value) {
    _isFavorite = value;
    notifyListeners();
  }
}
