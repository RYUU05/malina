part of 'favorites_bloc.dart';

abstract class FavoritesEvent {
  const FavoritesEvent();
}

class FavoritesStarted extends FavoritesEvent {}

class FavoritesAdded extends FavoritesEvent {
  final FavoriteItem item;
  const FavoritesAdded({required this.item});
}

class FavoritesDeleted extends FavoritesEvent {
  final String id;
  const FavoritesDeleted({required this.id});
}
