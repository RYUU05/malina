import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/auth_repository.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/cart/cart_repository.dart';
import '../../features/cart/bloc/cart_bloc.dart';

final locator = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton<SharedPreferences>(() => prefs);

  // Repositories
  locator.registerLazySingleton<AuthRepository>(() => AuthRepository(locator()));
  locator.registerLazySingleton<CartRepository>(() => CartRepository(locator()));

  // Blocs
  locator.registerLazySingleton<AuthBloc>(() => AuthBloc(locator()));
  
  locator.registerFactory<CartBloc>(
    () => CartBloc(
      locator(),
      locator<AuthBloc>(),
    ),
  );
}

