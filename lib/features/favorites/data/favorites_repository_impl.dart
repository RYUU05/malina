import 'dart:convert';

import 'package:malina/features/favorites/data/favorites_repository.dart';
import 'package:malina/features/favorites/domain/favorite_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  static const String _storageKey = 'favorites_items';

  final SharedPreferences _prefs;

  FavoritesRepositoryImpl(this._prefs);

  @override
  Future<List<FavoriteItem>> loadFavorites() async {
    final rawItems = _prefs.getStringList(_storageKey) ?? const [];
    return rawItems.map(_decodeItem).toList(growable: false);
  }

  @override
  Future<void> saveFavorite(FavoriteItem item) async {
    final items = (await loadFavorites()).toList();
    final index = items.indexWhere((favorite) => favorite.id == item.id);

    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }

    await _persist(items);
  }

  @override
  Future<void> removeFavorite(String id) async {
    final items = await loadFavorites();
    final updated = items.where((item) => item.id != id).toList();
    await _persist(updated);
  }

  FavoriteItem _decodeItem(String raw) {
    return FavoriteItem.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _persist(List<FavoriteItem> items) {
    final encodedItems = items
        .map((item) => jsonEncode(item.toJson()))
        .toList(growable: false);
    return _prefs.setStringList(_storageKey, encodedItems);
  }
}
