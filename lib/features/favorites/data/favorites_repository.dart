import 'package:malina/features/favorites/domain/favorite_item.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteItem>> loadFavorites();
  Future<void> saveFavorite(FavoriteItem item);
  Future<void> removeFavorite(String id);
}
