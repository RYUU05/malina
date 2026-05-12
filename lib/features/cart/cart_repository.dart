import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_item.dart';

class CartRepository {
  final SharedPreferences _prefs;
  static const _keyPrefix = 'cart_items_';

  CartRepository(this._prefs);

  Future<List<CartItem>> loadCart(String username) async {
    if (username.isEmpty) return [];
    final json = _prefs.getString(_keyPrefix + username);
    if (json == null) return [];
    
    final List<dynamic> list = jsonDecode(json);
    return list.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveCart(String username, List<CartItem> items) async {
    if (username.isEmpty) return;
    final json = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyPrefix + username, json);
  }

  Future<void> clearCart(String username) async {
    if (username.isEmpty) return;
    await _prefs.remove(_keyPrefix + username);
  }
}
