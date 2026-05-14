import 'dart:convert';
import 'package:malina/features/cart/data/cart_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/cart_item.dart';

class CartRepositoryImpl implements CartRepository {
  final SharedPreferences _prefs;
  static const _keyPrefix = 'cart_items_';

  CartRepositoryImpl(this._prefs);

  @override
  Future<List<CartItem>> loadCart(String username) async {
    if (username.isEmpty) return [];
    final json = _prefs.getString(_keyPrefix + username);
    if (json == null) return [];

    final List<dynamic> list = jsonDecode(json);
    return list
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveCart(String username, List<CartItem> items) async {
    if (username.isEmpty) return;
    final json = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyPrefix + username, json);
  }

  @override
  Future<void> clearCart(String username) async {
    if (username.isEmpty) return;
    await _prefs.remove(_keyPrefix + username);
  }
}
