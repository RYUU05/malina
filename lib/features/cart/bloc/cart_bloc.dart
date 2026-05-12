import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../cart_repository.dart';
import '../cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repo;
  final AuthBloc _authBloc;
  Timer? _debounceTimer;
  late final StreamSubscription<AuthState> _authSub;

  CartBloc(this._repo, this._authBloc) : super(const CartState()) {
    on<CartLoaded>(_onLoaded);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartItemQuantityChanged>(_onQuantityChanged);
    on<CartCleared>(_onCleared);

    _authSub = _authBloc.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated &&
          authState.username != null &&
          state.username != authState.username) {
        add(CartLoaded(authState.username!));
      }
      if (authState.status == AuthStatus.unauthenticated ||
          authState.status == AuthStatus.lockedOut) {
        _cancelPendingSave();
        add(const CartLoaded(''));
      }
    });

    if (_authBloc.state.status == AuthStatus.authenticated &&
        _authBloc.state.username != null) {
      add(CartLoaded(_authBloc.state.username!));
    }
  }

  Future<void> _onLoaded(CartLoaded event, Emitter<CartState> emit) async {
    final items = await _repo.loadCart(event.username);
    emit(state.copyWith(items: items, username: event.username));
  }

  Future<void> _onItemAdded(CartItemAdded event, Emitter<CartState> emit) async {
    final updated = [...state.items, event.item];
    emit(state.copyWith(items: updated));
    _debounceSave(updated);
  }

  Future<void> _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) async {
    final updated = state.items.where((i) => i.id != event.itemId).toList();
    emit(state.copyWith(items: updated));
    _debounceSave(updated);
  }

  Future<void> _onQuantityChanged(CartItemQuantityChanged event, Emitter<CartState> emit) async {
    final updated = state.items.map((i) {
      if (i.id != event.itemId) return i;
      final newQty = i.quantity + event.delta;
      return i.copyWith(quantity: newQty > 0 ? newQty : 0);
    }).where((i) => i.quantity > 0).toList();

    emit(state.copyWith(items: updated));
    _debounceSave(updated);
  }

  Future<void> _onCleared(CartCleared event, Emitter<CartState> emit) async {
    emit(state.copyWith(items: []));
    _debounceSave([]);
  }

  void _debounceSave(List<CartItem> items) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _repo.saveCart(state.username, items);
    });
  }

  void _cancelPendingSave() => _debounceTimer?.cancel();

  @override
  Future<void> close() {
    _authSub.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}

