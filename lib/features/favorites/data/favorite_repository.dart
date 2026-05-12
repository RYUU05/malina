import 'package:malina/features/favorites/domain/favorite_item.dart';

abstract class FavoriteRepository {
  Future<List<FavoriteItem>> getFavorites();
  Future<void> addFavorites(FavoriteItem item);
  Future<void> deleteFavorite(String id);
}
