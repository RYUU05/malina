import 'package:get_it/get_it.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/cart/bloc/cart_bloc.dart';
import '../../features/cart/data/cart_repository.dart';

final locator = GetIt.instance;

Future<void> setupDependencies() async {
  locator.registerLazySingleton<AuthRepository>(AuthRepository.new);
  locator.registerLazySingleton<CartRepository>(CartRepository.new);
  locator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(locator<AuthRepository>()),
  );
  locator.registerFactory<CartBloc>(
    () => CartBloc(locator<CartRepository>(), locator<AuthBloc>()),
  );
}
