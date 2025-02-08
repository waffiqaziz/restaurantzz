import 'package:flutter_test/flutter_test.dart';
import 'package:restaurantzz/core/provider/detail/favorite_icon_provider.dart';

void main() {
  group('FavoriteIconProvider', () {
    test('initialValue_isNotFavorite', () {
      final provider = FavoriteIconProvider();

      expect(provider.isFavorite, isFalse);
    });

    test('settingFavoriteValue_notifiesListeners', () {
      final provider = FavoriteIconProvider();
      bool notified = false;

      provider.addListener(() {
        notified = true;
      });

      provider.isFavorite = true;

      expect(notified, isTrue);
    });

    test('setFavoriteValue_updatesIsFavorite', () {
      final provider = FavoriteIconProvider();

      provider.isFavorite = true;

      expect(provider.isFavorite, isTrue);
    });
  });
}
