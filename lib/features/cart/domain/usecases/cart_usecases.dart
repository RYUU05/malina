import '../../domain/entities/cart_item.dart';
import '../repositories/i_cart_repository.dart';

class LoadCartUseCase {
  final ICartRepository _cartRepository;

  LoadCartUseCase(this._cartRepository);

  Future<List<CartItem>> call(String username) async {
    return _cartRepository.loadCart(username);
  }
}

class SaveCartUseCase {
  final ICartRepository _cartRepository;

  SaveCartUseCase(this._cartRepository);

  Future<void> call(String username, List<CartItem> items) async {
    return _cartRepository.saveCart(username, items);
  }
}

class ClearCartUseCase {
  final ICartRepository _cartRepository;

  ClearCartUseCase(this._cartRepository);

  Future<void> call(String username) async {
    return _cartRepository.clearCart(username);
  }
}
