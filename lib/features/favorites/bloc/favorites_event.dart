part of 'favorites_bloc.dart';

abstract class FavoritesEvent {
  const FavoritesEvent();
}

final class FavoritesStarted extends FavoritesEvent {
  const FavoritesStarted();
}

final class FavoritesAdded extends FavoritesEvent {
  final FavoriteItem item;
  const FavoritesAdded({required this.item});
}

final class FavoritesDeleted extends FavoritesEvent {
  final String id;
  const FavoritesDeleted({required this.id});
}
