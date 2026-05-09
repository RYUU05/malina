import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../data/cart_repository.dart';
import '../data/models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;
  final AuthBloc _authBloc;
  Timer? _debounceTimer;
  late final StreamSubscription<AuthState> _authSub;

  CartBloc(this._cartRepository, this._authBloc) : super(const CartState()) {
    on<CartLoaded>(_onLoaded);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartItemQuantityChanged>(_onQuantityChanged);

    _authSub = _authBloc.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated &&
          authState.username != null &&
          state.username != authState.username) {
        add(CartLoaded(authState.username!));
      }
      if (authState.status == AuthStatus.unauthenticated ||
          authState.status == AuthStatus.lockedOut) {
        cancelPendingSave();
        add(const CartLoaded(''));
      }
    });

    // Load cart if already authenticated at creation time
    if (_authBloc.state.status == AuthStatus.authenticated &&
        _authBloc.state.username != null) {
      add(CartLoaded(_authBloc.state.username!));
    }
  }

  Future<void> _onLoaded(CartLoaded event, Emitter<CartState> emit) async {
    final items = await _cartRepository.loadCart(event.username);
    emit(state.copyWith(items: items, username: event.username));
  }

  Future<void> _onItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    final updated = [...state.items, event.item];
    emit(state.copyWith(items: updated));
    _debounceSave(updated);
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final updated = state.items.where((i) => i.id != event.itemId).toList();
    emit(state.copyWith(items: updated));
    _debounceSave(updated);
  }

  Future<void> _onQuantityChanged(
    CartItemQuantityChanged event,
    Emitter<CartState> emit,
  ) async {
    final updated = state.items
        .map((i) {
          if (i.id == event.itemId) {
            final newQty = i.quantity + event.delta;
            if (newQty <= 0) return i.copyWith(quantity: 0);
            return i.copyWith(quantity: newQty);
          }
          return i;
        })
        .where((i) => i.quantity > 0)
        .toList();

    emit(state.copyWith(items: updated));
    _debounceSave(updated);
  }

  void _debounceSave(List<CartItem> items) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _cartRepository.saveCart(state.username, items);
    });
  }

  /// Immediately save any pending debounced changes.
  Future<void> flushSave() async {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
      await _cartRepository.saveCart(state.username, state.items);
    }
  }

  /// Cancel any pending debounced save without saving.
  void cancelPendingSave() {
    _debounceTimer?.cancel();
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}
