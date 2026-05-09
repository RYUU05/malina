import '../../domain/repositories/i_cart_repository.dart';
import '../../domain/entities/cart_item.dart';
import '../datasources/cart_local_data_source.dart';

class CartRepositoryImpl implements ICartRepository {
  final ICartLocalDataSource _localDataSource;

  CartRepositoryImpl(this._localDataSource);

  @override
  Future<List<CartItem>> loadCart(String username) {
    return _localDataSource.loadCart(username);
  }

  @override
  Future<void> saveCart(String username, List<CartItem> items) {
    return _localDataSource.saveCart(username, items);
  }

  @override
  Future<void> clearCart(String username) {
    return _localDataSource.clearCart(username);
  }
}
