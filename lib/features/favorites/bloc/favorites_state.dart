part of 'favorites_bloc.dart';

abstract class FavoritesState {
  const FavoritesState();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteItem> items;
  const FavoritesLoaded({required this.items});
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError({required this.message});
}
