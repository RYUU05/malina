import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models/cart_item.dart';

class CartRepository {
  String _cartKey(String username) => 'user_${username}_cart';

  Future<List<CartItem>> loadCart(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey(username));
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(raw);
    return jsonList.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveCart(String username, List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((e) => e.toJson()).toList();
    await prefs.setString(_cartKey(username), jsonEncode(jsonList));
  }

  Future<void> clearCart(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey(username));
  }
}
