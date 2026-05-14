part of 'favorites_bloc.dart';

abstract class FavoritesState {
  const FavoritesState();
}

final class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

final class FavoritesLoaded extends FavoritesState {
  final List<FavoriteItem> items;
  const FavoritesLoaded({required this.items});
}

final class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError({required this.message});
}
