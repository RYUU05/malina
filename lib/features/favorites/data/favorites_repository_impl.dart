import 'dart:convert';

import 'package:malina/features/favorites/data/favorites_repository.dart';
import 'package:malina/features/favorites/domain/favorite_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesRemositoryImpl implements FavoritesRepository {
  static const String _key = 'favorite';
  @override
  Future<List<FavoriteItem>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => FavoriteItem.fromJson(jsonDecode(e))).toList();
  }

  @override
  Future<void> addFavorites(FavoriteItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(item.toJson()));
    await prefs.setStringList(_key, list);
  }

  @override
  Future<void> deleteFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.removeWhere((e) => FavoriteItem.fromJson(jsonDecode(e)).id == id);
    await prefs.setStringList(_key, list);
  }
}
