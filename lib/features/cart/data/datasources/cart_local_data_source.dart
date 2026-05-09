import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/cart_item.dart';

abstract class ICartLocalDataSource {
  Future<List<CartItem>> loadCart(String username);
  Future<void> saveCart(String username, List<CartItem> items);
  Future<void> clearCart(String username);
}

class CartLocalDataSourceImpl implements ICartLocalDataSource {
  final SharedPreferences _prefs;

  CartLocalDataSourceImpl(this._prefs);

  String _cartKey(String username) => 'user_${username}_cart';

  @override
  Future<List<CartItem>> loadCart(String username) async {
    final raw = _prefs.getString(_cartKey(username));
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(raw);
    return jsonList.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> saveCart(String username, List<CartItem> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    await _prefs.setString(_cartKey(username), jsonEncode(jsonList));
  }

  @override
  Future<void> clearCart(String username) async {
    await _prefs.remove(_cartKey(username));
  }
}
