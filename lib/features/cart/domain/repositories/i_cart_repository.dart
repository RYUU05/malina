import '../../domain/entities/cart_item.dart';

abstract class ICartRepository {
  Future<List<CartItem>> loadCart(String username);
  Future<void> saveCart(String username, List<CartItem> items);
  Future<void> clearCart(String username);
}
