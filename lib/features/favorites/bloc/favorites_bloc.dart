import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malina/features/favorites/data/favorites_repository.dart';
import 'package:malina/features/favorites/domain/favorite_item.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesBloc({required FavoritesRepository repository})
    : _repository = repository,
      super(const FavoritesLoading()) {
    on<FavoritesStarted>(_onStarted);
    on<FavoritesAdded>(_onItemAdded);
    on<FavoritesDeleted>(_onItemRemoved);
  }

  Future<void> _onStarted(
    FavoritesStarted event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());
    try {
      final items = await _repository.loadFavorites();
      emit(FavoritesLoaded(items: items));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }

  Future<void> _onItemAdded(
    FavoritesAdded event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _repository.saveFavorite(event.item);
      final items = await _repository.loadFavorites();
      emit(FavoritesLoaded(items: items));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }

  Future<void> _onItemRemoved(
    FavoritesDeleted event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _repository.removeFavorite(event.id);
      final items = await _repository.loadFavorites();
      emit(FavoritesLoaded(items: items));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }
}
