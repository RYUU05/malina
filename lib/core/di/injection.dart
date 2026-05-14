import 'package:get_it/get_it.dart';
import 'package:malina/features/cart/data/cart_repository.dart';
import 'package:malina/features/favorites/bloc/favorites_bloc.dart';
import 'package:malina/features/favorites/data/favorites_repository.dart';
import 'package:malina/features/favorites/data/favorites_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/auth_repository.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/cart/data/cart_repository_impl.dart';
import '../../features/cart/bloc/cart_bloc.dart';

final locator = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton<SharedPreferences>(() => prefs);

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(locator()),
  );
  locator.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(locator()),
  );

  // Blocs
  locator.registerLazySingleton<AuthBloc>(() => AuthBloc(locator()));

  locator.registerFactory<CartBloc>(
    () => CartBloc(locator(), locator<AuthBloc>()),
  );

  locator.registerFactory<FavoritesBloc>(
    () => FavoritesBloc(repository: locator()),
  );
}
