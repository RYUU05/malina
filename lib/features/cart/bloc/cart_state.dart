import '../domain/cart_item.dart';

class CartState {
  final List<CartItem> items;
  final String username;

  const CartState({this.items = const [], this.username = ''});

  CartState copyWith({List<CartItem>? items, String? username}) {
    return CartState(
      items: items ?? this.items,
      username: username ?? this.username,
    );
  }
}
