import 'package:malina/features/cart/domain/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> loadCart(String username);
  Future<void> saveCart(String username, List<CartItem> items);
  Future<void> clearCart(String username);
}
