import '../domain/cart_item.dart';

abstract class CartEvent {
  const CartEvent();
}

final class CartLoaded extends CartEvent {
  final String username;
  const CartLoaded(this.username);
}

final class CartItemAdded extends CartEvent {
  final CartItem item;
  const CartItemAdded(this.item);
}

final class CartItemRemoved extends CartEvent {
  final String itemId;
  const CartItemRemoved(this.itemId);
}

final class CartItemQuantityChanged extends CartEvent {
  final String itemId;
  final int delta;
  const CartItemQuantityChanged({required this.itemId, required this.delta});
}

final class CartCleared extends CartEvent {
  const CartCleared();
}
