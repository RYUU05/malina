import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';

import '../../features/cart/bloc/cart_bloc.dart';
import '../../features/cart/data/datasources/cart_local_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/i_cart_repository.dart';
import '../../features/cart/domain/usecases/cart_usecases.dart';

final locator = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton<SharedPreferences>(() => prefs);

  // Auth Data Sources
  locator.registerLazySingleton<IAuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(locator()),
  );

  // Auth Repositories
  locator.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(locator()),
  );

  // Auth Use Cases
  locator.registerLazySingleton(() => LoginUseCase(locator()));
  locator.registerLazySingleton(() => LogoutUseCase(locator()));
  locator.registerLazySingleton(() => CheckAuthStatusUseCase(locator()));
  locator.registerLazySingleton(() => DeleteUserUseCase(locator()));
  locator.registerLazySingleton(() => GetFailedAttemptsUseCase(locator()));

  // Auth Bloc
  locator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
    ),
  );

  // Cart Data Sources
  locator.registerLazySingleton<ICartLocalDataSource>(
    () => CartLocalDataSourceImpl(locator()),
  );

  // Cart Repositories
  locator.registerLazySingleton<ICartRepository>(
    () => CartRepositoryImpl(locator()),
  );

  // Cart Use Cases
  locator.registerLazySingleton(() => LoadCartUseCase(locator()));
  locator.registerLazySingleton(() => SaveCartUseCase(locator()));
  locator.registerLazySingleton(() => ClearCartUseCase(locator()));

  // Cart Bloc
  locator.registerFactory<CartBloc>(
    () => CartBloc(
      locator(),
      locator(),
      locator<AuthBloc>(),
    ),
  );
}
